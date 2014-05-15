-- TOML FILES
-- simple example
-- path = "./tests/simple.toml"
-- medium example
-- path = "./tests/medium.toml"
-- hard example
path = "./tests/hard.toml"

-- LOAD LIBRARY
local pprint = require "pl.pretty"
require "luatoml"

-- READ FILE CONTENT
file = io.open(path, "r")
content = file:read("*all")

-- CONVERT TOML FORMAT TO LUA OBJECT
luaObj = load(content)

-- JSON PRINT TO CONSOLE TO SEE WHAT OUR LUA OBJECT LOOKS LIKE
pprint.dump(luaObj)

