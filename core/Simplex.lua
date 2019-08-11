---
-- Description of the module.
-- @module Simplex
--
local Simplex = {
  -- single-line comment
  classname = "HMEvent",
  debug = true,
  debug_col = 8,
  prepare_exclude=2
}

local m_M = nil
local m_Mx = nil
local m_Mr = nil
local m_row_headers = nil
local m_col_headers = nil
local m_col_headers2 = nil

-------------------------------------------------------------------------------
-- Initialisation
--
-- @function [parent=#Simplex] pivot
-- @param #Matrix M
-- @param #Number xrow
-- @param #Number xcol
--
-- @return #Simplex
--
function Simplex.new(M, row_headers, col_headers)
  m_M = M
  m_row_headers = row_headers
  m_col_headers = col_headers
  return Simplex
end
-------------------------------------------------------------------------------
-- Return prepared matrix
--
-- @function [parent=#Simplex] getMx
--
-- @return #Matrix
--
function Simplex.getMx()
  return m_Mx
end

-------------------------------------------------------------------------------
-- Return initial matrix
--
-- @function [parent=#Simplex] getM
--
-- @return #Matrix
--
function Simplex.getM()
  return m_M
end

-------------------------------------------------------------------------------
-- Return result matrix
--
-- @function [parent=#Simplex] getMr
--
-- @return #Matrix
--
function Simplex.getMr()
  return m_Mr
end
-------------------------------------------------------------------------------
-- Calcul pivot de gauss
--
-- @function [parent=#Simplex] pivot
-- @param #Matrix M
-- @param #Number xrow
-- @param #Number xcol
--
-- @return #Matrix
--
function Simplex.pivot(M, xrow, xcol)
  local Mx = {}
  local pivot_value = M[xrow][xcol]
  for irow,row in pairs(M) do
    Mx[irow]={}
    for icol,cell_value in pairs(row) do
      if irow == xrow then
        Mx[irow][icol] = cell_value/pivot_value
      elseif icol == xcol then
        Mx[irow][icol] = 0
      else
        Mx[irow][icol] = cell_value - ( M[irow][xcol]*M[xrow][icol] ) / pivot_value
      end
    end
  end
  if m_row_headers ~= nil then
    m_row_headers[xrow] = m_col_headers2[xcol-1]
  end
  return Mx
end

-------------------------------------------------------------------------------
-- Retourne le pivot
--
-- @function [parent=#Simplex] getPivotCol
-- @param #Matrix M
--
-- @return #Number
--
function Simplex.getPivot(M)
  local max_z_value = 0
  local xcol = nil
  local min_ratio_value = 0
  local xrow = nil
  local last_row = M[rawlen(M)]
  -- boucle sur la derniere ligne nommee Z
  for icol,z_value in pairs(last_row) do
    -- on exclus le premiere colonne nommee C
    if icol > 1 then
      if z_value > max_z_value then
        -- la valeur repond au critere, la colonne est eligible
        -- on recherche le ligne
        min_ratio_value = nil
        for irow, current_row in pairs(M) do
          local x_value = M[irow][icol]
          -- on n'utilise pas la derniere ligne
          -- seule les cases positives sont prises en compte
          if irow < rawlen(M) and x_value > 0 then
            -- calcul du ratio base / x
            local bx_ratio = M[irow][1]/x_value
            if min_ratio_value == nil or bx_ratio < min_ratio_value then
              min_ratio_value = bx_ratio
              xrow = irow
            end
          end
        end
        if min_ratio_value ~= nil then
          -- le pivot est possible
          max_z_value = z_value
          xcol = icol
        end
      end
    end
  end
  if max_z_value == 0 then
    -- il n'y a plus d'amelioration possible fin du programmme
    return false, xcol, xrow
  end
  Simplex.print(string.format("%s: %s,%s", "Pivot", xrow, xcol))
  return true, xcol, xrow
end

-------------------------------------------------------------------------------
-- Prepare la matrice
--
-- @function [parent=#Simplex] prepare
-- @param #Matrix M
--
-- @return #Matrix
--
function Simplex.prepare(M)
  local Mx = Simplex.clone(M)
  local num_row = rawlen(M) - Simplex.prepare_exclude
  local num_col = rawlen(M[1])
  for irow,row in pairs(M) do
    for xrow=1, num_row do
      if irow == xrow then
        Mx[irow][num_col+xrow] = 1
      else
        Mx[irow][num_col+xrow] = 0
      end
    end
  end
  m_col_headers2 = m_col_headers
  if m_row_headers ~= nil then
    for icol=1, (#m_row_headers) do
      table.insert(m_col_headers2,m_row_headers[icol])
    end
  end
  return Mx
end

-------------------------------------------------------------------------------
-- Clone la matrice
--
-- @function [parent=#Simplex] clone
-- @param #Matrix M
--
-- @return #Number
--
function Simplex.clone(M)
  local Mx = {}
  local num_row = rawlen(M)
  local num_col = rawlen(M[1])
  for irow,row in pairs(M) do
    Mx[irow] = {}
    for icol,col in pairs(row) do
      Mx[irow][icol] = col
    end
  end
  return Mx
end

-------------------------------------------------------------------------------
-- format
--
-- @function [parent=#Simplex] format
-- @param #string message
--
function Simplex.format(message)
  if message == nil then message = "nil" end
  local size = string.len(message)
  if size > Simplex.debug_col then
    return string.sub(message, 1, Simplex.debug_col)
  elseif size < Simplex.debug_col then
    return string.rep(" ",Simplex.debug_col-size)..message
  end
  return message
end

-------------------------------------------------------------------------------
-- Print
--
-- @function [parent=#Simplex] print
-- @param #Object object
--
function Simplex.print(object)
  if object ~= nil and Simplex.debug then
    if type(object) == "string" then
      print(object)
    else
      -- 1 ere ligne
      if m_col_headers ~= nil then
        local message = ""
        if m_row_headers ~= nil then
          message = string.format("%s %s %s", message, Simplex.format(""), "|")
        end
        message = string.format("%s %s %s", message, Simplex.format("B"), "|")
        if #object[1]-1 > #m_col_headers then
          for icol=1, (#m_col_headers2) do
            message = string.format("%s %s %s", message, Simplex.format(m_col_headers2[icol]), "|")
          end
        else
          for icol=1, (#m_col_headers) do
            message = string.format("%s %s %s", message, Simplex.format(m_col_headers[icol]), "|")
          end
        end
        print(message)
      end
      -- le tableau
      for irow,row in pairs(object) do
        local message = ""
        if m_row_headers ~= nil then
          if irow == #object then
            message = string.format("%s %s %s", message, Simplex.format("Z"), "|")
          else
            message = string.format("%s %s %s", message, Simplex.format(m_row_headers[irow]), "|")
          end
        end
        
        for icol,cell_value in pairs(row) do
          message = string.format("%s %s %s", message, Simplex.format(cell_value), "|")
        end
        
        print(message)
      end
      print("----------------------------------------------")
    end
  end
end
-------------------------------------------------------------------------------
-- Resoud la matrice
--
-- @function [parent=#Simplex] solve
--
-- @return #lua_event
--
function Simplex.solve()
  if m_M ~= nil then
    local num_loop = 0
    Simplex.print(m_M)
    m_Mx = Simplex.prepare(m_M)
    Simplex.print(m_Mx)
    m_Mr = Simplex.clone(m_Mx)
    local loop, xcol, xrow
    loop = true
    while loop do
      loop, xcol, xrow = Simplex.getPivot(m_Mr)
      if loop then
        m_Mr = Simplex.pivot(m_Mr, xrow, xcol)
        Simplex.print(m_Mr)
      end
      num_loop = num_loop + 1
    end
    Simplex.print(string.format("End in %s loop",num_loop))
    return m_Mr
  end
end

return Simplex