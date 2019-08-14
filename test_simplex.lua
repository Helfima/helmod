Simplex = require "core.SolverSimplex"

function printM(M)
  for irow,row in pairs(M) do
    local message = ""
    for icol,cell_value in pairs(row) do
      message = message .. cell_value .. "|"
    end
    
    print(message)
  end
  print("----------------------------------------------")
end

local index = 0
local M = {}
local Mx = {}
local row_headers = {}
local col_headers = {}

index = 1
row_headers[index] = {"x5", "x6", "x7"}
col_headers[index] = {"x1", "x2", "x3", "x4"}
M[index] = {}
M[index][1]={42,2,4,5,7}
M[index][2]={17,1,1,2,2}
M[index][3]={24,1,2,3,3}
M[index][4]={0,7,9,18,17}

index = 2
row_headers[index] = {"plastic", "petrol leger", "heavy oil", "petrol"}
col_headers[index] = {"plastic", "coal", "gas", "water", "leger", "lourd", "oil"}
M[index] = {}
M[index][1]={2,2,-1,-20,0,0,0,0}
M[index][2]={2,0,0,20,-30,-30,0,0}
M[index][3]={2,0,0,0,-30,30,-40,0}
M[index][4]={5,0,0,55,-50,45,25,-100}
M[index][5]={0,150,-75,-1500,0,0,0,0}

index = 3
row_headers[index] = {"plastic", "petrol leger", "heavy oil", "petrol"}
col_headers[index] = {"plastic", "coal", "gas", "water", "leger", "lourd", "oil"}
M[index] = {}
M[index][1]={2/-19,2,-1,-20,0,0,0,0}
M[index][2]={2/-40,0,0,20,-30,-30,0,0}
M[index][3]={2/-40,0,0,0,-30,30,-40,0}
M[index][4]={5/-35,0,0,55,-50,45,25,-100}
M[index][5]={0,2,0,0,0,0,0,0}

index = 4
row_headers[index] = {"R plastic", "R light oil", "R heavy oil", "R petrole", "R coal", "R water", "R crude", "tax"}
col_headers[index] = {"plastic", "coal", "gas", "water", "leger", "lourd", "crude", "tax"}
M[index] = {}
M[index][1]={0,2,-1,-20,0,0,0,0,-1}
M[index][2]={0,0,0,20,-30,-30,0,0,-1}
M[index][3]={0,0,0,0,-30,30,-40,0,-1}
M[index][4]={0,0,0,55,-50,45,25,-100,-1}
M[index][5]={10,0,1,0,0,0,0,0,0}
M[index][6]={100,0,0,0,1,0,0,0,0}
M[index][7]={1000,0,0,0,0,0,0,1,0}
M[index][8]={1,0,0,0,0,0,0,0,1}
M[index][9]={0,10,0,0,0,0,0,0,0}

index = 5
row_headers[index] = {"solid heavy", "solid light", "solid gas", "petrol2", "petrol1", "petrol3", "heavy", "light", "water", "crude", "coal", "steam", "tax"}
col_headers[index] = {"solid", "heavy", "light", "gas", "water", "oil", "coal", "steam", "tax"}
M[index] = {}
M[index][1]={0,1,-20,0,0,0,0,0,0,-1}
M[index][2]={0,1,0,-10,0,0,0,0,0,-1}
M[index][3]={0,1,0,0,-20,0,0,0,0,-1}
M[index][4]={0,0,25,45,55,-50,-100,0,0,-1}
M[index][5]={0,0,30,30,40,0,-100,0,0,-1}
M[index][6]={0,0,10,15,20,0,0,-10,-50,-1}
M[index][7]={0,0,-40,30,0,-30,0,0,0,-1}
M[index][8]={0,0,0,-30,20,-30,0,0,0,-1}
M[index][9]={100,0,0,0,0,1,0,0,0,0}
M[index][10]={10000,0,0,0,0,0,1,0,0,0}
M[index][11]={1000000,0,0,0,0,0,0,1,0,0}
M[index][12]={100000000,0,0,0,0,0,0,0,1,0}
M[index][13]={1,0,0,0,0,0,0,0,0,1}
M[index][14]={0,0,0,0,60,0,0,0,0,0}

index = 6
row_headers[index] = {"R petrol1", "R petrol2", "R petrol3", "R light oil", "R heavy oil"}
col_headers[index] = {"heavy", "light", "gas", "water", "oil", "coal", "steam"}
M[index] = {}
M[index][1]={5,0,0,45,0,-100,0,0}
M[index][2]={5,25,45,55,-50,-100,0,0}
M[index][3]={5,65,20,10,0,0,-10,-50}
M[index][4]={2,0,-30,20,-30,0,0,0}
M[index][5]={2,-40,30,0,-30,0,0,0}
M[index][6]={0,0,100,0,0,0,0,0}

