local  JsonScriptConfig = requirePack("task.appscripts.JsonScriptConfig");
local  JsonScriptUtil = requirePack("task.appscripts.JsonScriptUtil");
local  ArmatureUtil = requirePack("task.appscripts.ArmatureUtil");
local  ActivityItem = requirePack("task.appscripts.Base.ActivityItems.ActivityItem");

local CurZOrderSet = {
	bottomButtonZorder = 1,
	topButtonZorder = 2,
	
	xialingyingButtonZorder = 100000004,
	popLayerZorder = 100000005,
	backButtonZorder = 100000006
}

local  ActivityBaseLayer =  class("ActivityBaseLayer", function()
    local layer  = cc.Node:create()
      if nil ~= layer then
        local function onNodeEvent(event)
            if "enter" == event then
                layer:onEnter()
            elseif "exit" == event then
             
                layer:onExit()
            end
        end
        layer:registerScriptHandler(onNodeEvent)
    end
    return layer
end)
g_tConfigTable.CREATE_NEW(ActivityBaseLayer);
ActivityBaseLayer.CurZOrderSet = CurZOrderSet;

--测试代码 正常状态下让 ActivityBaseLayer.DEBUG_MODE = nil;
ActivityBaseLayer.DEBUG_ENTER_MODE = {
    ["E_PRE"] = 1,    -- 以预热状态启动
    ["E_FORMAT"] = 2, -- 以正式状态启动
}
ActivityBaseLayer.DEBUG_MODE = nil;--ActivityBaseLayer.DEBUG_ENTER_MODE.E_PRE; -- 活动的启动模式
ActivityBaseLayer.DEBUG_MODE_PRE_DAY_INDEX = 1;                          -- 活动预热启动日期【1-7】天
ActivityBaseLayer.DEBUG_MODE_FORMAT_DAY_INDEX = 1;                       -- 活动正式启动日期【1-n】天
ActivityBaseLayer.DEBUG_WIPEOUT_SIGN_DATA = false;                       -- 是否抹去签到数据

--[[
    成员声明方法
]]--
function ActivityBaseLayer:ctor()
    print("ActivityBaseLayer:ctor");
    -- 声明常量
    self.STR_TASK = "task";
    self.STR_ANIM = "animationEx";
    self.STR_JSON = "sayHelloGuide/story";
    self.STR_IMAGE = "image";
    self.STR_AUDIO = "audio";
    self.STR_PREPARE = "animation";

    self.STR_EVENT_TYPE = "xialingying";                               -- 统计事件类型

    self.STR_EVENT_SHOW_ACTIVITY = "xmas19_show_preheat";              -- 百度统计事件名称 [显示活动按钮]
    self.STR_EVENT_CLICK_ACTIVITY_TOP_BTN = "xmas19_click_preheat_";   -- 百度统计事件名称 [玩家点击活动按钮]
    --self.STR_EVENT_SHOW_ACTIVITY_BTN = "show_btn_ganenjie";            -- 百度统计事件名称 [显示活动按钮]
    --self.STR_EVENT_INIT_ACTIVITY_BTN = "init_btn_ganenjie";            -- 百度统计事件名称 [初始化活动按钮]

    self.STR_LOCAL_EVENT_SIGN = "SIGN_IN";                             -- 签到事件名称

    self.STR_LOCAL_EVENT_ENTER_BTN_CLICK_TODAY = "isnotClick";         -- 本地统计事件名称 [活动某天中点击活动按钮]
    --self.STR_LOCAL_EVENT_ENTER_PRE_LAYER_TODAY = "ganenjie_";          -- 本地统计事件名称 [进入活动预热界面]
    self.STR_LOCAL_EVENT_FIRST_ENTER_PRE_LAYER = "Chris_FirstEnter_"   -- 本地统计事件名称 [第一次进入预热界面]
    self.STR_LOCAL_EVENT_TRY_ENTER_TODAY = "try_enter_";               -- 本地统计事件名称 [当天试图进入活动]

    self.STR_ASYNC_RES_KEY = "XiaLingYingEx";                          -- 异步资源key值
    self.STR_ASYNC_RES_PREPARE_KEY = "XiaLingYing";                    -- 预热界面动画 异步资源key值

    self.STR_PUMPKIN_ARMTURE_NAME = "191225_rukou";                    -- 头部按钮动画名                   
    self.STR_PUMPKIN_SLOT_NAME = "deng";                               -- 头部按钮还图插槽名称
    self.STR_PUMPKIN_SLOT_IMAGE_PRE = "191225_rukoudeng3xj.png";       -- 头部按钮图片名称（预热阶段）
    self.STR_PUMPKIN_SLOT_IMAGE_FORMAT = "191225_rukoudeng2.png";      -- 头部按钮图片名称 (正式阶段)

    self.INT_MIN_PREPARE_DAY = 1;                                      -- 预热期间 单位 天 
    self.INT_MAX_PREPARE_DAY = 7;                                      -- 预热期间 单位 天 
    
    self.INT_SECOND_OF_DAY = 86400;                                    -- 一天的秒数
    self.INT_MAX_ACTIVITY_TIME = 10;                                   -- 最大活动持续时间

    self.STR_UN_SIGN_IN = "UN_SIGIN"                                   -- 未签到
    self.STR_SIGN_IN = "SIGIN"                                         -- 签到 

    self.STR_TRUE  = "TRUE";                                           -- true str
    self.STR_FALSE = "FALSE";                                          -- false str

    -- 声明成员
    self.packagePath = nil;             -- 包路径
    self.taskPath = nil;                -- task 文件夹路径
    self.animPath = nil;                -- 龙骨动画资源文件夹路径
    self.jsonPath = nil;                -- json剧情文件路径
	self.imagePath = nil;               -- 图片文件路径
    self.audioPath = nil;               -- 音频文件路径

    self.activityStartTime = 1574438400 -- 活动启动时间(19700101 到现在的秒数)
    
	self.pumpkin = nil ;                -- 主界面进入活动的按钮动画
	self.m_dayIndex = 1;                -- 当前日期
    self.tag_ = -1
    
	self.m_topBtn = nil                 -- 主界面进入活动的按钮
	self.m_bottomBtn = nil              -- 主界面进入活动的按钮     
    self.topMenuLayer = nil;            -- 预热窗口界面

    self.topMenuLayerActive = false;    -- 预热界面是否活跃

    self.data = nil;                    -- 预热界面数据

    self.backGroundMusicPath = ""       -- 背景音乐路径

    self.isLoadedPrepareLayerRes =false;-- 预热界面动画资源是否加载
    self.isLoadingPrepareLayer = false; -- 是否正在加载preparelayer res
