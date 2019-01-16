local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.pepkong.pepmain"

local PEPPlugin = BasePlugin:extend()

function PEPPlugin:new()
	PEPPlugin.super.new(self, "pepkong")
end

function PEPPlugin:access(conf)
	PEPPlugin.super.access(self)
	access.run(conf)	
end

return PEPPlugin