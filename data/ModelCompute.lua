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
  waste_value = 0.00001
}

-------------------------------------------------------------------------------
-- Check and valid unlinked all blocks
--
-- @function [parent=#ModelCompute] checkUnlinkedBlocks
--
function ModelCompute.checkUnlinkedBlocks()
  local model = Model.getModel()
  if model.blocks ~= nil then
    for _,block in spairs(model.blocks,function(t,a,b) return t[b].index > t[a].index end) do
      ModelCompute.checkUnlinkedBlock( block)
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
function ModelCompute.checkUnlinkedBlock(block)
  local model = Model.getModel()
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
function ModelCompute.update(check_unlink)
  local model = Model.getModel()
  if model.blocks ~= nil then
    if check_unlink == true then
      ModelCompute.checkUnlinkedBlocks()
    end
    -- calcul les blocks
    local input = {}
    for _, block in spairs(model.blocks, function(t,a,b) return t[b].index > t[a].index end) do
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
              if element.state ~= nil and element.state == 1 then
                if input[element.name] ~= nil then
                  element.input = (input[element.name] or 0) * factor
                  --element.state = 0
                end
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
          if input[product.name] == nil then
            input[product.name] =  product.count
          elseif input[product.name] ~= nil then
            input[product.name] = input[product.name] + product.count
          end
        end
        -- compte les ingredients
        for _,ingredient in pairs(block.ingredients) do
          if input[ingredient.name] == nil then
            input[ingredient.name] =  - ingredient.count
          else
            input[ingredient.name] = input[ingredient.name] - ingredient.count
          end
        end

      end
    end


    ModelCompute.computeInputOutput()
    ModelCompute.computeResources()

    -- genere un bilan
    ModelCompute.createSummary()
  end
  model.version = Model.version
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
  local model = Model.getModel()

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
  local model = Model.getModel()
  
  local recipes = block.recipes
  if recipes ~= nil then
    local row_headers = {}
    local col_headers = {}
    local col_index = {}
    local rows = {}
    col_headers["B"] = {index=1, name="B", type="none", tooltip="Base"} -- Base
    col_headers["M"] = {index=1, name="M", type="none", tooltip="Matrix calculation"} -- Matrix calculation
    col_headers["F"] = {index=1, name="F", type="none", tooltip="Number factory"} -- Number factory
    col_headers["S"] = {index=1, name="S", type="none", tooltip="Speed factory"} -- Speed factory
    col_headers["R"] = {index=1, name="R", type="none", tooltip="Count recipe"} -- Count recipe
    col_headers["P"] = {index=1, name="P", type="none", tooltip="Production"} -- Production
    col_headers["E"] = {index=1, name="E", type="none", tooltip="Energy"} -- Energy
    col_headers["C"] = {index=1, name="C", type="none", tooltip="Coefficient"} -- Coefficient ou resultat
    -- begin loop recipes
    local irow = 1

    local factor = 1
    local sorter = function(t,a,b) return t[b].index > t[a].index end
    if block.by_product == false then
      factor = -factor
      sorter = function(t,a,b) return t[b].index < t[a].index end
    end
    
    for _, recipe in spairs(recipes,sorter) do
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
      table.insert(row_headers,{name=recipe.name, type=recipe.type, tooltip=recipe.name.."\nRecette"})
      row["B"] = {name=recipe.name, type=recipe.type, tooltip=recipe.name.."\nRecette"}
      row["M"] = 0 --recipe.matrix_solver or 0
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
        local count = Product(lua_product):getAmount(recipe)
        if lua_product.by_time == true then
          count = count * model.time
        end
        lua_products[lua_product.name] = {name=lua_product.name, type=lua_product.type, count = count}
      end
      for i, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
        local count = Product(lua_ingredient):getAmount()
        if lua_ingredient.by_time == true then
          count = count * model.time
        end
        if lua_ingredients[lua_ingredient.name] == nil then
          lua_ingredients[lua_ingredient.name] = {name=lua_ingredient.name, type=lua_ingredient.type, count = count}
        else
          lua_ingredients[lua_ingredient.name].count = lua_ingredients[lua_ingredient.name].count + count
        end
      end

      if not(block.by_product == false) then
        -- prepare header products
        for name, lua_product in pairs(lua_products) do
          local index = 1
          if col_index[name] ~= nil then
            index = col_index[name]
          end
          col_index[name] = index

          local col_name = name..index
          col_headers[col_name] = {index=index, name=lua_product.name, type=lua_product.type, is_ingredient = false, tooltip=col_name.."\nProduit"}
          row[col_name] = lua_product.count * factor
          row_valid = true
        end
        -- prepare header ingredients
        for name, lua_ingredient in pairs(lua_ingredients) do
          local index = 1
          -- cas normal de l'ingredient n'existant pas du cote produit
          if col_index[name] ~= nil and lua_products[name] == nil then
            index = col_index[name]
          end
          -- cas de l'ingredient existant du cote produit
          if col_index[name] ~= nil and lua_products[name] ~= nil then
            -- cas de la valeur equivalente, on creer un nouveau element
            if lua_products[name].count == lua_ingredients[name].count or recipe.type == "resource" or recipe.type == "energy" then
              index = col_index[name]+1
            else
              index = col_index[name]
            end
          end
          col_index[name] = index

          local col_name = name..index
          col_headers[col_name] = {index=index, name=lua_ingredient.name, type=lua_ingredient.type, is_ingredient = true, tooltip=col_name.."\nIngredient"}
          row[col_name] = ( row[col_name] or 0 ) - lua_ingredients[name].count * factor
          row_valid = true
        end
      else
        -- prepare header ingredients
        for name, lua_ingredient in pairs(lua_ingredients) do
          local index = 1
          -- cas normal de l'ingredient n'existant pas du cote produit
          if col_index[name] ~= nil then
            index = col_index[name]
          end
          col_index[name] = index

          local col_name = name..index
          col_headers[col_name] = {index=index, name=lua_ingredient.name, type=lua_ingredient.type, is_ingredient = true, tooltip=col_name.."\nIngredient"}
          row[col_name] = ( row[col_name] or 0 ) - lua_ingredients[name].count * factor
          row_valid = true
        end
        -- prepare header products
        for name, lua_product in pairs(lua_products) do
          local index = 1
          if col_index[name] ~= nil then
            index = col_index[name]
          end
          -- cas du produit existant du cote ingredient
          if col_index[name] ~= nil and lua_ingredients[name] ~= nil then
            -- cas de la valeur equivalente, on creer un nouveau element
            if lua_products[name].count == lua_products[name].count or recipe.type == "resource" then
              index = col_index[name]+1
            else
              index = col_index[name]
            end
          end
          col_index[name] = index

          local col_name = name..index
          col_headers[col_name] = {index=index, name=lua_product.name, type=lua_product.type, is_ingredient = false, tooltip=col_name.."\nProduit"}
          row[col_name] = lua_product.count * factor
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
    for column,header in pairs(col_headers) do
      table.insert(rowH, header)
    end
    table.insert(mA, rowH)
    -- bluid value
    for _,row in pairs(rows) do
      local rowA = {}
      for column,_ in pairs(col_headers) do
        if row[column] ~= nil then
          table.insert(rowA, row[column])
        else
          table.insert(rowA, 0)
        end
      end
      table.insert(mA, rowA)
    end

    local row_input = {}
    local row_z = {}
    local input_ready = {}
    for column,col_header in pairs(col_headers) do
      if col_header.name == "B" then
        table.insert(row_input, {name="Input", type="none"})
        table.insert(row_z, {name="Z", type="none"})
      else
        local block_elements = block.products
        if block.by_product == false then
          block_elements = block.ingredients
        end
        if block_elements ~= nil and block_elements[col_header.name] ~= nil and not(input_ready[col_header.name]) and col_header.index == 1 then
          table.insert(row_input, block_elements[col_header.name].input or 0)
          input_ready[col_header.name] = true
        else
          table.insert(row_input, 0)
        end
        table.insert(row_z, 0)
      end
    end
    table.insert(mA, 2, row_input)
    table.insert(mA, row_z)

    return mA
  end
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
      local row = {}

      local row_valid = false
      local recipe_prototype = RecipePrototype(recipe)
      local lua_recipe = recipe_prototype:native()

      for i, lua_product in pairs(recipe_prototype:getProducts(recipe.factory)) do
        block_products[lua_product.name] = {name=lua_product.name, type=lua_product.type, count = 0}
      end
      for i, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
        block_ingredients[lua_ingredient.name] = {name=lua_ingredient.name, type=lua_ingredient.type, count = 0}
      end

    end
    -- preparation state
    -- state = 0 => produit
    -- state = 1 => produit pilotant
    -- state = 2 => produit restant
    for i, block_product in pairs(block_products) do
      -- recopie la valeur input
      if block.products[block_product.name] ~= nil then
        block_product.input = block.products[block_product.name].input
      end
      -- pose le status
      if block_ingredients[block_product.name] == nil then
        block_product.state = 1
      else
        block_product.state = 0
      end
    end

    for i, block_ingredient in pairs(block_ingredients) do
      -- recopie la valeur input
      if block.ingredients[block_ingredient.name] ~= nil then
        block_ingredient.input = block.ingredients[block_ingredient.name].input
      end
      -- pose le status
      if block_products[block_ingredient.name] ~= nil then
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
  local model = Model.getModel()
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
        local time = model.time
        if block.isEnergy then time = 1 end
        mC, runtimes = my_solver:solve(mA, debug, block.by_factory, time)
      end)
      if not(ok) then
        Player.print("Matrix solver can not found solution!")
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
      local ratioRecipe = nil
      -- calcul ordonnee sur les recipes du block
      local row_index = my_solver.row_input + 1
      local sorter = function(t,a,b) return t[b].index > t[a].index end
      if block.by_product == false then
        sorter = function(t,a,b) return t[b].index < t[a].index end
      end
      for _, recipe in spairs(recipes,sorter) do
        
        recipe.count =  mC[row_index][my_solver.col_R]
        recipe.production = mC[row_index][my_solver.col_P]
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
            ratioRecipe = recipe.index
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

      -- finalisation du bloc
      for icol,state in pairs(mC[#mC]) do
        if icol > my_solver.col_start then
          local Z = math.abs(mC[#mC-1][icol])
          local product_header = mC[1][icol]
          local product = Product(product_header):clone()
          product.count = Z
          product.state = state
          if block.by_product == false then
            if state == 1 or state == 3 then
              -- element produit
              if block.ingredients[product.name] == nil then
              --block.products[product.name] = product
              else
                block.ingredients[product.name].count = block.ingredients[product.name].count + product.count
                block.ingredients[product.name].state = state
              end
              -- element ingredient intermediaire
            else
              -- element ingredient
              if block.products[product.name] == nil then
              --block.ingredients[product.name] = product
              else
                block.products[product.name].count = block.products[product.name].count + product.count
                block.products[product.name].state = state
              end
              if block.ingredients[product.name] ~= nil then
                block.ingredients[product.name].state = state
              end
              -- element produit intermediaire
            end
          else
            if state == 1 or state == 3 then
              -- element produit
              if block.products[product.name] == nil then
              --block.products[product.name] = product
              else
                block.products[product.name].count = block.products[product.name].count + product.count
                block.products[product.name].state = state
              end
              -- element ingredient intermediaire
            else
              -- element ingredient
              if block.ingredients[product.name] == nil then
              --block.ingredients[product.name] = product
              else
                block.ingredients[product.name].count = block.ingredients[product.name].count + product.count
                block.ingredients[product.name].state = state
              end
              -- element produit intermediaire
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
    factory.effects.productivity = factory.effects.productivity + Player.getForce().mining_drill_productivity_bonus
  end
  -- cap la productivite
  if factory.effects.productivity < 0  then factory.effects.productivity = 0 end

  -- cap la vitesse a self.capSpeed
  if factory.effects.speed < ModelCompute.capSpeed  then factory.effects.speed = ModelCompute.capSpeed end
  -- cap short integer max for %
  -- @see https://fr.wikipedia.org/wiki/Entier_court
  if factory.effects.speed*100 > 32767 then factory.effects.speed = 32767/100 end

  -- cap l'energy a self.capEnergy
  if factory.effects.consumption < ModelCompute.capEnergy  then factory.effects.consumption = ModelCompute.capEnergy end

  -- cap la pollution a self.capPollution
  if factory.effects.pollution < ModelCompute.capPollution  then factory.effects.pollution = ModelCompute.capPollution end
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
  local recipe_energy = recipe_prototype:getEnergy()
  -- effet speed
  recipe.factory.speed = ModelCompute.speedFactory(recipe) * (1 + recipe.factory.effects.speed)
  -- cap speed creation maximum de 1 cycle par tick
  if recipe_energy/recipe.factory.speed < 1/60 then recipe.factory.speed = 60*recipe_energy end

  -- effet consumption
  local factory_prototype = EntityPrototype(recipe.factory)
  local energy_type = factory_prototype:getEnergyType()
  recipe.factory.energy = factory_prototype:getEnergyConsumption() * (1 + recipe.factory.effects.consumption)

  -- effet pollution
  recipe.factory.pollution = factory_prototype:getPollution() * (1 + recipe.factory.effects.pollution)
  
  -- compte le nombre de machines necessaires
  local model = Model.getModel()
  -- [ratio recipe] * [effort necessaire du recipe] / ([la vitesse de la factory] * [le temps en second])
  local count = recipe.count*recipe_energy/(recipe.factory.speed * model.time)
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
  recipe.factory.pollution_total = recipe.factory.pollution * recipe.factory.count * model.time
  
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
  local model = Model.getModel()
  local recipe_prototype = RecipePrototype(recipe)
  local recipe_energy = recipe_prototype:getEnergy()
  -- effet speed
  recipe.factory.speed = ModelCompute.speedFactory(recipe) * (1 + recipe.factory.effects.speed)
  -- cap speed creation maximum de 1 cycle par tick
  if recipe.type ~= "fluid" and recipe_energy/recipe.factory.speed < 1/60 then recipe.factory.speed = 60*recipe_energy end

  -- effet consumption
  local factory_prototype = EntityPrototype(recipe.factory)
  local energy_prototype = factory_prototype:getEnergySource()
      
  local energy_type = factory_prototype:getEnergyType()
  local gameDay = {day=12500,dust=5000,night=2500,dawn=2500}
  if factory_prototype:getType() == EntityType.accumulator then
    local dark_time = (gameDay.dust/2 + gameDay.night + gameDay.dawn / 2 )
    recipe_energy = dark_time/60
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
  recipe.factory.pollution_total = recipe.factory.pollution * recipe.factory.count * model.time
  
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
function ModelCompute.computeInputOutput()
  local model = Model.getModel()
  model.products = {}
  model.ingredients = {}

  local index = 1
  for _, element in spairs(model.blocks, function(t,a,b) return t[b].index > t[a].index end) do
    -- count product
    if element.products ~= nil and Model.countList(element.products) then
      for _, product in pairs(element.products) do
        if model.products[product.name] == nil then
          model.products[product.name] = Model.newIngredient(product.name, product.type)
          model.products[product.name].index = index
          index = index + 1
        end
        model.products[product.name].count = model.products[product.name].count + product.count
      end
    end
    -- count ingredient
    if element.ingredients ~= nil and Model.countList(element.ingredients) then
      for _, ingredient in pairs(element.ingredients) do
        if model.ingredients[ingredient.name] == nil then
          model.ingredients[ingredient.name] = Model.newIngredient(ingredient.name, ingredient.type)
          model.ingredients[ingredient.name].index = index
          index = index + 1
        end
        model.ingredients[ingredient.name].count = model.ingredients[ingredient.name].count + ingredient.count
      end
    end
  end

  for _, element in spairs(model.blocks, function(t,a,b) return t[b].index > t[a].index end) do
    -- consomme les produits
    if element.ingredients ~= nil and Model.countList(element.ingredients) then
      for _, ingredient in pairs(element.ingredients) do
        if model.products[ingredient.name] ~= nil and element.mining_ingredient ~= ingredient.name then
          model.products[ingredient.name].count = model.products[ingredient.name].count - ingredient.count
          if model.products[ingredient.name].count < 0.01 then model.products[ingredient.name] = nil end
        end
      end
    end
    -- consomme les ingredients
    if element.products ~= nil and Model.countList(element.products) then
      for _, product in pairs(element.products) do
        if model.ingredients[product.name] ~= nil then
          model.ingredients[product.name].count = model.ingredients[product.name].count - product.count
          if model.ingredients[product.name].count < 0.01 then model.ingredients[product.name] = nil end
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
function ModelCompute.computeResources()
  local model = Model.getModel()
  local resources = {}

  -- calcul resource
  for k, ingredient in pairs(model.ingredients) do
    if ingredient.resource_category ~= nil or ingredient.name == "water" then
      local resource = model.resources[ingredient.name]
      if resource ~= nil then
        resource.count = ingredient.count
      else
        resource = Model.newResource(ingredient.name, ingredient.type, ingredient.count)
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
function ModelCompute.createSummary()
  local model = Model.getModel()
  model.summary = {}
  model.summary.factories = {}
  model.summary.beacons = {}
  model.summary.modules = {}
  local energy = 0
  local pollution = 0

  for _, block in pairs(model.blocks) do
    energy = energy + block.power
    pollution = pollution + (block.pollution_total or 0)
    ModelCompute.computeSummaryFactory(block)
    for _,type in pairs({"factories", "beacons", "modules"}) do
      for _,element in pairs(block.summary[type]) do
        if model.summary[type][element.name] == nil then model.summary[type][element.name] = {name = element.name, type = "item", count = 0} end
        model.summary[type][element.name].count = model.summary[type][element.name].count + element.count
      end
    end
    
  end
  model.summary.energy = energy
  model.summary.pollution = pollution

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
    block.summary = {factories={}, beacons={}, modules={}}
    for _, recipe in pairs(block.recipes) do
      -- calcul nombre factory
      local factory = recipe.factory
      if block.summary.factories[factory.name] == nil then block.summary.factories[factory.name] = {name = factory.name, type = "item", count = 0} end
      block.summary.factories[factory.name].count = block.summary.factories[factory.name].count + math.ceil(factory.count)
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
-- Compute power
--
-- @function [parent=#ModelCompute] computePower
--
-- @param key power id
--
function ModelCompute.computePower(key)
  local power = Model.getPower(key)
  if power ~= nil then
    local primary_prototype = EntityPrototype(power.primary.name)
    local secondary_prototype = EntityPrototype(power.secondary.name)
    if primary_prototype:getType() == EntityType.generator then
      -- calcul primary
      local count = math.ceil( power.power / primary_prototype:getEnergyConsumption() )
      power.primary.count = count or 0
      -- calcul secondary
      if secondary_prototype:native() ~= nil and secondary_prototype:getType() == EntityType.boiler then
        local count = 0
        count = math.ceil( power.power / secondary_prototype:getEnergyConsumption() )
        power.secondary.count = count or 0
      else
        power.secondary.count = 0
      end
    end
    if primary_prototype:getType() == EntityType.solar_panel then
      -- calcul primary
      local count = math.ceil( power.power / primary_prototype:getEnergyConsumption() )
      power.primary.count = count or 0
      -- calcul secondary
      if secondary_prototype:native() ~= nil and secondary_prototype:getType() == EntityType.accumulator then
        local factor = 2
        -- ajout energy pour accumulateur
        local gameDay = {day=12500,dust=5000,night=2500,dawn=2500}
        -- selon les aires il faut de l'accu en dehors du jour selon le trapese journalier
        local accu= (gameDay.dust/factor + gameDay.night + gameDay.dawn / factor ) / ( gameDay.day )
        -- puissance nominale la nuit
        local energy_prototype = secondary_prototype:getEnergySource()
        local count1 = power.power/ energy_prototype:getOutputFlowLimit()
        -- puissance durant la penombre
        -- formula (puissance*durree_penombre)/(60s*capacite)
        local count2 = power.power*( gameDay.dust / factor + gameDay.night + gameDay.dawn / factor ) / ( 60 * energy_prototype:getBufferCapacity() )

        if count1 > count2 then
          power.secondary.count = count1 or 0
        else
          power.secondary.count = count2 or 0
        end
        power.primary.count = count*(1+accu) or 0
      else
        power.secondary.count = 0
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Return spped factory for recipe
--
-- @function [parent=#ModelCompute] speedFactory
--
-- @param #table recipe
--
function ModelCompute.speedFactory(recipe)
  if recipe.name == "steam" then
    -- @see https://wiki.factorio.com/Boiler
    local factory_prototype = EntityPrototype(recipe.factory)
    -- info energy 1J=1W
    local power_extract = factory_prototype:getPowerExtract()
    local power_usage = factory_prototype:getEnergyConsumption()
    return power_usage/power_extract
  elseif recipe.type == "resource" then
    -- (mining power - ore mining hardness) * mining speed
    -- @see https://wiki.factorio.com/Mining
    local factory_prototype = EntityPrototype(recipe.factory)
    local recipe_prototype = EntityPrototype(recipe.name)

    local mining_speed = factory_prototype:getMiningSpeed()
    local hardness = recipe_prototype:getMineableHardness()
    local mining_time = recipe_prototype:getMineableMiningTime()
    return hardness * mining_speed / mining_time
  elseif recipe.type == "fluid" then
    -- @see https://wiki.factorio.com/Power_production
    local factory_prototype = EntityPrototype(recipe.factory)
    local pumping_speed = factory_prototype:getPumpingSpeed()
    return pumping_speed
  elseif recipe.type == "technology" then
    local bonus = Player.getForce().laboratory_speed_modifier or 1
    return 1*bonus
  elseif recipe.type == "energy" then
    return 1
  else
    local factory_prototype = EntityPrototype(recipe.factory)
    return factory_prototype:getCraftingSpeed()
  end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#ModelCompute] updateVersion_0_9_3
--
function ModelCompute.updateVersion_0_9_3()
  if ModelCompute.versionCompare("0.9.3") then
    local model = Model.getModel()
    Model.resetRules()
  end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#ModelCompute] updateVersion_0_9_12
--
function ModelCompute.updateVersion_0_9_12()
  if ModelCompute.versionCompare("0.9.12") then
    local model = Model.getModel()
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
function ModelCompute.updateVersion_0_9_27()
  if ModelCompute.versionCompare("0.9.27") then
    ModelCompute.update()
  end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#ModelCompute] updateVersion_0_9_35
--
function ModelCompute.updateVersion_0_9_35()
  if ModelCompute.versionCompare("0.9.35") then
    local model = Model.getModel()
    if model.blocks ~= nil then
      for _, block in pairs(model.blocks) do
        for _,recipe in pairs(block.recipes) do
          if recipe.beacon ~= nil then
            recipe.beacon.per_factory = Format.round(1/recipe.beacon.factory, 3)
            recipe.beacon.per_factory_constant = 0
          end
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#ModelCompute] check
--
function ModelCompute.check()
  local model = Model.getModel()
  if model ~= nil and (model.version == nil or model.version ~= Model.version) then
    ModelCompute.updateVersion_0_9_3()
    ModelCompute.updateVersion_0_9_12()
    ModelCompute.updateVersion_0_9_27()
    ModelCompute.updateVersion_0_9_35()
  end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#ModelCompute] versionCompare
--
function ModelCompute.versionCompare(version)
  local model = Model.getModel()
  local vm1,vm2,vm3 = string.match(model.version, "([0-9]+)[.]([0-9]+)[.]([0-9]+)")
  local v1,v2,v3 = string.match(version, "([0-9]+)[.]([0-9]+)[.]([0-9]+)")
  if tonumber(vm1) <= tonumber(v1) and tonumber(vm2) <= tonumber(v2) and tonumber(vm3) < tonumber(v3) then
    Player.print("Helmod information: Model is updated to version "..Model.version)
    return true
  end
  return false
end

return ModelCompute
