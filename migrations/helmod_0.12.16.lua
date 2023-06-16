if global.models then
  for _, model in pairs(global.models) do
    if model.blocks then
      for _, block in pairs(model.blocks) do
        if block.recipes then
          for _, recipe in pairs(block.recipes) do
            -- Rename time to base_time
            recipe.base_time = recipe.time

            -- Set recipe.time
            local recipe_prototype = RecipePrototype(recipe)
            recipe.time = recipe_prototype:getEnergy(recipe.factory)

            --if recipe.type ~= "energy" then
              --ModelCompute.computeFactory(recipe)
            --end
          end
        end
      end
      -- Force recalculation of recipe.factory.speed_total and recipe.factory.speed
      -- Model and Block totals will be updated
      Player.try_load_by_name(model.owner)
      ModelCompute.update(model)
    end
  end
end