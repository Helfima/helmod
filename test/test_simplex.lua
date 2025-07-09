Simplex = require "math.SolverSimplex"

function rawlen(M)
  local index = 0
  for _,_ in pairs(M) do
    index = index + 1
  end
  return index
end

local index = 0
local M = {}

index = 1
M[index] = {}
table.insert(M[index], {{index=1,name="B",type="none"},{index=1,name="R",type="none"},{index=1,name="P",type="none"},{index=1,name="E",type="none"},{index=1,name="C",type="none"},
                        {index=1,name="x1"},{index=1,name="x2"},{index=1,name="x3"},{index=1,name="x4"}})
table.insert(M[index], {{name="Input",type="none"},0,0,0,0,7,9,18,17})
table.insert(M[index], {{index=1,name="x5"},0,1,1,42,2,4,5,7})
table.insert(M[index], {{index=1,name="x6"},0,1,1,17,1,1,2,2})
table.insert(M[index], {{index=1,name="x7"},0,1,1,24,1,2,3,3})
table.insert(M[index], {{name="Z",type="none"},0,0,0,0,0,0,0,0})

index = 2
M[index] = {}
table.insert(M[index], {{index=1,name="B",type="none"},{index=1,name="R",type="none"},{index=1,name="P",type="none"},{index=1,name="E",type="none"},{index=1,name="C",type="none"},{index=1,name="nitrogen",type="fluid",is_ingredient=false,tooltip="nitrogen1\nProduit"},{index=1,name="filtration-media",type="item",is_ingredient=true,tooltip="filtration-media1\nIngredient"},{index=1,name="purest-nitrogen-gas",type="fluid",is_ingredient=false,tooltip="purest-nitrogen-gas1\nProduit"},{index=1,name="oxygen",type="fluid",is_ingredient=false,tooltip="oxygen1\nProduit"},{index=1,name="pressured-air",type="fluid",is_ingredient=false,tooltip="pressured-air1\nProduit"}})
table.insert(M[index], {{name="Input",type="none"},0,0,0,0,1000,0,0,0,0})
table.insert(M[index], {{name="nitrogen",type="recipe",tooltip="nitrogen\nRecette"},0,1,4,0,200,-1,-100,0,0})
table.insert(M[index], {{name="purest-nitrogen-gas",type="recipe",tooltip="purest-nitrogen-gas\nRecette"},0,1,5,0,50,0,60,20,-100})
table.insert(M[index], {{name="pressured-air",type="recipe",tooltip="pressured-air\nRecette"},0,1,1,0,0,0,0,0,20})
table.insert(M[index], {{name="Z",type="none"},0,0,0,0,0,0,0,0,0})

local test = 2
Simplex.debug = true
--Simplex.new(M[test])
Simplex.new(M[test])
Simplex.solve()

