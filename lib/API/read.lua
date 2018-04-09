

local M = {}


local cgilua = require "cgilua"

local files = require "files"
local rj    = require "returnjson"


function M.get_post(post_id)

    local author_name = cgilua.QUERY.author
    local session_id  = cgilua.QUERY.session_id
    local rev         = cgilua.QUERY.rev

-- no need to require user to be logged in to retrieve markup.

--    if session.is_valid_login(author_name, session_id, rev) == false then 
--        rj.report_error("400", "Unable to peform action.", "You are not logged in.")
--    else

        local hash = {}
        hash.slug = post_id
        hash.markup = files.read_markup_file(post_id)        
        rj.success(hash)

--    end

end



return M
