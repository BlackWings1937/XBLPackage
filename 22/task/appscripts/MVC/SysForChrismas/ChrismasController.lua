

local ChrismasView = requirePack("appscripts.MVC.SysForChrismas.ChrismasView");
local ChrismasData = requirePack("appscripts.MVC.SysForChrismas.ChrismasData");

local BaseController = requirePack("appscripts.MVC.Base.BaseController");


local ChrismasController = class("ChrismasController",function() 
    return BaseController.new();
end);
g_tConfigTable.CREATE_NEW(ChrismasController);

function ChrismasController:ctor()
    -- 定义所有使用过的成员在这里..
    self.rootNode_ = nil;                --玩法根节点
end

--[[
    通过这个方法传入sys所有需要的外部参数
    初始化:
        View
        data
    参数:
    rootNode:sys根节点
]]--
function ChrismasController:Start(rootNode)
    self.rootNode_ = rootNode;

    self:setView(ChrismasView.new());--
    self:setData(ChrismasData.new());--
    dump(self:getView());
    local x,y = self:getView():getPosition();
    print("x:"..x);
    print("y:"..y);
    self.rootNode_:addChild(self:getView());

    self:getView():Init();
    self:getData():Init();
end

--[[
    通过这个方法终止sys
    撤销:
        View
        data
]]--
function ChrismasController:Stop()
    self:getView():Dispose();
    self:getData():Dispose();
end

return ChrismasController;