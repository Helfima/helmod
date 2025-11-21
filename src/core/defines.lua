require "core.defines_builded"
require "core.defines_builded2"
require "core.defines_colors"

defines.mod = defines.mod or {}
defines.mod.events = defines.mod.events or {}
defines.mod.events.on_gui_action = "on_gui_action"
defines.mod.events.on_gui_queue = "on_gui_queue"
defines.mod.events.on_gui_event = "on_gui_event"
defines.mod.events.on_gui_open = "on_gui_open"
defines.mod.events.on_gui_update = "on_gui_update"
defines.mod.events.on_gui_close = "on_gui_close"
defines.mod.events.on_gui_error = "on_gui_error"
defines.mod.events.on_gui_message = "on_gui_message"
defines.mod.events.on_gui_mod_menu = "on_gui_mod_menu"
defines.mod.events.on_gui_reset = "on_gui_reset"
defines.mod.events.on_before_delete_cache = "on_before_delete_cache"
defines.mod.events.on_console_command = "on_console_command"

defines.mod.events.pattern = "([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)"

defines.mod.events.clickable_type = {}
defines.mod.events.clickable_type["button"] = true
defines.mod.events.clickable_type["sprite-button"] = true
defines.mod.events.clickable_type["choose-elem-button"] = false

defines.mod.tags = {}
defines.mod.tags.color = {}
defines.mod.tags.color.close = "[/color]"
defines.mod.tags.color.white = "[color=255,255,255]"
defines.mod.tags.color.gray = "[color=229,229,229]"
defines.mod.tags.color.yellow = "[color=255,222,61]"
defines.mod.tags.color.red = "[color=255,0,0]"
defines.mod.tags.color.red_light = "[color=255,50,50]"
defines.mod.tags.color.green = "[color=0,127,14]"
defines.mod.tags.color.green_light = "[color=50,200,50]"
defines.mod.tags.color.blue = "[color=66,141,255]"
defines.mod.tags.color.blue_light = "[color=100,200,255]"
defines.mod.tags.color.gold = "[color=255,230,192]"
defines.mod.tags.color.orange = "[color=255,106,0]"
defines.mod.tags.color.black = "[color=0,0,0]"

defines.mod.tags.font = {}
defines.mod.tags.font.close = "[/font]"
defines.mod.tags.font.default_bold = "[font=default-bold]"
defines.mod.tags.font.default_semibold = "[font=default-semibold]"
defines.mod.tags.font.default_large_bold = "[font=default-large-bold]"

defines.mod.recipe_customized_prefix = "helmod_customized"
defines.mod.recipe_customized_category = "crafting"
defines.mod.recipes = {}
defines.mod.recipes.recipe = {name = "recipe", is_customizable = true}
defines.mod.recipes.burnt = {name = "recipe-burnt", category="helmod-burnt"}
defines.mod.recipes.energy = {name = "energy", category="helmod-energy"}
defines.mod.recipes.resource = {name = "resource", category="helmod-mining"}
defines.mod.recipes.fluid = {name = "fluid", category="helmod-pumping"}
defines.mod.recipes.boiler = {name = "boiler"}
defines.mod.recipes.technology = {name = "technology", category="helmod-research"}
defines.mod.recipes.rocket = {name = "rocket", category="helmod-rocket"}
defines.mod.recipes.agricultural = {name = "agricultural", category="helmod-farming"}
defines.mod.recipes.spoiling = {name = "spoiling"}
defines.mod.recipes.constant = {name = "constant", is_customizable = true}

defines.styles = {}
defines.styles.mod_gui_button = "frame_button"

defines.styles.frame = {}
defines.styles.frame.default = "frame"
defines.styles.frame.bordered = "bordered_frame"
defines.styles.frame.inside_deep = "inside_deep_frame"
defines.styles.frame.inner_outer = "inner_frame_in_outer_frame"
defines.styles.frame.invisible ="invisible_frame"
defines.styles.frame.action_button ="frame_action_button"
defines.styles.frame.inner_padding = "inside_shallow_frame_with_padding"
defines.styles.frame.inner = "inside_shallow_frame"
defines.styles.frame.inner_tab = "inside_deep_frame_for_tabs"
defines.styles.frame.subheader_frame ="subheader_frame"
defines.styles.frame.tabbed_pane = "tabbed_pane"
defines.styles.frame.tab_scroll_pane = "tab_scroll_pane"


defines.styles.label = {}
defines.styles.label.default = "label"
defines.styles.label.frame_title = "frame_title"
defines.styles.label.heading_1 = "heading_1_label"
defines.styles.label.heading_2 = "heading_2_label"

defines.styles.flow = {}
defines.styles.flow.default = "helmod_flow_default"
defines.styles.flow.horizontal = "helmod_flow_horizontal"
defines.styles.flow.vertical = "helmod_flow_vertical"

