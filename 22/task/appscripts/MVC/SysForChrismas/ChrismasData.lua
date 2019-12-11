local BaseData = requirePack("appscripts.MVC.Base.BaseData");


local ChrismasData = class("ChrismasData",function() 
    return BaseData.new();
end);
g_tConfigTable.CREATE_NEW(ChrismasData);

function ChrismasData:ctor()
    -- 定义所有使用过的成员在这里..
end

--[[
    在这个方法中初始化所有sys需要的数据
    包括:
        本地
        服务器
]]--
function ChrismasData:Init()

end

--[[
    在这个方法中保存所有sys需要的数据
    包括:
        本地
        服务器
]]--
function ChrismasData:Dispose()

end

return ChrismasData;