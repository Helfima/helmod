-- Fonction pour trouver le pivot dans la colonne
local function findPivotColumn(tableau, numVars)
    local pivotColumn = 1
    for j = 2, numVars do
        if tableau[1][j] < tableau[1][pivotColumn] then
            pivotColumn = j
        end
    end
    return pivotColumn
end

-- Fonction pour trouver le pivot dans la ligne
local function findPivotRow(tableau, pivotColumn, numVars, numConstraints)
    local pivotRow = 2
    for i = 3, numConstraints + 1 do
        if tableau[i][pivotColumn] > 0 then
            local ratio = tableau[i][numVars + numConstraints + 2] / tableau[i][pivotColumn]
            local pivotRatio = tableau[pivotRow][numVars + numConstraints + 2] / tableau[pivotRow][pivotColumn]
            if ratio < pivotRatio then
                pivotRow = i
            end
        end
    end
    return pivotRow
end

-- Fonction pour effectuer le pivot
local function pivot(tableau, pivotRow, pivotColumn, numVars, numConstraints)
    local pivotElement = tableau[pivotRow][pivotColumn]
    for j = 1, numVars + numConstraints + 2 do
        tableau[pivotRow][j] = tableau[pivotRow][j] / pivotElement
    end

    for i = 1, numConstraints + 1 do
        if i ~= pivotRow then
            local factor = tableau[i][pivotColumn]
            for j = 1, numVars + numConstraints + 2 do
                tableau[i][j] = tableau[i][j] - factor * tableau[pivotRow][j]
            end
        end
    end
end

-- Fonction pour vérifier si la solution est optimale
local function isOptimal(tableau, numVars)
    for j = 2, numVars do
        if tableau[1][j] < 0 then
            return false
        end
    end
    return true
end

-- Fonction principale du simplexe
local function simplexMaximize(c, A, b, numVars, numConstraints)
    -- Initialiser le tableau
    local tableau = {}
    for i = 1, numConstraints + 1 do
        tableau[i] = {}
        for j = 1, numVars + numConstraints + 2 do
            tableau[i][j] = 0
        end
    end

    -- Remplir la fonction objectif
    for j = 1, numVars do
        tableau[1][j + 1] = -c[j]
    end

    -- Remplir les contraintes
    for i = 1, numConstraints do
        for j = 1, numVars do
            tableau[i + 1][j + 1] = A[i][j]
        end
        tableau[i + 1][numVars + i + 1] = 1
        tableau[i + 1][numVars + numConstraints + 2] = b[i]
    end

    -- Algorithme du simplexe
    while not isOptimal(tableau, numVars + 1) do
        local pivotColumn = findPivotColumn(tableau, numVars + numConstraints + 1)
        local pivotRow = findPivotRow(tableau, pivotColumn, numVars, numConstraints)
        pivot(tableau, pivotRow, pivotColumn, numVars, numConstraints)
    end

    -- Extraire la solution
    local solution = {}
    for j = 1, numVars do
        local col = j + 1
        local isBasic = true
        for i = 2, numConstraints + 1 do
            if tableau[i][col] ~= 0 then
                isBasic = false
                break
            end
        end
        if isBasic then
            for i = 2, numConstraints + 1 do
                if tableau[i][numVars + numConstraints + 2] ~= 0 and tableau[i][col] == 1 then
                    solution[j] = tableau[i][numVars + numConstraints + 2]
                    break
                end
            end
        else
            solution[j] = 0
        end
    end

    -- Calculer la valeur optimale
    local optimalValue = tableau[1][numVars + numConstraints + 2]

    return solution, optimalValue
end

-- Exemple d'utilisation
local c = {0, 0.23, 0, 0, 0, 0} -- Coefficients de la fonction objectif
local A = {
    {0, 0.188-1,0.0558,0.00558,0.00063,0},
    {0.75, 0.2232, 0.02233, 0.00224, 0.00025,-20}
} -- Coefficients des contraintes
local b = {0, 0} -- Termes constants des contraintes
local numVars = 6
local numConstraints = 2

local solution, optimalValue = simplexMaximize(c, A, b, numVars, numConstraints)

print("Solution optimale:")
for i, value in ipairs(solution) do
    print("x" .. i .. " = " .. value)
end
print("Valeur optimale: " .. optimalValue)
