if global.models then
    for _, model in pairs(global.models) do
      if model.blocks then
        local first = Model.firstChild(model.blocks)
        model.block_root = Model.newBlock(model, { name = model.id, energy_total = 0, pollution = 0, summary = {} })
        model.block_root.parent_id = model.id
        model.block_root.name = first.name
        model.block_root.type = first.type
        for _, block in pairs(model.blocks) do
            model.block_root.children[block.id] = block
            block.class = "Block"
            if block.recipes ~= nil then
                block.children = {}
                for _, recipe in spairs(block.recipes, defines.sorters.block.sort) do
                    if recipe.beacon ~= nil and recipe.beacons == nil then
                        recipe.beacons = {}
                        table.insert(recipe.beacons, recipe.beacon)
                    end
                    block.children[recipe.id] = recipe
                end
            end
            block.recipes = nil
        end
        ModelBuilder.rebuildParentBlockOfModel(model)
        -- Force recalculation of recipe.factory.speed_total and recipe.factory.speed
        -- Model and Block totals will be updated
        Player.try_load_by_name(model.owner)
        ModelCompute.try_update(model)
      end
    end
  end