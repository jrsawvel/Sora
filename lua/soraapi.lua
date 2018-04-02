#!/usr/bin/env cgilua.cgi

package.path = package.path .. ';/home/sora/Sora/lib/Shared/?.lua'
package.path = package.path .. ';/home/sora/Sora/lib/API/?.lua'
local api = require "apidispatch"
api.execute()
