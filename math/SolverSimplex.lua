---
-- Description of the module.
-- @module Solver
--
local Solver = {
  -- single-line comment
  classname = "HMSolver",
  isTax = false,
  max = false,
  debug = false,
  debug_col = 8,
  row_input = 2,
  col_start = 5,
  col_R = 2,
  col_P = 3,
  col_E = 4,
  col_C = 5
}

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
-- Calcul pivot de gauss
--
-- @function [parent=#Solver] pivot
-- @param #table M
-- @param #number xrow
-- @param #number xcol
--
-- @return #table
--
function Solver.pivot(M, xrow, xcol)
  Solver.print(M, xrow, xcol)
  local Mx = {}
  local pivot_value = M[xrow][xcol]
  for irow,row in pairs(M) do
    Mx[irow]={}
    if irow > Solver.row_input then
      for icol,cell_value in pairs(row) do
        if icol >= Solver.col_start then
          if irow == xrow then
            --Transformation de la ligne pivot : elle est divisee par l’element pivot
            Mx[irow][icol] = cell_value/pivot_value
          elseif icol == xcol then
            --Transformation de la colonne pivot : toutes les cases sauf la case pivot deviennent zero.
            Mx[irow][icol] = 0
          else
            local B = M[irow][xcol]
            local D = M[xrow][icol]
            Mx[irow][icol] = cell_value - ( B * D ) / pivot_value
          end
        else
          Mx[irow][icol] = cell_value
        end
      end
    else
      for icol,cell_value in pairs(row) do
        Mx[irow][icol] = cell_value
      end
    end
  end
  Mx[xrow][1] = M[1][xcol]
  Mx[1][xcol] = M[xrow][1]
  return Mx
end

-------------------------------------------------------------------------------
-- Retourne le pivot
--
-- @function [parent=#Solver] getPivot
-- @param #table M
--
-- @return #table
--
function Solver.getPivot(M)
  local max_z_value = 0
  local xcol = nil
  local min_ratio_value = 0
  local xrow = nil
  local last_row = M[#M]
  -- boucle sur la derniere ligne nommee Z
  for icol,z_value in pairs(last_row) do
    -- on exclus les premieres colonnes
    if icol > Solver.col_start then
      if z_value > max_z_value then
        -- la valeur repond au critere, la colonne est eligible
        -- on recherche le ligne
        min_ratio_value = nil
        for irow, current_row in pairs(M) do
          local x_value = M[irow][icol]
          -- on n'utilise pas la derniere ligne
          -- seule les cases positives sont prises en compte
          if irow > Solver.row_input and irow < #M and x_value > 0 then
            -- calcul du ratio base / x
            local c_value = M[irow][Solver.col_start]
            local bx_ratio = c_value/x_value
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
  return true, xcol, xrow
end

-------------------------------------------------------------------------------
-- Prepare la matrice
--
-- @function [parent=#Solver] prepare
--
-- @return #table
--
function Solver.prepare()
  -- ajoute la ligne Z
  local irow = 1
  -- prepare les headers
  local Mx = Solver.clone(m_M)
  
  if Solver.isTax then
    -- ajoute la colonne Tax
    for irow,row in pairs(Mx) do
      if irow == 1 then
        table.insert(Mx[1], {name="T", type="none"})
      elseif irow <= Solver.row_input or irow == #Mx then
        table.insert(row,0)
      else
        table.insert(row,-1)
      end
      Mx[irow] = row
    end
  end
  -- ajoute les recettes d'ingredient
  -- initialise l'analyse
  local ckeck_cols = {}
  for icol,_ in pairs(Mx[1]) do
    ckeck_cols[icol] = true
  end
  for irow,row in pairs(Mx) do
    if irow > Solver.row_input and irow < #Mx then
      for icol,cell in pairs(row) do
        if icol > Solver.col_start then
          -- si une colonne est un produit au moins une fois on l'exclus
          if cell > 0 then
            ckeck_cols[icol] = false
          end
        else
          ckeck_cols[icol] = false
        end
      end
    end
  end
  -- ajout des faux recipe
  local index = 1
  for xcol,check in pairs(ckeck_cols) do
    if check then
      local row = {}
      for icol,header in pairs(Mx[1]) do
        if header.name == "B" then
          table.insert(row, Mx[1][xcol])
        else
          if icol == Solver.col_start then
            --table.insert(row,math.pow(10,index)*10) -- important ne pas changer
            table.insert(row,10*index) -- important ne pas changer
          elseif icol == xcol then
            table.insert(row,1)
          else
            table.insert(row,0)
          end
        end
      end
      table.insert(Mx, #Mx,row)
      index = index + 1
    end
  end
  if Solver.isTax then
    -- valeur TAX
    Mx[#Mx-1][Solver.col_start] = 1
  end
  -- ajoute les row en colonne
  local num_row = rawlen(m_M)-Solver.row_input-1
  local num_col = rawlen(Mx[1])
  for xrow=1, num_row do
    for irow,row in pairs(Mx) do
      if irow == 1 then
        -- ajoute le header
        Mx[irow][num_col+xrow] = Mx[xrow+Solver.row_input][1];
      else
        -- ajoute les valeurs
        if irow == xrow + Solver.row_input then
          Mx[irow][num_col+xrow] = 1
        else
          Mx[irow][num_col+xrow] = 0
        end
      end
    end
  end
  
  local row = {}
  -- initialise la ligne Z avec Z=input
  for icol,cell in pairs(Mx[Solver.row_input]) do
    if icol > Solver.col_start then
      Mx[#Mx][icol] = cell
    end
  end

  return Mx
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
        if icol > Solver.col_start then
          if cell < 0 then
            srow[icol] = 2
          end
          if cell > 0 and srow[icol] ~= 2 then
            srow[icol] = 1
          end
        end
        if srow[icol] == nil then
          table.insert(srow,0)
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
-- Calcul de la ligne
--
-- @function [parent=#Solver] lineCompute
-- @param #table M
--
-- @return #table
--
function Solver.lineCompute(Mx, xrow)
  if Mx == nil or xrow == 0 then return Mx end
  local row = Mx[xrow]
  local R = row[Solver.col_R]
  local E = row[Solver.col_E]
  
  for icol,cell_value in pairs(row) do
    if cell_value ~= 0 and icol > Solver.col_start then
      local Z = Mx[#Mx][icol] -- valeur demandee Z
      local X = cell_value

      local C = -Z/X
      if C > 0 and C > Mx[xrow][Solver.col_C] then
        Mx[xrow][Solver.col_C] = C
        Mx[xrow][Solver.col_P] = R * E / C
      end
    end
  end
  
  local P = Mx[xrow][Solver.col_P]
  local C = Mx[xrow][Solver.col_start]
  for icol,cell_value in pairs(row) do
    if cell_value ~= 0 and icol > Solver.col_start then
      local Z = Mx[#Mx][icol] -- valeur demandee Z
      local X = cell_value
      -- calcul du Z
      Mx[#Mx][icol] = Z + X * P * C
    end
  end
  return Mx
end

-------------------------------------------------------------------------------
-- Calcul du tableau
--
-- @function [parent=#Solver] tableCompute
-- @param #table Mx matrix finale
-- @param #table Mi matrix intermediaire
--
-- @return #table
--
function Solver.tableCompute(Mx, Mi)
  if Mx == nil then return Mx end
  -- preparation de la colonne R et P
  for irow,_ in pairs(Mx) do
    if irow > Solver.row_input and irow < #Mx then
      -- colonne correspondant à la recette
      local icol = #Mx[1] + irow - Solver.row_input
      if Solver.isTax then icol = icol + 1 end
      Mx[irow][Solver.col_R] = - Mi[#Mi][icol] -- moins la valeur affichee dans Z
      Mx[irow][Solver.col_P] = 0
    end
  end
  -- preparation input
  -- ajoute la ligne Z avec Z=-input
  for icol,cell in pairs(Mx[Solver.row_input]) do
    if icol > Solver.col_start then
      Mx[#Mx][icol] = 0-cell
    end
  end
  
    -- initialise les valeurs des produits par second
  for irow,row in pairs(Mx) do
    if irow > Solver.row_input and irow < #Mx then
      local E = Mx[irow][Solver.col_E]
      for icol,cell in pairs(row) do
        if icol > Solver.col_start then
          Mx[irow][icol] = cell / E
        end
      end
    end
  end
  
  -- calcul du resultat
  for irow,_ in pairs(Mx) do
    if irow > Solver.row_input and irow < #Mx then
      Mx = Solver.lineCompute(Mx, irow)
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
    m_runtime = {}
    table.insert(m_runtime, {name="Initial", matrix=m_M})
    m_Mi = Solver.prepare()
    table.insert(m_runtime, {name="Prepare", matrix=m_Mi})
    local loop, xcol, xrow
    loop = true
    while loop do
      loop, xcol, xrow = Solver.getPivot(m_Mi)
      if loop then
        Solver.print(string.format("Pivot= %s,%s",xcol, xrow))
        table.insert(m_runtime, {name="Step "..num_loop, matrix=m_Mi, pivot={x=xcol,y=xrow}})
        m_Mi = Solver.pivot(m_Mi, xrow, xcol)
      else
        table.insert(m_runtime, {name="Last", matrix=m_Mi})
        Solver.print(m_Mi)
      end
      num_loop = num_loop + 1
    end
    -- finalisation
    m_Mr = Solver.clone(m_M)
    m_Mr = Solver.tableCompute(m_Mr, m_Mi)
    m_Mr = Solver.finalize(m_Mr)
    m_Mr = Solver.appendState(m_Mr)
    table.insert(m_runtime, {name="final", matrix=m_Mr})
    Solver.print(m_Mr)
    return m_Mr
  end
end

return Solver