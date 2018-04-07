
local M = {}


local cgilua  = require "cgilua"
local cjson   = require "cjson"
local md5     = require "md5"
local Mailgun = require("mailgun").Mailgun
local io      = require "io"


-- my modules
local utils  = require "utils"
local config = require "config"
local rj     = require "returnjson"



function M.is_valid_login(submitted_author_name, submitted_session_id, submitted_rev)

    local author_name = config.get_value_for("author_name")

    if submitted_author_name ~= author_name then
        return false 
    else
        local h_session = _read_session_file(submitted_rev)
        if submitted_session_id ~= h_session.session_id then
            return false
        elseif h_session.status ~= "active" then
            return false
        else
            return true
        end
   end

end



function _send_login_link(email_rcpt, digest, client_url, date_time)

    local m = Mailgun({
        domain = config.get_value_for("mailgun_domain"),
        api_key = "api:" .. config.get_value_for("mailgun_api_key"),
        default_sender = config.get_value_for("mailgun_from")
    })

    local home_page = config.get_value_for("home_page")

    local link = client_url .. "/" .. digest

    local site_name = config.get_value_for("site_name")

    local subject = site_name .. " Login Link - " .. date_time

    local message = "Clink or copy link to log into the site.\n\n" .. link .. "\n"

    m:send_email({
        to      = "<" .. email_rcpt .. ">",
        subject = subject,
        html    = false,
        body    = message
    })

end



function _update_session_file(random_string, created_secs, session_id, status, updated_secs)

    local session_id_file = config.get_value_for("session_id_storage") .. "/" .. random_string .. ".txt"

    local output_str = created_secs .. ":" .. session_id .. ":" .. status .. ":" .. updated_secs .. "\n"

    local o = assert(io.open(session_id_file, "w"))

-- ::report_error("500", "Unable to open file for write.", "Cannot log in.")

    o:write(output_str)

    o:close()

end



function _create_session_id ()

    local epoch_secs = os.time()

    local random_string = utils.create_random_string(8) -- length of 8 chars

    local session_id = md5.sumhexa(config.get_value_for("author_email") .. random_string .. epoch_secs)

    _update_session_file(random_string, epoch_secs, session_id, "pending", 0)

   return random_string

end



function M.create_and_send_no_password_login_link()

    local json_text = cgilua.POST[1]

    local hash_ref_login = cjson.decode(json_text)

    local user_submitted_email = utils.trim_spaces(hash_ref_login.email)
    local client_url           = utils.trim_spaces(hash_ref_login.url)

    if user_submitted_email == nil or user_submitted_email == "" or client_url == nil or client_url == "" then
        rj.report_error("400", "Invalid input.", "Insufficent data was submitted.")
    else

        local author_email = config.get_value_for("author_email")
        local backup_author_email = config.get_value_for("author_email_2")

        local digest = ""

        local date_time = utils.get_date_time()

        if user_submitted_email ~= author_email and user_submitted_email ~= backup_author_email then
            rj.report_error("400", "Invalid input.", "Data was not found.")
        else
            digest = _create_session_id() -- return the login digest to be emailed
            _send_login_link(author_email, digest, client_url, date_time)
            _send_login_link(backup_author_email, digest, client_url, date_time)

            local hash = {}

            if config.get_value_for("debug_mode") then
                hash["session_id_digest"] = digest
            end
           
            hash["user_message"]   = "Creating New Login Link." 
            hash["system_message"] = "A new login link has been created and sent."
 
            rj.success(hash)
        end


    end

end



function _read_session_file(user_submitted_rev)

    -- user_submitted_rev = random_string created when requesting login link that was emailed to the author

    -- text file format is colon delimited.
    --     epoch_secs created : session_id : status (pending active deleted) : epoch_secs updated 

    local session_id_file = config.get_value_for("session_id_storage") .. "/" .. user_submitted_rev .. ".txt"

    local session_info

    local hash = {}

    local f = io.open(session_id_file, "r")

    if f == nil then
        hash = {
            iserror = true,
            msg1 = "Could not open session ID file for read.", 
            msg2 = "File may not exist"
        }
        return hash
    else
        local session_info = f:read("a")

        f:close()

        local session_array = utils.split(session_info, ":")

        hash = {
            iserror       = false,
            created_secs  = session_array[1],
            session_id    = session_array[2],
            status        = session_array[3],
            updated_secs  = session_array[4]
        }
 
        return hash
    end

end



function M.activate_no_password_login()

    local rev = cgilua.QUERY.rev -- the random_string created above and sent to the author

    local h_session = _read_session_file(rev)

    if h_session.iserror then
        rj.report_error("400", h_session.msg1, h_session.msg2)
    else
        if h_session.status ~= "pending" then
            rj.report_error("400", "Unable to login.", "Invalid session information submitted.")
        else
            updated_secs = os.time()

            _update_session_file(rev, h_session.created_secs, h_session.session_id, "active", updated_secs)

            local hash = {
                author_name = config.get_value_for("author_name"),
                session_id  = h_session.session_id,
                rev         = rev
            }

            rj.success(hash)
        end
    end

end



function M.logout()

    local author_name = cgilua.QUERY.author
    local session_id  = cgilua.QUERY.session_id
    local rev         = cgilua.QUERY.rev

    local config_author_name = config.get_value_for("author_name")

    if config_author_name ~= author_name then
        rj.report_error("400", "Unable to logout.", "Invalid info submitted.")
    else
        local h_session = _read_session_file(rev)

        if h_session.status ~= "active" then
            rj.report_error("400", "Unable to logout.", "Invalid info submitted.")
        else
            if h_session.session_id ~= session_id then
                rj.report_error("400", "Unable to logout.", "Invalid info submitted.")
            else 
                _update_session_file(rev, h_session.created_secs, session_id, "deleted", os.time())

                local hash = {
                    logged_out = true
                }

                rj.success(hash)
            end
        end     
    end
end



return M

