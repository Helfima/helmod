require "selector.ItemSelector"
local Orbit = require "model.Orbit"

OrbitSelector = newclass(ItemSelector, function(base, classname)
    AbstractSelector.init(base, classname)
end)

function OrbitSelector:afterInit()
    self.hidden_option = true
    self.is_support_quality = true
end

function OrbitSelector:getCaption()
    return {"helmod_orbit.title"}
end

function OrbitSelector:updateGroups(list_products, list_ingredients, list_translate)
    local silos = Orbit.machines()
    for _, item in pairs(Player.getItemPrototypes()) do
        for _, silo in pairs(silos) do
            if Orbit.capacity(item.name, silo) > 0 then
                self:appendGroups(item, "orbit", list_products, list_ingredients, list_translate)
                break
            end
        end
    end
end

function OrbitSelector:buildPrototypeIcon(gui_element, prototype, tooltip)
    local button = GuiElement.add(gui_element, GuiButtonSelectSprite(self.classname, "element-select", "orbit")
        :choose("item", prototype.name):tooltip(tooltip))
    button.locked = true
end
