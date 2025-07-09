-------------------------------------------------------------------------------
---Description of the module.
---@class SolverMatrixSimplex : SolverMatrix
SolverMatrixSimplex = newclass(SolverMatrix, function(base, object)
	SolverMatrix.init(base, object)
end)

-------------------------------------------------------------------------------
---Calcul pivot de gauss
---@param matrix Matrix
---@param xrow integer
---@param xcol integer
---@return Matrix
function SolverMatrixSimplex:pivot(matrix, xrow, xcol)
	local rows = matrix.rows

	local matrix_clone = self:clone(matrix)
	matrix_clone.rows = {}
	local rows_clone = matrix_clone.rows
	local pivot_value = rows[xrow][xcol]
	for irow, row in pairs(rows) do
		local parameters = matrix_clone.parameters[xrow]
		parameters.coefficient = parameters.coefficient / pivot_value
		rows_clone[irow] = {}
		for icol, column in pairs(matrix.columns) do
			local cell_value = row[icol] or 0
			if irow == xrow then
				--Transformation de la ligne pivot : elle est divisee par l'element pivot
				rows_clone[irow][icol] = cell_value / pivot_value
			elseif icol == xcol then
				--Transformation de la colonne pivot : toutes les cases sauf la case pivot deviennent zero.
				rows_clone[irow][icol] = 0
			else
				local B = rows[irow][xcol] or 0
				local D = rows[xrow][icol] or 0
				local value = cell_value - (B * D) / pivot_value
				if math.abs(value) < 1e-8 then
					rows_clone[irow][icol] = 0
				else
					rows_clone[irow][icol] = value
				end
			end
		end
	end
	-- swap base
	matrix_clone.headers[xrow] = matrix.columns[xcol]
	matrix_clone.columns[xcol] = matrix.headers[xrow]
	return matrix_clone
end

