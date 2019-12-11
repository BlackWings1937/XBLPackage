--[[
    MVC controller 基类
    子类通过重写 Start Stop 方法 关闭和启动系统
]]--

local BaseController = class("BaseController")
g_tConfigTable.CREATE_NEW(BaseController);

function BaseController:ctor()
    self.view_ = nil;
    self.data_ = nil;
end

function BaseController:getView()
    return self.view_;
end

function BaseController:getData()
    return self.data_;
end

function BaseController:setView(v)
    self.view_ = v;
end

function BaseController:setData(v)
    self.data_ = v;
end

function BaseController:Start()

end

function BaseController:Stop()

end

return BaseController;


