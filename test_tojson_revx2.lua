-- wget https://github.com/rxi/json.lua/raw/master/json.lua
local revx2 = require("revx2")
local json = require "json"

function capture_output(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

local rx2_file = arg[1]
local json_file = arg[2]
if rx2_file == nil then os.exit(1) end
if json_file == nil then os.exit(1) end

local info = revx2.parse_file(rx2_file)
local rx2_json = capture_output("echo '" .. json.encode(info) .. "' | jq", true)

local out_file = io.open(json_file, 'w')
out_file:write(rx2_json)
out_file:close()