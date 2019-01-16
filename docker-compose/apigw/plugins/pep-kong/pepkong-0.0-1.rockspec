
package = "pepkong"
version = "0.0-1"
source = {
  url = "null"
}
description = {
  summary = "A Kong plugin, that extract roles from a JWT token and make a request for a XACML Policy Decision Point (PDP)",
  license = "null"
}
dependencies = {
  "lua ~> 5.1",
  "json4lua ~> 0.9.30-1"
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.pepkong.pepmain"] = "src/PEPMain.lua",
    ["kong.plugins.pepkong.handler"] = "src/handler.lua",
    ["kong.plugins.pepkong.schema"] = "src/schema.lua",
    ["kong.plugins.pepkong.utils"] = "src/utils.lua",
    ["kong.plugins.pepkong.pdpsender"] = "src/PDPSender.lua",
    ["kong.plugins.pepkong.pdputils"] = "src/PDPUtils.lua"
  }
}