defines.styles.button = {}
defines.styles.button.link = "helmod_link"
defines.styles.button.menu_default = "helmod_button_menu_default"
defines.styles.button.menu_sm_default = "helmod_button_menu_sm_default"
defines.styles.button.menu_tool_default = "helmod_button_menu_tool_default"
defines.styles.button.menu = "helmod_button_menu"
defines.styles.button.menu_sm = "helmod_button_menu_sm"
defines.styles.button.menu_tool = "helmod_button_menu_tool"
defines.styles.button.menu_selected = "helmod_button_menu_selected"
defines.styles.button.menu_sm_selected = "helmod_button_menu_sm_selected"
defines.styles.button.menu_tool_selected = "helmod_button_menu_tool_selected"
defines.styles.button.menu_dark = "helmod_button_menu_dark"
defines.styles.button.menu_sm_dark = "helmod_button_menu_sm_dark"
defines.styles.button.menu_tool_dark = "helmod_button_menu_tool_dark"
defines.styles.button.menu_dark_selected = "helmod_button_menu_dark_selected"
defines.styles.button.menu_sm_dark_selected = "helmod_button_menu_sm_dark_selected"
defines.styles.button.menu_tool_dark_selected = "helmod_button_menu_tool_dark_selected"
defines.styles.button.menu_bold = "helmod_button_menu_bold"
defines.styles.button.menu_sm_bold = "helmod_button_menu_sm_bold"
defines.styles.button.menu_tool_bold = "helmod_button_menu_tool_bold"
defines.styles.button.menu_bold_selected = "helmod_button_menu_bold_selected"
defines.styles.button.menu_sm_bold_selected = "helmod_button_menu_sm_bold_selected"
defines.styles.button.menu_tool_bold_selected = "helmod_button_menu_tool_bold_selected"
defines.styles.button.menu_dark_bold = "helmod_button_menu_dark_bold"
defines.styles.button.menu_sm_dark_bold = "helmod_button_menu_sm_dark_bold"
defines.styles.button.menu_tool_dark_bold = "helmod_button_menu_tool_dark_bold"
defines.styles.button.menu_dark_bold_selected = "helmod_button_menu_dark_bold_selected"
defines.styles.button.menu_sm_dark_bold_selected = "helmod_button_menu_sm_dark_bold_selected"
defines.styles.button.menu_tool_dark_bold_selected = "helmod_button_menu_tool_dark_bold_selected"
defines.styles.button.menu_red = "helmod_button_menu_red"
defines.styles.button.menu_sm_red = "helmod_button_menu_sm_red"
defines.styles.button.menu_tool_red = "helmod_button_menu_tool_red"
defines.styles.button.menu_dark_red = "helmod_button_menu_dark_red"
defines.styles.button.menu_sm_dark_red = "helmod_button_menu_sm_dark_red"
defines.styles.button.menu_tool_dark_red = "helmod_button_menu_tool_dark_red"
defines.styles.button.menu_actived_red = "helmod_button_menu_actived_red"
defines.styles.button.menu_sm_actived_red = "helmod_button_menu_sm_actived_red"
defines.styles.button.menu_tool_actived_red = "helmod_button_menu_tool_actived_red"
defines.styles.button.menu_selected_red = "helmod_button_menu_selected_red"
defines.styles.button.menu_sm_selected_red = "helmod_button_menu_sm_selected_red"
defines.styles.button.menu_tool_selected_red = "helmod_button_menu_tool_selected_red"
defines.styles.button.menu_green = "helmod_button_menu_green"
defines.styles.button.menu_sm_green = "helmod_button_menu_sm_green"
defines.styles.button.menu_tool_green = "helmod_button_menu_tool_green"
defines.styles.button.menu_dark_green = "helmod_button_menu_dark_green"
defines.styles.button.menu_sm_dark_green = "helmod_button_menu_sm_dark_green"
defines.styles.button.menu_tool_dark_green = "helmod_button_menu_tool_dark_green"
defines.styles.button.menu_actived_green = "helmod_button_menu_actived_green"
defines.styles.button.menu_sm_actived_green = "helmod_button_menu_sm_actived_green"
defines.styles.button.menu_tool_actived_green = "helmod_button_menu_tool_actived_green"
defines.styles.button.menu_selected_green = "helmod_button_menu_selected_green"
defines.styles.button.menu_sm_selected_green = "helmod_button_menu_sm_selected_green"
defines.styles.button.menu_tool_selected_green = "helmod_button_menu_tool_selected_green"
defines.styles.button.menu_selected_yellow = "helmod_button_menu_selected_yellow"
defines.styles.button.menu_sm_selected_yellow = "helmod_button_menu_sm_selected_yellow"
defines.styles.button.menu_tool_selected_yellow = "helmod_button_menu_tool_selected_yellow"
defines.styles.button.menu_flat2 = "helmod_button_menu_flat2"
defines.styles.button.menu_flat = "helmod_button_menu_flat"
defines.styles.button.menu_sm_flat = "helmod_button_menu_sm_flat"

