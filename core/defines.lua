helmod_defines = {}

helmod_icons = {}
helmod_icons["unknown-assembling-machine"]="__helmod__/graphics/icons/unknown-assembling-machine.png"
helmod_icons["default-assembling-machine"]="__helmod__/graphics/icons/unknown-assembling-machine.png"

helmod_display_sizes = {"1920x1200","1920x1080","1680x1050","1680x900","1440x900","1360x768"}

helmod_display_cell_mod = {"default", "small-text", "small-icon", "by-kilo"}

helmod_settings_mod = {
  debug = {
    type = "string-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.debug"},
    localised_description = {"helmod_settings.debug-desc"},
    default_value = "none",
    allowed_values = {"none","info","error","debug","trace"},
    order = "a0"
  },
  debug_filter = {
    type = "string-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.debug-filter"},
    localised_description = {"helmod_settings.debug-filter-desc"},
    default_value = "all",
    allowed_values = {"all",
      "helmod",
      "HMAbstractEdition",
      "HMAbstractSelector",
      "HMAbstractTab",
      "HMController",
      "HMDialog",
      "HMElementGui",
      "HMEnergyEdition",
      "HMEnergyTab",
      "HMMainTab",
      "HMModel",
      "HMPinPanel",
      "HMPlayerController",
      "HMProductEdition",
      "HMProductionBlockTab",
      "HMProductionLineTab",
      "HMProductEdition",
      "HMPropertiesTab",
      "HMRecipeEdition",
      "HMRecipeSelector",
      "HMResourceEdition",
      "HMResourceTab",
      "HMSummaryTab",
      "HMTechnologySelector"
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
  -- display size
  display_size = {
    type = "string-setting",
    setting_type = "runtime-per-user",
    localised_name = {"helmod_settings.display-size"},
    localised_description = {"helmod_settings.display-size-desc"},
    default_value = "1680x1050",
    allowed_values = {"1920x1200","1920x1080","1680x1050","1680x900","1440x900","1360x768"},
    order = "b0"
  },
  -- display size
  display_size_free = {
    type = "string-setting",
    setting_type = "runtime-per-user",
    localised_name = {"helmod_settings.display-size-free"},
    localised_description = {"helmod_settings.display-size-free-desc"},
    default_value = "",
    allow_blank = true,
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
    allowed_values = {"1","2","3","4","last"},
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
  --model-filter-factory-module
  model_filter_factory_module = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.model-filter-factory-module"},
    localised_description = {"helmod_settings.model-filter-factory-module-desc"},
    default_value = true,
    order = "d3"
  },
  --model-filter-beacon-module
  model_filter_beacon_module = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.model-filter-beacon-module"},
    localised_description = {"helmod_settings.model-filter-beacon-module-desc"},
    default_value = true,
    order = "d4"
  },
  --model-filter-generator
  model_filter_generator = {
    type = "bool-setting",
    setting_type = "runtime-global",
    localised_name = {"helmod_settings.model-filter-generator"},
    localised_description = {"helmod_settings.model-filter-generator-desc"},
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
  }
}
