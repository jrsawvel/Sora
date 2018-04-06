
-- module: config.lua

local M = {}

local io      = require "io"
local lyaml   = require "lyaml"

local filename = "/home/sora/config/sora.yml"

local f = assert(io.open(filename, "r"))

local yaml_text = f:read("a")

f:close()

-- convert string to lua table
M.t = lyaml.load(yaml_text)

function M.get_value_for(wxkey)
    return M.t[wxkey]
end


return M

