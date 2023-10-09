local inspect = require 'inspect'
local glob = require 'posix.glob'.glob
local revx2 = require("revx2")
-- revx2.DEBUG = true

local pattern = arg[1]
if pattern == nil then os.exit(1) end

for i, file in pairs(glob(pattern, 0)) do
   print("File: " .. i .. " - " .. file)
   local info = revx2.parse_file(file)
   print(inspect(info, {depth = 1}))
end