local PartRecipe = {}

---@class SiloCraftSlots
---@field items integer
---@field inputs integer Fluid input boxes available to the recipe
---@field outputs integer Fluid output boxes available to the recipe

---@class SiloMaterial
---@field type string
---@field fluidbox_index? integer

---@param materials SiloMaterial[]
---@return integer items, integer fluidBoxes
local function requiredSlots(materials)
    local items, fluids, lastBox = 0, 0, 0
    for _, material in ipairs(materials) do
        if material.type == "fluid" then
            fluids = fluids + 1
            lastBox = math.max(lastBox, material.fluidbox_index or 0)
        elseif material.type == "item" then
            items = items + 1
        end
    end
    return items, math.max(fluids, lastBox)
end

---@param slots SiloCraftSlots
---@param ingredients SiloMaterial[]
---@param products SiloMaterial[]
---@return boolean
function PartRecipe.fits(slots, ingredients, products)
    local items, inputs = requiredSlots(ingredients)
    local _, outputs = requiredSlots(products)
    return items <= slots.items and inputs <= slots.inputs and outputs <= slots.outputs
end

return PartRecipe
