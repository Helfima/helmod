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
    local m = #rows - 1
    local n = #columns

    self:log("Computing initial point")

    -- Initialize primal variables
    matrix.x_variables = {}

    -- Start with larger values to help avoid infeasibility
    for i = 1, n do
        matrix.x_variables[i] = 1.0  -- Start with 1.0 instead of 0.1
    end

    self:log("Initial primal variables set to 1.0")

    -- Try multiple starting points if needed
    local best_violation = math.huge
    local best_x = {}
    
    -- Try different starting points
    for attempt = 1, 5 do
        -- Scale initial values for this attempt
        local scale = attempt * 0.5
        for i = 1, n do
            matrix.x_variables[i] = scale
        end
        
        -- Run more feasibility iterations
        for iter = 1, 10 do
            self:log("Feasibility adjustment iteration %d (attempt %d)", iter, attempt)
            self:adjust_for_feasibility(matrix)
        end
        
        -- Measure violation after adjustments
        local violation = self:calculate_constraint_violation(matrix)
        
        if violation < best_violation then
            -- Save this as the best point so far
            best_violation = violation
            best_x = {}
            for i = 1, n do
                best_x[i] = matrix.x_variables[i]
            end
        end
    end
    
    -- Use the best starting point found
    for i = 1, n do
        matrix.x_variables[i] = best_x[i]
    end

    return matrix
end

function SolverMatrixInteriorPoint:calculate_constraint_violation(matrix)
    local rows = matrix.rows
    local x = matrix.x_variables
    local m = #rows - 1
    
    local total_violation = 0
    
    for i = 1, m do
        local constraint_value = 0
        for j = 1, #matrix.columns do
            constraint_value = constraint_value + (rows[i][j] or 0) * (x[j] or 0)
        end
        
        total_violation = total_violation + math.abs(constraint_value)
    end
    
    return total_violation
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
---Precondition the matrix to improve numerical stability
---@param matrix Matrix
---@return Matrix
function SolverMatrixInteriorPoint:precondition_matrix(matrix)
    local rows = matrix.rows
    local m = #rows - 1
    local n = #matrix.columns
    
    -- Compute row scaling factors
    local row_scale = {}
    for i = 1, m do
        local max_abs = 0
        for j = 1, n do
            max_abs = math.max(max_abs, math.abs(rows[i][j] or 0))
        end
        row_scale[i] = max_abs > 1e-10 and (1.0 / max_abs) or 1.0
    end
    
    -- Apply row scaling
    for i = 1, m do
        for j = 1, n do
            if rows[i][j] then
                rows[i][j] = rows[i][j] * row_scale[i]
            end
        end
    end
    
    -- Store scaling factors for later unscaling
    matrix.row_scale = row_scale
    
    return matrix
end

