local XiaLingYingButton = class("XiaLingYingButton", function(msi)
  local sNode = StateNode:create(msi)
  sNode.msi = msi
  return sNode
end)
 
-- 重写New方法
XiaLingYingButton.new = function(...)
    local instance
    if XiaLingYingButton.__create then
        instance = XiaLingYingButton.__create(...)
    else
        instance = { }
    end
    for k, v in pairs(XiaLingYingButton) do instance[k] = v end
    instance.class = XiaLingYingButton
    instance:ctor(...);
    return instance
end
 
-- 已经创建初步初始化完成ｄｄｆ
function XiaLingYingButton:ctor() 
  if self.setLuaHandle == nil then
      self.scheduleInit = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        if self.scheduleInit then
          cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleInit)
          self.scheduleInit = nil
        end
        self:onSetHandle()
      end, 0.5, false)
  else
      self:onSetHandle()
  end 
end

--经常被重置 
function XiaLingYingButton:onSetHandle()
  if self.setLuaHandle == nil then
     return 
  end  
  self:setLuaHandle(function(sType, pInfo, pInfo2) 
    if sType == "onClickItemState" then --不必要
    elseif sType == "onStateChange" then --核实了
      self:changeCellStatePic()
    elseif sType == "onDownloadProgress" then
      self:onDownloadProgress(pInfo) --核实了 
    elseif sType == "onUnZipProgress" then
      self:onUnZipProgress(pInfo) --核实了 
    elseif sType == "onDownloadNetError" then --下载出错
      self:changeCellStatePic()
    elseif sType == "onPopViewClick" then --询问
      self:onPopViewClick(pInfo,pInfo2)--第一个参数是 1=取消0=确认，第二个参数是那个弹窗
    elseif sType == "longPressDeleteFinish" then --长按删除完成回调
       self:changeCellStatePic()
    elseif sType == "onEnter" then
    elseif sType == "onExit" then 
       self:onExit()  
    end
  end)
end

function XiaLingYingButton:onEnter()
   
end 

function XiaLingYingButton:onExit()
    if(self.msi ~= nil) then
      self.msi:release()
      self.msi = nil
    end

    if self.scheduleInit then
      cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleInit)
      self.scheduleInit = nil
    end

    self:clearCallBack();  -- 2018.9.5添加 。
end 

function XiaLingYingButton:onLongPressDel()--长按删除
   self:onLongPressDelete()
end 


function XiaLingYingButton:onDownloadProgress(percent)--下载进度
	self:updateWaterProgress(percent*0.8)
end 

function XiaLingYingButton:onUnZipProgress(percent)--解压进度
   self:updateWaterProgress(percent*0.2+80)
end 
 
function XiaLingYingButton:onPopViewClick(clickType,popView)--修复按钮，更新按钮，非WiFi信号 取消的回调
   self:changeCellStatePic()
   if popView == UpdateView  and clickType == 1  then -- 1是取消  
   end
end 

function XiaLingYingButton:getWidthAndHeight()
      return 220,220
end
 
