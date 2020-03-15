---
-- Description of the module.
-- @module SolverAlgebra
--
SolverAlgebra = newclass(Solver,function(base, object)
  Solver.init(base, object)
end)

-------------------------------------------------------------------------------
-- Retourne la colonne
--
-- @function [parent=#SolverAlgebra] getCol
-- @param #table M
-- @param #number xrow
--
-- @return #number
--
function SolverAlgebra:getCol(M, xrow)
  local row = M[xrow]
  local zrow = M[#M]
  local xcol = 0
  local max = 0
  -- on cherche la plus grande demande
  for icol,cell_value in pairs(row) do
    if icol > self.col_start and cell_value > 0 then
      local Z = M[#M][icol]-M[self.row_input][icol] -- valeur demandee (input - Z)
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
      if icol > self.col_start and cell_value < 0 then
        local Z = M[#M][icol]-M[self.row_input][icol] -- valeur demandee (input - Z)
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
-- @function [parent=#SolverAlgebra] lineCompute
-- @param #table M
-- @param #number xrow ligne du meilleur pour le ratio
-- @param #number xcol colonne du meilleur pour le ratio
--
-- @return #table
--
function SolverAlgebra:lineCompute(M, xrow, xcol)
  if M == nil or xrow == 0 or xcol == 0 then return M end
  local row = M[xrow]
  local P = M[xrow][self.col_P]
  local E = M[xrow][self.col_E] -- energy
  local Z = M[#M][xcol] -- valeur demandee Z
  local V = M[xrow][xcol] -- valeur produite
  local C = -Z/V -- coefficient
  local R = C/E -- nombre de recette necessaire
  M[xrow][self.col_C] = C
  M[xrow][self.col_R] = P * C / E
  for icol,cell_value in pairs(row) do
    if icol > self.col_start then
      local X = M[xrow][icol]
      M[#M][icol] = M[#M][icol] + X * P * C
    end
  end
  return M
end

-------------------------------------------------------------------------------
-- Resoud la matrice
--
-- @function [parent=#SolverAlgebra] solve
--
-- @return #table
--
function SolverAlgebra:solve(Mbase)
  if Mbase ~= nil then
    local num_loop = 0
    local icol = 0
    local runtime = {}
    self:addRuntime(runtime, "Initial", Mbase)
    local Mstep = self:prepare(Mbase)
    self:addRuntime(runtime, "Prepare", Mstep)
    for irow, row in pairs(Mstep) do
      if irow > self.row_input and irow < #Mstep then
        icol = self:getCol(Mstep, irow)
        self:addRuntime(runtime, "Step "..num_loop, Mstep, {x=icol,y=irow})
        Mstep = self:lineCompute(Mstep, irow, icol)
        num_loop = num_loop + 1
      end
    end
    local Mr = self:finalize(Mstep)
    Mr = self:appendState(Mr)
    self:addRuntime(runtime, "final", Mr)
    return Mr, runtime
  end
end
