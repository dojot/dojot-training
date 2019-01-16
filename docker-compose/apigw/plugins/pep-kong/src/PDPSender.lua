local PDPSender_module = {}
local http = require "socket.http"

local utils = require "kong.plugins.pepkong.utils"
local PDPUtils = require "kong.plugins.pepkong.pdputils"


--[[
  Prepare and send an access request to the PDP
--]]
function PDPSender_module.sendRequest(conf, rawJWT, action, resource, ip)
    utils.printToFile(debug.getinfo(1).currentline,'PDPSender:  action: ' .. action .. ' url: ' .. conf.pdpUrl .. ' mode: ' .. conf.pdpMode )

    local requestData = PDPUtils.buildRequest(conf.pdpMode, rawJWT, action, resource, ip)

    local response_body = { }

    -- Forward to PDP
    local res, code, response_headers, status = http.request
		{
			url = conf.pdpUrl,
			method = "POST",
      sink = ltn12.sink.table(response_body),
			headers =
			{
        ["content-type"] = 'application/json',
        ["charset"] = 'UTF-8',
        ["Accept"] = 'application/json',
        ["Content-Length"] = requestData:len(),
			},

      source =  ltn12.source.string(requestData),
		}

    --  If the request returned, extract the PDP verdict from the response
    if code == 200 then
        local decoded = json.decode(response_body[1])
        return decoded.decision
    else
      -- If an error occurred, return the error code
      return code
    end
end

return PDPSender_module
