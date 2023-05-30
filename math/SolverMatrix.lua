-------------------------------------------------------------------------------
---Description of the module.
---@class SolverMatrix
SolverMatrix = newclass(function(base)
end)

-------------------------------------------------------------------------------
---Clone la matrice
---@param matrix Matrix
---@return Matrix
function SolverMatrix:clone(matrix)
    local matrix_clone = table.deepcopy(matrix)
    return matrix_clone
end

-------------------------------------------------------------------------------
---Prepare la matrice
---@param matrix Matrix
---@return Matrix
function SolverMatrix:prepare(matrix)
    local matrix_clone = self:clone(matrix)
    local row = {}
    local objective_values = {}
    ---ajoute la ligne Z avec Z=-input
    for _, column in pairs(matrix_clone.columns) do
        local objective = matrix_clone.objectives[column.key]
        local objective_value = 0
        if objective ~= nil then
            objective_value = objective.value
        end
        local value = 0 - objective_value
        table.insert(row, value)
        table.insert(objective_values, objective_value)
    end
    matrix_clone.objective_values = objective_values
    table.insert(matrix_clone.rows, row)
    return matrix_clone
end

-------------------------------------------------------------------------------
---Finalise la matrice
---@param matrix Matrix
---@return Matrix
function SolverMatrix:finalize(matrix)
    ---finalize la ligne Z reinject le input Z=Z+input
    local zrow = matrix.rows[#matrix.rows]
    for icol, column in pairs(matrix.columns) do
        local objective = matrix.objective_values[icol] or 0
        zrow[icol] = zrow[icol] + objective
    end
    return matrix
end

-------------------------------------------------------------------------------
---Add runtime
---@param debug boolean
---@param runtime table
---@param name string
---@param matrix Matrix
---@param pivot table
function SolverMatrix:add_runtime(debug, runtime, name, matrix, pivot)
    if debug == true then
        local clone = table.deepcopy(matrix)
        table.insert(runtime, { name = name, matrix = clone, pivot = pivot })
    end
end

-------------------------------------------------------------------------------
---Ajoute la ligne State
---state = 0 => produit
---state = 1 => produit pilotant
---state = 2 => produit restant
---state = 3 => produit surplus
---@param matrix Matrix
---@return Matrix
function SolverMatrix:apply_state(matrix)
    local states = {}
    for irow, row in pairs(matrix.rows) do
        if irow < #matrix.rows then
            for icol, column in pairs(matrix.columns) do
                local cell_value = row[icol] or 0
                if states[icol] == nil then
                    table.insert(states, 0)
                end
                if cell_value < 0 then
                    states[icol] = 2
                end
                if cell_value > 0 and states[icol] ~= 2 then
                    states[icol] = 1
                end
            end
        end
    end
    local zrow = matrix.rows[#matrix.rows]
    for icol, cell in pairs(zrow) do
        if cell > 0 and states[icol] == 2 then
            states[icol] = 3
        end
    end
    matrix.states = states
    return matrix
end

-------------------------------------------------------------------------------
---Resoud la matrice
---@param matrix_base Matrix
---@param debug boolean
---@param by_factory boolean
---@param time number
---@return Matrix, table
function SolverMatrix:solve_matrix(matrix_base, debug, by_factory, time)
end
-------------------------------------------------------------------------------
---Return a matrix of block
---@param block table
---@param debug boolean
---@return table
function SolverMatrix:solve(block, debug)
    local mC, runtimes

    local ok, err = pcall(function()
        local mA = SolverMatrix.get_block_matrix(block)
        if mA ~= nil then
            mC, runtimes = self:solve_matrix(mA, debug, block.by_factory, block.time)
        end
    end)
    if not (ok) then
        if block.solver == true and block.by_factory ~= true then
            Player.print("Matrix solver can not find solution!")
        else
            Player.print("Algebraic solver can not find solution!")
        end
        if debug then
            Player.print(err)
        end
    end
    if debug then
        block.runtimes = runtimes
    else
        block.runtimes = nil
    end

    if mC ~= nil then
        ---remove temperature convert lines
        for i = #mC, 1, -1 do
            if mC[i][1].name == "helmod-temperature-convert" then
                table.remove(mC, i)
            end
        end

        ---ratio pour le calcul du nombre de block
        local ratio = 1
        ---calcul ordonnee sur les recipes du block
        local row_index = 1
        local sorter = function(t, a, b) return t[b].index > t[a].index end
        if block.by_product == false then
            sorter = function(t, a, b) return t[b].index < t[a].index end
        end

        local recipes = block.recipes
        for _, recipe in spairs(recipes, sorter) do
            local parameters = mC.parameters[row_index]
            if parameters.recipe_count > 0 then
                recipe.count = parameters.recipe_count
                recipe.production = parameters.recipe_production
            else
                recipe.count = 0
            end
            row_index = row_index + 1
            ---calcul dependant du recipe count
            if recipe.type == "energy" then
                ModelCompute.computeEnergyFactory(recipe)
            else
                ModelCompute.computeFactory(recipe)
            end

            block.power = block.power + recipe.energy_total
            block.pollution_total = block.pollution_total + recipe.pollution_total

            if type(recipe.factory.limit) == "number" and recipe.factory.limit > 0 then
                local currentRatio = recipe.factory.limit / recipe.factory.count
                if currentRatio < ratio then
                    ratio = currentRatio
                    ---block number
                    block.count = recipe.factory.count / recipe.factory.limit
                    ---subblock energy
                    if block.count ~= nil and block.count > 0 then
                    end
                end
            end
        end

        if block.count <= 1 then
            block.count = 1
            block.limit_energy = nil
            block.limit_pollution = nil
            block.limit_building = nil
            for _, recipe in spairs(recipes, function(t, a, b) return t[b].index > t[a].index end) do
                recipe.factory.limit_count = nil
                recipe.beacon.limit_count = nil
                recipe.limit_energy = nil
                recipe.limit_pollution = nil
            end
        else
            block.limit_energy = block.power / block.count
            block.limit_pollution = block.pollution_total / block.count
            for _, recipe in spairs(recipes, function(t, a, b) return t[b].index > t[a].index end) do
                recipe.factory.limit_count = recipe.factory.count / block.count
                recipe.beacon.limit_count = recipe.beacon.count / block.count
                recipe.limit_energy = recipe.energy_total / block.count
                recipe.limit_pollution = recipe.pollution_total / block.count
            end
        end
        ---state = 0 => produit
        ---state = 1 => produit pilotant
        ---state = 2 => produit restant
        ---state = 3 => produit surplus

        ---finalisation du bloc
        for icol, state in pairs(mC.states) do
            if icol > 0 then
                local rows = mC.rows
                local zrow = rows[#mC.rows]
                local Z = math.abs(zrow[icol])
                local product_header = mC.columns[icol]
                local product_key = product_header.key
                local product = Product(product_header):clone()
                product.count = Z
                product.state = state
                if block.by_product == false then
                    if state == 1 or state == 3 then
                        ---element produit
                        if block.ingredients[product_key] ~= nil then
                            block.ingredients[product_key].count = block.ingredients[product_key].count +
                                product.count
                            block.ingredients[product_key].state = state
                        end
                        if block.products[product_key] ~= nil then
                            block.products[product_key].state = 0
                        end
                    else
                        ---element ingredient
                        if block.products[product_key] ~= nil then
                            block.products[product_key].count = block.products[product_key].count + product.count
                            block.products[product_key].state = state
                        end
                        if block.ingredients[product_key] ~= nil then
                            block.ingredients[product_key].state = state
                        end
                    end
                else
                    if state == 1 or state == 3 then
                        ---element produit
                        if block.products[product_key] ~= nil then
                            block.products[product_key].count = block.products[product_key].count + product.count
                            block.products[product_key].state = state
                        end
                        if block.ingredients[product_key] ~= nil then
                            block.ingredients[product_key].state = 0
                        end
                    else
                        ---element ingredient
                        if block.ingredients[product_key] ~= nil then
                            block.ingredients[product_key].count = block.ingredients[product_key].count +
                                product.count
                            block.ingredients[product_key].state = state
                        end
                        if block.products[product_key] ~= nil then
                            block.products[product_key].state = state
                        end
                    end
                end
            end
        end
    end

    return block
end

-------------------------------------------------------------------------------
---Return a matrix of block
---@param block table
---@return table
function SolverMatrix.get_block_matrix(block)
    local recipes = block.recipes
    if recipes ~= nil then
        local matrix = Matrix()
        local col_index = {}
        ---begin loop recipes
        local factor = 1
        local sorter = function(t, a, b) return t[b].index > t[a].index end
        if block.by_product == false then
            factor = -factor
            sorter = function(t, a, b) return t[b].index < t[a].index end
        end

        for _, recipe in spairs(recipes, sorter) do
            recipe.base_time = block.time
            ModelCompute.computeModuleEffects(recipe)
            if recipe.type == "energy" then
                ModelCompute.computeEnergyFactory(recipe)
            else
                ModelCompute.computeFactory(recipe)
            end


            local row_valid = false
            local recipe_prototype = RecipePrototype(recipe)
            local lua_recipe = recipe_prototype:native()

            ---la recette n'existe plus
            if recipe_prototype:native() == nil then return end

            ---prepare le taux de production
            local production = 1
            if not (block.solver == true) and recipe.production ~= nil then production = recipe.production end

            local rowParameters = MatrixRowParameters()
            local row = MatrixRow(recipe.type, recipe.name, recipe.name .. "\nRecette")

            rowParameters.base = row.header
            if recipe.contraint ~= nil then
                rowParameters.contraint = { type = recipe.contraint.type, name = recipe.contraint.name }
            end
            rowParameters.factory_count = recipe.factory.input or 0
            rowParameters.factory_speed = recipe.factory.speed or 0
            rowParameters.recipe_count = 0
            rowParameters.recipe_production = production
            rowParameters.recipe_energy = recipe_prototype:getEnergy()
            rowParameters.coefficient = 0

            ---preparation
            local lua_products = {}
            local lua_ingredients = {}
            for i, lua_product in pairs(recipe_prototype:getProducts(recipe.factory)) do
                local product = Product(lua_product)
                local product_key = product:getTableKey()
                local count = product:getAmount(recipe)
                lua_products[product_key] = { name = lua_product.name, type = lua_product.type, count = count,
                    temperature = lua_product.temperature, minimum_temperature = lua_product.minimum_temperature,
                    maximum_temperature = lua_product.maximum_temperature }
            end
            for i, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
                local ingredient = Product(lua_ingredient)
                local ingredient_key = ingredient:getTableKey()
                local count = ingredient:getAmount()
                ---si constant compte comme un produit (recipe rocket)
                if lua_ingredient.constant then
                    count = ingredient:getAmount(recipe)
                end
                if lua_ingredients[ingredient_key] == nil then
                    lua_ingredients[ingredient_key] = { name = lua_ingredient.name, type = lua_ingredient.type,
                        count = count, temperature = lua_ingredient.temperature,
                        minimum_temperature = lua_ingredient.minimum_temperature,
                        maximum_temperature = lua_ingredient.maximum_temperature }
                else
                    lua_ingredients[ingredient_key].count = lua_ingredients[ingredient_key].count + count
                end
            end

            if not (block.by_product == false) then
                ---prepare header products
                for name, lua_product in pairs(lua_products) do
                    local product = Product(lua_product)
                    local product_key = product:getTableKey()
                    local index = 1
                    if col_index[product_key] ~= nil then
                        index = col_index[product_key]
                    end
                    col_index[product_key] = index

                    local col_name = product_key .. index

                    local col_header = MatrixHeader()
                    col_header.sysname = col_name
                    col_header.tooltip = col_name .. "\nProduit"
                    col_header.index = index
                    col_header.key = product_key
                    col_header.is_ingredient = false
                    col_header.product = lua_product

                    local cell_value = lua_product.count * factor
                    row:add_value(col_header, cell_value)

                    if rowParameters.contraint ~= nil and rowParameters.contraint.name == name then
                        rowParameters.contraint.name = col_name
                    end

                    row_valid = true
                end
                ---prepare header ingredients
                for name, lua_ingredient in pairs(lua_ingredients) do
                    local ingredient = Product(lua_ingredient)
                    local ingredient_key = ingredient:getTableKey()
                    local index = 1
                    ---cas normal de l'ingredient n'existant pas du cote produit
                    if col_index[ingredient_key] ~= nil and lua_products[ingredient_key] == nil then
                        index = col_index[ingredient_key]
                    end
                    ---cas de l'ingredient existant du cote produit
                    if col_index[ingredient_key] ~= nil and lua_products[ingredient_key] ~= nil then
                        ---cas de la valeur equivalente, on creer un nouveau element
                        if lua_products[ingredient_key].count == lua_ingredients[ingredient_key].count or recipe.type == "resource" or recipe.type == "energy" then
                            index = col_index[ingredient_key] + 1
                        else
                            index = col_index[ingredient_key]
                        end
                    end
                    col_index[ingredient_key] = index

                    local col_name = ingredient_key .. index

                    local col_header = MatrixHeader()
                    col_header.sysname = col_name
                    col_header.tooltip = col_name .. "\nIngredient"
                    col_header.index = index
                    col_header.key = ingredient_key
                    col_header.is_ingredient = true
                    col_header.product = lua_ingredient

                    local cell_value = row:get_value(col_header) or 0
                    cell_value = cell_value - lua_ingredients[ingredient_key].count * factor
                    row:add_value(col_header, cell_value)

                    row_valid = true
                end
            else
                ---prepare header ingredients
                for name, lua_ingredient in pairs(lua_ingredients) do
                    local ingredient = Product(lua_ingredient)
                    local ingredient_key = ingredient:getTableKey()
                    local index = 1
                    ---cas normal de l'ingredient n'existant pas du cote produit
                    if col_index[ingredient_key] ~= nil then
                        index = col_index[ingredient_key]
                    end
                    col_index[ingredient_key] = index

                    local col_name = ingredient_key .. index

                    local col_header = MatrixHeader()
                    col_header.name = col_name
                    col_header.tooltip = col_name .. "\nIngredient"
                    col_header.index = index
                    col_header.key = ingredient_key
                    col_header.is_ingredient = true
                    col_header.product = lua_ingredient

                    local cell_value = -lua_ingredient.count * factor
                    row:add_value(col_header, cell_value)

                    if rowParameters.contraint ~= nil and rowParameters.contraint.name == name then
                        rowParameters.contraint.name = col_name
                    end
                    row_valid = true
                end
                ---prepare header products
                for name, lua_product in pairs(lua_products) do
                    local product = Product(lua_product)
                    local product_key = product:getTableKey()
                    local index = 1
                    if col_index[product_key] ~= nil then
                        index = col_index[product_key]
                    end
                    ---cas du produit existant du cote ingredient
                    if col_index[product_key] ~= nil and lua_ingredients[product_key] ~= nil then
                        ---cas de la valeur equivalente, on creer un nouveau element
                        if lua_products[product_key].count == lua_ingredients[product_key].count or recipe.type == "resource" or recipe.type == "energy" then
                            index = col_index[product_key] + 1
                        else
                            index = col_index[product_key]
                        end
                    end
                    col_index[product_key] = index

                    local col_name = product_key .. index

                    local col_header = MatrixHeader()
                    col_header.sysname = col_name
                    col_header.tooltip = col_name .. "\nProduit"
                    col_header.index = index
                    col_header.key = product_key
                    col_header.is_ingredient = false
                    col_header.product = lua_product

                    local cell_value = row:get_value(col_header) or 0
                    cell_value = cell_value - lua_product.count * factor
                    row:add_value(col_header, cell_value)

                    row_valid = true
                end
            end
            if row_valid then
                matrix:add_row(row, rowParameters)
            end
        end

        ---end loop recipes

        local objectives = {}
        local input_ready = {}
        local block_elements = block.products
        if block.by_product == false then
            block_elements = block.ingredients
        end
        for _, column in pairs(matrix.columns) do
            if block_elements ~= nil and block_elements[column.key] ~= nil and not (input_ready[column.key]) and column.index == 1 then
                local objective = {}
                objective.value = block_elements[column.key].input or 0
                objective.key = column.key
                objectives[column.key] = objective
                input_ready[column.key] = true
            end
        end

        matrix.objectives = objectives

        return matrix
    end
    return nil
end
