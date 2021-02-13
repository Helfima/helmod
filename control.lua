if script.active_mods["gvv"] then require("__gvv__.gvv")() end
require "mod-gui"
require "core.tableExtends"
require "core.global"
require "core.class"
require "core.defines"
require "core.logging"
require "controller.DispatcherController"

--===========================
-- trace=4
-- debug=3
-- info=2
-- erro=1
-- nothing=0

Logging:new()
Logging.console = false

Dispatcher = DispatcherController("HMDispatcherController")
Format = require "core.Format"
require "gui.Gui"
Player = require "model.Player"
Controller = require "controller.Controller"
Command = require "core.Command"
EventController = require "controller.EventController"
-- attach events
EventController.start()
