-------------------------------------------------------------------------------
---@class MatrixHeader
---@field index uint
---@field key string
---@field type string
---@field name string
---@field sysname string
---@field tooltip string
---@field is_ingredient boolean
---@field product table
MatrixHeader = newclass(function(base, type, name, tooltip)
  base.name = name
  base.type = type
  base.tooltip = tooltip
end)

-------------------------------------------------------------------------------
---@return string
function MatrixHeader:get_column_key()
  if self.sysname ~= nil then
    return self.sysname
  end
  return string.format("%s#%s", self.type, self.name)
end

-------------------------------------------------------------------------------
---@param other MatrixHeader
---@return boolean
function MatrixHeader:equals(other)
  if other == nil then return false end
  return self.name == other.name and self.type == other.type
end

-------------------------------------------------------------------------------
---@class MatrixRow
---@field type string
---@field name string
---@field tooltip string
---@field header MatrixHeader
---@field columns {[integer] : MatrixHeader}
---@field values {[integer] : number}
---@field columnIndex {[string] : integer}
MatrixRow = newclass(function(base, type, name, tooltip)
  base.name = name
  base.type = type
  base.tooltip = tooltip
  base.header = MatrixHeader(type, name, tooltip)
  base.columns = {}
  base.values = {}
  base.columnIndex = {}
end)

-------------------------------------------------------------------------------
---@param header MatrixHeader
---@param value number
function MatrixRow:add_value(header, value)
  local key = header:get_column_key()
  if self.columnIndex[key] then
    local icol = self.columnIndex[key]
    self.values[icol] = value or 0
  else
    local icol = #self.columns + 1
    self.columnIndex[key] = icol
    self.values[icol] = value or 0
    self.columns[icol] = header
  end
end

-------------------------------------------------------------------------------
---@param header MatrixHeader
function MatrixRow:get_value(header)
  local key = header:get_column_key()
  local icol = self.columnIndex[key]
  return self.values[icol] or 0
end

-------------------------------------------------------------------------------
---@class MatrixRowParameters
---@field base string
---@field contraints table
---@field factory_count number
---@field factory_speed number
---@field recipe_count number
---@field recipe_production number
---@field recipe_energy number
---@field coefficient number
MatrixRowParameters = newclass(function(base)
  base.factory_count = 0
  base.factory_speed = 1
  base.recipe_count = 0
  base.recipe_production = 1
  base.recipe_energy = 1
  base.coefficient = 0
end)

-------------------------------------------------------------------------------
---@class Matrix
---@field columns {[integer] : MatrixHeader}
---@field headers {[integer] : MatrixHeader}
---@field rows {[integer] : {[integer] : number}}
---@field columnIndex {[string] : integer}
---@field parameters {[integer] : MatrixRowParameters}
---@field objectives {[string] : number}
---@field objective_values {[integer] : number}

Matrix = newclass(function(base)
  base.columns = {}
  base.headers = {}
  base.parameters = {}
  base.rows = {}
  base.columnIndex = {}
end)

-------------------------------------------------------------------------------
---@param header MatrixHeader
---@return number
function Matrix:get_column_index(header)
  local key = header:get_column_key()
  if self.columnIndex[key] then
    return self.columnIndex[key]
  end
  return -1
end

-------------------------------------------------------------------------------
---@param header MatrixHeader
function Matrix:add_column(header)
  local key = header:get_column_key()
  if self.columnIndex[key] == nil then
    local icol = #self.columns + 1
    self.columns[icol] = header
    self.columnIndex[key] = icol
  end
end

-------------------------------------------------------------------------------
---@param row MatrixRow
---@param parameters MatrixRowParameters
function Matrix:add_row(row, parameters)
  local irow = #self.headers + 1
  self.headers[irow] = row.header
  self.parameters[irow] = parameters
  -- add new columns
  for _, header in pairs(row.columns) do
    self:add_column(header)
  end
  for icol, column in pairs(self.columns) do
    local cell_value = row:get_value(column) or 0
    if self.rows[irow] == nil then self.rows[irow]={} end
    self.rows[irow][icol] = cell_value
  end
end