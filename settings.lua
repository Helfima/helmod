require("core.defines")

for settings_name,settings in pairs(helmod_settings_mod) do
  local name = "helmod_"..settings_name
  local current_settings = {
    type = settings.type,
    name = name,
    setting_type = settings.setting_type,
    localised_name = settings.localised_name,
    localised_description = settings.localised_description,
    default_value = settings.default_value,
    minimum_value = settings.minimum_value,
    maximum_value = settings.maximum_value,
    allowed_values = settings.allowed_values,
    allow_blank = settings.allow_blank,
    order = settings.order
  }
  data:extend{current_settings}
end
