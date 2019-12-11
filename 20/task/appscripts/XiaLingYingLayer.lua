local  ActivityBaseLayer = requirePack("task.appscripts.ActivityBaseLayer");
local  ShiftMove = requirePack("task.appscripts.Base.ShiftActions.ShiftMove");

-- 设置debug 活动启动模式
ActivityBaseLayer.DEBUG_MODE = nil;-- ActivityBaseLayer.DEBUG_ENTER_MODE.E_PRE; -- 活动的启动模式 nil E_PRE E_FORMAT
ActivityBaseLayer.DEBUG_MODE_PRE_DAY_INDEX = 7;                          -- 活动预热启动日期【1-7】天
ActivityBaseLayer.DEBUG_MODE_FORMAT_DAY_INDEX = 1;                       -- 活动正式启动日期【1-n】天
ActivityBaseLayer.DEBUG_WIPEOUT_SIGN_DATA = false;                       -- 是否抹去签到数据


local XiaLingYingLayer = class("XiaLingYingLayer", function()
	return ActivityBaseLayer.new();
end)

g_tConfigTable.CREATE_NEW(XiaLingYingLayer);

function XiaLingYingLayer:ctor(...)
end

--[[
	重写start 方法
	设置主界面活动启动按钮外形
	设置活动启动时间
]]--
function XiaLingYingLayer:start(sSdPath)
	self:SetBGMPath(sSdPath.."task/sounds/bgm_no_12.mp3"); -- 设置背景音乐
	self:setTopBtnArmtureInfo(                             -- 设置主界面顶部按钮
		"191225_rukou",
		"191225_rukoudeng3xj",
		"191225_rukoudeng2");
	self:setActivityStartTime(2019,12,3,0,0,0);           -- 设置活动开始日期

	ActivityBaseLayer.start(self,sSdPath);                -- 调用基类启动方法
end


--[[
    重写这个方法，定义预热界面如何出现
    参数:
    n:预热界面
]]--
function XiaLingYingLayer:ShiftMainScreenToPrepareLayer(n,cb)

	ActivityBaseLayer.ShiftMainScreenToPrepareLayer(self,n,cb);

	self:CallBaiduEventStart("xmas19_preheat_everytime");
	
	
	if  self.m_xiaLingYingBtn ~= nil then
		self.m_xiaLingYingBtn:clickForwardDown()
	end
	n:setVisible(true);
	local sm = ShiftMove.new();
	sm:Init(
		cc.p(0,0),
		cc.p(0,0),
		0.1,
		n,
		function()
			print("show prepareLayer complie..");--0.427
			if cb ~= nil then 
				cb();
			end
		end
	);
	sm:ProcessShift();

	SoundUtil:getInstance():playBackgroundMusic(self:GetBGMPath(),true);
end

--[[
    重写这个方法，定义预热界面如何隐藏
    参数:
    n:预热界面
]]--
function XiaLingYingLayer:ShiftPrepareLayerToMainScreen(n,cb)
	self:CallBaiduEventEnd("xmas19_preheat_everytime");

	local sm = ShiftMove.new();
	sm:Init(
		cc.p(0,0),
		cc.p(0,0),
		0.1,
		n,
		function()
			writeToFile("show prepareLayer complie.."); 
			n:setVisible(false);
			if cb ~= nil then 
				cb();
			end
		end
	);
	sm:ProcessShift();

	SoundUtil:getInstance():stopBackgroundMusic(self:GetBGMPath(),true);
end

return XiaLingYingLayer

