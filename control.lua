require "core.global"
require "core.class"
require "core.defines"
require "core.logging"

Format = require "core.Format"
ElementGui = require "core.ElementGui"
Player = require "model.Player"
Controller = require "controller.Controller"
UnitTest = require "core.UnitTest"
Command = require "core.Command"
Event = require "core.Event"
--===========================
-- trace=4
-- debug=3
-- info=2
-- erro=1
-- nothing=0

Logging:new()
Logging.console = false

-- add interface
-- remote.add_interface("helmod", require "core.Remote")

-- attach events
Event.start()