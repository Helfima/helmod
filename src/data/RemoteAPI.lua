---
---Description of the module.
---@class RemoteAPI
local RemoteAPI = {
  ---single-line comment
  classname = "HMRemoteAPI"
}

-------------------------------------------------------------------------------
---Expose
function RemoteAPI.expose()
    remote.add_interface("helmod_interface", {
        get_models = function() return storage.models end,
        get_recipe = function(recipe)
            recipe.products = {}
            recipe.ingredients = {}
            local prototype = RecipePrototype(recipe)
            for _, lua_product in pairs(prototype:getQualityProducts(recipe.factory, recipe.quality)) do
                local product_prototype = Product(lua_product)
                local product = product_prototype:clone()
				product.count = product_prototype:countProduct(recipe)
				product.count_limit = product_prototype:countLimitProduct(recipe)
				product.count_deep = product_prototype:countDeepProduct(recipe)
                table.insert(recipe.products, product)
            end
            for _, lua_ingredient in pairs(prototype:getQualityIngredients(recipe.factory, recipe.quality)) do
                local ingredient_prototype = Product(lua_ingredient)
                local ingredient = ingredient_prototype:clone()
				ingredient.count = ingredient_prototype:countIngredient(recipe)
				ingredient.count_limit = ingredient_prototype:countLimitIngredient(recipe)
				ingredient.count_deep = ingredient_prototype:countDeepIngredient(recipe)
                table.insert(recipe.ingredients, ingredient)
            end
            return recipe
        end
    })
end

RemoteAPI.expose()