--[[
    MVC View 基类
    子类通过重写:
    Init    方法 定义界面初始化，1.创建所有需要的显示对象 2.注册所有要使用的UI事件
    Dispose 方法 撤销界面       1.删除所有持有的显示对象 2.注销所有持有的UI事件
    Update  方法 根据数据 更新所有相关界面 显示对象 
]]--

local BaseView = class("BaseView");
g_tConfigTable.CREATE_NEW(BaseView);

function BaseView:Init()

end

function BaseView:Dispose()

end

function BaseView:Update()

end

return BaseView;