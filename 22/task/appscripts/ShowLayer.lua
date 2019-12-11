local isTest = false;
local ShowLayer = class("ShowLayer", function()
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
ShowLayer.new = function(...)
    local instance
    if ShowLayer.__create then
        instance = ShowLayer.__create(...)
    else
        instance = { }
    end

    for k, v in pairs(ShowLayer) do instance[k] = v end
    instance.class = ShowLayer
    instance:ctor(...);
    return instance
end

function ShowLayer:onEnter() 
    
end

function ShowLayer:onExit()
    g_tConfigTable.AnimationEngine:GetInstance():Dispose();
end

function ShowLayer:ctor(...)
	local tSdPath = ...
	self.sSdPath = tSdPath;
    self:init()
	self:addMainLayer()
end

function ShowLayer:init()
    self:setColor(cc.c3b(255,255,255))
    self.winSize = cc.Director:getInstance():getWinSize()
    self.ScaleMultiple = ArmatureDataDeal:sharedDataDeal():getUIItemScale_1024_1920() *0.8 
    self.m_mainLayer = nil;

	local btn_close = ccui.Button:create()
    btn_close:setTouchEnabled(true)
    btn_close:loadTextures(THEME_IMG("third/ic_back_n.png"), THEME_IMG("third/ic_back_p.png"), THEME_IMG("third/ic_back_p.png"))
    btn_close:setAnchorPoint(cc.p(0,0.5))
	btn_close:setScale(self.ScaleMultiple) 
 
    local x =15
    local y = self.winSize.height - btn_close:getContentSize().height/2 * btn_close:getScale()-20
    btn_close:setPosition(cc.p(-200, y))   
    btn_close:setPressedActionEnabled(true)     
    btn_close:setZoomScale(-0.12)
    btn_close:setTag(2017)
    self:addChild(btn_close,10)
    btn_close:addClickEventListener(function(sender)
        self:exitScene();
    end)    
    
    local function delayShowCloseBtn()
        btn_close:setPositionX(x)
    end
    performWithDelay(btn_close,delayShowCloseBtn, 1.0)

    if(isTest) then
        local btn_close1 = ccui.Button:create()
        btn_close1:setTouchEnabled(true)
        btn_close1:loadTextures(THEME_IMG("third/ic_back_n.png"), THEME_IMG("third/ic_back_p.png"), THEME_IMG("third/ic_back_p.png"))
        btn_close1:setAnchorPoint(cc.p(0,0.5))
        btn_close1:setScale(self.ScaleMultiple) 
    
        local x = 100
        local y = self.winSize.height - btn_close1:getContentSize().height/2 * btn_close1:getScale()-20
        btn_close1:setPosition(cc.p(x, y))   
        btn_close1:setPressedActionEnabled(true)     
        btn_close1:setZoomScale(-0.12)
        btn_close1:setTag(2017)
        self:addChild(btn_close1,10)
        btn_close1:addClickEventListener(function(sender)
            self:addMainLayer()
        end)

        local btn_close1 = ccui.Button:create()
        btn_close1:setTouchEnabled(true)
        btn_close1:loadTextures(THEME_IMG("third/ic_back_n.png"), THEME_IMG("third/ic_back_p.png"), THEME_IMG("third/ic_back_p.png"))
        btn_close1:setAnchorPoint(cc.p(0,0.5))
        btn_close1:setScale(self.ScaleMultiple) 
    
        local x =300
        local y = self.winSize.height - btn_close1:getContentSize().height/2 * btn_close1:getScale()-20
        btn_close1:setPosition(cc.p(x, y))   
        btn_close1:setPressedActionEnabled(true)     
        btn_close1:setZoomScale(-0.12)
        btn_close1:setTag(2017)
        self:addChild(btn_close1,10)
        btn_close1:addClickEventListener(function(sender)
            self:removeChildByTag(1)

            local function funx(preName)
                for key, _ in pairs(package.preload) do
                    if string.find(tostring(key), preName) == 1 then
                        package.preload[key] = nil
                    end
                end
                for key, _ in pairs(package.loaded) do
                    if string.find(tostring(key), preName) == 1 then
                        package.loaded[key] = nil
                    end
                end
            end
            funx("appscripts.MainLayer")
            funx("appscripts.ShareLayer")
        end)
    end
end

--主界面业务逻辑
function ShowLayer:addMainLayer()
    local winSize = cc.Director:getInstance():getWinSize()
	local MainLayer = requirePack("appscripts.MainLayer");
    local mainLayer = MainLayer.new();
    mainLayer:setContentSize(cc.size(768,1024))
    mainLayer:createUI(self.sSdPath);
    mainLayer:setTag(1)   
    mainLayer:setPosition(cc.p((winSize.width-768)*0.5,(winSize.height-1024)*0.5))
    mainLayer.parent = self
    self:addChild(mainLayer);
    self.m_mainLayer = mainLayer
end

function ShowLayer:exitScene()
    if(self.m_mainLayer ~= nil) then
        self.m_mainLayer:closeShare();
    end
    AudioEngine.stopMusic(true);--停止音乐
    xblStaticData:clearKeepFrom();
    xblStaticData:gotoSource(MOUDULE_XIALINGYING,MOUDULE_XIALINGYING, "21",STORY4V_TYPE_UNKNOW)
    SimpleAudioEngine:getInstance():playEffect(UISOUND_A_BTN)
end

return ShowLayer