helmod_base_times = {
  { value = 1, caption = "1s", tooltip="1s"},
  { value = 60, caption = "1", tooltip="1mn"},
  { value = 300, caption = "5", tooltip="5mn"},
  { value = 600, caption = "10", tooltip="10mn"},
  { value = 1800, caption = "30", tooltip="30mn"},
  { value = 3600, caption = "1h", tooltip="1h"},
  { value = 3600*6, caption = "6h", tooltip="6h"},
  { value = 3600*12, caption = "12h", tooltip="12h"},
  { value = 3600*24, caption = "24h", tooltip="24h"}
}

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
  section = "helmod_frame_section",
  scroll_pane = "scroll_pane",
  scroll_recipe_selector = "helmod_scroll_recipe_selector",
  recipe_column = "helmod_frame_recipe_info"
}

helmod_scroll_style = {
  default = "scroll_pane",
  recipe_selector = "helmod_scroll_recipe_selector",
  recipe_list = "helmod_scroll_recipe_module_list",
  pin_tab = "helmod_scroll_block_pin_tab"
}

helmod_table_style = {
  default = "helmod_table_default",
  panel = "helmod_table_panel",
  list = "helmod_table_list",
  tab = "helmod_table_tab",
  rule = "helmod_table_rule"
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

helmod_settings_mod = {
  debug = {
    type = "string-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.debug"},
    localised_description = {"helmod_settings.debug-desc"},
    default_value = "none",
    allowed_values = {"none","error","warn","info","debug","trace"},
    order = "a0"
  },
  debug_filter = {
    type = "string-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.debug-filter"},
    localised_description = {"helmod_settings.debug-filter-desc"},
    default_value = "all",
    allowed_values = {"all",
      "HMAbstractEdition",
      "HMAbstractSelector",
      "HMAbstractTab",
      "HMCache",
      "HMCalculator",
      "HMContainerSelector",
      "HMController",
      "HMDispatcherController",
      "HMDownload",
      "HMElementGui",
      "HMEnergyEdition",
      "HMEnergyTab",
      "HMEvent",
      "HMEventController",
      "HMHelpPanel",
      "HMMainMenuPanel",
      "HMModel",
      "HMModelCompute",
      "HMModelBuilder",
      "HMLeftMenuPanel",
      "HMPinPanel",
      "HMPlayer",
      "HMProduct",
      "HMProductEdition",
      "HMProductionBlockTab",
      "HMProductionLineTab",
      "HMProductEdition",
      "HMPropertiesTab",
      "HMPrototype",
      "HMPrototypeFiltersTab",
      "HMRecipeEdition",
      "HMRecipeSelector",
      "HMRecipePrototype",
      "HMRemote",
      "HMResourceEdition",
      "HMResourceTab",
      "HMRuleEdition",
      "HMSatisticTab",
      "HMSummaryTab",
      "HMTechnology",
      "HMTechnologySelector",
      "HMUser"
    },
    order = "a1"
  },
  -- format number factory
  format_number_factory = {
    type = "string-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.format-number-factory"},
    localised_description = {"helmod_settings.format-number-factory-desc"},
    default_value = "0",
    allowed_values = {"0","0.0","0.00"},
    order = "a2"
  },
  -- format number element
  format_number_element = {
    type = "string-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.format-number-element"},
    localised_description = {"helmod_settings.format-number-element-desc"},
    default_value = "0.0",
    allowed_values = {"0","0.0","0.00"},
    order = "a2"
  },
  -- display_ratio_horizontal
  display_ratio_horizontal = {
    type = "double-setting",
    setting_type = "runtime-per-user",
    localised_name = {"helmod_settings.display-ratio-horizontal"},
    localised_description = {"helmod_settings.display-ratio-horizontal-desc"},
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
    localised_name = {"helmod_settings.display-ratio-vertical"},
    localised_description = {"helmod_settings.display-ratio-vertical-desc"},
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
    localised_name = {"helmod_settings.display-main-icon"},
    localised_description = {"helmod_settings.display-main-icon-desc"},
    default_value = true,
    order = "b2"
  },
  -- display location
  display_location = {
    type = "string-setting",
    setting_type = "runtime-per-user",
    localised_name = {"helmod_settings.display-location"},
    localised_description = {"helmod_settings.display-location-desc"},
    default_value = "center",
    allowed_values = {"center", "left", "top"},
    order = "b3"
  },
  --display-cell-mod
  display_cell_mod = {
    type = "string-setting",
    setting_type = "runtime-per-user",
    localised_name = {"helmod_settings.display-cell-mod"},
    localised_description = {"helmod_settings.display-cell-mod-desc"},
    default_value = "default",
    allowed_values = {"default","small-text","small-icon","by-kilo"},
    order = "b4"
  },
  --display product cols
  display_product_cols = {
    type = "int-setting",
    setting_type = "runtime-per-user",
    localised_name = {"helmod_settings.display-product-cols"},
    localised_description = {"helmod_settings.display-product-cols-desc"},
    default_value = 5,
    minimum_value = 2,
    maximum_value = 10,
    order = "b5"
  },
  --display-ingredient-cols
  display_ingredient_cols = {
    type = "int-setting",
    setting_type = "runtime-per-user",
    localised_name = {"helmod_settings.display-ingredient-cols"},
    localised_description = {"helmod_settings.display-ingredient-cols-desc"},
    default_value = 5,
    minimum_value = 2,
    maximum_value = 10,
    order = "b6"
  },
  --row_move_step
  row_move_step = {
    type = "int-setting",
    setting_type = "runtime-per-user",
    localised_name = {"helmod_settings.row-move-step"},
    localised_description = {"helmod_settings.row-move-step-desc"},
    default_value = 5,
    minimum_value = 2,
    maximum_value = 10,
    order = "c0"
  },
  -- format number element
  default_factory_level = {
    type = "string-setting",
    setting_type = "runtime-per-user",
    localised_name = {"helmod_settings.default-factory-level"},
    localised_description = {"helmod_settings.default-factory-level-desc"},
    default_value = "last",
    allowed_values = {"1","2","3","4","5","6","last"},
    order = "a2"
  },
  --display_all_sheet
  display_all_sheet = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.display-all-sheet"},
    localised_description = {"helmod_settings.display-all-sheet-desc"},
    default_value = false,
    order = "c0"
  },
  --display-real-name
  display_real_name = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.display-real-name"},
    localised_description = {"helmod_settings.display-real-name-desc"},
    default_value = false,
    order = "c1"
  },
  --data-col-index
  display_data_col_index = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.display-data-col-index"},
    localised_description = {"helmod_settings.display-data-col-index-desc"},
    default_value = false,
    order = "c2"
  },
  --data-col-id
  display_data_col_id = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.display-data-col-id"},
    localised_description = {"helmod_settings.display-data-col-id-desc"},
    default_value = false,
    order = "c3"
  },
  --data-col-name
  display_data_col_name = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.display-data-col-name"},
    localised_description = {"helmod_settings.display-data-col-name-desc"},
    default_value = false,
    order = "c4"
  },
  --data-col-name
  display_data_col_type = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.display-data-col-type"},
    localised_description = {"helmod_settings.display-data-col-type-desc"},
    default_value = false,
    order = "c5"
  },
  filter_on_text_changed = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.filter-on-text-changed"},
    localised_description = {"helmod_settings.filter-on-text-changed-desc"},
    default_value = false,
    order = "d0"
  },
  --model-filter-factory
  model_filter_factory = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.model-filter-factory"},
    localised_description = {"helmod_settings.model-filter-factory-desc"},
    default_value = true,
    order = "d1"
  },
  --model-filter-beacon
  model_filter_beacon = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.model-filter-beacon"},
    localised_description = {"helmod_settings.model-filter-beacon-desc"},
    default_value = true,
    order = "d2"
  },
  --model-filter-generator
  model_filter_generator = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.model-filter-generator"},
    localised_description = {"helmod_settings.model-filter-generator-desc"},
    default_value = true,
    order = "d3"
  },
  --model-filter-factory-module
  model_filter_factory_module = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.model-filter-factory-module"},
    localised_description = {"helmod_settings.model-filter-factory-module-desc"},
    default_value = true,
    order = "d4"
  },
  --model-filter-beacon-module
  model_filter_beacon_module = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.model-filter-beacon-module"},
    localised_description = {"helmod_settings.model-filter-beacon-module-desc"},
    default_value = true,
    order = "d5"
  },
  --properties-tab
  properties_tab = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.properties-tab"},
    localised_description = {"helmod_settings.properties-tab-desc"},
    default_value = false,
    order = "e1"
  },
  --prototype-filters-tab
  prototype_filters_tab = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.prototype-filters-tab"},
    localised_description = {"helmod_settings.prototype-filters-tab-desc"},
    default_value = false,
    order = "e2"
  }
}
