local JsonScriptConfig = requirePack("task.appscripts.JsonScriptConfig");
local JsonScriptUtil = requirePack("task.appscripts.JsonScriptUtil");
local  ActivityItem = requirePack("task.appscripts.Base.ActivityItems.ActivityItem");
local  PrepareBaseLayer = requirePack("task.appscripts.PrepareBaseLayer");
local  ArmatureUtil = requirePack("task.appscripts.ArmatureUtil");

local HomeEventName = requirePack("sceneScripts.HomeEvent")
local YuReMoonLayer = class("YuReMoonLayer", function()
	return PrepareBaseLayer.new();
end)
g_tConfigTable.CREATE_NEW(YuReMoonLayer);

-- ----- 事件 -----
--[[
	用户点击灯开关按钮
]]--
function YuReMoonLayer:onBtnClickVIPUserStarLamp()
	if self:GetData() ~= nil  then 
		if self:GetData().VIP then 
			self:switchVIPLamp();
		end
	end

	self:NoOperationCount();
end

--[[
	用户点击装饰按钮
]]--
function YuReMoonLayer:onBtnClickDecoration()
	if self:IsXBLWellComeActing() == false then 
		if self.cbOfClickDecorationBtn_ ~= nil then 
			self.cbOfClickDecorationBtn_();
			self.cbOfClickDecorationBtn_ = nil;
		end
	end

	self:NoOperationCount();
end

--[[
	用户点击小伴龙
]]--
function YuReMoonLayer:onBtnClickXBL(  )
	if self:IsXBLWellComeActing() == false then 

		self:CallBaiduRecord("xmas19_click_xbl_");              -- 点击小伴龙统计

		self:xblGuide();
	end

	self:NoOperationCount();
end

-- ----- 生命周期方法 -----

--[[
    预热界面切换完成后被调用的方法
]]--
function YuReMoonLayer:Start()
	print("YuReMoonLayer:Start");
	if self:GetParentNode():GetIsUserFirstEnterActivity() then 
		print("YuReMoonLayer:Start1");

		self:XBLWellCome();
	else 
		print("YuReMoonLayer:Start2");

		local todayIndex = self:GetData().dayIndex;
		local jsonName = "";
		if self:GetParentNode():GetUserSignInInfoByDay(todayIndex) then 
			jsonName = JsonScriptConfig.GET_GIFT_OP_JSON;
		else 
			local item = JsonScriptUtil.GetNpcByName(self,ActivityItem.GetItemArmatureName()..todayIndex);
		    local x,y = item:getPosition();
		    self:showFingerTipAtPos(cc.p(x,y));
			jsonName = JsonScriptConfig.UNLOCK_OP_JSON[todayIndex];
		end
		self:guide(jsonName);
	end
	self:NoOperationCount();

	self:GetParentNode():setIsUserFirstEnterActivity(true);
end

-- ----- 初始化 -----

function YuReMoonLayer:ctor()
	self.listOfActivityItems_ = {}                             -- 活动item列表
	self.numOfActiviyNum_ = 7;                                 -- 活动预热天数

	ActivityItem.SetItemArmatureName("npc_daoju");             -- 活动item 动画前缀名
	ActivityItem.SetItemGiftArmatureName("npc_daoju0");        -- 活动item 礼物前缀名
	ActivityItem.SetItemImageName("gui_gift0");                -- 活动item 图片前缀名

	self.VIPLampActive_ = true;                                -- VIP 灯光是否开启

	self.armActivityItemUnlockPath_ = nil;                     -- 活动item解锁路径 armature 动画
	self.armVIPLamp_ = nil;                                    -- VIP牛逼闪闪灯    armature 动画
	self.lbDayCountDown_ = nil ;                               -- 正式活动开始日期倒数母label
	self.lbActivityDay_ = nil;                                 -- 活动当天日期标签


	self.jsonScriptSingleTrackTag_  = -1;                      -- 当前运行的json tag 值
	self.cbOfJsonScriptSingleTrack_ = nil;                     -- 单一json播放轨道json 完成回掉 
	
	self.cbOfClickDecorationBtn_ = nil;                        -- 用户点击装饰按钮的回掉

	self.wellcomeActing_ = false;                              -- 小伴龙欢迎说明动画
	self.xblGuiding_ = false;                                  -- 小伴龙是否正在引导

	self.noOperationQuitTime = 60;                             -- 用户无操作推出时间(单位秒)

