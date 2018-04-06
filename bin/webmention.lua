#!/usr/bin/env lua


local http   = require "socket.http"
local ltn12  = require "ltn12"
local io     = require "io"
local cjson  = require "cjson"


local dt = os.date("%d-%b-%Y %X:%M")

local source_url = arg[1]
local target_url = arg[2]

if ( source_url == nil or target_url == nil ) then
    error("usage: " .. arg[0] .. " source-url target-url")
end 

assert(source_url)
assert(target_url)

local api_url = "http://sora.soupmode.com/api/v1"

local request_body = "source=" .. source_url .. "&target=" .. target_url

local response_body = {}

local res, status_code, response_headers, status_string = http.request{
    url = api_url .. "/webmentions",
    method = "POST", 
    headers = 
      {
          ["User-Agent"] = "Mozilla/5.0 (X11; CrOS armv7l 9901.77.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.97 Safari/537.36",
          ["Content-Type"] = "application/x-www-form-urlencoded",
          ["Content-Length"] = #request_body
      },
      source = ltn12.source.string(request_body),
      sink = ltn12.sink.table(response_body),
}


--[[
if type(response_headers) == "table" then
  for k, v in pairs(response_headers) do 
    print(k, v)
  end
end
]]


if type(response_body) == "table" then
    local returned_json_text = table.concat(response_body)
    print(returned_json_text)

--[[
    local value = cjson.decode(returned_json_text)
    for k,v in pairs(value) do
        print(k,v)
    end
]]

else
  print("Not a table:", type(response_body))
end
