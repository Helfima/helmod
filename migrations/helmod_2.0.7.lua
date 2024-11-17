function migration_priority(priority_module)
    if priority_module == nil then return end
    for _, module in pairs(priority_module) do
        module.amount = module.value
        module.value = nil
    end
end

function migration_modules(modules)
    if modules == nil then return modules end
    local new_modules= {}
    local updated = false
    for module_name, module_value in pairs(modules) do
        if type(module_value) == "number" then
            local new_module = {name=module_name, amount=module_value}
            table.insert(new_modules, new_module)
            updated = true
        end
    end
    if updated then
        return new_modules;
    end
    return modules;
end

function migration_factory(factory)
    if factory == nil then return end
    if factory.modules then
        local new_modules = migration_modules(factory.modules)
        factory.modules = new_modules
    end
    if factory.priority_module then
        migration_priority(factory.priority_module)
    end
end

function migration_recipe(recipe)
    if recipe == nil then return end
    if recipe.factory then
        migration_factory(recipe.factory)
    end
    if recipe.beacons then
        for _, beacon in pairs(recipe.beacons) do
            migration_factory(beacon)
        end
    end
end

function migration_block(block)
    if block == nil then return end
    if block.children then
        for _, child in pairs(block.children) do
            if child.class == "Recipe" then
                migration_recipe(child)
            end
        end
    end
end

if storage.users then
    for _, user in pairs(storage.users) do
        if user.parameter then
            if user.parameter.priority_modules then
                for _, priority_modules in pairs(user.parameter.priority_modules) do
                    migration_priority(priority_modules)
                end
            end
            if user.parameter.default_factory then
                for _, default_factory in pairs(user.parameter.default_factory) do
                    migration_priority(default_factory.priority_module)
                end
            end
        end
    end
end

if storage.models then
    for _, model in pairs(storage.models) do
        if model.block_root then
            migration_block(model.block_root)
        end
        if model.blocks then
            for _, block in pairs(model.blocks) do
                migration_block(block)
            end
        end
    end
end