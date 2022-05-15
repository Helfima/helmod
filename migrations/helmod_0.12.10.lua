local fluid_recipes = Player.getFluidRecipes()
local boiler_recipes = Player.getBoilerRecipes()

for _, model in pairs(global.models) do
  for _, block in pairs(model.blocks) do
    for _, recipe in pairs(block.recipes) do
      ---Find fluid recipes that no longer exist
      if (recipe.type == "fluid") and recipe.factory and (not fluid_recipes[recipe.name]) then
        ---Check if fluid recipe should be replaced with a boiler recipe

        -- Boilers
        local filters = {}
        table.insert(filters, {filter="type", type="boiler", mode="or"})
        table.insert(filters, {filter="name", name=recipe.factory.name, mode="and"})
        local prototypes = game.get_filtered_entity_prototypes(filters)

        for _, boiler in pairs(prototypes) do
          ---Check input fluid
          local input_fluid
          local fluidbox = boiler.fluidbox_prototypes[1]
          if fluidbox.filter then
            input_fluid = fluidbox.filter.name
          end

          if input_fluid == nil then
            goto continue
          end

          ---Check output fluid
          local output_fluid
          for _, fluidbox in pairs(boiler.fluidbox_prototypes) do
            if fluidbox.filter and fluidbox.production_type == "output" and fluidbox.filter.name == recipe.name then
              output_fluid = fluidbox.filter.name
            end
          end

          if output_fluid == nil then
            goto continue
          end

          local recipe_name = string.format("%s->%s#%s", input_fluid, output_fluid, boiler.target_temperature)
          if boiler_recipes[recipe_name] then
            recipe.type = "boiler"
            recipe.name = recipe_name
          end

          ::continue::
        end
      end
    end
  end
end
