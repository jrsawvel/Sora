

local M = {}


local rex   = require "rex_pcre"
local io    = require "io"
local cjson = require "cjson"
local pretty = require "resty.prettycjson"


local page      = require "page"
local config    = require "config"
local rj        = require "returnjson"
local utils     = require "utils"




function _create_hfeed_file(hash, stream)

    local max_entries = config.get_value_for("max_entries")
    local mft_stream = {}

    for i=1, max_entries and #stream do
        table.insert(mft_stream, stream[i])
    end

    page.set_template_name("hfeed")
    page.set_template_variable("site_name", config.get_value_for("site_name"))
    page.set_template_variable("site_description", config.get_value_for("site_description"))
    page.set_template_variable("article_loop", mft_stream)

    local hfeed_output = page.get_output("MicroFormats h-feed of h-entries")

    local hfeed_filename = config.get_value_for("default_doc_root") .. "/" .. config.get_value_for("hfeed_file")

    local o = io.open(hfeed_filename, "w")
    if o == nil then
        rj.report_error("400", "Could not open h-feed file for write.", "")
        return false
    else
        o:write(hfeed_output .. "\n")
        o:close()
    end

    return true

end



function _update_links_json_file(hash)

    local filename = config.get_value_for("links_json_file_storage") .. "/" .. config.get_value_for("links_json_file")

    local json_text = ""

    local stream = {}

    local f = io.open(filename, "r")
    if f == nil then
        rj.report_error("400", "Could not open links JSON file for read.", "")
        return false
    else
        for line in f:lines() do
            json_text = json_text .. line
        end

        local t = cjson.decode(json_text)

        stream = t.posts

        local tmp_hash = {
            title = hash.title,
            created = hash.created_date .. "T" .. hash.created_time .. "Z",
            author = hash.author 
        }

        if hash.dir ~= nil then
            tmp_hash.url = config.get_value_for("home_page") .. "/" .. hash.dir .. "/" .. hash.slug .. ".html"
        else
            tmp_hash.url = config.get_value_for("home_page") .. "/" .. hash.slug .. ".html"
        end

        table.insert(stream, 1, tmp_hash)

        t.posts = stream 

        json_text = pretty(t)

--        json_text = cjson.encode(t)

        local o = io.open(filename, "w")
        if o == nil then
            rj.report_error("500", "Unable to open links JSON file for write.", filename)
            return false
        else
            o:write(json_text .. "\n")
            o:close()
        end
    end

    return stream

end



function _save_markup_to_web_directory(submit_type, markup, hash)

    local markup_filename

    if hash.dir ~= nil then
        markup_filename = config.get_value_for("default_doc_root") .. "/" .. hash.dir .. "/" .. hash.slug .. ".txt"
    else 
        markup_filename = config.get_value_for("default_doc_root") .. "/" .. hash.slug .. ".txt"
    end
 
    if rex.match(markup_filename, "^[a-zA-Z0-9/%.%-_]+$") == nil then
        rj.report_error("500", "Bad file name or directory path.", "Could not write markup for post id: " .. hash.title .. " filename: " .. markup_filename)
        return false
    else 

        local dir_path = config.get_value_for("default_doc_root") .. "/" .. hash.dir
        local r = os.execute("mkdir -p " .. dir_path)
        if r == false then
            rj.report_error("500", "Bad directory path.", "Could not create directory structure.")
            return false
        else
            local o = io.open(markup_filename, "w")
            if o == nil then
                rj.report_error("500", "Unable to open file for write.", "Post id: " .. hash.slug .. " filename: " .. markup_filename)
                return false
            else
                o:write(markup .. "\n")
                o:close()
            end
        end
    end

    return true

end



function _save_markup_to_storage_directory(submit_type, markup, hash)

    local save_markup = markup ..  "\n\n<!-- author_name: " .. config.get_value_for("author_name") .. " -->\n"
    save_markup = save_markup  ..  "<!-- published_date: "  .. hash.created_date .. " -->\n"
    save_markup = save_markup  ..  "<!-- published_time: "  .. hash.created_time .. " -->\n"

    local tmp_slug = hash.slug

    if hash.dir ~= nil then
        tmp_slug = utils.clean_title(hash.dir) .. "-" .. tmp_slug
    end 

    -- write markup to markup storage outside of document root
    -- if "create" then the file must not exist
    local domain_name = config.get_value_for("domain_name")
    local markup_filename = config.get_value_for("markup_storage") .. "/" .. domain_name .. "-" .. tmp_slug .. ".markup"

    if submit_type == "create" and io.open(markup_filename, "r") ~= nil then 
        rj.report_error("400", "Unable to create markup and HTML files because they already exist.", "Change title or do an 'update'.")
        return false
    else
        local o = io.open(markup_filename, "w")
        if o == nil then
            rj.report_error("500", "Unable to open file for write.", "Post id: " .. hash.slug .. " filename: " .. markup_filename)
            return false
        else
            o:write(save_markup .. "\n")
            o:close()
        end
    end

    return true

end



function _save_html(html, hash)

    local html_filename

    if hash.dir ~= nil then
        html_filename = config.get_value_for("default_doc_root") .. "/" .. hash.dir .. "/" .. hash.slug .. ".html"
    else 
        html_filename = config.get_value_for("default_doc_root") .. "/" .. hash.slug .. ".html"
    end
 
    if rex.match(html_filename, "^[a-zA-Z0-9/%.%-_]+$") == nil then
        rj.report_error("500", "Bad file name or directory path.", "Could not write html for post id: " .. hash.title .. " filename: " .. html_filename)
        return false
    else 

        local dir_path = config.get_value_for("default_doc_root") .. "/" .. hash.dir
        local r = os.execute("mkdir -p " .. dir_path)
        if r == false then
            rj.report_error("500", "Bad directory path.", "Could not create directory structure.")
            return false
        else
            local o = io.open(html_filename, "w")
            if o == nil then
                rj.report_error("500", "Unable to open file for write.", "Post id: " .. hash.slug .. " filename: " .. html_filename)
                return false
            else
                o:write(html .. "\n")
                o:close()
            end
        end
    end

    return true

end



function M.output(submit_type, hash, markup)

    if hash.template ~= nil then
        page.set_template_name(hash.template)
    elseif hash.post_type == "article" then
        page.set_template_name("articlehtml")
    else
        page.set_template_name("notehtml")
    end

    page.set_template_variable("html", hash.html)
    page.set_template_variable("title", hash.title)
    page.set_template_variable("created_date", hash.created_date)
    page.set_template_variable("created_time", hash.created_time)
    page.set_template_variable("author", hash.author)

    if hash.custom_css ~= nil then
        page.set_template_variable("using_custom_css", true)
        page.set_template_variable("custom_css", hash.custom_css)
    end

    local html_output = page.get_output(hash.title)

    if submit_type == "update" then 
        hash.slug = hash.original_slug
    end

    if submit_type == "rebuild" then
        _save_html(html_output, hash)
        return true
    end  

    if _save_markup_to_storage_directory(submit_type, markup, hash) == false then
        return false
    end

--    if submit_type == "update" then
--        _save_markup_to_backup_directory(submit_type, markup, hash)
--    end

    if _save_markup_to_web_directory(submit_type, markup, hash) == false then
        return false
    end

    if _save_html(html_output, hash) == false then
        return false
    end

    if submit_type == "create" then
        local stream = _update_links_json_file(hash)
        if _create_hfeed_file(hash, stream) == false then
            return false
        end
--        _create_jsonfeed_file(hash, stream)
rj.report_error("400", "debug", "okay")
return false
    end

    return true

end



return M
