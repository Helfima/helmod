-------------------------------------------------------------------------------
---Description of the module.
---@class SolverLinkedMatrix
SolverLinkedMatrix = newclass(function(base)
end)

-------------------------------------------------------------------------------
---Clone la matrice
---@param matrix Matrix
---@return Matrix
function SolverLinkedMatrix:clone(matrix)
    local matrix_clone = table.deepcopy(matrix)
    return matrix_clone
end

-------------------------------------------------------------------------------
---Prepare la matrice
---@param matrix Matrix
---@return Matrix
function SolverLinkedMatrix:prepare(matrix)
    local matrix_clone = self:clone(matrix)
    self:prepare_z_and_objectives(matrix_clone, false)
    return matrix_clone
end

-------------------------------------------------------------------------------
---Prepare Z et objectives
---@param matrix Matrix
---@param reverse boolean reverse objective sign
function SolverLinkedMatrix:prepare_z_and_objectives(matrix, reverse)
    local row = {}
    local objective_values = {}
    ---ajoute la ligne Z avec Z=-input
    for _, column in pairs(matrix.columns) do
        local objective = matrix.objectives[column.key]
        local objective_value = 0
        if objective ~= nil then
            objective_value = objective.value
        end
        if reverse then
            objective_value = -objective_value
        end
        local value = 0 - objective_value
        table.insert(row, value)
        table.insert(objective_values, objective_value)
    end
    matrix.objective_values = objective_values
    table.insert(matrix.rows, row)
end
-------------------------------------------------------------------------------
---Finalise la matrice
---@param matrix Matrix
---@return Matrix
function SolverLinkedMatrix:finalize(matrix)
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
---@param pivot? table
function SolverLinkedMatrix:add_runtime(debug, runtime, name, matrix, pivot)
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
function SolverLinkedMatrix:apply_state(matrix)
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
---Abstract Resoud la matrice
---@param matrix_base Matrix
---@param debug boolean
---@param by_factory boolean
---@param time number
---@return Matrix, table
function SolverLinkedMatrix:solve_matrix(matrix_base, debug, by_factory, time)
end
-------------------------------------------------------------------------------
---Return a matrix of block
---@param block BlockData
---@param parameters ParametersData
---@param debug boolean
---@return BlockData
function SolverLinkedMatrix:solve(block, parameters, debug)
    block.blocks_linked = nil
    if block.products_linked ~= nil then
        -- build and compute reduced matrix when there are linked products
        local blocks_linked = {}
        for product_name, linked in pairs(block.products_linked) do
            if linked == true then
                -- work on full copy
                local linked_block = table.deepcopy(block)
                linked_block.contraint = nil
                linked_block.objectives = {}
                local children = linked_block.children
                local sorter = defines.sorters.block.sort
                if block.by_product == false then
                    sorter = defines.sorters.block.reverse
                end
                local child_products = nil
                local child_ingredients = nil
                local exit_for = false
                for _, child in spairs(children, sorter) do
                    local is_block = Model.isBlock(child)
                    if is_block then
                        child_products = child.products
                        child_ingredients = child.ingredients
                    else
                        local recipe = child
                        -- check recipe doesn't exist
                        local recipe_prototype = RecipePrototype(recipe)
                        if recipe_prototype:native() == nil then return end
                        child_products = recipe_prototype:getProducts(recipe.factory)
                        child_ingredients = recipe_prototype:getIngredients(recipe.factory)
                    end
                    for i, lua_product in pairs(child_products) do
                        -- search the product with the name of linked product
                        if lua_product.name == product_name then
                            local factor = 1
                            local product = Product(lua_product)
                            local element_key = product:getTableKey()
                            local objective = {}
                            objective.key = element_key
                            objective.value = lua_product.amount * factor
                            linked_block.objectives[element_key] = objective
                            exit_for = true
                            linked_block.product_linked=lua_product
                            break
                        end
                    end
                    if exit_for == true then
                        break
                    end
                end
                blocks_linked[product_name] = self:solve_block(linked_block, parameters, debug)
            end
        end
        block.blocks_linked = blocks_linked
    end
    return self:solve_block(block, parameters, debug)
