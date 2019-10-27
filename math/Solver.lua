---
-- Description of the module.
-- @module Solver
--
local Solver = {
  -- single-line comment
  classname = "HMSolver",
  debug = false,
  debug_col = 8,
  col_start = 4,
  row_input = 1
}

local m_Values = nil
local m_M = nil
local m_Mx = nil
local m_Mr = nil
local m_row_headers = nil
local m_col_headers = nil

-------------------------------------------------------------------------------
-- Initialisation
--
-- @function [parent=#Solver] new
-- @param #table M
-- @param #table row_headers
-- @param #table col_headers
--
-- @return #Solver
--
function Solver.new(M, row_headers, col_headers)
  m_M = M
  m_row_headers = row_headers
  m_col_headers = col_headers
  return Solver
end
-------------------------------------------------------------------------------
-- Return prepared matrix
--
-- @function [parent=#Solver] getMx
--
-- @return #table
--
function Solver.getMx()
  return m_Mx
end

-------------------------------------------------------------------------------
-- Return initial matrix
--
-- @function [parent=#Solver] getM
--
-- @return #table
--
function Solver.getM()
  return m_M
end

-------------------------------------------------------------------------------
-- Return result matrix
--
-- @function [parent=#Solver] getMr
--
-- @return #table
--
function Solver.getMr()
  return m_Mr
end

-------------------------------------------------------------------------------
-- format
--
-- @function [parent=#Solver] format
-- @param #string message
--
function Solver.format(message)
  if message == nil then message = "nil" end
  local size = string.len(message)
  if size > Solver.debug_col then
    return string.sub(message, 1, Solver.debug_col)
  elseif size < Solver.debug_col then
    return string.rep(" ",Solver.debug_col-size)..message
  end
  return message
end

-------------------------------------------------------------------------------
-- Print
--
-- @function [parent=#Solver] print
-- @param #Object object
-- @param #number xrow
-- @param #number xcol
--
function Solver.print(object, xrow, xcol)
  if object ~= nil and Solver.debug then
    if type(object) == "string" then
      print(object)
    else
      -- le tableau
      for irow,row in pairs(object) do
        -- 1 ere ligne
        if irow == Solver.row_input + 1 then
          if m_col_headers ~= nil then
            local message = ""
            if m_row_headers ~= nil then
              message = string.format("%s %s %s", message, Solver.format(""), "|")
            end
            for icol=1, (#m_col_headers) do
              message = string.format("%s %s %s", message, Solver.format(m_col_headers[icol]), "|")
            end
            local line = string.rep("-",(Solver.debug_col+3)*(#row+1))
            print(line)
            print(message)
            print(line)
          end
        end
        -- ligne
        local message = ""
        local separator = "|"
        if irow == xrow then separator = "<" end
        if m_row_headers ~= nil then
          message = string.format("%s %s %s", message, Solver.format(m_row_headers[irow]), separator)
        end
        
        for icol,cell_value in pairs(row) do
          separator = "|"
          if irow == xrow or icol == xcol then separator = "<" end
          if math.abs(cell_value) < 0.001 then cell_value = 0 end
          message = string.format("%s %s %s", message, Solver.format(cell_value), separator)
        end
        
        print(message)
      end
      local line = string.rep("=",(Solver.debug_col+3)*(#object[1]+1))
      print(line)
    end
  end
end
-------------------------------------------------------------------------------
-- Clone la matrice
--
-- @function [parent=#Solver] clone
-- @param #table M
--
-- @return #number
--
function Solver.clone(M)
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
-- Insert une ligne dans la matrice
--
-- @function [parent=#Solver] insert
-- @param #string row_name
-- @param #table values
--
function Solver.insert(row_name, values)
  m_row_headers[row_name] = true
  m_Values[row_name] = values
  for key, value in pairs(values) do
    m_col_headers[key] = true
  end
end

-------------------------------------------------------------------------------
-- Prepare la matrice
--
-- @function [parent=#Solver] prepare
-- @param #table M
--
-- @return #table
--
function Solver.prepare(M)
  Solver.row_input = 1
  local Mx = Solver.clone(M)
  -- initialise les valeurs des produits par second
  for irow,row in pairs(Mx) do
    if irow > Solver.row_input then
      local E = Mx[irow][3]
      for icol,cell in pairs(row) do
        if icol > Solver.col_start then
          Mx[irow][icol] = cell / E
        end
      end
    end
  end
  local irow = 1
  local row = {}
  -- ajoute la ligne Z avec Z=-input
  for icol,cell in pairs(Mx[irow]) do
    table.insert(row, 0-Mx[Solver.row_input][icol])
  end
  table.insert(Mx, row)
  if m_row_headers ~= nil then
    table.insert(m_row_headers, "Z")
  end
  return Mx
end

-------------------------------------------------------------------------------
-- Finalise la matrice
--
-- @function [parent=#Solver] finalize
-- @param #table M
--
-- @return #table
--
function Solver.finalize(M)
  -- finalize la ligne Z reinject le input Z=Z+input
  for icol,cell in pairs(M[#M]) do
    M[#M][icol] = M[#M][icol] + M[Solver.row_input][icol]
  end
  return M
end

-------------------------------------------------------------------------------
-- Ajoute la ligne State
--
-- @function [parent=#Solver] appendState
-- @param #table M
--
-- @return #table
--
function Solver.appendState(M)
  local srow = {}
  for irow,row in pairs(M) do
    if irow > Solver.row_input and irow < #M then
      for icol,cell in pairs(row) do
        if srow[icol] == nil then
          table.insert(srow,0)
        end
        if icol > Solver.col_start then
          if cell < 0 then
            srow[icol] = 2
          end
          if cell > 0 and srow[icol] ~= 2 then
            srow[icol] = 1
          end
        end
      end
    end
  end
  local zrow = M[#M]
  for icol,cell in pairs(zrow) do
    if icol > Solver.col_start then
      if cell > 0 and srow[icol] == 2 then
        srow[icol] = 3
      end
    end
  end
  table.insert(M,1, srow)
  if m_row_headers ~= nil then
    table.insert(m_row_headers,1, "State")
  end
  Solver.row_input = Solver.row_input + 1
  return M
end
-------------------------------------------------------------------------------
-- Retourne la colonne
--
-- @function [parent=#Solver] getCol
-- @param #table M
-- @param #number xrow
--
-- @return #number
--
function Solver.getCol(M, xrow)
  local row = M[xrow]
  local zrow = M[#M]
  local xcol = 0
  local max = 0
  -- on cherche la plus grande demande
  for icol,cell_value in pairs(row) do
    if icol > Solver.col_start and cell_value > 0 then
      local Z = M[#M][icol]-M[Solver.row_input][icol] -- valeur demandee (input - Z)
      local C = -Z/cell_value
      if C > max then
        max = C
        xcol = icol
      end 
    end
  end
  -- cas des voider
  if xcol == 0 then
    for icol,cell_value in pairs(row) do
      if icol > Solver.col_start and cell_value < 0 then
        local Z = M[#M][icol]-M[Solver.row_input][icol] -- valeur demandee (input - Z)
        local C = -Z/cell_value
        if C > max then
          max = C
          xcol = icol
        end 
      end
    end
  end
  Solver.print(string.format("%s: %s in %s,%s", "Best Ratio", max, xrow, xcol))
  return xcol
end

-------------------------------------------------------------------------------
-- Calcul de la ligne
--
-- @function [parent=#Solver] lineCompute
-- @param #table M
-- @param #number xrow ligne du meilleur pour le ratio
-- @param #number xcol colonne du meilleur pour le ratio
--
-- @return #table
--
function Solver.lineCompute(M, xrow, xcol)
  Solver.print(m_Mr, xrow, xcol)
  if m_Mr == nil or xrow == 0 or xcol == 0 then return M end
  local row = M[xrow]
  local P = M[xrow][2]
  local E = M[xrow][Solver.col_start-1] -- energy
  local Z = M[#M][xcol] -- valeur demandee Z
  local V = M[xrow][xcol] -- valeur produite
  local C = -Z/V -- coefficient
  local R = C/E -- nombre de recette necessaire
  M[xrow][Solver.col_start] = C
  M[xrow][1] = P * C / E
  for icol,cell_value in pairs(row) do
    if icol > Solver.col_start then
      local X = M[xrow][icol]
      M[#M][icol] = M[#M][icol] + X * P * C
    end
  end
  return M
end

-------------------------------------------------------------------------------
-- Resoud la matrice
--
-- @function [parent=#Solver] solve
--
-- @return #table
--
function Solver.solve()
  if m_M ~= nil then
    local num_loop = 0
    local icol = 0
    Solver.print(m_M)
    m_Mx = Solver.prepare(m_M)
    Solver.print(m_Mx)
    m_Mr = Solver.clone(m_Mx)
    for irow, row in pairs(m_Mr) do
      if irow > Solver.row_input and irow < #m_Mr then
        icol = Solver.getCol(m_Mr, irow)
        m_Mr = Solver.lineCompute(m_Mr, irow, icol)
        num_loop = num_loop + 1
      end
    end
    m_Mr = Solver.finalize(m_Mr)
    m_Mr = Solver.appendState(m_Mr)
    Solver.print(m_Mr)
    Solver.print(string.format("End in %s loop",num_loop))
    return m_Mr
  end
end


return Solver