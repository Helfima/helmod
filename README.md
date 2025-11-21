# Helmod

This a mod for Factorio: [Mod Page](https://mods.factorio.com/mod/helmod)

Data model [here](doc\runtime-api-model.lua)

To see the data in the game, open Helmod, click on Admin icon, choose Global tab

## Remote API

Name of remote interface `helmod_interface`
Use `remote.call` from your mod for request data

Methodes:

* get_models : Return all models
* get_recipe(recipe_data) : Return the recipe with products and ingredients

To traverse the model, start with the root block `model.block_root` and to traverse each block `block.children`

Data Class:

* Model : the model
* Block : a block that contains blocks or recipes
* Recipe : a helmod recipe, the type `recipe` is native recipe of Factorio, otherwise is custom recipe

Examples:
```LUA
-- return all models
local data = remote.call("helmod_interface", "get_models")
```

```LUA
---Traverse model to append products and ingredients on each recipe
---@param data ModelData | BlokcData | RecipeData
function UnitTestPanel:loopDataRemoteAPI(data)
    if data.class == "Model" then
        for _, child in pairs(data.block_root.children) do
            self:loopDataRemoteAPI(child)
        end
    elseif data.class == "Block" then
        for _, child in pairs(data.children) do
            self:loopDataRemoteAPI(child)
        end
    elseif data.class == "Recipe" then
        local recipe = remote.call("helmod_interface", "get_recipe", data)
        data.products = recipe.products
        data.ingredients = recipe.ingredients
    end
end
```