-------------------------------------------------------------------------------
---Retourne le pivot
---@param matrix Matrix
---@return boolean, integer, integer
function SolverMatrixSimplex:get_pivot(matrix)
	local rows = matrix.rows
	local zrow = matrix.rows[#matrix.rows]

	local max_z_value = 0
	local xcol = nil
	local ratio_value = 0
	local max_value = 0
	local xrow = nil
	-- boucle sur la derniere ligne nommee Z
	for icol, column in pairs(matrix.columns) do
		-- exclusion de la colonne coefficient
		if icol > 1 then
			local z_value = zrow[icol] or 0
			if z_value > max_z_value then
				-- la valeur repond au critere, la colonne est eligible
				-- on recherche le ligne
				ratio_value = nil
				for irow, current_row in pairs(rows) do
					local parameters = matrix.parameters[irow]
					local x_value = rows[irow][icol]
					-- on n'utilise pas la derniere ligne
					-- seule les cases positives sont prises en compte
					if irow < #rows and x_value > 0 then
						-- calcul du ratio base / x
						local c_value = parameters.coefficient
						local bx_ratio = c_value / x_value
						-- prend la premier valeur ou le plus grand ratio sinon la plus grande valeur
						if ratio_value == nil or bx_ratio > ratio_value or c_value > max_value then
							ratio_value = bx_ratio
							max_value = c_value
							xrow = irow
						end
					end
				end
				if ratio_value ~= nil then
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
	return true, xcol, xrow
end

-------------------------------------------------------------------------------
---Prepare la matrice
---@param matrix Matrix
---@return Matrix
function SolverMatrixSimplex:prepare(matrix)
	---ajoute la ligne Z
	local irow = 1
	---prepare les headers
	local matrix_clone = self:clone(matrix)
	local rows = matrix_clone.rows
	local headers = matrix_clone.headers
	local columns = matrix_clone.columns
	local parameters = matrix_clone.parameters

	---ajoute les recettes d'ingredient
	---initialise l'analyse
	local ckeck_cols = {}
	for icol, column in pairs(columns) do
		ckeck_cols[icol] = true
	end
	for irow, row in pairs(rows) do
		if irow <= #rows then
			for icol, column in pairs(columns) do
				local cell_value = row[icol] or 0
				---si une colonne est un produit au moins une fois on l'exclus
				if cell_value > 0 then
					ckeck_cols[icol] = false
				end
			end
		end
	end
	---ajout des faux recipe
	local index = 1
	for xcol, check in pairs(ckeck_cols) do
		if check then
			-- Add new header
			local new_header = table.deepcopy(columns[xcol])
			table.insert(headers, new_header)
			-- Add coefficient value
			local rowParameters = MatrixRowParameters()
			rowParameters.base = new_header
			rowParameters.contraint = nil
			rowParameters.factory_count = 0
            rowParameters.factory_speed = 0
            rowParameters.recipe_count = 0
            rowParameters.recipe_production = 1
            rowParameters.recipe_energy = 1
            rowParameters.coefficient = 1e4 * index --important ne pas changer
			--rowParameters.coefficient = math.pow(10,index)*10
			table.insert(parameters, rowParameters)
			local new_row = {}
			for icol, column in pairs(columns) do
				if icol == xcol then
					table.insert(new_row, 1)
				else
					table.insert(new_row, 0)
				end
			end
			table.insert(rows, new_row)
			index = index + 1
		end
	end
	self:prepare_z_and_objectives(matrix_clone, true)

	-- ajout colonne coefficient
	local new_column = {type="none", name="C"}
	table.insert(columns, 1, new_column)
	for irow, row in pairs(rows) do
		local parameters = matrix_clone.parameters[irow]
		local C = 0
		if parameters ~= nil and parameters.coefficient ~= nil then
			C = parameters.coefficient or 0
		end
		table.insert(row, 1, C)
	end

	---ajoute les row en colonne
	local num_row = rawlen(matrix.rows)
	local num_col = rawlen(matrix_clone.columns)
	for icol = 1, num_row do
		-- Add new column
		local new_column = table.deepcopy(matrix_clone.headers[icol])
		table.insert(columns, new_column)
		for irow, row in pairs(rows) do
			---ajoute les valeurs
			if irow == icol then
				rows[irow][num_col + icol] = 1
			else
				rows[irow][num_col + icol] = 0
			end
		end
	end

	return matrix_clone
end

-------------------------------------------------------------------------------
---Calcul de la ligne
---@param matrix Matrix
---@param xrow integer
---@return Matrix
function SolverMatrixSimplex:line_compute(matrix, xrow)
	if matrix == nil or xrow == 0 then return matrix end
	local row = matrix.rows[xrow]
    local parameters = matrix.parameters[xrow]
    local zrow = matrix.rows[#matrix.rows]
	local R = parameters.recipe_count
	local E = parameters.recipe_energy

	for icol, column in pairs(matrix.columns) do
		local cell_value = row[icol] or 0
		if cell_value ~= 0 then
			local Z = zrow[icol] ---valeur demandee Z
			local X = cell_value

			local C = -Z / X
			if C > 0 and C > parameters.coefficient then
				parameters.coefficient = C
				parameters.recipe_production = R * E / C
			end
		end
	end

	local P = parameters.recipe_production
	local C = parameters.coefficient
	for icol, column in pairs(matrix.columns) do
		local cell_value = row[icol] or 0
		if cell_value ~= 0 then
			local Z = zrow[icol] ---valeur demandee Z
			local X = cell_value
			---calcul du Z
			zrow[icol] = Z + X * P * C
		end
	end
	return matrix
end

-------------------------------------------------------------------------------
---Calcul du tableau
---@param matrix Matrix --matrix finale
---@param matrix_result Matrix --matrix intermediaire
---@return Matrix
function SolverMatrixSimplex:table_compute(matrix, matrix_result)
	if matrix == nil then return matrix end
	local zrow = matrix_result.rows[#matrix_result.rows]

	---preparation input
	self:prepare_z_and_objectives(matrix, false)

	---preparation du resultat
	for irow, _ in pairs(matrix.rows) do
		if irow < #matrix.rows then
			---colonne correspondant a la recette
			local icol = #matrix_result.columns - #matrix.headers + irow

			local parameters = matrix.parameters[irow]
			parameters.recipe_count = -zrow[icol] ---moins la valeur affichee dans Z
			parameters.recipe_production = 0
		end
	end

	---remove recipe helmod-temperature-convert
	for irow = #matrix_result.headers, 1, -1 do
		local header = matrix_result.headers[irow]
		if header.name == "helmod-temperature-convert" then
			table.remove(matrix_result.headers, irow)
			table.remove(matrix_result.rows, irow)
		end
	end

	---initialise les valeurs des produits par second
	for irow, row in pairs(matrix.rows) do
		if irow < #matrix.rows then
			local parameters = matrix.parameters[irow]
			local E = parameters.recipe_energy
			for icol, column in pairs(matrix.columns) do
				local cell_value = row[icol] or 0
				row[icol] = cell_value / E
			end
		end
	end

	---calcul du resultat
	for irow, _ in pairs(matrix.rows) do
		if irow < #matrix.rows then
			matrix = self:line_compute(matrix, irow)
		end
	end
	return matrix
end

-------------------------------------------------------------------------------
---Resoud la matrice
---@param Mbase table
---@param debug boolean
---@param by_factory boolean
---@param time number
---@return Matrix, {[integer] : Matrix}
function SolverMatrixSimplex:solve_matrix(Mbase, debug, by_factory, time)
	if Mbase ~= nil then
		local num_loop = 0
		local runtime = {}
		self:add_runtime(debug, runtime, "Initial", Mbase)
		local Mstep = self:prepare(Mbase)
		self:add_runtime(debug, runtime, "Prepare", Mstep)
		local loop, xcol, xrow
		loop = true
		while loop do
			loop, xcol, xrow = self:get_pivot(Mstep)
			if loop then
				self:add_runtime(debug, runtime, "Step " .. num_loop, Mstep, { x = xcol, y = xrow })
				Mstep = self:pivot(Mstep, xrow, xcol)
			else
				self:add_runtime(debug, runtime, "Last", Mstep)
			end
			num_loop = num_loop + 1
		end
		---finalisation
		local matrix_result = self:clone(Mbase)
		matrix_result = self:table_compute(matrix_result, Mstep)
		matrix_result = self:finalize(matrix_result)
		matrix_result = self:apply_state(matrix_result)
		self:add_runtime(debug, runtime, "final", matrix_result)
		return matrix_result, runtime
	end
end
