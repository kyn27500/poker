
cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"

local function main()
    require("src.hall.Login"):createScene()
end

-- 重启
cc.exports.restart = function( ... )
	
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
