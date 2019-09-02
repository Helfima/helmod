require "mod-gui"
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
ElementGui = require "core.ElementGui"
Player = require "model.Player"
Controller = require "controller.Controller"
UnitTest = require "core.UnitTest"
Command = require "core.Command"
EventController = require "controller.EventController"

-- attach events
EventController.start()