end

--[[
    异步加载预热界面资源
    参数:
    cb:加载完成回掉
]]--
function ActivityBaseLayer:loadPrepareLayerRes(cb)
    if self.isLoadingPrepareLayer == false then
        AsyncLoadRes:shareMgr():addOneDirAsyncLoadLua(self.preparePath, "", self.STR_ASYNC_RES_PREPARE_KEY  , function(key)
            if cb ~= nil then
                cb();
                self.isLoadingPrepareLayer = false;
            end
        end)
    end
end

-- ----- [事件] -----

--[[
    当活动资源加载完毕后进入此方法，展示活动相关显示对象到主界面
]]--
function  ActivityBaseLayer:onAsyncResLoadComplie(  )
    self:startActivity();
end


--[[
    主界面活动启动事件
]]--
function ActivityBaseLayer:onEnter() 

end

--[[
    主界面活动推出事件
]]--
function ActivityBaseLayer:onExit()
    writeToFile("ActivityBaseLayerexit!!!!!!!!!!!!!!");
    self:CallBaiduEventEnd("xmas19_preheat_everytime");

    if self.topMenuLayer ~= nil then 
        self.topMenuLayer:Dispose();
        self.topMenuLayer:removeFromParent();
    end

    AsyncLoadRes:shareMgr():cancelOneDirAsyncLoad(self.STR_ASYNC_RES_KEY, true);
    AsyncLoadRes:shareMgr():cancelOneDirAsyncLoad(self.STR_ASYNC_RES_PREPARE_KEY, true);
end


--[[
    用户点击活动按钮
]]--
function ActivityBaseLayer:onUserClickActivityBtn()
    if self.isLoadedPrepareLayerRes then 
        self:startEnterPrepareLayer();
    else
        self:loadPrepareLayerRes(function() 
            self:startEnterPrepareLayer();
            self.isLoadedPrepareLayerRes = true;
        end);
    end
    self:setIsTryEnterActivityToday(true);
    self:CallBaiduRecord(self.STR_EVENT_CLICK_ACTIVITY_TOP_BTN);     --统计用户点击入口按钮次数
end



-- ----- [私有方法] -----



--[[
    抹去用户所有签到数据
]]--
function ActivityBaseLayer:wipeOutSignData()
    for i = self.INT_MIN_PREPARE_DAY,self.INT_MAX_PREPARE_DAY,1 do 
        self:setUserSignInInfoByDay(i,false);
    end
    self:setIsUserFirstEnterActivity(false);
    self:setIsTryEnterActivityToday(false);
end

