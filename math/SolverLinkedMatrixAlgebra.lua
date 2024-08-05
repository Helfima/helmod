-------------------------------------------------------------------------------
---Description of the module.
---@class SolverLinkedMatrixAlgebra : SolverLinkedMatrix
SolverLinkedMatrixAlgebra = newclass(SolverLinkedMatrix, function(base, object)
    SolverLinkedMatrix.init(base, object)
end)

-------------------------------------------------------------------------------
---Retourne la colonne
---@param matrix Matrix
---@param xrow integer
---@param invert boolean
---@return integer
function SolverLinkedMatrixAlgebra:get_col(matrix, xrow, invert)
    local row = matrix.rows[xrow]
    local parameters = matrix.parameters[xrow]
    if parameters.unlinked == 1 then
        return 1
    end
    local zrow = matrix.rows[#matrix.rows]
    local xcol = 0
    local max = 0
    local has_master = false
    for icol, column in pairs(matrix.columns) do
        local cell_value = row[icol] or 0
        if parameters.consumer == 1 or parameters.voider == 1 then
            -- to consume value we must use -value
            cell_value = -cell_value
        end
        if ((invert ~= true and cell_value > 0) or (invert == true and cell_value < 0)) then
            local zvalue = zrow[icol]
            if parameters.consumer == 1 or parameters.voider == 1 then
                -- to consume value we must use -value
                zvalue = -zvalue
            end
            local Z = zvalue
            local C = -Z / cell_value
            -- contraints
            local has_contraint = parameters.contraints ~= nil
            local is_master = false
            local is_exclude = false
            if parameters.contraints ~= nil and column.product ~= nil and parameters.contraints[column.product.name] then
                local contraint = parameters.contraints[column.product.name]
                if contraint.type == "master" then
                    is_master = true
                    has_master = true
                else
                    is_exclude = true
                end
            end
            -- if zvalue = 0 the choose is already use
            if (C > max and zvalue ~= 0 and has_contraint == false)
                or (is_master)
                or (C > max and is_exclude == false and has_master == false) then
                max = C
                xcol = icol
            end
        end
    end
    parameters.pivot = xcol
    return xcol
end

-------------------------------------------------------------------------------
---Calcul de la ligne
---@param matrix Matrix
---@param xrow integer
---@param xcol integer
---@return Matrix
function SolverLinkedMatrixAlgebra:line_compute(matrix, xrow, xcol)
    if matrix == nil or xrow == 0 or xcol == 0 then return matrix end
    local row = matrix.rows[xrow]
    local parameters = matrix.parameters[xrow]
    local zrow = matrix.rows[#matrix.rows]
    local P = parameters.recipe_production
    local E = parameters.recipe_energy  ---energy
    local Z = zrow[xcol]                ---valeur demandee Z
    local V = row[xcol]                 ---valeur produite
    local C = -Z / V                    ---coefficient
    if parameters.unlinked == 1 then
        C = 1
    end
    if Z < 0 or parameters.by_product == 0 or parameters.voider == 1 or parameters.unlinked == 1 then
        parameters.coefficient = C
        parameters.recipe_count = P * C
        for icol, cell_value in pairs(row) do
            local X = row[icol]
            zrow[icol] = zrow[icol] + X * P * C
        end
    end
    return matrix
end

-------------------------------------------------------------------------------
---Calcul de la ligne par factory
---@param matrix Matrix
---@param xrow integer
---@param time number
---@return Matrix
function SolverLinkedMatrixAlgebra:line_compute_by_factory(matrix, xrow, time)
    if matrix == nil or xrow == 0 then return matrix end
    local row = matrix.rows[xrow]
    local parameters = matrix.parameters[xrow]
    local zrow = matrix.rows[#matrix.rows]

    local F = parameters.factory_count
    local S = parameters.factory_speed
    local P = parameters.recipe_production
    local E = parameters.recipe_energy  ---energy
    local C = 1                         ---coefficient
    local R = time * F * S / E          ---nombre de recette/seconde
    parameters.coefficient = C
    parameters.recipe_count = R
    for icol, cell_value in pairs(row) do
        local X = row[icol]
        ---calcul Z
        zrow[icol] = zrow[icol] + X * R
    end
    return matrix
end

-------------------------------------------------------------------------------
---Resoud la matrice
---@param matrix_base Matrix
---@param debug boolean
---@param by_factory boolean
---@param time number
---@return Matrix, table
function SolverLinkedMatrixAlgebra:solve_matrix(matrix_base, debug, by_factory, time)
    if matrix_base ~= nil then
        local num_loop = 0
        local icol = 0
        local runtime = {}
        self:add_runtime(debug, runtime, "Initial", matrix_base)
        local Mstep = self:prepare(matrix_base)
        self:add_runtime(debug, runtime, "Prepare", Mstep)
        if by_factory == true then
            -- start_row ligne de démarrage du calcul
            local start_row = 0
            for irow, row in pairs(Mstep.rows) do
                if irow < #Mstep.rows then
                    local parameters = Mstep.parameters[irow]
                    local factory_count = parameters.factory_count
                    if factory_count > 0 then
                        if start_row == 0 then start_row = irow end
                        self:add_runtime(debug, runtime, "Step " .. num_loop, Mstep, { x = -1, y = irow })
                        Mstep = self:line_compute_by_factory(Mstep, irow, time)
                        num_loop = num_loop + 1
                        if start_row > 1 then
                            for xrow = start_row, 1, -1 do
                                local parameters = Mstep.parameters[xrow]
                                local factory_count = parameters.factory_count
                                if factory_count == 0 then
                                    icol = self:get_col(Mstep, xrow, true)
                                    self:add_runtime(debug, runtime, "Step " .. num_loop, Mstep, { x = icol, y = xrow })
                                    Mstep = self:line_compute(Mstep, xrow, icol)
                                    num_loop = num_loop + 1
                                end
                            end
                        end
                    elseif start_row ~= 0 then
                        icol = self:get_col(Mstep, irow, false)
                        self:add_runtime(debug, runtime, "Step " .. num_loop, Mstep, { x = icol, y = irow })
                        Mstep = self:line_compute(Mstep, irow, icol)
                        num_loop = num_loop + 1
                    end
                end
            end
        else
            for irow, _ in pairs(Mstep.rows) do
                if irow < #Mstep.rows then
                    icol = self:get_col(Mstep, irow, false)
                    self:add_runtime(debug, runtime, "Step " .. num_loop, Mstep, { x = icol, y = irow })
                    Mstep = self:line_compute(Mstep, irow, icol)
                    num_loop = num_loop + 1
                end
            end
        end
        local matrix_result = self:finalize(Mstep)
        matrix_result = self:apply_state(matrix_result)
        self:add_runtime(debug, runtime, "final", matrix_result)
        return matrix_result, runtime
    end
end
