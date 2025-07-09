local data = {mod="Base"}
data.energy = {}
data.energy["offshore-pump"] = {
    energy_type="none",
    energy_type_input="none",
    energy_usage_min=0,
    energy_usage_max=0,
    energy_usage_priority="none",
    energy_consumption=0,
    energy_type_output="none",
    energy_production=0,
    effectivity=1,
    target_temperature=0,
    maximum_temperature=0,
    fluid_usage=0,
    fluid_burns="none",
    fluid_fuel = {name="none", capacity=0},
    fluid_consumption=0,
    fluid_production={name="water", amount=1200},
    pollution=0,
    speed=1200,
    recipe={type="fluid"}
}
data.energy["assembling-machine-1"] = {
    energy_type="electric",
    energy_type_input="electric",
    energy_usage_min=2500,
    energy_usage_max=75000,
    energy_usage_priority="secondary-input",
    energy_consumption=77500,
    energy_type_output="none",
    energy_production=0,
    effectivity=1,
    target_temperature=0,
    maximum_temperature=0,
    fluid_usage=0,
    fluid_burns="none",
    fluid_fuel = {name="none", capacity=0},
    fluid_consumption=0,
    fluid_production={name="none", amount=0},
    pollution=4,
    speed=0.5,
    recipe={type="recipe"}
}
data.energy["assembling-machine-2"] = {
    energy_type="electric",
    energy_type_input="electric",
    energy_usage_min=5000,
    energy_usage_max=150000,
    energy_usage_priority="secondary-input",
    energy_consumption=155000,
    energy_type_output="none",
    energy_production=0,
    effectivity=1,
    target_temperature=0,
    maximum_temperature=0,
    fluid_usage=0,
    fluid_burns="none",
    fluid_fuel = {name="none", capacity=0},
    fluid_consumption=0,
    fluid_production={name="none", amount=0},
    pollution=3,
    speed=0.75,
    recipe={type="recipe"}
}
data.energy["assembling-machine-3"] = {
    energy_type="electric",
    energy_type_input="electric",
    energy_usage_min=12500,
    energy_usage_max=375000,
    energy_usage_priority="secondary-input",
    energy_consumption=387500,
    energy_type_output="none",
    energy_production=0,
    effectivity=1,
    target_temperature=0,
    maximum_temperature=0,
    fluid_usage=0,
    fluid_burns="none",
    fluid_fuel = {name="none", capacity=0},
    fluid_consumption=0,
    fluid_production={name="none", amount=0},
    pollution=2,
    speed=1.25,
    recipe={type="recipe"}
}
data.energy["boiler"] = {
    energy_type="burner",
    energy_type_input="burner",
    energy_usage_min=0,
    energy_usage_max=1800000,
    energy_usage_priority="none",
    energy_type_output="none",
    energy_consumption=1800000,
    energy_production=0,
    effectivity=1,
    target_temperature=165,
    maximum_temperature=0,
    fluid_usage=0,
    fluid_burns="none",
    fluid_fuel = {name="none", capacity=0},
    fluid_consumption=0,
    fluid_production={name="steam", amount=60},
    pollution=30,
    speed=1,
    recipe={name="steam"}
}
data.energy["steam-engine"] = {
    energy_type="electric",
    energy_type_input="fluid",
    energy_usage_min=0,
    energy_usage_max=0,
    energy_usage_priority="secondary-output",
    energy_consumption=900000,
    energy_type_output="electric",
    energy_production=900000,
    effectivity=1,
    target_temperature=0,
    maximum_temperature=165,
    fluid_usage=30,
    fluid_burns=false,
    fluid_fuel = {name="steam", capacity=200},
    fluid_consumption=30,
    fluid_production={name="none", amount=0},
    pollution=0,
    speed=1,
    recipe={type="recipe"}
}
data.energy["heat-exchanger"] = {
    energy_type="heat",
    energy_type_input="heat",
    energy_usage_min=0,
    energy_usage_max=10000000,
    energy_usage_priority="none",
    energy_consumption=10000000,
    energy_type_output="none",
    energy_production=0,
    effectivity=1,
    target_temperature=500,
    maximum_temperature=0,
    fluid_usage=0,
    fluid_burns="none",
    fluid_fuel = {name="none", capacity=0},
    fluid_consumption=0,
    fluid_production={name="steam", amount=103},
    pollution=0,
    speed=1,
    recipe={type="resource"}
}
data.energy["steam-turbine"] = {
    energy_type="electric",
    energy_type_input="fluid",
    energy_usage_min=0,
    energy_usage_max=0,
    energy_usage_priority="secondary-output",
    energy_consumption=5820000,
    energy_type_output="electric",
    energy_production=5820000,
    effectivity=1,
    target_temperature=0,
    maximum_temperature=500,
    fluid_usage=60,
    fluid_burns=false,
    fluid_fuel = {name="steam", capacity=200},
    fluid_consumption=60,
    fluid_production={name="none", amount=0},
    pollution=0,
    speed=1,
    recipe={type="recipe"}
}
data.energy["nuclear-reactor"] = {
    energy_type="burner",
    energy_type_input="burner",
    energy_usage_min=0,
    energy_usage_max=40000000,
    energy_usage_priority="none",
    energy_consumption=40000000,
    energy_type_output="heat",
    energy_production=40000000,
    effectivity=1,
    target_temperature=0,
    maximum_temperature=0,
    fluid_usage=0,
    fluid_burns="none",
    fluid_fuel = {name="none", capacity=0},
    fluid_consumption=0,
    fluid_production={name="none", amount=0},
    pollution=0,
    speed=1,
    recipe={type="recipe"}
}

