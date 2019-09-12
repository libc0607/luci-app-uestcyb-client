-- @libc0607 (libc0607@gmail.com)

m = Map("ybclient", translate("ybclient"), translate("UESTC Yibin campus network client"))

require "luci.sys"
require "nixio.fs"

-- ybclient.client: settings
s = m:section(TypedSection, "client", translate("ybclient settings"))
s.anonymous = true
s.addremove = false

-- ybclient.client.enable: Enable
o_enable = s:option(Flag, "enable", translate("Enable ybclient"))
o_enable.rmempty = false

-- ybclient.client.watchdog: watchdog enable
o_watchdog = s:option(Flag, "watchdog", translate("Enable watchdog"))
o_watchdog.rmempty = false

-- ybclient.client.username: username
o_username = s:option(Value, "username", translate("Username"))
o_username.rmempty = false

-- ybclient.client.password: password
o_password = s:option(Value, "password", translate("Password"))
o_password.rmempty = false

-- ybclient.client.type: login type
o_type = s:option(ListValue, "type", translate("login type"))
o_type.rmempty = false
o_type:value("campus", translate("Campus"))
o_type:value("telecom", translate("China Telecom"))
o_type:value("mobile", translate("China Mobile"))


local apply = luci.http.formvalue("cbi.apply")
if apply then
	luci.sys.exec("/etc/init.d/ybclient enable")
    luci.sys.exec("/etc/init.d/ybclient restart")
end

return m
