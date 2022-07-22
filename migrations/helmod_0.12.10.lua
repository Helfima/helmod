local fluid_recipes = Player.getFluidRecipes()
local boiler_recipes = Player.getBoilerRecipes()

local function FindRecipeNameForBoiler(entity_name)
  -- Boilers
  local filters = {}
  table.insert(filters, {filter="type", type="boiler", mode="and"})
  table.insert(filters, {filter="name", name=entity_name, mode="and"})
  local prototypes = game.get_filtered_entity_prototypes(filters)

  for _, entity in pairs(prototypes) do
    ---Check input fluid
    local input_fluid
    local fluidbox = entity.fluidbox_prototypes[1]
    if fluidbox.filter then
      input_fluid = fluidbox.filter.name
    end

    if input_fluid == nil then
      goto continue
    end

    ---Check output fluid
    local output_fluid
    for _, fluidbox in pairs(entity.fluidbox_prototypes) do
      if fluidbox.filter and fluidbox.production_type == "output" then
        output_fluid = fluidbox.filter.name
      end
    end

    if output_fluid == nil then
      goto continue
    end

    local recipe_name = string.format("%s->%s#%s", input_fluid, output_fluid, entity.target_temperature)
    if boiler_recipes[recipe_name] then
      return recipe_name
    end

    ::continue::
  end

  return nil
end

local function FindRecipeNameForOffshorePump(entity_name)
  -- Offshore pumps
  local filters = {}
  table.insert(filters, {filter="type", type="offshore-pump", mode="and"})
  table.insert(filters, {filter="name", name=entity_name, mode="and"})
  local entities = game.get_filtered_entity_prototypes(filters)

  for key, entity in pairs(entities) do
    return entity.fluid.name    
  end

  return nil
end

if global.models then
  for _, model in pairs(global.models) do
    if model.blocks then
      for _, block in pairs(model.blocks) do
        if block.recipes then
          for _, recipe in pairs(block.recipes) do

            ---Find fluid recipes that no longer exist
            if (recipe.type == "fluid") and recipe.factory and (not fluid_recipes[recipe.name]) then

              ---Check if fluid recipe should be replaced with a boiler recipe
              local recipe_name = FindRecipeNameForBoiler(recipe.factory.name)
              if recipe_name then
                recipe.type = "boiler"
                recipe.name = recipe_name
              end

            elseif recipe.type == "energy" then

              local prototype = EntityPrototype(recipe.factory)

              if prototype:getType() == "boiler" then
                local recipe_name = FindRecipeNameForBoiler(recipe.factory.name)
                if recipe_name then
                  recipe.type = "boiler"
                  recipe.name = recipe_name
                end

              elseif prototype:getType() == "offshore-pump" then
                local recipe_name = FindRecipeNameForOffshorePump(recipe.factory.name)
                if recipe_name then
                  recipe.type = "fluid"
                  recipe.name = recipe_name
                end
              end

            end
          end
        end
      end
    end
  end
end
