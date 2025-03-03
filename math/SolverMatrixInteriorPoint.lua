-------------------------------------------------------------------------------
---Description of the module.
---@class SolverMatrixInteriorPoint : SolverMatrix
SolverMatrixInteriorPoint = newclass(SolverMatrix, function(base, object)
    SolverMatrix.init(base, object)
end)

function SolverMatrixInteriorPoint:prepare(matrix)
    local matrix_clone = self:clone(matrix)

    -- Initialize the slack variables
    matrix_clone = self:initialize_slack_variables(matrix_clone)

    -- Initialize the dual variables
    matrix_clone = self:initialize_dual_variables(matrix_clone)

    -- Prepare Z and objectives as in other solvers
    self:prepare_z_and_objectives(matrix_clone, false)

    return matrix_clone
end

-------------------------------------------------------------------------------
--- Logger function for the interior point solver
---@param message string
---@param ...
function SolverMatrixInteriorPoint:log(message, ...)
    if true then
        local log_file = "helmod_interior_point.log"
        local formatted_message = string.format(message, ...)

        helpers.write_file(log_file, formatted_message .. "\n", true)
    end
end

-------------------------------------------------------------------------------
--- Log the current state of the matrix and variables
---@param matrix Matrix
---@param iteration number
function SolverMatrixInteriorPoint:log_state(matrix, iteration)
    self:log("=== Iteration %d ===", iteration)

    -- Log matrix dimensions
    self:log("Matrix dimensions: %d rows x %d columns", #matrix.rows, #matrix.columns)

    -- Log a sample of primal variables
    self:log("Primal variables sample:")
    for i = 1, math.min(5, #(matrix.x_variables or {})) do
        self:log("  x[%d] = %g", i, matrix.x_variables[i] or 0)
    end

    -- Log a sample of dual variables
    self:log("Dual variables sample:")
    for i = 1, math.min(5, #(matrix.dual_variables or {})) do
        self:log("  y[%d] = %g", i, matrix.dual_variables[i] or 0)
    end

    -- Log a sample of dual bound variables
    self:log("Dual bound variables sample:")
    for i = 1, math.min(5, #(matrix.dual_bounds or {})) do
        self:log("  z[%d] = %g", i, matrix.dual_bounds[i] or 0)
    end

    -- Log a sample of matrix values
    self:log("Matrix sample (first 3x3 corner):")
    for i = 1, math.min(3, #matrix.rows) do
        local row_str = "  "
        for j = 1, math.min(3, #matrix.columns) do
            row_str = row_str .. string.format("%10g ", matrix.rows[i][j] or 0)
        end
        self:log(row_str)
    end

    -- Log objective value if available
    if matrix.rows and matrix.rows[#matrix.rows] then
        local obj_val = 0
        for j = 1, #matrix.columns do
            if matrix.objective_values and matrix.objective_values[j] then
                obj_val = obj_val + (matrix.objective_values[j] * (matrix.x_variables[j] or 0))
            end
        end
        self:log("Current objective value estimate: %g", obj_val)
    end

    self:log("") -- Empty line for readability
end

-------------------------------------------------------------------------------
---Initialize slack variables to convert inequalities to equalities
---@param matrix Matrix
---@return Matrix
function SolverMatrixInteriorPoint:initialize_slack_variables(matrix)
    local rows = matrix.rows
    local columns = matrix.columns
    local headers = matrix.headers

    -- Add new columns for slack variables
    local slack_columns = {}
    for i = 1, #rows - 1 do -- Exclude Z row
        local slack_header = MatrixHeader("slack", "s" .. i, "Slack variable " .. i)
        slack_header.key = "slack" .. i
        slack_header.is_ingredient = false
        table.insert(slack_columns, slack_header)
    end

    -- Add the slack columns to the matrix
    for _, slack_header in ipairs(slack_columns) do
        matrix:add_column(slack_header)
    end

    -- Set the slack variable values in each row
    for i = 1, #rows - 1 do -- Exclude Z row
        for j = 1, #slack_columns do
            local slack_header = slack_columns[j]
            local icol = matrix:get_column_index(slack_header)
            if icol > 0 then
                if i == j then
                    rows[i][icol] = 1 -- Identity matrix pattern for slack variables
                else
                    rows[i][icol] = 0
                end
            end
        end
    end

    -- Set slack variables in Z row to 0
    local zrow = rows[#rows]
    for _, slack_header in ipairs(slack_columns) do
        local icol = matrix:get_column_index(slack_header)
        if icol > 0 then
            zrow[icol] = 0
        end
    end

    return matrix
end

-------------------------------------------------------------------------------
---Initialize dual variables for the interior point method
---@param matrix Matrix
---@return Matrix
function SolverMatrixInteriorPoint:initialize_dual_variables(matrix)
    -- Store dual variables separately to avoid modifying matrix structure
    matrix.dual_variables = {}

    -- Initialize dual variables for constraints
    for i = 1, #matrix.rows do
        matrix.dual_variables[i] = 1.0 -- Start with 1.0 for all dual variables
    end

    -- Initialize dual variables for bounds (can be stored directly in matrix.dual_bounds)
    matrix.dual_bounds = {}
    for i = 1, #matrix.columns do
        matrix.dual_bounds[i] = 1.0 -- Start with 1.0 for all bound variables
    end

    return matrix
end

-------------------------------------------------------------------------------
---Compute an initial feasible point
---@param matrix Matrix
---@return Matrix, table
function SolverMatrixInteriorPoint:compute_initial_point(matrix)
    local rows = matrix.rows
    local columns = matrix.columns

    self:log("Computing initial feasible point")

    -- Initialize primal variables (stored in x_variables)
    matrix.x_variables = {}

    -- Initial values for all variables - use modest values
    for i = 1, #columns do
        matrix.x_variables[i] = 0.1 -- Start with small positive values
    end

    self:log("Initial primal variables set to 0.1")

    -- Ensure the initial point is strictly feasible
    for iter = 1, 5 do -- Limit to just a few iterations
        self:log("Feasibility adjustment iteration %d", iter)
        self:adjust_for_feasibility(matrix)
    end

    return matrix
end

-------------------------------------------------------------------------------
---Adjust the current point to improve feasibility
---@param matrix Matrix
function SolverMatrixInteriorPoint:adjust_for_feasibility(matrix)
    local rows = matrix.rows
    local x = matrix.x_variables

    -- Calculate maximum constraint violation
    local max_violation = 0
    local worst_constraint = 0

    for i = 1, #rows - 1 do
        local constraint_value = 0
        for j = 1, #matrix.columns do
            constraint_value = constraint_value + (rows[i][j] or 0) * (x[j] or 0)
        end

        if constraint_value < 0 and -constraint_value > max_violation then
            max_violation = -constraint_value
            worst_constraint = i
        end
    end

    self:log("Maximum constraint violation: %g (constraint %d)", max_violation, worst_constraint)

    -- If there's a significant violation, adjust variables
    if max_violation > 0.01 and worst_constraint > 0 then
        for j = 1, #matrix.columns do
            local a_ij = rows[worst_constraint][j] or 0

            -- If this variable appears with positive coefficient, increase it
            if a_ij > 0 then
                -- Avoid extreme adjustments with a cap
                local adjustment = math.min(1.0, max_violation / a_ij)
                x[j] = (x[j] or 0) + adjustment

                self:log("Adjusted x[%d] by +%g to %g", j, adjustment, x[j])
                break -- Just adjust one variable per iteration
            end
        end
    else
        self:log("No significant constraint violations found")
    end

    -- Ensure all variables have reasonable bounds
    for j = 1, #x do
        -- Cap variables to avoid extreme values
        if x[j] > 10.0 then
            self:log("Capping x[%d] from %g to 10.0", j, x[j])
            x[j] = 10.0
        end
    end
end

-------------------------------------------------------------------------------
---Solve the matrix using interior point method
---@param matrix_base Matrix
---@param debug boolean
---@param by_factory boolean
---@param time number
---@return Matrix, table
function SolverMatrixInteriorPoint:solve_matrix(matrix_base, debug, by_factory, time)
    if matrix_base ~= nil then
        -- Start a new log file
        local log_file = "helmod_interior_point.log"

        helpers.write_file(log_file, "", false)
        helpers.write_file(log_file, "Interior Point Solver Log\n", true)
        helpers.write_file(log_file, "=======================\n", true)
        helpers.write_file(log_file, "\n", true)

        -- Log initial information
        self:log("Starting interior point solver")
        self:log("Debug mode: %s", debug and "true" or "false")
        self:log("By factory: %s", by_factory and "true" or "false")
        self:log("Time factor: %g", time or 0)

        local runtime = {}
        self:add_runtime(debug, runtime, "Initial", matrix_base)

        -- Prepare the matrix
        self:log("Preparing matrix...")
        local matrix = self:prepare(matrix_base)
        self:log("Matrix prepared with %d rows and %d columns", #matrix.rows, #matrix.columns)
        self:add_runtime(debug, runtime, "Prepare", matrix)

        -- Compute initial point
        self:log("Computing initial point...")
        matrix = self:compute_initial_point(matrix)
        self:log("Initial point computed")
        self:log_state(matrix, 0)
        self:add_runtime(debug, runtime, "Initial Point", matrix)

        -- Parameters for the algorithm
        local mu = 0.1      -- Initial barrier parameter
        local epsilon = 1e-6 -- Convergence tolerance
        local max_iter = 100 -- Maximum iterations

        self:log("Algorithm parameters:")
        self:log("  Initial mu: %g", mu)
        self:log("  Epsilon: %g", epsilon)
        self:log("  Max iterations: %d", max_iter)

        -- Main loop
        for iter = 1, max_iter do
            self:log("Starting iteration %d", iter)

            -- Compute search direction using Newton's method
            self:log("Computing Newton direction...")
            local dx, dy, dz = self:compute_newton_direction(matrix, mu)

            -- Log search directions
            self:log("Search direction samples:")
            for i = 1, math.min(3, #dx) do
                self:log("  dx[%d] = %g", i, dx[i] or 0)
            end

            -- Check for convergence
            local converged = self:check_convergence(matrix, dx, dy, dz, epsilon)
            self:log("Convergence check: %s", converged and "CONVERGED" or "not converged")

            if converged then
                self:log("Algorithm converged after %d iterations", iter)
                self:add_runtime(debug, runtime, "Converged", matrix)
                break
            end

            -- Compute step size
            self:log("Computing step size...")
            local alpha = self:compute_step_size(matrix, dx, dy, dz)
            self:log("Step size alpha = %g", alpha)

            -- Update variables
            self:log("Updating variables...")
            self:update_variables(matrix, dx, dy, dz, alpha)

            -- Update barrier parameter adaptively
            mu = self:update_barrier_parameter(matrix, dx, dy, dz)
            self:log("Updated mu = %g", mu)

            -- Log state after update
            self:log_state(matrix, iter)

            self:add_runtime(debug, runtime, "Iteration " .. iter, matrix)
        end

        -- Extract solution and finalize
        self:log("Extracting solution...")
        local matrix_result = self:extract_solution(matrix_base, matrix)

        self:log("Finalizing matrix...")
        matrix_result = self:finalize(matrix_result)

        self:log("Applying state...")
        matrix_result = self:apply_state(matrix_result)

        -- Log final solution details
        self:log("Final solution:")
        for irow = 1, #matrix_result.parameters do
            local params = matrix_result.parameters[irow]
            if params then
                self:log("Row %d: recipe_count = %g, recipe_production = %g",
                    irow, params.recipe_count or 0, params.recipe_production or 0)
            end
        end

        self:add_runtime(debug, runtime, "Final", matrix_result)

        self:log("Interior point solver completed")
        return matrix_result, runtime
    end
end

-------------------------------------------------------------------------------
---Compute the Newton direction for the interior point method
---@param matrix Matrix
---@param mu number
---@return table, table, table
function SolverMatrixInteriorPoint:compute_newton_direction(matrix, mu)
    local rows = matrix.rows
    local x = matrix.x_variables
    local y = matrix.dual_variables
    local z = matrix.dual_bounds
    local n = #matrix.columns
    local m = #rows - 1  -- Exclude Z row
    
    -- Step 1: Formulate the augmented system matrix
    -- [ 0   A ] [ dy ] = [ r_p ]
    -- [ A'  D ] [ dx ]   [ r_c ]
    -- where D = X^(-1)Z
    
    local D = {}
    for j = 1, n do
        D[j] = (z[j] or 0.1) / math.max(x[j] or 0.1, 0.1)
    end
    
    -- Step 2: Compute the residuals
    local r_p = {}  -- Primal residual: Ax - b
    for i = 1, m do
        r_p[i] = 0
        for j = 1, n do
            r_p[i] = r_p[i] + (rows[i][j] or 0) * (x[j] or 0)
        end
    end
    
    local r_c = {}  -- Complementarity residual: XZe - μe
    for j = 1, n do
        local x_j = math.max(x[j] or 0.1, 0.1)
        local z_j = math.max(z[j] or 0.1, 0.1)
        r_c[j] = mu - x_j * z_j
    end
    
    -- Step 3: Solve the Schur complement system
    -- (A D^(-1) A') dy = r_p + A D^(-1) r_c
    local schur_rhs = {}
    for i = 1, m do
        schur_rhs[i] = r_p[i]
        for j = 1, n do
            if D[j] > 0 then
                schur_rhs[i] = schur_rhs[i] + (rows[i][j] or 0) * r_c[j] / D[j]
            end
        end
    end
    
    -- Solve using a simple iterative method (Jacobi)
    local dy = {}
    for i = 1, m do dy[i] = 0 end
    
    for iter = 1, 20 do  -- Limited iterations for Jacobi
        local dy_new = {}
        for i = 1, m do
            local sum = schur_rhs[i]
            local diag = 0
            
            -- Compute diagonal and off-diagonal contributions
            for j = 1, n do
                if D[j] > 0 then
                    local a_ij = rows[i][j] or 0
                    diag = diag + a_ij * a_ij / D[j]
                    
                    for k = 1, m do
                        if i ~= k then
                            local a_kj = rows[k][j] or 0
                            sum = sum - (a_ij * a_kj / D[j]) * (dy[k] or 0)
                        end
                    end
                end
            end
            
            -- Avoid division by zero
            if diag > 1e-10 then
                dy_new[i] = sum / diag
            else
                dy_new[i] = 0
            end
        end
        
        -- Update dy
        dy = dy_new
    end
    
    -- Step 4: Recover dx from dy
    local dx = {}
    for j = 1, n do
        dx[j] = 0
        if D[j] > 0 then
            dx[j] = r_c[j] / D[j]
            for i = 1, m do
                dx[j] = dx[j] - (rows[i][j] or 0) * (dy[i] or 0) / D[j]
            end
        end
    end
    
    -- Step 5: Compute dz = X^(-1) (mu*e - Z*dx - X*Z*e)
    local dz = {}
    for j = 1, n do
        local x_j = math.max(x[j] or 0.1, 0.1)
        local z_j = math.max(z[j] or 0.1, 0.1)
        dz[j] = (mu - z_j * dx[j] - x_j * z_j) / x_j
    end
    
    -- Limit extreme values
    for j = 1, n do
        dx[j] = math.max(-1.0, math.min(1.0, dx[j] or 0))
        dy[j] = math.max(-1.0, math.min(1.0, dy[j] or 0)) 
        dz[j] = math.max(-1.0, math.min(1.0, dz[j] or 0))
    end
    
    return dx, dy, dz
end

-------------------------------------------------------------------------------
---Update barrier parameter adaptively
---@param matrix Matrix
---@param dx table
---@param dy table
---@param dz table
---@return number
function SolverMatrixInteriorPoint:update_barrier_parameter(matrix, dx, dy, dz)
    local x = matrix.x_variables
    local z = matrix.dual_bounds
    local n = #matrix.columns
    
    -- Compute current duality gap
    local gap = 0
    local count = 0
    for j = 1, n do
        if x[j] and z[j] then
            gap = gap + x[j] * z[j]
            count = count + 1
        end
    end
    
    -- Average gap per variable
    if count > 0 then
        gap = gap / count
    end
    
    -- Decrease mu more aggressively when gap is large
    local sigma = 0.1
    if gap > 1.0 then
        sigma = 0.5
    elseif gap > 0.1 then
        sigma = 0.3
    elseif gap > 0.01 then
        sigma = 0.2
    end
    
    return gap * sigma
end

-------------------------------------------------------------------------------
---Compute the maximum step size with backtracking
---@param matrix Matrix
---@param dx table
---@param dy table
---@param dz table
---@return number
function SolverMatrixInteriorPoint:compute_step_size(matrix, dx, dy, dz)
    local x = matrix.x_variables or {}
    local z = matrix.dual_bounds or {}
    
    -- Compute the maximum feasible step size
    local alpha_max_primal = 1.0
    for j = 1, #x do
        if dx[j] and dx[j] < 0 and x[j] and x[j] > 0 then
            alpha_max_primal = math.min(alpha_max_primal, -0.95 * x[j] / dx[j])
        end
    end
    
    local alpha_max_dual = 1.0
    for j = 1, #z do
        if dz[j] and dz[j] < 0 and z[j] and z[j] > 0 then
            alpha_max_dual = math.min(alpha_max_dual, -0.95 * z[j] / dz[j])
        end
    end
    
    local alpha_max = math.min(alpha_max_primal, alpha_max_dual)
    alpha_max = math.min(1.0, alpha_max)  -- Never exceed 1.0
    
    -- Use a safety factor to stay away from boundary
    local alpha = 0.9 * alpha_max
    
    -- Backtracking line search could be added here
    -- but for simplicity, we'll use this reduced step size
    
    -- If step size is too small, use a minimum step
    if alpha < 1e-8 then
        alpha = math.max(alpha, 1e-8)
    end
    
    return alpha
end

-------------------------------------------------------------------------------
---Update the primal and dual variables
---@param matrix Matrix
---@param dx table
---@param dy table
---@param dz table
---@param alpha number
function SolverMatrixInteriorPoint:update_variables(matrix, dx, dy, dz, alpha)
    local x = matrix.x_variables or {}
    local y = matrix.dual_variables or {}
    local z = matrix.dual_bounds or {}

    -- Update primal variables
    for j = 1, #x do
        if dx[j] then
            x[j] = (x[j] or 0) + alpha * dx[j]
        end
    end

    -- Update dual variables for constraints
    for i = 1, #y do
        if dy[i] then
            y[i] = (y[i] or 0) + alpha * dy[i]
        end
    end

    -- Update dual variables for bounds
    for j = 1, #z do
        if dz[j] then
            z[j] = (z[j] or 0) + alpha * dz[j]
        end
    end
end

-------------------------------------------------------------------------------
---Check for algorithm convergence
---@param matrix Matrix
---@param dx table
---@param dy table
---@param dz table
---@param epsilon number
---@return boolean
function SolverMatrixInteriorPoint:check_convergence(matrix, dx, dy, dz, epsilon)
    local x = matrix.x_variables
    local z = matrix.dual_bounds
    local n = #matrix.columns
    
    -- Compute step size norm
    local step_norm = 0
    for j = 1, n do
        if dx[j] then
            step_norm = math.max(step_norm, math.abs(dx[j]))
        end
    end
    
    -- Compute duality gap
    local gap = 0
    local count = 0
    for j = 1, n do
        if x[j] and z[j] then
            gap = gap + x[j] * z[j]
            count = count + 1
        end
    end
    
    if count > 0 then
        gap = gap / count
    end
    
    -- Compute primal and dual infeasibility
    local primal_infeas = 0
    local rows = matrix.rows
    for i = 1, #rows - 1 do
        local row_sum = 0
        for j = 1, n do
            row_sum = row_sum + (rows[i][j] or 0) * (x[j] or 0)
        end
        primal_infeas = math.max(primal_infeas, math.abs(row_sum))
    end
    
    -- Convergence check based on all criteria
    local converged = (step_norm < epsilon) and (gap < epsilon) and (primal_infeas < epsilon)
    
    -- Log convergence metrics
    self:log("Convergence metrics:")
    self:log("  Step norm: %g", step_norm)
    self:log("  Duality gap: %g", gap)
    self:log("  Primal infeasibility: %g", primal_infeas)
    self:log("  Converged: %s", converged and "YES" or "NO")
    
    return converged
end

-------------------------------------------------------------------------------
---Extract the solution from the interior point result
---@param matrix_base Matrix
---@param matrix Matrix
---@return Matrix
function SolverMatrixInteriorPoint:extract_solution(matrix_base, matrix)
    local result = self:clone(matrix_base)
    local x = matrix.x_variables or {}

    self:log("Extracting solution from interior point result")

    -- Initialize objective_values if not present
    if not result.objective_values then
        result.objective_values = {}
        for i = 1, #result.columns do
            result.objective_values[i] = 0
        end
    end

    -- Set recipe counts based on x_variables with reasonable limits
    local max_reasonable_count = 1000.0 -- Limit extreme values

    for irow = 1, #result.headers do
        local parameters = result.parameters[irow]
        if parameters then
            -- Find the corresponding variable in the solution
            local var_index = irow -- Assuming simple 1:1 mapping

            if var_index <= #x and x[var_index] then
                -- Cap extreme values
                local original_value = x[var_index]
                local limited_value = math.min(max_reasonable_count, original_value)

                if original_value > max_reasonable_count then
                    self:log("WARNING: Capping extreme recipe count value from %g to %g for row %d",
                        original_value, limited_value, irow)
                end

                parameters.recipe_count = limited_value
                parameters.recipe_production = 1 -- Or compute based on the solution
            else
                parameters.recipe_count = 0
                parameters.recipe_production = 0
            end

            self:log("Recipe %d count set to: %g", irow, parameters.recipe_count)
        end
    end

    -- Initialize Z row if not present
    if not result.rows[#result.rows] then
        result.rows[#result.rows] = {}
        for i = 1, #result.columns do
            result.rows[#result.rows][i] = 0
        end
    end

    self:log("Computing objective values")

    -- Compute the objective row values
    for irow = 1, #result.rows - 1 do
        local row = result.rows[irow]
        local parameters = result.parameters[irow]

        if row and parameters then
            -- Compute the effect of this recipe on the objective
            for icol = 1, #result.columns do
                local cell_value = row[icol] or 0
                local recipe_count = parameters.recipe_count or 0

                -- Update the Z row
                if not result.rows[#result.rows][icol] then
                    result.rows[#result.rows][icol] = 0
                end

                local increment = cell_value * recipe_count
                result.rows[#result.rows][icol] = result.rows[#result.rows][icol] + increment

                -- Log significant contributions
                if math.abs(increment) > 1.0 then
                    self:log("Added %g to Z row column %d from row %d", increment, icol, irow)
                end
            end
        end
    end

    self:log("Solution extraction complete")
    return result
end

-------------------------------------------------------------------------------
---Return a matrix of block
---@param block BlockData
---@param parameters ParametersData
---@param debug boolean
---@return BlockData
function SolverMatrixInteriorPoint:solve(block, parameters, debug)
    -- This function should match the interface of other solvers
    -- We can reuse the implementation from SolverMatrix
    return SolverMatrix.solve(self, block, parameters, debug)
end
