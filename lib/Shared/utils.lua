
-- module: utils.lua

local M = {}

local ltn12 = require "ltn12"
local http  = require "socket.http"
local rex   = require "rex_pcre"
local https = require "ssl.https"




function M.url_to_link(str)
    str = " " .. str
    for w, p, d in rex.gmatch(str, "([\\s])(\\w+://)([.A-Za-z0-9?=:|;,_#^\\-/%+&~\\(\\)@!]+)", "is", nil) do
--        str = rex.gsub(str, "[\\s]" .. p .. d, ' <a href="' .. p .. d .. '">' .. p .. d .. '</a>', nil, "is")
        str = rex.gsub(str, w .. p .. d, w .. '<a href="' .. p .. d .. '">' .. p .. d .. '</a>', nil, "is")
    end
    return str
end




function M.clean_title(str)
    str = string.gsub(str, "-", "")
    str = string.gsub(str, " ", "-")
    str = string.gsub(str, ":", "-")
    str = rex.gsub(str, "--", "")
    str =  rex.gsub(str, "[^-a-zA-Z0-9]","")
    return string.lower(str)
end



-- https://gist.github.com/ignisdesign/4323051
function M.urlencode(str)
   if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w ])",
         function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
   end
   return str    
end



function M.create_random_string(length) 

    -- https://gist.github.com/haggen/2fd643ea9a261fea2094

    local charset = {}  do -- [0-9a-zA-Z]
        for c = 48, 57  do table.insert(charset, string.char(c)) end
        for c = 65, 90  do table.insert(charset, string.char(c)) end
        for c = 97, 122 do table.insert(charset, string.char(c)) end
    end

    math.randomseed(os.time())

    if not length or length <= 0 then return '' end

    return M.create_random_string(length - 1) .. charset[math.random(1, #charset)]

end



function M.get_web_page(url)
    local body,code,headers,status = https.request(url)
    return body,code,headers,status
end


function M.get_unsecure_web_page(url)
    local content = {}
    local ua = "Mozilla/5.0 (X11; CrOS armv7l 9901.77.0) AppleWebKit/537.36"
    ua = ua .. " (KHTML, like Gecko) Chrome/62.0.3202.97 Safari/537.36"
    local num, status_code, headers, status_string = http.request {
        method = "GET",
        url = url,
        headers = {
            ["User-Agent"] = ua,
            ["Accept"] = "*/*"
        },
        sink = ltn12.sink.table(content)   
    }
    -- get body as string by concatenating table filled by sink
    content = table.concat(content)
    return content
end



-- https://gist.github.com/balaam/3122129
function M.reverse_list(tbl)
  for i=1, math.floor(#tbl / 2) do
    tbl[i], tbl[#tbl - i + 1] = tbl[#tbl - i + 1], tbl[i]
  end
  return tbl
end



-- https://stackoverflow.com/questions/20284515/capitalize-first-letter-of-every-word-in-lua
function M.ucfirst_each_word(str)
    return(str:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end))
end


-- https://stackoverflow.com/questions/19664666/check-if-a-string-isnt-nil-or-empty-in-lua
function M.is_empty(s)
  return s == nil or s == ''

--[[
    if s==nil or s=='' then
        return true
    else
        return false
    end
]]
end


function M.remove_newline (str)
    str = string.gsub(str, "[\n]", "")
    return str
end


function M.trim_spaces (str)
    if (str == nil) then
        return ""
    end
   
    -- remove leading spaces 
    str = string.gsub(str, "^%s+", "")

    -- remove trailing spaces.
    str = string.gsub(str, "%s+$", "")

    return str
end


function M.newline_to_br (str) 
    str = string.gsub(str, "\r\n", "<br />")
    str = string.gsub(str, "\n", "<br />")
    return str
end


function M.get_date_time()
-- time displayed for Toledo, Ohio (eastern time zone)
-- Thu, Jan 25, 2018 - 6:50 p.m.

    local time_type = "EDT"
    local epochsecs = os.time()
    local localsecs 
    local dt = os.date("*t", epochsecs)

    if ( dt.isdst ) then
        localsecs = epochsecs - (4 * 3600)
    else 
        localsecs = epochsecs - (5 * 3600)
        time_type = "EST"
    end

    -- damn hack - mar 11, 2018 - frigging isdst does not work as expected. it's always false.
    -- time_type = "EDT"
    -- localsecs = epochsecs - (4 * 3600)
    
    time_type = "GMT"

    -- local dt_str = os.date("%a, %b %d, %Y - %I:%M %p", localsecs)
    local dt_str = os.date("%a, %b %d, %Y - %I:%M %p", os.time())

    return(dt_str .. " " .. time_type)
end


function M.remove_html (str)
    local tmp_str = rex.gsub(str, "<([^>])+>|&([^;])+;", "", nil, "sx")
    if M.is_empty(tmp_str) then
        return str
    else
        return tmp_str
    end
end


function M.table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    for key, value in pairs (tt) do
      io.write(string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        io.write(string.format("[%s] => table\n", tostring (key)));
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write("(\n");
        M.table_print (value, indent + 7, done)
        io.write(string.rep (" ", indent+4)) -- indent it
        io.write(")\n");
      else
        io.write(string.format("[%s] => %s\n",
            tostring (key), tostring(value)))
      end
    end
  else
    io.write(tt .. "\n")
  end
end


function M.split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end


function M.is_numeric(str)
    if ( str == nil ) then
        return false
    end

    local s = string.match(str, '^[0-9]+$')

    if ( s == nil ) then
        return false
    end

    return true
end

-- 2.5 = 2
-- 3.5 = 4
-- -2.5 = -2
-- -3.5 = -4=
function M.round (x)
    local f = math.floor(x)
    if (x == f) or (x % 2.0 == 0.5) then
        return f
    else
        return math.floor(x + 0.5)
    end
end


-- line feed = 10 and carriage return = 13. don't encode.
function encode_extended_ascii_char(dec_char)
    if dec_char == 10 or dec_char == 13 then
        return utf8.char(dec_char)
    elseif dec_char >= 32 and dec_char <= 37 then -- skip the amper (38) because we want to encode it.
        return utf8.char(dec_char)
    elseif dec_char >= 39 and dec_char <= 126 then
        return utf8.char(dec_char)
    else 
        return "&#" .. dec_char .. ";"
    end
end



function M.encode_extended_ascii(str) 
    local new_str = ""

    for i, c in utf8.codes(str) do
        local x = encode_extended_ascii_char(c)
        new_str = new_str .. x
    end

    return new_str
end



-- http://lua-users.org/wiki/BaseSixtyFour
-- https://gist.github.com/bortels/1436940
-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
-- licensed under the terms of the LGPL2

-- character table string

-- encoding
function M.base64_encode(data)
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function M.base64_decode(data)
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(7-i) or 0) end
        return string.char(c)
    end))
end




return M



-- http://lua-users.org/wiki/SplitJoin

--[[
function M.string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

-- hrminsec = string.split(xdate, '-')

function M.string:split( inSplitPattern, outResults )
   if not outResults then
      outResults = { }
   end
   local theStart = 1
   local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )

   while theSplitStart do
      table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
      theStart = theSplitEnd + 1
      theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   end
   table.insert( outResults, string.sub( self, theStart ) )
   return outResults
end

-- hrminsec = string.split(xdate, '-')
]]