-------------------------------------------------------------------------------
---Unscale the matrix after solving
---@param matrix Matrix
---@return Matrix
function SolverMatrixInteriorPoint:unscale_matrix(matrix)
    if not matrix.row_scale then
        return matrix
    end
    
    local rows = matrix.rows
    local m = #rows - 1
    local n = #matrix.columns
    
    -- Unscale the rows
    for i = 1, m do
        for j = 1, n do
            if rows[i][j] then
                rows[i][j] = rows[i][j] / matrix.row_scale[i]
            end
        end
    end
    
    -- Remove the scaling factors
    matrix.row_scale = nil
    
    return matrix
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

        -- Precondition the matrix for better numerical stability
        self:log("Preconditioning matrix...")
        matrix = self:precondition_matrix(matrix)
        self:log("Matrix preconditioned")

        -- Compute initial point
        self:log("Computing initial point...")
        matrix = self:compute_initial_point(matrix)
        self:log("Initial point computed")
        self:log_state(matrix, 0)
        self:add_runtime(debug, runtime, "Initial Point", matrix)

        -- Parameters for the algorithm
        local mu = 0.1       -- Initial barrier parameter
        local epsilon = 1e-4 -- Convergence tolerance
        local max_iter = 100 -- Maximum iterations

        self:log("Algorithm parameters:")
        self:log("  Initial mu: %g", mu)
        self:log("  Epsilon: %g", epsilon)
        self:log("  Max iterations: %d", max_iter)

        -- Main loop
        for iter = 1, max_iter do
            matrix.current_iteration = iter

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

        -- Before extracting solution, unscale the matrix
        self:log("Unscaling matrix...")
        matrix = self:unscale_matrix(matrix)

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
---Compute the Newton direction for the interior point method with Conjugate Gradient
---@param matrix Matrix
---@param mu number
---@return table, table, table
function SolverMatrixInteriorPoint:compute_newton_direction(matrix, mu)
    local rows = matrix.rows
    local x = matrix.x_variables
    local y = matrix.dual_variables
    local z = matrix.dual_bounds
    local n = #matrix.columns
    local m = #rows - 1 -- Exclude Z row

    -- Step 1: Formulate the augmented system matrix
    -- [ 0   A ] [ dy ] = [ r_p ]
    -- [ A'  D ] [ dx ]   [ r_c ]
    -- where D = X^(-1)Z

    local D = {}
    for j = 1, n do
        D[j] = (z[j] or 0.1) / math.max(x[j] or 0.1, 0.1)
    end

    -- Step 2: Compute the residuals
    local r_p = {} -- Primal residual: Ax - b
    for i = 1, m do
        r_p[i] = 0
        for j = 1, n do
            r_p[i] = r_p[i] + (rows[i][j] or 0) * (x[j] or 0)
        end
    end

    local r_c = {} -- Complementarity residual: XZe - μe
    for j = 1, n do
        local x_j = math.max(x[j] or 0.1, 0.1)
        local z_j = math.max(z[j] or 0.1, 0.1)
        r_c[j] = mu - x_j * z_j
    end

    -- Step 3: Solve the Schur complement system using Conjugate Gradient
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

    -- Helper function to compute (A D^(-1) A') * v
    local function apply_schur_matrix(v)
        -- First compute A' * v
        local A_transpose_v = {}
        for j = 1, n do
            A_transpose_v[j] = 0
            for i = 1, m do
                A_transpose_v[j] = A_transpose_v[j] + (rows[i][j] or 0) * (v[i] or 0)
            end
        end
        
        -- Then compute D^(-1) * (A' * v)
        local D_inv_A_transpose_v = {}
        for j = 1, n do
            if D[j] > 0 then
                D_inv_A_transpose_v[j] = A_transpose_v[j] / D[j]
            else
                D_inv_A_transpose_v[j] = 0
            end
        end
        
        -- Finally compute A * (D^(-1) * (A' * v))
        local result = {}
        for i = 1, m do
            result[i] = 0
            for j = 1, n do
                result[i] = result[i] + (rows[i][j] or 0) * D_inv_A_transpose_v[j]
            end
        end
        
        return result
    end

    -- Initialize Conjugate Gradient method
    local dy = {}
    for i = 1, m do dy[i] = 0 end -- Initial guess
    
    local r = {} -- Initial residual r = b - Ax
    local schur_dy = apply_schur_matrix(dy)
    for i = 1, m do
        r[i] = schur_rhs[i] - (schur_dy[i] or 0)
    end
    
    local p = {} -- Initial search direction = residual
    for i = 1, m do p[i] = r[i] end
    
    local r_dot_r = 0
    for i = 1, m do
        r_dot_r = r_dot_r + (r[i] or 0) * (r[i] or 0)
    end
    
    -- CG iteration parameters
    local max_cg_iter = math.min(m, 50) -- Limited iterations or dimension
    local cg_tol = 1e-8 -- Tolerance for convergence
    
    self:log("Starting Conjugate Gradient with r_dot_r = %g", r_dot_r)
    
    -- Main CG loop
    for cg_iter = 1, max_cg_iter do
        -- Check for early convergence
        if r_dot_r < cg_tol then
            self:log("CG converged in %d iterations, residual = %g", cg_iter-1, r_dot_r)
            break
        end
        
        -- Compute A*p
        local Ap = apply_schur_matrix(p)
        
        -- Compute step size alpha = r'r / p'Ap
        local p_dot_Ap = 0
        for i = 1, m do
            p_dot_Ap = p_dot_Ap + (p[i] or 0) * (Ap[i] or 0)
        end
        
        -- Avoid division by zero
        if math.abs(p_dot_Ap) < 1e-14 then
            self:log("CG breakdown: p_dot_Ap ≈ 0 in iteration %d", cg_iter)
            break
        end
        
        local alpha = r_dot_r / p_dot_Ap
        
        -- Update solution: dy = dy + alpha*p
        for i = 1, m do
            dy[i] = (dy[i] or 0) + alpha * (p[i] or 0)
        end
        
        -- Store old r'r for beta calculation
        local r_dot_r_old = r_dot_r
        
        -- Update residual: r = r - alpha*Ap
        r_dot_r = 0
        for i = 1, m do
            r[i] = (r[i] or 0) - alpha * (Ap[i] or 0)
            r_dot_r = r_dot_r + (r[i] or 0) * (r[i] or 0)
        end
        
        -- Compute beta = r_new'r_new / r_old'r_old
        local beta = r_dot_r / r_dot_r_old
        
        -- Update search direction: p = r + beta*p
        for i = 1, m do
            p[i] = (r[i] or 0) + beta * (p[i] or 0)
        end
        
        self:log("CG iteration %d: residual = %g", cg_iter, r_dot_r)
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
        if j <= m then -- Only apply limits to valid indices
            dy[j] = math.max(-1.0, math.min(1.0, dy[j] or 0))
        end
        dz[j] = math.max(-1.0, math.min(1.0, dz[j] or 0))
    end

    return dx, dy, dz
end

-------------------------------------------------------------------------------
---Preconditioner for Conjugate Gradient method (Optional enhancement)
---@param matrix Matrix
---@return table
function SolverMatrixInteriorPoint:compute_preconditioner(matrix)
    local rows = matrix.rows
    local n = #matrix.columns
    local m = #rows - 1
    local D = matrix.D or {} -- Diagonal scaling matrix
    
    -- Create a simple diagonal preconditioner based on the row norms
    local M_inv = {}
    
    for i = 1, m do
        local row_norm_squared = 0
        
        for j = 1, n do
            local a_ij = rows[i][j] or 0
            if a_ij ~= 0 and D[j] and D[j] > 0 then
                row_norm_squared = row_norm_squared + (a_ij * a_ij / D[j])
            end
        end
        
        -- Avoid division by zero
        if row_norm_squared > 1e-12 then
            M_inv[i] = 1.0 / row_norm_squared
        else
            M_inv[i] = 1.0 -- Default if row is near zero
        end
    end
    
    return M_inv
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
        if x[j] and x[j] > 0 and z[j] and z[j] > 0 then
            gap = gap + x[j] * z[j]
            count = count + 1
        end
    end
    
    -- Average gap per variable
    if count > 0 then
        gap = gap / count
    end
    
    -- Calculate progress measure based on step size and iterations
    local iterations_remaining = 100 - matrix.current_iteration
    if iterations_remaining < 1 then iterations_remaining = 1 end
    
    -- More aggressive reduction factor as iterations increase
    local reduction_factor
    if matrix.current_iteration > 80 then
        -- Very aggressive in final iterations
        reduction_factor = 0.01
    elseif matrix.current_iteration > 60 then
        -- More aggressive in later iterations
        reduction_factor = 0.05
    elseif matrix.current_iteration > 40 then
        -- Moderately aggressive in middle iterations
        reduction_factor = 0.1
    else
        -- Conservative in early iterations
        reduction_factor = 0.5
    end
    
    -- Calculate new mu, ensure it's positive
    local new_mu = math.max(gap * reduction_factor, 1e-10)
    
    -- Add extra tracking information
    if not matrix.previous_gap then matrix.previous_gap = gap end
    
    -- If gap isn't decreasing fast enough, be more aggressive
    if gap > 0.95 * matrix.previous_gap and matrix.current_iteration > 20 then
        new_mu = new_mu * 0.5  -- Cut mu in half if progress is slow
    end
    
    matrix.previous_gap = gap
    
    return new_mu
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
    alpha_max = math.min(1.0, alpha_max) -- Never exceed 1.0

    -- Use a safety factor to stay away from boundary
    local alpha = 0.9 * alpha_max

    -- Add a backtracking line search
    local alpha = alpha_max
    local beta = 0.8                -- Backtracking factor
    local sufficient_decrease = 0.01 -- Armijo condition parameter

    -- Compute current merit function value
    local current_merit = self:compute_merit_function(matrix)

    -- Try backtracking to find a better step size
    for backtrack = 1, 10 do
        -- Create a temporary copy of variables
        local x_new = {}
        local y_new = {}
        local z_new = {}

        for j = 1, #matrix.x_variables do
            x_new[j] = (matrix.x_variables[j] or 0) + alpha * (dx[j] or 0)
        end

        for i = 1, #matrix.dual_variables do
            y_new[i] = (matrix.dual_variables[i] or 0) + alpha * (dy[i] or 0)
        end

        for j = 1, #matrix.dual_bounds do
            z_new[j] = (matrix.dual_bounds[j] or 0) + alpha * (dz[j] or 0)
        end

        -- Save original variables
        local x_orig = matrix.x_variables
        local y_orig = matrix.dual_variables
        local z_orig = matrix.dual_bounds

        -- Set new variables temporarily
        matrix.x_variables = x_new
        matrix.dual_variables = y_new
        matrix.dual_bounds = z_new

        -- Compute merit function with new variables
        local new_merit = self:compute_merit_function(matrix)

        -- Restore original variables
        matrix.x_variables = x_orig
        matrix.dual_variables = y_orig
        matrix.dual_bounds = z_orig

        -- Check if sufficient decrease condition is satisfied
        if new_merit <= current_merit - sufficient_decrease * alpha then
            break
        end

        -- Reduce step size
        alpha = alpha * beta

        -- Lower bound on step size
        if alpha < 1e-6 then
            alpha = 1e-6
            break
        end
    end

    return alpha
end

-- Merit function for line search
function SolverMatrixInteriorPoint:compute_merit_function(matrix)
    local x = matrix.x_variables
    local y = matrix.dual_variables
    local z = matrix.dual_bounds
    local rows = matrix.rows
    local n = #matrix.columns
    local m = #rows - 1
    
    -- Compute objective value
    local obj_val = 0
    for j = 1, n do
        if matrix.objective_values and matrix.objective_values[j] then
            obj_val = obj_val + (matrix.objective_values[j] * (x[j] or 0))
        end
    end
    
    -- Compute constraint violation
    local constraint_violation = 0
    for i = 1, m do
        local row_sum = 0
        for j = 1, n do
            row_sum = row_sum + (rows[i][j] or 0) * (x[j] or 0)
        end
        constraint_violation = constraint_violation + math.abs(row_sum)
    end
    
    -- Compute barrier term
    local barrier = 0
    for j = 1, n do
        if x[j] and x[j] > 0 then
            barrier = barrier - math.log(x[j])
        end
    end
    
    -- Weight parameters
    local constraint_weight = 100.0
    local barrier_weight = 1.0
    
    return obj_val + constraint_weight * constraint_violation + barrier_weight * barrier
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

    -- Update primal variables with non-negativity constraint
    for j = 1, #x do
        if dx[j] then
            x[j] = (x[j] or 0) + alpha * dx[j]
            -- Ensure primal variables stay positive
            x[j] = math.max(x[j], 1e-6)
        end
    end

    -- Update dual variables
    for i = 1, #y do
        if dy[i] then
            y[i] = (y[i] or 0) + alpha * dy[i]
        end
    end

    -- Update dual bounds with non-negativity constraint
    for j = 1, #z do
        if dz[j] then
            z[j] = (z[j] or 0) + alpha * dz[j]
            -- Ensure dual bound variables stay positive
            z[j] = math.max(z[j], 1e-6)
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
