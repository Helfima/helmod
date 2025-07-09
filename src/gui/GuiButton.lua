-------------------------------------------------------------------------------
---Class to help to build GuiButton
---@class GuiButton : GuiElement
GuiButton = newclass(GuiElement, function(base, ...)
    GuiElement.init(base, ...)
    base.classname = "HMGuiButton"
    base.options.type = "button"
    base.options.style = "helmod_button_default"
end)

-------------------------------------------------------------------------------
---Set Sprite
---@param element_type string
---@param element_name string
---@param hovered string
---@return GuiButton
function GuiButton:sprite(element_type, element_name, hovered)
    self.options.type = "sprite-button"
    self.options.tags = { type = element_type, name = element_name}
    self.is_caption = false
    if element_type == "menu" then
        self.options.sprite = GuiElement.getSprite(element_name)
        if hovered then
            self.options.hovered_sprite = GuiElement.getSprite(hovered)
        end
    elseif element_type == "energy" and defines.sprite_tooltips[element_name] ~= nil then
        self.options.sprite = GuiElement.getSprite(defines.sprite_tooltips[element_name])
        if hovered then
            self.options.hovered_sprite = GuiElement.getSprite(hovered)
        end
        table.insert(self.name, element_name)
    else
        self.options.sprite = GuiElement.getSprite(element_type, element_name)
        if hovered then
            self.options.hovered_sprite = GuiElement.getSprite(element_type, hovered)
        end
        table.insert(self.name, element_name)
    end
    return self
end

-------------------------------------------------------------------------------
---Set Sprite
---@param element_type string
---@param element_name string
---@param element_quality string
---@param hovered string
---@return GuiButton
function GuiButton:sprite_with_quality(element_type, element_name, element_quality, hovered)
    self.options.type = "sprite-button"
    self.options.tags = { type = element_type, name = element_name, quality = element_quality }
    self.is_caption = false
    if element_type == "energy" and defines.sprite_tooltips[element_name] ~= nil then
        self.options.sprite = GuiElement.getSprite(defines.sprite_tooltips[element_name])
        if hovered then
            self.options.hovered_sprite = GuiElement.getSprite(hovered)
        end
    else
        self.options.sprite = GuiElement.getSprite(element_type, element_name)
        if hovered then
            self.options.hovered_sprite = GuiElement.getSprite(element_type, hovered)
        end
    end
    table.insert(self.name, element_name)
    if element_quality ~= nil then
        self.post_action["mask_quality"] = {quality=element_quality, size=self.mask_quality_size}
    end
    return self
end

-------------------------------------------------------------------------------
---Set spoil_percent
---@param element ProductData
---@return GuiButton
function GuiButton:spoilage(element)
    if element ~= nil and User.getPreferenceSetting("display_spoilage") then
        self.post_action["mask_spoil"] = {spoil=element, size=0}
    end
    return self
end

-------------------------------------------------------------------------------
---Set option
---@param name string
---@param value any
---@return GuiButton
function GuiButton:option(name, value)
    self.options[name] = value
end

-------------------------------------------------------------------------------
---Set index
---@param index number
---@return GuiButton
function GuiButton:index(index)
    self.m_index = index
    table.insert(self.name, index)
    return self
end

-------------------------------------------------------------------------------
---Set index
---@param value number
---@return GuiButton
function GuiButton:number(value)
    self.options.number = value
    return self
end

-------------------------------------------------------------------------------
---Set Choose button style
---@param element_type string
---@param element_name string
---@return GuiButton
function GuiButton:choose(element_type, element_name, key)
    self.options.type = "choose-elem-button"
    self.options.tags = { type = element_type, name = element_name}
    self.options.elem_type = element_type
    self.options[element_type] = element_name
    table.insert(self.name, key or element_name)
    return self
end

-------------------------------------------------------------------------------
---Set Choose button style
---@param element_type string
---@param element_name string
---@param element_quality string
---@return GuiButton
function GuiButton:choose_with_quality(element_type, element_name, element_quality)
    self.options.type = "choose-elem-button"
    self.options.tags = { type = element_type, name = element_name, quality = element_quality }
    if element_type == "signal" then
        self.options.elem_type = element_type
        if element_name ~= nil then
            self.post_action["apply_elem_value"] = { type = element_name.type, name = element_name.name, quality = element_quality or "normal" }
            table.insert(self.name, element_name.type)
            table.insert(self.name, element_name.name)
        end
    else 
        self.options.elem_type = string.format("%s-with-quality", element_type)
        if element_name ~= nil then
            self.post_action["apply_elem_value"] = { name = element_name, quality = element_quality or "normal" }
            table.insert(self.name, element_name)
        end
    end
    return self
end

