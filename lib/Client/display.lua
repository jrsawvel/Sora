
local M = {}

-- installed modules
local cgilua = require "cgilua"
local cookies = require "cgilua.cookies"
local urlcode = require "cgilua.urlcode"

-- my modules
local page   = require "page"
local config = require "config"


function M.do_invalid_function(a_params)
    local action = "unknown"

    if a_params ~= nil and #a_params > 0 then
        action = a_params[1]
    end

    M.report_error("user", "Invalid client action: " .. action, "It's not supported.")
end


function M.report_error(errtype, cusmsg, sysmsg)
    local tmpl = errtype .. "error"

    page.set_template_name(tmpl)

    page.set_template_variable("cusmsg", cusmsg)

    if errtype == "user" then
        page.set_template_variable("sysmsg", sysmsg)
    elseif errtype == "system" and config.get_value_for("debug_mode") then
        page.set_template_variable("sysmsg", sysmsg)
    end

    local html_output = page.get_output("Error")

    cgilua.htmlheader()
    cgilua.put(html_output)
end


function M.web_page(html_output)
    cgilua.htmlheader()
    cgilua.put(html_output)
end


function M.redirect_to(url)
    cgilua.redirect (url)
end


function M.set_cookie(cname, cvalue, ctable)
    cookies.set(cname, cvalue, ctable)
end


function M.get_cookie(cname)
    return cookies.get(config.get_value_for("cookie_prefix") .. cname)
end


function M.unescape(str)
    return urlcode.unescape(str)
end


function M.escape(str)
    return urlcode.escape(str)
end


function M.get_POST_value_for(name)
    return cgilua.POST[name]
end



function M.get_query_info()
    local str;
    local t = {}
    -- ?bird=warbler
--    urlcode.parsequery (os.getenv("QUERY_STRING"), t)
--    M.report_error("user", "debug",  t.bird)
end


function M.success(title, para1, para2)

    page.set_template_name("success")

    if title == nil or title == "" then
        title = "Success"
    end

    if para1 == nil then
        para1 = ""
    end

    if para2 == nil then
        para2 = ""
    end

    page.set_template_variable("para1", para1)
    page.set_template_variable("para2", para2)

    local html_output = page.get_output(title)
    cgilua.htmlheader()
    cgilua.put(html_output)

end



return M

