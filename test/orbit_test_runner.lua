local Runner = {}
local windows = package.config:sub(1, 1) == "\\"

function Runner.read(path)
    local file = assert(io.open(path, "rb"))
    local content = file:read("*a")
    file:close()
    return content
end

function Runner.write(path, content)
    local file = assert(io.open(path, "wb"))
    assert(file:write(content))
    file:close()
end

local function temporary_file()
    local path = os.tmpname()
    if windows == true then
        path = assert(os.getenv("TEMP"), "TEMP is required") .. "/" .. path:match("[^/\\]+$")
    end
    return path
end

local function quote(value)
    assert(value:find("[\r\n]") == nil, "Paths cannot contain line breaks")
    if windows == true then
        return "'" .. value:gsub("'", "''") .. "'"
    end
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function shell(posix, powershell)
    local script = temporary_file()
    local output = temporary_file()
    local command
    if windows == true then
        os.remove(script)
        script = script .. ".ps1"
        Runner.write(script, "$ErrorActionPreference = 'Stop'\n" .. powershell .. "\n")
        assert((script .. output):find('[%%!"\r\n]') == nil, "Unsupported TEMP path")
        command = 'powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' .. script .. '" > "' .. output .. '" 2>&1'
    else
        Runner.write(script, "set -e\n" .. posix .. "\n")
        command = "sh " .. quote(script) .. " > " .. quote(output) .. " 2>&1"
    end
    local status = os.execute(command)
    local text = Runner.read(output)
    os.remove(script)
    os.remove(output)
    assert(status == true or status == 0, "Command failed (" .. tostring(status) .. "): " .. text)
    return text
end

function Runner.absolute(path)
    if path:match("^/") ~= nil or path:match("^%a:[/\\]") ~= nil or path:match("^\\\\") ~= nil then
        return path
    end
    local current = shell("pwd", "[Console]::WriteLine((Get-Location).Path)"):gsub("[\r\n]+$", "")
    return current .. "/" .. path
end

function Runner.directory(path)
    shell("mkdir -p " .. quote(path), "New-Item -ItemType Directory -Force -Path " .. quote(path) .. " | Out-Null")
end

function Runner.copy(source, destination)
    shell("cp -RL " .. quote(source) .. " " .. quote(destination),
        "Copy-Item -Recurse -LiteralPath " .. quote(source) .. " -Destination " .. quote(destination))
end

function Runner.files(path)
    local output = shell("find -L " .. quote(path) .. " -maxdepth 1 -type f -printf '%f\\n'",
        "Get-ChildItem -LiteralPath " .. quote(path) .. " -File | ForEach-Object { [Console]::WriteLine($_.Name) }")
    local files = {}
    for name in output:gmatch("[^\r\n]+") do
        table.insert(files, name)
    end
    return files
end

function Runner.create(root, data)
    local marker = temporary_file()
    local work = marker .. ".work"
    shell("mkdir " .. quote(work), "New-Item -ItemType Directory -Path " .. quote(work) .. " | Out-Null")
    os.remove(marker)
    Runner.directory(work .. "/mods")
    Runner.copy(root .. "/src", work .. "/mods/helmod")
    Runner.write(work .. "/config.ini", "[path]\nread-data=" .. data .. "\nwrite-data=" .. work .. "/write\n")
    print("Test directory: " .. work)
    return work
end

function Runner.cleanup(work)
    shell("rm -rf " .. quote(work), "Remove-Item -Recurse -Force -LiteralPath " .. quote(work))
end

function Runner.suite(root, work, name)
    local mod = work .. "/mods/helmod"
    Runner.copy(root .. "/test/" .. name .. ".lua", mod .. "/" .. name .. ".lua")
    local control = mod .. "/control.lua"
    Runner.write(control, Runner.read(control) .. '\nrequire "' .. name .. '"\n')
end

function Runner.factorio(executable, work, arguments, graphical)
    local command = quote(executable)
    local parameters = {"--config", work .. "/config.ini", "--mod-directory", work .. "/mods"}
    for _, argument in ipairs(arguments) do
        table.insert(parameters, argument)
    end
    local quoted = {}
    for _, argument in ipairs(parameters) do
        command = command .. " " .. quote(argument)
        table.insert(quoted, quote('"' .. argument .. '"'))
    end
    local posix = command
    local powershell = "& " .. command .. "\nexit $LASTEXITCODE"
    if graphical == true then
        posix = "export SteamAppId=427520\nset +e\ntimeout --signal=TERM --kill-after=5s 45s " .. command
            .. '\nstatus=$?\nif [ "$status" -ne 0 ] && [ "$status" -ne 124 ]; then exit "$status"; fi'
        powershell = "$env:SteamAppId = '427520'\n"
            .. "$process = Start-Process -FilePath " .. quote(executable)
            .. " -ArgumentList @(" .. table.concat(quoted, ", ") .. ") -PassThru\n"
            .. "if ($process.WaitForExit(45000) -eq $false) {\n"
            .. "    $process.Kill()\n    $process.WaitForExit()\n"
            .. "} elseif ($process.ExitCode -ne 0) { exit $process.ExitCode }"
    end
    shell(posix, powershell)
    local log = Runner.read(work .. "/write/factorio-current.log")
    io.write(log)
    return log
end

return Runner
