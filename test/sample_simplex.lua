-- Fonction pour trouver le pivot
local function findPivot(tableau, numVars, numConstraints)
    local pivotCol = 1
    local minVal = tableau[1][1]
    for j = 2, numVars do
        if tableau[1][j] < minVal then
            minVal = tableau[1][j]
            pivotCol = j
        end
    end

    local pivotRow = 2
    local minRatio = tableau[pivotRow][numVars + numConstraints + 1] / tableau[pivotRow][pivotCol]
    for i = 3, numConstraints + 1 do
        if tableau[i][pivotCol] > 0 then
            local ratio = tableau[i][numVars + numConstraints + 1] / tableau[i][pivotCol]
            if ratio < minRatio then
                minRatio = ratio
                pivotRow = i
            end
        end
    end

    return pivotRow, pivotCol
end

-- Fonction pour effectuer le pivot
local function pivot(tableau, pivotRow, pivotCol, numVars, numConstraints)
    local pivotVal = tableau[pivotRow][pivotCol]
    for j = 1, numVars + numConstraints + 1 do
        tableau[pivotRow][j] = tableau[pivotRow][j] / pivotVal
    end

    for i = 1, numConstraints + 1 do
        if i ~= pivotRow then
            local factor = tableau[i][pivotCol]
            for j = 1, numVars + numConstraints + 1 do
                tableau[i][j] = tableau[i][j] - factor * tableau[pivotRow][j]
            end
        end
    end
end

-- Fonction pour vérifier si la solution est optimale
local function isOptimal(tableau, numVars)
    for j = 1, numVars do
        if tableau[1][j] < 0 then
            return false
        end
    end
    return true
end

-- Fonction principale du simplexe
local function simplex(c, A, b, numVars, numConstraints)
    -- Construire le tableau initial
    local tableau = {}
    for i = 1, numConstraints + 1 do
        tableau[i] = {}
        for j = 1, numVars + numConstraints + 1 do
            tableau[i][j] = 0
        end
    end

    -- Remplir le tableau avec les coefficients de la fonction objectif
    for j = 1, numVars do
        tableau[1][j] = -c[j]
    end

    -- Remplir le tableau avec les coefficients des contraintes
    for i = 1, numConstraints do
        for j = 1, numVars do
            tableau[i + 1][j] = A[i][j]
        end
        tableau[i + 1][numVars + i] = 1
        tableau[i + 1][numVars + numConstraints + 1] = b[i]
    end

    -- Algorithme du simplexe
    while not isOptimal(tableau, numVars) do
        local pivotRow, pivotCol = findPivot(tableau, numVars, numConstraints)
        pivot(tableau, pivotRow, pivotCol, numVars, numConstraints)
    end

    -- Extraire la solution
    local solution = {}
    for j = 1, numVars do
        local isBasic = true
        for i = 2, numConstraints + 1 do
            if tableau[i][j] ~= 0 then
                isBasic = false
                break
            end
        end
        if isBasic then
            for i = 2, numConstraints + 1 do
                if tableau[i][numVars + numConstraints + 1] ~= 0 and tableau[i][j] == 1 then
                    solution[j] = tableau[i][numVars + numConstraints + 1]
                    break
                end
            end
        else
            solution[j] = 0
        end
    end

    -- Calculer la valeur optimale de la fonction objectif
    local optimalValue = tableau[1][numVars + numConstraints + 1]

    return solution, optimalValue
end

-- Exemple d'utilisation
local c = {3, 2} -- Coefficients de la fonction objectif
local A = {{2, 1}, {1, 2}} -- Coefficients des contraintes
local b = {20, 20} -- Termes constants des contraintes
local numVars = 2 -- Nombre de variables
local numConstraints = 2 -- Nombre de contraintes

local solution, optimalValue = simplex(c, A, b, numVars, numConstraints)

print("Solution optimale:")
for i, v in ipairs(solution) do
    print("x" .. i .. " = " .. v)
end
print("Valeur optimale de la fonction objectif: " .. optimalValue)
