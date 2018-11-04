-- fileName:init.lua
-- author:koba
-- date:2018-11-4
-- purpose:初始化全局文件

local init = {
	_globalLua = {
		CsbLoader="src.common.CsbLoader",
		HotUpdate="src.common.HotUpdate"
	}
}

-- 初始化文件
function init:initLua( ... )
	for k,v in pairs(self._globalLua)do
		cc.exports[k] = require(v)
	end
end

return init
