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
local CC_DESIGN_RESOLUTION ={
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
	local posx = point.x / CC_DESIGN_RESOLUTION.width * display.width / self._fScaleX
	local posy = point.y / CC_DESIGN_RESOLUTION.height * display.height / self._fScaleX
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

	self._winSize = cc.Director:getInstance():getVisibleSize()
	self._winCenterX = self._winSize.width/2
	self._winCenterY = self._winSize.height/2
	-- X轴伸缩比
	self._fScaleX = self._winSize.width/CC_DESIGN_RESOLUTION.width
	-- Y轴伸缩比
	self._fScaleY = self._winSize.height/CC_DESIGN_RESOLUTION.height

 	if self._fScaleX > self._fScaleY then
        self._fMinScaleRatio = self._fScaleY
        self._fMaxScaleRatio = self._fScaleX
    else
        self._fMinScaleRatio = self._fScaleX
        self._fMaxScaleRatio = self._fScaleY
    end
end
CsbLoader:initGloableVar()

--初始化控件(ui：控件，tab：绑定列表，nodeList:table-控件索引（可不传）)
function CsbLoader:initUi(ui,tab,nodeList)
	if not (ui or tab) or type(tab) ~= "table" then return end
	for k,v in pairs(tab)do
		print(k,v)
		if type(v) == "table" then
			if nodeList and type(nodeList) == "table" then 
				nodeList["_"..k] = ui:getChildByName(k) 
			end
			self:initUi(ui:getChildByName(k),v,nodeList)
		else
			self:doWidgetFunc(ui,k,v)
		end
	end
end 

-- 
function CsbLoader:doWidgetFunc(ui,key,func)
	if string.sub(key,1,1) ~= "_" then
		print("--CsbLoader:doWidgetFunc: key is invalid",key)
		return
	end

	if key == "_click" then
		ui:addTouchEventListener(function(sender,eventType)
			if eventType == ccui.TouchEventType.ended then
				if func then func(sender,eventType) end
			end
		end)
	elseif key == "_run" then
		if func then func(ui) end
	elseif key == "_visible" then
		ui:setVisible(func)
	elseif key == "_text" then
		ui:setString(func)
	end
end

return CsbLoader