--[[
    更新预热界面信息
]]--
function ActivityBaseLayer:updateData()

    -- 1.更新data今日日期
    self.data.dayIndex = self.m_dayIndex;


    -- 2.根据日期更新item状态
    local minDate = 1;
    local maxDate = math.min(self.m_dayIndex-1,self.INT_MAX_PREPARE_DAY) ;
    if maxDate >= minDate then 
        for i= minDate ,maxDate,1 do 
            self.data.listOfItems[i].status = ActivityItem.EnumOfItemStatus.E_UNLOCKED;
        end
    end
    if self.m_dayIndex<=self.INT_MAX_PREPARE_DAY then 
        self.data.listOfItems[self.m_dayIndex].status = ActivityItem.EnumOfItemStatus.E_TODAY;
    end
    
    -- 3.根据点击情况更新item 状态
    for i = self.INT_MIN_PREPARE_DAY,self.INT_MAX_PREPARE_DAY,1 do 
        local info = self:getUserSignInInfoByDay(i);
        if info == "" or info == self.STR_UN_SIGN_IN then 
        elseif info == self.STR_SIGN_IN then 
            self.data.listOfItems[i].status = ActivityItem.EnumOfItemStatus.E_GETED;
        end
    end

    -- 4.更新vip状态
    self.data.VIP = ( UInfoUtil:getInstance():getVipLevel() ~= 0 );

    -- 更新准备界面
    self:updatePrepareLayer();
end

--[[
    根据日期获取用户签到信息
    参数:
    d:活动启动后的第几天
]]--
function ActivityBaseLayer:getUserSignInInfoByDay(d) -- STR_EVENT_SIGN _ UserId _ Date
	local curIdStr = UInfoUtil:getInstance():getCurUidStr()
	local strKey = self.STR_LOCAL_EVENT_SIGN.."_"..curIdStr.."_"..d;
	local gUserData = cc.UserDefault:getInstance() 
    local isSign = gUserData:getStringForKey(strKey);
    print("isSign:"..isSign);
    return isSign;
end

--[[
    设置用户签到信息
    参数:
    d:活动启动后的第几天
    isSignIn:true 签到，false 未签到
]]--
function ActivityBaseLayer:setUserSignInInfoByDay(d,isSignIn)
	local curIdStr = UInfoUtil:getInstance():getCurUidStr()
    local strKey = self.STR_LOCAL_EVENT_SIGN.."_"..curIdStr.."_"..d;
    local gUserData = cc.UserDefault:getInstance() 
    if isSignIn then 
        gUserData:setStringForKey(strKey,self.STR_SIGN_IN)
    else 
        gUserData:setStringForKey(strKey,self.STR_UN_SIGN_IN);
    end
    gUserData:flush();
end


--[[
    获取是否是首次进入
]]--
function ActivityBaseLayer:getIsUserFirstEnterActivity()
	local curIdStr = UInfoUtil:getInstance():getCurUidStr();
	local strKey = self.STR_LOCAL_EVENT_FIRST_ENTER_PRE_LAYER..curIdStr;
	local gUserData = cc.UserDefault:getInstance() ;
    local str = gUserData:getStringForKey(strKey,"") ;  
    print("check:"..str); 
    return( str == self.STR_FALSE or str == "" );
end

--[[
    设置首次进入信息
    参数:
    v: true:[首次签到] false:[首次没签到]
]]--
function ActivityBaseLayer:setIsUserFirstEnterActivity(v)
	local curIdStr = UInfoUtil:getInstance():getCurUidStr();
	local strKey = self.STR_LOCAL_EVENT_FIRST_ENTER_PRE_LAYER..curIdStr;
    local gUserData = cc.UserDefault:getInstance() ;
    if v then 
        gUserData:setStringForKey(strKey,self.STR_TRUE) ;   
    else 
        gUserData:setStringForKey(strKey,self.STR_FALSE) ;   
    end
    gUserData:flush();
end


--[[
    设置当天是否点击过活动入口按钮
    参数:
    v: true:[点击过] false:[未点击过]
]]--
function ActivityBaseLayer:setIsTryEnterActivityToday(v)
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
	local strKey = self.STR_LOCAL_EVENT_TRY_ENTER_TODAY..curIdStr.."_"..self.m_dayIndex;
    local gUserData = cc.UserDefault:getInstance() ;
    if v then 
        gUserData:setStringForKey(strKey,self.STR_TRUE) ;   
    else 
        gUserData:setStringForKey(strKey,self.STR_FALSE) ;   
    end
    gUserData:flush();
end

--[[
    获取当天是否点击过活动入口按钮
]]--
function ActivityBaseLayer:getIsTryEnterActivityToday()
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
	local strKey = self.STR_LOCAL_EVENT_TRY_ENTER_TODAY..curIdStr.."_"..self.m_dayIndex;
    local gUserData = cc.UserDefault:getInstance() ;
    local str = gUserData:getStringForKey(strKey) ; 
    return (str == self.STR_TRUE);
end


--[[
    设置预热界面是否启动
    参数:
    v:预热界面是否启动
]]--
function ActivityBaseLayer:setTopMenuLayerActive(v)
    self.topMenuLayerActive = v;
end

--[[
    获取预热界面是否启动
]]--
function ActivityBaseLayer:GetTopMenuLayerActive()
    return self.topMenuLayerActive;
end

