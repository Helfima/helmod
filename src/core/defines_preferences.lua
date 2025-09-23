defines.constant = defines.constant or {}

defines.constant.preferences = {
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
    allowed_values = {"0","0.0","0.00","0.000","0.0000"},
    group = "general"
  },
  -- format number element
  format_number_element = {
    type = "string-setting",
    localised_name = {"helmod_pref_settings.format-number-element"},
    localised_description = {"helmod_pref_settings.format-number-element-desc"},
    default_value = "0.0",
    allowed_values = {"0","0.0","0.00","0.000","0.0000"},
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
  --display-spoilage
  display_fuel_compact = {
    type = "bool-setting",
    localised_name = {"helmod_pref_settings.display-fuel-compact"},
    localised_description = {"helmod_pref_settings.display-fuel-compact-desc"},
    default_value = false,
    group = "general"
  },
  --display-spoilage
  display_spoilage = {
    type = "bool-setting",
    localised_name = {"helmod_pref_settings.display-spoilage"},
    localised_description = {"helmod_pref_settings.display-spoilage-desc"},
    default_value = true,
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
  --beacon-affecting-one
  beacon_affecting_one = {
    type = "float-setting",
    localised_name = {"helmod_pref_settings.beacon-affecting-one"},
    localised_description = {"helmod_pref_settings.beacon-affecting-one-desc"},
    default_value = defines.constant.beacon_combo,
    group = "general"
  },
  --beacon-affecting-one
  beacon_by_factory = {
    type = "float-setting",
    localised_name = {"helmod_pref_settings.beacon-by-factory"},
    localised_description = {"helmod_pref_settings.beacon-by-factory-desc"},
    default_value = defines.constant.beacon_factory,
    group = "general"
  },
  --beacon-constant
  beacon_constant = {
    type = "float-setting",
    localised_name = {"helmod_pref_settings.beacon-constant"},
    localised_description = {"helmod_pref_settings.beacon-constant-desc"},
    default_value = defines.constant.beacon_constant,
    group = "general"
  },
  --ui-production-lines-menu
  ui_production_lines_menu = {
    type = "string-setting",
    localised_name = {"helmod_pref_settings.ui-production-lines-menu"},
    localised_description = {"helmod_pref_settings.ui-production-lines-menu-desc"},
    default_value = 2,
    allowed_values = {0,1,2,3,4,5},
    group = "ui"
  },
  --ui-menu-lines
  ui_menu_lines = {
    type = "string-setting",
    localised_name = {"helmod_pref_settings.ui-menu-lines"},
    localised_description = {"helmod_pref_settings.ui-menu-lines"},
    default_value = "auto",
    allowed_values = {"auto","one line","two lines"},
    group = "ui"
  },
  --ui-summary-mode
  ui_summary_mode = {
    type = "string-setting",
    localised_name = {"helmod_pref_settings.ui-summary-mode"},
    localised_description = {"helmod_pref_settings.ui-summary-mode"},
    default_value = "global",
    allowed_values = {"global","local"},
    group = "ui"
  },
  --ui-close-after-selection
  close_after_selection = {
    type = "bool-setting",
    localised_name = {"helmod_pref_settings.ui-close-after-selection"},
    localised_description = {"helmod_pref_settings.ui-close-after-selection-desc"},
    default_value = false,
    group = "ui",
    items = {
      HMEntitySelector = true,
      HMRecipeSelector = true,
      HMTechnologySelector = true,
      HMItemSelector = true,
      HMFluidSelector = true
    }
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
  --one_block_factor_enable
  one_block_factor_enable = {
    type = "bool-setting",
    localised_name = "one_block_factor_enable",
    localised_description = "one_block_factor_enable",
    default_value = true,
    group = "debug"
  },
}

defines.constant.settings_mod = {
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
    allowed_values = {"None", "Index and Id", "Type and Name", "All"},
    order = "f2"
  }
}