index = 7
row_headers[index] = {"R bras", "R vert", "R gear", "R fer", "R fil","R tax"}
col_headers[index] = {"bras","p fer", "gear", "vert", "fil", "tax"}
M[index] = {}
M[index][1]={0,1,-1,-1,-1,0,-0.5}
M[index][2]={0,0,-1,0,1,-3,-0.5}
M[index][3]={0,0,-2,1,0,0,-0.5}
M[index][4]={10,0,1,0,0,0,0}
M[index][5]={100,0,0,0,0,1,0}
M[index][6]={1,0,0,0,0,0,1}
M[index][7]={0,100,0,0,0,0,0}

index = 8
row_headers[index] = {"R fuel", "R kovarex", "R uranium", "R fer", "R U"}
col_headers[index] = {"fuel","p fer", "u235", "u238", "uranium", "tax"}
M[index] = {}
M[index][1]={0,10,-10,-1,-19,0,-1}
M[index][2]={0,0,0,1,-3,0,-1}
M[index][3]={0,0,0,0.007,0.993,-10,-1}
M[index][4]={10,0,1,0,0,0,0}
M[index][5]={100,0,0,0,0,1,0}
M[index][6]={1,0,0,0,0,0,1}
M[index][7]={0,10,0,0,0,0,0}

index = 9
row_headers[index] = {"R plastic", "R light oil", "R heavy oil", "R petrole", "R water", "R crude", "tax"}
col_headers[index] = {"plastic", "coal", "gas", "water", "leger", "lourd", "crude", "tax"}
M[index] = {}
M[index][1]={0,2,-1,-20,0,0,0,0,-1}
M[index][2]={0,0,0,20,-30,-30,0,0,-1}
M[index][3]={0,0,0,0,-30,30,-40,0,-1}
M[index][4]={0,0,0,55,-50,45,25,-100,-1}
M[index][5]={100,0,0,0,1,0,0,0,0}
M[index][6]={1000,0,0,0,0,0,0,1,0}
M[index][7]={1,0,0,0,0,0,0,0,1}
M[index][8]={0,0,0,100,0,0,0,0,0}

index = 10
row_headers[index] = {"R pressure", "R tank", "R steel", "R water1", "R scrap", "R water2", "R iron", "tax"}
col_headers[index] = {"pressure", "scap", "water1", "tank", "data", "water2", "iron", "steel", "tax"}
M[index] = {}
M[index][1]={0,5,50,9900,-1,-5,-10000,0,0,-1}
M[index][2]={0,0,0,0,1,0,0,-20,-5,-1}
M[index][3]={0,0,0,0,0,0,0,-5,1,-1}
M[index][4]={0,0,0,1,0,0,-1,0,0,-1}
M[index][5]={100,0,1,0,0,0,0,0,0,0}
M[index][6]={1000,0,0,0,0,0,1,0,0,0}
M[index][7]={10000,0,0,0,0,0,0,1,0,0}
M[index][8]={1,0,0,0,0,0,0,0,0,1}
M[index][9]={0,5,0,0,0,0,0,0,0,0}

index = 11
row_headers[index] = {"Input","R pressure", "R tank", "R steel", "R water2"}
col_headers[index] = {"R","P","E","C","pressure", "scap", "water1", "tank", "data", "water2", "iron", "steel", "water3"}
M[index] = {}
M[index][1]={0,0,0,0,5,0,0,0,0,0,0,0,0}
M[index][2]={0,1,40,0,5,50,9900,-1,-5,-10000,0,0,0}
M[index][3]={0,1,3,0,0,0,0,1,0,0,-20,-5,0}
M[index][4]={0,1,16,0,0,0,0,0,0,0,-5,1,0}
M[index][5]={0,1,1,0,0,0,0,0,0,1,0,0,-1}

index = 12
row_headers[index] = {"Input","R plastic", "R solid-fuel", "R sulfuric-acid", "R lubricant", "R light-oil-cracking", "R heavy-oil-cracking", "R advanced-oil-processing"}
col_headers[index] = {"R","P","E","C","plastic-bar", "coal", "petroleum-gas", "solid-fuel", "light-oil", "sulfuric-acid", "iron-plate", "sulfur", "water", "lubricant", "heavy-oil", "crude-oil"}
M[index] = {}
M[index][1]={0,0,0,0,30,0,0,30,0,1000,0,0,0,500,0,0}
M[index][2]={0,0,1,1,2,-1,-20,0,0,0,0,0,0,0,0,0}
M[index][3]={0,0,1,2,0,0,0,1,-10,0,0,0,0,0,0,0}
M[index][4]={0,0,1,1,0,0,0,0,0,50,-1,-5,-100,0,0,0}
M[index][5]={0,0,1,1,0,0,0,0,0,0,0,0,0,10,-10,0}
M[index][6]={0,0,1,2,0,0,20,0,-30,0,0,0,-30,0,0,0}
M[index][7]={0,0,1,2,0,0,0,0,30,0,0,0,-30,0,-40,0}
M[index][8]={0,0,1,5,0,0,55,0,45,0,0,0,-50,0,25,-100}

local test = 12
--Simplex.new(M[test])
Simplex.new(M[test], row_headers[test], col_headers[test])
Simplex.solve()

