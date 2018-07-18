
local M = {}

local rex = require "rex_pcre"



local MAX_TITLE_LEN = 150

local TITLE = {
    max_title_len       =  MAX_TITLE_LEN,
    after_title_markup  =  nil,
    is_error            =  false,
    error_message       =  nil,
    title               =  nil,
    slug                =  nil,
    post_type           = "article" 
}


function M.process(markup)

    local t = TITLE

    local tmp_title = rex.match(markup, "(.+)", 1, "m")

    if tmp_title ~= nil then
        if string.len(tmp_title) < t.max_title_len+1 then
            local tmp_title_len = string.len(tmp_title)
            t.title = tmp_title
            local tmp_total_len = string.len(markup)
            t.after_title_markup = string.sub(markup, tmp_title_len+1)
        else
            t.title = string.sub(markup, 1, t.max_title_len)
            local tmp_total_len = string.len(markup)
            t.after_title_markup = string.sub(markup, t.max_title_len+1)
       end
    end 

    if t.title == nil then
        t.is_error = true
        t.error_message = "You must give a title for your post."
    else
        local tmp_title_2 = string.match(t.title, '^#%s*(.+)')

        if tmp_title_2 ~= nil then
            t.title = tmp_title_2 
            t.post_type = "article"
        else 
            t.post_type = "note"
            t.after_title_markup = markup
            if string.len(t.title) > 75 then
                t.title = string.sub(t.title, 1, 75)
            end
        end 
       
        t.title = _trim_spaces(t.title) 
        t.title = string.gsub(t.title, "<", "&lt;")
        t.title = string.gsub(t.title, ">", "&gt;")
        t.slug  = _clean_title(t.title)
    end

    return t 

end



function _trim_spaces (str)
    if (str == nil) then
        return ""
    end
   
    -- remove leading spaces 
    str = string.gsub(str, "^%s+", "")

    -- remove trailing spaces.
    str = string.gsub(str, "%s+$", "")

    return str
end



function _clean_title(str)
    str = string.gsub(str, "-", "")
    str = string.gsub(str, " ", "-")
    str = string.gsub(str, ":", "-")
    str = rex.gsub(str, "--", "")
    str =  rex.gsub(str, "[^-a-zA-Z0-9]","")
    return string.lower(str)
end


return M