data.energy["solar-panel"] = {
    energy_type="electric",
    energy_type_input="none",
    energy_usage_min=0,
    energy_usage_max=0,
    energy_usage_priority="solar",
    energy_consumption=0,
    energy_type_output="electric",
    energy_production=60000,
    effectivity=1,
    target_temperature=0,
    maximum_temperature=0,
    fluid_usage=0,
    fluid_burns="none",
    fluid_fuel = {name="none", capacity=0},
    fluid_consumption=0,
    fluid_production={name="none", amount=0},
    pollution=0,
    speed=1,
    recipe={type="recipe"}
}

data.energy["accumulator"] = {
    energy_type="electric",
    energy_type_input="electric",
    energy_usage_min=0,
    energy_usage_max=300000,
    energy_usage_priority="managed-accumulator",
    energy_consumption=300000,
    energy_type_output="electric",
    energy_production=300000,
    effectivity=1,
    target_temperature=0,
    maximum_temperature=0,
    fluid_usage=0,
    fluid_burns="none",
    fluid_fuel = {name="none", capacity=0},
    fluid_consumption=0,
    fluid_production={name="none", amount=0},
    pollution=0,
    speed=1,
    recipe={type="recipe"}
}
data.modules = {}

data.modules["speed-module"] = {}
data.modules["speed-module"]["normal"] = { speed = 0.2, productivity = 0, consumption = 0.5, pollution = 0, quality = -0.1 }
data.modules["speed-module"]["uncommon"] = { speed = 0.26, productivity = 0, consumption = 0.5, pollution = 0, quality = -0.1 }
data.modules["speed-module"]["rare"] = { speed = 0.32, productivity = 0, consumption = 0.5, pollution = 0, quality = -0.1 }
data.modules["speed-module"]["epic"] = { speed = 0.38, productivity = 0, consumption = 0.5, pollution = 0, quality = -0.1 }
data.modules["speed-module"]["legendary"] = { speed = 0.5, productivity = 0, consumption = 0.5, pollution = 0, quality = -0.1 }

data.modules["speed-module-2"] = {}
data.modules["speed-module-2"]["normal"] = { speed = 0.3, productivity = 0, consumption = 0.6, pollution = 0, quality = -0.15 }
data.modules["speed-module-2"]["uncommon"] = { speed = 0.39, productivity = 0, consumption = 0.6, pollution = 0, quality = -0.15 }
data.modules["speed-module-2"]["rare"] = { speed = 0.48, productivity = 0, consumption = 0.6, pollution = 0, quality = -0.15 }
data.modules["speed-module-2"]["epic"] = { speed = 0.57, productivity = 0, consumption = 0.6, pollution = 0, quality = -0.15 }
data.modules["speed-module-2"]["legendary"] = { speed = 0.75, productivity = 0, consumption = 0.6, pollution = 0, quality = -0.15 }

