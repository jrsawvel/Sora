
local M = {}

-- installed modules

-- my modules
local requri     = require "requri"
local user       = require "user"
local display    = require "display"
local search     = require "search"
local createPost = require "createPost"
local updatePost = require "updatePost"


function M.execute()
    local a_cgi_params = requri.get_cgi_params()


    local subs = { 
                   search     = search.do_search,
                   login      = user.show_login_form,
                   dologin    = user.do_login,
                   nopwdlogin = user.no_password_login, 
                   logout     = user.logout,
                   create     = createPost.show_new_post_form, 
                   createpost = createPost.create_post,
                   update     = updatePost.show_post_to_edit,
                   updatepost = updatePost.update_post,
                   showerror  = display.do_invalid_function
                 }


    if a_cgi_params == nil or #a_cgi_params == 0 then
         display.report_error("user", "Cannot complete request.", "No action given.")
    else
        local action = a_cgi_params[1]
        if subs[action] ~= nil then
            subs[action](a_cgi_params)
        else
            subs.showerror(a_cgi_params)
        end          
    end
end

return M