function XiaLingYingButton:init(dayIndex,rootPath,parent)
	if not dayIndex then
		dayIndex = 1
	end
	if dayIndex < 1 then
		dayIndex = 1
	end
	
	self.m_dayIndex = dayIndex	
	self.m_rootPath = rootPath
	self.m_parent = parent
	self.m_baiduKey = "xmas19"
	
    local width = 140 
    local height = 140
	
    local  itemLayer  = cc.LayerColor:create(cc.c4b(0, 0, 0,0))
    itemLayer:setContentSize(cc.size(width,height))
    itemLayer:setAnchorPoint( cc.p(0,0)) -- 锚点 是 0  0 
    itemLayer:setTouchEnabled(false) 
    itemLayer:setTag(1024)
    itemLayer:setPosition(cc.p(0,0))
    self:addChild(itemLayer)
	
	if(self.m_dayIndex < 8) then
		return
	end
	
	local refPath = THEME_IMG("OperationPosition/default/xialingying.png") 
	local HomeUIButton =  requirePack("baseScripts.homeUI.HomeUIButton", false); --新的封装的按钮
	local Button_item = HomeUIButton.new()
	Button_item:init(refPath,refPath,refPath,width*0.5,height*0.5,cc.p(0.5,0.5),itemLayer,0,1)
	Button_item:setOpacity(0)
	Button_item:defaultSetting()
	Button_item:setName("Button_item")

	-- 创建新的加载动画
	local pic = "gui_bannerloading_001.png"
	local plisFile = "allimgs/gui_bannerloading_ios0.plist"
	local pngFile = "allimgs/gui_bannerloading_ios0.png"
	local isLoad = cc.SpriteFrameCache:getInstance():isSpriteFramesWithFileLoaded(plisFile)
	if not isLoad then
		cc.SpriteFrameCache:getInstance():addSpriteFrames(plisFile)
	end
	--
	local scale1 = ArmatureDataDeal:sharedDataDeal():getUIItemScale_1024_1920() * 0.8
	local sp = cc.Sprite:createWithSpriteFrameName(pic)
	sp:setPosition(cc.p(width*0.5,height*0.5))
	sp:setScale(scale1)
	sp:setVisible(false)
	itemLayer:addChild(sp,10)
	self.loadingSprite = sp
	--
	local cloneAnim = CreateSpriteFrameAnim("gui_bannerloading_%03d.png",76,nil,0.05)
	local ac = cc.RepeatForever:create(cloneAnim)
	sp:runAction(ac)
	
	-- 百分比
	local scale2 = ArmatureDataDeal:sharedDataDeal():getUIItemScale()
	local numImg = THEME_IMG("new2ji/copyNum.png")
	local lable = cc.LabelAtlas:_create("0",numImg,16/scale2,26/scale2,string.byte("0"))
	lable:setAnchorPoint(cc.p(1,0.5))
	lable:setPosition(cc.p(width*0.5,height*0.5 + 5))
	lable:setVisible(false)
	lable:setScale(0.5)
	itemLayer:addChild(lable,12)
	self.fsLable = lable

	local tsprite = cc.Sprite:create(THEME_IMG("new2ji/copyPercent.png"))
	tsprite:setAnchorPoint(cc.p(0,0.5))
	tsprite:setPosition(cc.p(width*0.5,height*0.5 + 5))
	tsprite:setVisible(false)
	tsprite:setScale(0.5)
	itemLayer:addChild(tsprite,12)
	self.bfbSprite = tsprite
end

function XiaLingYingButton:clickForwardDown()
	if(self.m_dayIndex < 8) then
		local state = self:getCurDownState()
		if state == UPDATE_START or  
		   state == REPAIR_START or 
		   state == DOWNLOAD_START then  --需要更新 需要修复  没下载
			Utils:GetInstance():baiduTongji("xialingying","down_"..self.m_baiduKey)--tong ji
			self:onClickItem()
		end
	end
end

function XiaLingYingButton:onShowCellContent(msi)
	self.msi = msi
	self.msi:retain();

	if(self.m_dayIndex >= 8) then
		local function touchFuncton()
			HomeUILayer:getCurInstance():getNormalUIItem():getCanTouch()  
			SimpleAudioEngine:getInstance():playEffect(UISOUND_A_BTN)
			local state = self:getCurDownState()
			if state == UPDATE_START or  
			   state == REPAIR_START or 
			   state == DOWNLOAD_START then  --需要更新 需要修复  没下载
				Utils:GetInstance():baiduTongji("xialingying","down_"..self.m_baiduKey)--tong ji
				self:onClickItem()
			elseif state == DOWNLOAD_OK then
				Utils:GetInstance():baiduTongji("xialingying", "click_ok_"..self.m_baiduKey)
				self:OnTouchClick() 
			end 
		end
		
		local item = self:getChildByTag(1024)
		item:getChildByName("Button_item"):registerTouchEnd(touchFuncton)
		item:getChildByName("Button_item"):setSwallowTouches(true) --吞噬
	end
	
	self:refreshShowItemInfo(self.msi) --调用C++的方法 
	self:changeCellStatePic()--修改状态显示
end

function XiaLingYingButton:changeCellStatePic()
    local item = self:getChildByTag(1024) 
	if(self.loadingSprite) then
		self.fsLable:setVisible(false)
		self.bfbSprite:setVisible(false)
		self.loadingSprite:setVisible(false)
	end
	
    if self.msi.isNeiZhi == true  then
       return 
    end
	
    local state = self:getCurDownState() --c++的方法
    if state == CHECK_VIP_START then  -- // 未知     
    elseif  state == UPDATE_START then  -- //需要更新  then
		--item:getChildByName("Image_state"):setVisible(true) --状态
		--item:getChildByName("Image_state"):loadTexture(THEME_IMG( "OperationPosition/default/download_toybox/needupdate.png")) 
    elseif state == REPAIR_START then --需要修复
		--item:getChildByName("Image_state"):setVisible(true) --状态
		--item:getChildByName("Image_state"):loadTexture(THEME_IMG("OperationPosition/default/download_toybox/needrepair.png")) 
    elseif state == DOWNLOAD_START then -- 未下载
		--item:getChildByName("Image_state"):setVisible(true) --状态
		--item:getChildByName("Image_state"):loadTexture(THEME_IMG("OperationPosition/default/download_toybox/needdown.png")) 
    elseif state == DOWNLOADING then --正在下载中 
		if(self.loadingSprite) then
			self.fsLable:setVisible(true)
			self.bfbSprite:setVisible(true)
			self.loadingSprite:setVisible(true)
		end
    elseif state == DOWNLOAD_WAIT then --等待下载  
		if(self.loadingSprite) then
			self.fsLable:setVisible(true)
			self.bfbSprite:setVisible(true)
			self.loadingSprite:setVisible(true)
		end
    elseif state == DOWNLOAD_OK then --下载好了
		
    elseif state == ITEM_NOT_BUY then --//未购买
 
    elseif state == UNZIPING then --正在解压中
		if(self.loadingSprite) then
			self.fsLable:setVisible(true)
			self.bfbSprite:setVisible(true)
			self.loadingSprite:setVisible(true)
		end
    end
