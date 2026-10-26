# Helmod

This a mod for Factorio: [Mod Page](https://mods.factorio.com/mod/helmod)

Data model [here](doc/runtime-api-model.lua)

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

## Sending items to orbit

The rocket button appears when a platform-capable silo is available, such as with Space Age enabled. Without one, existing satellite launch recipes remain available through the recipe selector.

Click the rocket button to select cargo and set how much to send to orbit. Silo quality, modules and beacons are configured in the recipe editor; cargo and rocket ingredients link to their production recipes.

Each cargo recipe calculates its own silo count. The tooltip shows launch and rocket-part rates; the editor shows the minimum launch interval and the crafting speed needed to sustain it.

Capacity, rocket recipes, part counts, buffers and animation properties come from prototypes. Counts assume full cargo loads and immediate launch availability; construction uses average productivity, so discrete craft and dispatch ticks can slightly change observed throughput.

## Silo timing data

`data-final-fixes.lua` copies silo animation fields unavailable through the runtime API into a [mod-data prototype](https://lua-api.factorio.com/latest/prototypes/ModData.html). This stores planner metadata without adding or changing items, entities or recipes.

## Orbit tests

Run `lua test/run_orbit.lua /path/to/factorio --data /path/to/factorio/data` to check orbit calculations through Helmod's solvers inside Factorio. The launcher uses Lua 5.1+ or LuaJIT without Lua packages, plus Linux coreutils or Windows PowerShell for file and process operations. On Windows, quote paths containing spaces.

The launcher creates isolated mod and save directories. Successful runs remove them; failed runs keep the files and print their location for inspection.

* `--base-only` checks existing planning without Space Age.
* `--timing` measures 18 silo configurations over 40,000 ticks.
* `--ui` uses a graphical Factorio client to exercise the selector and recipe editor, then closes that test client after 45 seconds. Screenshots go to `orbit-screenshots` in the current directory, or the directory selected with `--output`.
* `--mods /path/to/mod-set` checks a separately prepared mod set, including compatible silos, cargo demand recalculation and available qualities. The directory supplies mod archives, `mod-list.json` with Helmod enabled, and optional `mod-settings.dat`.
* `--mods /path/to/mod-set --launches` also measures normal and legendary silo launch intervals using continuously supplied rocket parts. This requires platform-capable silos and the Space Age test platform prototypes.

Use `lua test/run_orbit.lua --help` for the command options. The test suites in `test/test_orbit*.lua` run inside Factorio; the launcher only prepares files and starts the engine.
