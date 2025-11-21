------------------------------------------------------------------------------
---Description of the module.
---@class GuiHelper
GuiHelper = {}

-------------------------------------------------------------------------------
---Return object icons
---@param model ModelData
function GuiHelper.getModelIcons(model)
    local root_block = Model.getRootBlock(model)
    return GuiHelper.getBlockIcons(root_block, model.location)
end

-------------------------------------------------------------------------------
---Return object icons
---@param block BlockData
---@param location? LocationData
function GuiHelper.getBlockIcons(block, location)
    local icons = {}
    local primary_type = nil
    local primary_name = nil
    local primary_quality = nil

    local first_child = Model.firstChild(block.children)
    icons.first_child = first_child
    if first_child ~= nil then
        local recipe_prototype = RecipePrototype(first_child)
        primary_type, primary_name = recipe_prototype:getIcon()
        primary_quality = first_child.quality
    end

    local block_infos = Model.getBlockInfos(block)
    if block_infos.primary_icon ~= nil and block_infos.primary_icon.type ~= nil then
        primary_type = block_infos.primary_icon.name.type or "item"
        primary_name = block_infos.primary_icon.name.name
        primary_quality = block_infos.primary_icon.quality
        icons.first_child = nil
    end

    icons.primary = {type = primary_type, name = primary_name, quality = primary_quality}

    local secondary_type = nil
    local secondary_name = nil
    local secondary_quality = nil
    if block_infos.secondary_icon ~= nil then
        secondary_type = block_infos.secondary_icon.name.type or "item"
        secondary_name = block_infos.secondary_icon.name.name
        secondary_quality = block_infos.secondary_icon.quality
    elseif location ~= nil and location.name ~= "nauvis" then
        secondary_type = location.type or "item"
        secondary_name = location.name
    end

    if secondary_type ~= nil then
        icons.secondary = {type = secondary_type, name = secondary_name, quality = secondary_quality}
    end
    return icons
end