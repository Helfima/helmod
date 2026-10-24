-- Store silo animation fields that the runtime API does not expose.
-- This mod-data prototype contains planner metadata only.
local function animation_parameters(animation)
  if animation == nil then
    return 0, 0, 0, 1
  end
  if animation.layers ~= nil then
    return animation_parameters(animation.layers[1])
  end
  local frames = animation.frame_count or 1
  if animation.frame_sequence ~= nil then
    frames = #animation.frame_sequence
  end
  frames = frames * (animation.repeat_count or 1)
  if animation.run_mode == "forward-then-backward" then
    frames = math.max(1, 2 * frames - 2)
  end
  local speed = animation.animation_speed or 1
  if speed <= 0 then
    return nil, nil
  end
  return frames / speed, math.max(0, frames - 1) / speed, frames, speed
end

local silos = {}
for name, silo in pairs(data.raw["rocket-silo"] or {}) do
  local front = animation_parameters(silo.arm_03_front_animation)
  local back, retract, back_frames, back_speed = animation_parameters(silo.arm_01_back_animation)
  silos[name] = {
    rocket_entity = silo.rocket_entity,
    times_to_blink = silo.times_to_blink,
    front_arm_duration = front,
    back_arm_duration = back,
    back_arm_retract_duration = retract,
    back_arm_frames = back_frames,
    back_arm_speed = back_speed
  }
end

data:extend{{type = "mod-data", name = "helmod-rocket-timing", data = silos}}
