
local M = {}

local utils = require "utils"


function M.get_cgi_params()

    local arr = {}

    -- local env_var = "PATH_INFO"
    local env_var = "REQUEST_URI"

    if os.getenv(env_var) == nil then
        return arr
    end

    local path_info = os.getenv(env_var)

    path_info = string.gsub(path_info, "/sora.lua", "") 

    path_info = string.gsub(path_info, ".html", "") 

    path_info = string.gsub(path_info, "/api/v1", "") -- api code

    if string.find(path_info, "/sora/") ~= nil then
        path_info = string.gsub(path_info, "/sora/", "/") -- client-side code
        -- path_info = "/" .. path_info -- why is this needed?
    end

    if string.find(path_info, "?") ~= nil then
        local a = utils.split(path_info, "?")
        path_info = a[1]
    end

    arr = utils.split(path_info, "/")

    return arr
 
end

-- if true then return "DEBUG " .. path_info end

return M