-------------------------------------------------------------------------------
---Get options
---@return table
function GuiButton:onErrorOptions()
    local options = self:getOptions()
    options.style = "helmod_button_default"
    options.type = "button"
    if (type(options.caption) == "boolean") then
        Logging:error(self.classname, "addGuiButton - caption is a boolean")
    elseif self.m_caption ~= nil then
        options.caption = self.m_caption
    else
        options.caption = options.key
    end
    return options
end

-------------------------------------------------------------------------------
---@class GuiButtonSprite
GuiButtonSprite = newclass(GuiButton, function(base, ...)
    GuiButton.init(base, ...)
    base.options.style = "helmod_button_icon"
    base.is_caption = false
end)

-------------------------------------------------------------------------------
---@class GuiButtonSelectSprite
GuiButtonSelectSprite = newclass(GuiButton, function(base, ...)
    GuiButton.init(base, ...)
    base.options.style = "helmod_button_select_icon"
    base.is_caption = false
end)

-------------------------------------------------------------------------------
---Set color
---@param color string
---@return GuiButtonSelectSprite
function GuiButtonSelectSprite:color(color)
    local style = "helmod_button_select_icon"
    if color == "red" then style = "helmod_button_select_icon_red" end
    if color == "yellow" then style = "helmod_button_select_icon_yellow" end
    if color == "green" then style = "helmod_button_select_icon_green" end
    if color == "flat" then style = "helmod_button_select_icon_flat" end
    self.options.style = style
    return self
end

-------------------------------------------------------------------------------
---@class GuiButtonSpriteM
GuiButtonSpriteM = newclass(GuiButton, function(base, ...)
    GuiButton.init(base, ...)
    base.options.style = "helmod_button_icon_m"
    base.is_caption = false
end)

-------------------------------------------------------------------------------
---@class GuiButtonSelectSpriteM
GuiButtonSelectSpriteM = newclass(GuiButton, function(base, ...)
    GuiButton.init(base, ...)
    base.options.style = "helmod_button_select_icon_m"
    base.is_caption = false
end)

-------------------------------------------------------------------------------
---Set color
---@param color string
---@return GuiButtonSelectSpriteM
function GuiButtonSelectSpriteM:color(color)
    local style = "helmod_button_select_icon_m"
    if color == "red" then style = "helmod_button_select_icon_m_red" end
    if color == "yellow" then style = "helmod_button_select_icon_m_yellow" end
    if color == "green" then style = "helmod_button_select_icon_m_green" end
    if color == "flat" then style = "helmod_button_select_icon_m_flat" end
    self.options.style = style
    return self
end

-------------------------------------------------------------------------------
---@class GuiButtonSpriteSm
GuiButtonSpriteSm = newclass(GuiButton, function(base, ...)
    GuiButton.init(base, ...)
    base.options.style = "helmod_button_icon_sm"
    base.is_caption = false
end)

-------------------------------------------------------------------------------
---@class GuiButtonSelectSpriteSm
GuiButtonSelectSpriteSm = newclass(GuiButton, function(base, ...)
    GuiButton.init(base, ...)
    base.options.style = "helmod_button_select_icon_sm"
    base.is_caption = false
    base.mask_quality_size = 8
end)

-------------------------------------------------------------------------------
---Set color
---@param color string
---@return GuiButtonSelectSpriteSm
function GuiButtonSelectSpriteSm:color(color)
    local style = "helmod_button_select_icon_sm"
    if color == "red" then style = "helmod_button_select_icon_sm_red" end
    if color == "yellow" then style = "helmod_button_select_icon_sm_yellow" end
    if color == "green" then style = "helmod_button_select_icon_sm_green" end
    if color == "flat" then style = "helmod_button_select_icon_sm_flat" end
    self.options.style = style
    return self
end

-------------------------------------------------------------------------------
---@class GuiButtonSpriteXxl
GuiButtonSpriteXxl = newclass(GuiButton, function(base, ...)
    GuiButton.init(base, ...)
    base.options.style = "helmod_button_icon_xxl"
    base.is_caption = false
end)

-------------------------------------------------------------------------------
---@class GuiButtonSelectSpriteXxl
GuiButtonSelectSpriteXxl = newclass(GuiButton, function(base, ...)
    GuiButton.init(base, ...)
    base.options.style = "helmod_button_select_icon_xxl"
    base.is_caption = false
end)

-------------------------------------------------------------------------------
---Set color
---@param color string
---@return GuiButtonSelectSpriteXxl
function GuiButtonSelectSpriteXxl:color(color)
    local style = "helmod_button_select_icon_xxl"
    if color == "red" then style = "helmod_button_select_icon_xxl_red" end
    if color == "yellow" then style = "helmod_button_select_icon_xxl_yellow" end
    if color == "green" then style = "helmod_button_select_icon_xxl_green" end
    self.options.style = style
    return self
end
