

local io  = require "io"
local rex = require "rex_pcre"


function table_print (tt, indent, done)
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
        table_print (value, indent + 7, done)
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



function split(str, pat)
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



-------------------------------



local filename = "/home/sora/docroot/rss3.txt"

local f = assert(io.open(filename, "r"))
local rss3_text = f:read("a")
f:close()

local blocks = split(rss3_text, "\n\n")

local feed = {}
local items_array = {}
local site_hash = {}

for i=1,#blocks do
    local tmp_hash = {}
    for n, v in rex.gmatch(blocks[i], "(\\w+): (.*)", "", nil) do
        tmp_hash[n] = v
    end
    if i > 1 then
        table.insert(items_array, tmp_hash)
    else
        feed.site = tmp_hash
    end
end

feed.items = items_array

table_print(feed)


