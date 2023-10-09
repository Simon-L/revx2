local inspect = require 'inspect'

local revx2 = require("revx2")
revx2.DEBUG = true

local file = arg[1]
if file == nil then os.exit(1) end
print("File: " .. file)

local info = revx2.parse_file(file)
print(inspect(info))
