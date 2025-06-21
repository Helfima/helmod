if storage.models then
    local ok , err = pcall(function()
        for _, model in pairs(storage.models) do
            local player = Player.try_load_by_name(model.owner)
            if player ~= nil then
                ModelCompute.update(model)
            end
        end
    end)
end