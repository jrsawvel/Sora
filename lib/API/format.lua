

local M = {}

local rex = require "rex_pcre"
local markdown = require "markdown"


local rj      = require "returnjson"
local utils   = require "utils"



function M.calc_reading_time_and_word_count(html)

    local text = utils.remove_html(html)

    local hash = {}

    local dummy, n = text:gsub("%S+","") -- n = substitutions

    hash.word_count   = n or 0

    hash.reading_time = 0  -- minutes

    if hash.word_count >= 180 then
        hash.reading_time = math.floor(hash.word_count / 180) 
    end

    return hash

end

 

-- <!-- toc:yes -->  except that no YES/NO commands exist in Sora at the moment. 
-- this function is unused.
function M.get_power_command_on_off_setting_for(command, str, default_bool) 

    local return_bool = default_bool

    local tmp_str = rex.match(str, "^<!--[ ]*" .. command .. "[ ]*:[ ]*(.*)[ ]*-->", 1, "im")

    if tmp_str ~= nil then   
        local string_value = utils.trim_spaces(string.lower(tmp_str))
        if string_value == "no" then
            return_bool = false
        elseif string_value == "yes" then 
            return_bool = true 
        end 
    else
    end
 
    return return_bool

end



function M.extract_css(str)

    local return_data = {}

    str = rex.gsub(str, "^css_end -->", "</css>", nil, "im")
    str = rex.gsub(str, "^<!-- css_start", "<css>", nil, "im")

    local pre_css, tmp_css, tmp_markup = rex.match(str, "^(.*)<css>(.*)</css>(.*)$", 1, "is")

    if pre_css ~= nil and tmp_css ~= nil and tmp_markup ~= nil then
        return_data.markup = pre_css .. tmp_markup
        return_data.custom_css = tmp_css
--rj.report_error("400", return_data.markup, return_data.custom_css)
    else
        return_data.markup = str
        return_data.custom_css = nil
--rj.report_error("400", return_data.markup, "no custom css found")
    end 

    return return_data
    
end



function M.extract_json(str)

    str = rex.gsub(str, "^json_end -->", "</jsontmp>", nil, "im")
    str = rex.gsub(str, "^<!-- json_start", "<jsontmp>", nil, "im")

    local pre_json, tmp_json, tmp_markup = rex.match(str, "^(.*)<jsontmp>(.*)</jsontmp>(.*)$", 1, "is")

    if tmp_json ~= nil then 
        return utils.trim_spaces(tmp_json)
    else
        return nil
    end
end



function _custom_commands(str)

    str = rex.gsub(str, "^c[.][.]", "</code></pre>", nil, "im")
    str = rex.gsub(str, "^c[.]", "<pre><code>", nil, "im")

--    str = rex.gsub(str, "^q[.][.]", "\n</blockquote>", nil, "im")
--    str = rex.gsub(str, "^q[.]", "<blockquote>\n", nil, "im")

    return str

end



function M.markup_to_html(markup)

    local html = _custom_commands(markup)

    html = markdown(html)

    return html

end




return M
