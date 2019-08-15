---
-- Description of the module.
-- @module Simplex
--
local Simplex = {
  -- single-line comment
  classname = "HMSimplex",
  debug = true,
  debug_col = 8,
  row_input = 1,
  col_start = 4
}

local m_M = nil
local m_Mx = nil
local m_Mi = nil
local m_Mr = nil
local m_row_headers = nil
local m_col_headers = nil
local m_row_headers2 = nil
local m_col_headers2 = nil

-------------------------------------------------------------------------------
-- Initialisation
--
-- @function [parent=#Simplex] new
-- @param #table M
-- @param #table row_headers
-- @param #table col_headers
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
-- @return #table
--
function Simplex.getMx()
  return m_Mx
end

-------------------------------------------------------------------------------
-- Return initial matrix
--
-- @function [parent=#Simplex] getM
--
-- @return #table
--
function Simplex.getM()
  return m_M
end

-------------------------------------------------------------------------------
-- Return intermediaire matrix
--
-- @function [parent=#Simplex] getMi
--
-- @return #table
--
function Simplex.getMi()
  return m_Mi
end

-------------------------------------------------------------------------------
-- Return result matrix
--
-- @function [parent=#Simplex] getMr
--
-- @return #table
--
function Simplex.getMr()
  return m_Mr
end
-------------------------------------------------------------------------------
-- Calcul pivot de gauss
--
-- @function [parent=#Simplex] pivot
-- @param #table M
-- @param #number xrow
-- @param #number xcol
--
-- @return #table
--
function Simplex.pivot(M, xrow, xcol)
  Simplex.print(M, xrow, xcol)
  local Mx = {}
  local pivot_value = M[xrow][xcol]
  for irow,row in pairs(M) do
    Mx[irow]={}
    if irow > Simplex.row_input then
      for icol,cell_value in pairs(row) do
        if icol >= Simplex.col_start then
          if irow == xrow then
            Mx[irow][icol] = cell_value/pivot_value
          elseif icol == xcol then
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
  if m_row_headers ~= nil then
    m_row_headers2[xrow] = m_col_headers2[xcol]
  end
  return Mx
end

-------------------------------------------------------------------------------
-- Retourne le pivot
--
-- @function [parent=#Simplex] getPivot
-- @param #table M
--
-- @return #table
--
function Simplex.getPivot(M)
  local max_z_value = 0
  local xcol = nil
  local min_ratio_value = 0
  local xrow = nil
  local last_row = M[rawlen(M)]
  -- boucle sur la derniere ligne nommee Z
  for icol,z_value in pairs(last_row) do
    -- on exclus les premieres colonnes
    if icol > Simplex.col_start then
      if z_value > max_z_value then
        -- la valeur repond au critere, la colonne est eligible
        -- on recherche le ligne
        min_ratio_value = nil
        for irow, current_row in pairs(M) do
          local x_value = M[irow][icol]
          -- on n'utilise pas la derniere ligne
          -- seule les cases positives sont prises en compte
          if irow > Simplex.row_input and irow < #M and x_value > 0 then
            -- calcul du ratio base / x
            local c_value = M[irow][Simplex.col_start]
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
  Simplex.print(string.format("%s: %s,%s", "Pivot", xrow, xcol))
  return true, xcol, xrow
end

-------------------------------------------------------------------------------
-- Prepare la matrice
--
-- @function [parent=#Simplex] prepare
--
-- @return #table
--
function Simplex.prepare()
  Simplex.row_input = 1
  -- ajoute la ligne Z
  local irow = 1
  local zrow = {}
  for icol,cell in pairs(m_M[irow]) do
    table.insert(zrow, 0)
  end
  table.insert(m_M, zrow)
  -- prepare les headers
  if m_col_headers ~= nil then
    table.insert(m_row_headers, "Z")
  
    m_col_headers2 = {}
    for _,col in pairs(m_col_headers) do
      table.insert(m_col_headers2,col)
    end
  end
  if m_row_headers ~= nil then
    m_row_headers2 = {}
    for _,row in pairs(m_row_headers) do
      table.insert(m_row_headers2,row)
    end
  end
  local Mx = Simplex.clone(m_M)
  
  -- ajoute la colonne Tax
  if m_row_headers ~= nil then
    table.insert(m_col_headers2, "T")
  end
  for irow,row in pairs(Mx) do
    if irow <= Simplex.row_input or irow == #Mx then
      table.insert(row,0)
    else
      table.insert(row,-1)
    end
    Mx[irow] = row
  end
  -- ajoute les recettes d'ingredient
  -- initialise l'analyse
  local ckeck_cols = {}
  for icol,_ in pairs(Mx[1]) do
    ckeck_cols[icol] = true
  end
  for irow,row in pairs(Mx) do
    if irow > Simplex.row_input and irow < #Mx then
      for icol,cell in pairs(row) do
        if icol > Simplex.col_start then
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
      for icol,_ in pairs(Mx[1]) do
        if icol == Simplex.col_start then
          table.insert(row,math.pow(10,index)*10)
        elseif icol == xcol then
          table.insert(row,1)
        else
          table.insert(row,0)
        end
      end
      table.insert(Mx, #Mx,row)
      if m_row_headers ~= nil then
        -- ajoute les headers des row
        table.insert(m_row_headers2, #m_row_headers2,m_col_headers2[xcol])
      end
      index = index + 1
    end
  end
  Mx[#Mx-1][Simplex.col_start] = 1
  -- ajoute les row en colonne
  local num_row = rawlen(m_M)-Simplex.row_input-1
  local num_col = rawlen(Mx[1])
  for xrow=1, num_row do
    for irow,row in pairs(Mx) do
      if irow == xrow + Simplex.row_input then
        Mx[irow][num_col+xrow] = 1
      else
        Mx[irow][num_col+xrow] = 0
      end
    end
    if m_row_headers ~= nil then
      -- ajoute les headers des row
      table.insert(m_col_headers2,m_row_headers[xrow + Simplex.row_input])
    end
  end
  
  local row = {}
  -- ajoute la ligne Z avec Z=input
  for icol,cell in pairs(Mx[Simplex.row_input]) do
    Mx[#Mx][icol] = cell
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
function Simplex.appendState(M)
  local srow = {}
  for irow,row in pairs(M) do
    if irow > Simplex.row_input and irow < #M then
      for icol,cell in pairs(row) do
        if srow[icol] == nil then
          table.insert(srow,0)
        end
        if icol > Simplex.col_start then
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
    if icol > Simplex.col_start then
      if cell > 0 and srow[icol] == 2 then
        srow[icol] = 3
      end
    end
  end
  table.insert(M,1, srow)
  if m_row_headers ~= nil then
    table.insert(m_row_headers,1, "State")
  end
  Simplex.row_input = Simplex.row_input + 1
  return M
end

-------------------------------------------------------------------------------
-- Clone la matrice
--
-- @function [parent=#Simplex] clone
-- @param #table M
--
-- @return #number
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
-- @param #number xrow
-- @param #number xcol
--
function Simplex.print(object, xrow, xcol)
  if object ~= nil and Simplex.debug then
    if type(object) == "string" then
      print(object)
    else
      -- le tableau
      for irow,row in pairs(object) do
        -- ligne header
        if irow == Simplex.row_input + 1 then
          if m_col_headers ~= nil then
            local message = ""
            if m_row_headers ~= nil then
              message = string.format("%s %s %s", message, Simplex.format("B"), "|")
            end
            if #object[1] > #m_col_headers then
              for icol=1, (#m_col_headers2) do
                  message = string.format("%s %s %s", message, Simplex.format(m_col_headers2[icol]), "|")
              end
            else
              for icol=1, (#m_col_headers) do
                message = string.format("%s %s %s", message, Simplex.format(m_col_headers[icol]), "|")
              end
            end
            local line = string.rep("-",(Simplex.debug_col+3)*(#row+1))
            print(line)
            print(message)
            print(line)
          end
        end
        -- ligne
        local message = ""
        local separator = "|"
        if m_row_headers ~= nil then
          if #object > #m_row_headers then
            message = string.format("%s %s %s", message, Simplex.format(m_row_headers2[irow]), separator)
          else
            message = string.format("%s %s %s", message, Simplex.format(m_row_headers[irow]), separator)
          end
        end
        
        for icol,cell_value in pairs(row) do
          separator = "|"
          if (irow == xrow and icol >= Simplex.col_start) or (icol == xcol and irow > Simplex.row_input) then separator = "<" end
          message = string.format("%s %s %s", message, Simplex.format(cell_value), separator)
        end
        
        print(message)
      end
      local line = string.rep("=",(Simplex.debug_col+3)*(#object[1]+1))
      print(line)
    end
  end
end

-------------------------------------------------------------------------------
-- Calcul de la ligne
--
-- @function [parent=#Simplex] lineCompute
-- @param #table M
--
-- @return #table
--
function Simplex.lineCompute(Mx, xrow)
  if Mx == nil or xrow == 0 then return Mx end
  local row = Mx[xrow]
  local R = row[1]
  local E = row[3]
  local C = row[4]
  for icol,cell_value in pairs(row) do
    if icol > Simplex.col_start then
      -- initialise les valeurs des produits par second
      Mx[xrow][icol] = cell_value / E
      -- calcul du Z
      local Z = Mx[#Mx][icol] -- valeur demandee Z
      Mx[#Mx][icol] = Z + Mx[xrow][icol] * C
    end
  end
  return Mx
end

-------------------------------------------------------------------------------
-- Calcul du tableau
--
-- @function [parent=#Simplex] tableCompute
-- @param #table Mx matrix finale
-- @param #table Mi matrix intermediaire
--
-- @return #table
--
function Simplex.tableCompute(Mx, Mi)
  if Mx == nil then return Mx end
  -- preparation ligne Z
  for icol,cell in pairs(Mx[#Mx]) do
    Mx[#Mx][icol] = 0
  end
  
  -- preparation de la colonne R et C
  for irow,_ in pairs(Mx) do
    if irow > Simplex.row_input and irow < #Mx then
      -- colonne correspondant à la recette
      local icol = #Mx[1] + 1 + irow - Simplex.row_input
      Mx[irow][1] = - Mi[#Mi][icol] -- moins la valeur affichee dans Z
      Mx[irow][4] = Mx[irow][3]*Mx[irow][1] -- C = R*E
    end
  end
  
  -- calcul du resultat
  for irow,_ in pairs(Mx) do
    if irow > Simplex.row_input and irow < #Mx then
      Mx = Simplex.lineCompute(Mx, irow)
    end
  end
  return Mx
end

-------------------------------------------------------------------------------
-- Finalise la matrice
--
-- @function [parent=#Simplex] finalize
-- @param #table M
--
-- @return #table
--
function Simplex.finalize(M)
  -- finalize la ligne Z reinject le input Z=Z+input
  for icol,cell in pairs(M[#M]) do
    M[#M][icol] = M[#M][icol] + M[Simplex.row_input][icol]
  end
  return M
end

-------------------------------------------------------------------------------
-- Resoud la matrice
--
-- @function [parent=#Simplex] solve
--
-- @return #table
--
function Simplex.solve()
  if m_M ~= nil then
    local num_loop = 0
    m_Mx = Simplex.prepare()
    Simplex.print(m_M)
    m_Mi = Simplex.clone(m_Mx)
    local loop, xcol, xrow
    loop = true
    while loop do
      loop, xcol, xrow = Simplex.getPivot(m_Mi)
      if loop then
        m_Mi = Simplex.pivot(m_Mi, xrow, xcol)
      end
      num_loop = num_loop + 1
    end
    Simplex.print(m_Mi)
    Simplex.print(string.format("End in %s loop",num_loop))
    -- finalisation
    m_Mr = Simplex.clone(m_M)
    m_Mr = Simplex.tableCompute(m_Mr, m_Mi)
    m_Mr = Simplex.appendState(m_Mr)
    Simplex.print(m_Mr)
    return m_Mr
  end
end

return Simplex