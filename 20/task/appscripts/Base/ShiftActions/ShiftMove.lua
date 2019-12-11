local  ShiftNodeAction = requirePack("task.appscripts.Base.ShiftActions.ShiftNodeAction");

local ShiftMove = class("ShiftMove",function() 
    return ShiftNodeAction.new();
end);
g_tConfigTable.CREATE_NEW(ShiftMove);

--[[
    运行动作
]]--
function ShiftMove:ProcessShift()
    if self.n ~= nil then 
        local a = self.n:getActionByTag(self:GetShiftActionTag());
        if a ~= nil then 
            return ;
        end
        a = cc.Sequence:create(cc.MoveTo:create(self.dt,self.ep),cc.CallFunc:create(function()
            self:processCallBack();
        end));
        a:setTag(self:GetShiftActionTag());
        self.n:runAction(a);
    end
end


--[[
    设置动作的方法
    参数:
    sp:开始位置
    ep:结束位置
    dt:运行时间
    n: 控制场景
]]--
function ShiftMove:Init(sp,ep,dt,n,cb)
    print("ShiftMove:Init1");
    self.n  = n;
    if  self.n ~= nil  then 
        print("ShiftMove:Init2");
        if  self.n.setPosition ~= nil then 
            print("ShiftMove:Init3");
            self.sp = sp;
            self.ep = ep;
            self.cb = cb;
            self.dt = dt;

            self.n:setPosition(self.sp);
        end
    end
end


return ShiftMove;