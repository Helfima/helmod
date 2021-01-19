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

local list = {
  {name="arrow-down", sm=true, tool=true},
  {name="arrow-right", sm=true},
  {name="arrow-up", sm=true, tool=true},
  {name="arrow-left"},
  {name="beacon-hide", sm=true},
  {name="bug"},
  {name="burnt", sm=true, tool=true},
  {name="brief"},
  {name="by_ingredient", sm=true},
  {name="by_product", sm=true},
  {name="calculator"},
  {name="chart"},
  {name="checkmark", sm=true},
  {name="checkmark-hide", sm=true},
  {name="clock"},
  {name="close-window"},
  {name="container"},
  {name="copy"},
  {name="database"},
  {name="delete", sm=true},
  {name="done"},
  {name="download"},
  {name="edit"},
  {name="end", sm=true},
  {name="energy"},
  {name="erase", sm=true},
  {name="factory", sm=true, tool=true},
  {name="filter", sm=true},
  {name="filter-edit"},
  {name="graduation", sm=true, tool=true},
  {name="gas-mask", sm=true},
  {name="hangar", sm=true, tool=true},
  {name="hangar-hide", sm=true},
  {name="help"},
  {name="info"},
  {name="jewel", sm=true, tool=true},
  {name="jewel-hide", sm=true},
  {name="limitation", sm=true, tool=true},
  {name="link", sm=true, tool=true},
  {name="maximize-window"},
  {name="menu"},
  {name="minimize-window"},
  {name="minus", sm=true, tool=true},
  {name="nuclear", sm=true, tool=true},
  {name="ok"},
  {name="paste"},
  {name="pause"},
  {name="pin"},
  {name="play", sm=true},
  {name="plus", sm=true, tool=true},
  {name="property"},
  {name="record", sm=true},
  {name="refresh", sm=true},
  {name="robot"},
  {name="save", sm=true},
  {name="search"},
  {name="services", sm=true},
  {name="settings", sm=true},
  {name="steam-heat"},
  {name="text", sm=true},
  {name="time"},
  {name="unlink", sm=true},
  {name="upload"},
  {name="wrench"}
}
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

for icon_row,icon in pairs(list) do
  table.insert(spite_icons, sprite_icon(icon.name, 32, 32))
  table.insert(spite_icons, sprite_icon(icon.name, 32, 32, true))
  if icon.sm then
    table.insert(spite_icons, sprite_icon_sm(icon.name, 24, 24))
    table.insert(spite_icons, sprite_icon_sm(icon.name, 24, 24, true))
  end
  if icon.tool then
    table.insert(spite_icons, sprite_icon_tool(icon.name, 15, 15))
  end
end

local list = {
  {name="alert1", size=16, scale=1},
  {name="tooltip-add", size=24, scale=1},
  {name="tooltip-remove", size=24, scale=1},
  {name="tooltip-edit", size=48, scale=1},
  {name="tooltip-energy", size=32, scale=1},
  {name="tooltip-blank", size=24, scale=1},
  {name="tooltip-pipette", size=24, scale=1},
  {name="tooltip-info", size=32, scale=1},
  {name="tooltip-record", size=32, scale=1},
  {name="tooltip-play", size=32, scale=1},
  {name="tooltip-end", size=32, scale=1},
  {name="tooltip-erase", size=32, scale=1}
}
for icon_row,icon in pairs(list) do
  table.insert(spite_icons, sprite_tooltip(icon.name, icon.size, icon.scale))
end
data:extend(spite_icons)