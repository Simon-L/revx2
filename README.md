revx2.lua
===========
> :warning: Super WIP stuff! :warning:

This library extracts tempo and slices informations from rx2 files for the ReCycle sampling software by Propellerheads. Designed for `luajit`.

Examples of use
===============

Try the test script by passing an rx2 file as argument

```bash
luajit test_revx2.lua "/path/to/some/file.rx2" 
```

Here is its content:
```lua
local inspect = require 'inspect'

local revx2 = require("revx2")
revx2.DEBUG = true -- comment to remove prints while parsing

local file = arg[1]
if file == nil then os.exit(1) end
print("File: " .. file)

local info = revx2.parse_file(file)
print(inspect(info))
```


### Dependencies

```bash
git clone https://github.com/moonlibs/ffi-reloadable/
cd ffi-reloadable && luarocks --local make
git clone https://github.com/moonlibs/bin
cd bin && luarocks --local make
```