end

--[[
	用户无操作，自动退出计时开始[每次用户点击操作后调用]
]]--
function YuReMoonLayer:NoOperationCount(  )
	local tag = 1002;
	self:stopActionByTag(tag);
	local seq = cc.Sequence:create(cc.DelayTime:create(self.noOperationQuitTime),cc.CallFunc:create(function() 
		self:guide(JsonScriptConfig.XBL_AUTO_LEAVE,function() 
			self:onUserClickBtnExitPrepareLayer();
		end);
	end));
	seq:setTag(tag);
	self:runAction(seq);
end


--[[
	重写这个方法定义界面初始状态
]]--
function YuReMoonLayer:initView() 
	--local bg =  JsonScriptUtil.GetNpcByName(self,"bg");
	--bg:setScale(0.001);
	local contentSize = self:getContentSize();
	-- 初始化界面布局
	JsonScriptUtil.PlayBgConfig(self ,"Xmas_bg2",function()
		--self:Start();
		writeToFile("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxcomplie:PlayBgConfig");
	end);

	self.armActivityItemUnlockPath_ = JsonScriptUtil.GetNpcByName(self,"npc_lu");
	self.armVIPLamp_                = JsonScriptUtil.GetNpcByName(self,"vip_deng");
	self.lbActivityDay_             = JsonScriptUtil.GetNpcByName(self,"bg_riqi2");
	
	self.lbDayCountDown_            = cc.Label:createWithSystemFont("0","",60*0.426);
	self.lbDayCountDown_:setColor(cc.c3b(0xfe,0xa0,0x24,0xff));
	self.lbDayCountDown_:setScale(0.9);
	JsonScriptUtil.GetNpcByName(self,"npc_991"):addChild(self.lbDayCountDown_);

	self.btnOfVIPStar = ccui.Button:create(g_tConfigTable.imagePath.."btnStar.png",g_tConfigTable.imagePath.."btnStar.png");
	self:addChild(self.btnOfVIPStar,JsonScriptUtil.INT_MAX_ENGINE_ZORDER);
	
	self.btnOfVIPStar:setPosition(cc.p(contentSize.width/2,contentSize.height/2));
	self.btnOfVIPStar:addClickEventListener(function(sender)
		self:onBtnClickVIPUserStarLamp();
	end);

	self.btnDecoration_ = ccui.Button:create(g_tConfigTable.imagePath.."btnDecoration.png",g_tConfigTable.imagePath.."btnDecoration.png");
	self:addChild(self.btnDecoration_,JsonScriptUtil.INT_MAX_ENGINE_ZORDER +3);
	self.btnDecoration_:addClickEventListener(function ( sender )
		print("self.btnDecoration_:addClickEventListener");
		self:onBtnClickDecoration();
	end);
	local decorationItem = JsonScriptUtil.GetNpcByName(self, "npc_zuobiao");
	local x,y = decorationItem:getPosition();
	self.btnDecoration_:setPosition(cc.p(x,y));


	self.btnShowDecorationBlock_ = ccui.Button:create(g_tConfigTable.imagePath.."btnDecoration.png",g_tConfigTable.imagePath.."btnDecoration.png");
	self:addChild(self.btnShowDecorationBlock_,JsonScriptUtil.INT_MAX_ENGINE_ZORDER +2);
	self.btnShowDecorationBlock_:setPosition(cc.p(contentSize.width/2,contentSize.height/2));
	local btnContentSize = self.btnShowDecorationBlock_:getContentSize();
	self.btnShowDecorationBlock_:setScaleX(contentSize.width/btnContentSize.width);
	self.btnShowDecorationBlock_:setScaleY(contentSize.height/btnContentSize.height);
	self.btnShowDecorationBlock_:setVisible(false);

	self.armFinger_ = TouchArmature:create("point_all",TOUCHARMATURE_NORMAL);
	self:addChild(self.armFinger_,JsonScriptUtil.INT_MAX_ENGINE_ZORDER +1);
	self.armFinger_:setVisible(false);
	ArmatureUtil.PlayLoop(self.armFinger_,1);
	self.armFinger_:setScale(0.6);

	local xbl = self:getChildByName("XBL");
	if xbl ~= nil then 
		x,y = xbl:getPosition();
		self.btnXBL_  = ccui.Button:create(g_tConfigTable.imagePath.."btnBlackBtn.png",g_tConfigTable.imagePath.."btnBlackBtn.png");
		self:addChild(self.btnXBL_,JsonScriptUtil.INT_MAX_ENGINE_ZORDER + 1);
		self.btnXBL_:addClickEventListener(function ( sender )
			self:onBtnClickXBL();
		end);
		self.btnXBL_:setPosition(cc.p(x,y));
	end
