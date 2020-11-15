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
-- @function [parent=#SolverAlgebra] getColUse
-- @param #table M
-- @param #number xrow
-- @param #boolean invert
-- invert = false => Search better product
-- invert = true => Search better ingredient
--
-- @return #number
--
function SolverAlgebra:getCol(M, xrow, invert)
  local row = M[xrow]
  local zrow = M[#M]
  local xcol = 0
  local max = 0
  local col_master = 0
  local col_exclude = 0
  if row[self.col_Cn] > 0 then
    col_master = row[self.col_Cn]
  end
  if row[self.col_Cn] < 0 then
    col_exclude = -row[self.col_Cn]
  end
  -- on cherche la plus grande demande
  for icol,cell_value in pairs(row) do
    if icol > self.col_start and ((invert ~= true and cell_value > 0) or (invert == true and cell_value < 0)) then
      local Z = M[#M][icol]-M[self.row_input][icol] -- valeur demandee (input - Z)
      local C = -Z/cell_value
      if (C > max and col_master == 0 and col_exclude == 0)
        or (col_master ~= 0 and col_master == icol)
        or (C > max and col_exclude ~= 0 and col_exclude ~= icol) then
        max = C
        xcol = icol
      end 
    end
  end
  -- cas des voider
  if xcol == 0 then
    for icol,cell_value in pairs(row) do
      if icol > self.col_start and ((invert ~= true and cell_value > 0) or (invert == true and cell_value < 0)) then
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
  M[xrow][self.col_C] = C
  M[xrow][self.col_R] = P * C
  for icol,cell_value in pairs(row) do
    if icol > self.col_start then
      local X = M[xrow][icol]
      M[#M][icol] = M[#M][icol] + X * P * C
    end
  end
  return M
end

-------------------------------------------------------------------------------
-- Calcul de la ligne par factory
--
-- @function [parent=#SolverAlgebra] lineComputeByFactory
-- @param #table M
-- @param #number xrow
-- @param #number time
--
-- @return #table
--
function SolverAlgebra:lineComputeByFactory(M, xrow, time)
  if M == nil or xrow == 0 then return M end
  local row = M[xrow]
  local F = M[xrow][self.col_F]
  local S = M[xrow][self.col_S]
  local P = M[xrow][self.col_P]
  local E = M[xrow][self.col_E] -- energy
  local C = 1 -- coefficient
  local R = time*F*S/E -- nombre de recette/seconde
  M[xrow][self.col_C] = C
  M[xrow][self.col_R] = R
  for icol,cell_value in pairs(row) do
    if icol > self.col_start then
      local X = M[xrow][icol]
      -- calcul Z
      M[#M][icol] = M[#M][icol] + X * R
    end
  end
  return M
end

-------------------------------------------------------------------------------
-- Check factory column
--
-- @function [parent=#SolverAlgebra] checkFactoryColumn
-- @param #table M
--
-- @return #number
--
function SolverAlgebra:checkFactoryColumn(Mx)
  for irow, row in pairs(Mx) do
    if row[self.col_F] > 0 then return row[self.col_F] end
  end
end

-------------------------------------------------------------------------------
-- Resoud la matrice
--
-- @function [parent=#SolverAlgebra] solve
--
-- @return #table
--
function SolverAlgebra:solve(Mbase, debug, by_factory, time)
  if Mbase ~= nil then
    local num_loop = 0
    local icol = 0
    local runtime = {}
    self:addRuntime(debug, runtime, "Initial", Mbase)
    local Mstep = self:prepare(Mbase)
    self:addRuntime(debug, runtime, "Prepare", Mstep)
    if by_factory == true then
      local start_row = 0
      for irow, row in pairs(Mstep) do
        if irow > self.row_input and irow < #Mstep then
          if row[self.col_F] > 0 then
            if start_row == 0 then start_row = irow end
            self:addRuntime(debug, runtime, "Step "..num_loop, Mstep, {x=self.col_F,y=irow})
            Mstep = self:lineComputeByFactory(Mstep, irow, time)
            num_loop = num_loop + 1
            if start_row > self.row_input + 1 then
              for xrow = start_row, self.row_input + 1, -1 do
                if Mstep[xrow][self.col_R] == 0 then
                  icol = self:getCol(Mstep, xrow, true)
                  self:addRuntime(debug, runtime, "Step "..num_loop, Mstep, {x=icol,y=xrow})
                  Mstep = self:lineCompute(Mstep, xrow, icol)
                  num_loop = num_loop + 1
                end
              end
            end
          elseif start_row ~= 0 then
            icol = self:getCol(Mstep, irow, false)
            self:addRuntime(debug, runtime, "Step "..num_loop, Mstep, {x=icol,y=irow})
            Mstep = self:lineCompute(Mstep, irow, icol)
            num_loop = num_loop + 1
          end
        end
      end
    else
      for irow, row in pairs(Mstep) do
        if irow > self.row_input and irow < #Mstep then
          icol = self:getCol(Mstep, irow, false)
          self:addRuntime(debug, runtime, "Step "..num_loop, Mstep, {x=icol,y=irow})
          Mstep = self:lineCompute(Mstep, irow, icol)
          num_loop = num_loop + 1
        end
      end
    end
    local Mr = self:finalize(Mstep)
    Mr = self:appendState(Mr)
    self:addRuntime(debug, runtime, "final", Mr)
    return Mr, runtime
  end
end
