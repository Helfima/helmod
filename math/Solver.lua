---
-- Description of the module.
-- @module Solver
--
local Solver = {
  -- single-line comment
  classname = "HMSolver",
  debug = false,
  debug_col = 8,
  col_start = 5,
  row_input = 2,
  col_R = 2,
  col_P = 3,
  col_E = 4,
  col_C = 5
}

local m_Values = nil
local m_M = nil
local m_Mi = nil
local m_Mr = nil
local m_runtime = nil

-------------------------------------------------------------------------------
-- Initialisation
--
-- @function [parent=#Solver] new
-- @param #table M
--
-- @return #Solver
--
function Solver.new(M)
  m_M = M
  return Solver
end

-------------------------------------------------------------------------------
-- Return runtime
--
-- @function [parent=#Solver] getRuntime
--
-- @return #table
--
function Solver.getRuntime()
  return m_runtime
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
-- Return intermediaire matrix
--
-- @function [parent=#Solver] getMi
--
-- @return #table
--
function Solver.getMi()
  return m_Mi
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
        -- ligne
        local message = ""
        local separator = "|"
        for icol,cell_value in pairs(row) do
          separator = "|"
          if (irow == xrow and icol >= Solver.col_start) or (icol == xcol and irow > Solver.row_input) then separator = "<" end
          if type(cell_value) == "table" then
            cell_value = cell_value.name
          else
            if math.abs(cell_value) < 0.001 then cell_value = 0 end
          end
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
-- Prepare la matrice
--
-- @function [parent=#Solver] prepare
-- @param #table M
--
-- @return #table
--
function Solver.prepare(M)
  local Mx = Solver.clone(M)
  -- initialise les valeurs des produits par second
  for irow,row in pairs(Mx) do
    if irow > Solver.row_input then
      local E = Mx[irow][Solver.col_E]
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
  for icol,cell in pairs(Mx[Solver.row_input]) do
    if icol > Solver.col_start then
      Mx[#Mx][icol] = 0-cell
    end
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
    if icol > Solver.col_start then
      M[#M][icol] = M[#M][icol] + M[Solver.row_input][icol]
    end
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
  srow[1] = {name="State", type="none"}
  table.insert(M, srow)
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
  Solver.print(M, xrow, xcol)
  if m_Mr == nil or xrow == 0 or xcol == 0 then return M end
  local row = M[xrow]
  local P = M[xrow][Solver.col_P]
  local E = M[xrow][Solver.col_E] -- energy
  local Z = M[#M][xcol] -- valeur demandee Z
  local V = M[xrow][xcol] -- valeur produite
  local C = -Z/V -- coefficient
  local R = C/E -- nombre de recette necessaire
  M[xrow][Solver.col_C] = C
  M[xrow][Solver.col_R] = P * C / E
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
    Solver.print(m_M)
    local num_loop = 0
    local icol = 0
    m_runtime = {}
    table.insert(m_runtime, {name="Initial", matrix=m_M})
    m_Mi = Solver.prepare(m_M)
    table.insert(m_runtime, {name="Prepare", matrix=Solver.clone(m_Mi)})
    for irow, row in pairs(m_Mi) do
      if irow > Solver.row_input and irow < #m_Mi then
        icol = Solver.getCol(m_Mi, irow)
        Solver.print(string.format("Pivot= %s,%s",irow, icol))
        table.insert(m_runtime, {name="Step "..num_loop, matrix=Solver.clone(m_Mi), pivot={x=icol,y=irow}})
        m_Mi = Solver.lineCompute(m_Mi, irow, icol)
        num_loop = num_loop + 1
      end
    end
    m_Mr = Solver.finalize(m_Mi)
    m_Mr = Solver.appendState(m_Mr)
    table.insert(m_runtime, {name="final", matrix=m_Mr})
    Solver.print(m_Mr)
    return m_Mr
  end
end


return Solver