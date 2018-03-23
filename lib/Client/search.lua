
local M = {}


local display = require "display"


function M.do_search(a_params)

    if a_params[2] ~= nil then
        display.report_error("user", "debug", "hello from search.lua - " .. display.unescape(a_params[2]))
    else
        display.report_error("user", "debug", "hello from search.lua")
    end

end

return M