--[[
    隐藏主界面UI
]]--
function ActivityBaseLayer:HideMainScreenUI()
    HomeUILayer:getCurInstance():getNormalUIItem():hideLeftMenuLayer();
    HomeUILayer:getCurInstance():getNormalUIItem():hideRightMenuLayer();
    HomeUILayer:getCurInstance():getNormalUIItem():setMenuDownInvisible();	
end

--[[
    显示主界面UI
]]--
function ActivityBaseLayer:ResumeMainScreenUI()
    HomeUILayer:getCurInstance():getNormalUIItem():showLeftMenuLayer();
    HomeUILayer:getCurInstance():getNormalUIItem():showRightMenuLayer();
    HomeUILayer:getCurInstance():getNormalUIItem():setMenuToNormal();
end

--[[
    主界面小伴龙播放json
    参数:
    jsonName:将要播放的json名称
    cb:json播放完成的回掉
]]--
function ActivityBaseLayer:XBLMainScreenPlayJson(jsonName,cb)
    local xblNpc = Home7World:getCurInstance():getHomeNpcByName("XBL")
    xblNpc:playXBLSayNewActionScripts(
        jsonName,
        self.imagePath,
        self.jsonPath,
        self.audioPath,
        function() 
            if cb~= nil then 
                cb();
                cb = nil;
            end
        end
    )  
end

--[[
    初始化预热窗口界面（如果界面不存在则创建界面）
]]--
function ActivityBaseLayer:initPrepareLayer()
    if self.topMenuLayer == nil then 
        local luaFile = "task.appscripts.YuReWindowLayer"	
        local YuReWindowLayer = requirePack(luaFile, false);
        self.topMenuLayer = YuReWindowLayer.new() ;
        self.topMenuLayer:SetParentNode(self);
        self.topMenuLayer:Init(self.taskPath);
        self:addChild(
            self.topMenuLayer,
            ActivityBaseLayer.CurZOrderSet.popLayerZorder
        );
    end
end

--[[
    更新预热界面
]]--
function ActivityBaseLayer:updatePrepareLayer()
    if self.topMenuLayer ~= nil then 
        self.topMenuLayer:Update(self.data);
    end
end

--[[
    撤销预热窗口（移除掉预热窗口）
]]--
function ActivityBaseLayer:disposePrepare()
    if self.topMenuLayer ~= nil then 
        self.topMenuLayer:removeFromParent();
    end
end

--[[
    调用百度统计方法
    参数:
    eventName:百度统计事件名称
]]--
function ActivityBaseLayer:callBaiduRecord(eventName)
    print("ActivityBaseLayer:callBaiduRecord");
    print(type(eventName));
    if eventName ~= nil then 
        Utils:GetInstance():baiduTongji(self.STR_EVENT_TYPE ,eventName)
    end
end

--[[
    调用百度统计事件开始方法
    参数:
    eventName:事件名称
]]--
function ActivityBaseLayer:CallBaiduEventStart(eventName)
    if eventName ~= nil then 
        Utils:GetInstance():baiduTongjiEventStart(self.STR_EVENT_TYPE ,eventName)
    end
end

--[[
    调用百度统计事件结束方法
    参数:
    eventName:事件名称
]]--
function ActivityBaseLayer:CallBaiduEventEnd(eventName)
    if eventName ~= nil then 
        Utils:GetInstance():baiduTongjiEventEnd(self.STR_EVENT_TYPE ,eventName)
    end
end

--[[
    正式启动活动
]]--
function ActivityBaseLayer:startActivity(  )
    self:initData();
    self:createActivityEnterUIForMainScreen();

    self:CallBaiduRecord(self.STR_EVENT_SHOW_ACTIVITY);                    -- 统计入口按钮展示次数
end



--[[
    初始化预热界面数据
]]--
function ActivityBaseLayer:initData()
    -- 0.计算当前日期
    local index = self:caculateDayIndex();
	if index == 0 then
		return
	end
    self.m_dayIndex = index;
    
    -- 1.上锁所有的item
    self.data = {}
    self.data.listOfItems = {};

    for i = 1,self.INT_MAX_PREPARE_DAY,1 do 
        local itemData = {};
        itemData.index = i;
        itemData.status = ActivityItem.EnumOfItemStatus.E_LOCK;
        table.insert(self.data.listOfItems,itemData)
    end
    
    -- 更新数据
    self:updateData();


end

--[[
    根据根目录初始化所有路径成员
    参数:
    rot:根目录
]]--
function ActivityBaseLayer:initPathByRootPath(rot)
    self.packagePath = rot;      
    self.taskPath  = self.packagePath .. self.STR_TASK .. "/";
    self.animPath  = self.taskPath .. self.STR_ANIM  .. "/";         
    self.jsonPath  = self.taskPath .. self.STR_JSON  .. "/";         
	self.imagePath = self.taskPath .. self.STR_IMAGE .. "/";        
    self.audioPath = self.taskPath .. self.STR_AUDIO .. "/";
    self.preparePath = self.taskPath .. self.STR_PREPARE .. "/";

    g_tConfigTable.imagePath = self.imagePath;
    g_tConfigTable.jsonPath  = self.jsonPath;
    g_tConfigTable.audioPath = self.audioPath;
    
    JsonScriptUtil.SetJsonPath(self.jsonPath,self.imagePath,self.audioPath);
    
    g_tConfigTable.sTaskpath = self.taskPath ;

