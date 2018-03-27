
local M = {}

local ltn12 = require "ltn12"
local http  = require "socket.http"
local https = require "ssl.https"


function M.get_secure_web_page(url)
    local body,code,headers,status = https.request(url)
    return body,code,headers,status
end


function M.get_unsecure_web_page(url)
    local body = {}
    local ua = "Mozilla/5.0 (X11; CrOS armv7l 9901.77.0) AppleWebKit/537.36"
    ua = ua .. " (KHTML, like Gecko) Chrome/62.0.3202.97 Safari/537.36"
    local num, status_code, headers, status_string = http.request {
        method = "GET",
        url = url,
        headers = {
            ["User-Agent"] = ua,
            ["Accept"] = "*/*"
        },
        sink = ltn12.sink.table(body)   
    }
    -- get body as string by concatenating table filled by sink
    body = table.concat(body)
    return body, status_code, headers, status_string 
end


function M.unsecure_json_post(url, json_text)
    local response_body = {}
    local res, status_code, response_headers, status_string = http.request{
        url = url,
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
    response_body = table.concat(response_body)
    return response_body, status_code, response_headers, status_string
end



function M.unsecure_json_put(url, json_text)
    local response_body = {}
    local res, status_code, response_headers, status_string = http.request{
        url = url,
        method = "PUT", 
        headers = 
          {
              ["User-Agent"] = "Mozilla/5.0 (X11; CrOS armv7l 9901.77.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.97 Safari/537.36",
              ["Content-Type"] = "application/json";
              ["Content-Length"] = #json_text;
          },
        source = ltn12.source.string(json_text),
        sink = ltn12.sink.table(response_body),
    }
    response_body = table.concat(response_body)
    return response_body, status_code, response_headers, status_string
end

return M
