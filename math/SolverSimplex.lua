---
-- Description of the module.
-- @module SolverSimplex
--

SolverSimplex = newclass(Solver,function(base, object)
  Solver.init(base, object)
end)

-------------------------------------------------------------------------------
-- Calcul pivot de gauss
--
-- @function [parent=#SolverSimplex] pivot
-- @param #table M
-- @param #number xrow
-- @param #number xcol
--
-- @return #table
--
function SolverSimplex:pivot(M, xrow, xcol)
  local Mx = {}
  local pivot_value = M[xrow][xcol]
  for irow,row in pairs(M) do
    Mx[irow]={}
    if irow > self.row_input then
      for icol,cell_value in pairs(row) do
        if icol >= self.col_start then
          if irow == xrow then
            --Transformation de la ligne pivot : elle est divisee par l'element pivot
            Mx[irow][icol] = cell_value/pivot_value
          elseif icol == xcol then
            --Transformation de la colonne pivot : toutes les cases sauf la case pivot deviennent zero.
            Mx[irow][icol] = 0
          else
            local B = M[irow][xcol]
            local D = M[xrow][icol]
            local value = cell_value - ( B * D ) / pivot_value
            if math.abs(value) < 1e-8 then
              Mx[irow][icol] = 0
            else
              Mx[irow][icol] = value
            end
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
-- @function [parent=#SolverSimplex] getPivot
-- @param #table M
--
-- @return #table
--
function SolverSimplex:getPivot(M)
  local max_z_value = 0
  local xcol = nil
  local min_ratio_value = 0
  local xrow = nil
  local last_row = M[#M]
  -- boucle sur la derniere ligne nommee Z
  for icol,z_value in pairs(last_row) do
    -- on exclus les premieres colonnes
    if icol > self.col_start then
      if z_value > max_z_value then
        -- la valeur repond au critere, la colonne est eligible
        -- on recherche le ligne
        min_ratio_value = nil
        for irow, current_row in pairs(M) do
          local x_value = M[irow][icol]
          -- on n'utilise pas la derniere ligne
          -- seule les cases positives sont prises en compte
          if irow > self.row_input and irow < #M and x_value > 0 then
            -- calcul du ratio base / x
            local c_value = M[irow][self.col_start]
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
-- @function [parent=#SolverSimplex] prepare
--
-- @return #table
--
function SolverSimplex:prepare(M)
  -- ajoute la ligne Z
  local irow = 1
  -- prepare les headers
  local Mx = self:clone(M)
  
  -- ajoute les recettes d'ingredient
  -- initialise l'analyse
  local ckeck_cols = {}
  for icol,_ in pairs(Mx[1]) do
    ckeck_cols[icol] = true
  end
  for irow,row in pairs(Mx) do
    if irow > self.row_input and irow < #Mx then
      for icol,cell in pairs(row) do
        if icol > self.col_start then
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
          if icol == self.col_start then
            --table.insert(row,math.pow(10,index)*10) -- important ne pas changer
            table.insert(row,1e4*index) -- important ne pas changer
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
  -- ajoute les row en colonne
  local num_row = rawlen(M)-self.row_input-1
  local num_col = rawlen(Mx[1])
  for xrow=1, num_row do
    for irow,row in pairs(Mx) do
      if irow == 1 then
        -- ajoute le header
        Mx[irow][num_col+xrow] = Mx[xrow+self.row_input][1];
      else
        -- ajoute les valeurs
        if irow == xrow + self.row_input then
          Mx[irow][num_col+xrow] = 1
        else
          Mx[irow][num_col+xrow] = 0
        end
      end
    end
  end
  
  -- initialise la ligne Z avec Z=input
  for icol,cell in pairs(Mx[self.row_input]) do
    if icol > self.col_start then
      Mx[#Mx][icol] = cell
    end
  end

  return Mx
end

-------------------------------------------------------------------------------
-- Calcul de la ligne
--
-- @function [parent=#SolverSimplex] lineCompute
-- @param #table M
--
-- @return #table
--
function SolverSimplex:lineCompute(Mx, xrow)
  if Mx == nil or xrow == 0 then return Mx end
  local row = Mx[xrow]
  local R = row[self.col_R]
  local E = row[self.col_E]
  
  for icol,cell_value in pairs(row) do
    if cell_value ~= 0 and icol > self.col_start then
      local Z = Mx[#Mx][icol] -- valeur demandee Z
      local X = cell_value

      local C = -Z/X
      if C > 0 and C > Mx[xrow][self.col_C] then
        Mx[xrow][self.col_C] = C
        Mx[xrow][self.col_P] = R * E / C
      end
    end
  end
  
  local P = Mx[xrow][self.col_P]
  local C = Mx[xrow][self.col_start]
  for icol,cell_value in pairs(row) do
    if cell_value ~= 0 and icol > self.col_start then
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
-- @function [parent=#SolverSimplex] tableCompute
-- @param #table Mx matrix finale
-- @param #table Mi matrix intermediaire
--
-- @return #table
--
function SolverSimplex:tableCompute(Mx, Mi)
  if Mx == nil then return Mx end
  -- preparation de la colonne R et P
  for irow,_ in pairs(Mx) do
    if irow > self.row_input and irow < #Mx then
      -- colonne correspondant a la recette
      local icol = #Mx[1] + irow - self.row_input
      Mx[irow][self.col_R] = - Mi[#Mi][icol] -- moins la valeur affichee dans Z
      Mx[irow][self.col_P] = 0
    end
  end
  -- preparation input
  -- ajoute la ligne Z avec Z=-input
  for icol,cell in pairs(Mx[self.row_input]) do
    if icol > self.col_start then
      Mx[#Mx][icol] = 0-cell
    end
  end
  
    -- initialise les valeurs des produits par second
  for irow,row in pairs(Mx) do
    if irow > self.row_input and irow < #Mx then
      local E = Mx[irow][self.col_E]
      for icol,cell in pairs(row) do
        if icol > self.col_start then
          Mx[irow][icol] = cell / E
        end
      end
    end
  end
  
  -- calcul du resultat
  for irow,_ in pairs(Mx) do
    if irow > self.row_input and irow < #Mx then
      Mx = self:lineCompute(Mx, irow)
    end
  end
  return Mx
end

-------------------------------------------------------------------------------
-- Resoud la matrice
--
-- @function [parent=#SolverSimplex] solve
--
-- @return #table
--
function SolverSimplex:solve(Mbase, debug, by_factory, time)
  if Mbase ~= nil then
    local num_loop = 0
    local runtime = {}
    self:addRuntime(debug, runtime, "Initial", Mbase)
    local Mstep = self:prepare(Mbase)
    self:addRuntime(debug, runtime, "Prepare", Mstep)
    local loop, xcol, xrow
    loop = true
    while loop do
      loop, xcol, xrow = self:getPivot(Mstep)
      if loop then
        self:addRuntime(debug, runtime, "Step "..num_loop, Mstep, {x=xcol,y=xrow})
        Mstep = self:pivot(Mstep, xrow, xcol)
      else
        self:addRuntime(debug, runtime, "Last", Mstep)
      end
      num_loop = num_loop + 1
    end
    -- finalisation
    local Mr = self:clone(Mbase)
    Mr = self:tableCompute(Mr, Mstep)
    Mr = self:finalize(Mr)
    Mr = self:appendState(Mr)
    self:addRuntime(debug, runtime, "final", Mr)
    return Mr, runtime
  end
end
