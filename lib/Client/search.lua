
local M = {}


-- external modules
local cjson   = require "cjson"

-- my modules
local display   = require "display"
local utils     = require "utils"
local config    = require "config"
local httputils = require "httputils"
local page      = require "page"


function M.do_search(a_params)

    local author_name  = display.get_cookie("author_name")
    local session_id   = display.get_cookie("session_id")
    local rev          = display.get_cookie("rev")

    if author_name == nil or session_id == nil or rev == nil then
        display.report_error("user", "Unable to complete action.", "You are not logged in.")
    else
        local query_string = "?author=" .. author_name .. "&session_id=" .. session_id .. "&rev=" .. rev

        local search_string = nil 

        local request_method = os.getenv("REQUEST_METHOD")

        if request_method == "GET" then
            search_string = a_params[2]
            if search_string ~= nill then
                search_string = display.unescape(search_string)
            end
        elseif request_method == "POST" then
            search_string = display.get_POST_value_for("keywords")  
        end

        search_string = utils.trim_spaces(search_string)

        if search_string == nil or search_string == "" then
            display.report_error("user", "Missing data.", "Enter keyword(s) to search on.")
        else

            local search_uri_str = display.escape(search_string)

            local api_url = config.get_value_for("api_url") .. "/searches/" .. search_uri_str
            api_url = api_url .. query_string

            local response_body, status_code, headers_table, status_string = httputils.get_unsecure_web_page(api_url)

            local h_json = cjson.decode(response_body)
 
            if status_code >= 400 and status_code < 500 then
                display.report_error("user", h_json["user_message"], h_json["system_message"])
            else
                if h_json.total_hits == 0 then
                    display.success("No search results found", "Search results for '" .. search_string .. "'", "No matches were found.")
                else
                    local stream = h_json.posts    
                    page.set_template_name("searchresults")
                    page.set_template_variable("stream_loop", stream)
                    page.set_template_variable("keyword", search_string)
                    page.set_template_variable("search_uri_str", search_uri_str) 
                    display.web_page(page.get_output("Search results for " .. search_string))
               end
            end

        end

    end
end

return M
