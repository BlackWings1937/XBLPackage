local istest = true;
local ShareLayer = requirePack("appscripts.ShareLayer", false);  -- 用来读取数据

requirePack("scripts.FrameWork.Global.GlobalFunctions");
g_tConfigTable.RootFolderPath = "scripts.";
requirePack("scripts.FrameWork.AnimationEngineLua.AnimationEngine");

local BAG_ID_1 = 1
local BAG_ID_2 = 2
local BAG_ID_3 = 3
local LAYOUT_WIDTH = 768
local LAYOUT_HEIGHT = 1024

local MainLayer = class("MainLayer", function()
    local layer  = cc.Layer:create()
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

-- 重写New方法
MainLayer.new = function(...)
    local instance
    if MainLayer.__create then
        instance = MainLayer.__create(...)
    else
        instance = { }
    end

    for k, v in pairs(MainLayer) do instance[k] = v end
    instance.class = MainLayer
    instance:ctor(...);
    return instance
end

function MainLayer:onEnter() 
    
end

function MainLayer:onExit()
	AudioEngine.stopMusic(true)--release资源就不会在win上停止后还播放
	g_tConfigTable.AnimationEngine:GetInstance():Dispose();
	SoundUtil:getInstance():soundListenDetectStop();
	SoundUtil:getInstance():setUploadAudioEnable(false)--恢复默认
end

function MainLayer:ctor(...)
	local tSdPath = ...
    self:init()
end

function MainLayer:init()
	self.m_sSdPath = nil
	self.m_winSize = nil
	self.tag_ = -1;

	self.m_finger = nil
	self.m_select_1 = nil
	self.m_select_2 = nil
	self.m_select_3 = nil
	self.m_select_4 = nil
	self.m_select_5 = nil
	self.m_select_index = 1;
	self.m_gift_sprite = nil
	self.m_shareLayer = nil
	self.m_shareFinger = nil
	self.m_shareBtn = nil;
	self.m_liwuhe = nil;
	self.m_btn_next = nil
	self.m_curStep = 0;
	self.m_saveState = 0;
	self.m_gui_default_btn_list = {}
	self.m_gui_select_sprite_list = {}
	self.m_gui_granule_sprite_list = {}
	g_tConfigTable.AnimationEngine:GetInstance()
	XueTangDataAdapter:getInstance():setWillPlayGame(false)
	SoundUtil:getInstance():setUploadAudioEnable(true)--允许上传
end

function MainLayer:createUI(sSdPath)
	
	self.m_sSdPath = sSdPath;
	self.m_winSize = cc.Director:getInstance():getWinSize()
	self.m_bagId = XiaLingYingData:getInstance():getTargetBagId()

	AudioEngine.playMusic(self.m_sSdPath.."sounds/191128wf.mp3", true) 
		
	self.ScaleMultiple = ArmatureDataDeal:sharedDataDeal():getUIItemScale_1024_1920() * 0.8
    if ArmatureDataDeal:sharedDataDeal():getIsHdScreen() == false then
		self.ScaleMultiple = self.ScaleMultiple * 2
	end

	local wx = (self.m_winSize.width-768)*0.5
	local wy = (self.m_winSize.height-1024)*0.5
	local colorLayer = cc.Layer:create()
	colorLayer:setPosition(cc.p(0,0))
	self:addChild(colorLayer,9999999)
	local function touchLayerCallFunc(eventType, x, y)
		if eventType == "began" then
        	local tx = TouchArmature:create("xy_efface_touch", TOUCHARMATURE_NORMAL)
		    tx:setPosition(cc.p(x-wx,y-wy))
		    tx:setRectAndBeginPlay()
		    colorLayer:addChild(tx)
		    tx:playByIndex(0, LOOP_NO)
		    tx:setLuaCallBack( function (eType)
	        	if eType == TouchArmLuaStatus_AnimEnd then
	                tx:removeFromParent()
	                tx = nil
	        	end
	    	end)
            return false
        end
    end
    colorLayer:registerScriptTouchHandler(touchLayerCallFunc, false, 0, true)
	colorLayer:setTouchEnabled(true)

	local basePath = self.m_sSdPath.."image/"
	local rightPosX = (LAYOUT_WIDTH+self.m_winSize.width)*0.5 - 10 - self.ScaleMultiple * 75
	local rightPosY = (LAYOUT_HEIGHT+self.m_winSize.height)*0.5 - 20 - self.ScaleMultiple * 75
	
	local bgSprite = cc.Sprite:create(basePath.."191128wf2.jpg")
	bgSprite:setPosition(cc.p(LAYOUT_WIDTH*0.5,LAYOUT_HEIGHT*0.5))
	self:addChild(bgSprite);

	self.stageNode = cc.Node:create();
    self.stageNode:setPosition(cc.p(384,512))
    self.stageNode:setContentSize(self:getContentSize());
	self:addChild(self.stageNode)
	
	self:playAnim(basePath);
	Utils:GetInstance():baiduTongji("xialingying","wanfa_op_"..self.m_bagId)--tong ji
end

function MainLayer:createList(basePath)
	local gui_progress_bg_sprite = cc.Sprite:create(basePath.."gui_progress_bg.png")
	gui_progress_bg_sprite:setScale(self.ScaleMultiple);
	gui_progress_bg_sprite:setPosition(cc.p(LAYOUT_WIDTH*0.5,(self.m_winSize.height+LAYOUT_HEIGHT)*0.5-gui_progress_bg_sprite:getContentSize().height*0.5 - 20));
	self:addChild(gui_progress_bg_sprite,1000001);

	local py = 48
	local px = {70,195,320,444} 
	for k=1,4 do
		local gui_granule_bg_sprite = cc.Sprite:create(basePath.."gui_granule_bg.png")
		gui_granule_bg_sprite:setPosition(cc.p(px[k],py))
		gui_progress_bg_sprite:addChild(gui_granule_bg_sprite);

		local gui_granule_sprite = cc.Sprite:create(basePath.."gui_granule.png")
		gui_granule_sprite:setPosition(cc.p(px[k],py))
		gui_progress_bg_sprite:addChild(gui_granule_sprite);
		gui_granule_sprite:setVisible(false)
		table.insert(self.m_gui_granule_sprite_list,gui_granule_sprite)
	end

	local gui_zhuozi_img_sprite = cc.Sprite:create(basePath.."gui_zhuozi_img.png")
	gui_zhuozi_img_sprite:setScale(self.ScaleMultiple);
	gui_zhuozi_img_sprite:setPosition(cc.p(LAYOUT_WIDTH*0.5,350));
	self:addChild(gui_zhuozi_img_sprite,1000001);

	local gui_UI_bg_sprite = cc.Sprite:create(basePath.."gui_UI_bg.png")
	gui_UI_bg_sprite:setAnchorPoint(cc.p(0.5,0))
	gui_UI_bg_sprite:setScale(self.ScaleMultiple);
	gui_UI_bg_sprite:setPosition(cc.p(LAYOUT_WIDTH*0.5,0));
	self:addChild(gui_UI_bg_sprite,1000001);

	local scrollView = cc.ScrollView:create(cc.size(self.m_winSize.width,160));
    scrollView:setAnchorPoint(cc.p(0, 0));
    scrollView:setPosition(cc.p((LAYOUT_WIDTH-self.m_winSize.width)*0.5,100));
    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
	scrollView:setTouchEnabled(true)
	scrollView:setContentSize(cc.size(760,160));
    scrollView:setDelegate()
	self:addChild(scrollView,1000001)

	local gui_gift_list = {"gui_gift01.png","gui_gift02.png","gui_gift03.png","gui_gift04.png","gui_gift05.png","gui_gift06.png"}
	local playJson_list = {"ganenwf009","ganenwf013","ganenwf011","ganenwf010","ganenwf008","ganenwf012"}
	local tupian_list = {"191128wfA_e","191128wfA_a","191128wfA_b","191128wfA_c","191128wfA_f","191128wfA_d"}
	for k,v in pairs(gui_gift_list)do
		local item = self:createItem(basePath,gui_gift_list[k],playJson_list[k],tupian_list[k]);
		item:setPosition(cc.p(145*k-70,80))
		scrollView:addChild(item);

		local arr = {}
		table.insert(arr,cc.MoveTo:create(145*k/100,cc.p(-80,80)))
		table.insert(arr,cc.CallFunc:create(function() 
			local arr1 = {}
			table.insert(arr1,cc.CallFunc:create(function() 
				item:setPosition(cc.p(800,80))
			end))
			table.insert(arr1,cc.MoveTo:create(870/100,cc.p(-80,80)))
			item:runAction(cc.RepeatForever:create(cc.Sequence:create(arr1)))
		end))
		item:runAction(cc.Sequence:create(arr))
	end

	local finger = TouchArmature:create("point_all", TOUCHARMATURE_NORMAL);	
	finger:setScale(self.ScaleMultiple)
	finger:setPosition(cc.p(220,60));
	finger:playByIndex(1,LOOP_YES);
	scrollView:addChild(finger,10);
	self.m_finger = finger

	local liwuhe = TouchArmature:create("191128wf_liwuhe", TOUCHARMATURE_NORMAL);	
	liwuhe:setPosition(cc.p(376,480));
	liwuhe:playByIndex(0,LOOP_YES);
	liwuhe:ChangeOneSkin("he1", "191128wfD_x");
	liwuhe:ChangeOneSkin("he2", "191128wfD_x");
	liwuhe:ChangeOneSkin("liwu", "191128wfD_x");
	liwuhe:ChangeOneSkin("dai", "191128wfD_x");
	liwuhe:ChangeOneSkin("baoshi", "191128wfD_x");
	self:addChild(liwuhe,1000002);
	self.m_liwuhe = liwuhe;

	local gift_sprite = cc.Sprite:create(basePath.."gui_decorations_01.png");
	gift_sprite:setScale(self.ScaleMultiple)
	gift_sprite:setPosition(cc.p(LAYOUT_WIDTH*0.5,450));
	gift_sprite:setVisible(false)
	self:addChild(gift_sprite,1000002)
	self.m_gift_sprite = gift_sprite

	local next_path = basePath.."gui_next.png"
	local btn_next = ccui.Button:create()
    btn_next:setTouchEnabled(true)
    btn_next:loadTextures(next_path,next_path,next_path)
    btn_next:setAnchorPoint(cc.p(0,0.5))
	btn_next:setScale(self.ScaleMultiple) 
    btn_next:setPosition(cc.p(LAYOUT_WIDTH*0.5+self.m_winSize.width*0.5-100,370))   
    btn_next:setPressedActionEnabled(true)     
	btn_next:setZoomScale(-0.12)
	btn_next:setVisible(false)
	self.m_btn_next = btn_next;
    self:addChild(btn_next,1000002)
	btn_next:addClickEventListener(function(sender)
		local startJson = nil
		local gui_gift_list = nil;
		local playJson_list = nil;
		local tupiao_list = nil;
		local hezibg_list = nil;
		if(self.m_select_index == 1) then
			startJson = "ganenwf014x"
			gui_gift_list = {"gui_gift_box_01.png","gui_gift_box_02.png","gui_gift_box_03.png"}
			playJson_list = {"ganenwf016","ganenwf017","ganenwf015"}
			tupiao_list = {"191128wfB_a1","191128wfB_b1","191128wfB_c1"}
			hezibg_list = {"191128wfB_a2","191128wfB_b2","191128wfB_c2"}
		elseif(self.m_select_index == 2) then	
			startJson = "ganenwf018x"
			gui_gift_list = {"gui_ribbon_01.png","gui_ribbon_02.png","gui_ribbon_03.png"}
			playJson_list = {"ganenwf019","ganenwf019a","ganenwf020"}
			tupiao_list =  {"191128wfC_amov1","191128wfC_bmov1","191128wfC_cmov1"}
			hezibg_list =  {"191128wfC_amov0","191128wfC_bmov0","191128wfC_cmov0"}
		elseif(self.m_select_index == 3) then
			startJson = "ganenwf021x"
			gui_gift_list = {"gui_decorations_01.png","gui_decorations_02.png","gui_decorations_03.png"}
			playJson_list = {"ganenwf022","ganenwf023","ganenwf024"}
			tupiao_list = {"191128wfD_amov1","191128wfD_bmov1","191128wfD_cmov1"}
			hezibg_list = {"191128wfD_amov0","191128wfD_bmov0","191128wfD_cmov0"}
		end
		self:selectStep(basePath,scrollView,startJson,gui_gift_list,playJson_list,tupiao_list,hezibg_list)

		Utils:GetInstance():baiduTongji("xialingying","wanfa_nx_"..self.m_bagId.."_"..self.m_select_index)--tong ji

		btn_next:stopAllActions()
		btn_next:setVisible(false)
		self.m_select_index = self.m_select_index + 1

		if(self.m_select_index == 5) then
			self.m_liwuhe:setVisible(false)
			scrollView:setVisible(false)
			gui_UI_bg_sprite:setVisible(false)
			gui_progress_bg_sprite:setVisible(false)
			gui_zhuozi_img_sprite:setVisible(false)
			self:isSuccess(true)
			self:playEndOver(basePath);
		end
	end)
end

function MainLayer:createItem(basePath,itemImg,playJson,tupian,hezibg)
	local itemImg_sprite = nil
	local gui_select_sprite = nil
	local gui_default_path = basePath.."gui_default.png"
	local btn_gui_default = ccui.Button:create()
    btn_gui_default:setTouchEnabled(true)
    btn_gui_default:loadTextures(gui_default_path,gui_default_path,gui_default_path)
	btn_gui_default:setScale(self.ScaleMultiple) 
	btn_gui_default:setPressedActionEnabled(true)    
	btn_gui_default:setSwallowTouches(false) 
    btn_gui_default:setZoomScale(-0.12)
	btn_gui_default:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			if(itemImg_sprite) then
				itemImg_sprite:stopAllActions()
				itemImg_sprite:runAction(cc.ScaleTo:create(0.05,0.9))
			end
			if(gui_select_sprite) then
				gui_select_sprite:stopAllActions()
				gui_select_sprite:runAction(cc.ScaleTo:create(0.05,0.9))
			end
		elseif eventType == ccui.TouchEventType.canceled then
			if(itemImg_sprite) then
				itemImg_sprite:stopAllActions()
				itemImg_sprite:runAction(cc.ScaleTo:create(0.05,1.0))
			end
			if(gui_select_sprite) then
				gui_select_sprite:stopAllActions()
				gui_select_sprite:runAction(cc.ScaleTo:create(0.05,1.0))
			end
		elseif eventType == ccui.TouchEventType.ended then
			Utils:GetInstance():baiduTongji("xialingying","wanfa_sz_"..self.m_bagId.."_"..self.m_select_index)--tong ji 

			if(itemImg_sprite) then
				itemImg_sprite:stopAllActions()
				itemImg_sprite:runAction(cc.ScaleTo:create(0.05,1.0))
			end
			if(gui_select_sprite) then
				gui_select_sprite:stopAllActions()
				gui_select_sprite:runAction(cc.ScaleTo:create(0.05,1.0))
			end

			if(math.abs(sender:getTouchEndPosition().x-sender:getTouchBeganPosition().x) > 20 or 
			   math.abs(sender:getTouchEndPosition().y-sender:getTouchBeganPosition().y) > 20) then
				return
			end

			for k,v in pairs(self.m_gui_select_sprite_list)do
				if v:getName() == itemImg then
					v:setVisible(true)
				else
					v:setVisible(false)
				end
			end

			local arr = {}
			table.insert(arr,cc.DelayTime:create(5))
			table.insert(arr,cc.CallFunc:create(function() 
				local px = 10
				local arr1 = {}
				table.insert(arr1,cc.MoveBy:create(0.1,cc.p(px,0)))
				table.insert(arr1,cc.MoveBy:create(0.2,cc.p(-px*2,0)))
				table.insert(arr1,cc.MoveBy:create(0.2,cc.p(px*2,0)))
				table.insert(arr1,cc.MoveBy:create(0.1,cc.p(-px,0)))
				table.insert(arr1,cc.DelayTime:create(1))
				self.m_btn_next:runAction(cc.RepeatForever:create(cc.Sequence:create(arr1)))
			end))
			self.m_btn_next:stopAllActions()
			self.m_btn_next:runAction(cc.Sequence:create(arr))
			self.m_btn_next:setVisible(true)
			self.m_finger:setVisible(false)
			self.m_gui_granule_sprite_list[self.m_select_index]:setVisible(true)

			self:playActionAmin(playJson);

			local addY = 450
			if self.m_select_index == 3 or 
			   self.m_select_index == 4 then
				addY = addY + 50
			end

			local arr = {}
			table.insert(arr,cc.MoveTo:create(0.2,ccp(LAYOUT_WIDTH*0.5,addY)))
			table.insert(arr,cc.CallFunc:create(function()
				if(self.m_select_index == 1) then
					self.m_select_1 = tupian
					self.m_liwuhe:ChangeOneSkin("liwu", tupian);
					self.m_liwuhe:playByIndex(2, LOOP_NO);
					self.m_liwuhe:setLuaCallBack(function(eType, pTouchArm, sEvent)
						if eType == TouchArmLuaStatus_AnimPerEnd then
							self.m_liwuhe:playByIndex(1, LOOP_YES);
						end
					end);
				elseif self.m_select_index == 2 then
					self.m_select_2 = tupian
					self.m_select_3 = hezibg
					self.m_liwuhe:ChangeOneSkin("he1", tupian);
					self.m_liwuhe:ChangeOneSkin("he2", hezibg);
					self.m_liwuhe:playByIndex(3, LOOP_NO);
					self.m_liwuhe:setLuaCallBack(function(eType, pTouchArm, sEvent)
						if eType == TouchArmLuaStatus_AnimPerEnd then
							self.m_liwuhe:playByIndex(0, LOOP_YES);
						end
					end);
				elseif self.m_select_index == 3 then
					self.m_select_4 = hezibg
					self.m_liwuhe:changeOneSkinToArmature("dai",tupian,"0");
					self.m_liwuhe:playByIndex(4, LOOP_NO);
					self.m_liwuhe:setLuaCallBack(function(eType, pTouchArm, sEvent)
						if eType == TouchArmLuaStatus_AnimPerEnd then
							self.m_liwuhe:changeOneSkinToArmature("dai",hezibg, "0");
							self.m_liwuhe:playByIndex(0, LOOP_YES);
						end
					end);
				elseif self.m_select_index == 4 then
					self.m_select_5 = hezibg
					self.m_liwuhe:changeOneSkinToArmature("baoshi",tupian,"0");
					self.m_liwuhe:playByIndex(5, LOOP_NO);
					self.m_liwuhe:setLuaCallBack(function(eType, pTouchArm, sEvent)
						if eType == TouchArmLuaStatus_AnimPerEnd then
							self.m_liwuhe:changeOneSkinToArmature("baoshi",hezibg, "0");
							self.m_liwuhe:playByIndex(0, LOOP_YES);
						end
					end);
				end
				self.m_gift_sprite:setVisible(false)
			end))

			local size = btn_gui_default:getContentSize();
			local point1 = btn_gui_default:convertToWorldSpace(cc.p(0,0));
			local point2 = self:convertToNodeSpace(point1);
			self.m_gift_sprite:setVisible(true)
			self.m_gift_sprite:stopAllActions()
			self.m_gift_sprite:setTexture(basePath..itemImg);
			self.m_gift_sprite:setPosition(cc.p(point2.x+size.width*0.5*self.ScaleMultiple,point2.y+size.height*0.5*self.ScaleMultiple))
			self.m_gift_sprite:runAction(cc.Sequence:create(arr))

			SimpleAudioEngine:getInstance():playEffect(UISOUND_A_BTN)
		end
	end)
	table.insert(self.m_gui_default_btn_list,btn_gui_default)

	local size = btn_gui_default:getContentSize();
	gui_select_sprite = cc.Sprite:create(basePath.."gui_select01.png");
	gui_select_sprite:setPosition(cc.p(size.width*0.5,size.height*0.5))
	gui_select_sprite:setName(itemImg);
	gui_select_sprite:setVisible(false)
	btn_gui_default:addChild(gui_select_sprite)
	table.insert(self.m_gui_select_sprite_list,gui_select_sprite)

	itemImg_sprite = cc.Sprite:create(basePath..itemImg);
	itemImg_sprite:setPosition(cc.p(size.width*0.5,size.height*0.5))
	btn_gui_default:addChild(itemImg_sprite)

	return btn_gui_default
