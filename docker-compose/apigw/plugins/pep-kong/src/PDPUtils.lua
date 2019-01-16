require 'json'
local PDP_Utils_module = {}

-- Receives information about a request and encode it
-- to be send to the PDP.
-- How the request is encoded depends on 'pdpMode' parameter
function PDP_Utils_module.buildRequest(pdpMode, rawJWT,
                                       action,
                                       resource, userIpAddr)
  if (pdpMode == 'JWTForward') then
    -- Forward the JWT. so JWT capable PDPs have all possible information
    local requestJson = ({
            jwt = rawJWT,
            action = action,
            resource = resource
          })
    return json.encode(requestJson)
   end
end

return PDP_Utils_module
