Matrix = require "core.Matrix"
Solver = require "core.Solver"
Simplex = require "core.SolverSimplex"
------------------------------------------------------------------------------
-- Description of the module.
-- @module ModelCompute
--
local ModelCompute = {
  -- single-line comment
  classname = "HMModelCompute",
  capEnergy = -0.8,
  capSpeed = -0.8,
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
  Logging:debug(ModelCompute.classname, "checkUnlinkedBlocks()")
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
  Logging:debug(ModelCompute.classname, "checkUnlinkedBlock():", block)
  local model = Model.getModel()
  local unlinked = true
  local recipe = Player.getRecipe(block.name)
  if recipe ~= nil then
    if model.blocks ~= nil then
      for _, current_block in spairs(model.blocks,function(t,a,b) return t[b].index > t[a].index end) do
        if current_block.id == block.id then
          Logging:debug(ModelCompute.classname, "checkUnlinkedBlock():break",block.id)
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
  end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#ModelCompute] update
--
function ModelCompute.update()
  Logging:debug(ModelCompute.classname , "********** update()")
  ModelCompute.updateVersion_0_5_4()
  ModelCompute.updateVersion_0_6_0()

  local model = Model.getModel()

  -- reset all factories
  if model ~= nil and (model.version == nil or model.version ~= Model.version) then
    Logging:debug(Model.classname , "********** version",Model.version)

    if model.blocks ~= nil then
      for _, productBlock in pairs(model.blocks) do
        for _, recipe in pairs(productBlock.recipes) do
          local factory = recipe.factory
          local beacon = recipe.beacon
          local _recipe = Player.getRecipe(recipe.name)
          Model.setFactory(productBlock.id, recipe.name, factory.name)
          Model.setBeacon(productBlock.id, recipe.name, beacon.name)
          if _recipe ~= nil then
            recipe.is_resource = not(_recipe.force)
            if recipe.is_resource then recipe.category = "extraction-machine" end
          end
        end
      end
    end
  end

  if model.blocks ~= nil then
    -- calcul les blocks
    local input = {}
    for _, block in spairs(model.blocks, function(t,a,b) return t[b].index > t[a].index end) do
      -- premiere recette
      local _,recipe = next(block.recipes)
      if recipe ~= nil then

        --ModelCompute.prepareBlock(block)

        -- state = 0 => produit
        -- state = 1 => produit pilotant
        -- state = 2 => produit restant
        -- prepare input
        if not(block.unlinked) and block.products ~= nil then
          for _,product in pairs(block.products) do
            if product.state ~= nil and bit32.band(product.state, 1) > 0 then
              if input[product.name] ~= nil then
                -- block linked
                if block.input == nil then block.input = {} end
                block.input[product.name] = input[product.name]
                product.state = 0
              end
            end
          end
        end

        ModelCompute.computeBlockByFactory(block)
        ModelCompute.computeBlockCleanInput(block)

        if block.solver == true then
          local ok , err = pcall(function()
            ModelCompute.computeSimplexBlock(block)
          end)
          if not(ok) then
            Player.print("Matrix solver can not found solution!")
          end
        else
          --ModelCompute.computeBlock(block)
          ModelCompute.computeBlock2(block)
        end

        -- compte les ingredients
        for _,ingredient in pairs(block.ingredients) do
          if input[ingredient.name] == nil then
            input[ingredient.name] = ingredient.count
          else
            input[ingredient.name] = input[ingredient.name] + ingredient.count
          end
        end
        -- consomme les ingredients
        for _,product in pairs(block.products) do
          if input[product.name] ~= nil then
            input[product.name] = input[product.name] - product.count
          end
        end
      end
    end


    ModelCompute.computeInputOutput()

    ModelCompute.computeResources()

    Logging:debug(ModelCompute.classname, "update():","Factory compute OK")
    -- genere un bilan
    ModelCompute.createSummary()
    Logging:debug(ModelCompute.classname, "update():","Summary OK")

    Logging:debug(ModelCompute.classname , "********** model updated:",model)
  end
  model.version = Model.version
end
-------------------------------------------------------------------------------
-- Compute recipe block
--
-- @function [parent=#ModelCompute] computeBlockRecipe
--
-- @param #table element production block model
--
function ModelCompute.computeBlockRecipe(block, recipe)
  Logging:debug(ModelCompute.classname, "computeBlockRecipe()", block.name, recipe.name, recipe.type)
  if recipe ~= nil then
    local lua_recipe = RecipePrototype.load(recipe).native()

    local production = 1
    if recipe.production ~= nil then production = recipe.production end

    -- for void in angel mod
    if RecipePrototype.isVoid() then
      Logging:debug(ModelCompute.classname, "isvoid", RecipePrototype.isVoid(), "recipe name", recipe.name)
      local lua_ingredient = RecipePrototype.getIngredients(recipe.factory)[1]
      local ingredient = Product.load(lua_ingredient).new()
      local p_amount = ingredient.amount
      local count = 0
      if block.products[lua_ingredient.name] ~= nil then
        count = block.products[lua_ingredient.name].count*production / p_amount
      end
      if recipe.count < count then recipe.count = count end
    else
      -- recipe classique
      -- prepare le recipe
      for _, lua_product in pairs(RecipePrototype.getProducts()) do
        if block.ingredients[lua_product.name] ~= nil then
          local product = Product.load(lua_product).new()
          local p_amount = Product.getAmount(recipe)
          local count = block.ingredients[lua_product.name].count*production / p_amount
          Logging:debug(ModelCompute.classname, "count", count)
          Logging:debug(ModelCompute.classname, "p_amount", p_amount)
          if recipe.count < count then recipe.count = count end
        end
      end
    end
    Logging:debug(ModelCompute.classname, "recipe.count=", recipe.count)

    -- compute ingredients
    for k, lua_ingredient in pairs(RecipePrototype.getIngredients(recipe.factory)) do
      local ingredient = Product.load(lua_ingredient).new()
      -- consolide la production
      local i_amount = ingredient.amount
      -- exclus le type ressource ou fluid
      if recipe.type ~= "resource" and recipe.type ~= "fluid" then
        for k, lua_product in pairs(RecipePrototype.getProducts()) do
          if lua_ingredient.name == lua_product.name then
            local product = Product.load(lua_product).new()
            i_amount = i_amount - product.amount
          end
        end
      end

      local nextCount = i_amount * recipe.count
      block.ingredients[lua_ingredient.name].count = block.ingredients[lua_ingredient.name].count + nextCount
      Logging:debug(ModelCompute.classname, "lua_ingredient.name", lua_ingredient.name, "nextCount=", nextCount)
    end
    Logging:debug(ModelCompute.classname, "block.ingredients=", block.ingredients)
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
  Logging:debug(ModelCompute.classname, "computeMatrixBlockRecipe()", block.name, recipe.name, recipe.type, factory_count)
  if recipe ~= nil then
    local lua_recipe = RecipePrototype.load(recipe).native()

    Logging:debug(ModelCompute.classname, "recipe.count=", recipe.count)

    -- compute ingredients
    for k, lua_ingredient in pairs(RecipePrototype.getIngredients(recipe.factory)) do
      local ingredient = Product.load(lua_ingredient).new()
      -- consolide la production
      local i_amount = ingredient.amount
      -- exclus le type ressource ou fluid
      if recipe.type ~= "resource" and recipe.type ~= "fluid" then
        for k, lua_product in pairs(RecipePrototype.getProducts()) do
          if lua_ingredient.name == lua_product.name then
            local product = Product.load(lua_product).new()
            i_amount = i_amount - product.amount
          end
        end
      end

      local nextCount = i_amount * recipe.count
      block.ingredients[lua_ingredient.name].count = block.ingredients[lua_ingredient.name].count + nextCount
      Logging:debug(ModelCompute.classname, "lua_ingredient.name", lua_ingredient.name, "nextCount=", nextCount)
    end
    Logging:debug(ModelCompute.classname, "block.ingredients=", block.ingredients)
  end
end

-------------------------------------------------------------------------------
-- Compute recipe block
--
-- @function [parent=#ModelCompute] computeBlockTechnology
--
-- @param #table element production block model
--
function ModelCompute.computeBlockTechnology(block, recipe)
  Logging:debug(ModelCompute.classname, "computeBlockTechnology()", block.name)
  local lua_recipe = RecipePrototype.load(recipe).native()
  local production = 1
  if recipe.production ~= nil then production = recipe.production end

  local productNominal = lua_recipe.research_unit_count
  if recipe.research_unit_count_formula ~= nil then
    productNominal = loadstring("local L = " .. lua_recipe.level .. " return " .. recipe.research_unit_count_formula)()
  end
  -- calcul factory productivity effect
  recipe.count = productNominal*production / (1 + recipe.factory.effects.productivity)

  -- compute ingredients
  for k, lua_ingredient in pairs(RecipePrototype.getIngredients(recipe.factory)) do
    local ingredient = Product.load(lua_ingredient).new()
    local i_amount = ingredient.amount
    local nextCount = i_amount * recipe.count
    block.ingredients[ingredient.name].count = block.ingredients[ingredient.name].count + nextCount
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
  Logging:debug(ModelCompute.classname, "computeMatrixBlockTechnology()", block.name)
  local lua_recipe = RecipePrototype.load(recipe).native()
  -- compute ingredients
  for k, lua_ingredient in pairs(RecipePrototype.getIngredients(recipe.factory)) do
    local ingredient = Product.load(lua_ingredient).new()
    local i_amount = ingredient.amount
    local nextCount = i_amount * recipe.count
    block.ingredients[ingredient.name].count = block.ingredients[ingredient.name].count + nextCount
  end
end

-------------------------------------------------------------------------------
-- Prepare production block
--
-- @function [parent=#ModelCompute] prepareBlock
--
-- @param #table block block of model
--
function ModelCompute.prepareBlock(block)
  Logging:debug(ModelCompute.classname, "prepareBlock", block.name)
  local model = Model.getModel()

  local recipes = block.recipes
  if recipes ~= nil then
    -- initialisation
    block.products = {}
    block.ingredients = {}
    block.power = 0
    block.count = 1

    block.mining_ingredient = nil
    -- preparation produits et ingredients du block
    for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
      Logging:debug(ModelCompute.classname, "recipe", recipe.name, recipe.type)
      local lua_recipe = RecipePrototype.load(recipe).native()
      -- construit la list des ingredients
      for _, lua_ingredient in pairs(RecipePrototype.getIngredients(recipe.factory)) do
        if block.ingredients[lua_ingredient.name] == nil then
          if recipe.type == "resource" then
            block.mining_ingredient = lua_ingredient.name
            Logging:debug(ModelCompute.classname, "mining_ingredient", block.mining_ingredient)
          end
          block.ingredients[lua_ingredient.name] = Product.load(lua_ingredient).new()
        end
        block.ingredients[lua_ingredient.name].count = 0
      end
      -- construit la list des produits
      -- si c'est un voider la liste est vide
      for _, lua_product in pairs(RecipePrototype.getProducts()) do
        if block.products[lua_product.name] == nil then
          block.products[lua_product.name] = Product.load(lua_product).new()
          -- state = 0 => produit
          -- state = 1 => produit pilotant
          -- state = 2 => produit restant

          if not(block.ingredients[lua_product.name]) or block.mining_ingredient == lua_product.name then
            block.products[lua_product.name].state = 1
          else
            block.products[lua_product.name].state = 0
          end
        end
        block.products[lua_product.name].count = 0
      end
      -- initialise le recipe
      recipe.count = 0
    end
  end
end

-------------------------------------------------------------------------------
-- Compute production block
--
-- @function [parent=#ModelCompute] computeBlockByFactory
--
-- @param #table block block of model
--
function ModelCompute.computeBlockByFactory(block)
  Logging:debug(ModelCompute.classname, "computeBlockByFactory():", block.name)
  local model = Model.getModel()

  local recipes = block.recipes
  if recipes ~= nil then

    -- calcul selon la factory
    if block.by_factory == true then
      -- initialise la premiere recette avec le nombre d'usine
      local first_recipe = Model.firstRecipe(recipes)
      if first_recipe ~= nil then
        Logging:debug(Model.classname, "first_recipe",first_recipe)
        first_recipe.factory.count = block.factory_number
        ModelCompute.computeModuleEffects(first_recipe)
        ModelCompute.computeFactory(first_recipe)

        if first_recipe.type == "technology" then
          first_recipe.count = 1
        else
          local _,lua_product = next(RecipePrototype.load(first_recipe).getProducts())
          if block.input == nil then block.input = {} end
          -- formula [product amount] * (1 + [productivity]) *[assembly speed]*[time]/[recipe energy]
          -- Product.load(lua_product).getAmount(first_recipe) calcul avec la productivity
          block.input[lua_product.name] = Product.load(lua_product).getAmount(first_recipe) * ( block.factory_number or 0 ) * first_recipe.factory.speed * model.time / RecipePrototype.getEnergy()
          Logging:debug(ModelCompute.classname, "by factory info", Product.load(lua_product).getAmount(first_recipe), first_recipe.factory.speed)
        end
        Logging:debug(ModelCompute.classname, "block.input",block.input)
      end
    end
  end

end

-------------------------------------------------------------------------------
-- Compute production block
--
-- @function [parent=#ModelCompute] computeSimplexBlock
--
-- @param #table block block of model
--
function ModelCompute.computeSimplexBlock(block)
  Logging:debug(ModelCompute.classname, "computeSimplexBlock():", block.name)
  local model = Model.getModel()

  local recipes = block.recipes
  block.power = 0
  block.count = 1
  
  if recipes ~= nil then
    local mB,mC
    local mA, row_headers, col_headers = ModelCompute.getBlockMatrix(block)

    if mA ~= nil then
      if Player.getSettings("debug", true) ~= "none" then
        block.matrix2 = {}
        block.matrix2.col_headers = col_headers
        block.matrix2.row_headers = row_headers
        block.matrix2.mA = mA
      end

      Simplex.new(mA)

      mC = Simplex.solve()
      mB = Simplex.getMx()
      Logging:debug(ModelCompute.classname, "----> matrix B", mB)

      if Player.getSettings("debug", true) ~= "none" then
        block.matrix2.mB = mB
        block.matrix2.mC = mC
      end
    end
    if mC ~= nil then
      -- ratio pour le calcul du nombre de block
      local ratio = 1
      local ratioRecipe = nil
      -- calcul ordonnee sur les recipes du block
      local row_index = Simplex.row_input + 1
      for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
        Logging:debug(ModelCompute.classname , "matrix index", recipe.name, row_index)
        ModelCompute.computeModuleEffects(recipe)
        local icol = 1
        recipe.count =  mC[row_index][icol]
        row_index = row_index + 1
        Logging:debug(ModelCompute.classname , "----> matrix solution", recipe.name, icol, recipe.count)
        --Logging:debug(Model.classname , "matrix recipe.count", recipe.count, Model.speedFactory(recipe) * (1 + recipe.factory.effects.speed))

        --        if recipe.type == "technology" then
        --          ModelCompute.computeMatrixBlockTechnology(block, recipe)
        --        else
        --          ModelCompute.computeMatrixBlockRecipe(block, recipe)
        --        end

        ModelCompute.computeFactory(recipe)

        block.power = block.power + recipe.energy_total

        if type(recipe.factory.limit) == "number" and recipe.factory.limit > 0 then
          local currentRatio = recipe.factory.limit/recipe.factory.count
          if currentRatio < ratio then
            ratio = currentRatio
            ratioRecipe = recipe.index
            -- block number
            block.count = recipe.factory.count/recipe.factory.limit
            -- subblock energy
            block.sub_power = 0
            if block.count ~= nil and block.count > 0 then
              block.sub_power = math.ceil(block.power/block.count)
            end
          end
        end

        -- state = 0 => produit
        -- state = 1 => produit pilotant
        -- state = 2 => produit restant
      end

      if block.count < 1 then
        block.count = 1
      end

      -- initialisation
      block.products = {}
      block.ingredients = {}
      -- conversion des col headers en array
      local product_headers = {}
      for _,header in pairs(col_headers) do
        table.insert(product_headers,header)
      end
      -- finalisation du bloc
      for icol,state in pairs(mC[1]) do
        if icol > Solver.col_start then
          local Z = math.abs(mC[#mC][icol])
          local product_header = product_headers[icol]
          local product = Product.load(product_header).new()
          product.count = Z
          product.state = state
          Logging:debug(ModelCompute.classname , "----> product", product)
          if state == 1 or state == 3 then
            if block.products[product.name] == nil then
              block.products[product.name] = product
            else
              block.products[product.name].count = block.products[product.name].count + product.count
            end
          else
            if math.abs(Z) > ModelCompute.waste_value then
              if block.ingredients[product.name] == nil then
                block.ingredients[product.name] = product
              else
                block.ingredients[product.name].count = block.products[product.name].count + product.count
              end
            end
          end
        end
      end
      -- initialisation end
    end
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
  Logging:debug(ModelCompute.classname, "computeBlockCleanInput():", block.name)
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
-- @function [parent=#ModelCompute] getMatrix
--
-- @param #table block block of model
--
function ModelCompute.getBlockMatrix(block)
  Logging:debug(ModelCompute.classname, "getBlockMatrix()", block.name, block.recipes)

  local recipes = block.recipes
  if recipes ~= nil then
    local row_headers = {}
    local col_headers = {}
    local col_index = {}
      local rows = {}
      col_headers["R"] = {name="R", type="none"} -- Count recipe
      col_headers["P"] = {name="P", type="none"} -- Production
      col_headers["E"] = {name="E", type="none"} -- Energy
      col_headers["C"] = {name="C", type="none"} -- Coefficient ou resultat
      -- begin loop recipes
      local irow = 1
      for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
        local row = {}

        local row_valid = false
        local lua_recipe = RecipePrototype.load(recipe).native()

        -- prepare le taux de production
        local production = 1
        if recipe.production ~= nil then production = recipe.production end
        table.insert(row_headers,{name=recipe.name, type=recipe.type, tooltip=recipe.name.."\nRecette"})
        row["R"] = 0
        row["P"] = production
        row["E"] = RecipePrototype.getEnergy()
        row["C"] = 0

        ModelCompute.computeModuleEffects(recipe)
        --ModelCompute.computeFactory(recipe)

        local col_product = {}
        for i, lua_product in pairs(RecipePrototype.getProducts()) do
          local index = 1
          if col_index[lua_product.name] ~= nil then
            index = col_index[lua_product.name]
          end
          col_index[lua_product.name] = index
          col_product[lua_product.name] = true

          local col_name = lua_product.name..index
          col_headers[col_name] = {name=lua_product.name, type=lua_product.type, is_ingredient = false, tooltip=col_name.."\nProduit"}
          row[col_name] = Product.load(lua_product).getAmount(recipe)
          row_valid = true
        end
        local col_ingredient = {}
        Logging:debug(ModelCompute.classname, "----> ingredient", recipe.name, RecipePrototype.getIngredients(recipe.factory))
        for i, lua_ingredient in pairs(RecipePrototype.getIngredients(recipe.factory)) do
          local index = 1
          -- cas normal de l'ingredient n'existant pas du cote produit
          if col_index[lua_ingredient.name] ~= nil and col_product[lua_ingredient.name] == nil then
            index = col_index[lua_ingredient.name]
          end
          -- cas de l'ingredient existant du cote produit
          if col_index[lua_ingredient.name] ~= nil and col_product[lua_ingredient.name] ~= nil then
            if col_ingredient[lua_ingredient.name] == nil then
              index = col_index[lua_ingredient.name]+1
            else
              index = col_index[lua_ingredient.name]
            end
          end
          col_index[lua_ingredient.name] = index
          col_ingredient[lua_ingredient.name] = true

          local col_name = lua_ingredient.name..index
          col_headers[col_name] = {name=lua_ingredient.name, type=lua_ingredient.type, is_ingredient = true, tooltip=col_name.."\nIngredient"}
          row[col_name] = ( row[col_name] or 0 ) - Product.load(lua_ingredient).getAmount()
          row_valid = true
        end

        if row_valid then
          table.insert(rows,row)
        end
      end

      -- end loop recipes
      Logging:debug(ModelCompute.classname, "----> matrix col headers", col_headers)
      Logging:debug(ModelCompute.classname, "----> matrix row headers", row_headers)
      Logging:debug(ModelCompute.classname, "----> matrix rows", rows)

      -- on bluid A correctement
      local mA = {}
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
      local input_ready = {}
      for column,col_header in pairs(col_headers) do
        if block.input ~= nil and block.input[col_header.name] and not(input_ready[col_header.name]) then
          table.insert(row_input, block.input[col_header.name])
          input_ready[col_header.name] = true
        else
          table.insert(row_input, 0)
        end
      end
      table.insert(mA, 1, row_input)
      table.insert(row_headers,1, {name="Input", type="none"})
      table.insert(row_headers, {name="Z", type="none"})

      Logging:debug(ModelCompute.classname, "----> matrix A", mA)
      local export = ""
      for _,row in pairs(mA) do
        export = export.."{"
        for icol,cell in pairs(row) do
          export = export..cell
          if icol ~= #row then
            export = export..","
          end
        end
        export = export.."}"
      end
      Logging:debug(ModelCompute.classname, "----> export matrix A", export)

      return mA, row_headers, col_headers
  end
end
-------------------------------------------------------------------------------
-- Compute production block
--
-- @function [parent=#ModelCompute] computeBlock2
--
-- @param #table block block of model
--
function ModelCompute.computeBlock2(block)
  Logging:debug(ModelCompute.classname, "computeBlock()", block.name)

  local recipes = block.recipes
  block.power = 0
  block.count = 1
  
  if recipes ~= nil then
    local mB,mC
    local mA, row_headers, col_headers = ModelCompute.getBlockMatrix(block)

    if mA ~= nil then
      if Player.getSettings("debug", true) ~= "none" then
        block.matrix1 = {}
        block.matrix1.col_headers = col_headers
        block.matrix1.row_headers = row_headers
        block.matrix1.mA = mA
      end

      Solver.new(mA)

      mC = Solver.solve()
      mB = Solver.getMx()


      Logging:debug(ModelCompute.classname, "----> matrix B", mB)
      Logging:debug(ModelCompute.classname, "----> matrix C", mC)

      if Player.getSettings("debug", true) ~= "none" then
        block.matrix1.mB = mB
        block.matrix1.mC = mC
      end
    end
    if mC ~= nil then
      -- ratio pour le calcul du nombre de block
      local ratio = 1
      local ratioRecipe = nil
      -- calcul ordonnee sur les recipes du block
      local row_index = Solver.row_input + 1
      for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
        Logging:debug(ModelCompute.classname , "solver index", recipe.name, row_index)
        ModelCompute.computeModuleEffects(recipe)
        local icol = 1
        recipe.count = mC[row_index][icol]
        row_index = row_index + 1
        Logging:debug(ModelCompute.classname , "----> solver solution", recipe.name, icol, recipe.count)

        ModelCompute.computeFactory(recipe)

        block.power = block.power + recipe.energy_total

        if type(recipe.factory.limit) == "number" and recipe.factory.limit > 0 then
          local currentRatio = recipe.factory.limit/recipe.factory.count
          if currentRatio < ratio then
            ratio = currentRatio
            ratioRecipe = recipe.index
            -- block number
            block.count = recipe.factory.count/recipe.factory.limit
            -- subblock energy
            block.sub_power = 0
            if block.count ~= nil and block.count > 0 then
              block.sub_power = math.ceil(block.power/block.count)
            end
          end
        end

        Logging:debug(ModelCompute.classname , "********** Compute before clean:", block)

        -- state = 0 => produit
        -- state = 1 => produit pilotant
        -- state = 2 => produit restant

      end

      if block.count < 1 then
        block.count = 1
      end

      -- initialisation
      block.products = {}
      block.ingredients = {}
      -- conversion des col headers en array
      local product_headers = {}
      for _,header in pairs(col_headers) do
        table.insert(product_headers,header)
      end
      -- finalisation du bloc
      for icol,state in pairs(mC[1]) do
        if icol > Solver.col_start then
          local Z = math.abs(mC[#mC][icol])
          local product_header = product_headers[icol]
          local product = Product.load(product_header).new()
          product.count = Z
          product.state = state
          Logging:debug(ModelCompute.classname , "----> product", product)
          if state == 1 or state == 3 then
            if block.products[product.name] == nil then
              block.products[product.name] = product
            else
              block.products[product.name].count = block.products[product.name].count + product.count
            end
          else
            if block.ingredients[product.name] == nil then
              block.ingredients[product.name] = product
            else
              block.ingredients[product.name].count = block.ingredients[product.name].count + product.count
            end
          end
        end
      end
      -- nettoyage meme nom produit et ingredient
      for name, product in pairs(block.products) do
        if block.ingredients[name] ~= nil then
          local product_count = block.products[name].count
          local ingredient_count = block.ingredients[name].count
          block.products[name].count = product_count - ingredient_count
          block.ingredients[name].count = ingredient_count - product_count
        end
      end
      -- nettoyage des produits
      for name, product in pairs(block.products) do
        if product.state ~= 1 and product.count < ModelCompute.waste_value then
          block.products[name] = nil
        end
      end
      -- nettoyage des ingredients
      for name, product in pairs(block.ingredients) do
        if product.count < ModelCompute.waste_value then
          block.ingredients[name] = nil
        end
      end
      -- initialisation end
    end
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
  Logging:debug(ModelCompute.classname, "********** computeBlock **********")
  local model = Model.getModel()

  local recipes = block.recipes
  if recipes ~= nil then

    if block.input ~= nil then
      local input_computed = {}
      for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
        local lua_recipe = RecipePrototype.load(recipe).native()
        -- prepare le taux de production
        local production = 1
        if recipe.production ~= nil then production = recipe.production end
        -- initialise la premiere recette avec le input
        for _, lua_product in pairs(RecipePrototype.getProducts()) do
          local product = Product.load(lua_product).new()
          if input_computed[product.name] == nil and block.input[product.name] ~= nil then
            local p_amount = product.amount
            local i_amount = 0

            -- consolide product.count
            -- exclus le type ressource ou fluid
            if recipe.type ~= "resource" and recipe.type ~= "fluid" then
              for k, lua_ingredient in pairs(RecipePrototype.getIngredients(recipe.factory)) do
                if lua_ingredient.name == product.name then
                  local ingredient = Product.load(lua_ingredient).new()
                  i_amount = ingredient.amount
                end
              end
            end

            if block.ingredients[product.name] == nil then
              block.ingredients[product.name] = {
                name = product.name,
                type = "fake",
                amount = 0,
                count = 0
              }
            end
            block.ingredients[product.name].count = block.input[product.name] * (p_amount/(p_amount-i_amount))
            input_computed[product.name] = true
          end
        end
      end
    end

    Logging:debug(ModelCompute.classname , "********** initialized:", block)

    -- ratio pour le calcul du nombre de block
    local ratio = 1
    local ratioRecipe = nil
    -- calcul ordonnee sur les recipes du block
    for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
      ModelCompute.computeModuleEffects(recipe)

      if recipe.type == "technology" then
        ModelCompute.computeBlockTechnology(block, recipe)
      else
        ModelCompute.computeBlockRecipe(block, recipe)
      end

      ModelCompute.computeFactory(recipe)

      block.power = block.power + recipe.energy_total

      if type(recipe.factory.limit) == "number" and recipe.factory.limit > 0 then
        local currentRatio = recipe.factory.limit/recipe.factory.count
        if currentRatio < ratio then
          ratio = currentRatio
          ratioRecipe = recipe.index
          -- block number
          block.count = recipe.factory.count/recipe.factory.limit
          -- subblock energy
          block.sub_power = 0
          if block.count ~= nil and block.count > 0 then
            block.sub_power = math.ceil(block.power/block.count)
          end
        end
      end

      Logging:debug(ModelCompute.classname , "********** Compute before clean:", block)

      local lua_recipe = RecipePrototype.load(recipe).native()
      -- reduit les produits du block
      -- state = 0 => produit
      -- state = 1 => produit pilotant
      -- state = 2 => produit restant
      for _, lua_product in pairs(RecipePrototype.getProducts()) do
        local count = Product.load(lua_product).countProduct(recipe)
        if count > 0 then
          -- compte les produits
          if block.products[lua_product.name] ~= nil then
            block.products[lua_product.name].count = block.products[lua_product.name].count + count
          end
          -- consomme les produits
          if block.ingredients[lua_product.name] ~= nil then
            block.ingredients[lua_product.name].count = block.ingredients[lua_product.name].count - count
          end
        end
      end
      Logging:debug(ModelCompute.classname , "********** Compute after clean product:", block)
      for _, lua_ingredient in pairs(RecipePrototype.getIngredients(recipe.factory)) do
        local count = Product.load(lua_ingredient).countIngredient(recipe)
        if count > 0 then
          -- consomme les ingredients
          -- exclus le type ressource ou fluid
          if recipe.type ~= "resource" and recipe.type ~= "fluid" and block.products[lua_ingredient.name] ~= nil and block.mining_ingredient ~= lua_ingredient.name  then
            block.products[lua_ingredient.name].count = block.products[lua_ingredient.name].count - count
            if RecipePrototype.isVoid() then
              block.ingredients[lua_ingredient.name].count = block.ingredients[lua_ingredient.name].count - count
            end
          end
        end
      end
      Logging:debug(ModelCompute.classname , "********** Compute after clean ingredient:", block)
    end

    -- control zero state 1
    local count_state_1 = 0
    for _, product in pairs(block.products) do
      if bit32.band(product.state, 1) > 0 then count_state_1 = count_state_1 + 1 end
    end
    Logging:debug(ModelCompute.classname , "product.state = 1", count_state_1)
    if count_state_1 == 0 then
      for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
        for _, product in pairs(RecipePrototype.load(recipe).getProducts()) do
          if block.products[product.name] ~= nil then
            block.products[product.name].state = 1
          end
        end
        break
      end
    end
    Logging:debug(ModelCompute.classname , "block.products", block.products)
    if block.count < 1 then
      block.count = 1
    end

    -- reduit les engredients fake du block
    for _, ingredient in pairs(block.ingredients) do
      if ingredient.type == "fake" then block.ingredients[ingredient.name] = nil end
    end

    -- reduit les produits du block
    for _, product in pairs(block.products) do
      -- change le satuts si exedant
      if block.ingredients[product.name] ~= nil and count_state_1 ~= 0 and block.mining_ingredient ~= product.name and not(RecipePrototype.isVoid()) then
        product.state = 2
      end
      if block.products[product.name].count < ModelCompute.waste_value and not(bit32.band(product.state, 1) > 0) then
        block.products[product.name] = nil
      end
    end

    -- reduit les ingredients du block
    for _, ingredient in pairs(block.ingredients) do
      if block.ingredients[ingredient.name].count < ModelCompute.waste_value then
        block.ingredients[ingredient.name] = nil
      end
    end
    Logging:debug(ModelCompute.classname , "computeBlock end", block)
  end
end

-------------------------------------------------------------------------------
-- Compute module effects of factory
--
-- @function [parent=#ModelCompute] computeModuleEffects
--
-- @param #table recipe
--
function ModelCompute.computeModuleEffects(recipe)
  Logging:debug(ModelCompute.classname, "computeModuleEffects()",recipe.name)

  local factory = recipe.factory
  factory.effects = {speed = 0, productivity = 0, consumption = 0}
  -- effet module factory
  if factory.modules ~= nil then
    for module, value in pairs(factory.modules) do
      local speed_bonus = Player.getModuleBonus(module, "speed")
      local productivity_bonus = Player.getModuleBonus(module, "productivity")
      local consumption_bonus = Player.getModuleBonus(module, "consumption")
      factory.effects.speed = factory.effects.speed + value * speed_bonus
      factory.effects.productivity = factory.effects.productivity + value * productivity_bonus
      factory.effects.consumption = factory.effects.consumption + value * consumption_bonus
    end
  end
  -- effet module beacon
  local beacon = recipe.beacon
  if beacon.modules ~= nil then
    for module, value in pairs(beacon.modules) do
      local speed_bonus = Player.getModuleBonus(module, "speed")
      local productivity_bonus = Player.getModuleBonus(module, "productivity")
      local consumption_bonus = Player.getModuleBonus(module, "consumption")
      local distribution_effectivity = EntityPrototype.load(beacon).getDistributionEffectivity()
      factory.effects.speed = factory.effects.speed + value * speed_bonus * distribution_effectivity * beacon.combo
      factory.effects.productivity = factory.effects.productivity + value * productivity_bonus * distribution_effectivity * beacon.combo
      factory.effects.consumption = factory.effects.consumption + value * consumption_bonus * distribution_effectivity * beacon.combo
    end
  end

  -- cap la vitesse a self.capSpeed
  if factory.effects.speed < Model.capSpeed  then factory.effects.speed = Model.capSpeed end

  -- cap l'energy a self.capEnergy
  if factory.effects.consumption < Model.capEnergy  then factory.effects.consumption = Model.capEnergy end

end

-------------------------------------------------------------------------------
-- Compute energy, speed, number of factory for recipes
--
-- @function [parent=#ModelCompute] computeFactory
--
-- @param #table recipe
--
function ModelCompute.computeFactory(recipe)
  Logging:debug(ModelCompute.classname, "computeFactory()", recipe.name)
  local recipe_energy = RecipePrototype.load(recipe).getEnergy()
  -- effet speed
  recipe.factory.speed = ModelCompute.speedFactory(recipe) * (1 + recipe.factory.effects.speed)
  -- cap speed creation maximum de 1 cycle par tick
  if recipe.name ~= "steam" and recipe_energy/recipe.factory.speed < 1/60 then recipe.factory.speed = 60*recipe_energy end

  -- effet consumption
  local energy_type = EntityPrototype.load(recipe.factory).getEnergyType()
  if energy_type ~= "burner" then
    recipe.factory.energy = EntityPrototype.load(recipe.factory).getEnergyUsage() * (1 + recipe.factory.effects.consumption)
  else
    recipe.factory.energy = 0
  end

  -- compte le nombre de machines necessaires
  local model = Model.getModel()
  -- [ratio recipe] * [effort necessaire du recipe] / ([la vitesse de la factory] * [le temps en second])
  local count = recipe.count*recipe_energy/(recipe.factory.speed * model.time)
  Logging:debug(ModelCompute.classname, "computeFactory()", "recipe.count=" , recipe.count, "lua_recipe.energy=", recipe_energy, "recipe.factory.speed=", recipe.factory.speed, "model.time=", model.time)
  if recipe.factory.speed == 0 then count = 0 end
  recipe.factory.count = count
  if Model.countModulesModel(recipe.beacon) > 0 then
    recipe.beacon.count = count/recipe.beacon.factory
  else
    recipe.beacon.count = 0
  end

  recipe.beacon.energy = EntityPrototype.load(recipe.beacon).getEnergyUsage()
  -- calcul des totaux
  recipe.factory.energy_total = math.ceil(recipe.factory.count*recipe.factory.energy)
  recipe.beacon.energy_total = math.ceil(recipe.beacon.count*recipe.beacon.energy)
  recipe.energy_total = recipe.factory.energy_total + recipe.beacon.energy_total
  -- arrondi des valeurs
  recipe.factory.speed = recipe.factory.speed
  recipe.factory.energy = math.ceil(recipe.factory.energy)
  recipe.beacon.energy = math.ceil(recipe.beacon.energy)
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
  Logging:debug(ModelCompute.classname, "computeInputOutput()")
  local model = Model.getModel()
  model.products = {}
  model.ingredients = {}

  local index = 1
  for _, element in spairs(model.blocks, function(t,a,b) return t[b].index > t[a].index end) do
    -- count product
    if element.products ~= nil and Model.countList(element.products) then
      Logging:debug(ModelCompute.classname, "element.products", element.products)
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
  Logging:debug(ModelCompute.classname, "computeResources()")
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

  -- cumul de l'energie des blocks
  for _, block in pairs(model.blocks) do
    energy = energy + block.power
    for _, recipe in pairs(block.recipes) do
      ModelCompute.computeSummaryFactory(recipe)
    end
  end

  model.summary.energy = energy

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
-- @param object object
--
function ModelCompute.computeSummaryFactory(object)
  local model = Model.getModel()
  -- calcul nombre factory
  local factory = object.factory
  if model.summary.factories[factory.name] == nil then model.summary.factories[factory.name] = {name = factory.name, type = "item", count = 0} end
  model.summary.factories[factory.name].count = model.summary.factories[factory.name].count + math.ceil(factory.count)
  -- calcul nombre de module factory
  for module, value in pairs(factory.modules) do
    if model.summary.modules[module] == nil then model.summary.modules[module] = {name = module, type = "item", count = 0} end
    model.summary.modules[module].count = model.summary.modules[module].count + value * math.ceil(factory.count)
  end
  -- calcul nombre beacon
  local beacon = object.beacon
  if model.summary.beacons[beacon.name] == nil then model.summary.beacons[beacon.name] = {name = beacon.name, type = "item", count = 0} end
  model.summary.beacons[beacon.name].count = model.summary.beacons[beacon.name].count + math.ceil(beacon.count)
  -- calcul nombre de module beacon
  for module, value in pairs(beacon.modules) do
    if model.summary.modules[module] == nil then model.summary.modules[module] = {name = module, type = "item", count = 0} end
    model.summary.modules[module].count = model.summary.modules[module].count + value * math.ceil(beacon.count)
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
  Logging:debug(ModelCompute.classname, "computePower():", key, power)
  if power ~= nil then
    if EntityPrototype.load(power.primary.name).getType() == EntityType.generator then
      -- calcul primary
      local count = math.ceil( power.power / EntityPrototype.load(power.primary.name).getEnergyNominal() )
      power.primary.count = count or 0
      -- calcul secondary
      if EntityPrototype.load(power.secondary.name).native() ~= nil and EntityPrototype.load(power.secondary.name).getType() == EntityType.boiler then
        local count = 0
        -- angel mod a un electrical boiler, on filtre
        if EntityPrototype.getEnergyType() == "burner" then
          count = math.ceil( power.power / EntityPrototype.load(power.secondary.name).getEnergyNominal() )
        end
        power.secondary.count = count or 0
      else
        power.secondary.count = 0
      end
    end
    if EntityPrototype.load(power.primary.name).getType() == EntityType.solar_panel then
      -- calcul primary
      local count = math.ceil( power.power / EntityPrototype.load(power.primary.name).getEnergyNominal() )
      power.primary.count = count or 0
      -- calcul secondary
      if EntityPrototype.load(power.secondary.name).native() ~= nil and EntityPrototype.load(power.secondary.name).getType() == EntityType.accumulator then
        local factor = 2
        -- ajout energy pour accumulateur
        local gameDay = {day=12500,dust=5000,night=2500,dawn=2500}
        -- selon les aires il faut de l'accu en dehors du jour selon le trapese journalier
        local accu= (gameDay.dust/factor + gameDay.night + gameDay.dawn / factor ) / ( gameDay.day )
        -- puissance nominale la nuit
        local count1 = power.power/ EntityPrototype.load(power.secondary.name).getElectricOutputFlowLimit()
        -- puissance durant la penombre
        -- formula (puissance*durree_penombre)/(60s*capacite)
        local count2 = power.power*( gameDay.dust / factor + gameDay.night + gameDay.dawn / factor ) / ( 60 * EntityPrototype.load(power.secondary.name).getElectricBufferCapacity() )

        Logging:debug(ModelCompute.classname , "********** computePower result:", accu, count1, count2)
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
  Logging:debug(ModelCompute.classname, "speedFactory()", recipe.name)
  if recipe.name == "steam" then
    -- @see https://wiki.factorio.com/Boiler
    EntityPrototype.load(recipe.factory)
    -- info energy 1J=1W
    local power_extract = EntityPrototype.getPowerExtract()
    local power_usage = EntityPrototype.getMaxEnergyUsage()
    Logging:debug(ModelCompute.classname, "power_extract", power_extract, "power_usage", power_usage, "fluid", power_usage/power_extract)
    return power_usage/power_extract
  elseif recipe.type == "resource" then
    -- (mining power - ore mining hardness) * mining speed
    -- @see https://wiki.factorio.com/Mining
    local mining_speed = EntityPrototype.load(recipe.factory).getMiningSpeed()
    local hardness = EntityPrototype.load(recipe.name).getMineableHardness()
    local mining_time = EntityPrototype.load(recipe.name).getMineableMiningTime()
    return hardness * mining_speed / mining_time
  elseif recipe.type == "technology" then
    local bonus = Player.getForce().laboratory_speed_modifier or 1
    return 1*bonus
  else
    return EntityPrototype.load(recipe.factory).getCraftingSpeed()
  end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#ModelCompute] updateVersion_0_6_0
--
function ModelCompute.updateVersion_0_6_0()
  local model = Model.getModel()
  if model.version == nil or model.version < "0.6.0" then
    Logging:debug(Model.classname , "********** updating version 0.6.0")
    local globalGui = Player.getGlobalGui()
    for _, block in pairs(model.blocks) do
      globalGui.currentBlock = block.id
      for _, recipe in pairs(block.recipes) do
        local recipe_type = RecipePrototype.find(recipe).type()
        if recipe.is_resource then recipe_type = "resource" end

        local recipeModel = {}
        recipeModel.id = recipe.id
        recipeModel.index = recipe.index
        recipeModel.name = recipe.name
        recipeModel.type = recipe_type
        recipeModel.count = 0
        recipeModel.production = recipe.production or 1
        recipeModel.factory = Model.newFactory(recipe.factory.name)
        recipeModel.factory.limit = recipe.factory.limit
        recipeModel.factory.modules = recipe.factory.modules
        recipeModel.beacon = Model.newBeacon(recipe.beacon.name)
        recipeModel.beacon.modules = recipe.beacon.modules
        block.recipes[recipe.id] = recipeModel
      end
    end
    ModelCompute.checkUnlinkedBlocks()
    Logging:debug(ModelCompute.classname , "********** updated version 0.6.0")
    Player.print("Helmod information: Model is updated to version 0.6.0")
  end
end
-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#ModelCompute] updateVersion_0_5_4
--
function ModelCompute.updateVersion_0_5_4()
  local model = Model.getModel()
  if model.version == nil or model.version < "0.5.4" then
    Logging:debug(ModelCompute.classname , "********** updating version 0.5.4")
    model.resources = {}
    for _, productBlock in pairs(model.blocks) do
      -- modify recipe id
      local recipes = {}
      for _, recipe in pairs(productBlock.recipes) do
        recipe.id = "R"..recipe.id
        recipes[recipe.id] = recipe
      end
      productBlock.recipes = recipes
      -- modify input
      if productBlock.input ~= nil and productBlock.input.key ~= nil then
        local key = productBlock.input.key
        local quantity = productBlock.input.quantity
        productBlock.input = {}
        productBlock.input[key] = quantity or 0
      end
    end
    ModelCompute.checkUnlinkedBlocks()
    Logging:debug(ModelCompute.classname , "********** updated version 0.5.4")
    Player.print("Helmod information: Model is updated to version 0.5.4")
  end
end


return ModelCompute