end


--显示下面需要捕鱼的
function MainLayer:isSuccess(suc)
    local nUid = UInfoUtil:getInstance():getCurUidStr();
    local activityId = XiaLingYingData:getInstance():getActivityId();
    local subActivityId = XiaLingYingData:getInstance():getSubActivityId();
    local savePath = GET_REAL_PATH_ONLY("",PathGetRet_ONLY_SD) .. "xialingyingTemp/userInfo_"..nUid.."_"..activityId.."_"..subActivityId..".json";
    
    local cjson = require("cjson")
    local JsonData = requirePack("baseScripts.homeUI.JsonData", false);  -- 用来读取数据
    local jsonData = JsonData.new() --获取数据
    local userInfo = jsonData:ReadJsonFileContentTable(savePath) or {};
    local bagId = XiaLingYingData:getInstance():getTargetBagId()
    if(userInfo["success"..bagId] == nil) then
        if (suc) then
            userInfo["success"..bagId] = 1
        else
            userInfo["success"..bagId] = 0
        end
    else
        if (suc) then
            userInfo["success"..bagId] = 1
        end
    end
    jsonData:WriteFilePath(savePath,cjson.encode(userInfo));
end

function MainLayer:playAnim(basePath)
	local bgJson = nil
	local playJson = nil
	local curBagId = tonumber(self.m_bagId)
	if(curBagId == BAG_ID_1) then
		bgJson = "op1bg"
		playJson = "ganenwf001"
	elseif(curBagId == BAG_ID_2) then
		bgJson = "op2bg"
		playJson = "ganenwf003"
	elseif(curBagId == BAG_ID_3) then
		bgJson = "op3bg"
		playJson = "ganenwf005"
	end
	
	self:playBaseAmin(bgJson,function()
		if(istest) then
			self:playActionAmin(playJson,function()
				self:createFinger(basePath);
			end)
		else 
			g_tConfigTable.AnimationEngine:GetInstance():RemoveEngineCreatedObjOnNode(self.stageNode)
			self:createList(basePath);
			self:playActionAmin("ganenwf007x")
		end
	end);
