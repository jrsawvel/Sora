
local M = {}

-- external modules
local cjson   = require "cjson"

-- my modules
local page      = require "page"
local display   = require "display"
local config    = require "config"
local httputils = require "httputils"



function M.logout()
    local author_name  = display.get_cookie("author_name")
    local session_id   = display.get_cookie("session_id")
    local rev          = display.get_cookie("rev")

    if author_name == nil or session_id == nil or rev == nil then
        display.report_error("user", "Unable to complete action.", "You are not logged in.")
    else

        local query_string = "/?author=" .. author_name .. "&session_id=" .. session_id .. "&rev=" .. rev

        local api_url = config.get_value_for("api_url") .. "/users/logout"
        api_url = api_url .. query_string

        local response_body, status_code, headers_table, status_string = httputils.get_unsecure_web_page(api_url)

        local h_json = cjson.decode(response_body)

        if status_code >= 200 and status_code < 300 then
            local cookie_prefix = config.get_value_for("cookie_prefix")
            local cookie_domain = config.get_value_for("domain_name")

            local t = os.date("*t", os.time())
            local e = os.time({year = t.year - 10, month=t.month, day=t.day, hour=t.hour, min=t.min, sec=t.sec})

            local cookies_table = {path = "/", expires = e, domain = "." .. cookie_domain}

            display.set_cookie(cookie_prefix .. "author_name", "0",  cookies_table)
            display.set_cookie(cookie_prefix .. "session_id",  "0",  cookies_table)
            display.set_cookie(cookie_prefix .. "rev",         "0",  cookies_table)

            display.redirect_to(config.get_value_for("home_page"))
        elseif status_code >= 400 and status_code < 500 then
            display.report_error("user", h_json["user_message"], h_json["system_message"])
        else
            display.report_error("user", "Unable to complete request.", "Invalid response code returned from API. " .. h_json["user_message"] .. " - " .. h_json["system_message"])
        end

    end

end



function M.show_login_form(a_params)
    page.set_template_name("loginform")
    page.set_template_variable("css_dir_url", config.get_value_for("css_dir_url"))
    local html_output = page.get_output("Login Form")
    display.web_page(html_output) 
end



function M.do_login(a_params)

    local email = display.get_POST_value_for("email")

    if email == nil then
        display.report_error("user", "Invalid input.", "No data was submitted")
    else
        local api_url = config.get_value_for("api_url")
        local post_url = api_url .. "/users/login"
        local request_body = { 
            email = email,
            url   = config.get_value_for("home_page") .. "/sora/nopwdlogin"
        }
        local json_text = cjson.encode(request_body)
   
        local response_body, status_code, headers_table, status_string = httputils.unsecure_json_post(post_url, json_text)

        local h_json = cjson.decode(response_body)

        if status_code >= 200 and status_code < 300 then
            display.success("Creating New Login Link", "A new login link has been created and sent.", "")
        elseif status_code >= 400 and status_code < 500 then
            display.report_error("user", "Unable to complete request.", "Invalid data provided. " .. h_json["user_message"] .. " - " .. h_json["system_message"])
        else
            display.report_error("user", "Unable to complete request.", "Invalid response code returned from API. " .. h_json["user_message"] .. " - " .. h_json["system_message"])
        end

    end        
end



function M.no_password_login(a_params)

    local rev

    if a_params[2] == nil then
        display.report_error("user", "Unable to login.", "Insufficient data provided.")
    else
        rev = a_params[2]
        local api_url = config.get_value_for("api_url") .. "/users/login/?rev=" .. rev

        local response_body, status_code, headers_table, status_string = httputils.get_unsecure_web_page(api_url)

        local h_json = cjson.decode(response_body)

        if status_code >= 200 and status_code < 300 then
            local cookie_prefix = config.get_value_for("cookie_prefix")
            local cookie_domain = config.get_value_for("domain_name")
 
            local author_name = h_json["author_name"]
            local session_id  = h_json["session_id"]
            rev               = h_json["rev"]
            
            local t = os.date("*t", os.time())
            local e = os.time({year = t.year+10, month=t.month, day=t.day, hour=t.hour, min=t.min, sec=t.sec})

            local cookies_table = {path = "/", expires = e, domain = "." .. cookie_domain}

            display.set_cookie(cookie_prefix .. "author_name", author_name, cookies_table)
            display.set_cookie(cookie_prefix .. "session_id",  session_id,  cookies_table)
            display.set_cookie(cookie_prefix .. "rev",         rev,         cookies_table)

            display.redirect_to(config.get_value_for("home_page"))

-- optional:
--            page.set_template_name("loginsuccess")
--            local html_output = page.get_output("Successfully Logged In")
--            display.web_page(html_output) 

        elseif status_code >= 400 and status_code < 500 then
            display.report_error("user", h_json["user_message"], h_json["system_message"])
        else
            display.report_error("user", "Unable to complete request.", "Invalid response code returned from API. " .. h_json["user_message"] .. " - " .. h_json["system_message"])
        end

    end
end

return M
