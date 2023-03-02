local nxfs = require 'nixio.fs'
local wa = require 'luci.tools.webadmin'
local opkg = require 'luci.model.ipkg'
local sys = require 'luci.sys'
local http = require 'luci.http'
local nutil = require 'nixio.util'
local name = 'design'
local uci = require 'luci.model.uci'.cursor()

local fstat = nxfs.statvfs(opkg.overlay_root())
local space_total = fstat and fstat.blocks or 0
local space_free = fstat and fstat.bfree or 0
local space_used = space_total - space_free

local free_byte = space_free * fstat.frsize

local navbar_proxy_logo
if nxfs.access('/etc/config/design') then
	navbar_proxy_logo = uci:get_first('design', 'global', 'navbar_proxy_logo')
end

function glob(...)
    local iter, code, msg = nxfs.glob(...)
    if iter then
        return nutil.consume(iter)
    else
        return nil, code, msg
    end
end

-- [[ 设置 ]]--
br = SimpleForm('config', translate('Design Config'), translate('Here you can set the mode of the theme and change the proxy tool icon in the navigation bar. [Recommend Chrome]'))
br.reset = false
br.submit = false
s = br:section(SimpleSection) 

o = s:option(ListValue, 'mode', translate('Theme mode'))
o:value('normal', translate('Follow System'))
o:value('light', translate('Force Light'))
o:value('dark', translate('Force Dark'))
o.default = mode
o.rmempty = false
o.description = translate('You can choose Theme color mode here')

o = s:option(Value, 'navbar_proxy_logo', translate('[Light mode] Primary Color'), translate('A HEX Color ; ( Default: #5e72e4 )'))
o.default = navbar_proxy_logo
o.datatype = ufloat
o.rmempty = false

o = s:option(Button, 'save', translate('Save Changes'))
o.inputstyle = 'reload'

function br.handle(self, state, data)
    if (state == FORM_VALID and data.mode ~= nil  and data.navbar_proxy_logo ~= nil) then
        nxfs.writefile('/tmp/aaa', data)
        for key, value in pairs(data) do
            uci:set('design','@global[0]',key,value)
        end 
        uci:commit('design')
    end
    return true
end

return br