end

function MainLayer:createFinger(basePath)
	local finger = TouchArmature:create("point_all", TOUCHARMATURE_NORMAL);	
	finger:setScale(self.ScaleMultiple*1.5)
	finger:setPosition(cc.p(470,420));
	finger:playByIndex(1,LOOP_YES);
	self:addChild(finger,100001);

	local function callBack()
		g_tConfigTable.AnimationEngine:GetInstance():RemoveEngineCreatedObjOnNode(self.stageNode)
		self:createList(basePath);
		self:playActionAmin("ganenwf007x")
	end

	local imgPath = THEME_IMG("transparent.png") --g_tConfigTable.sTaskpath.."image/temp.png" ----
	local enterBtn = ccui.Button:create(imgPath,imgPath);
	enterBtn:setScale(23)
	enterBtn:setAnchorPoint(cc.p(0.5,0.5));
	enterBtn:setPosition(cc.p(470,420));
	enterBtn:setPressedActionEnabled(true)  
	enterBtn:setSwallowTouches(false);   
	self:addChild(enterBtn,100001);
	enterBtn:addClickEventListener(function()		
		finger:removeFromParent()
		enterBtn:removeFromParent()
		self:stopAllActions()
		self:showOPOver(callBack)
	end)

	local arr = {}
	table.insert(arr,cc.DelayTime:create(10))
	table.insert(arr,cc.CallFunc:create(function()
		finger:removeFromParent()
		enterBtn:removeFromParent()
		self:showOPOver(callBack)
	end))
	self:runAction(cc.Sequence:create(arr))
