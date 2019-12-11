local ShareLayer = class("ShareLayer", function()
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
ShareLayer.new = function(...)
    local instance
    if ShareLayer.__create then
        instance = ShareLayer.__create(...)
    else
        instance = { }
    end

    for k, v in pairs(ShareLayer) do instance[k] = v end
    instance.class = ShareLayer
    instance:ctor(...);
    return instance
end

function ShareLayer:onEnter() 
    
end

function ShareLayer:onExit()

end

function ShareLayer:ctor(...)
	local tSdPath = ...
    self:init()
end

function ShareLayer:init()

end

function ShareLayer:createUI(sSdPath,select_1,select_2,select_3,select_4,select_5,saveState,callBack)
	self.m_sSdPath = sSdPath;
	self.m_saveState = saveState;
	self.ScaleMultiple = ArmatureDataDeal:sharedDataDeal():getUIItemScale_1024_1920() * 0.8
    if ArmatureDataDeal:sharedDataDeal():getIsHdScreen() == false then
		self.ScaleMultiple = self.ScaleMultiple * 2
	end

	local bgLayer = cc.LayerColor:create(cc.c4b(0,0,0,170))
	bgLayer:setScale(10)
	bgLayer:setPosition(cc.p(0,0))
	self:addChild(bgLayer)

	local basePath = self.m_sSdPath.."image/"
	local bgSprite = cc.Sprite:create(basePath.."gui_Updated_bg.png");
	bgSprite:setScale(self.ScaleMultiple)
	bgSprite:setPosition(cc.p(384,512))
	self:addChild(bgSprite,10);

	local headSprite1 = cc.Sprite:create(basePath.."gui_head_portrait_bg.png");
	headSprite1:setScale(self.ScaleMultiple)
	headSprite1:setPosition(cc.p(486,728))
	self:addChild(headSprite1,10);

	local selfHeadSprite = UInfoUtil:getInstance():getBabyHeadSprite();
	selfHeadSprite:setAnchorPoint(cc.p(0.5,0.5));
	selfHeadSprite:setScale(self.ScaleMultiple*1.2)
	selfHeadSprite:setPosition(cc.p(486,728));
	self:addChild(selfHeadSprite,11)

	local headSprite2 = cc.Sprite:create(basePath.."gui_head_portrait.png");
	headSprite2:setScale(self.ScaleMultiple)
	headSprite2:setPosition(cc.p(486,728))
	self:addChild(headSprite2,12);
	
	local getNickName =  UInfoUtil:getInstance():getNickName()  
	if getNickName == nil or getNickName == ""  then
		getNickName = "宝宝"
	end

	local pLbDownload = cc.Label:createWithSystemFont("--"..getNickName, "", 24);
	pLbDownload:setColor(cc.c3b(0, 0, 0));
	pLbDownload:setAnchorPoint(cc.p(1,0.5))
	pLbDownload:setPosition(cc.p(550,345));
	self:addChild(pLbDownload,11);

	local imgPath = basePath.."gui_share_wechat.png"
	local hyBtn = ccui.Button:create(imgPath,imgPath);
	hyBtn:setScale(self.ScaleMultiple)
	hyBtn:setAnchorPoint(cc.p(0.5,0.5));
	hyBtn:setPosition(cc.p(470,165));
	hyBtn:setPressedActionEnabled(true)  
	hyBtn:setSwallowTouches(false);   
	self:addChild(hyBtn,10);
	hyBtn:addClickEventListener(function()
		Utils:GetInstance():baiduTongji("xialingying","wanfa_hy_0")--tong ji
		self:createSharePng(select_1,select_2,select_3,select_4,select_5,callBack,0);
	end)

	imgPath = basePath.."gui_share_Moments.png"
	local pyqBtn = ccui.Button:create(imgPath,imgPath);
	pyqBtn:setScale(self.ScaleMultiple)
	pyqBtn:setAnchorPoint(cc.p(0.5,0.5));
	pyqBtn:setPosition(cc.p(550,165));
	pyqBtn:setPressedActionEnabled(true)  
	pyqBtn:setSwallowTouches(false);   
	self:addChild(pyqBtn,10);
	pyqBtn:addClickEventListener(function()
		Utils:GetInstance():baiduTongji("xialingying","wanfa_pyq_0")--tong ji
		self:createSharePng(select_1,select_2,select_3,select_4,select_5,callBack,1);
	end)

	imgPath = basePath.."-s-gui_pop_contect_btn_close.png"
	local clseBtn = ccui.Button:create(imgPath,imgPath);
	clseBtn:setScale(self.ScaleMultiple)
	clseBtn:setAnchorPoint(cc.p(0.5,0.5));
	clseBtn:setPosition(cc.p(560,840));
	clseBtn:setPressedActionEnabled(true)  
	clseBtn:setSwallowTouches(false);   
	self:addChild(clseBtn,10);
	clseBtn:addClickEventListener(function()
		if(callBack) then
			callBack(false)
		end
	end)

	local liwuheArm = TouchArmature:create("191128wf_liwuhe", TOUCHARMATURE_NORMAL);	
	liwuheArm:setPosition(cc.p(384,620));
	liwuheArm:setScale(0.8)
	liwuheArm:playByIndex(1,LOOP_YES);
	if(select_1) then
		liwuheArm:ChangeOneSkin("liwu", select_1);
	end
	if(select_2) then
		liwuheArm:ChangeOneSkin("he1",select_2);
	end
	if(select_3) then
		liwuheArm:ChangeOneSkin("he2",select_3);
	end
	if(select_4) then
		liwuheArm:changeOneSkinToArmature("dai",select_4,"0");
	end
	if(select_5) then
		liwuheArm:changeOneSkinToArmature("baoshi",select_5,"0");
	end
	self:addChild(liwuheArm,10);
end

function ShareLayer:createSharePng(select_1,select_2,select_3,select_4,select_5,callBack,state)
	local tempPath = "201906Diaolog/fxtp1.png"
	local savePath = cc.FileUtils:getInstance():getWritablePath() .. tempPath
	if(self.m_saveState == 0) then
		self.m_saveState = 1;
		local rw = 920
		local rh = 1400
		local renderTextureLocal = cc.RenderTexture:create(rw,rh,2,0x88f0)
		local tRect = cc.rect(0, 0, rw,rh)
		
		local basePath = self.m_sSdPath.."image/"
		local bgSprite = cc.Sprite:create(basePath.."gui_Updated_bg.png");
		bgSprite:setPosition(cc.p(rw*0.5,rh*0.5))
		
		local size = bgSprite:getContentSize()
		local headSprite1 = cc.Sprite:create(basePath.."gui_head_portrait_bg.png");
		headSprite1:setPosition(cc.p(700,1200))
		bgSprite:addChild(headSprite1,10);
		
		local head = UInfoUtil:getInstance():getBabyHeadSprite()
		head:setScale(1.2)
		head:setPosition(cc.p(72,72))

		local hd_rd = cc.RenderTexture:create(144,144,2, 0x88f0) --其中设置最后两个参数为了无像素的图元不参与绘制，防止黑色块
		hd_rd:retain()
		hd_rd:begin() 
		head:visit()
		hd_rd:endToLua()
		hd_rd:release()
		hd_rd:setCascadeOpacityEnabled(true)
	
		local sp = cc.Sprite:createWithTexture(hd_rd:getSprite():getTexture())
		sp:setScaleY(-1)
		sp:setPosition(cc.p(700,1200))
		bgSprite:addChild(sp,11)
	
		local headSprite2 = cc.Sprite:create(basePath.."gui_head_portrait.png");
		headSprite2:setPosition(cc.p(700,1200))
		bgSprite:addChild(headSprite2,12);

		local getNickName =  UInfoUtil:getInstance():getNickName()  
		if getNickName == nil or getNickName == ""  then
			getNickName = "宝宝"
		end
		local pLbDownload = cc.Label:createWithSystemFont("--"..getNickName, "", 96);
		pLbDownload:setColor(cc.c3b(0, 0, 0));
		pLbDownload:setAnchorPoint(cc.p(1,0.5))
		pLbDownload:setScale(0.5)
		pLbDownload:setPosition(cc.p(850,300));
		bgSprite:addChild(pLbDownload,11);

		local liwuheArm = TouchArmature:create("191128wf_liwuhe", TOUCHARMATURE_NORMAL);	
		liwuheArm:setPosition(cc.p(size.width*0.5,960));
		liwuheArm:setScale(0.8/self.ScaleMultiple)
		liwuheArm:playByIndex(1,LOOP_YES);
		if(select_1) then
			liwuheArm:ChangeOneSkin("liwu", select_1);
		end
		if(select_2) then
			liwuheArm:ChangeOneSkin("he1",select_2);
		end
		if(select_3) then
			liwuheArm:ChangeOneSkin("he2",select_3);
		end
		if(select_4) then
			liwuheArm:changeOneSkinToArmature("dai",select_4,"0");
		end
		if(select_5) then
			liwuheArm:changeOneSkinToArmature("baoshi",select_5,"0");
		end
		bgSprite:addChild(liwuheArm,10);

		renderTextureLocal:retain()
		renderTextureLocal:begin()
		bgSprite:visit()
		renderTextureLocal:endToLua()
		renderTextureLocal:saveToFile(tempPath,1)
		renderTextureLocal:release()
	end

	local winSize = cc.Director:getInstance():getWinSize()
	local function closeCallBack()
		if(state == 0) then
			Utils:GetInstance():baiduTongji("xialingying","wanfa_hy_1")--tong ji
		else
			Utils:GetInstance():baiduTongji("xialingying","wanfa_pyq_1")--tong ji
		end
		showTips("分享成功",self, nil,24,3,0.5,0.5,nil,winSize.width*0.5,winSize.height*0.5)
		if(callBack) then
			callBack(true)
		end
	end

	local arr = {}
	table.insert(arr,cc.DelayTime:create(0.1))
	table.insert(arr,cc.CallFunc:create(function() 
		if not WxEventMgr:getInstance():isWeixinInstalled() then
			showTips("你还没装微信哦~",self, nil,24,3,0.5,0.5,nil,winSize.width*0.5,winSize.height*0.5)
			return
		end
		Utils:GetInstance():baiduTongji("xialingying","fx")
		Utils:GetInstance():weixinShare(state,0,"","",savePath,closeCallBack)
	end))
	self:runAction(cc.Sequence:create(arr));
end

return ShareLayer