end

--[[
    初始化iphonex 适配
]]--
function ActivityBaseLayer:initIphoneXAdapt()
	self.liuHaiY = 0;
	self.liuHaiY1 = 0;
	if Utils:GetInstance():getIsIphoneX() then
		self.liuHaiY = 20
		self.liuHaiY1 = -20;
	end
end

--[[
    异步加载资源
    参数:
    asyncResPath:   异步资源路径
    cb:             加载完成回掉
]]--
function ActivityBaseLayer:loadResAsync(asyncResPath,cb) 
	AsyncLoadRes:shareMgr():addOneDirAsyncLoadLua(asyncResPath, "", self.STR_ASYNC_RES_KEY , function(key)
        local arr = {}
		table.insert(arr,cc.DelayTime:create(0.3))
		table.insert(arr,cc.CallFunc:create(function() 
            if cb ~= nil then 
                cb(); 
            end
		end))
		self:runAction(cc.Sequence:create(arr))
    end)
end


--[[
    计算目前时间索引
]]--
function ActivityBaseLayer:caculateDayIndex()
	-- Block: 设置活动时间配置
	local nLocalTime = --[[ 1574438400-- ]]os.time(); -- 当前时间
	local dayStamp = self.INT_SECOND_OF_DAY;          -- 一天的时间(秒)
	local startTime = self.activityStartTime;         -- 开始日期的时间撮（秒）
    local maxday = self.INT_MAX_ACTIVITY_TIME;        -- 活动最大时间
    
	-- Block: 计算目前是哪一天
	local index = 0                                   -- 目前是哪一天
	for k=1,maxday do
		if nLocalTime >= startTime + (k - 1) * dayStamp and nLocalTime < startTime + k * dayStamp then
			index = k
			break
		end
    end
    -- debug 控制启动时间
    if ActivityBaseLayer.DEBUG_MODE ~= nil then 
        if ActivityBaseLayer.DEBUG_MODE == ActivityBaseLayer.DEBUG_ENTER_MODE.E_PRE then 
            index = self.INT_MIN_PREPARE_DAY+ActivityBaseLayer.DEBUG_MODE_PRE_DAY_INDEX-1;
            print("mark:"..index);
            print("mark2:"..self.INT_MIN_PREPARE_DAY);
            print("mark3:"..ActivityBaseLayer.DEBUG_MODE_PRE_DAY_INDEX);
        elseif ActivityBaseLayer.DEBUG_MODE == ActivityBaseLayer.DEBUG_ENTER_MODE.E_FORMAT then 
            index = self.INT_MAX_PREPARE_DAY+ActivityBaseLayer.DEBUG_MODE_FORMAT_DAY_INDEX;
        end
    end
    return index;
end




function ActivityBaseLayer:createTopBtn()
    -- Block: 进入活动的触碰区域
    local itemPath = THEME_IMG("transparent.png")
    self.m_topBtn  = ccui.Button:create(itemPath,itemPath);
    self.m_topBtn:setAnchorPoint(cc.p(0.5,0.5));
    self.m_topBtn:setPosition(cc.p(768*0.5,1024-200 - self.liuHaiY1));
    self.m_topBtn:setPressedActionEnabled(true); 
    self.m_topBtn:setVisible(true);
    self.m_topBtn:setScale(ArmatureDataDeal:sharedDataDeal():getIsHdScreen() and 20 or 10)
    self:addChild(self.m_topBtn , CurZOrderSet.topButtonZorder);
    -- Block: 点击活动按钮的事件
    self.m_topBtn:addClickEventListener(function(sender)
        print("self.m_topBtn:addClickEventListener");
        self:onUserClickActivityBtn();
    end)
end

function ActivityBaseLayer:createOneTouchArmGL(parent, anim, idx, pos, scale, nzorder, bGL)
	local arm = TouchArmature:create(anim, TOUCHARMATURE_NORMAL);	
	arm:setScale(scale)
	arm:setPosition(bGL and cc.p(pos.x, 1024 - pos.y) or pos)
	arm:playByIndex(idx, LOOP_YES)
	parent:addChild(arm, nzorder);
	local x,y,width,height = 0,0,0,0
	x,y,width,height = arm:getBoundingBoxValue(x,y,width,height)
	arm.boxRect = cc.rect(x - width/2,y - height/2,width,height)
	return arm
end

