local ShiftNodeAction = class("ShiftNodeAction");

g_tConfigTable.CREATE_NEW(ShiftNodeAction);

function ShiftNodeAction:ctor()
    self.shiftActionTag = 1001; -- 使用动作标签
    self.cb = nil;              -- 切换结束后的回掉
    self.dt = 0;                -- 切换过场时间
    self.n = nil;               -- 操作节点
end

function ShiftNodeAction:GetShiftActionTag()
    return self.shiftActionTag;
end

function ShiftNodeAction:processCallBack()
    if self.cb ~= nil then 
        self.cb();
    end
end

--[[
    运行切场
    子类重写
]]--
function ShiftNodeAction:ProcessShift()

end

--[[
    运行切场
    子类重写
]]--
function ShiftNodeAction:Init(sp,ep,dt,n)

end




return ShiftNodeAction;