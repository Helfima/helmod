function sprite_help(name,width,height)
  return {
    type ="sprite",
    name = "helmod_"..name,
    filename = "__helmod__/graphics/help/"..name..".png",
    priority = "medium",
    width = width,
    height = height
  }
end

data:extend({
  sprite_help("getting-start", 798, 359),
  sprite_help("quick-start", 800, 506),
  sprite_help("mod-settings-map", 478, 524),
  sprite_help("mod-settings-player", 415, 524),
  sprite_help("preferences-general", 500, 567),
  sprite_help("preferences-ui", 500, 567),
  sprite_help("preferences-module-priority", 500, 567),
  sprite_help("preferences-items-logistic", 500, 567),
  sprite_help("preferences-fluids-logistic", 500, 567),
  sprite_help("production-line", 800, 542),
  sprite_help("production-block", 800, 542),
  sprite_help("production-edition", 308, 556),
  sprite_help("recipe-editor", 500, 617),
  sprite_help("recipe-editor-info", 500, 109),
  sprite_help("recipe-editor-factory", 500, 241),
  sprite_help("recipe-editor-beacon", 500, 255),
  sprite_help("recipe-editor-tools", 500, 214),
  sprite_help("recipe-editor-module-selection", 500, 214),
  sprite_help("recipe-editor-module-priority", 500, 215),
  sprite_help("recipe-selector", 490, 647),
  sprite_help("recipe-selector-all", 490, 647),
  sprite_help("recipe-selector-helmod", 490, 647),
  sprite_help("compute-order", 800, 416),
  sprite_help("filter-panel", 800, 443),
  sprite_help("admin-tab", 800, 542),
  sprite_help("unittest-panel", 800, 372),
  sprite_help("properties-panel", 800, 542),
  sprite_help("solver-debug-panel", 800, 404)
})

function sprite_icon(name, width, height, white)
  local icon_name = "helmod-"..name
  local position = {0,0}
  if white then 
    position = {32,0}
    icon_name = icon_name.."-white"
  end
  return {
    type ="sprite",
    name = icon_name,
    filename = "__helmod__/graphics/icons/"..name..".png",
    priority = "extra-high-no-scale",
    width = width,
    height = height,
    position = position,
    shift = {0, 0}
  }
end

function sprite_icon_sm(name, width, height, white)
  local icon_name = "helmod-"..name
  local position = {64,0}
  if white then 
    position = {88,0}
    icon_name = icon_name.."-white"
  end
  icon_name = icon_name.."-sm"
  return {
    type ="sprite",
    name = icon_name,
    filename = "__helmod__/graphics/icons/"..name..".png",
    priority = "extra-high-no-scale",
    width = width,
    height = height,
    position = position,
    scale = 0.7,
    shift = {0, 0}
  }
end

function sprite_icon_tool(name, width, height)
  local icon_name = "helmod-tool-"..name
  local position = {112,0}
  return {
    type ="sprite",
    name = icon_name,
    filename = "__helmod__/graphics/icons/"..name..".png",
    priority = "extra-high-no-scale",
    width = width,
    height = height,
    position = position,
    scale = 0.7,
    shift = {0, 0}
  }
end

function sprite_tooltip(name, size, scale)
  local icon_name = "helmod-"..name
  return {
    type ="sprite",
    name = icon_name,
    filename = "__helmod__/graphics/icons/"..name..".png",
    priority = "extra-high-no-scale",
    width = size,
    height = size,
    scale = scale
  }
end

local spite_icons = {}

table.insert(spite_icons, {
  type ="sprite",
  name = "helmod-group",
  filename = "__helmod__/graphics/icons/helmod-group.png",
  priority = "extra-high-no-scale",
  width = 64,
  height = 64,
  scale = 1
})

local list = {
  {name="alert1", size=16, scale=1},
  {name="tooltip-blank", size=24, scale=1},
}
for icon_row,icon in pairs(list) do
  table.insert(spite_icons, sprite_tooltip(icon.name, icon.size, icon.scale))
end

function sprite_mipmap(name, size, count)
  local icon_name = "helmod-"..name
  return {
    type ="sprite",
    name = icon_name,
    filename = "__helmod__/graphics/icons/"..name..".png",
    size = size,
    mipmap_count = count,
    flags = {"gui-icon"}
  }
end

local mipmaps = require("prototypes.sprites_builded")
for icon_row,icon in pairs(mipmaps) do
  table.insert(spite_icons, sprite_mipmap(icon.name, icon.size, icon.count))
end
data:extend(spite_icons)