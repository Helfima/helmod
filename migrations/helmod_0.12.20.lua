if global.models then
    for _, model in pairs(global.models) do
      if model.blocks then
        for _, block in pairs(model.blocks) do
          if block.recipes then
            for _, recipe in pairs(block.recipes) do
              local ok , err = pcall(function()
                if recipe.beacon ~= nil and recipe.beacon.module_priority ~= nil then
                    recipe.beacons = {}
                    table.insert(recipe.beacons, recipe.beacon)
                end
              end)
              if not(ok) then
                log(err)
              end
            end
          end
        end
        -- Force recalculation of recipe.factory.speed_total and recipe.factory.speed
        -- Model and Block totals will be updated
        Player.try_load_by_name(model.owner)
        ModelCompute.try_update(model)
      end
    end
  end