defines.styles.button.default = "helmod_button_default"
defines.styles.button.selected = "helmod_button_selected"
defines.styles.button.icon_default = "helmod_button_icon_default"

defines.styles.button.icon = "helmod_button_icon"
defines.styles.button.icon_xxl = "helmod_button_icon_xxl"
defines.styles.button.icon_m = "helmod_button_icon_m"
defines.styles.button.icon_sm = "helmod_button_icon_sm"

defines.styles.button.slot = "helmod_button_slot"
defines.styles.button.slot_m = "helmod_button_slot_m"
defines.styles.button.slot_sm = "helmod_button_slot_sm"

defines.styles.button.select_icon = "helmod_button_select_icon"
defines.styles.button.select_icon_green = "helmod_button_select_icon_green"
defines.styles.button.select_icon_yellow = "helmod_button_select_icon_yellow"
defines.styles.button.select_icon_red = "helmod_button_select_icon_red"
defines.styles.button.select_icon_flat = "helmod_button_select_icon_flat"

defines.styles.button.select_icon_xxl = "helmod_button_select_icon_xxl"
defines.styles.button.select_icon_xxl_green = "helmod_button_select_icon_xxl_green"
defines.styles.button.select_icon_xxl_yellow = "helmod_button_select_icon_xxl_yellow"
defines.styles.button.select_icon_xxl_red = "helmod_button_select_icon_xxl_red"
defines.styles.button.select_icon_xxl_flat = "helmod_button_select_icon_xxl_flat"

defines.styles.button.select_icon_m = "helmod_button_select_icon_m"
defines.styles.button.select_icon_m_green = "helmod_button_select_icon_m_green"
defines.styles.button.select_icon_m_yellow = "helmod_button_select_icon_m_yellow"
defines.styles.button.select_icon_m_red = "helmod_button_select_icon_m_red"
defines.styles.button.select_icon_m_flat = "helmod_button_select_icon_m_flat"

defines.styles.button.select_icon_sm = "helmod_button_select_icon_sm"
defines.styles.button.select_icon_sm_green = "helmod_button_select_icon_sm_green"
defines.styles.button.select_icon_sm_yellow = "helmod_button_select_icon_sm_yellow"
defines.styles.button.select_icon_sm_red = "helmod_button_select_icon_sm_red"
defines.styles.button.select_icon_sm_flat = "helmod_button_select_icon_sm_flat"

defines.sprite_size=14

defines.sprite_tooltips = {}
defines.sprite_tooltips["energy"] = defines.sprites.event.white
defines.sprite_tooltips["steam-heat"] = defines.sprites.steam_heat.white

defines.sprite_info = {}
--- sprite info
defines.sprite_info["developer"] = defines.sprites.info_settings.blue
defines.sprite_info["education"] = defines.sprites.info_education.blue
defines.sprite_info["burnt"] = defines.sprites.info_fire.blue
defines.sprite_info["block"] = defines.sprites.info_hangar.white
defines.sprite_info["energy"] = defines.sprites.info_energy.blue
defines.sprite_info["rocket"] = defines.sprites.rocket.blue
defines.sprite_info["mining"] = defines.sprites.mining.blue
defines.sprite_info["customized"] = defines.sprites.info_create.blue
--- sprite contraint
defines.sprite_info["linked"] = defines.sprites.info_arrow_top.red
defines.sprite_info["master"] = defines.sprites.info_add.red
defines.sprite_info["exclude"] = defines.sprites.info_remove.red

defines.sprite_tooltip = {}
defines.sprite_tooltip["info"] = defines.sprites.tooltip_information.white
defines.sprite_tooltip["edit"] = defines.sprites.tooltip_edit.yellow
defines.sprite_tooltip["add"] = defines.sprites.tooltip_add.yellow
defines.sprite_tooltip["remove"] = defines.sprites.tooltip_remove.yellow
defines.sprite_tooltip["erase"] = defines.sprites.tooltip_erase.yellow
defines.sprite_tooltip["favorite"] = defines.sprites.tooltip_favorite.yellow
defines.sprite_tooltip["expand_right"] = defines.sprites.tooltip_expand_right.yellow
defines.sprite_tooltip["expand_right_group"] = defines.sprites.tooltip_expand_right_group.yellow
defines.sprite_tooltip["pipette"] = defines.sprites.tooltip_pipette.yellow

