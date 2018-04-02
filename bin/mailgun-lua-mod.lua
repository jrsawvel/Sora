
local Mailgun = require("mailgun").Mailgun


    local email_rcpt = "x@x.com"

    local m = Mailgun({
        domain = "y.com",
        api_key = "api:key",
        default_sender = "Mr. Y <postmaster@y.com>"
    })

local res =    m:send_email({
        to      = "<" .. email_rcpt .. ">",
        subject = "test mg from lua",
        html    = false,
        body    = "hello world"
    })


if type(res) == "table" then
    print("table")
else
    print("other")
end

