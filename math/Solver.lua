---
-- Description of the module.
-- @module Solver
--
Solver = newclass(function(base)
    base.debug_col = 11
    base.col_start = 9
    base.row_input = 2
    base.col_M = 2
    base.col_Cn = 3
    base.col_F = 4
    base.col_S = 5
    base.col_R = 6
    base.col_P = 7
    base.col_E = 8
    base.col_C = 9
end)

-------------------------------------------------------------------------------
-- Clone la matrice
--
-- @function [parent=#Solver] clone
-- @param #table M
--
-- @return #table
--
function Solver:clone(M)
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
function Solver:prepare(M)
    local Mx = self:clone(M)
    local irow = 1
    local row = {}
    -- ajoute la ligne Z avec Z=-input
    for icol,cell in pairs(Mx[self.row_input]) do
      if icol > self.col_start then
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
function Solver:finalize(M)
    -- finalize la ligne Z reinject le input Z=Z+input
    for icol,cell in pairs(M[#M]) do
      if icol > self.col_start then
        M[#M][icol] = M[#M][icol] + M[self.row_input][icol]
      end
    end
    return M
end

-------------------------------------------------------------------------------
-- Add runtime
--
-- @function [parent=#Solver] addRuntime
--
function Solver:addRuntime(debug, runtime, name, matrix, pivot)
    if debug == true then
        table.insert(runtime, {name=name, matrix=self:clone(matrix), pivot=pivot})
    end
end

-------------------------------------------------------------------------------
-- Ajoute la ligne State
--
-- @function [parent=#Solver] appendState
-- @param #table M
--
-- @return #table
--
-- state = 0 => produit
-- state = 1 => produit pilotant
-- state = 2 => produit restant
-- state = 3 => produit surplus

function Solver:appendState(M)
    local srow = {}
    for irow,row in pairs(M) do
      if irow > self.row_input and irow < #M then
        for icol,cell in pairs(row) do
          if srow[icol] == nil then
            table.insert(srow,0)
          end
          if icol > self.col_start then
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
      if icol > self.col_start then
        if cell > 0 and srow[icol] == 2 then
          srow[icol] = 3
        end
      end
    end
    srow[1] = {name="State", type="none"}
    table.insert(M, srow)
    return M
end