end
-------------------------------------------------------------------------------
---Return a matrix of block
---@param block BlockData
---@param parameters ParametersData
---@param debug boolean
---@return BlockData
function SolverLinkedMatrix:solve_block(block, parameters, debug)
    local mC, runtimes

    local ok, err = pcall(function()
        local mA = self:get_block_matrix(block, parameters)
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
    block.runtimes = nil
    if debug then
        block.runtimes = runtimes
    end

    if mC ~= nil then
        -- remove temperature convert lines
        -- necessary to retieve the right value
        for i = #mC.headers, 1, -1 do
            if mC.headers[i].name == "helmod-temperature-convert" then
                table.remove(mC.rows, i)
                table.remove(mC.headers, i)
                table.remove(mC.parameters, i)
            end
        end

        local sorter = defines.sorters.block.sort
        if block.by_product == false then
            sorter = defines.sorters.block.reverse
        end

        -- build map to find parameter index by key
        local parameters_index = {}
        for index, header in pairs(mC.headers) do
            local key = header.name
            if header.product_linked ~= nil then
                key = header.name .. "_" .. header.product_linked.name
            end
            if parameters_index[key] == nil then
                parameters_index[key] = index
            end
        end

        local children = block.children
        for _, child in spairs(children, sorter) do
            local is_block = Model.isBlock(child)
            local row_index = parameters_index[child.name]
            local parameters = mC.parameters[row_index]
            if parameters ~= nil and parameters.recipe_count > 0 then
                child.count = parameters.recipe_count
                child.production = parameters.recipe_production
            else
                child.count = 0
            end
            
            if is_block then
                self:solve_block_append(child, mC, parameters_index)
            else
                local recipe = child
                ---calcul dependant du recipe count
                if child.type == "energy" then
                    ModelCompute.computeEnergyFactory(recipe)
                else
                    ModelCompute.computeFactory(recipe)
                end
            end
        end

        
    end
    self:solve_block_finalize(block, mC)
    return block
end

---Append linked block values
---@param block BlockData
---@param matrix Matrix
---@param parameters_index any
function SolverLinkedMatrix:solve_block_append(block, matrix, parameters_index)
    -- append linked block values
    if block.blocks_linked ~= nil then
        for key, linked_block in pairs(block.blocks_linked) do
            -- search the count of linked block
            local parameter_key = linked_block.name .. "_" .. key
            local row_index = parameters_index[parameter_key]
            local parameters = matrix.parameters[row_index]
            local count = 0
            if parameters ~= nil and parameters.recipe_count > 0 then
                count = parameters.recipe_count / block.count
            end
            local linked_children = linked_block.children
            local sorter = defines.sorters.block.sort
            if block.by_product == false then
                sorter = defines.sorters.block.reverse
            end
            -- Set count on each child
            for key, child_linked in spairs(linked_children, sorter) do
                local child = block.children[key]
                if child ~= nil then
                    child.count = child.count + child_linked.count * count
                end
            end
            -- Append values
            for product_key, product in pairs(linked_block.products) do
                block.products[product_key].amount = block.products[product_key].amount + product.amount * count
                if block.by_product ~= false then
                    if block.products[product_key].amount > 0 and block.products[product_key].state == 2 then
                        block.products[product_key].state = 3
                    end
                end
            end
            for product_key, ingredient in pairs(linked_block.ingredients) do
                block.ingredients[product_key].amount = block.ingredients[product_key].amount + ingredient.amount * count
                if block.by_product == false then
                    if block.ingredients[product_key].amount > 0 and block.ingredients[product_key].state == 2 then
                        block.ingredients[product_key].state = 3
                    end
                end
            end
        end
    end
end

---Finalize the block
---@param block any
---@param matrix any
function SolverLinkedMatrix:solve_block_finalize(block, matrix)
    -- state = 0 => produit
    -- state = 1 => produit pilotant
    -- state = 2 => produit restant
    -- state = 3 => produit surplus
    for icol, state in pairs(matrix.states) do
        if icol > 0 then
            local rows = matrix.rows
            local zrow = rows[#matrix.rows]
            local Z = math.abs(zrow[icol])
            local product_header = matrix.columns[icol]
            local product_key = product_header.key
            local product = Product(product_header):clone()
            product.amount = Z
            if math.abs(product.amount) < 1e-10 then
                product.amount = 0
            end
            product.state = state
            if block.by_product == false then
                if state == 1 or state == 3 then
                    -- element produit
                    if block.ingredients[product_key] ~= nil then
                        block.ingredients[product_key].amount = block.ingredients[product_key].amount + product.amount
                        block.ingredients[product_key].state = state
                    end
                    if block.products[product_key] ~= nil then
                        block.products[product_key].state = 0
                    end
                else
                    -- element ingredient
                    if block.products[product_key] ~= nil then
                        block.products[product_key].amount = block.products[product_key].amount + product.amount
                        block.products[product_key].state = state
                    end
                    if block.ingredients[product_key] ~= nil then
                        block.ingredients[product_key].state = state
                    end
                end
            else
                if state == 1 or state == 3 then
                    -- element produit
                    if block.products[product_key] ~= nil then
                        block.products[product_key].amount = block.products[product_key].amount + product.amount
                        block.products[product_key].state = state
                    end
                    if block.ingredients[product_key] ~= nil then
                        block.ingredients[product_key].state = 0
                    end
                else
                    -- element ingredient
                    if block.ingredients[product_key] ~= nil then
                        block.ingredients[product_key].amount = block.ingredients[product_key].amount + product.amount
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

-------------------------------------------------------------------------------
---Return a matrix of block
---@param block BlockData
---@param parameters ParametersData
---@return table
function SolverLinkedMatrix:get_block_matrix(block, parameters)
    local children = block.children
    if children ~= nil then
        local matrix = Matrix()
        matrix.column_sum = {}

        local col_index = {}
        local factor = 1
        local sorter = defines.sorters.block.sort
        if block.by_product == false then
            factor = -factor
            sorter = defines.sorters.block.reverse
        end

        ---begin loop children
        for _, child in spairs(children, sorter) do
            local is_block = Model.isBlock(child)
            local child_info = {}
            child_info.recipe_energy = 1
            child_info.factory_count = 0
            child_info.factory_speed = 1

            -- prepare production %
            local production = 1
            if not (block.solver == true) and child.production ~= nil then production = child.production end

            if is_block then
                child_info.name = child.name
                child_info.type = child.type
                child_info.tooltip = child.name .. "\nBlock"

                child_info.products = child.products
                child_info.ingredients = child.ingredients

                self:add_matrix_row(matrix, child, child_info, is_block, col_index, block.by_product, production, factor)

                if child.blocks_linked ~= nil then
                    -- add virtual row of linked blocks
                    for key, child_linked in pairs(child.blocks_linked) do
                        local child_linked_info = {}
                        child_linked_info.name = child.name
                        child_linked_info.type = child.type
                        child_linked_info.tooltip = child.name .. "\nLinked Block"
                        child_linked_info.recipe_energy = 1
                        child_linked_info.factory_count = 0
                        child_linked_info.factory_speed = 1

                        child_linked_info.products = child_linked.products
                        child_linked_info.ingredients = child_linked.ingredients
                        self:add_matrix_row(matrix, child_linked, child_linked_info, is_block, col_index, block.by_product, production, factor)
                    end
                end
            else
                local recipe = child
                -- check recipe doesn't exist
                local recipe_prototype = RecipePrototype(recipe)
                if recipe_prototype:native() == nil then return end

                child_info.name = recipe.name
                child_info.type = recipe.type
                child_info.tooltip = recipe.name .. "\nRecette"
                child_info.recipe_energy = recipe_prototype:getEnergy(recipe.factory)
                child_info.factory_count = recipe.factory.input or 0

                recipe.base_time = block.time
                ModelCompute.computeModuleEffects(recipe, parameters)
                if recipe.type == "energy" then
                    ModelCompute.computeEnergyFactory(recipe)
                else
                    ModelCompute.computeFactory(recipe)
                end
                
                child_info.factory_speed = recipe.factory.speed or 0

                child_info.products = recipe_prototype:getProducts(recipe.factory)
                child_info.ingredients = recipe_prototype:getIngredients(recipe.factory)
                self:add_matrix_row(matrix, child, child_info, is_block, col_index, block.by_product, production, factor)
            end

        end

        ---end loop recipes

        matrix = self:linkTemperatureFluid(matrix, block.by_product)
        matrix.objectives = block.objectives
        return matrix
    end
    return nil
end

-------------------------------------------------------------------------------
---Add matrix row
---@param matrix table
---@param child table
---@param child_info table
---@param is_block boolean
---@param col_index table
---@param by_product boolean
---@param production number
---@param factor number
function SolverLinkedMatrix:add_matrix_row(matrix, child, child_info, is_block, col_index, by_product, production, factor)

    local row_valid = false
    local rowParameters = MatrixRowParameters()
    local row = MatrixRow(child_info.type, child_info.name, child_info.tooltip)
    if child.product_linked then
        row.header.product_linked = child.product_linked
    end

    rowParameters.base = row.header
    if child.contraints ~= nil then
        rowParameters.contraints = table.deepcopy(child.contraints)
    end
    rowParameters.factory_count = child_info.factory_count
    rowParameters.factory_speed = child_info.factory_speed
    rowParameters.recipe_count = 0
    rowParameters.recipe_production = production
    rowParameters.recipe_energy = child_info.recipe_energy
    rowParameters.coefficient = 0
    rowParameters.voider = 0
    rowParameters.by_product = 0
    if not (child.by_product == false) then
        rowParameters.by_product = 1
    end

    ---preparation
    local lua_products = {}
    local lua_ingredients = {}
    for i, lua_product in pairs(child_info.products) do
        local product = Product(lua_product)
        local product_key = product:getTableKey()
        local product_amount = 0
        if is_block then
            product_amount = lua_product.amount or 0
        else
            product_amount = product:getAmount(child)
        end
        lua_products[product_key] = {
            name = lua_product.name,
            type = lua_product.type,
            amount = product_amount,
            temperature = lua_product.temperature,
            minimum_temperature = lua_product.minimum_temperature,
            maximum_temperature = lua_product.maximum_temperature
        }
    end
    for i, lua_ingredient in pairs(child_info.ingredients) do
        local ingredient = Product(lua_ingredient)
        local ingredient_key = ingredient:getTableKey()
        local ingredient_amount = 0
        if is_block then
            ingredient_amount = lua_ingredient.amount or 0
        else
            ingredient_amount = ingredient:getAmount()
            ---si constant compte comme un produit (recipe rocket)
            if lua_ingredient.constant then
                ingredient_amount = ingredient:getAmount(child)
            end
        end
        
        if lua_ingredients[ingredient_key] == nil then
            lua_ingredients[ingredient_key] = {
                name = lua_ingredient.name,
                type = lua_ingredient.type,
                amount = ingredient_amount,
                temperature = lua_ingredient.temperature,
                minimum_temperature = lua_ingredient.minimum_temperature,
                maximum_temperature = lua_ingredient.maximum_temperature
            }
        else
            lua_ingredients[ingredient_key].amount = lua_ingredients[ingredient_key].amount + ingredient_amount
        end
    end

    if not (by_product == false) then
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

            local value = lua_product.amount * factor
            local cell_value = value
            row:add_value(col_header, cell_value)

            matrix.column_sum[product_key] = ( matrix.column_sum[product_key] or 0 ) + value

            row_valid = true
        end
        ---prepare header ingredients
        for name, lua_ingredient in pairs(lua_ingredients) do
            local ingredient = Product(lua_ingredient)
            local ingredient_key = ingredient:getTableKey()
            local index = 1
            ---default case
            if col_index[ingredient_key] ~= nil and lua_products[ingredient_key] == nil then
                index = col_index[ingredient_key]
            end
            ---case where the ingredient exist in the product side
            if col_index[ingredient_key] ~= nil and lua_products[ingredient_key] ~= nil then
                local child_type = child_info.type
                ---case of the equivalent value, we create a new element
                if lua_products[ingredient_key].amount > 0 and lua_ingredients[ingredient_key].amount > 0 and 
                    lua_products[ingredient_key].amount == lua_ingredients[ingredient_key].amount or child_type == "resource" or child_type == "energy" then
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
            local value = - lua_ingredients[ingredient_key].amount * factor
            cell_value = cell_value + value
            row:add_value(col_header, cell_value)

            matrix.column_sum[ingredient_key] = ( matrix.column_sum[ingredient_key] or 0 ) + value

            row_valid = true
        end
        if row.values ~= nil and #row.values == 1 and row.values[1] < 0 then
            rowParameters.voider = 1
        end
    else
        ---prepare header ingredients
        for name, lua_ingredient in pairs(lua_ingredients) do
            local ingredient = Product(lua_ingredient)
            local ingredient_key = ingredient:getTableKey()
            local index = 1
            ---default case
            if col_index[ingredient_key] ~= nil then
                index = col_index[ingredient_key]
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

            local value = -lua_ingredient.amount * factor
            local cell_value = value
            row:add_value(col_header, cell_value)

            matrix.column_sum[ingredient_key] = ( matrix.column_sum[ingredient_key] or 0 ) + value

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
            --- case where the product exist in the ingredient side
            if col_index[product_key] ~= nil and lua_ingredients[product_key] ~= nil then
                local child_type = child_info.type
                ---case of the equivalent value, we create a new element
                if lua_products[product_key].amount > 0 and lua_ingredients[product_key].amount > 0 and 
                    lua_products[product_key].amount == lua_ingredients[product_key].amount or child_type == "resource" or child_type == "energy" then
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

            local value = lua_product.amount * factor
            local cell_value = row:get_value(col_header) or 0
            cell_value = cell_value + value
            row:add_value(col_header, cell_value)

            matrix.column_sum[product_key] = ( matrix.column_sum[product_key] or 0 ) + value

            row_valid = true
        end
    end
    if row_valid then
        matrix:add_row(row, rowParameters)
    end
end
-------------------------------------------------------------------------------
---Link Temperature Fluid
---@param matrix table
---@param by_product boolean
---@return table
function SolverLinkedMatrix:linkTemperatureFluid(matrix, by_product)
    ---Create blank parameters
    local template_parameters = MatrixRowParameters()
    template_parameters.factory_count = 0
    template_parameters.factory_speed = 1
    template_parameters.recipe_count = 0
    template_parameters.recipe_production = 1
    template_parameters.recipe_energy = 1
    template_parameters.coefficient = 0

    ---Create blank row
    local template_row = {}
    for _, column in pairs(matrix.columns) do
        table.insert(template_row, 0)
    end

    local mA2 = Matrix()
    mA2.column_sum = matrix.column_sum
    local block_ingredient_fluids = {}
    local block_product_fluids = {}

    for irow, row in pairs(matrix.rows) do
        local rowParameters = matrix.parameters[irow]
        local rowHeader = matrix.headers[irow]
        local rowMatrix = MatrixRow(rowHeader.type, rowHeader.name, rowHeader.tooltip)
        rowMatrix.header.product_linked = rowHeader.product_linked
        rowMatrix.columns = matrix.columns
        rowMatrix.columnIndex = matrix.columnIndex
        rowMatrix.values = row
        

        local ingredient_fluids = {}
        local product_fluids = {}

        for icol, column in pairs(matrix.columns) do
            local cell_value = row[icol] or 0
            local product = column.product
            if (column.key ~= nil) and (product.type == "fluid") then
                if cell_value > 0 then
                    block_product_fluids[product.name] = block_product_fluids[product.name] or {}
                    block_product_fluids[product.name][column.key] = column
                    product_fluids[column.key] = column
                elseif cell_value < 0 then
                    ingredient_fluids[column.key] = column
                end
            end
        end

        local coefficient = 0
        ---Convert any Z into product
        for _, product_fluid in pairs(product_fluids) do
            local product = product_fluid.product
            local linked_fluids = block_ingredient_fluids[product.name] or {}
            for _, linked_fluid in pairs(linked_fluids) do
                if self:checkLinkedTemperatureFluid(product_fluid, linked_fluid, by_product) then
                    local parameters = MatrixRowParameters()
                    parameters.coefficient = coefficient
                    local new_row = MatrixRow("recipe", "helmod-temperature-convert", "")
                    new_row.header.is_ingredient = false
                    new_row.header.primary = product_fluid.product
                    new_row.header.secondary = linked_fluid.product
                    new_row:add_value(product_fluid, -1)
                    new_row:add_value(linked_fluid, 1)
                    mA2:add_row(new_row, parameters)
                end
            end
        end

        -- Insert the row
        mA2:add_row(rowMatrix, rowParameters)

        ---Convert any overflow product back into Z
        for _, product_fluid in pairs(product_fluids) do
            local product = product_fluid.product
            local linked_fluids = block_ingredient_fluids[product.name] or {}
            for _, linked_fluid in pairs(linked_fluids) do
                if self:checkLinkedTemperatureFluid(product_fluid, linked_fluid, by_product) then
                    local parameters = MatrixRowParameters()
                    parameters.coefficient = coefficient
                    local new_row = MatrixRow("recipe", "helmod-temperature-convert", "")
                    new_row.header.is_ingredient = false
                    new_row.header.primary = linked_fluid.product
                    new_row.header.secondary = product_fluid.product
                    new_row:add_value(product_fluid, 1)
                    new_row:add_value(linked_fluid, -1)
                    mA2:add_row(new_row, parameters)
                end
            end
        end

        ---If an ingredient has already been made in this block
        ---Convert any Z into ingredient
        ---Convert any unmet ingredient back into Z
        for _, ingredient_fluid in pairs(ingredient_fluids) do
            local product = ingredient_fluid.product
            block_ingredient_fluids[product.name] = block_ingredient_fluids[product.name] or {}
            block_ingredient_fluids[product.name][ingredient_fluid.key] = ingredient_fluid

            local linked_fluids = block_product_fluids[product.name] or {}
            for _, linked_fluid in pairs(linked_fluids) do
                if self:checkLinkedTemperatureFluid(linked_fluid, ingredient_fluid, by_product) then
                    local parameters = MatrixRowParameters()
                    parameters.coefficient = coefficient
                    local new_row = MatrixRow("recipe", "helmod-temperature-convert", "")
                    new_row.header.is_ingredient = true
                    new_row.header.primary = linked_fluid.product
                    new_row.header.secondary = ingredient_fluid.product
                    new_row:add_value(linked_fluid, -1)
                    new_row:add_value(ingredient_fluid, 1)
                    mA2:add_row(new_row, parameters)

                    local parameters = MatrixRowParameters()
                    parameters.coefficient = coefficient
                    local new_row = MatrixRow("recipe", "helmod-temperature-convert", "")
                    new_row.header.is_ingredient = true
                    new_row.header.primary = ingredient_fluid.product
                    new_row.header.secondary = linked_fluid.product
                    new_row:add_value(linked_fluid, 1)
                    new_row:add_value(ingredient_fluid, -1)
                    mA2:add_row(new_row, parameters)
                end
            end
        end
    end

    return mA2
end

-------------------------------------------------------------------------------
---Check Linked Temperature Fluid
---@param item1 table
---@param item2 table
---@param by_product boolean
---@return boolean
function SolverLinkedMatrix:checkLinkedTemperatureFluid(item1, item2, by_product)
    local result = false

    local product, ingredient
    if by_product ~= false then
        product = item1
        ingredient = item2
    else
        product = item2
        ingredient = item1
    end

    if product.key ~= ingredient.key then
        local T = product.product.temperature
        local T2 = ingredient.product.temperature
        local T2min = ingredient.product.minimum_temperature
        local T2max = ingredient.product.maximum_temperature
        if T ~= nil or T2 ~= nil or T2min ~= nil or T2max ~= nil then
            ---traitement seulement si une temperature
            if T2min == nil and T2max == nil then
                ---Temperature sans intervale
                if T == nil or T2 == nil or T2 == T then
                    result = true
                end
            else
                ---Temperature avec intervale
                ---securise les valeurs
                T = T or 25
                T2min = T2min or -defines.constant.max_float
                T2max = T2max or defines.constant.max_float
                if T >= T2min and T <= T2max then
                    result = true
                end
            end
        end
    end

    return result
end