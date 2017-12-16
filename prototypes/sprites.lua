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


data:extend(
{
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