end

function MainLayer:playEndOver(basePath)
	local curBagId = tonumber(self.m_bagId)
	local playJson = nil;
	local endbg = nil
	if(curBagId == BAG_ID_1) then
		endbg = "end1bg"
		playJson = "ganenwf025"
	elseif(curBagId == BAG_ID_2) then
		endbg = "end2bg"
		playJson = "ganenwf029"
	elseif(curBagId == BAG_ID_3) then
		endbg = "end3bg"
		playJson = "ganenwf033"
	end
	
	self:showOPOver(function() 
		self:createShare(basePath)
		self:playBaseAmin(endbg,function()
			local liwuheArm = self.stageNode:getChildByName("AESOP*npc_liwu");
			if(liwuheArm) then
				if(self.m_select_1) then
					liwuheArm:ChangeOneSkin("liwu", self.m_select_1);
				end
				if(self.m_select_2) then
					liwuheArm:ChangeOneSkin("he1",self.m_select_2);
				end
				if(self.m_select_3) then
					liwuheArm:ChangeOneSkin("he2",self.m_select_3);
				end
				if(self.m_select_4) then
					liwuheArm:changeOneSkinToArmature("dai",self.m_select_4,"0");
				end
				if(self.m_select_5) then
					liwuheArm:changeOneSkinToArmature("baoshi",self.m_select_5,"0");
				end
			end
			
			self.m_curStep = 1;
			self:playActionAmin(playJson,function()
				if(curBagId == BAG_ID_1) then
					self:playRecord()
				elseif(curBagId == BAG_ID_2) then
					self:createNext("ganenwf029a",true)
				elseif(curBagId == BAG_ID_3) then
					self:createNext("ganenwf033a",true)
				end
			end)
		end)
	end)