--[[
    创建活动入口按钮
]]--
function ActivityBaseLayer:createPumpkinBtn()
    local winSize = cc.Director:getInstance():getWinSize()
    return self:createOneTouchArmGL(self, self.STR_PUMPKIN_ARMTURE_NAME, 0, cc.p(389, winSize.height*0.5+512 - self.liuHaiY), 0.427, 500, false);
end


--[[
    根据活动日期创建对应的活动入口按钮
    参数:
    index : 活动已经启动的天数 [1天 - 10天]
]]--
function ActivityBaseLayer:initActivityEnterBtnByDayIndex(index)
    self.pumpkin = self:createPumpkinBtn();
	if index >= self.INT_MIN_PREPARE_DAY and index <= self.INT_MAX_PREPARE_DAY then	
        self:createTopBtn();
		self.pumpkin:ChangeOneSkin(self.STR_PUMPKIN_SLOT_NAME ,self.STR_PUMPKIN_SLOT_IMAGE_PRE)
	else
		self.pumpkin:ChangeOneSkin(self.STR_PUMPKIN_SLOT_NAME ,self.STR_PUMPKIN_SLOT_IMAGE_FORMAT)
    end

    local isTryEnterActivityToDay = self:getIsTryEnterActivityToday();
    if isTryEnterActivityToDay == false then 
        self.pumpkin:playByIndex(1,LOOP_YES);
    else 
        self.pumpkin:playByIndex(0,LOOP_YES);
    end

end

--[[
    开始启动预热界面
]]--
function ActivityBaseLayer:startEnterPrepareLayer()
    if self:GetTopMenuLayerActive() == false then 
        self:setTopMenuLayerActive(true);
        self:AnimPlayTopBtnClick();
    
        
        --self:recordUserClickedActivityEnterBtnToday();
    
        self:playSoundEffectClick(function() 
            self:XBLMainScreenActWellComeForEnterActivity(function()
                --self:recordUserEnterActivityPrepareLayer();
                self:enterPrepareLayer();
            end);
        end);
    
        self:HideMainScreenUI();
        Home7World:getCurInstance():setOnlyScrollEnable(false);
        Home7World:getCurInstance():setAllTouchEnableLua(false);
    end

end

--[[
    开始推出预热界面
]]--
function ActivityBaseLayer:startExitPrepareLayer()

    self:exitPrepareLayer();
    self:setTopMenuLayerActive(false);

end



--[[
    进入预热界面
    参数:
    cb:主界面切换成预热界面完成回掉
]]--
function ActivityBaseLayer:enterPrepareLayer(cb)
    SimpleAudioEngine:getInstance():playEffect("allaudios/animationSound/sound003.mp3");		

    self:initPrepareLayer();
    self:updateData();
    --self:updatePrepareLayer();
    self:SetMainScreenStatusForEnterPrepareLayer();
    self:ShiftMainScreenToPrepareLayer(self.topMenuLayer,function() 
        self:prepareLayerStart();
    end);
end

--[[
    退出预热界面
    参数:
    cb:预热界面切换回主界面完成回掉
]]--
function ActivityBaseLayer:exitPrepareLayer(cb)
     self:ShiftPrepareLayerToMainScreen(self.topMenuLayer);
     self:SetMainScreenStatusForExitPrepareLayer();
end

--[[
    预热界面启动
]]--
function ActivityBaseLayer:prepareLayerStart()
    if self.topMenuLayer ~= nil then 
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.016),cc.CallFunc:create(function() 
            Home7World:getCurInstance():setAllTouchEnableLua(true);
            self.topMenuLayer:Start()
        end)));
    end
end



--[[
    本地记录玩家按过主界面活动进入按钮
]]--
--[[
function ActivityBaseLayer:recordUserClickedActivityEnterBtnToday()
    -- Block: 设置本地是记录当天是否有人点击过按钮
    local gUserData = cc.UserDefault:getInstance() 	
    local strKey = self.STR_LOCAL_EVENT_ENTER_BTN_CLICK_TODAY..UInfoUtil:getInstance():getCurUidStr().."_"..self.m_dayIndex
    local isnotClick = gUserData:getStringForKey(strKey,"")
    if isnotClick == "" then
        gUserData:setStringForKey(strKey, "1")
    end
end
]]--

--[[
    本地记录玩家进入过预热界面
]]--
--[[
function ActivityBaseLayer:recordUserEnterActivityPrepareLayer()
    -- Block: 设置用户进来过
    local curIdStr = UInfoUtil:getInstance():getCurUidStr()
    local strKey = self.STR_LOCAL_EVENT_ENTER_PRE_LAYER_TODAY..curIdStr.."_"..self.m_dayIndex
    local gUserData = cc.UserDefault:getInstance() 
    gUserData:setStringForKey(strKey, "1")
    gUserData:flush()
end
]]--


