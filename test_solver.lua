Solver = require "core.Solver"

local index = 0
local M = {}
local Mx = {}
local row_headers = {}
local col_headers = {}

index = 1
row_headers[index] = {"Input","R pressure", "R tank", "R steel", "R water2"}
col_headers[index] = {"R","P","E","C","pressure", "scap", "water1", "tank", "data", "water2", "iron", "steel", "water3"}
M[index] = {}
M[index][1]={0,0,0,0,5,0,0,0,0,0,0,0,0}
M[index][2]={0,1,40,0,5,50,9900,-1,-5,-10000,0,0,0}
M[index][3]={0,1,3,0,0,0,0,1,0,0,-20,-5,0}
M[index][4]={0,1,16,0,0,0,0,0,0,0,-5,1,0}
M[index][5]={0,1,1,0,0,0,0,0,0,1,0,0,-1}

index = 2
row_headers[index] = {"Input","R plastic", "R solid-fuel", "R sulfuric-acid", "R lubricant", "R light-oil-cracking", "R heavy-oil-cracking", "R advanced-oil-processing"}
col_headers[index] = {"R","P","E","C","plastic-bar", "coal", "petroleum-gas", "solid-fuel", "light-oil", "sulfuric-acid", "iron-plate", "sulfur", "water", "lubricant", "heavy-oil", "crude-oil"}
M[index] = {}
M[index][1]={0,0,0,0,30,0,0,30,0,1000,0,0,0,500,0,0}
M[index][2]={0,1,1,0,2,-1,-20,0,0,0,0,0,0,0,0,0}
M[index][3]={0,1,2,0,0,0,0,1,-10,0,0,0,0,0,0,0}
M[index][4]={0,1,1,0,0,0,0,0,0,50,-1,-5,-100,0,0,0}
M[index][5]={0,1,1,0,0,0,0,0,0,0,0,0,0,10,-10,0}
M[index][6]={0,1,2,0,0,0,20,0,-30,0,0,0,-30,0,0,0}
M[index][7]={0,1,2,0,0,0,0,0,30,0,0,0,-30,0,-40,0}
M[index][8]={0,1,5,0,0,0,55,0,45,0,0,0,-50,0,25,-100}

local test = 2
--Simplex.new(M[test])
Solver.new(M[test], row_headers[test], col_headers[test])
Solver.solve()

