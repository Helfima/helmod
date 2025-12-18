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
    local commands = Command.initialize()
    if event.parameters == "" then
        local names = {}
        for _, cmd in pairs(commands) do
            table.insert(names, cmd.name)
        end
        Player.print(string.format("Valid arguments: %s", table.concat(names, " | ")))
    else
        local cmd = commands[string.lower(event.parameters)]
        cmd.action();
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
                    if element.get_mod() == "helmod" then
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
