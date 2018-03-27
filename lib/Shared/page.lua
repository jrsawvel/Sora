
-- module: page.lua

local M = {}

local io       = require "io"
local lustache = require "lustache"

local config   = require "config"
local utils    = require "utils"

M.template_text = ""

M.view_model = {}

partials = {}


function M.set_template_name(tmpl_name)
    local tmpl_home = config.get_value_for("template_home")
    local filename = tmpl_home .. "/" .. tmpl_name .. ".mustache"
    local f = assert(io.open(filename, "r"))
    M.template_text = f:read("a")
    f:close()
    process_includes()
end


function M.set_template_variable(var_key, var_val)
    M.view_model[var_key] = var_val
end


function M.get_output(title)
    local site_name = config.get_value_for("site_name")
    M.set_template_variable("pagetitle", title .. " - " .. site_name )
    M.set_template_variable("site_name", site_name)
    M.set_template_variable("home_page", config.get_value_for("home_page"))
    M.set_template_variable("maincss_url", config.get_value_for("maincss_url"))
    M.set_template_variable("pagecreateddate", utils.get_date_time())
    return lustache:render(M.template_text, M.view_model, partials)
end


function M.get_output_min()
    return lustache:render(M.template_text, M.view_model, partials)
end


function process_includes()
    local partial_name 
    for partial_name in string.gmatch(M.template_text, '{{> ([%w_]*)}}') do
        read_partial(partial_name)    
    end
end


function read_partial(partial_tmpl_name)
    local tmpl_home = config.get_value_for("template_home")
    local filename = tmpl_home .. "/" .. partial_tmpl_name .. ".mustache"
    local f = assert(io.open(filename, "r"))
    partials[partial_tmpl_name] = f:read("a")
    f:close()
end


return M

