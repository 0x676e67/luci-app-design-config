local nxfs = require 'nixio.fs'
local nutil = require 'nixio.util'
local name = 'design'
local uci = require 'luci.model.uci'.cursor()

local mode, navbar_proxy_icon
if nxfs.access('/etc/config/design') then
    mode = uci:get_first('design', 'global', 'mode')
	navbar_proxy_icon = uci:get_first('design', 'global', 'navbar_proxy_icon')
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

o = s:option(ListValue, 'navbar_proxy_icon', translate('Navigation bar proxy icon'))
o:value('luci-app-openclash', translate('luci-app-openclash'))
o:value('luci-app-ssr-plus', translate('luci-app-ssr-plus'))
o:value('luci-app-vssr', translate('luci-app-vssr'))
o:value('luci-app-passwall', translate('luci-app-passwall'))
o:value('luci-app-passwall2', translate('luci-app-passwall2'))
o.default = navbar_proxy_icon
o.rmempty = false
o.description = translate('Show OpenClash icon by default')

o = s:option(Button, 'save', translate('Save Changes'))
o.inputstyle = 'reload'

function br.handle(self, state, data)
    if (state == FORM_VALID and data.mode ~= nil  and data.navbar_proxy_icon ~= nil) then
        nxfs.writefile('/tmp/aaa', data)
        for key, value in pairs(data) do
            uci:set('design','@global[0]',key,value)
        end 
        uci:commit('design')
    end
    return true
end

return br
