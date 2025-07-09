if storage.models then
    local ok , err = pcall(function()
        for _, model in pairs(storage.models) do
            -- copy old infos from model to root_block
            if model.block_root ~= nil then
                local block_infos = Model.getBlockInfos(model.block_root)
                if model.infos ~= nil then
                    block_infos.primary_icon = model.infos.primary_icon
                    block_infos.secondary_icon = model.infos.secondary_icon
                    block_infos.title = model.title
                end
            end
        end
    end)
end