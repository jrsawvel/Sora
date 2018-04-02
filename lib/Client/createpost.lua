

local M = {}


local cjson = require "cjson"

local display   = require "display"
local page      = require "page"
local config    = require "config"
local httputils = require "httputils"
local utils     = require "utils"



function M.show_new_post_form()

    local author_name  = display.get_cookie("author_name")
    local session_id   = display.get_cookie("session_id")
    local rev          = display.get_cookie("rev")

    if author_name == nil or session_id == nil or rev == nil then
        display.report_error("user", "Cannot perform action.", "You are not logged in.")
    else
        page.set_template_name("newpostform")
        page.set_template_variable("css_dir_url", config.get_value_for("css_dir_url"))
        display.web_page(page.get_output("Create new post"))
    end
end





function M.create_post()

    local author_name  = display.get_cookie("author_name")
    local session_id   = display.get_cookie("session_id")
    local rev          = display.get_cookie("rev")

    local submit_type     = display.get_POST_value_for("sb")  --  Preview or Create
    local original_markup = display.get_POST_value_for("markup")

    local markup = utils.encode_extended_ascii(original_markup)
  
    local api_url = config.get_value_for("api_url")
    local post_url = api_url .. "/posts"

    local request_body = { 
        author      = author_name,
        session_id  = session_id,
        rev         = rev,
        submit_type = submit_type,
        markup      = markup 
    }
    local json_text = cjson.encode(request_body)
   
    local response_body, status_code, headers_table, status_string = httputils.unsecure_json_post(post_url, json_text)

    local h_json = cjson.decode(response_body)

    if status_code >= 200 and status_code < 300 then
        if submit_type == "Preview" then
            page.set_template_name("newpostform")
            page.set_template_variable("css_dir_url", config.get_value_for("css_dir_url"))
            page.set_template_variable("previewingpost", true)
            page.set_template_variable("markup", original_markup)
            page.set_template_variable("html", h_json.html)
            page.set_template_variable("title", h_json.title)
            display.web_page(page.get_output("Create new post"))
        elseif submit_type == "Create" then
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



function M.show_editor_create() 

    local author_name  = display.get_cookie("author_name")
    local session_id   = display.get_cookie("session_id")
    local rev          = display.get_cookie("rev")

    if author_name == nil or session_id == nil or rev == nil then
        display.report_error("user", "Cannot perform action.", "You are not logged in.")
    else
        page.set_template_name("tanager")
        page.set_template_variable("action", "addarticle")
        page.set_template_variable("api_url", config.get_value_for("api_url"))
        page.set_template_variable("post_id", "0")
        page.set_template_variable("post_rev", "undef")
        display.web_page(page.get_output_min("Creating Post - Editor"))
    end
end

return M