--[[
    播放点击音效
]]--
function ActivityBaseLayer:playSoundEffectClick(cb)
    -- Block: 播放点击音效
    HomeUILayer:getCurInstance():getNormalUIItem():clickDo(
        function() 
            if cb ~= nil then 
                cb();
            end
        end,
        false,
        THEME_FILE("sounds/ui002.mp3")
    );
end






-- ----- 动画播放 -----
--[[
    活动入口按钮点击动画
]]--
function ActivityBaseLayer:AnimPlayTopBtnClick()
    ArmatureUtil.PlayAndStay(self.pumpkin,2,0);
end

-- ----- [对子类方法 用来子类调用] -----
--[[
    设置活动开启时间
    参数:
    year:   年
    month:  月
    day:    日
    hour:   时
    minute: 分
    second: 秒
]]--
function ActivityBaseLayer:setActivityStartTime(year,month,day,hour,minute,second)
    local t = os.time({ year=year,month=month,day=day, hour=hour, minute=minute, second=second});
    self.activityStartTime = t;
end

--[[
    设置主界面顶部入口按钮
    参数:
    armatureName:    顶部按钮动画名称
    preImageName:    预热活动按钮图片名称
    formatImageName: 正式活动按钮图片名称
]]--
function ActivityBaseLayer:setTopBtnArmtureInfo(armatureName,preImageName,formatImageName)
    self.STR_PUMPKIN_ARMTURE_NAME = armatureName;                        
    self.STR_PUMPKIN_SLOT_IMAGE_PRE = preImageName;       
    self.STR_PUMPKIN_SLOT_IMAGE_FORMAT = formatImageName; 
end

--[[
    为主界面创建活动相关UI
]]--
function ActivityBaseLayer:createActivityEnterUIForMainScreen()
	self:initActivityEnterBtnByDayIndex(self.m_dayIndex);
	self:initActivityDownloadBtn()
end


function ActivityBaseLayer:initActivityDownloadBtn()
	local winSize = cc.Director:getInstance():getWinSize()
	local bagId = "22"
	local msi = MenuItemNetData:getInstance():getOneMenuShowItem(MENU_TYPE_XIALINGYING,bagId,true);
	if(msi and msi.fnType) then
		local xiaLingYingButton = requirePack("task.appscripts.XiaLingYingButton", false); 
		local cNode = xiaLingYingButton.new() --不传参数。通过赋值的形式 来处理 
		cNode:init(self.m_dayIndex,self.taskPath,self)
		cNode:onShowCellContent(msi)
		cNode:setAnchorPoint(cc.p(0.5,0.5)) -- 锚点 是 0  0 
		cNode:setPosition(cc.p(768*0.5-70,winSize.height*0.5 + 320 - self.liuHaiY)) -- 212 = 512 - 70 - 230
		self:addChild(cNode, ActivityBaseLayer.CurZOrderSet.xialingyingButtonZorder);
		self.m_xiaLingYingBtn = cNode
	end
end


-- ----- [对外接口 用来重写扩展] -----


--[[
    调用百度统计方法
    参数:
    eventName:百度统计事件名称
]]--
function ActivityBaseLayer:CallBaiduRecord(eventName)
    self:callBaiduRecord(eventName);
end

--[[
    设置背景音乐路径
    参数:
    v:背景音乐路径
]]--
function ActivityBaseLayer:SetBGMPath(v)
    self.backGroundMusicPath = v;
end

--[[
    获取背景音乐路径
]]--
function ActivityBaseLayer:GetBGMPath()
    return self.backGroundMusicPath;
end

--[[
    设置用户签到信息
    参数:
    d:活动启动后的第几天
    isSignIn:true 签到，false 未签到
]]--
function ActivityBaseLayer:SetUserSignInInfoByDay(d,isSignIn)
    self:setUserSignInInfoByDay(d,isSignIn);
end

--[[
    获取用户签到信息
    参数:
    d:活动启动后的第几天
]]--
function ActivityBaseLayer:GetUserSignInInfoByDay(d)
    return (self.STR_SIGN_IN  == self:getUserSignInInfoByDay(d)); 
end


--[[
    活动层初始化方法( 重写这个方法扩展活动的数据初始化 )
]]--
function ActivityBaseLayer:init()
    print("ActivityBaseLayer:init");

end

--[[
    活动启动方法 （ 重写这个方法扩展活动的启动，或设置活动的启动相关信息 ）
    参数:
    sSdPath:sd卡路径（相当于活动包根路径）
]]--
function ActivityBaseLayer:start(sSdPath)
    if ActivityBaseLayer.DEBUG_WIPEOUT_SIGN_DATA then 
        self:wipeOutSignData();
    end
    print("ActivityBaseLayer:start");
    local nowTime = os.time();
    if nowTime >= self.activityStartTime then 
        self:initIphoneXAdapt();
        self:initPathByRootPath(sSdPath);
        -- todo init prepareLayer data
        self:loadResAsync(self.animPath,function()
            self:onAsyncResLoadComplie();
        end);
    end
   

end

