

local M = {}


local cgilua  = require "cgilua"
local urlcode = require "cgilua.urlcode"
local cjson   = require "cjson"
local rex     = require "rex_pcre"


local session = require "session"
local utils   = require "utils"
local rj      = require "returnjson"
local title   = require "title"
local format  = require "format"
local config  = require "config"
local files   = require "files"


function M.create_post()

    local json_text = cgilua.POST[1]

    local hash = cjson.decode(json_text)

    local logged_in_author_name = hash.author
    local session_id            = hash.session_id
    local rev                   = hash.rev
   
    if session.is_valid_login(logged_in_author_name, session_id, rev) == false then 
        rj.report_error("400", "Unable to peform action.", "You are not logged in.")
    else
        local submit_type = hash.submit_type
        if submit_type ~= "Preview" and submit_type ~= "Create" then
            rj.report_error("400", "Unable to process post.", "Invalid submit type given.")
        else
           local original_markup = hash.markup
           local markup = utils.trim_spaces(original_markup)
           if markup == nil or markup == "" then
               rj.report_error("400", "Invalid post.", "You must enter text.")
           else
               local form_type = hash.form_type
               if form_type ~= nill and form_type == "ajax" then
                   markup = urlcode.unescape(markup) 
                   markup = utils.encode_extended_ascii(markup) 
               end

               local t = title.process(markup)
               if t.is_error then
                   rj.report_error("400", "Error creating post.", t.error_message)
               else
                   local page_data   = format.extract_css(t.after_title_markup)
                   local html        = format.markup_to_html(page_data.markup)
                   local post_stats  = format.calc_reading_time_and_word_count(html) -- returns hash

                   local post_hash = {}
                   -- post_hash.pretty_date_time = os.date("%a, %b %d, %Y - %I:%M %p Z")
                     -- can assemble these two items into ISO 8601 format 2018-04-05T23:45:17Z
                   post_hash.created_date   = os.date("%Y-%m-%d") -- 2018-04-05 = year, month, day
                   post_hash.created_time   = os.date("%X") -- 23:45:17 in GMT
                   post_hash.html           = html
                   post_hash.title          = t.title
                   post_hash.slug           = t.slug
                   post_hash.post_type      = t.post_type
                   post_hash.reading_time   = post_stats.reading_time
                   post_hash.word_count     = post_stats.word_count 
                   post_hash.author         = config.get_value_for("author_name")
                   post_hash.custom_css     = page_data.custom_css
                   post_hash.custom_json    = format.extract_json(t.after_title_markup)

                   local tmp_diff_slug = rex.match(markup, "^<!--[ ]*slug[ ]*:[ ]*(.+)[ ]*-->", 1, "im")
                   if tmp_diff_slug ~= nil then
                       post_hash.slug = utils.trim_spaces(tmp_diff_slug)
                   end 

                   local tmp_tmpl = rex.match(markup, "^<!--[ ]*template[ ]*:[ ]*(.+)[ ]*-->", 1, "im")
                   if tmp_tmpl ~= nil then
                       post_hash.template = utils.trim_spaces(tmp_tmpl)
                   end 

                   local tmp_dir = rex.match(markup, "^<!--[ ]*dir[ ]*:[ ]*(.+)[ ]*-->", 1, "im")
                   if tmp_dir ~= nil then
                       post_hash.dir = utils.trim_spaces(tmp_dir)
                       -- remove ending forward slash if it exists
                       if rex.match(post_hash.dir, "[/]$") ~= nil then
                           post_hash.dir = string.sub(post_hash.dir, 1, -2)
                       end
                       post_hash.location = config.get_value_for("home_page") .. "/" .. post_hash.dir .. "/" .. post_hash.slug .. ".html"   
                   else
                       post_hash.location = config.get_value_for("home_page") .. "/" .. post_hash.slug .. ".html"   
                   end

                  if post_hash.dir ~= nil and rex.match(post_hash.dir, "^[a-zA-Z0-9]") == nil then
                      rj.report_error("400", "Invalid directory: [" .. post_hash.dir .. "]", "Directory structure must start with alpha-numeric.")
                  else

                      local rc_boolean = true

                      if submit_type == "Create" then
                          rc_boolean = files.output("create", post_hash, markup)
                      end

                      if rc_boolean == true then
                          rj.success(post_hash)
                      end
                  end
--                   rj.report_error("400", t.title .. "<br>" .. t.slug .. "<br><br>" .. t.after_title_markup, t.post_type .. "<br><br>" .. page_data.custom_css .. "<br><br><h3>markup</h3>" .. page_data.markup)
-- rj.report_error("400", "HTML=", html)
               end
           end
        end 
    end

end



return M
