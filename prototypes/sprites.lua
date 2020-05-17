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
  sprite_help("getting-start", 798, 237),
  sprite_help("quick-start", 800, 431),
  sprite_help("mod-settings-map", 395, 650),
  sprite_help("mod-settings-player", 394, 654),
  sprite_help("preferences-general", 600, 467),
  sprite_help("preferences-module-priority", 601, 467),
  sprite_help("preferences-items-logistic", 600, 467),
  sprite_help("preferences-fluids-logistic", 599, 465),
  sprite_help("production-block", 800, 378),
  sprite_help("production-line", 800, 424),
  sprite_help("recipe-editor-factory", 200, 364),
  sprite_help("recipe-editor-module", 200, 366),
  sprite_help("recipe-selector", 492, 491),
  sprite_help("recipe-selector-all", 492, 683),
  sprite_help("compute-order", 300, 223)
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
  {name="arrow-down", sm=true},
  {name="arrow-right"},
  {name="arrow-up", sm=true},
  {name="arrow-left"},
  {name="bug"},
  {name="brief"},
  {name="calculator"},
  {name="chart"},
  {name="checkmark"},
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
  {name="factory"},
  {name="filter", sm=true},
  {name="filter-edit"},
  {name="graduation", sm=true},
  {name="gas-mask", sm=true},
  {name="hangar"},
  {name="help"},
  {name="info"},
  {name="jewel"},
  {name="link", sm=true},
  {name="maximize-window"},
  {name="menu"},
  {name="minimize-window"},
  {name="minus", sm=true, tool=true},
  {name="nuclear"},
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
  {name="search"},
  {name="services", sm=true},
  {name="settings", sm=true},
  {name="steam-heat"},
  {name="time"},
  {name="unlink", sm=true},
  {name="upload"},
  {name="wrench"}
}
local spite_icons = {}
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
  {name="tooltip-erase", size=32, scale=1},
  {name="recipe-jewel", size=16, scale=1},
  {name="recipe-nuclear", size=16, scale=1},
  {name="recipe-graduation", size=16, scale=1}
}
for icon_row,icon in pairs(list) do
  table.insert(spite_icons, sprite_tooltip(icon.name, icon.size, icon.scale))
end
data:extend(spite_icons)