defines.sorters = {}
defines.sorters.block = {}
defines.sorters.block.sort = function(t, a, b) return t[b]["index"] > t[a]["index"] end
defines.sorters.block.reverse = function(t, a, b) return t[b]["index"] < t[a]["index"] end

defines.thumbnail_color = {}
defines.thumbnail_color.names = {}
defines.thumbnail_color.names.default = "default"
defines.thumbnail_color.names.block_default = "block_default"
defines.thumbnail_color.names.block_selected = "block_selected"
defines.thumbnail_color.names.block_reverted = "block_reverted"
defines.thumbnail_color.names.recipe_default = "recipe_default"
defines.thumbnail_color.names.product_default = "product_default"
defines.thumbnail_color.names.product_driving = "product_driving"
defines.thumbnail_color.names.product_overflow = "product_overflow"
defines.thumbnail_color.names.ingredient_default = "ingredient_default"
defines.thumbnail_color.names.ingredient_driving = "ingredient_driving"
defines.thumbnail_color.names.ingredient_overflow = "ingredient_overflow"

defines.thumbnail_color.values = {}
defines.thumbnail_color.values.default = "gray"
defines.thumbnail_color.values.block_default = "T200_9"
defines.thumbnail_color.values.block_selected = "T35_4"
defines.thumbnail_color.values.block_reverted = "T30_6"
defines.thumbnail_color.values.recipe_default = "G40_3"
defines.thumbnail_color.values.product_default = "T200_4"
defines.thumbnail_color.values.product_driving = "T125_5"
defines.thumbnail_color.values.product_overflow = "T10_4"
defines.thumbnail_color.values.ingredient_default = "T40_4"
defines.thumbnail_color.values.ingredient_driving = "T125_5"
defines.thumbnail_color.values.ingredient_overflow = "T10_4"

defines.constant = defines.constant or {}
defines.constant.solvers = {}
defines.constant.solvers.default = "linked matrix"
defines.constant.solvers.matrix = "matrix"

defines.constant.rocket_deploy_delay = 2434 / 60
defines.constant.max_float = 1e300
defines.constant.base_times = {
  { value = 1, caption = "1s", tooltip={"helmod_si.seconde",1}},
  { value = 60, caption = "1", tooltip={"helmod_si.minute",1}},
  { value = 300, caption = "5", tooltip={"helmod_si.minute",5}},
  { value = 600, caption = "10", tooltip={"helmod_si.minute",10}},
  { value = 1800, caption = "30", tooltip={"helmod_si.minute",30}},
  { value = 3600, caption = "1h", tooltip={"helmod_si.hour",1}},
  { value = 3600*6, caption = "6h", tooltip={"helmod_si.hour",6}},
  { value = 3600*12, caption = "12h", tooltip={"helmod_si.hour",12}},
  { value = 3600*24, caption = "24h", tooltip={"helmod_si.hour",24}}
}

defines.constant.logistic_list_for_item = { "inserter", "belt", "container", "transport" }
defines.constant.logistic_list_for_fluid = { "pipe", "container", "transport" }

defines.constant.beacon_combo = 1
defines.constant.beacon_factory = 1/8
defines.constant.beacon_constant = 0

require "core.defines_preferences"

helmod_flow_style = {
  flow = "flow",
  horizontal = "helmod_flow_horizontal",
  vertical = "helmod_flow_vertical"
}

helmod_frame_style = {
  default = "helmod_frame_default",
  hidden = "helmod_frame_hidden",
  panel = "helmod_frame_panel",
  cell = "helmod_frame_hidden",
  tab = "helmod_frame_tab",
  section = "helmod_frame_section"
}

helmod_rules = {}
helmod_rules["production-crafting"] = {excluded_only=false ,categories={}}
helmod_rules["production-crafting"].categories["standard"] = {"entity-name", "entity-type", "entity-group", "entity-subgroup"}
helmod_rules["production-crafting"].categories["extraction-machine"] = {"entity-name", "entity-type", "entity-group", "entity-subgroup"}
helmod_rules["production-crafting"].categories["energy"] = {"entity-name", "entity-type", "entity-group", "entity-subgroup"}
helmod_rules["production-crafting"].categories["technology"] = {"entity-name", "entity-type", "entity-group", "entity-subgroup"}
helmod_rules["production-crafting"].categories["exclude-placed-by-hidden"] = {"entity-name", "entity-type", "entity-group", "entity-subgroup"}

helmod_rules["module-limitation"] = {excluded_only=true ,categories={}}
helmod_rules["module-limitation"].categories["standard"] = {"entity-name", "entity-type", "entity-group", "entity-subgroup"}
helmod_rules["module-limitation"].categories["extraction-machine"] = {"entity-name", "entity-type", "entity-group", "entity-subgroup"}
helmod_rules["module-limitation"].categories["technology"] = {"entity-name", "entity-type", "entity-group", "entity-subgroup"}