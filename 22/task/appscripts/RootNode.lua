
local PathsUtil = requirePack("appscripts.Utils.PathsUtil"); 
local SpriteUtil = requirePack("appscripts.Utils.SpriteUtil"); 
local Controller = requirePack("appscripts.MVC.SysForChrismas.ChrismasController");

local RootNode = class("RootNode",function() 
    local node = cc.Node:create();
    return node;
end);

g_tConfigTable.CREATE_NEW(RootNode);

function RootNode:registerNodeEvent()
    self:registerScriptHandler(function(e)
        if e == "enter" then 
            self:onEnter();
        elseif e == "exit" then 
            self:onExit();
        end
    end);
end

function RootNode:onEnter()
    print(debug.traceback());
end

function RootNode:onExit()
    print(debug.traceback());
    if self.controller_ ~= nil then 
        self.controller_:Stop();
    end
end

function RootNode:ctor()
    self:registerNodeEvent();

    PathsUtil.SetImagePath(g_tConfigTable.sTaskpath .. "image/");
    SpriteUtil.SetScaleAdapt( ArmatureDataDeal:sharedDataDeal():getUIItemScale_1024_1920() );
    SpriteUtil.SetContentSize(cc.size(768,1024));

    local winSize = cc.Director:getInstance():getWinSize()
    self:setScale((1024-200)/1024);
    self:setPosition(cc.p((winSize.width-768*((1024-200)/1024))*0.5,(winSize.height-1024*((1024-200)/1024))*0.5))

    self.controller_ = Controller.new();
    self.controller_:Start(self);

end


return RootNode;