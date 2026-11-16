-- Run with standalone Lua from any directory; test saves and mods are isolated.
local test_directory = arg[0]:match("^(.*)[/\\]") or "."
local Runner = dofile(test_directory .. "/orbit_test_runner.lua")
local root = Runner.absolute(test_directory .. "/..")
local usage = [[Usage: lua test/run_orbit.lua FACTORIO --data DATA [MODE]
Modes:
  --base-only             Check existing planning without Space Age
  --timing                Measure 18 launch configurations over 40,000 ticks
  --ui [--output PATH]    Exercise the GUI and save screenshots (graphical client)
  --mods PATH [--launches] Check an isolated mod profile and optional launch timing
With no mode, run the Space Age orbit integration suite.
Requires Lua 5.1+ or LuaJIT; Linux coreutils or Windows PowerShell for file/process operations.
]]

if arg[1] == nil or arg[1] == "--help" then
    print(usage)
    os.exit(0)
end
local executable = Runner.absolute(arg[1])
local data, profile, output
local mode = "integration"
local launches = false
local index = 2
while index <= #arg do
    local option = arg[index]
    if option == "--data" or option == "--mods" or option == "--output" then
        index = index + 1
        assert(arg[index] ~= nil and arg[index]:sub(1, 2) ~= "--", "Missing value for " .. option)
        local path = Runner.absolute(arg[index])
        if option == "--data" then
            data = path
        elseif option == "--mods" then
            assert(mode == "integration", "Choose only one test mode")
            mode = "compatibility"
            profile = path
        else
            output = path
        end
    elseif option == "--base-only" or option == "--timing" or option == "--ui" then
        assert(mode == "integration", "Choose only one test mode")
        mode = option:sub(3)
    elseif option == "--launches" then
        launches = true
    else
        error("Unknown option: " .. option .. "\n" .. usage)
    end
    index = index + 1
end
assert(data ~= nil, "--data is required\n" .. usage)
assert(launches == false or mode == "compatibility", "--launches requires --mods")
assert(output == nil or mode == "ui", "--output requires --ui")

local work = Runner.create(root, data)
local success, message = xpcall(function()
    if mode == "compatibility" then
        for _, name in ipairs(Runner.files(profile)) do
            if name == "mod-list.json" or name == "mod-settings.dat" or name:match("%.zip$") ~= nil then
                Runner.copy(profile .. "/" .. name, work .. "/mods/" .. name)
            end
        end
        Runner.suite(root, work, "test_orbit_compatibility")
        if launches == true then
            Runner.suite(root, work, "test_orbit_compatibility_launches")
        end
    else
        local mods = {}
        for _, name in ipairs({"base", "quality", "elevated-rails", "space-age", "helmod"}) do
            local enabled = true
            if mode == "base-only" and name ~= "base" and name ~= "helmod" then
                enabled = false
            end
            table.insert(mods, '{"name":"' .. name .. '","enabled":' .. tostring(enabled) .. '}')
        end
        Runner.write(work .. "/mods/mod-list.json", '{"mods":[' .. table.concat(mods, ",") .. ']}')
        local suites = {integration="test_orbit", ["base-only"]="test_orbit_base", timing="test_orbit_timing", ui="test_orbit_ui"}
        Runner.suite(root, work, suites[mode])
        if mode == "integration" or mode == "timing" then
            local fixture = "orbit-prototypes"
            if mode == "timing" then
                fixture = "orbit-timing-prototypes"
            end
            local mod = work .. "/mods/helmod"
            Runner.copy(root .. "/test/" .. fixture .. ".lua", mod .. "/" .. fixture .. ".lua")
            local capture = mod .. "/data-final-fixes.lua"
            Runner.write(capture, 'require "' .. fixture .. '"\n' .. Runner.read(capture))
        end
    end

    local log = Runner.factorio(executable, work, {"--create", work .. "/test.zip"})
    if mode == "integration" or mode == "base-only" then
        assert(log:find("ORBIT TESTS PASSED", 1, true) ~= nil, "Integration checks did not finish")
    elseif mode == "compatibility" then
        assert(log:find("ORBIT COMPATIBILITY PASSED", 1, true) ~= nil, "Compatibility checks did not finish")
    end
    if mode == "timing" then
        log = Runner.factorio(executable, work, {"--benchmark", work .. "/test.zip", "--benchmark-ticks", "40000"})
        local _, count = log:gsub("TIMING PASS ", "")
        assert(count == 18, "Expected 18 timing checks, got " .. count)
    elseif launches == true then
        log = Runner.factorio(executable, work, {"--benchmark", work .. "/test.zip", "--benchmark-ticks", "16000"})
        assert(log:find("COMPAT LAUNCH PASS", 1, true) ~= nil, "Launch checks did not finish")
    elseif mode == "ui" then
        log = Runner.factorio(executable, work, {"--load-game", work .. "/test.zip", "--disable-audio", "--window-size", "1600x1000"}, true)
        assert(log:find("ORBIT UI SMOKE PASSED", 1, true) ~= nil, "GUI checks did not finish")
        output = output or Runner.absolute("orbit-screenshots")
        Runner.directory(output)
        local count = 0
        for _, name in ipairs(Runner.files(work .. "/write/script-output")) do
            if name:match("^orbit%-.+%.png$") ~= nil then
                Runner.copy(work .. "/write/script-output/" .. name, output .. "/" .. name)
                count = count + 1
            end
        end
        assert(count == 6, "Expected GUI screenshots, got " .. count)
        print("Screenshots: " .. output)
    end
end, debug.traceback)
if success == false then
    io.stderr:write(message .. "\nTest files retained at " .. work .. "\n")
    os.exit(1)
end
Runner.cleanup(work)
print("Orbit checks passed (" .. mode .. ")")
