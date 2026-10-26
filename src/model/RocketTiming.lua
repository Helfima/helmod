local RocketTiming = {}

local function progress_ticks(speed, initial, limit)
  if speed == nil or speed <= 0 then
    return nil
  end
  -- Accumulate progress per tick to match the engine's floating-point rounding.
  local progress, ticks = initial or 0, 0
  limit = limit or 1
  while progress < limit and ticks < 10000 do
    progress = progress + speed
    ticks = ticks + 1
  end
  if progress >= limit then
    return ticks
  end
  return math.ceil((limit - (initial or 0)) / speed)
end

function RocketTiming.stages(silo, rocket, animation, level)
  level = level or 0
  local rise_speed = rocket.rising_speed * (1 + level * (silo.rocket_rising_speed_modifier_per_quality_level or 0))
  local engine_speed = rocket.engine_starting_speed * (1 + level * (silo.rocket_engine_starting_speed_modifier_per_quality_level or 0))
  local arm_multiplier = 1 + level * (silo.arms_speed_modifier_per_quality_level or 0)
  local front = animation.front_arm_duration / arm_multiplier
  local back = progress_ticks(animation.back_arm_speed * arm_multiplier, 0, animation.back_arm_frames)
  local retract = animation.back_arm_retract_duration / arm_multiplier
  local flight_speed = rocket.flying_speed
  local acceleration = rocket.flying_acceleration
  if rise_speed <= 0 or engine_speed <= 0 or flight_speed <= 0 then
    return nil
  end
  -- Flight releases the silo at 0.1 progress; arm retraction runs concurrently.
  local flight
  if acceleration == 0 then
    flight = math.ceil(0.1 / flight_speed)
  elseif acceleration > 0 then
    flight = math.ceil(math.log(1 + 0.1 * acceleration / flight_speed) / math.log(1 + acceleration))
  else
    return nil
  end
  local function rising(offset)
    return math.max(1, progress_ticks(rise_speed, offset + front * rise_speed)) + math.max(1, math.ceil(back))
  end
  local blinking = progress_ticks(silo.light_blinking_speed)
  local doors = progress_ticks(silo.door_opening_speed)
  if blinking == nil or doors == nil then
    return nil
  end
  return {
    fast_preparation = 1 + rising(silo.rocket_quick_relaunch_start_offset),
    full_preparation = 1 + blinking + doors + silo.rocket_rising_delay + 1 + rising(0),
    launch = 1 + silo.launch_wait_time + math.ceil(1 / engine_speed) + math.max(flight, math.ceil(retract) + 1),
    closing = blinking + doors,
    blinking = blinking,
    blinking_phase_speed = silo.light_blinking_speed * (animation.times_to_blink + 0.5)
  }
end

function RocketTiming.calculate(silo, rocket, animation, level)
  local stages = RocketTiming.stages(silo, rocket, animation, level)
  if stages == nil then
    return nil
  end
  return stages.fast_preparation + stages.launch
end

-- A closing silo can resume a quick launch only while the warning light is off.
local function dark_window(delay, stages)
  local tick = math.max(1, math.ceil(delay))
  if tick >= stages.blinking then
    return stages.blinking
  end
  local step = stages.blinking_phase_speed
  if step <= 0 then
    return tick
  end
  local phase = tick * step
  local fraction = phase - math.floor(phase)
  if fraction < 0.05 or fraction > 0.95 then
    return tick
  end
  tick = math.ceil((math.floor(phase) + 0.95) / step)
  local f = tick * step % 1
  if f >= 0.05 and f <= 0.95 then
    tick = tick + 1
  end
  return math.min(tick, stages.blinking)
end

function RocketTiming.cycle(silo, stages, craft_ticks)
  local required = silo.rocket_parts_required
  local cap = silo.rocket_parts_storage_cap or required
  local rate = required / math.max(craft_ticks, 0.000001)
  local function transition(fast, stock)
    local preparation = stages.full_preparation
    if fast == true then
      preparation = stages.fast_preparation
    end
    local flight_end = preparation + stages.launch
    local ready = math.max(0, (required - stock) / rate)
    local elapsed, next_fast
    if cap >= required and ready <= flight_end then
      elapsed, next_fast = flight_end, true
    elseif cap >= required and ready <= flight_end + stages.blinking then
      elapsed, next_fast = flight_end + dark_window(ready - flight_end, stages), true
    else
      elapsed, next_fast = flight_end + stages.closing, false
      if cap < required then
        local buffered = math.min(cap, stock + elapsed * rate)
        elapsed = elapsed + (required - buffered) / rate
      else
        elapsed = math.max(elapsed, ready)
      end
    end
    return elapsed, next_fast, math.max(0, math.min(cap, stock + elapsed * rate) - required)
  end
  if cap <= required then
    local fast_time, after_fast = transition(true, 0)
    if after_fast == true then
      return fast_time
    end
    local full_time, after_full = transition(false, 0)
    if after_full == false then
      return full_time
    end
    return (fast_time + full_time) / 2
  end
  -- Average launch intervals after the rocket-part buffer settles.
  local fast, stock, elapsed = false, 0, 0
  for index = 1, 2048 do
    local interval
    interval, fast, stock = transition(fast, stock)
    if index > 1024 then
      elapsed = elapsed + interval
    end
  end
  return elapsed / 1024
end

local function configuration(silo, quality)
  local mod_data = prototypes.mod_data["helmod-rocket-timing"]
  if mod_data == nil then
    return nil
  end
  local animation = mod_data.data[silo.name]
  if animation == nil or animation.front_arm_duration == nil or animation.back_arm_duration == nil
    or animation.back_arm_retract_duration == nil or animation.times_to_blink == nil
    or animation.back_arm_frames == nil or animation.back_arm_speed == nil then
    return nil
  end
  local rocket = prototypes.entity[animation.rocket_entity]
  if rocket == nil then
    return nil
  end
  local level = 0
  if type(quality) == "number" then
    level = quality
  elseif type(quality) == "string" then
    level = prototypes.quality[quality].level
  elseif type(quality) == "table" or type(quality) == "userdata" then
    level = quality.level
  end
  return RocketTiming.stages(silo, rocket, animation, level)
end

function RocketTiming.getLaunchTicks(silo, quality)
  local stages = configuration(silo, quality)
  if stages == nil then
    return nil
  end
  return stages.fast_preparation + stages.launch
end

function RocketTiming.getCycleTicks(silo, quality, craft_ticks)
  local stages = configuration(silo, quality)
  if stages == nil then
    return nil
  end
  return RocketTiming.cycle(silo, stages, craft_ticks)
end

return RocketTiming