--[[
    重写这个方法，定义预热界面如何出现(视觉表现)
    参数:
    n: 预热界面
    cb:切换完成的回掉
]]--
function ActivityBaseLayer:ShiftMainScreenToPrepareLayer(n,cb)
    self.topMenuLayer:OnEnter();
end

--[[
    重写这个方法，定义预热界面如何隐藏(视觉表现)
    参数:
    n: 预热界面
    cb:切换完成的回掉
]]--
function ActivityBaseLayer:ShiftPrepareLayerToMainScreen(n,cb)
    self.topMenuLayer:OnExit();
end

--[[
    进入预热界面，设置主界面状态
]]--
function ActivityBaseLayer:SetMainScreenStatusForEnterPrepareLayer()


    Home7World:getCurInstance():setOnlyScrollEnable(false);

    local xblNpc = Home7World:getCurInstance():getHomeNpcByName("XBL")
    xblNpc:setToXBLvision()


    Home7World:getCurInstance():setOnlyScrollEnable(false)  
end

--[[
    退出预热界面，还原主界面状态
]]--
function ActivityBaseLayer:SetMainScreenStatusForExitPrepareLayer()

    Home7World:getCurInstance():setOnlyScrollEnable(true) ;
    HomeUILayer:getCurInstance():getNormalUIItem():getCanTouch();

    local xblNpc = Home7World:getCurInstance():getHomeNpcByName("XBL");
    xblNpc:playXianZhi();
    xblNpc:setToXBLvision();

    self:ResumeMainScreenUI();
end

--[[
    主界面小伴龙小伴龙表演 [欢迎玩家进入活动预热界面] XBLMainScreen
]]--
function ActivityBaseLayer:XBLMainScreenActWellComeForEnterActivity(cb)
    self:XBLMainScreenPlayJson(JsonScriptConfig.FIRST_CLICK_ACTIVITY_BTN,function() 
        if cb ~= nil then 
            cb();
        end
    end);
end


--[[
    更新预热界面
]]--
function ActivityBaseLayer:UpdatePrepareLayer()
    self:updateData();
    --self:updatePrepareLayer();
end


--[[
    获取是否是首次进入
]]--
function ActivityBaseLayer:GetIsUserFirstEnterActivity()
	return self:getIsUserFirstEnterActivity();
end

return ActivityBaseLayer;


--[[
	-- Block: 计算是否第一次启动
	local curIdStr = UInfoUtil:getInstance():getCurUidStr()
	local strKey = "ganenjie_zhaohu_ry_"..curIdStr
	local gUserData = cc.UserDefault:getInstance() 
	local isFirstYrZh = "1"--gUserData:getStringForKey(strKey,"")
	--strKey = "ganenjie_zhaohu_act_"..curIdStr
	--self.isFirstActZh = gUserData:getStringForKey(strKey,"")
			if isFirstYrZh ~= "" then
			print("isFirstYrZh ~= empty string");
			local winSize = cc.Director:getInstance():getWinSize()
			local pumpkin = self:createOneTouchArmGL(self, "20191101_rukou", 0, cc.p(389, winSize.height*0.5+512 - self.liuHaiY), 0.427, 500, false)
			pumpkin:ChangeOneSkin("deng","191128ge_rukoudeng2.png")
			self.pumpkin = pumpkin

			if self.m_topBtn then
				self.m_topBtn:setVisible(true)
			end
		end
]]--

--[[
    创建主界面预热活动层
]]--
--[[
function ActivityBaseLayer:createTopMenuLayer()
	-- Block: 进入活动
	--self:removeTopMenuLayer(true)

	-- Block: 获取活动层 
	--local luaFile = "task.appscripts.YuReWindowLayer"	
	--local YuReWindowLayer = requirePack(luaFile, false);
	--local cNode = YuReWindowLayer.new() --不传参数。通过赋值的形式 来处理 
	
	-- Block: 活动层初始化
	--cNode:init(self.taskPath)
	
	-- Block: 设置活动层节点
	--cNode:setTag(20190903)
	--cNode:setContentSize(768,1024)
	--cNode:setPosition(cc.p(0,300)) -- 设置节点位置
	--cNode:setAnchorPoint(cc.p(0,0))
	
	-- Block: 添加活动层
	--self:addChild(cNode,ActivityBaseLayer.CurZOrderSet.popLayerZorder)
	

	--self.topMenuLayer = cNode
	--self.topMenuLayer.normalPX = 0
	--self.topMenuLayer.normalPY = 0
	--self.topMenuLayer.moveoutPY = 300
	--self.topMenuLayer.parentNode = self    -- wait to get ride of
    --self.moveTime = 0.6                    -- wait to get ride of
    
	Home7World:getCurInstance():setOnlyScrollEnable(false) 

	-- 跳转场景
	--self:showTopMenuLayer(0.2)
	self:ShiftMainScreenToPrepareLayer(self.topMenuLayer);
end
]]--    