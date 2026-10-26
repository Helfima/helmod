for i, seconds in ipairs({20, 27, 30, 35, 40}) do
  local silo = table.deepcopy(data.raw["rocket-silo"]["rocket-silo"])
  silo.name = "timing-craft-" .. i
  silo.crafting_speed = 150 / seconds
  data:extend{silo}
end
for _, cap in ipairs({0, 25, 100}) do
  local silo = table.deepcopy(data.raw["rocket-silo"]["rocket-silo"])
  silo.name = "timing-cap-" .. cap
  silo.crafting_speed = 5
  silo.rocket_parts_storage_cap = cap
  data:extend{silo}
end
data.raw["rocket-silo"]["rocket-silo"].crafting_speed = 1000

for i=1,5 do
 local s=table.deepcopy(data.raw["rocket-silo"]["rocket-silo"])
 s.name="timing-animation-"..i
 if i==1 then s.arm_01_back_animation.repeat_count=2 end
 if i==2 then s.arm_01_back_animation.frame_sequence={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16} end
 if i==3 then s.arm_01_back_animation.run_mode="forward-then-backward" end
 if i==4 then s.arm_01_back_animation.run_mode="backward" end
 if i==5 then s.arm_01_back_animation.frame_sequence={1,2,3,4};s.arm_01_back_animation.repeat_count=3 end
 data:extend{s}
end
