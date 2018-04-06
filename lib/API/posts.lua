
local M = {}


local cgilua = require "cgilua"


local rj     = require "returnjson"
local create = require "create"


function M.posts()

    local request_method = cgilua.servervariable("REQUEST_METHOD")

    if request_method == "POST" then
        create.create_post()
    else
        rj.report_error("400", "Not found", "Invalid request $request_method")
    end

end


return M


