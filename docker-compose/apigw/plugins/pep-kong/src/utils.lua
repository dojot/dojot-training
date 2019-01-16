local utils_module = {}

-- a simple log function
-- TODO: use a real log module
function utils_module.printToFile(line, txt)
	local s = "echo \"Linha " .. line .. " - " .. txt .."\"  >> /tmp/lualogs.txt"
	os.execute(s)
end

-- String split (or explode)
function utils_module.split(source, delimiters)
      local elements = {}
      local pattern = '([^'..delimiters..']+)'
      string.gsub(source, pattern, function(value) elements[#elements + 1] =     value;  end);
      return elements
end

return utils_module
