#!/usr/bin/env lua
--[[

	Auto login/keepalive script for UESTC Yibin network.
	Only for OpenWrt based system (it contains shell codes), 
	luci, wget, lua, luasocket are required. 
	
	Dirty coded by Github @libc0607 <libc0607@gmail.com>

	Usage: 
		./client.lua <userid> <pwd (default 000000)> <campus/mobile/telecom(default)> <login> 
		./client.lua <userIndex> <logout> 
	e.g.
		./client.lua 201922029999 000000 telecom login
		./client.lua a_very_long_userIndex logout
		
	--... and the userIndex will be saved to userindex_file (default /var/run/ybclient-userindex)
	
]]--


local socket = require("socket")
local http = require("socket.http")
local ltn12 = require("ltn12")
--local json = require("luci.jsonc")

local user = {}
user.id = arg[1]
if user.id == nil then
	print("Error: At least the username should be specified! Exit.")
	os.exit()
end
-- Note: user.id has different meanings when logging in and logging out
-- But for convenience ...
user.pwd = arg[2] or "000000"
user.net = arg[3] or "telecom"	
user.action = arg[4] or (#user.id > 16 and "logout" or "login")

local auth_url = {}
auth_url.login = "http://10.254.5.253/eportal/InterFace.do?method=login"
auth_url.logout = "http://10.254.5.253/eportal/InterFace.do?method=logout"

local service_char = {}
service_char.campus = "%25E6%25A0%25A1%25E5%259B%25AD%25E7%25BD%2591"	-- javascript:encodeURIComponent(encodeURIComponent("校园网"))
service_char.mobile = "%25E4%25B8%25AD%25E5%259B%25BD%25E7%25A7%25BB%25E5%258A%25A8"	-- 中国移动 同上
service_char.telecom = "%25E4%25B8%25AD%25E5%259B%25BD%25E7%2594%25B5%25E4%25BF%25A1"	-- 中国电信 同上上

local userindex_file = "/var/run/ybclient-userindex"


-- 1. info & debug
print("UESTC Yibin network client")
print("Dirty coded by Github @libc0607 <libc0607@gmail.com>")
print("LuaSocket version: " .. socket._VERSION)
if user.action == "login" then 
	print("User "..user.id..", "..user.net..", "..user.action)
end
if user.action == "logout" then
	print("userIndex "..user.id..", "..user.action)
end


--[[
	2. send GET to http://123.123.123.123
	It will return a <script> like "top.self.location.href='http://10.254.5.253/.......'"
	
	/eportal/index.jsp?
	wlanuserip=<32 bytes char>
	&wlanacname=<32 bytes char>
	&ssid=<32 bytes char>
	&nasip=<32 bytes char>
	&mac=<32 bytes char>
	&t=wireless-v2
	&url=<?? bytes char>
	
	These data should be some hash (salted md5?) or sth.
	and we don't need to figure out what's meaning of them
	just save & post
	
]]--
local query_string
if user.action == "login" then 
	query_string = io.popen("wget 123.123.123.123 -qO-|cut -d '?' -f 2|cut -d \"'\" -f 1|sed 's/=/%253D/g'|sed 's/\&/%2526/g'"):read("*all")
	--print("converted queryString: =======  "..query_string)
end


-- 3. Log in & out
local request_body = user.action == "login" 
					and "userId="..user.id..
						"&password="..user.pwd..
						"&service="..service_char[user.net]..
						"&queryString="..query_string..
						"&operatorPwd=&operatorUserId=&validcode=&passwordEncrypt=false"
					or "userIndex="..user.id
local response_body = {}
local res, code, response_headers

res, code, response_headers = http.request{
	url = auth_url[user.action],
	method = "POST",
	headers = {
		["Content-Type"] = "application/x-www-form-urlencoded";
		["Content-Length"] = #request_body;
	},
	source = ltn12.source.string(request_body),
	sink = ltn12.sink.table(response_body),
}
print("Login: code "..code..", res = "..res)

print("Response body:")
local response_body_char, response_body_obj
if type(response_body) == "table" then
	response_body_char = table.concat(response_body)
    print(response_body_char)
--	response_body_obj = json.parse(response_body_char)
--	if response_body_obj.userIndex then
--		print("userIndex: "..response_body_obj.userIndex)
--		os.execute("echo "..response_body_obj.userIndex.." > "..userindex_file)
--	end
else
    print("Response is not a table:", type(response_body))
end







   