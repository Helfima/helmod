Solver = require "math.Solver"

local index = 0
local M = {}
local Mx = {}
local row_headers = {}
local col_headers = {}

index = 1
M[index] = {}
M[index]["matrix"] = {}
M[index]["col_headers"] = {"R","P","E","C","pressure", "scap", "water1", "tank", "data", "water2", "iron", "steel", "water3"}
M[index]["row_headers"] = {"Input","R pressure", "R tank", "R steel", "R water2"}
M[index]["matrix"][1]={0,0,0,0,5,0,0,0,0,0,0,0,0}
M[index]["matrix"][2]={0,1,40,0,5,50,9900,-1,-5,-10000,0,0,0}
M[index]["matrix"][3]={0,1,3,0,0,0,0,1,0,0,-20,-5,0}
M[index]["matrix"][4]={0,1,16,0,0,0,0,0,0,0,-5,1,0}
M[index]["matrix"][5]={0,1,1,0,0,0,0,0,0,1,0,0,-1}

index = 2
M[index] = {}
M[index]["matrix"] = {}
M[index]["col_headers"] = {"R","P","E","C","plastic-bar", "coal", "petroleum-gas", "solid-fuel", "light-oil", "sulfuric-acid", "iron-plate", "sulfur", "water", "lubricant", "heavy-oil", "crude-oil"}
M[index]["row_headers"] = {"Input","R plastic", "R solid-fuel", "R sulfuric-acid", "R lubricant", "R light-oil-cracking", "R heavy-oil-cracking", "R advanced-oil-processing"}
M[index]["matrix"][1]={0,0,0,0,30,0,0,30,0,1000,0,0,0,500,0,0}
M[index]["matrix"][2]={0,1,1,0,2,-1,-20,0,0,0,0,0,0,0,0,0}
M[index]["matrix"][3]={0,1,2,0,0,0,0,1,-10,0,0,0,0,0,0,0}
M[index]["matrix"][4]={0,1,1,0,0,0,0,0,0,50,-1,-5,-100,0,0,0}
M[index]["matrix"][5]={0,1,1,0,0,0,0,0,0,0,0,0,0,10,-10,0}
M[index]["matrix"][6]={0,1,2,0,0,0,20,0,-30,0,0,0,-30,0,0,0}
M[index]["matrix"][7]={0,1,2,0,0,0,0,0,30,0,0,0,-30,0,-40,0}
M[index]["matrix"][8]={0,1,5,0,0,0,55,0,45,0,0,0,-50,0,25,-100}

index = 3
M[index] = {}
M[index]["matrix"] = {}
M[index]["col_headers"] = {"R","P","E","C","steel-plate","iron-plate","iron-ore"}
M[index]["row_headers"] = {"Input","steel-plate","iron-plate","Z"}
M[index]["matrix"][1] = {0,0,0,0,5,0,0}
M[index]["matrix"][2] = {0,1,16,0,1,-5,0}
M[index]["matrix"][3] = {0,0.5,3.2,0,0,1,-1}

index = 4
M[index] = {}
M[index]["matrix"] = {}
M[index]["col_headers"] = {"R", "P", "E", "C", "plastic-bar1", "coal1", "petroleum-gas1", "water1","light-oil1","heavy-oil1","crude-oil1"}
M[index]["row_headers"] = {"input","R plastic-bar", "R light-oil-cracking", "R heavy-oil-cracking", "R advanced-oil-processing"}
M[index]["matrix"][1]={0,0,0,0,30,0,0,0,0,0,0}
M[index]["matrix"][2]={0,1,1,0,2,-1,-20,0,0,0,0}
M[index]["matrix"][3]={0,0.435897,2,0,0,0,20,-30,-30,0,0}
M[index]["matrix"][4]={0,0.294117,2,0,0,0,0,-30,30,-40,0}
M[index]["matrix"][5]={0,1,5,0,0,0,55,-50,45,25,-100}

index = 5
M[index] = {}
M[index]["matrix"] = {}
M[index]["col_headers"] = {"R","P","E","C","liquid-nitric-acid","gas-nitrogen-dioxide","water-purified","gas-oxygen","gas-nitrogen-monoxide","catalyst-metal-carrier","catalyst-metal-green","gas-ammonia","catalyst-metal-red","gas-hydrogen","gas-nitrogen","gas-compressed-air"}
M[index]["row_headers"] = {"Input","liquid-nitric-acid","gas-nitrogen-dioxide","gas-nitrogen-monoxide","gas-ammonia","air-separation","water-separation","angels-chemical-void-gas-hydrogen","Z"}
M[index]["matrix"][1]={0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0}
M[index]["matrix"][2]={0,1,2,0,50,-100,-50,0,0,0,0,0,0,0,0,0}
M[index]["matrix"][3]={0,1,2,0,0,100,0,-60,-40,0,0,0,0,0,0,0}
M[index]["matrix"][4]={0,1,2,0,0,0,0,-40,100,1,-1,-60,0,0,0,0}
M[index]["matrix"][5]={0,1,2,0,0,0,0,0,0,1,0,100,-1,-50,-50,0}
M[index]["matrix"][6]={0,0.1578947368421050878595224276068620383739471435546875,2,0,0,0,0,50,0,0,0,0,0,0,50,-100}
M[index]["matrix"][7]={0,0.99999999999999982236431605997495353221893310546875,4,0,0,0,-100,40,0,0,0,0,0,60,0,0}
M[index]["matrix"][8]={0,1,1,0,0,0,0,0,0,0,0,0,0,-100,0,0}

local test = 5
Solver.debug = true
Solver.new(M[test]["matrix"], M[test]["row_headers"], M[test]["col_headers"])
Solver.solve()

