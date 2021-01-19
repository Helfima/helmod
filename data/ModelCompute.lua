require "math.Solver"
require "math.SolverAlgebra"
require "math.SolverSimplex"

------------------------------------------------------------------------------
-- Description of the module.
-- @module ModelCompute
--
local ModelCompute = {
  -- single-line comment
  classname = "HMModelCompute",
  capEnergy = -0.8,
  capSpeed = -0.8,
  capPollution = -0.8,
  -- 15°c
  initial_temp = 15,
  -- 200J/unit/°c
  fluid_energy_per_unit = 200,
  waste_value = 0.00001,

  cap_reason = {
    speed = {
      cycle = 1,
      module_low = 2,
      module_high = 4
    },
    productivity = {
      module_low = 1
    },
    consumption = {
      module_low = 1
    },
    pollution = {
      module_low = 1
    }
  }
}

-------------------------------------------------------------------------------
-- Check and valid unlinked all blocks
--
-- @function [parent=#ModelCompute] checkUnlinkedBlocks
--
function ModelCompute.checkUnlinkedBlocks(model)
  if model.blocks ~= nil then
    for _,block in spairs(model.blocks,function(t,a,b) return t[b].index > t[a].index end) do
      ModelCompute.checkUnlinkedBlock(model, block)
    end
  end
end

-------------------------------------------------------------------------------
-- Check and valid unlinked block
--
-- @function [parent=#ModelCompute] checkUnlinkedBlock
--
-- @param #table block
--
function ModelCompute.checkUnlinkedBlock(model, block)
  local unlinked = true
  local recipe = Player.getRecipe(block.name)
  if recipe ~= nil then
    if model.blocks ~= nil then
      for _, current_block in spairs(model.blocks,function(t,a,b) return t[b].index > t[a].index end) do
        if current_block.id == block.id then
          break
        end
        for _,ingredient in pairs(current_block.ingredients) do
          for _,product in pairs(recipe.products) do
            if product.name == ingredient.name then
              unlinked = false
            end
          end
        end
        if current_block.id ~= block.id and current_block.name == block.name then
          unlinked = true
        end
      end
    end
    block.unlinked = unlinked
  else
    -- not a recipe
    block.unlinked = true
  end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#ModelCompute] update
--
function ModelCompute.update(model)
  if model~= nil and model.blocks ~= nil then
    -- calcul les blocks
    local input = {}
    for _, block in spairs(model.blocks, function(t,a,b) return t[b].index > t[a].index end) do
      block.time = model.time
      -- premiere recette
      local _,recipe = next(block.recipes)
      if recipe ~= nil then

        -- state = 0 => produit
        -- state = 1 => produit pilotant
        -- state = 2 => produit restant
        -- prepare input
        if not(block.unlinked) then
          if block.products == nil then
            ModelCompute.computeBlock(block)
          end
          -- prepare les inputs
          local factor = -1
          local block_elements = block.products
          if block.by_product == false then
            block_elements = block.ingredients
            factor = 1
          end
          if block_elements ~= nil then
            for _,element in pairs(block_elements) do
              local element_key = Product(element):getTableKey()
              if (element.state ~= nil and element.state == 1) or (block.products_linked ~= nil and block.products_linked[element_key] == true) then
                if input[element_key] ~= nil then
                  element.input = (input[element_key] or 0) * factor
                  --element.state = 0
                end
              else
                element.input = 0
              end
            end
          end
        end

        -- prepare bloc
        local block_products, block_ingredients = ModelCompute.prepareBlock(block)
        block.products = block_products
        block.ingredients = block_ingredients

        ModelCompute.computeBlockCleanInput(block)

        ModelCompute.computeBlock(block)

        -- consomme les ingredients
        for _,product in pairs(block.products) do
          local element_key = Product(product):getTableKey()
          if input[element_key] == nil then
            input[element_key] =  product.count
          elseif input[element_key] ~= nil then
            input[element_key] = input[element_key] + product.count
          end
        end
        -- compte les ingredients
        for _,ingredient in pairs(block.ingredients) do
          local element_key = Product(ingredient):getTableKey()
          if input[element_key] == nil then
            input[element_key] =  - ingredient.count
          else
            input[element_key] = input[element_key] - ingredient.count
          end
        end

      end
    end

    ModelCompute.computeInputOutput(model)
    ModelCompute.computeResources(model)

    -- genere un bilan
    ModelCompute.createSummary(model)
    model.version = Model.version
  end
end

-------------------------------------------------------------------------------
-- Compute recipe block
--
-- @function [parent=#ModelCompute] computeMatrixBlockRecipe
--
-- @param #table element production block model
--
function ModelCompute.computeMatrixBlockRecipe(block, recipe)
  if recipe ~= nil then
    local recipe_prototype = RecipePrototype(recipe)
    local lua_recipe = recipe_prototype:native()

    -- compute ingredients
    for k, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
      local ingredient = Product(lua_ingredient):clone()
      -- consolide la production
      local i_amount = ingredient.amount
      -- exclus le type ressource ou fluid
      if recipe.type ~= "resource" and recipe.type ~= "fluid" then
        for k, lua_product in pairs(recipe_prototype:getProducts(recipe.factory)) do
          if lua_ingredient.name == lua_product.name then
            local product = Product(lua_product):clone()
            i_amount = i_amount - product.amount
          end
        end
      end

      local nextCount = i_amount * recipe.count
      block.ingredients[lua_ingredient.name].count = block.ingredients[lua_ingredient.name].count + nextCount
    end
  end
end

-------------------------------------------------------------------------------
-- Compute recipe block
--
-- @function [parent=#ModelCompute] computeMatrixBlockTechnology
--
-- @param #table element production block model
--
function ModelCompute.computeMatrixBlockTechnology(block, recipe)
  local recipe_prototype = RecipePrototype(recipe)
  local lua_recipe = recipe_prototype:native()
  -- compute ingredients
  for k, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
    local ingredient = Product(lua_ingredient):clone()
    local i_amount = ingredient.amount
    local nextCount = i_amount * recipe.count
    block.ingredients[ingredient.name].count = block.ingredients[ingredient.name].count + nextCount
  end
end

-------------------------------------------------------------------------------
-- Compute production block
--
-- @function [parent=#ModelCompute] computeBlockCleanInput
--
-- @param #table block block of model
--
function ModelCompute.computeBlockCleanInput(block)
  local recipes = block.recipes
  if recipes ~= nil then

    if block.input ~= nil then
      -- state = 0 => produit
      -- state = 1 => produit pilotant
      -- state = 2 => produit restant
      for product_name,quantity in pairs(block.input) do
        if block.products[product_name] == nil or not(bit32.band(block.products[product_name].state, 1)) then
          block.input[product_name] = nil
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Clone une matrice
--
-- @function [parent=#ModelCompute] cloneMatrix
-- @param #table M
--
-- @return #number
--
function ModelCompute.cloneMatrix(M)
  local Mx = {}
  local num_row = rawlen(M)
  local num_col = rawlen(M[1])
  for irow,row in pairs(M) do
    Mx[irow] = {}
    for icol,col in pairs(row) do
      Mx[irow][icol] = col
    end
  end
  return Mx
end


-------------------------------------------------------------------------------
-- Return a matrix of block
--
-- @function [parent=#ModelCompute] getBlockMatrix
--
-- @param #table block block of model
--
function ModelCompute.getBlockMatrix(block)
  local recipes = block.recipes
  if recipes ~= nil then
    local row_headers = {}
    local col_headers = {}
    local col_index = {}
    local rows = {}
    
    col_headers["B"] = {index=1, name="B", type="none", tooltip="Base"} -- Base
    col_headers["M"] = {index=1, name="M", type="none", tooltip="Matrix calculation"} -- Matrix calculation
    col_headers["Cn"] = {index=1, name="Cn", type="none", tooltip="Contraint"} -- Contraint
    col_headers["F"] = {index=1, name="F", type="none", tooltip="Number factory"} -- Number factory
    col_headers["S"] = {index=1, name="S", type="none", tooltip="Speed factory"} -- Speed factory
    col_headers["R"] = {index=1, name="R", type="none", tooltip="Count recipe"} -- Count recipe
    col_headers["P"] = {index=1, name="P", type="none", tooltip="Production"} -- Production
    col_headers["E"] = {index=1, name="E", type="none", tooltip="Energy"} -- Energy
    col_headers["C"] = {index=1, name="C", type="none", tooltip="Coefficient"} -- Coefficient ou resultat
    -- begin loop recipes
    local factor = 1
    local sorter = function(t,a,b) return t[b].index > t[a].index end
    if block.by_product == false then
      factor = -factor
      sorter = function(t,a,b) return t[b].index < t[a].index end
    end
    
    for _, recipe in spairs(recipes,sorter) do
      recipe.time = block.time
      ModelCompute.computeModuleEffects(recipe)
      if block.isEnergy == true then
        ModelCompute.computeEnergyFactory(recipe)
      else
        ModelCompute.computeFactory(recipe)
      end
      local row = {}

      local row_valid = false
      local recipe_prototype = RecipePrototype(recipe)
      local lua_recipe = recipe_prototype:native()

      -- la recette n'existe plus
      if recipe_prototype:native() == nil then return end
      
          
      -- prepare le taux de production
      local production = 1
      if not(block.solver == true) and recipe.production ~= nil then production = recipe.production end
      local row_header = {name=recipe.name, type=recipe.type, tooltip=recipe.name.."\nRecette"}
      table.insert(row_headers,row_header)
      row["B"] = row_header
      row["M"] = 0 --recipe.matrix_solver or 0
      if recipe.contraint ~= nil then
        row["Cn"] = {type=recipe.contraint.type, name=recipe.contraint.name}
      else
        row["Cn"] = 0
      end
      row["F"] = recipe.factory.input or 0
      row["S"] = recipe.factory.speed or 0
      row["R"] = 0
      row["P"] = production
      row["E"] = recipe_prototype:getEnergy()
      row["C"] = 0

      -- preparation
      local lua_products = {}
      local lua_ingredients = {}
      for i, lua_product in pairs(recipe_prototype:getProducts(recipe.factory)) do
        local product = Product(lua_product)
        local product_key = product:getTableKey()
        local count = product:getAmount(recipe)
        if lua_product.by_time == true then
          count = count * block.time
        end
        lua_products[product_key] = {name=lua_product.name, type=lua_product.type, count = count, temperature=lua_product.temperature, minimum_temperature=lua_product.minimum_temperature, maximum_temperature=lua_product.maximum_temperature}
      end
      for i, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
        local ingredient = Product(lua_ingredient)
        local ingredient_key = ingredient:getTableKey()
        local count = ingredient:getAmount()
        -- si constant compte comme un produit (recipe rocket)
        if lua_ingredient.constant then
          count = ingredient:getAmount(recipe)
        end
        if lua_ingredient.by_time == true then
          count = count * block.time
        end
        if lua_ingredients[ingredient_key] == nil then
          lua_ingredients[ingredient_key] = {name=lua_ingredient.name, type=lua_ingredient.type, count = count, temperature=lua_ingredient.temperature, minimum_temperature=lua_ingredient.minimum_temperature, maximum_temperature=lua_ingredient.maximum_temperature}
        else
          lua_ingredients[ingredient_key].count = lua_ingredients[ingredient_key].count + count
        end
      end

      if not(block.by_product == false) then
        -- prepare header products
        for name, lua_product in pairs(lua_products) do
          local product = Product(lua_product)
          local product_key = product:getTableKey()
          local index = 1
          if col_index[product_key] ~= nil then
            index = col_index[product_key]
          end
          col_index[product_key] = index

          local col_name = product_key..index
          local col_header = {index=index, key=product_key, name=lua_product.name, type=lua_product.type, is_ingredient = false, tooltip=col_name.."\nProduit", temperature=lua_product.temperature, minimum_temperature=lua_product.minimum_temperature, maximum_temperature=lua_product.maximum_temperature}
          col_headers[col_name] = col_header
          row[col_name] = lua_product.count * factor
          row_valid = true
          if row["Cn"] ~= 0 and row["Cn"].name == name then
            row["Cn"].name = col_name
          end
          
        end
        -- prepare header ingredients
        for name, lua_ingredient in pairs(lua_ingredients) do
          local ingredient = Product(lua_ingredient)
          local ingredient_key = ingredient:getTableKey()
          local index = 1
          -- cas normal de l'ingredient n'existant pas du cote produit
          if col_index[ingredient_key] ~= nil and lua_products[ingredient_key] == nil then
            index = col_index[ingredient_key]
          end
          -- cas de l'ingredient existant du cote produit
          if col_index[ingredient_key] ~= nil and lua_products[ingredient_key] ~= nil then
            -- cas de la valeur equivalente, on creer un nouveau element
            if lua_products[ingredient_key].count == lua_ingredients[ingredient_key].count or recipe.type == "resource" or recipe.type == "energy" then
              index = col_index[ingredient_key]+1
            else
              index = col_index[ingredient_key]
            end
          end
          col_index[ingredient_key] = index

          local col_name = ingredient_key..index
          local col_header = {index=index, key=ingredient_key, name=lua_ingredient.name, type=lua_ingredient.type, is_ingredient = true, tooltip=col_name.."\nIngredient", temperature=lua_ingredient.temperature, minimum_temperature=lua_ingredient.minimum_temperature, maximum_temperature=lua_ingredient.maximum_temperature}
          col_headers[col_name] = col_header
          row[col_name] = ( row[col_name] or 0 ) - lua_ingredients[ingredient_key].count * factor
          row_valid = true
          
        end
      else
        -- prepare header ingredients
        for name, lua_ingredient in pairs(lua_ingredients) do
          local ingredient = Product(lua_ingredient)
          local ingredient_key = ingredient:getTableKey()
          local index = 1
          -- cas normal de l'ingredient n'existant pas du cote produit
          if col_index[ingredient_key] ~= nil then
            index = col_index[ingredient_key]
          end
          col_index[ingredient_key] = index

          local col_name = ingredient_key..index
          local col_header = {index=index, key=ingredient_key, name=lua_ingredient.name, type=lua_ingredient.type, is_ingredient = true, tooltip=col_name.."\nIngredient", temperature=lua_ingredient.temperature, minimum_temperature=lua_ingredient.minimum_temperature, maximum_temperature=lua_ingredient.maximum_temperature}
          col_headers[col_name] = col_header
          row[col_name] = -lua_ingredients[name].count * factor
          row_valid = true
          if row["Cn"] ~= 0 and row["Cn"].name == name then
            row["Cn"].name = col_name
          end
          
        end
        -- prepare header products
        for name, lua_product in pairs(lua_products) do
          local product = Product(lua_product)
          local product_key = product:getTableKey()
          local index = 1
          if col_index[product_key] ~= nil then
            index = col_index[product_key]
          end
          -- cas du produit existant du cote ingredient
          if col_index[product_key] ~= nil and lua_ingredients[product_key] ~= nil then
            -- cas de la valeur equivalente, on creer un nouveau element
            if lua_products[product_key].count == lua_ingredients[product_key].count or recipe.type == "resource" or recipe.type == "energy" then
              index = col_index[product_key]+1
            else
              index = col_index[product_key]
            end
          end
          col_index[product_key] = index

          local col_name = product_key..index
          local col_header = {index=index, key=product_key, name=lua_product.name, type=lua_product.type, is_ingredient = false, tooltip=col_name.."\nProduit", temperature=lua_product.temperature, minimum_temperature=lua_product.minimum_temperature, maximum_temperature=lua_product.maximum_temperature}
          col_headers[col_name] = col_header
          row[col_name] = ( row[col_name] or 0 ) + lua_product.count * factor
          row_valid = true
          
        end
      end
      if row_valid then
        table.insert(rows,row)
      end
    end

    -- end loop recipes

    -- on bluid A correctement
    local mA = {}
    -- bluid header
    local rowH = {}
    local col_cn = 3
    for column,header in pairs(col_headers) do
      table.insert(rowH, header)
    end
    table.insert(mA, rowH)
    -- bluid value
    for _,row in pairs(rows) do
      local colx = 1
      local rowA = {}
      for column,_ in pairs(col_headers) do
        if column == "Cn" then
          col_cn = colx
        end
        if row[column] ~= nil then
          table.insert(rowA, row[column])
        else
          table.insert(rowA, 0)
        end
        if type(row["Cn"]) == "table" and row["Cn"].name == column then
          if row["Cn"].type == "master" then
            rowA[col_cn] = colx
          else
            rowA[col_cn] = -colx
          end
        end
        colx =colx + 1
      end
      if type(rowA[col_cn]) == "table" then
        rowA[col_cn] = 0
      end
      table.insert(mA, rowA)
    end

    local row_input = {}
    local row_z = {}
    local input_ready = {}
    local block_elements = block.products
    if block.by_product == false then
      block_elements = block.ingredients
    end
    for column,col_header in pairs(col_headers) do
      if col_header.name == "B" then
        table.insert(row_input, {name="Input", type="none"})
        table.insert(row_z, {name="Z", type="none"})
      else
        if block_elements ~= nil and block_elements[col_header.key] ~= nil and not(input_ready[col_header.name]) and col_header.index == 1 then
          table.insert(row_input, block_elements[col_header.key].input or 0)
          input_ready[col_header.name] = true
        else
          table.insert(row_input, 0)
        end
        table.insert(row_z, 0)
      end
    end
    table.insert(mA, 2, row_input)
    table.insert(mA, row_z)
    ModelCompute.linkTemperatureFluid(mA)
    return mA
  end
end

-------------------------------------------------------------------------------
-- Link Temperature Fluid
--
-- @function [parent=#ModelCompute] linkTemperatureFluid
--
-- @param #table matrix
--
function ModelCompute.linkTemperatureFluid(mA)
  local ingredient_fluids = {}
  local product_fluids = {}
  for column,col_header in pairs(mA[1]) do
    col_header.icol = column
    if col_header.type == "fluid" then
      local is_product = true
      -- check is_product
      for irow,row in pairs(mA) do
        if irow > 2 and irow < #mA then
          local value = row[column]
          if value < 0 then
            is_product = false
          end
        end
      end
      col_header.is_product = is_product
      if is_product == true then
        product_fluids[col_header.key] = col_header
      else
        ingredient_fluids[col_header.key] = col_header
      end
    end
  end
  for _,product in pairs(product_fluids) do
    local T = product.temperature
    for key,ingredient in pairs(ingredient_fluids) do
      if product.name == ingredient.name then
        local T2 = ingredient.temperature
        local T2min = ingredient.minimum_temperature
        local T2max = ingredient.maximum_temperature
        if T ~= nil or T2 ~= nil or T2min ~= nil or T2max ~= nil then
          -- traitement seulement si une temperature
          if T2min == nil and T2max == nil then
            -- Temperature sans intervale
            if T == nil or T2 == nil or T2 == T then
              for irow,row in pairs(mA) do
                if irow > 2 and irow < #mA and row[ingredient.icol] ~= 0 then
                  row[product.icol] = row[ingredient.icol]
                  row[ingredient.icol] = 0
                end
              end
              ingredient_fluids[key] = nil
              break
            end
          else
            -- Temperature avec intervale
            -- securise les valeurs
            T = T or 25
            T2min = T2min or -helmod_constant.max_float
            T2max = T2max or helmod_constant.max_float
            if T >= T2min and T <= T2max then
              for irow,row in pairs(mA) do
                if irow > 2 and irow < #mA and row[ingredient.icol] ~= 0 then
                  row[product.icol] = row[ingredient.icol]
                  row[ingredient.icol] = 0
                end
              end
              ingredient_fluids[key] = nil
              break
            end
          end
        end
      end
    end
  end
  return mA
end

-------------------------------------------------------------------------------
-- Prepare production block
--
-- @function [parent=#ModelCompute] prepareBlock
--
-- @param #table block of model
--
function ModelCompute.prepareBlock(block)
  local recipes = block.recipes
  if recipes ~= nil then
    local block_products = {}
    local block_ingredients = {}
    -- preparation
    for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
      
      local recipe_prototype = RecipePrototype(recipe)
      
      for i, lua_product in pairs(recipe_prototype:getProducts(recipe.factory)) do
        local product_key = Product(lua_product):getTableKey()
        block_products[product_key] = {name=lua_product.name, type=lua_product.type, count = 0, temperature=lua_product.temperature, minimum_temperature=lua_product.minimum_temperature, maximum_temperature=lua_product.maximum_temperature}
      end
      for i, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
        local ingredient_key = Product(lua_ingredient):getTableKey()
        block_ingredients[ingredient_key] = {name=lua_ingredient.name, type=lua_ingredient.type, count = 0, temperature=lua_ingredient.temperature, minimum_temperature=lua_ingredient.minimum_temperature, maximum_temperature=lua_ingredient.maximum_temperature}
      end

    end
    -- preparation state
    -- state = 0 => produit
    -- state = 1 => produit pilotant
    -- state = 2 => produit restant
    for i, block_product in pairs(block_products) do
      local product_key = Product(block_product):getTableKey()
      -- recopie la valeur input
      if block.products[product_key] ~= nil then
        block_product.input = block.products[product_key].input
      end
      -- pose le status
      if block_ingredients[product_key] == nil then
        block_product.state = 1
      else
        block_product.state = 0
      end
    end

    for i, block_ingredient in pairs(block_ingredients) do
      local ingredient_key = Product(block_ingredient):getTableKey()
      -- recopie la valeur input
      if block.ingredients[ingredient_key] ~= nil then
        block_ingredient.input = block.ingredients[ingredient_key].input
      end
      -- pose le status
      if block_products[ingredient_key] ~= nil then
        block_ingredient.state = 1
      else
        block_ingredient.state = 0
      end
    end
    return block_products, block_ingredients
  end
end

-------------------------------------------------------------------------------
-- Compute production block
--
-- @function [parent=#ModelCompute] computeBlock
--
-- @param #table block block of model
--
function ModelCompute.computeBlock(block)
  local recipes = block.recipes
  block.power = 0
  block.count = 1
  block.pollution_total = 0

  if recipes ~= nil then
    local mB,mC,my_solver, runtimes
    local mA = ModelCompute.getBlockMatrix(block)

    if mA ~= nil then
      local debug = User.getModGlobalSetting("debug_solver")
      if block.solver == true and block.by_factory ~= true then
        my_solver = SolverSimplex()
      else
        my_solver = SolverAlgebra()
      end
      -- activate debug
      local ok , err = pcall(function()
        local time = block.time
        if block.isEnergy then time = 1 end
        mC, runtimes = my_solver:solve(mA, debug, block.by_factory, time)
      end)
      if not(ok) then
        if block.solver == true and block.by_factory ~= true then
          Player.print("Matrix solver can not find solution!")
        else
          Player.print("Algebraic solver can not find solution!")
        end
      end

      if User.getModGlobalSetting("debug_solver") == true then
        if not(ok) then
          Player.print(err)
        end
        block.runtimes = runtimes
      else
        block.runtime = nil
        block.runtimes = nil
      end
    end
    if mC ~= nil then
      -- ratio pour le calcul du nombre de block
      local ratio = 1
      -- calcul ordonnee sur les recipes du block
      local row_index = my_solver.row_input + 1
      local sorter = function(t,a,b) return t[b].index > t[a].index end
      if block.by_product == false then
        sorter = function(t,a,b) return t[b].index < t[a].index end
      end
      for _, recipe in spairs(recipes,sorter) do
        if mC[row_index][my_solver.col_R] > 0 then
          recipe.count =  mC[row_index][my_solver.col_R]
          recipe.production = mC[row_index][my_solver.col_P]
        else
          recipe.count = 0
          recipe.production = 1
        end
        row_index = row_index + 1
        -- calcul dependant du recipe count
        if block.isEnergy == true then
          ModelCompute.computeEnergyFactory(recipe)
        else
          ModelCompute.computeFactory(recipe)
        end
        
        block.power = block.power + recipe.energy_total
        block.pollution_total = block.pollution_total + recipe.pollution_total

        if type(recipe.factory.limit) == "number" and recipe.factory.limit > 0 then
          local currentRatio = recipe.factory.limit/recipe.factory.count
          if currentRatio < ratio then
            ratio = currentRatio
            -- block number
            block.count = recipe.factory.count/recipe.factory.limit
            -- subblock energy
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
        for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
          recipe.factory.limit_count = nil
          recipe.beacon.limit_count = nil
          recipe.limit_energy = nil
          recipe.limit_pollution = nil
        end
      else
        block.limit_energy = block.power/block.count
        block.limit_pollution = block.pollution_total/block.count
        for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
          recipe.factory.limit_count = recipe.factory.count / block.count
          recipe.beacon.limit_count = recipe.beacon.count / block.count
          recipe.limit_energy = recipe.energy_total / block.count
          recipe.limit_pollution = recipe.pollution_total / block.count
        end
      end
      -- state = 0 => produit
      -- state = 1 => produit pilotant
      -- state = 2 => produit restant
      -- state = 3 => produit surplus

      -- finalisation du bloc
      for icol,state in pairs(mC[#mC]) do
        if icol > my_solver.col_start then
          local Z = math.abs(mC[#mC-1][icol])
          local product_header = mC[1][icol]
          local product_key = product_header.key
          local product = Product(product_header):clone()
          product.count = Z
          product.state = state
          if block.by_product == false then
            if state == 1 or state == 3 then
              -- element produit
              if block.ingredients[product_key] ~= nil then
                 block.ingredients[product_key].count = block.ingredients[product_key].count + product.count
                block.ingredients[product_key].state = state
              end
              if block.products[product_key] ~= nil then
                block.products[product_key].state = 0
              end
            else
              -- element ingredient
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
              -- element produit
              if block.products[product_key] ~= nil then
                block.products[product_key].count = block.products[product_key].count + product.count
                block.products[product_key].state = state
              end
              if block.ingredients[product_key] ~= nil then
                block.ingredients[product_key].state = 0
              end
            else
              -- element ingredient
              if block.ingredients[product_key] ~= nil then
                block.ingredients[product_key].count = block.ingredients[product_key].count + product.count
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
  end
end

--------------------------------------------------------------------------------
-- Compute module effects of factory
--
-- @function [parent=#ModelCompute] computeModuleEffects
--
-- @param #table recipe
--
function ModelCompute.computeModuleEffects(recipe)
  local factory = recipe.factory
  factory.effects = {speed = 0, productivity = 0, consumption = 0, pollution = 0}
  factory.cap = {speed = 0, productivity = 0, consumption = 0, pollution = 0}
  local factory_prototype = EntityPrototype(factory)
  factory.effects.productivity = factory_prototype:getBaseProductivity()
  -- effet module factory
  if factory.modules ~= nil then
    for module, value in pairs(factory.modules) do
      local speed_bonus = Player.getModuleBonus(module, "speed")
      local productivity_bonus = Player.getModuleBonus(module, "productivity")
      local consumption_bonus = Player.getModuleBonus(module, "consumption")
      local pollution_bonus = Player.getModuleBonus(module, "pollution")
      factory.effects.speed = factory.effects.speed + value * speed_bonus
      factory.effects.productivity = factory.effects.productivity + value * productivity_bonus
      factory.effects.consumption = factory.effects.consumption + value * consumption_bonus
      factory.effects.pollution = factory.effects.pollution + value * pollution_bonus
    end
  end
  -- effet module beacon
  local beacon = recipe.beacon
  if beacon.modules ~= nil then
    for module, value in pairs(beacon.modules) do
      local speed_bonus = Player.getModuleBonus(module, "speed")
      local productivity_bonus = Player.getModuleBonus(module, "productivity")
      local consumption_bonus = Player.getModuleBonus(module, "consumption")
      local pollution_bonus = Player.getModuleBonus(module, "pollution")
      local distribution_effectivity = EntityPrototype(beacon):getDistributionEffectivity()
      factory.effects.speed = factory.effects.speed + value * speed_bonus * distribution_effectivity * beacon.combo
      factory.effects.productivity = factory.effects.productivity + value * productivity_bonus * distribution_effectivity * beacon.combo
      factory.effects.consumption = factory.effects.consumption + value * consumption_bonus * distribution_effectivity * beacon.combo
      factory.effects.pollution = factory.effects.pollution + value * pollution_bonus * distribution_effectivity * beacon.combo
    end
  end
  if recipe.type == "resource" then
    local bonus = Player.getForce().mining_drill_productivity_bonus
    factory.effects.productivity = factory.effects.productivity + bonus
  end
  if recipe.type == "technology" then
    local bonus = Player.getForce().laboratory_speed_modifier or 0
    factory.effects.speed = factory.effects.speed + bonus * (1 + factory.effects.speed)
  end
  -- nuclear reactor
  if factory_prototype:getType() == "reactor" then
    local bonus = factory_prototype:getNeighbourBonus()
    factory.effects.consumption = factory.effects.consumption + bonus
  end

  -- cap la productivite
  if factory.effects.productivity < 0  then
    factory.effects.productivity = 0
    factory.cap.productivity = factory.cap.productivity + ModelCompute.cap_reason.productivity.module_low
  end

  -- cap la vitesse a self.capSpeed
  if factory.effects.speed < ModelCompute.capSpeed  then
    factory.effects.speed = ModelCompute.capSpeed
    factory.cap.speed = factory.cap.speed + ModelCompute.cap_reason.speed.module_low
  end
  -- cap short integer max for %
  -- @see https://fr.wikipedia.org/wiki/Entier_court
  if factory.effects.speed*100 > 32767 then
    factory.effects.speed = 32767/100
    factory.cap.speed = factory.cap.speed + ModelCompute.cap_reason.speed.module_high
  end

  -- cap l'energy a self.capEnergy
  if factory.effects.consumption < ModelCompute.capEnergy  then
    factory.effects.consumption = ModelCompute.capEnergy
    factory.cap.consumption = factory.cap.consumption + ModelCompute.cap_reason.consumption.module_low
  end

  -- cap la pollution a self.capPollution
  if factory.effects.pollution < ModelCompute.capPollution  then
    factory.effects.pollution = ModelCompute.capPollution
    factory.cap.pollution = factory.cap.pollution + ModelCompute.cap_reason.pollution.module_low
  end
  return recipe
end

-------------------------------------------------------------------------------
-- Compute energy, speed, number of factory for recipes
--
-- @function [parent=#ModelCompute] computeFactory
--
-- @param #table recipe
--
function ModelCompute.computeFactory(recipe)
  local recipe_prototype = RecipePrototype(recipe)
  local factory_prototype = EntityPrototype(recipe.factory)
  local recipe_energy = recipe_prototype:getEnergy()
  -- effet speed
  recipe.factory.speed = factory_prototype:speedFactory(recipe) * (1 + recipe.factory.effects.speed)
  -- cap speed creation maximum de 1 cycle par tick
  -- seulement sur les recipes normaux
  if recipe.type == "recipe" and recipe_energy/recipe.factory.speed < 1/60 then 
    recipe.factory.speed = 60*recipe_energy
    recipe.factory.cap.speed = recipe.factory.cap.speed + ModelCompute.cap_reason.speed.cycle
  end

  -- effet consumption
  local energy_type = factory_prototype:getEnergyType()
  recipe.factory.energy = factory_prototype:getEnergyConsumption() * (1 + recipe.factory.effects.consumption)

  -- effet pollution
  recipe.factory.pollution = factory_prototype:getPollution() * (1 + recipe.factory.effects.pollution) * (1 + recipe.factory.effects.consumption)
  
  -- compte le nombre de machines necessaires
  -- [ratio recipe] * [effort necessaire du recipe] / ([la vitesse de la factory] * [le temps en second])
  local count = recipe.count*recipe_energy/(recipe.factory.speed * recipe.time)
  if recipe.factory.speed == 0 then count = 0 end
  recipe.factory.count = count
  if Model.countModulesModel(recipe.beacon) > 0 then
    local variant = recipe.beacon.per_factory or 0
    local constant = recipe.beacon.per_factory_constant or 0
    recipe.beacon.count = count*variant + constant
  else
    recipe.beacon.count = 0
  end
  local beacon_prototype = EntityPrototype(recipe.beacon)
  recipe.beacon.energy = beacon_prototype:getEnergyUsage()
  -- calcul des totaux
  local fuel_emissions_multiplier = 1
  if energy_type ~= "electric" then
    recipe.factory.energy_total = 0
    if energy_type == "burner" or energy_type == "fluid" then
      local energy_prototype = EntityPrototype(recipe.factory):getEnergySource()
      local fuel_prototype = energy_prototype:getFuelPrototype()
      fuel_emissions_multiplier = fuel_prototype:getFuelEmissionsMultiplier()
    end
  else
    recipe.factory.energy_total = math.ceil(recipe.factory.count*recipe.factory.energy)
  end
  recipe.factory.pollution_total = recipe.factory.pollution * recipe.factory.count * recipe.time
  
  recipe.beacon.energy_total = math.ceil(recipe.beacon.count*recipe.beacon.energy)
  recipe.energy_total = recipe.factory.energy_total + recipe.beacon.energy_total
  recipe.pollution_total = recipe.factory.pollution_total * fuel_emissions_multiplier * recipe_prototype:getEmissionsMultiplier()
  -- arrondi des valeurs
  recipe.factory.speed = recipe.factory.speed
  recipe.factory.energy = math.ceil(recipe.factory.energy)
  recipe.beacon.energy = math.ceil(recipe.beacon.energy)
end

-------------------------------------------------------------------------------
-- Compute energy factory for recipes
--
-- @function [parent=#ModelCompute] computeEnergyFactory
--
-- @param #table recipe
--
function ModelCompute.computeEnergyFactory(recipe)
  local recipe_prototype = RecipePrototype(recipe)
  local factory_prototype = EntityPrototype(recipe.factory)
  local recipe_energy = recipe_prototype:getEnergy()
  -- effet speed
  recipe.factory.speed = factory_prototype:speedFactory(recipe) * (1 + recipe.factory.effects.speed)
  -- cap speed creation maximum de 1 cycle par tick
  -- seulement sur les recipes normaux
  if recipe.type == "recipe" and recipe_energy/recipe.factory.speed < 1/60 then recipe.factory.speed = 60*recipe_energy end

  -- effet consumption
  local energy_prototype = factory_prototype:getEnergySource()
      
  local energy_type = factory_prototype:getEnergyType()
  local gameDay = {day=12500,dusk=5000,night=2500,dawn=2500}
  if factory_prototype:getType() == "accumulator" then
    local dark_time = (gameDay.dusk/2 + gameDay.night + gameDay.dawn / 2 )
    --recipe_energy = dark_time
  end
  recipe.factory.energy = factory_prototype:getEnergyConsumption() * (1 + recipe.factory.effects.consumption)

  -- effet pollution
  recipe.factory.pollution = factory_prototype:getPollution() * (1 + recipe.factory.effects.pollution)
  
  -- compte le nombre de machines necessaires
  -- [ratio recipe] * [effort necessaire du recipe] / ([la vitesse de la factory]
  local count = recipe.count*recipe_energy/recipe.factory.speed
  if recipe.factory.speed == 0 then count = 0 end
  recipe.factory.count = count
  -- calcul des totaux
  local fuel_emissions_multiplier = 1
  if energy_type == "electric" then
    recipe.factory.energy_total = 0
  else
    recipe.factory.energy_total = 0
    if energy_type == "burner" or energy_type == "fluid" then
      local fuel_prototype = energy_prototype:getFuelPrototype()
      fuel_emissions_multiplier = fuel_prototype:getFuelEmissionsMultiplier()
    end
  end
  recipe.factory.pollution_total = recipe.factory.pollution * recipe.factory.count * recipe.time
  
  recipe.energy_total = recipe.factory.energy_total
  recipe.pollution_total = recipe.factory.pollution_total * fuel_emissions_multiplier * recipe_prototype:getEmissionsMultiplier()
  -- arrondi des valeurs
  recipe.factory.speed = recipe.factory.speed
  recipe.factory.energy = math.ceil(recipe.factory.energy)
  
  recipe.beacon.energy_total = 0
  recipe.beacon.energy = 0
end

-------------------------------------------------------------------------------
-- Compute input and output
--
-- @function [parent=#ModelCompute] computeInputOutput
--
-- @param #ModelRecipe recipe
-- @param #number maxLoop
-- @param #number level
-- @param #string path
--
function ModelCompute.computeInputOutput(model)
  model.products = {}
  model.ingredients = {}

  local index = 1
  for _, element in spairs(model.blocks, function(t,a,b) return t[b].index > t[a].index end) do
    -- count product
    if element.products ~= nil and table.size(element.products) then
      for key, product in pairs(element.products) do
        if model.products[key] == nil then
          model.products[key] = Model.newIngredient(product.name, product.type)
          model.products[key].temperature = product.temperature
          model.products[key].minimum_temperature = product.minimum_temperature
          model.products[key].maximum_temperature = product.maximum_temperature
          model.products[key].index = index
          index = index + 1
        end
        model.products[key].count = model.products[key].count + product.count
      end
    end
    -- count ingredient
    if element.ingredients ~= nil and table.size(element.ingredients) then
      for key, ingredient in pairs(element.ingredients) do
        if model.ingredients[key] == nil then
          model.ingredients[key] = Model.newIngredient(ingredient.name, ingredient.type)
          model.ingredients[key].temperature = ingredient.temperature
          model.ingredients[key].minimum_temperature = ingredient.minimum_temperature
          model.ingredients[key].maximum_temperature = ingredient.maximum_temperature
          model.ingredients[key].index = index
          index = index + 1
        end
        model.ingredients[key].count = model.ingredients[key].count + ingredient.count
      end
    end
  end

  for _, element in spairs(model.blocks, function(t,a,b) return t[b].index > t[a].index end) do
    -- consomme les produits
    if element.ingredients ~= nil and table.size(element.ingredients) then
      for key, ingredient in pairs(element.ingredients) do
        if model.products[key] ~= nil and element.mining_ingredient ~= ingredient.name then
          model.products[key].count = model.products[key].count - ingredient.count
          if model.products[key].count < 0.01 then model.products[key] = nil end
        end
      end
    end
    -- consomme les ingredients
    if element.products ~= nil and table.size(element.products) then
      for key, product in pairs(element.products) do
        if model.ingredients[key] ~= nil then
          model.ingredients[key].count = model.ingredients[key].count - product.count
          if model.ingredients[key].count < 0.01 then model.ingredients[key] = nil end
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Compute resources
--
-- @function [parent=#Model] computeResources
--
-- @param #ModelRecipe recipe
-- @param #number maxLoop
-- @param #number level
-- @param #string path
--
function ModelCompute.computeResources(model)
  local resources = {}

  -- calcul resource
  for k, ingredient in pairs(model.ingredients) do
    if ingredient.resource_category ~= nil or ingredient.name == "water" then
      local resource = model.resources[ingredient.name]
      if resource ~= nil then
        resource.count = ingredient.count
      else
        resource = Model.newResource(model, ingredient.name, ingredient.type, ingredient.count)
      end

      if ingredient.resource_category == "basic-solid" then
        resource.category = "basic-solid"
      end
      if ingredient.name == "water" then
        resource.category = "basic-fluid"
      end
      if ingredient.name == "crude-oil" then
        resource.category = "basic-fluid"
      end

      resource.blocks = 1
      resource.wagon = nil
      resource.storage = nil
      local ratio = 1

      -- compute storage
      if resource.category == "basic-solid" then
        resource.wagon = {type="item", name="cargo-wagon"}
        resource.wagon.count = math.ceil(resource.count/2000)
        resource.wagon.limit_count = math.ceil(resource.wagon.count * ratio)

        resource.storage = {type="item", name="steel-chest"}
        resource.storage.count = math.ceil(resource.count/(48*50))
        resource.storage.limit_count = math.ceil(resource.storage.count * ratio)
      elseif resource.category == "basic-fluid" then
        --resource.wagon = {type="item", name="cargo-wagon"}
        --resource.wagon.count = math.ceil(resource.count/2000)

        resource.storage = {type="item", name="storage-tank"}
        resource.storage.count = math.ceil(resource.count/2400)
        resource.storage.limit_count = math.ceil(resource.storage.count * ratio)
      end
      resources[resource.name] = resource
    end
  end
  model.resources = resources
end

-------------------------------------------------------------------------------
-- Compute energy, speed, number total
--
-- @function [parent=#ModelCompute] createSummary
--
function ModelCompute.createSummary(model)
  model.summary = {}
  model.summary.factories = {}
  model.summary.beacons = {}
  model.summary.modules = {}
  model.summary.building = 0
  local energy = 0
  local pollution = 0
  local building = 0

  for _, block in pairs(model.blocks) do
    energy = energy + block.power
    pollution = pollution + (block.pollution_total or 0)
    ModelCompute.computeSummaryFactory(block)
    building = building + block.summary.building
    for _,type in pairs({"factories", "beacons", "modules"}) do
      for _,element in pairs(block.summary[type]) do
        if model.summary[type][element.name] == nil then model.summary[type][element.name] = {name = element.name, type = "item", count = 0} end
        model.summary[type][element.name].count = model.summary[type][element.name].count + element.count
      end
    end
    
  end
  model.summary.energy = energy
  model.summary.pollution = pollution
  model.summary.building = building

  model.generators = {}
  -- formule 20 accumulateur /24 panneau solaire/1 MW
  model.generators["accumulator"] = {name = "accumulator", type = "item", count = 20*math.ceil(energy/(1000*1000))}
  model.generators["solar-panel"] = {name = "solar-panel", type = "item", count = 24*math.ceil(energy/(1000*1000))}
  model.generators["steam-engine"] = {name = "steam-engine", type = "item", count = math.ceil(energy/(510*1000))}
end

-------------------------------------------------------------------------------
-- Compute summary factory
--
-- @function [parent=#ModelCompute] computeSummaryFactory
--
-- @param #table block
--
function ModelCompute.computeSummaryFactory(block)
  if block ~= nil then
    block.summary = {building = 0, factories={}, beacons={}, modules={}}
    for _, recipe in pairs(block.recipes) do
      -- calcul nombre factory
      local factory = recipe.factory
      if block.summary.factories[factory.name] == nil then block.summary.factories[factory.name] = {name = factory.name, type = "item", count = 0} end
      block.summary.factories[factory.name].count = block.summary.factories[factory.name].count + math.ceil(factory.count)
      block.summary.building = block.summary.building + math.ceil(factory.count)
      -- calcul nombre de module factory
      if factory.modules ~= nil then
        for module, value in pairs(factory.modules) do
          if block.summary.modules[module] == nil then block.summary.modules[module] = {name = module, type = "item", count = 0} end
          block.summary.modules[module].count = block.summary.modules[module].count + value * math.ceil(factory.count)
        end
      end
      -- calcul nombre beacon
      local beacon = recipe.beacon
      if block.summary.beacons[beacon.name] == nil then block.summary.beacons[beacon.name] = {name = beacon.name, type = "item", count = 0} end
      block.summary.beacons[beacon.name].count = block.summary.beacons[beacon.name].count + math.ceil(beacon.count)
      block.summary.building = block.summary.building + math.ceil(beacon.count)
      -- calcul nombre de module beacon
      if beacon.modules ~= nil then
        for module, value in pairs(beacon.modules) do
          if block.summary.modules[module] == nil then block.summary.modules[module] = {name = module, type = "item", count = 0} end
          block.summary.modules[module].count = block.summary.modules[module].count + value * math.ceil(beacon.count)
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#ModelCompute] updateVersion_0_9_3
--
function ModelCompute.updateVersion_0_9_3(model)
  if ModelCompute.versionCompare(model, "0.9.3") then
    Model.resetRules()
  end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#ModelCompute] updateVersion_0_9_12
--
function ModelCompute.updateVersion_0_9_12(model)
  if ModelCompute.versionCompare(model, "0.9.12") then
    if model.blocks ~= nil then
      for _, block in pairs(model.blocks) do
        for _,element in pairs(block.products) do
          if block.input ~= nil and block.input[element.name] ~= nil then
            element.input = block.input[element.name]
          end
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#ModelCompute] updateVersion_0_9_27
--
function ModelCompute.updateVersion_0_9_27(model)
  if ModelCompute.versionCompare(model, "0.9.27") then
    ModelCompute.update(model)
  end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#ModelCompute] updateVersion_0_9_35
--
function ModelCompute.updateVersion_0_9_35(model)
  if ModelCompute.versionCompare(model, "0.9.35") then
    if model.blocks ~= nil then
      for _, block in pairs(model.blocks) do
        for _,recipe in pairs(block.recipes) do
          if recipe.beacon ~= nil then
            recipe.beacon.per_factory = Format.round(1/recipe.beacon.factory, 3)
            recipe.beacon.per_factory_constant = 0
          end
        end
      end
      ModelCompute.update(model)
    end
  end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#ModelCompute] check
--
function ModelCompute.check(model)
  if model ~= nil and (model.version == nil or model.version ~= Model.version) then
    ModelCompute.updateVersion_0_9_3(model)
    ModelCompute.updateVersion_0_9_12(model)
    ModelCompute.updateVersion_0_9_27(model)
    ModelCompute.updateVersion_0_9_35(model)
  end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#ModelCompute] versionCompare
--
function ModelCompute.versionCompare(model, version)
  local vm1,vm2,vm3 = string.match(model.version, "([0-9]+)[.]([0-9]+)[.]([0-9]+)")
  local v1,v2,v3 = string.match(version, "([0-9]+)[.]([0-9]+)[.]([0-9]+)")
  if tonumber(vm1) <= tonumber(v1) and tonumber(vm2) <= tonumber(v2) and tonumber(vm3) < tonumber(v3) then
    Player.print("Helmod information: Model is updated to version "..Model.version)
    return true
  end
  return false
end

return ModelCompute