end

function MainLayer:createShare(basePath)
	if(tonumber(self.m_bagId) ~= BAG_ID_1) then
		return;
	end

	local function closeCallBack(isSave)
		if(isSave) then
			self.m_saveState = 1;
		end

		if(self.m_shareBtn) then
			self.m_shareBtn:setEnabled(true)
		end

		if(self.m_shareLayer) then
			self.m_shareLayer:removeFromParent()
			self.m_shareLayer = nil
		end

		if(self.m_curStep == 1) then
			self:playActionAmin("ganenwf025",function()
				self:playRecord()
			end)
		elseif(self.m_curStep == 2) then
			self:playRecord()
		elseif(self.m_curStep == 3) then
			self:playActionAmin("ganenwf027",function() 
				self.m_curStep = 4;
				self:createNext("ganenwf028",false)
			end)
		elseif(self.m_curStep == 4) then
		elseif(self.m_curStep == 5) then
			self:waitExitScene()
		end
	end

	local imgPath = basePath.."gui_share.png"
	local shareBtn = ccui.Button:create(imgPath,imgPath);
	shareBtn:setScale(self.ScaleMultiple)
	shareBtn:setAnchorPoint(cc.p(0.5,0.5));
	shareBtn:setPosition(cc.p(LAYOUT_WIDTH*0.5+self.m_winSize.width*0.5-60,145));
	shareBtn:setPressedActionEnabled(true)  
	shareBtn:setSwallowTouches(false);   
	self:addChild(shareBtn,100002);
	shareBtn:addClickEventListener(function()
		if(self.m_shareLayer ~= nil) then
			return;
		end
		
		local shareLayer = ShareLayer.new();
		shareLayer:setContentSize(self:getContentSize())
		shareLayer:createUI(self.m_sSdPath,self.m_select_1,self.m_select_2,self.m_select_3,self.m_select_4,self.m_select_5,self.m_saveState,closeCallBack);   
		shareLayer:setPosition(cc.p(0,20))
		self:addChild(shareLayer,100004);
		self.m_shareLayer = shareLayer;
		self.m_shareBtn:setEnabled(false)
		self.m_shareFinger:setVisible(false)
		self:playActionAmin("ganenwf028a")
		
		local scene = cc.Director:getInstance():getRunningScene()
		SoundUtil:getInstance():soundListenDetectStop();
		Utils:GetInstance():removeListenTips(scene)
		Utils:GetInstance():baiduTongji("xialingying","wanfa_fx")--tong ji
	end)
	self.m_shareBtn = shareBtn;

	local shareFinger = TouchArmature:create("191128wf_antx", TOUCHARMATURE_NORMAL);	
	shareFinger:setScale(0.4)
	shareFinger:setPosition(cc.p(100,120));
	shareFinger:playByIndex(0,LOOP_YES);
	shareFinger:setVisible(false)
	shareBtn:addChild(shareFinger);
	self.m_shareFinger = shareFinger
