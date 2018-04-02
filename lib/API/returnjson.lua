

local M = {}

local cjson = require "cjson"
local cgilua = require "cgilua"


function M.success(h_msg)

    h_msg.status = "200"
    h_msg.description = "OK"

--[[
    local hash = {
        status          =  "200",
        description     =  "OK",
        user_message    =  h_msg["user_message"],
        system_message  =  h_msg["system_message"]
    }
]]

    local json_str = cjson.encode(h_msg)

    cgilua.jrStatus(200)
    cgilua.contentheader ("application", "json; charset=ISO-8859-1")
    cgilua.header("Vary", "Accept-Encoding")
    cgilua.put(json_str) 

end


function M.show_error(a_params)

    local user_message
    local system_message

    if a_params[1] ~= nil then
        user_message = "Invalid function: " .. a_params[1]
    else
        user_message = "Invalid function: no function given."
    end

    system_message = "It's not supported." 

    M.report_error("404", user_message, system_message)

end


function M.report_error(status, user_message, system_message)

    local http_status_codes = {
        ["200"] = "OK",
        ["201"] = "Created",
        ["204"] = "No Content",
        ["400"] = "Bad Request",
        ["401"] = "Not Authorized",
        ["403"] = "Forbidden",
        ["404"] = "Not Found",
        ["500"] = "Internal Server Error"
    }

    local hash = {
        status = status,
        description = http_status_codes[status],
        user_message = user_message,
        system_message = system_message
    }

    local json_str = cjson.encode(hash)

    cgilua.jrStatus(status)
    cgilua.contentheader ("application", "json; charset=ISO-8859-1")
    cgilua.header("Vary", "Accept-Encoding")
    cgilua.put(json_str) 

end


return M
