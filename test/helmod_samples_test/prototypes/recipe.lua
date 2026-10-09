local seconds = 60
local minutes = 60*seconds

data:extend(
{
  {
    type = "recipe",
    name = "helmod_test_1",
    categories = {"chemistry"},
    energy_required = 1,
    enabled = true,
    auto_recycle = true,
    ingredients =
    {
      {type = "fluid", name = "petroleum-gas", amount = 20},
      {type = "item", name = "coal", amount = 1, quality_min="uncommon"}
    },
    results =
    {
      {type = "item", name = "plastic-bar", amount = 2, shared_probability = { min = 0.4, max = 0.8 }, quality_min="rare", ignored_by_productivity = 1}
    },
    allow_productivity = true,
    icons =
    {
      {
        icon = "__base__/graphics/icons/plastic-bar.png",
        icon_size = 64
      },
      {
        icon = "__base__/graphics/icons/parameter/parameter-1.png",
        icon_size = 64,
        scale = 0.25,
        shift = {7, 0}
      }
    }
  },
{
    type = "recipe",
    name = "helmod_test_2",
    categories = {"chemistry"},
    energy_required = 1,
    enabled = true,
    auto_recycle = true,
    ingredients =
    {
      {type = "fluid", name = "petroleum-gas", amount = 20},
      {type = "item", name = "coal", amount = 1, quality_max="rare"}
    },
    results =
    {
      {type = "item", name = "plastic-bar", amount = 2, shared_probability = { min = 0.4, max = 0.8 }, quality_min="rare", quality_max="epic", ignored_by_productivity = 1}
    },
    allow_productivity = true,
    icons =
    {
      {
        icon = "__base__/graphics/icons/plastic-bar.png",
        icon_size = 64
      },
      {
        icon = "__base__/graphics/icons/parameter/parameter-2.png",
        icon_size = 64,
        scale = 0.25,
        shift = {7, 0}
      }
    }
  },
  {
    type = "recipe",
    name = "helmod_test_3",
    categories = {"chemistry"},
    energy_required = 1,
    enabled = true,
    auto_recycle = true,
    ingredients =
    {
      {type = "fluid", name = "petroleum-gas", amount = 20},
      {type = "item", name = "coal", amount = 1, quality_min="uncommon", quality_max="rare"}
    },
    results =
    {
      {type = "item", name = "plastic-bar", amount = 2, shared_probability = { min = 0.4, max = 0.8 }, quality_min="rare", quality_max="epic", ignored_by_productivity = 1}
    },
    allow_productivity = true,
    icons =
    {
      {
        icon = "__base__/graphics/icons/plastic-bar.png",
        icon_size = 64
      },
      {
        icon = "__base__/graphics/icons/parameter/parameter-3.png",
        icon_size = 64,
        scale = 0.25,
        shift = {7, 0}
      }
    }
  },
  {
    type = "recipe",
    name = "helmod_test_4",
    categories = {"chemistry"},
    energy_required = 1,
    enabled = true,
    auto_recycle = true,
    ingredients =
    {
      {type = "fluid", name = "petroleum-gas", amount = 20},
      {type = "item", name = "coal", amount = 1, quality_min="normal"}
    },
    results =
    {
      {type = "item", name = "plastic-bar", amount = 2, shared_probability = { min = 0.4, max = 0.8 }, quality_min="rare", ignored_by_productivity = 1}
    },
    allow_productivity = true,
    icons =
    {
      {
        icon = "__base__/graphics/icons/plastic-bar.png",
        icon_size = 64
      },
      {
        icon = "__base__/graphics/icons/parameter/parameter-4.png",
        icon_size = 64,
        scale = 0.25,
        shift = {7, 0}
      }
    }
  },
})
