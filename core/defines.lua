helmod_constant = {
  max_float = 1e300
}

helmod_base_times = {
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

helmod_logistic_flow_default = 3000

helmod_logistic_flow = {
  {pipe=1, flow=6000},
  {pipe=2, flow=3000},
  {pipe=3, flow=2250},
  {pipe=7, flow=1500},
  {pipe=12, flow=1285},
  {pipe=17, flow=1200},
  {pipe=20, flow=1169},
  {pipe=30, flow=1112},
  {pipe=50, flow=1067},
  {pipe=100, flow=1033},
  {pipe=150, flow=1022},
  {pipe=200, flow=1004},
  {pipe=261, flow=800},
  {pipe=300, flow=707},
  {pipe=400, flow=546},
  {pipe=500, flow=445},
  {pipe=600, flow=375},
  {pipe=800, flow=286},
  {pipe=1000, flow=230}
}

helmod_flow_style = {
  flow = "flow",
  horizontal = "helmod_flow_horizontal",
  vertical = "helmod_flow_vertical"
}

helmod_tag = {}
helmod_tag.color = {}
helmod_tag.color.close = "[/color]"
helmod_tag.color.white = "[color=255,255,255]"
helmod_tag.color.gray = "[color=229,229,229]"
helmod_tag.color.yellow = "[color=255,222,61]"
helmod_tag.color.red = "[color=255,0,0]"
helmod_tag.color.red_light = "[color=255,50,50]"
helmod_tag.color.green = "[color=0,127,14]"
helmod_tag.color.green_light = "[color=50,200,50]"
helmod_tag.color.blue = "[color=66,141,255]"
helmod_tag.color.blue_light = "[color=100,200,255]"
helmod_tag.color.gold = "[color=255,230,192]"
helmod_tag.color.orange = "[color=255,106,0]"
helmod_tag.color.black = "[color=0,0,0]"

helmod_tag.font = {}
helmod_tag.font.close = "[/font]"
helmod_tag.font.default_bold = "[font=default-bold]"
helmod_tag.font.default_semibold = "[font=default-semibold]"
helmod_tag.font.default_large_bold = "[font=default-large-bold]"

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
helmod_rules["production-crafting"].categories["crafting-handonly"] = {"entity-name", "entity-type", "entity-group", "entity-subgroup"}
helmod_rules["production-crafting"].categories["extraction-machine"] = {"entity-name", "entity-type", "entity-group", "entity-subgroup"}
helmod_rules["production-crafting"].categories["energy"] = {"entity-name", "entity-type", "entity-group", "entity-subgroup"}
helmod_rules["production-crafting"].categories["technology"] = {"entity-name", "entity-type", "entity-group", "entity-subgroup"}

helmod_rules["module-limitation"] = {excluded_only=true ,categories={}}
helmod_rules["module-limitation"].categories["standard"] = {"entity-name", "entity-type", "entity-group", "entity-subgroup"}
helmod_rules["module-limitation"].categories["extraction-machine"] = {"entity-name", "entity-type", "entity-group", "entity-subgroup"}
helmod_rules["module-limitation"].categories["technology"] = {"entity-name", "entity-type", "entity-group", "entity-subgroup"}

helmod_display_cell_mod = {"default", "small-text", "small-icon", "by-kilo"}

helmod_preferences = {
  -- factory level
  default_factory_level = {
    type = "string-setting",
    localised_name = {"helmod_pref_settings.default-factory-level"},
    localised_description = {"helmod_pref_settings.default-factory-level-desc"},
    default_value = "1",
    allowed_values = {"1","2","3","4","5","6","last"},
    group = "general"
  },
  -- format number factory
  format_number_factory = {
    type = "string-setting",
    localised_name = {"helmod_pref_settings.format-number-factory"},
    localised_description = {"helmod_pref_settings.format-number-factory-desc"},
    default_value = "0",
    allowed_values = {"0","0.0","0.00"},
    group = "general"
  },
  -- format number element
  format_number_element = {
    type = "string-setting",
    localised_name = {"helmod_pref_settings.format-number-element"},
    localised_description = {"helmod_pref_settings.format-number-element-desc"},
    default_value = "0.0",
    allowed_values = {"0","0.0","0.00"},
    group = "general"
  },
  -- preference number line by scroll
  preference_number_line = {
    type = "int-setting",
    localised_name = {"helmod_pref_settings.preference-number-line"},
    localised_description = {"helmod_pref_settings.preference-number-line-desc"},
    default_value = 3,
    allowed_values = {2,3,4,5},
    group = "general"
  },
  -- preference number column by scroll
  preference_number_column = {
    type = "int-setting",
    localised_name = {"helmod_pref_settings.preference-number-column"},
    localised_description = {"helmod_pref_settings.preference-number-column-desc"},
    default_value = 6,
    allowed_values = {6,7,8,9,10,11,12},
    group = "general"
  },
  -- display product order
  display_product_order = {
    type = "string-setting",
    localised_name = {"helmod_pref_settings.display-product-order"},
    localised_description = {"helmod_pref_settings.display-product-order-desc"},
    default_value = "natural",
    allowed_values = {"natural","name","cost"},
    group = "general"
  },
  --display product cols
  display_product_cols = {
    type = "int-setting",
    localised_name = {"helmod_pref_settings.display-product-cols"},
    localised_description = {"helmod_pref_settings.display-product-cols-desc"},
    default_value = 5,
    allowed_values = {5,6,7,8,9,10},
    group = "general"
  },
  --display-ingredient-cols
  display_ingredient_cols = {
    type = "int-setting",
    localised_name = {"helmod_pref_settings.display-ingredient-cols"},
    localised_description = {"helmod_pref_settings.display-ingredient-cols-desc"},
    default_value = 5,
    allowed_values = {5,6,7,8,9,10},
    group = "general"
  },
  --display-pollution
  display_pollution = {
    type = "bool-setting",
    localised_name = {"helmod_pref_settings.display-pollution"},
    localised_description = {"helmod_pref_settings.display-pollution-desc"},
    default_value = true,
    group = "general"
  },
  --display-building
  display_building = {
    type = "bool-setting",
    localised_name = {"helmod_pref_settings.display-building"},
    localised_description = {"helmod_pref_settings.display-building-desc"},
    default_value = true,
    group = "general"
  },
  --display-tips
  display_tips = {
    type = "bool-setting",
    localised_name = {"helmod_pref_settings.display-tips"},
    localised_description = {"helmod_pref_settings.display-tips-desc"},
    default_value = true,
    group = "general"
  },
  --ui-auto-close
  ui_auto_close = {
    type = "bool-setting",
    localised_name = {"helmod_pref_settings.ui-auto-close"},
    localised_description = {"helmod_pref_settings.ui-auto-close-desc"},
    default_value = false,
    group = "ui",
    items = {
      HMRecipeEdition = true,
      HMProductEdition = false,
      HMRuleEdition = false,
      HMPreferenceEdition = false,
  
      HMEnergySelector = true,
      HMEntitySelector = true,
      HMRecipeSelector = true,
      HMTechnologySelector = true,
      HMItemSelector = true,
      HMFluidSelector = true
    }
  },
  --ui-glue
  ui_glue = {
    type = "bool-setting",
    localised_name = {"helmod_pref_settings.ui-glue"},
    localised_description = {"helmod_pref_settings.ui-glue-desc"},
    default_value = false,
    group = "ui",
    items = {
      HMRecipeEdition = true,
      HMProductEdition = false,
      HMRuleEdition = false,
      HMPreferenceEdition = false,
  
      HMEnergySelector = true,
      HMEntitySelector = true,
      HMRecipeSelector = true,
      HMTechnologySelector = true,
      HMItemSelector = true,
      HMFluidSelector = true
    }
  },
  ui_glue_offset = {
    type = "int-setting",
    localised_name = {"helmod_pref_settings.ui-glue-offset"},
    localised_description = {"helmod_pref_settings.ui-glue-offset-desc"},
    default_value = 0,
    minimum_value = -1,
    maximum_value = 1,
    group = "ui"
  },
}

helmod_settings_mod = {
  -- display_ratio_horizontal
  display_ratio_horizontal = {
    type = "double-setting",
    setting_type = "runtime-per-user",
    localised_name = {"helmod_user_settings.display-ratio-horizontal"},
    localised_description = {"helmod_user_settings.display-ratio-horizontal-desc"},
    default_value = 0.85,
    minimum_value = 0.1,
    maximum_value = 2,
    allow_blank = false,
    order = "b0"
  },
  -- display_ratio_vertical
  display_ratio_vertical = {
    type = "double-setting",
    setting_type = "runtime-per-user",
    localised_name = {"helmod_user_settings.display-ratio-vertical"},
    localised_description = {"helmod_user_settings.display-ratio-vertical-desc"},
    default_value = 0.8,
    minimum_value = 0.1,
    maximum_value = 2,
    allow_blank = false,
    order = "b1"
  },
  -- display main icon
  display_main_icon = {
    type = "bool-setting",
    setting_type = "runtime-per-user",
    localised_name = {"helmod_user_settings.display-main-icon"},
    localised_description = {"helmod_user_settings.display-main-icon-desc"},
    default_value = true,
    order = "b2"
  },
  --display-cell-mod
  display_cell_mod = {
    type = "string-setting",
    setting_type = "runtime-per-user",
    localised_name = {"helmod_user_settings.display-cell-mod"},
    localised_description = {"helmod_user_settings.display-cell-mod-desc"},
    default_value = "default",
    allowed_values = {"default","small-text","small-icon","by-kilo"},
    order = "b4"
  },
  --row_move_step
  row_move_step = {
    type = "int-setting",
    setting_type = "runtime-per-user",
    localised_name = {"helmod_user_settings.row-move-step"},
    localised_description = {"helmod_user_settings.row-move-step-desc"},
    default_value = 5,
    minimum_value = 2,
    maximum_value = 10,
    order = "c0"
  },
  -- debug_solver
  debug_solver = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_map_settings.debug-solver"},
    localised_description = {"helmod_map_settings.debug-solver-desc"},
    default_value = false,
    order = "a2"
  },
  -- display_ratio_horizontal
  user_cache_step = {
    type = "int-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_map_settings.user-cache-step"},
    localised_description = {"helmod_map_settings.user-cache-step-desc"},
    default_value = 100,
    allowed_values = {50,100,200,300,400,500},
    order = "a3"
  },
  --display_all_sheet
  display_all_sheet = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_map_settings.display-all-sheet"},
    localised_description = {"helmod_map_settings.display-all-sheet-desc"},
    default_value = false,
    order = "c0"
  },

  filter_translated_string_active = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_map_settings.filter-translated-string-active"},
    localised_description = {"helmod_map_settings.filter-translated-string-active-desc"},
    default_value = true,
    order = "d0"
  },
  filter_on_text_changed = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_map_settings.filter-on-text-changed"},
    localised_description = {"helmod_map_settings.filter-on-text-changed-desc"},
    default_value = false,
    order = "d1"
  },
  --model-filter-factory
  model_filter_factory = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_map_settings.model-filter-factory"},
    localised_description = {"helmod_map_settings.model-filter-factory-desc"},
    default_value = true,
    order = "d2"
  },
  --model-filter-beacon
  model_filter_beacon = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_map_settings.model-filter-beacon"},
    localised_description = {"helmod_map_settings.model-filter-beacon-desc"},
    default_value = true,
    order = "d3"
  },
  --model-filter-factory-module
  model_filter_factory_module = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_map_settings.model-filter-factory-module"},
    localised_description = {"helmod_map_settings.model-filter-factory-module-desc"},
    default_value = true,
    order = "d5"
  },
  --model-filter-beacon-module
  model_filter_beacon_module = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_map_settings.model-filter-beacon-module"},
    localised_description = {"helmod_map_settings.model-filter-beacon-module-desc"},
    default_value = true,
    order = "d6"
  },
  --properties-panel
  hidden_panels = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_map_settings.hidden_panels"},
    localised_description = {"helmod_map_settings.hidden_panels-desc"},
    default_value = false,
    order = "e1"
  },
  --data-col-index
  display_hidden_column = {
    type = "string-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_map_settings.display-hidden-column"},
    localised_description = {"helmod_map_settings.display-hidden-column-desc"},
    default_value = "None",
    allowed_values = {"None","Type and Name","All"},
    order = "f2"
  }
}