end

function MainLayer:closeShare()
	if(self.m_shareLayer) then
		self.m_shareLayer:removeFromParent()
		self.m_shareLayer = nil
	end
end


function MainLayer:playRecord()
	local scene = cc.Director:getInstance():getRunningScene()
	local function recordIngCallBack(ntype)
		self:playActionAmin("ganenwf027",function() 
			self.m_curStep = 4;
			self:createNext("ganenwf028",false)
		end)
		SoundUtil:getInstance():soundListenDetectStop();
		Utils:GetInstance():removeListenTips(scene)
		self.m_curStep = 3;
	end
	Utils:GetInstance():addListenTips(CCP(0,0), scene)
	SoundUtil:getInstance():soundListenStartLua(1,1,false, recordIngCallBack);
	self.m_curStep = 2;
end

function MainLayer:createNext(playJson,isExit)
	local clickFinger = TouchArmature:create("point_all", TOUCHARMATURE_NORMAL);	
	clickFinger:setScale(self.ScaleMultiple*1.5)
	clickFinger:setPosition(cc.p(LAYOUT_WIDTH*0.5-10,LAYOUT_HEIGHT*0.5 + 70));
	clickFinger:playByIndex(1,LOOP_YES);
	self:addChild(clickFinger,100002);
	
	local itemPath = THEME_IMG("transparent.png")--g_tConfigTable.sTaskpath.."image/temp.png" --
	local clickBtn = ccui.Button:create(itemPath,itemPath);
	clickBtn:setScale(20)
	clickBtn:setAnchorPoint(cc.p(0.5,0.5));
	clickBtn:setPosition(cc.p(LAYOUT_WIDTH*0.5-10,LAYOUT_HEIGHT*0.5 + 70));
	clickBtn:setPressedActionEnabled(true)  
	clickBtn:setSwallowTouches(false);   
	self:addChild(clickBtn,100001);
	clickBtn:addClickEventListener(function()
		if(self.m_shareLayer == nil) then
			self.m_curStep = 5;
			clickBtn:removeFromParent()
			clickFinger:removeFromParent()
			
			self:playActionAmin(playJson,function()		
				if(isExit) then
					self.parent:exitScene()
				else
					self:waitExitScene()
				end
			end)
		end
	end)
