#!/usr/bin/env lua


local http   = require "socket.http"
local ltn12  = require "ltn12"
local io     = require "io"
local cjson  = require "cjson"


local api_url = "http://sora.soupmode.com/api/v1"

local request_body = { 
                         email = "jothut@fastmail.fm",
                         url   = "http://sora.soupmode.com/sora/nopwdlogin"
                     }

local json_text = cjson.encode(request_body)

local response_body = {}

local res, status_code, response_headers, status_string = http.request{
    url = api_url .. "/users/login",
    method = "POST", 
    headers = 
      {
          ["User-Agent"] = "Mozilla/5.0 (X11; CrOS armv7l 9901.77.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.97 Safari/537.36",
          ["Content-Type"] = "application/json";
          ["Content-Length"] = #json_text;
      },
      source = ltn12.source.string(json_text),
      sink = ltn12.sink.table(response_body),
}

if type(response_headers) == "table" then
  for k, v in pairs(response_headers) do 
    print(k, v)
  end
end

if type(response_body) == "table" then
    local returned_json_text = table.concat(response_body)
    print(returned_json_text)
    local value = cjson.decode(returned_json_text)
    for k,v in pairs(value) do
        print(k,v)
    end
else
  print("Not a table:", type(response_body))
end
