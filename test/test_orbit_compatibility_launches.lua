local Orbit = require "model.Orbit"
local Timing = require "model.RocketTiming"
script.on_event(defines.events.on_tick, function(event)
    if event.tick == 1 then
        local force=game.forces.player
        local surface=game.create_surface("orbit-compatibility", {width=512,height=128,autoplace_controls={}})
        surface.request_to_generate_chunks({0,0},4)
        surface.force_generate_chunk_requests()
        for _, entity in pairs(surface.find_entities()) do entity.destroy() end
        local tiles={}
        for x=-150,150 do for y=-16,16 do tiles[#tiles+1]={name="refined-concrete",position={x,y}} end end
        surface.set_tiles(tiles)
        storage.orbit_test_platform=force.create_space_platform{name="Orbit test",planet="nauvis",starter_pack="space-platform-starter-pack"}
        storage.orbit_test_platform.apply_starter_pack()
        storage.orbit_test_silos={}
        for name in pairs(Orbit.machines("iron-plate")) do
            for _, quality in ipairs{"normal","legendary"} do
                if prototypes.quality[quality] then
                    local prototype=Orbit.silo({name=name,quality=quality},"iron-plate")
                    local entity=surface.create_entity{name=prototype.name,quality=quality,force=force,position={#storage.orbit_test_silos*28-120,0}}
                    storage.orbit_test_silos[#storage.orbit_test_silos+1]={entity=entity,expected=Timing.getLaunchTicks(prototype,quality),launches={}}
                end
            end
        end
        assert(#storage.orbit_test_silos>0,"platform silos for launch test")
    end
    for _, case in ipairs(storage.orbit_test_silos or {}) do
        local entity=case.entity
        entity.energy=1000000000
        entity.rocket_parts=entity.prototype.rocket_parts_required
        local cargo=entity.get_inventory(defines.inventory.rocket_silo_rocket)
        if cargo then cargo.insert{name="iron-plate",count=1} end
        if entity.rocket_silo_status==defines.rocket_silo_status.rocket_ready then
            assert(entity.launch_rocket{type=defines.cargo_destination.station,station=storage.orbit_test_platform.hub})
            case.launches[#case.launches+1]=event.tick
        end
    end
    if event.tick==15999 then
        for _, case in ipairs(storage.orbit_test_silos) do
            local launches=case.launches
            assert(#launches>=4,"enough launches " .. case.entity.name)
            local actual=(launches[#launches]-launches[2])/(#launches-2)
            assert(math.abs(actual-case.expected)<0.00001,case.entity.name .. ": measured " .. actual .. " predicted " .. case.expected)
            log("COMPAT LAUNCH PASS " .. case.entity.name .. "/" .. case.entity.quality.name .. " ticks=" .. actual)
        end
    end
end)