end

--[[
	在某个位置显示手指提示
	参数:
	p:目标位置
]]--
function YuReMoonLayer:showFingerTipAtPos(p)
	if self.armFinger_ ~= nil and p ~= nil then 
		self.armFinger_:setVisible(true);
		self.armFinger_:setPosition(p);
	end
end

--[[
	关闭手指提示
]]--
function YuReMoonLayer:closeFingerTip()
	if self.armFinger_ ~= nil then 
		self.armFinger_:setVisible(false);
	end
end

--[[
    撤销活动按钮
]]--
function YuReMoonLayer:disposeActivityItems()
	for i=1,self.numOfActiviyNum_,1 do 
		self.listOfActivityItems_[i]:Dispose();
	end
end

--[[
    初始化活动按钮
]]--
function PrepareBaseLayer:initActivityItems()
	for i=1,self.numOfActiviyNum_,1 do 
		local item = ActivityItem.new();
		item:Init(self);
		table.insert(self.listOfActivityItems_,item);
	end
end

-- ----- 私有功能函数 -----

--[[
	是否小伴龙正在引导
]]--
function YuReMoonLayer:IsXBLGuiding()
	return self.xblGuiding_;
end


--[[
	是否小伴龙正在欢迎动作
]]--
function YuReMoonLayer:IsXBLWellComeActing()
	return self.wellcomeActing_;
end

--[[
	小伴龙欢迎并介绍活动
]]--
function YuReMoonLayer:XBLWellCome()
	if self.wellcomeActing_ == false then
		self.wellcomeActing_ = true;
		self:guide(JsonScriptConfig.XBL_WELLCOME ,function() 
			self.wellcomeActing_ = false;
		end);
	end
end

--[[
	显示装饰礼物界面
	参数:
	cb:              点击装饰按钮的回掉
]]--
function YuReMoonLayer:showDecorationView(cb)
	if self.btnDecoration_ ~= nil then 
		self.cbOfClickDecorationBtn_ = cb;
		self.btnDecoration_:setVisible(true);
	end
end

--[[
	关闭礼物显示界面
]]--
function YuReMoonLayer:closeDecorationView()
	if self.btnDecoration_ ~= nil then 
		self.cbOfClickDecorationBtn_ = nil;
		self.btnDecoration_:setVisible(false);
	end
end

function YuReMoonLayer:xblGuide()
	--self.xblGuiding_ = true;
	self:guide(JsonScriptConfig.CLICK_XBL,function() end);
end

--[[
	VIP牛逼闪闪星星灯 开关 [按一下开 按一下关 有不有意思？]
]]--
function YuReMoonLayer:switchVIPLamp()
	if self:VIPLampActive() then 
		self:OffVIPLamp();
	else 
		self:OnVIPLamp();
	end
end

--[[
	打开牛逼闪闪VIP灯
]]--
function YuReMoonLayer:OnVIPLamp()
	ArmatureUtil.PlayAndStay(self.armVIPLamp_,2,1);
	self.VIPLampActive_ = true;
end

--[[
	关闭牛逼闪闪VIP灯
]]--
function YuReMoonLayer:OffVIPLamp()
	ArmatureUtil.PlayAndStay(self.armVIPLamp_,0,0);
	self.VIPLampActive_ = false;
end

--[[
	牛逼闪闪VIP灯状态
]]--
function YuReMoonLayer:VIPLampActive()
	return self.VIPLampActive_;
end

