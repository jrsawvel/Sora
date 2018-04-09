
local M = {}


local cgilua = require "cgilua"


local rj     = require "returnjson"
local create = require "create"
local read   = require "read"
local update = require "update"


function M.posts(a_params)

    local request_method = cgilua.servervariable("REQUEST_METHOD")

    if request_method == "POST" then
        create.create_post()
    elseif request_method == "GET" then
        local post_id = ""
        if #a_params > 2 then
            for i=2, #a_params do
                post_id = post_id .. a_params[i]
                if i < #a_params then
                    post_id = post_id .. "/"
                end
            end    
        else
            post_id = a_params[2]   -- in this app, id = the slug or post uri 
        end
        read.get_post(post_id)
    elseif request_method == "PUT" then
        update.update_post()
    else
        rj.report_error("400", "Not found", "Invalid request " .. request_method .. ".")
    end
end


return M


