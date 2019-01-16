return {
  fields = {
    pdpUrl = {type = "string", required = true, },
    pdpMode = {
                type = "string",
                enum = {"JWTForward", "JSON_XACML"},
                default  = "JWTForward"
              }
  }
}