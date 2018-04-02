local https = require "ssl.https"
local ltn12  = require "ltn12"
local urlcode = require "cgilua.urlcode"


function urlencode(str)
   if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w ])",
         function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
   end
   return str    
end



local to = "x@x.com"
local from = "MrY <postmaster@somwhere.com>"
local subject = "test mg post"
local text = "testing from mailgun send from lua script"

local request_body = "to=" .. to .. "&from=" .. from .. "&subject=" .. subject .. "&text=" .. text

-- request_body = urlencode(request_body)

-- request_body = urlcode.escape(request_body)

-- local request_body = "%3cjothut%40fastmail%2efm%3e&from=Sora%20%3cpostmaster%40maketoledo%2ecom%3e&subject=test%20mg%20from%20lua&text=hello%20world"

local response_body = {}

local req = {
        url = "https://api:key@api.mailgun.net/v3/somewhere.com/messages",
        source = ltn12.source.string(request_body),
        method = "POST",
        headers = {
          ["User-Agent"] = "Mozilla/5.0 (X11; CrOS armv7l 9901.77.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.97 Safari/537.36",
          ["Host"] = "api.mailgun.net",
          ["Content-Type"] = "application/x-www-form-urlencoded",
          ["Content-length"] = #request_body
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


--[[



    local h_json = cjson.decode(response_body)

    if status_code >= 200 and status_code < 300 then
        print("Creating New Login Link", "A new login link has been created and sent.", "")
    elseif status_code >= 400 and status_code < 500 then
        print("user", "Unable to complete request.", "Invalid data provided. " .. h_json["user_message"] .. " - " .. h_json["system_message"])
    else
        print("user", "Unable to complete request.", "Invalid response code returned from API. " .. h_json["user_message"] .. " - " .. h_json["system_message"])
    end

]]
