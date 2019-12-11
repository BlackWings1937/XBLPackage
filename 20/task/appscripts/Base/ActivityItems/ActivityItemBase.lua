local ActivityItemBase = class("ActivityItemBase")

g_tConfigTable.CREATE_NEW(ActivityItemBase);

function ActivityItemBase:ctor()
    self.parent_ = nil;                      -- 母结点
    self.data_ = nil;                        -- item数据
end

function ActivityItemBase:GetParent()
    return self.parent_;
end



--[[
    更新图标方法 - [子类重写实现各种活动效果]
]]--
function ActivityItemBase:Update(data)

end

--[[
    删除item前需要撤销节点 - [子类重写实现各种活动效果]
]]--
function ActivityItemBase:Dispose()

end

--[[
    初始化方法
    参数:
    n:item母节点
]]--
function ActivityItemBase:Init(n)
    self.parent_ = n;
end




return ActivityItemBase;