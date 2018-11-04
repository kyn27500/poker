-- fileName:login.lua
-- author:koba
-- date:2018-11-4
-- purpose:登录界面

require("src.common.init"):initLua()

local Login = {
	_layer = nil,
	_scene = nil,
	_nodeList = {},
}
-- 登录界面
function Login:createScene()
	self._scene = cc.Scene:create()
	display.runScene(self._scene)
	performWithDelay(self._scene,function( ... )
		self:createLayer()
	end,0)
end

-- 登录界面
function Login:createLayer()
	self._layer = CsbLoader:createLayerByCsb("res/csb/login.csb")
	self._scene:addChild(self._layer)
	self:bindUI()
end

-- 绑定界面方法
function Login:bindUI( ... )
	local bindTable = {
		updateText={},
		btn={
			_click=function( ... )
				print("点击")
				HotUpdate:create(function( ... )
					print("------游戏开始!")
				end)
			end
		}
	}
	CsbLoader:initUi(self._layer,bindTable,self._nodeList)
end

return Login
