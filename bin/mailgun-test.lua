local https = require "ssl.https"
local ltn12  = require "ltn12"

package.path = package.path .. ';/home/sora/Sora/lib/Shared/?.lua'

local utils = require "utils"

local key = "key-gibberish"

local encoded_key = utils.base64_encode("api:" .. key)

local to = "x@x.com"
local from = "Mr. Y <postmaster@y.com>"
local subject = "test mg post"
local text = os.date() .. " testing from mailgun send from z2 lua script"

local request_body = "to=" .. to .. "&from=" .. from .. "&subject=" .. subject .. "&text=" .. text


local response_body = {}

local req = {
        url = "https://api.mailgun.net/v3/y.com/messages",
        source = ltn12.source.string(request_body),
        method = "POST",
        headers = {
          ["User-Agent"] = "Mozilla/5.0 (X11; CrOS armv7l 9901.77.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.97 Safari/537.36",
          ["Host"] = "api.mailgun.net",
          ["Content-Type"] = "application/x-www-form-urlencoded",
          ["Content-length"] = #request_body,
          ["Authorization"] = "Basic " .. encoded_key
        },
        sink = ltn12.sink.table(response_body)
      }


local res, status_code, response_headers, status_string = https.request(req)


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


print("res = " .. res)
print("status code = " .. status_code)
print("status string = " .. status_string)

for k,v in pairs(response_headers) do
print(k,v)
end

