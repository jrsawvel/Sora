

local M = {}

local cgilua  = require "cgilua"
local urlcode = require "cgilua.urlcode"
local rex     = require "rex_pcre"

local session = require "session"
local config  = require "config"
local utils   = require "utils"
local rj      = require "returnjson"


function M.searches(a_params)

    local author_name = cgilua.QUERY.author
    local session_id  = cgilua.QUERY.session_id
    local rev         = cgilua.QUERY.rev

    if session.is_valid_login(author_name, session_id, rev) == false then 
        rj.report_error("400", "Unable to peform action.", "You are not logged in.")
    else
        local posts = {}

        local total_hits = 0
  
        local search_text = a_params[2]

        search_text = urlcode.unescape(search_text)

        -- remove unnacceptable chars from the search string
        search_text = rex.gsub(search_text, "[^A-Za-z0-9 _'%-%#%.]", "", nil, "sx")

        local default_doc_root = config.get_value_for("default_doc_root")

        local search_results_filename = config.get_value_for("searches_storage") .. "/" .. os.time() .. ".txt"

        local grep_cmd = "grep -i -R --exclude-dir=versions --include='*.txt' -m 1 '" .. search_text .. "' " .. default_doc_root .. " > " .. search_results_filename

        local r = os.execute(grep_cmd)

        if r == true then
            local f = io.open(search_results_filename, "r")

            if f == nil then
                rj.report_error("400", "Could not open search results file for read.", "")
            else
                local home_page = config.get_value_for("home_page")
                for line in f:lines() do
                    local tmp_array = utils.split(line, ".txt:")
                    local tmp_str = rex.gsub(tmp_array[1], default_doc_root .. "/" , "")
                    local tmp_hash = {
                        uri = tmp_str,
                        url = home_page .. "/" .. tmp_str .. ".html"
                    }
                    table.insert(posts, tmp_hash)
                    total_hits = total_hits + 1
                end
                f:close()
                local hash = {
                    total_hits = total_hits,
                    search_text = search_text,
                    posts = posts
                }
                
                rj.success(hash) 
            end
        else
            rj.report_error("400", "Unable to execute search.", grep_cmd)
        end

    end
end


return M