end

function MainLayer:waitExitScene()
	if(self.m_shareFinger ~= nil) then
		self.m_shareFinger:setVisible(true)
	end
	self.m_curStep = 6;
	self:playActionAmin("ganenwf028a")

	local arr = {}
	table.insert(arr,cc.DelayTime:create(30))
	table.insert(arr,cc.CallFunc:create(function() 
		self.parent:exitScene()
	end))
	self:stopAllActions()
	self:runAction(cc.Sequence:create(arr))
end

--显示转场
function MainLayer:showOPOver(callBack)
    local changeSceneArm = TouchArmature:create(("home_ZC"), TOUCHARMATURE_NORMAL)
    changeSceneArm:setAnchorPoint( cc.p(0.5,0.5)) --动画的的锚点无意义
    changeSceneArm:setPosition(cc.p( cc.Director:getInstance():getWinSize().width/2, cc.Director:getInstance():getWinSize().height/2 ))--位置
    cc.Director:getInstance():getRunningScene():addChild(changeSceneArm , Max_INT())  --层级最高 
    changeSceneArm:playByIndex(0, LOOP_NO)
    changeSceneArm:setLuaCallBack(function ( eType, pTouchArm, sEvent )
        if eType == TouchArmLuaStatus_AnimEnd then  
            changeSceneArm:removeFromParent()
			changeSceneArm = nil
			
			if(callBack) then
				callBack()
			end
        end     
    end)
