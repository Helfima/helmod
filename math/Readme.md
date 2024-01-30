# Solver Matrix

Current Solver:
* Matrix.lua: Contain class of Matrix
* SolverMatrix.lua: Common code of solvers
* SolverMatrixAlgebra.lua: Specifique code of Algebra calculation
* SolverMatrixSimplex.lua: Specifique code of Simplex method calculation

# Classes

## Matrix
Container for all informations
* field objectives is the input value, key column/value
* field objective_values is the input value, index column/value, is use with icol value in the code

```
---@class Matrix
---@field columns {[integer] : MatrixHeader}
---@field headers {[integer] : MatrixHeader}
---@field rows {[integer] : {[integer] : number}}
---@field columnIndex {[string] : integer}
---@field parameters {[integer] : MatrixRowParameters}
---@field objectives {[string] : number}
---@field objective_values {[integer] : number}
```

## MatrixHeader
Header of row or column
```
---@class MatrixHeader
---@field index uint
---@field key string
---@field type string
---@field name string
---@field sysname string
---@field tooltip string
---@field is_ingredient boolean
---@field product table
```

## MatrixRow
Row of matrix
```
---@class MatrixRow
---@field type string
---@field name string
---@field tooltip string
---@field header MatrixHeader
---@field columns {[integer] : MatrixHeader}
---@field values {[integer] : number}
---@field columnIndex {[string] : integer}
```

## MatrixRowParameters
Parameters on recipe of row
This stores all values for a recipe
```
---@class MatrixRowParameters
---@field base string
---@field contraint table
---@field factory_count number
---@field factory_speed number
---@field recipe_count number
---@field recipe_production number
---@field recipe_energy number
---@field coefficient number
```

# Matrix Debugger in factorio

To active the debugger: find it in the menu Settings/Mod Settings/Map, in helmod section enable "Active the debug solver"

After to see something use refresh in helmod to generate cache of matrix (only need one time)

Click on Open debug button

![Debugger view in factorio](/math/solver_matrix.png)

# Simplex code algorithm

1. Prepare initial matrix `SolverMatrix.get_block_matrix(block, parameters)`
1. Inject objectives in matrix `SolverMatrix:prepare_z_and_objectives(matrix, reverse)`
1. Start of program `SolverMatrixSimplex:solve_matrix(Mbase, debug, by_factory, time)`
1. Add ingredient recipes in rows and Inject initial recipes in columns `SolverMatrixSimplex:prepare(matrix)`
1. Search a pivot, greater positive value in row Z is the column, the greater division of coefficient bettween positive value of the colum is the row  `SolverMatrixSimplex:get_pivot(matrix)`
1. Apply Gaussian pivot `SolverMatrixSimplex:pivot(matrix, xrow, xcol)`
1. Loop at "Search a pivot" while a pivot found
1. Compute the final Matrix, copy the recipe result in the parameters and compute the % production on each recipe `SolverMatrixSimplex:table_compute(matrix, matrix_result)` and `SolverMatrixSimplex:line_compute(matrix, xrow)`
1. Finalize the row Z `SolverMatrix:finalize(matrix)`
1. Apply status on products/ingredients `SolverMatrix:apply_state(matrix)`
