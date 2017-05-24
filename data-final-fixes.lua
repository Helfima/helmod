local data_entity = {}

-- recherche tout les types item
for type,elements in pairs(data.raw) do
  if type =="item" then
    for _,element in pairs(elements) do
      local entity = {}
      entity.type = element.type
      data_entity[element.name] = entity
    end
  end
end
-- recherche des attributs non visible pour les items precedents
for type,elements in pairs(data.raw) do
  if type ~="item" then
    for _,element in pairs(elements) do
      if element.name ~= nil and element.type ~= "recipe" then
        local entity = data_entity[element.name]
        if entity ~= nil then
          -- util pour le generation de list
          if element.type == "solar-panel" then 
            if element.production ~= nil then entity.production = element.production end
          end
          -- proprietes pour les usines
          if element.distribution_effectivity ~= nil then entity.efficiency = element.distribution_effectivity end
        end
      end
    end
  end
end

-- @see https://mods.factorio.com/mods/Earendel/data-raw-prototypes

local chunk_suffix = "_"
local function save_chunk (name, string)
    data:extend({{
      type = "flying-text",
      name = name,
      time_to_live = 0,
      speed = 1,
      order = string
    }})
end

local function chunkify(string)
    local chunkSize = 200
    local s = {}
    for i=1, #string, chunkSize do
        s[#s+1] = string:sub(i,i+chunkSize - 1)
    end
    return s
end

local function save_string (name, string)
    local chunks = chunkify(string)
    for i, chunk in ipairs(chunks) do
        save_chunk(name..chunk_suffix..i, chunk)
    end
end

save_string("data_entity", serpent.dump(data_entity))