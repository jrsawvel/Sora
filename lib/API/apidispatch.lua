
local M = {}

-- installed modules
local cgilua = require "cgilua"


-- my modules
local requri    = require "requri"
local users     = require "users"
local posts     = require "posts"
local searches  = require "searches"
local rj        = require "returnjson"


function M.execute()
    local a_cgi_params = requri.get_cgi_params()

    local subs = { 
                     posts     = posts.posts,
                     users     = users.users,
                     searches  = searches.searches,
                     showerror = rj.show_error
                 }

    if a_cgi_params == nil or #a_cgi_params == 0 then
         rj.report_error("400", "Cannot complete API request.", "No action given.")
    else
        local action = a_cgi_params[1]
        if subs[action] ~= nil then
            subs[action](a_cgi_params)
        else
            subs.showerror(a_cgi_params)
        end          
    end

end

    cgilua.seterroroutput (function (s)
        s = string.gsub (string.gsub (s, "\n", "<br>\n"), "\t", "  ")
        rj.report_error("500", "Server error", s)
    end)

return M