data.modules["speed-module-3"] = {}
data.modules["speed-module-3"]["normal"] = { speed = 0.5, productivity = 0, consumption = 0.7, pollution = 0, quality = -0.25 }
data.modules["speed-module-3"]["uncommon"] = { speed = 0.65, productivity = 0, consumption = 0.7, pollution = 0, quality = -0.25 }
data.modules["speed-module-3"]["rare"] = { speed = 0.8, productivity = 0, consumption = 0.7, pollution = 0, quality = -0.25 }
data.modules["speed-module-3"]["epic"] = { speed = 0.95, productivity = 0, consumption = 0.7, pollution = 0, quality = -0.25 }
data.modules["speed-module-3"]["legendary"] = { speed = 1.25, productivity = 0, consumption = 0.7, pollution = 0, quality = -0.25 }

data.modules["efficiency-module"] = {}
data.modules["efficiency-module"]["normal"] = { speed = 0, productivity = 0, consumption = -0.3, pollution = 0, quality = 0 }
data.modules["efficiency-module"]["uncommon"] = { speed = 0, productivity = 0, consumption = -0.39, pollution = 0, quality = 0 }
data.modules["efficiency-module"]["rare"] = { speed = 0, productivity = 0, consumption = -0.48, pollution = 0, quality = 0 }
data.modules["efficiency-module"]["epic"] = { speed = 0, productivity = 0, consumption = -0.57, pollution = 0, quality = 0 }
data.modules["efficiency-module"]["legendary"] = { speed = 0, productivity = 0, consumption = -0.75, pollution = 0, quality = 0 }

data.modules["efficiency-module-2"] = {}
data.modules["efficiency-module-2"]["normal"] = { speed = 0, productivity = 0, consumption = -0.4, pollution = 0, quality = 0 }
data.modules["efficiency-module-2"]["uncommon"] = { speed = 0, productivity = 0, consumption = -0.52, pollution = 0, quality = 0 }
data.modules["efficiency-module-2"]["rare"] = { speed = 0, productivity = 0, consumption = -0.64, pollution = 0, quality = 0 }
data.modules["efficiency-module-2"]["epic"] = { speed = 0, productivity = 0, consumption = -0.76, pollution = 0, quality = 0 }
data.modules["efficiency-module-2"]["legendary"] = { speed = 0, productivity = 0, consumption = -1, pollution = 0, quality = 0 }

data.modules["efficiency-module-3"] = {}
data.modules["efficiency-module-3"]["normal"] = { speed = 0, productivity = 0, consumption = -0.5, pollution = 0, quality = 0 }
data.modules["efficiency-module-3"]["uncommon"] = { speed = 0, productivity = 0, consumption = -0.65, pollution = 0, quality = 0 }
data.modules["efficiency-module-3"]["rare"] = { speed = 0, productivity = 0, consumption = -0.8, pollution = 0, quality = 0 }
data.modules["efficiency-module-3"]["epic"] = { speed = 0, productivity = 0, consumption = -0.95, pollution = 0, quality = 0 }
data.modules["efficiency-module-3"]["legendary"] = { speed = 0, productivity = 0, consumption = -1.25, pollution = 0, quality = 0 }

data.modules["productivity-module"] = {}
data.modules["productivity-module"]["normal"] = { speed = -0.05, productivity = 0.04, consumption = 0.4, pollution = 0.05, quality = 0 }
data.modules["productivity-module"]["uncommon"] = { speed = -0.05, productivity = 0.05, consumption = 0.4, pollution = 0.05, quality = 0 }
data.modules["productivity-module"]["rare"] = { speed = -0.05, productivity = 0.06, consumption = 0.4, pollution = 0.05, quality = 0 }
data.modules["productivity-module"]["epic"] = { speed = -0.05, productivity = 0.07, consumption = 0.4, pollution = 0.05, quality = 0 }
data.modules["productivity-module"]["legendary"] = { speed = -0.05, productivity = 0.1, consumption = 0.4, pollution = 0.05, quality = 0 }

