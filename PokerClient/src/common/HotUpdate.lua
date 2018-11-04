
local _M = {}


function _M:create(pCallback) 
	self._callback = pCallback
	-- self.image_loading = self.root:getChildByNameFo("Image_loading");
	-- self.loading_Text_Tip = self.root:getChildByNameFo("Image_loading.Text_Tip");
	-- self.loading_bar = self.root:getChildByNameFo("Image_loading.LoadingBar");
	-- self.loading_image_bar = self.root:getChildByNameFo("Image_loading.LoadingBar.Image_bar");

    
	if device.platform == "windows" or device.platform == "mac" then
	  	-- return
	end

	--更新
	self:PackageUpdateCheck()

end

--检查更新 
function _M:PackageUpdateCheck()
	-- local _FileUtils = cc.FileUtils:getInstance()
	-- local _file_path = _FileUtils:getWritablePath().."hotUpdate/project.manifest.temp"
	-- local _file_version_path = _FileUtils:getWritablePath().."hotUpdate/version.manifest"
	-- if _FileUtils:isFileExist(_file_path) then
	-- 	cc.FileUtils:getInstance():removeFile(_file_path)
	-- 	cc.FileUtils:getInstance():removeFile(_file_version_path)
	-- end	
	
	-- 检查是否需要热更脚本
	self:checkIsUpdateScript(function(isUpdate,localVersion)

		if isUpdate then
			self:hotUpdate()
		else
			self:startGame(localVersion)
		end
	end)
end

-- 检查脚本版本号，如果本地脚本版本号大于线上，则不热更
function _M:checkIsUpdateScript(fnCallback)
	local localVersionData = json.decode(cc.FileUtils:getInstance():getStringFromFile("src/version/version.manifest"))
	local xhr = cc.XMLHttpRequest:new()
	xhr.timeout = 10
	xhr:open("GET", localVersionData.remoteVersionUrl)
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status == 200 then
			local response   = xhr.response -- 获得返回数据
			local onlineVersionData = json.decode(response)
			local localVersion = tonumber(string.sub(localVersionData.version,5))
			local onlineVersion = tonumber(string.sub(onlineVersionData.version,5))
			print("是否更新：",localVersion,onlineVersion,localVersion<onlineVersion,localVersion)
			if fnCallback then fnCallback(localVersion<onlineVersion,localVersion) end
		end
	end
	xhr:registerScriptHandler(onReadyStateChange)
	xhr:send()
end


-- 开始热更
function _M:hotUpdate()
	--设置新文件保存的位置
	local writablePath = cc.FileUtils:getInstance():getWritablePath()
	local storagePath = writablePath.."hotUpdate"
	print("设置新文件保存的位置"..storagePath)
	--创建AssetsManagerEx对象
	local assetsManagerEx = cc.AssetsManagerEx:create("src/version/project.manifest", storagePath)
	assetsManagerEx:retain()

    local localManifest = assetsManagerEx:getLocalManifest() 
    print(localManifest:getManifestFileUrl()) 
    
	--设置下载消息listener
	local function handleAssetsManagerEx(event)
		if (cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE == event:getEventCode()) then
			print("已经更新到服务器最新版本")
			local version = assetsManagerEx:getLocalManifest():getVersion()
			self:startGame(tostring(version))
		elseif (cc.EventAssetsManagerEx.EventCode.NEW_VERSION_FOUND == event:getEventCode()) then
			print("发现新版本，开始升级")
			-- self.loading_Text_Tip:setString("发现新版本，开始升级")
			-- self.loading_bar:setPercent(0)
			-- self.image_loading:setVisible(true)
		elseif (cc.EventAssetsManagerEx.EventCode.ASSET_UPDATED == event:getEventCode()) then
            print("单个资源被更新事件 "..event:getAssetId())
		elseif (cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION == event:getEventCode()) then
		 	local assetId = event:getAssetId()
            local percent = event:getPercentByFile()
            local str = ""
            if assetId == cc.AssetsManagerExStatic.VERSION_ID then  
                str = string.format("Version file: %d%%", percent)  
            elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then  
                str = string.format("Manifest file: %d%%", percent)               
            else  
                str = string.format("正在更新资源..%.1f", tonumber(percent) )
                str = str .. "%"
				-- self.loading_Text_Tip:setString(str)
				-- self.loading_bar:setPercent(percent)
				-- local vec = self.loading_image_bar:getPositionPercent()
				-- vec.x = percent/100
				-- self.loading_image_bar:setPositionPercent(vec)
            end
            print("更新中..."..str)
		elseif (cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED == event:getEventCode()) then
			print("更新成功事件")
			-- local msgbox = HNMsgBox:create("更新成功，请重启软件！")
			-- if device.platform == "android" then 
			-- 	msgbox:setCallBackForBtnSure(function ()
			-- 		device.exit()
			-- 	end)
	  --       elseif device.platform == "ios" then
			-- 	msgbox:setCallBackForBtnSure(function ()
			-- 		os.exit()
			-- 	end)
			-- end
			--local version = assetsManagerEx:getLocalManifest():getVersion()
			--self:startGame(tostring(version))		
		elseif (cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED == event:getEventCode()) then
			print("更新失败事件")
            assetsManagerEx:downloadFailedAssets() 
        elseif (cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST == event:getEventCode()) then
			print("发生错误:本地找不到资源清单manifest文件")
            self:hotUpdate()
		elseif (cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST == event:getEventCode()) then
			print("发生错误:远程资源清单manifest文件下载失败")
            self:hotUpdate() 
		elseif (cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST == event:getEventCode()) then
			print("发生错误:资源清单manifest文件解析失败") 
            self:hotUpdate()
		elseif (cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING == event:getEventCode()) then
			print("发生错误:更新过程中遇到错误")
            assetsManagerEx:downloadFailedAssets()
        elseif event:getEventCode() == cc.EventAssetsManagerEx.EventCode.ERROR_DECOMPRESS then  
            print("解压缩失败") 
            self:hotUpdate() 
        end  
    end
	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	local eventListenerAssetsManagerEx = cc.EventListenerAssetsManagerEx:create(assetsManagerEx, handleAssetsManagerEx)
	dispatcher:addEventListenerWithFixedPriority(eventListenerAssetsManagerEx, 1)

	--检查版本并升级
	assetsManagerEx:update()
end
--更新完成时初始化项目配置
function _M:startGame(version)
	print("startGame",version)
	if self._callback then self._callback(version) end
end

return _M
