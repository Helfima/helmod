---
---Description of the module.
---@class Blueprint
local Blueprint = {
  ---single-line comment
  classname = "HMBlueprint",
}

function Blueprint.get_entities(data)
    local entities = {}
    if data.blueprint then
        Blueprint.get_blueprint_entities(entities, data)
    elseif data.blueprint_book then
        for _, blueprint in pairs(data.blueprint_book.blueprints) do
            Blueprint.get_blueprint_entities(entities, blueprint)
        end
    end
    return entities
end

function Blueprint.get_blueprint_entities(entities, data)
    if data.blueprint then
        local blueprint = data.blueprint
        if blueprint.entities then
            for key, entity in pairs(blueprint.entities) do
                local name = entity.name
                if not(entities[name]) then
                    entities[name] = {name=name}
                end
            end
        end
    end

    for name, entity in pairs(entities) do
        local lua_entity = Player.getEntityPrototype(name)
        entity.lua_prototype = lua_entity
    end
end

function Blueprint.get_tiles(data)
    local tiles = {}
    if data.blueprint then
        Blueprint.get_blueprint_tiles(tiles, data)
    elseif data.blueprint_book then
        for _, blueprint in pairs(data.blueprint_book.blueprints) do
            Blueprint.get_blueprint_tiles(tiles, blueprint)
        end
    end
    return tiles
end

function Blueprint.get_blueprint_tiles(tiles, data)
    if data.blueprint then
        local blueprint = data.blueprint
        if blueprint.tiles then
            for key, entity in pairs(blueprint.tiles) do
                local name = entity.name
                if not(tiles[name]) then
                    tiles[name] = {name=name}
                end
            end
        end
    end

    for name, tile in pairs(tiles) do
        local lua_item = Player.getItemPrototype(name)
        tile.lua_prototype = lua_item
    end
end

return Blueprint