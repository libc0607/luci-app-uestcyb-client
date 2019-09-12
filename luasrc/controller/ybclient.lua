module("luci.controller.ybclient", package.seeall)

http = require "luci.http"
fs = require "nixio.fs"
sys  = require "luci.sys"

function index()
	if not fs.access("/etc/config/ybclient") then
		return
	end
	local uci = require "luci.model.uci".cursor()

	entry({"admin", "ybclient"}, 				alias("admin", "ybclient", "settings"), 	translate("ybclient"), 90)
	entry({"admin", "ybclient", "settings"}, 	cbi("ybclient/ybclient"), 					translate("Settings"), 10).leaf = true

	-- login & logout api
	-- Google "luci-mod-rpc" for usage
	-- Note: call "conf" will trigger auto restart by procd
	entry({"admin", "ybclient", "login"}, 			call("login"))
	entry({"admin", "ybclient", "logout"}, 			call("logout"))	
	entry({"admin", "ybclient", "conf"}, 			call("conf"))

	
end

--[[
	login
	just a simple login
	use /etc/config/ybclient as config
	http://openwrt_ip/cgi-bin/luci/admin/ybclient/login
	return: {"status": "<some-output>"}
]]--
function login()
	local j = {}
	j.status = io.popen("/usr/sbin/ybclient.lua $(uci get ybclient.client.username) $(uci get ybclient.client.password) $(uci get ybclient.client.type) login"):read("*all")
	http.prepare_content("application/json")
	http.write_json(j)
	http.close()
end

--[[
	logout
	just a simple logout
	use /etc/config/ybclient and /var/run/ybclient-userindex as config
	http://openwrt_ip/cgi-bin/luci/admin/ybclient/logout
	return: {"status": "<some-output>"}
]]--
function logout()
	local j = {}
	j.status = io.popen("/usr/sbin/ybclient.lua $(cat /var/run/ybclient-userindex) logout"):read("*all")
	http.prepare_content("application/json")
	http.write_json(j)
	http.close()
end

function set_uci_val(p, v)
	if v then sys.exec("uci set "..p.."="..v) end
end
--[[
	conf
	set conf or get conf
	the conf in URL will be set: username, password, watchdog, enable, type
	http://openwrt_ip/cgi-bin/luci/admin/ybclient/conf?username=20191145141919810
	return: full config of /etc/config/ybclient
		{"enable":1,"username":"1145141919810","password":"000000", ......}
]]--
function conf()
	local j = {}

	-- To-do: rewrite it using uci api
	set_uci_val("ybclient.client.enable",   tonumber(luci.http.formvalue("enable")) )
	set_uci_val("ybclient.client.watchdog", tonumber(luci.http.formvalue("watchdog")) )
	set_uci_val("ybclient.client.username", tostring(luci.http.formvalue("username")) )
	set_uci_val("ybclient.client.password", tostring(luci.http.formvalue("password")) )
	set_uci_val("ybclient.client.type",     tostring(luci.http.formvalue("type")) )
	
	j.enable = tonumber(sys.exec("uci get ybclient.client.enable"))
	j.watchdog = tonumber(sys.exec("uci get ybclient.client.watchdog"))
	j.username = tostring(sys.exec("uci get ybclient.client.username"))
	j.password = tostring(sys.exec("uci get ybclient.client.password"))
	j.type = tostring(sys.exec("uci get ybclient.client.type"))
	
	http.prepare_content("application/json")
	http.write_json(j)
	http.close()
end


