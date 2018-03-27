
local M = {}


local cjson = require "cjson"
local entities = require "htmlEntities"

local display   = require "display"
local page      = require "page"
local config    = require "config"
local httputils = require "httputils"
local utils     = require "utils"



function M.show_post_to_edit(a_params)

    local author_name  = display.get_cookie("author_name")
    local session_id   = display.get_cookie("session_id")
    local rev          = display.get_cookie("rev")

    if author_name == nil or session_id == nil or rev == nil then
        display.report_error("user", "Cannot perform action.", "You are not logged in.")
    else
        local post_id = a_params[2]   -- in this app, id = the slug or post uri 
        local original_slug = post_id
 
        local query_string = "?author=" .. author_name .. "&session_id=" .. session_id .. "&rev=" .. rev
        query_string = query_string .. "&text=markup"

        local api_url = config.get_value_for("api_url") .. "/posts/" .. post_id

        api_url = api_url .. query_string
     
        local response_body, status_code, headers_table, status_string = httputils.get_unsecure_web_page(api_url)

        local h_json = cjson.decode(response_body)

        if status_code >= 200 and status_code < 300 then
            page.set_template_name("updatepostform")
            page.set_template_variable("html_file", post_id .. ".html")
            page.set_template_variable("original_slug", original_slug)
            page.set_template_variable("post_id", post_id)
            page.set_template_variable("markup", entities.decode(h_json.markup))    
            page.set_template_variable("css_dir_url", config.get_value_for("css_dir_url"))
            display.web_page(page.get_output("Updating Post "))
        elseif status_code >= 400 and status_code < 500 then
            display.report_error("user", h_json["user_message"], h_json["system_message"])
        else
            display.report_error("user", "Unable to complete request.", "Invalid response code returned from API. " .. h_json["user_message"] .. " - " .. h_json["system_message"])
        end

    end
end



function M.update_post()

    local author_name  = display.get_cookie("author_name")
    local session_id   = display.get_cookie("session_id")
    local rev          = display.get_cookie("rev")

    local submit_type     = display.get_POST_value_for("sb")  --  Preview or Update
    local original_markup = display.get_POST_value_for("markup")
    local original_slug   = display.get_POST_value_for("original_slug")

    local markup = utils.encode_extended_ascii(original_markup)
  
    local api_url = config.get_value_for("api_url")
    local post_url = api_url .. "/posts"

    local request_body = { 
        author      = author_name,
        session_id  = session_id,
        rev         = rev,
        submit_type = submit_type,
        markup      = markup,
        original_slug = original_slug 
    }
    local json_text = cjson.encode(request_body)
   
    local response_body, status_code, headers_table, status_string = httputils.unsecure_json_put(post_url, json_text)

    local h_json = cjson.decode(response_body)

    if status_code >= 200 and status_code < 300 then
        if submit_type == "Preview" then
            page.set_template_name("updatepostform")
            page.set_template_variable("css_dir_url", config.get_value_for("css_dir_url"))
            page.set_template_variable("previewingpost", true)
            page.set_template_variable("markup", original_markup)
            page.set_template_variable("html", h_json.html)
            page.set_template_variable("html_file", h_json["post_id"] .. ".html")
            page.set_template_variable("original_slug", original_slug)
            page.set_template_variable("post_id", h_json["post_id"])
            page.set_template_variable("title", h_json.title)
            display.web_page(page.get_output("Previewing updated post"))
        elseif submit_type == "Update" then
            display.redirect_to(h_json.location)
        else 
            display.report_error("user", "Unable to complete request.", "Invalid submit type: " .. submit_type .. ".")
        end
    elseif status_code >= 400 and status_code < 500 then
        display.report_error("user", h_json["user_message"], h_json["system_message"])
    else
        display.report_error("user", "Unable to complete request.", "Invalid response code returned from API. " .. h_json["user_message"] .. " - " .. h_json["system_message"])
    end

end



return M
