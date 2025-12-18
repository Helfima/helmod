if storage.rules ~= nil then
    table.reindex_list(storage.rules)
    local new_rule = {index=-1, mod="base", name="selector-filter", category="recipe", type="entity-category", value="recycling", excluded = true}
    local add_rules = true
    for _, rule in pairs(storage.rules) do
        local match = true
        for _, attr in pairs({"mod", "name", "category", "type", "value", "excluded"}) do
            if rule[attr] ~= new_rule[attr] then
                match = false
            end
        end
        if match then
            add_rules = false
        end
    end
    if add_rules == true then
        table.insert(storage.rules, 0, new_rule)
        table.reindex_list(storage.rules)
    end
end