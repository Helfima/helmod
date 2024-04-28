-------------------------------------------------------------------------------
---Description of the module.
---@class SolverMatrixAlgebra : SolverMatrix
SolverMatrixAlgebra = newclass(SolverMatrix, function(base, object)
    SolverMatrix.init(base, object)
end)

-------------------------------------------------------------------------------
---Retourne la colonne
---@param matrix Matrix
---@param xrow integer
---@param invert boolean
---@return integer
function SolverMatrixAlgebra:get_col(matrix, xrow, invert)
    local row = matrix.rows[xrow]
    local parameters = matrix.parameters[xrow]
    local zrow = matrix.rows[#matrix.rows]
    local xcol = 0
    local max = 0
    local col_master = -1
    local col_exclude = -1
    -- if row[self.col_Cn] > 0 then
    --     col_master = row[self.col_Cn]
    -- end
    -- if row[self.col_Cn] < 0 then
    --     col_exclude = -row[self.col_Cn]
    -- end
    ---on cherche la plus grande demande
    for icol, column in pairs(matrix.columns) do
        local cell_value = row[icol] or 0
        if parameters.by_product == 0 or parameters.voider == 1 then
            -- to consume value we must use -value
            cell_value = -cell_value
        end
        if ((invert ~= true and cell_value > 0) or (invert == true and cell_value < 0)) then
            local zvalue = zrow[icol]
            if parameters.by_product == 0 or parameters.voider == 1 then
                -- to consume value we must use -value
                zvalue = -zvalue
            end
            local Z = zvalue
            local C = -Z / cell_value
            -- contraint
            local has_contraint = parameters.contraint ~= nil
            local is_master = parameters.contraint ~= nil and parameters.contraint.type == "master" and parameters.contraint.name == column.sysname
            local is_exclude = parameters.contraint ~= nil and parameters.contraint.type == "exclude" and parameters.contraint.name ~= column.sysname
            -- if zvalue = 0 the choose is already use
            if (C > max and zvalue ~= 0 and has_contraint == false)
                or (is_master)
                or (C > max and is_exclude) then
                max = C
                xcol = icol
            end
        end
    end
    return xcol
end

-------------------------------------------------------------------------------
---Calcul de la ligne
---@param matrix Matrix
---@param xrow integer
---@param xcol integer
---@return Matrix
function SolverMatrixAlgebra:line_compute(matrix, xrow, xcol)
    if matrix == nil or xrow == 0 or xcol == 0 then return matrix end
    local row = matrix.rows[xrow]
    local parameters = matrix.parameters[xrow]
    local zrow = matrix.rows[#matrix.rows]
    local P = parameters.recipe_production
    local E = parameters.recipe_energy  ---energy
    local Z = zrow[xcol]                ---valeur demandee Z
    local V = row[xcol]                 ---valeur produite
    local C = -Z / V                    ---coefficient
    if Z < 0 or parameters.by_product == 0 or parameters.voider == 1 then
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
function SolverMatrixAlgebra:line_compute_by_factory(matrix, xrow, time)
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
function SolverMatrixAlgebra:solve_matrix(matrix_base, debug, by_factory, time)
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