--[[
	播放json
	参数:
	actionName: 要播放的动作名
	cb:         动作播放完成的回掉
	返回
	tag:        当前动作的唯一tag
]]--
function YuReMoonLayer:playJsonAction(actionName,cb)--PlayActionFronzenZ
	self.jsonScriptSingleTrackTag_ = JsonScriptUtil.PlayAction(
		self,
		actionName,
		function(eventName) 
			if eventName == "Complie" then 
				if cb ~= nil then 
					cb();
					self.cbOfJsonScriptSingleTrack_ = nil;
					self.jsonScriptSingleTrackTag_ = -1;
				end
			end
		end
    );
	if self.jsonScriptSingleTrackTag_ == -1 then 
		print("Error: actionName:" .. actionName .. "play fail please check json config");
		print(debug.traceback(  ));
		if cb ~= nil then 
			cb();
		end
	end

	self.cbOfJsonScriptSingleTrack_ = cb;
end

--[[
	停止当前播放的json
	参数:
	isCallBack: true:[正常调用引导完成回掉] false:[不调用引导完成回掉]
]]--
function YuReMoonLayer:stopJsonAction(isCallBack)
	if self.jsonScriptSingleTrackTag_ ~= -1 then 
		JsonScriptUtil.ProcessActionToEndByTag(self.jsonScriptSingleTrackTag_ );
		JsonScriptUtil.StopActionByTag(self.jsonScriptSingleTrackTag_ );

		if self.cbOfJsonScriptSingleTrack_  ~= nil then 
			if isCallBack then
				self.cbOfJsonScriptSingleTrack_ ();
			end
		end
		self.jsonScriptSingleTrackTag_  = -1;
		self.cbOfJsonScriptSingleTrack_ = nil;
	end
end


--[[
	单一json 运行，一个时间最多只运行一个json
	参数:
	actionName: 要播放的动作名
	cb:         动作播放完成的回掉
	返回
	tag:        当前动作的唯一tag
]]--
function YuReMoonLayer:playJsonSingleTrack(actionName,cb)
	self:playJsonAction(actionName,cb);
end

--[[
	隐藏某个activityItem
	参数:
	index:item的索引
]]--
function YuReMoonLayer:hideActivityItemByIndex ( index )
	if 1 <= index and index <= #self.listOfActivityItems_ then 
		self.listOfActivityItems_[index]:Hide();
	end
end

--[[
	终止场景中一切动作恢复初始状态
]]--
function YuReMoonLayer:stopGuide()
	self:stopJsonAction(false);
	self:GetParentNode():UpdatePrepareLayer();
end


--[[
	播放引导 - [仅仅播放json]
	参数:
	jsonName: 引导json的名称
	cb:       引导完成的回掉
]]--
function YuReMoonLayer:guide(jsonName,cb)
	print("mark5"..jsonName);
	self:stopGuide();
	self:playJsonAction(jsonName,cb);
end

--[[
	播放引导 - [播放json,而且隐藏对饮index的activityItem]
	参数:
	jsonName: 引导json的名称
	cb:       引导完成的回掉
]]--
function YuReMoonLayer:guideAndHideActivityItem(index,jsonName,cb)
	self:stopGuide();
	self:playJsonAction(jsonName,cb);
	self:hideActivityItemByIndex(index);
end

--[[
	展示activityItem 并准备装饰
	参数:
	index: item index
	cb: 展示完成时的回掉 daoju0
]]--
function YuReMoonLayer:showDecorationActivityItemByIndex(index)
	self:guideAndHideActivityItem(index,JsonScriptConfig.SHOW_GIFTS_JSON[index],function()
		self:showDecorationView(function() 
			self:decorationActivityItemByIndex(index,function() 
				self.btnShowDecorationBlock_:setVisible(false);
				self:GetParentNode():UpdatePrepareLayer();
			end);
		end);
	end);

	self.btnShowDecorationBlock_:setVisible(true);
end

--[[
	装饰activityitem
	参数:
	index:要装饰的item index
	cb: 装饰完成的回掉
]]--
function YuReMoonLayer:decorationActivityItemByIndex(index ,cb)
	self:guideAndHideActivityItem(index,JsonScriptConfig.DECORATION_GIFTS_JSON[index],function()
		if cb ~= nil then 
			cb();
		end
	end);