end

--第一步
function MainLayer:selectStep(basePath,scrollView,startJson,gui_gift_list,playJson_list,tupiao_list,hezibg_list)
	if(gui_gift_list == nil) then
		return;
	end

	for k=#self.m_gui_default_btn_list,1,-1 do
		self.m_gui_default_btn_list[k]:removeFromParent()
		table.remove(self.m_gui_default_btn_list,k)
	end

	self.m_gui_default_btn_list = {}
	self.m_gui_select_sprite_list = {}
	scrollView:setContentOffset(cc.p(0,0),false)
	scrollView:setContentSize(cc.size(435,160));
	scrollView:setTouchEnabled(false)
	scrollView:setPositionX((LAYOUT_WIDTH-435)*0.5)

	for k,v in pairs(gui_gift_list)do
		local item = self:createItem(basePath,gui_gift_list[k],playJson_list[k],tupiao_list[k],hezibg_list[k]);
		item:setPosition(cc.p(145*k-70,80))
		scrollView:addChild(item);
	end

	if(self.m_finger) then
		self.m_finger:playByIndex(1,LOOP_YES);
		self.m_finger:setVisible(true)
	end

	if(self.m_gui_select_sprite_list[2]) then
		self.m_gui_select_sprite_list[2]:setVisible(true)
	end

	self:playActionAmin(startJson)
end

function MainLayer:playBaseAmin(jsonFile,callBack)
	if(jsonFile == nil or jsonFile == "") then
		if(callBack) then
			callBack("Complie")
		end
		return
	end

	local function playCallBack(eventName)
		if eventName == "Complie" then 
			self.m_isIdleIng = true
			if(callBack) then
				callBack(eventName)
			end
		elseif eventName == "InternalINterupt" then 
		end
	end

	g_tConfigTable.AnimationEngine:GetInstance():PlayPackageBgConfig(
		g_tConfigTable.sTaskpath.."sayHelloGuide/story/"..jsonFile..".json",
		self.stageNode ,
		g_tConfigTable.sTaskpath.."image/",
		g_tConfigTable.sTaskpath.."sounds/",
		playCallBack
	);
end

function MainLayer:playActionAmin(jsonFile,callBack)
	if(jsonFile == nil or jsonFile == "") then
		if(callBack) then
			callBack("Complie")
		end
		return
	end

	local function playCallBack(eventName)
		self.tag_ = -1;
		if eventName == "Complie" then 
			if(callBack) then
				callBack(eventName)
			end
		elseif eventName == "InternalINterupt" then 
		end
	end
	
	if(self.tag_ > -1) then
		g_tConfigTable.AnimationEngine:GetInstance():ProcessActionToEndByTag(self.tag_);
		g_tConfigTable.AnimationEngine:GetInstance():StopPlayStory(self.tag_);
	end
	
	self.tag_ = g_tConfigTable.AnimationEngine:GetInstance():PlayPackageAction(
		g_tConfigTable.sTaskpath.."sayHelloGuide/story/"..jsonFile..".json",
		self.stageNode ,
		g_tConfigTable.sTaskpath.."image/",
		g_tConfigTable.sTaskpath.."audio/",
		playCallBack
	);
end

return MainLayer