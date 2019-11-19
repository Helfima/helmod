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
  sprite_help("getting-start", 400, 203),
  sprite_help("mod-settings-map", 150, 179),
  sprite_help("mod-settings-player", 150, 179),
  sprite_help("production-block", 300, 223),
  sprite_help("production-line", 300, 200),
  sprite_help("recipe-editor-factory", 200, 364),
  sprite_help("recipe-editor-module", 200, 366),
  sprite_help("recipe-selector", 200, 319),
  sprite_help("recipe-selector-all", 200, 321),
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
  {name="download"},
  {name="edit"},
  {name="end", sm=true},
  {name="energy"},
  {name="erase", sm=true},
  {name="factory"},
  {name="filter", sm=true},
  {name="filter-edit"},
  {name="graduation"},
  {name="hangar"},
  {name="help"},
  {name="info"},
  {name="jewel"},
  {name="link", sm=true},
  {name="maximize-window"},
  {name="menu"},
  {name="minimize-window"},
  {name="nuclear"},
  {name="ok"},
  {name="paste"},
  {name="pause"},
  {name="pin"},
  {name="play", sm=true},
  {name="property"},
  {name="record", sm=true},
  {name="refresh"},
  {name="robot"},
  {name="search"},
  {name="services", sm=true},
  {name="settings"},
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
end

local list = {
  {name="tooltip-add", size=24, scale=1},
  {name="tooltip-edit", size=48, scale=1},
  {name="tooltip-blank", size=24, scale=1},
  {name="tooltip-info", size=32, scale=1}
}
for icon_row,icon in pairs(list) do
  table.insert(spite_icons, sprite_tooltip(icon.name, icon.size, icon.scale))
end
data:extend(spite_icons)