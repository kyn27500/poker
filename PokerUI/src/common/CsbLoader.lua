-- filename:CsbLoader.lua
-- coding=utf-8
-- author：kongyanan
-- date：2016-03-02
-- purpose:createLayerByCsb,createPopupByCsb

local CsbLoader = {}

-- 背景节点 tag 值
local _bgTag = 1001
local _bgName = "bg"
-- 设备可视屏幕size
local m_autoScale ={
	width = 1136,
    height = 640,
    autoscale = "FIXED_WIDTH"
}

-- 获取全屏layer
function CsbLoader:createLayerByCsb(csbPath)
	local layer = cc.CSLoader:createNode(csbPath)
 	local bg = layer:getChildByTag(_bgTag)
 	if bg then
	 	bg:setPosition(display.center)
	 	bg:setScale(self._fMaxScaleRatio/self._fScaleX)
 	end
	for k,v in pairs(layer:getChildren()) do
		if v:getTag() ~= _bgTag then
			local curPosition = cc.p(v:getPosition())
			-- v:setScale(self._fMinScaleRatio/self._fScaleX)
			v:setPosition(self:getWinPosition(curPosition))
		end
	end
	return layer
end


-- 获取弹框 layer
function CsbLoader:createPopupByCsb(csbPath )
	local layer = cc.CSLoader:createNode(csbPath)
 	local bg = layer:getChildByTag(_bgTag)
 	if bg then
	 	bg:setPosition(display.center)
	 	bg:setScale(self._fMinScaleRatio/self._fScaleX)
 	end
	return layer
end

function CsbLoader:createActionNode(csbPath)
	local node = cc.CSLoader:createNode(csbPath)
	local action = cc.CSLoader:createTimeline(csbPath)
	action:gotoFrameAndPlay(0,true)
	node:runAction(action)
	return node
end

-- 获取 该点 在屏幕上的坐标
function CsbLoader:getWinPosition( point )
	local posx = point.x / m_autoScale.width * display.width / self._fScaleX
	local posy = point.y / m_autoScale.height * display.height / self._fScaleX
	return cc.p(posx,posy)

end

CsbLoader.seekWidgetByName = function (node,name)
	if node and node:getName() == name then return node end
	local children = {node:getChildren()}
	local index = 0
	while index < #children do
		index = index + 1
		for k,v in pairs(children[index]) do
			if v.getName and v:getName() == name then
				return v
			end
			if v.getChildren then
				table.insert(children,v:getChildren())
			end
		end
	end
	return nil
end

CsbLoader.seekWidgetByTag = function (node,tag)
	if node and node:getTag() == tag then return node end
	local children = {node:getChildren()}
	local index = 0
	while index < #children do
		index = index + 1
		for k,v in pairs(children[index]) do
			if v.getTag and v:getTag() == tag then
				return v 
			end
			if v.getChildren then
				table.insert(children,v:getChildren())
			end
		end
	end
	return nil
end

function CsbLoader:initGloableVar()

	if self._winSize then return end

	-- display.setAutoScale(m_autoScale)
	m_autoScale = CC_DESIGN_RESOLUTION

	self._winSize = cc.Director:getInstance():getVisibleSize()
	self._winCenterX = self._winSize.width/2
	self._winCenterY = self._winSize.height/2
	-- X轴伸缩比
	self._fScaleX = self._winSize.width/m_autoScale.width
	-- Y轴伸缩比
	self._fScaleY = self._winSize.height/m_autoScale.height

 	if self._fScaleX > self._fScaleY then
        self._fMinScaleRatio = self._fScaleY
        self._fMaxScaleRatio = self._fScaleX
    else
        self._fMinScaleRatio = self._fScaleX
        self._fMaxScaleRatio = self._fScaleY
    end
end
CsbLoader:initGloableVar()

return CsbLoader