data.modules["productivity-module-2"] = {}
data.modules["productivity-module-2"]["normal"] = { speed = -0.1, productivity = 0.06, consumption = 0.6, pollution = 0.07, quality = 0 }
data.modules["productivity-module-2"]["uncommon"] = { speed = -0.1, productivity = 0.07, consumption = 0.6, pollution = 0.07, quality = 0 }
data.modules["productivity-module-2"]["rare"] = { speed = -0.1, productivity = 0.09, consumption = 0.6, pollution = 0.07, quality = 0 }
data.modules["productivity-module-2"]["epic"] = { speed = -0.1, productivity = 0.11, consumption = 0.6, pollution = 0.07, quality = 0 }
data.modules["productivity-module-2"]["legendary"] = { speed = -0.1, productivity = 0.15, consumption = 0.6, pollution = 0.07, quality = 0 }

data.modules["productivity-module-3"] = {}
data.modules["productivity-module-3"]["normal"] = { speed = -0.15, productivity = 0.1, consumption = 0.8, pollution = 0.1, quality = 0 }
data.modules["productivity-module-3"]["uncommon"] = { speed = -0.15, productivity = 0.13, consumption = 0.8, pollution = 0.1, quality = 0 }
data.modules["productivity-module-3"]["rare"] = { speed = -0.15, productivity = 0.16, consumption = 0.8, pollution = 0.1, quality = 0 }
data.modules["productivity-module-3"]["epic"] = { speed = -0.15, productivity = 0.19, consumption = 0.8, pollution = 0.1, quality = 0 }
data.modules["productivity-module-3"]["legendary"] = { speed = -0.15, productivity = 0.25, consumption = 0.8, pollution = 0.1, quality = 0 }

data.modules["quality-module"] = {}
data.modules["quality-module"]["normal"] = { speed = -0.05, productivity = 0, consumption = 0, pollution = 0, quality = 0.01 }
data.modules["quality-module"]["uncommon"] = { speed = -0.05, productivity = 0, consumption = 0, pollution = 0, quality = 0.013 }
data.modules["quality-module"]["rare"] = { speed = -0.05, productivity = 0, consumption = 0, pollution = 0, quality = 0.016 }
data.modules["quality-module"]["epic"] = { speed = -0.05, productivity = 0, consumption = 0, pollution = 0, quality = 0.019 }
data.modules["quality-module"]["legendary"] = { speed = -0.05, productivity = 0, consumption = 0, pollution = 0, quality = 0.025 }

data.modules["quality-module-2"] = {}
data.modules["quality-module-2"]["normal"] = { speed = -0.05, productivity = 0, consumption = 0, pollution = 0, quality = 0.02 }
data.modules["quality-module-2"]["uncommon"] = { speed = -0.05, productivity = 0, consumption = 0, pollution = 0, quality = 0.026 }
data.modules["quality-module-2"]["rare"] = { speed = -0.05, productivity = 0, consumption = 0, pollution = 0, quality = 0.032 }
data.modules["quality-module-2"]["epic"] = { speed = -0.05, productivity = 0, consumption = 0, pollution = 0, quality = 0.038 }
data.modules["quality-module-2"]["legendary"] = { speed = -0.05, productivity = 0, consumption = 0, pollution = 0, quality = 0.05 }

data.modules["quality-module-3"] = {}
data.modules["quality-module-3"]["normal"] = { speed = -0.05, productivity = 0, consumption = 0, pollution = 0, quality = 0.025 }
data.modules["quality-module-3"]["uncommon"] = { speed = -0.05, productivity = 0, consumption = 0, pollution = 0, quality = 0.032 }
data.modules["quality-module-3"]["rare"] = { speed = -0.05, productivity = 0, consumption = 0, pollution = 0, quality = 0.04 }
data.modules["quality-module-3"]["epic"] = { speed = -0.05, productivity = 0, consumption = 0, pollution = 0, quality = 0.047 }
data.modules["quality-module-3"]["legendary"] = { speed = -0.05, productivity = 0, consumption = 0, pollution = 0, quality = 0.062 }

return data