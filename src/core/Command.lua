---
-- Description of the module.
-- @class Command
--
local Command = {
    -- single-line comment
    classname = "HMCommand"
}

-------------------------------------------------------------------------------
-- Start
--
function Command.start()
    commands.add_command("helmod", "helmod commands", Command.run)
end

-------------------------------------------------------------------------------
-- Run
--
function Command.run(event)
    -- do nothing
end

-------------------------------------------------------------------------------
-- Parse
--
-- @param event table
--
function Command.parse(event)
    if event.command == "helmod" then
        if event.parameters == "" then
            Command.help()
        else
            Command.execute(event.parameters)
        end
    end
end

function Command.help()
    local commands = Command.initialize()
    local names = {}
    for _, cmd in pairs(commands) do
        table.insert(names, cmd.name)
    end
    Player.print(string.format("Valid arguments: %s", table.concat(names, " | ")))
end

function Command.execute(parameters)
    local commands = Command.initialize()
    local cmd = commands[string.lower(parameters)]
    if cmd ~= nil then
        cmd.action();
    else
        Command.help()
    end
end

function Command.initialize()
    local commands = {}
    commands["close"] = {
        name = "CloseUI",
        description = "Close all panels",
        action = function()
            for _, location in pairs({ "top", "left", "center", "screen", "goal" }) do
                for _, element in pairs(Player.getGui(location).children) do
                    if element.get_mod() == "helmod" and element.name ~= "mod_gui_top_frame" then
                        element.destroy()
                    end
                end
            end
            Player.print("Close all panels executed!")
        end
    }
    commands["resetuserall"] = {
        name = "ResetUserAll",
        description = "Reset all parameters for all users",
        action = function()
            User.resetAll()
            Player.print("All Users are reseted!")
        end
    }
    commands["resetuser"] = {
        name = "ResetUser",
        description = "Reset all user parameters",
        action = function()
            User.reset()
            Player.print("User parameters are reseted!")
        end
    }
    commands["resetuserexplorer"] = {
        name = "ResetUserExplorer",
        description = "Reset user explorer parameters",
        action = function()
            User.setParameter("explore_recipe", nil)
            User.setParameter("explore_recipe_id", nil)
            Player.print("User explorer parameter are reseted!")
        end
    }
    return commands
end

return Command
