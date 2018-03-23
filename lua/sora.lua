#!/usr/bin/env cgilua.cgi

package.path = package.path .. ';/home/sora/Sora/lib/Shared/?.lua'
package.path = package.path .. ';/home/sora/Sora/lib/Client/?.lua'
local client = require "cDispatch"
client.execute()