end 
 
 --打斷
function XiaLingYingButton:OnTouchClick() --点击 
	HomeUILayer:getCurInstance():getNormalUIItem():getCanTouch(10)  
	local function sayCallback()
		Utils:GetInstance():baiduTongji("xialingying","goto_"..self.m_baiduKey)--tong ji
		XiaLingYingData:getInstance():setXiaLingYingInfo(1,1,self.msi.bagId);
		xblStaticData:gotoSource(MOUDULE_MAIN,MOUDULE_XIALINGYING, self.msi.bagId,STORY4V_TYPE_UNKNOW)
	end
  
	local function callback()

		Utils:GetInstance():baiduTongji("xialingying","say_"..self.m_baiduKey)
		Home7World:getCurInstance():setOnlyScrollEnable(false)  --设置不能滑动。因为绵绵关闭的时候会 滑动
		HomeUILayer:getCurInstance():getNormalUIItem():getCanTouch(5)  
		local xblNpc = Home7World:getCurInstance():getHomeNpcByName("XBL")
		local jsonPath = self.m_rootPath.."sayHelloGuide/story/"
		local imagePath = self.m_rootPath.."image/"
		local audioPath = self.m_rootPath.."audio/"
		
		local curIdStr = UInfoUtil:getInstance():getCurUidStr()
		local strKey = self.m_baiduKey.."_act_into_"..curIdStr
		local gUserData = cc.UserDefault:getInstance()
		local isFirst = gUserData:getStringForKey(strKey,"")
		local jsonFile = nil
		if isFirst == "" then
			gUserData:setStringForKey(strKey, "1")
			gUserData:flush()
			jsonFile = "geyr050"
		else
			jsonFile = "geyr051"
		end	
		
		local strKey = self.m_baiduKey.."_"..curIdStr.."_"..self.m_dayIndex
		gUserData:setStringForKey(strKey, "1")
		gUserData:flush()
		
		xblNpc:playXBLSayNewActionScripts(jsonFile,imagePath,jsonPath,audioPath,sayCallback )	
		
		local gUserData = cc.UserDefault:getInstance() 	
		local strKey = "isnotClick"..UInfoUtil:getInstance():getCurUidStr().."_"..self.m_dayIndex
		local isnotClick = gUserData:getStringForKey(strKey,"")
		if isnotClick == "" then
			gUserData:setStringForKey(strKey, "1")
		end

		self.m_parent.pumpkin:playByIndex(2, LOOP_NO);
		self.m_parent.pumpkin:setLuaCallBack(function ( eType, pTouchArm, sEvent )
			if eType == TouchArmLuaStatus_AnimPerEnd then
				self.m_parent.pumpkin:playByIndex(0, LOOP_YES)
			end
		end)
	end
	HomeUILayer:getCurInstance():getNormalUIItem():clickDo(callback,false,THEME_FILE("sounds/ui002.mp3"))   
end


--帧动画动画
function XiaLingYingButton:createSpriteFrameAnim(nameStrFormat,num,isResOrig,rate)
	if type(nameStrFormat) ~= "string" or type(num) ~= "number" then
		return
	end
	
	-- qianzName前缀名字 num个数
	local spriteFrame = cc.SpriteFrameCache:getInstance()
	local animation = cc.Animation:create()  
	for i=1,num do 
	    local blinkFrame = spriteFrame:getSpriteFrame(string.format(nameStrFormat,i))  
	    animation:addSpriteFrame( blinkFrame )  
	end  
	animation:setDelayPerUnit(rate or 0.1)--设置每帧的播放间隔  
	animation:setRestoreOriginalFrame( isResOrig or true )--设置播放完成后是否回归最初状态  
	local action = cc.Animate:create(animation)  
	return action
end

function XiaLingYingButton:updateWaterProgress(percent)
	if(self.fsLable) then
		self.fsLable:setString(math.floor(percent))
	end
end

return XiaLingYingButton