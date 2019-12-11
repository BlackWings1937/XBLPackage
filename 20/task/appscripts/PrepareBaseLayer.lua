local JsonScriptUtil = requirePack("task.appscripts.JsonScriptUtil");
local PrepareBaseLayer = class("PrepareBaseLayer",function() 
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
  return layer;
end)

g_tConfigTable.CREATE_NEW(PrepareBaseLayer);

function PrepareBaseLayer:ctor() 
    self:initData();             -- 初始化成员数据
    self:initNodeInfo();         -- 初始化节点信息
    self:initExitBtn();          -- 初始化退出按钮
end


-- ----- 私有方法 -----
--[[
    初始化成员数据
]]--
function PrepareBaseLayer:initData()
    self.parentNode = nil;          -- 母节点
    self.btnExitPrepareLayer = nil; -- 退出预热界面的按钮
	self.data = {} ;                -- 当前界面数据
end

--[[
    初始化节点信息
]]--
function PrepareBaseLayer:initNodeInfo()
    self:setTag(20190903);
    self:setContentSize(768,1024);
    self:setAnchorPoint(cc.p(0,0));
end

--[[
    设置预热界面数据
    参数:
    d: data
]]--
function PrepareBaseLayer:setData( d )
    self.data = d;
end


-- ----- 事件 -----
function PrepareBaseLayer:onUserClickBtnExitPrepareLayer() 
    if self.parentNode ~= nil then 
        self:setTouchEnabled(false);
        JsonScriptUtil.StopAllAction(self);
        self:stopAllActions();
        self.parentNode:startExitPrepareLayer();
        -- todo set pre view normal
    end
end



-- ----- 子类重写扩展方法 -----
function PrepareBaseLayer:initExitBtn()
  
    self.btnExitPrepareLayer  = ccui.Button:create(
        THEME_IMG("third/ic_back_n.png"),
        THEME_IMG("third/ic_back_p.png"),
        THEME_IMG("third/ic_back_p.png")
    )
    self:addChild(self.btnExitPrepareLayer,1000000);
    local scaleTemp = ArmatureDataDeal:sharedDataDeal():getUIItemScale_1024_1920() *0.8
    local sz = cc.Director:getInstance():getWinSize()
    local excuteY = 0
    local pos = 
    cc.p(
        (768 - sz.width)/2 + 50,
        (1024 - (1024 - sz.height)/2)-self.btnExitPrepareLayer:getContentSize().width*scaleTemp-excuteY 
    )
    if  Utils:GetInstance():getIsIphoneX() == true then
        excuteY = 0 + 14
        pos = 
        cc.p(
            (768 - sz.width)/2 + 50,
            (1024 - (1024 - sz.height)/2)-self.btnExitPrepareLayer:getContentSize().width*scaleTemp-excuteY  
        )
    end

    self.btnExitPrepareLayer:setPosition(pos);
    self.btnExitPrepareLayer:setAnchorPoint(cc.p(0.5, 0.5));
    self.btnExitPrepareLayer:setScale(scaleTemp);
    self.btnExitPrepareLayer:defaultSetting();
    self.btnExitPrepareLayer:addClickEventListener(function(sender)
        self:onUserClickBtnExitPrepareLayer();
    end);
end

--[[
    初始化预热界面布局
]]--
function PrepareBaseLayer:initView() 

end

--[[
    初始化活动按钮
]]--
function PrepareBaseLayer:initActivityItems()

end

--[[
    层触碰监听
]]--
function PrepareBaseLayer:initTouch()
    self:registerScriptTouchHandler(function() 
        print("xxxxxxxxxxxxxxxxxxxxxxxxxx");
        return true;
    end, false, 0, true)
end

--[[
    撤销活动按钮
]]--
function PrepareBaseLayer:disposeActivityItems()

end

--[[
    预热界面切换完成后被调用的方法
]]--
function PrepareBaseLayer:Start()
    
end


-- ----- 对外接口 -----
--[[
    设置母节点
    参数:
    v: 预热界面的母节点
]]--
function PrepareBaseLayer:SetParentNode(v) 
    self.parentNode = v;
end

--[[
    获取母节点
]]--
function PrepareBaseLayer:GetParentNode()
    return self.parentNode;
end

--[[
    初始化
]]--
function PrepareBaseLayer:Init()
    self:initTouch();
    self:initActivityItems();
    self:initView();
end

--[[
    撤销预热层 - 要删除前调用
]]--
function PrepareBaseLayer:Dispose()
    self:disposeActivityItems();
end


--[[
    更新用户数据
]]--
function PrepareBaseLayer:Update(d)

end

--[[
    获取界面数据
]]--
function PrepareBaseLayer:GetData(  )
    return self.data ;
end

function PrepareBaseLayer:OnEnter()
    self:setTouchEnabled(true);
end

function PrepareBaseLayer:OnExit()
    self:setTouchEnabled(false);
end

return PrepareBaseLayer;