end




-- ----- 各种更新方法 -----

--[[
    更新用户数据
]]--
function YuReMoonLayer:Update(d)
	self.data = d;
	self:updateActivityCountDown(self.data);
	self:updateActivityItems(self.data);
	self:updateActivityUnLockPath(self.data);
	self:updateVIP(self.data);

	self:closeDecorationView();
end

--[[
	更新活动项目按钮
]]--
function YuReMoonLayer:updateActivityItems(d)
	-- 更新项目按钮
	local listOfActivityItemsData = d.listOfItems;
	for i = 1 , #listOfActivityItemsData,1 do 
		local itemData = listOfActivityItemsData[i];
		local item = self.listOfActivityItems_[i];
		item:Update(itemData);
	end
end

--[[
	更新活动解锁路径
]]--
function YuReMoonLayer:updateActivityUnLockPath(d)
	local dayIndex = d.dayIndex;
	if dayIndex < 1 then 
		dayIndex = 1;
	end
	if dayIndex >= self.numOfActiviyNum_ then 
		dayIndex = self.numOfActiviyNum_ ;
	end
	print("dayIndex1:"..dayIndex);
	dayIndex = dayIndex - 1;
	print("dayIndex2:"..dayIndex);

	dayIndex = dayIndex * 2;
	local playIndex = math.max(dayIndex-1 ,0);
	local stayIndex = math.min(dayIndex   ,12) ;
	print("playIndex:"..playIndex);
	print("stayIndex:"..stayIndex);

	if self.armActivityItemUnlockPath_ ~= nil then 
		ArmatureUtil.PlayAndStay(self.armActivityItemUnlockPath_,playIndex,stayIndex);
	end
end

--[[
	更新VIP相关装饰
]]--
function YuReMoonLayer:updateVIP(d)
	self.armVIPLamp_:setVisible(d.VIP);
end

--[[
	更新倒计时
]]--
function YuReMoonLayer:updateActivityCountDown(d)
	print("d.dayIndex:"..d.dayIndex);
	local countDown = self.numOfActiviyNum_ - d.dayIndex + 1;

	self.lbDayCountDown_:setString(""..countDown);

	if countDown == 0 then 
		self.lbActivityDay_:setVisible(false);
	end
end

-- ----- 对外接口 ------
--[[
	用户获得礼物
	参数:
	i:礼物的索引
]]--
function YuReMoonLayer:OnUserGetGiftByIndex(i)
	if self:IsXBLWellComeActing() == false then 

		if 1 <= i and i <= #JsonScriptConfig.GET_GIFTS_JSON then 

			self:guideAndHideActivityItem(i,JsonScriptConfig.GET_GIFTS_JSON[i],function()
				-- todo triggle decoration
				self:showDecorationActivityItemByIndex(i);
			end);
			self:GetParentNode():SetUserSignInInfoByDay(i,true);

			
		end
	end

	self:closeFingerTip();
	
	self:NoOperationCount();
end

--[[
	用户解锁礼物失败
	参数:
	i:礼物索引
]]--
function YuReMoonLayer:OnUserGetGiftFailByIndex(i)
	if self:IsXBLWellComeActing() == false then 
		self:guide(JsonScriptConfig.XBL_NEXT_DAY_CAN_GET,function() end);
	end

	self:closeFingerTip();

	self:NoOperationCount();
end

--[[
	用户玩耍礼物
	参数:
	i:礼物的索引
]]--
function YuReMoonLayer:OnUserPlayGiftByIndex(i)
	if self:IsXBLWellComeActing() == false then 
		if 1 <= i and i <= #JsonScriptConfig.GET_GIFTS_JSON then 
			self:guideAndHideActivityItem(i,JsonScriptConfig.PLAY_GIFTS_JSON[i],function()
				self:GetParentNode():UpdatePrepareLayer();
			end);
		end
	end

	self:closeFingerTip();

	self:NoOperationCount();
end

--[[
	百度统计事件
	参数:
	eventName:事件名称
]]--
function YuReMoonLayer:CallBaiduRecord(eventName)
	self:GetParentNode():CallBaiduRecord(eventName);
end



return YuReMoonLayer
