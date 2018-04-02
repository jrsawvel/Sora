#!/usr/bin/env lua


local http =   require "socket.http"
local ltn12 =  require "ltn12"
local io =     require "io"
local cjson =  require "cjson"


-- prompt user to enter the rev from the email
-- local rev = io.read("*l")

-- reserved lua array arg
-- arg[0] is the name of the script
-- arg[1] is first value entered after script name

local rev = arg[1]
if ( rev == nil ) then
    error("command line arg 'rev' missing. usage: activate-login rev")
end 


local api_url = "http://sora.soupmode.com/api/v1"

local full_url = api_url .. "/users/login/?rev=" .. rev

local response_body = {}

local num, status_code, headers, status_string = http.request {
    method = "GET",
    url = full_url,
    headers = {
        ["User-Agent"] = "Mozilla/5.0 (X11; CrOS armv7l 9901.77.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.97 Safari/537.36"
    },
    sink = ltn12.sink.table(response_body)   
}


--[[
for k,v in pairs(headers) do
    print (k,v)
end
]]

-- get body as string by concatenating table filled by sink
response_body = table.concat(response_body)
print(response_body)


--[[
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
]]
