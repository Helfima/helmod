local Timing = require "model.RocketTiming"

script.on_init(function()
  EventController.onInit()
  local force = game.forces.player
  local surface = game.create_surface("timing", {width=512, height=256, autoplace_controls={}})
  surface.request_to_generate_chunks({0,0}, 7)
  surface.force_generate_chunk_requests()
  for _, entity in pairs(surface.find_entities()) do entity.destroy() end
  local tiles = {}
  for x=-150,150 do for y=-12,12 do tiles[#tiles+1]={name="refined-concrete",position={x,y}} end end
  surface.set_tiles(tiles)
  storage.platform = force.create_space_platform{name="Timing", planet="nauvis", starter_pack="space-platform-starter-pack"}
  storage.platform.apply_starter_pack()
  storage.cases = {}
  local function add(name, quality, craft_ticks, tolerance)
    local index = #storage.cases + 1
    local entity = surface.create_entity{name=name, quality=quality, position={index*14-140,0}, force=force}
    storage.cases[index] = {entity=entity, expected=Timing.getCycleTicks(entity.prototype, quality, craft_ticks), launches={}, tolerance=tolerance or 0}
  end
  for _, quality in ipairs{"normal","uncommon","rare","epic","legendary"} do add("rocket-silo", quality, 10) end
  for index, seconds in ipairs{20,27,30,35,40} do add("timing-craft-"..index,"normal",seconds*60) end
  add("timing-cap-0","normal",1800,1)
  add("timing-cap-25","normal",1800,1)
  add("timing-cap-100","normal",1800,1)
  for i=1,5 do add("timing-animation-"..i,"normal",10) end
end)

script.on_event(defines.events.on_tick,function(event)
  for _, case in ipairs(storage.cases) do
    local entity = case.entity
    entity.energy = 1000000000
    local input = entity.get_inventory(defines.inventory.crafter_input)
    for _, name in ipairs{"rocket-fuel","low-density-structure","processing-unit"} do input.insert{name=name,count=100} end
    local cargo = entity.get_inventory(defines.inventory.rocket_silo_rocket)
    if cargo then cargo.insert{name="iron-plate",count=1} end
    if entity.rocket_silo_status == defines.rocket_silo_status.rocket_ready then
      assert(entity.launch_rocket{type=defines.cargo_destination.station,station=storage.platform.hub})
      case.launches[#case.launches+1] = event.tick
    end
  end
  if event.tick == 39999 then
    for _, case in ipairs(storage.cases) do
      local ticks = case.launches
      assert(#ticks >= 7, "Too few launches: "..case.entity.name)
      local count = math.floor((#ticks-3)/2)*2
      local actual = (ticks[#ticks] - ticks[#ticks-count]) / count
      assert(math.abs(actual-case.expected) <= case.tolerance+0.00001,
        case.entity.name.."/"..case.entity.quality.name..": "..actual.." != "..case.expected)
      log("TIMING PASS "..case.entity.name.."/"..case.entity.quality.name.." measured="..actual.." predicted="..case.expected)
    end
  end
end)
