#!/usr/bin/env lua


local http =   require "socket.http"
local ltn12 =  require "ltn12"
local io =     require "io"
local cjson =  require "cjson"


local session_filename = arg[1]
if ( session_filename == nil ) then
    error("command line arg 'session-filename' missing. usage: " .. arg[0] .. " session-filename")
end 


local f = assert(io.open(session_filename, "r"))

-- if ( f == nil ) then
--    print("file " .. session_filename .. " not found.")
--    os.exit()
-- end

local json_text = f:read("a")

f:close()


local value = cjson.decode(json_text)

assert(value.author_name)
assert(value.session_id)
assert(value.rev)


local api_url = "http://sora.soupmode.com/api/v1"

local full_url = api_url .. "/users/logout?author=" .. value.author_name .. "&session_id=" .. value.session_id .. "&rev=" .. value.rev

local response_body = {}

local num, status_code, headers, status_string = http.request {
    method = "GET",
    url = full_url,
    headers = {
        ["User-Agent"] = "Mozilla/5.0 (X11; CrOS armv7l 9901.77.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.97 Safari/537.36"
    },
    sink = ltn12.sink.table(response_body)   
}


for k,v in pairs(headers) do
    print (k,v)
end

-- get body as string by concatenating table filled by sink
response_body = table.concat(response_body)

print(response_body)

local value = cjson.decode(response_body)

for k,v in pairs(value) do
    if ( type(v) == "table" ) then
        print(k ..  " = table")
        for x,y in pairs(v) do
            print(x,y)
        end
    else 
        print(k,v)
    end
end

