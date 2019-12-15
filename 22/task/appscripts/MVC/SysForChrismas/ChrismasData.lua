local BaseData = requirePack("appscripts.MVC.Base.BaseData");


local ChrismasData = class("ChrismasData",function() 
    return BaseData.new();
end);
g_tConfigTable.CREATE_NEW(ChrismasData);

ChrismasData.EnumViewType = {
    ["E_DECORATION"] = 1,
    ["E_RECORD_AUDIO"] = 2,
    ["E_FINISH"] = 3,
    ["E_SHARE"] = 4
}

function ChrismasData:ctor()
    -- 定义所有使用过的成员在这里..
end

function ChrismasData:initDebugData()

    -- judge vip

    local data = {};
    data.IsVip = true;
    data.ViewType = ChrismasData.EnumViewType.E_DECORATION;
    data.DecorationStep  = 1;
    data.RecordAudioStep = 1;
    data.ListOfBackGroundOption = {
        {index = 1,iconName = "gui_heka01_vip.png",VipItem = true},
        {index = 2,iconName = "gui_heka02.png",VipItem = false},
        {index = 3,iconName = "gui_heka03.png",VipItem = false},
        {index = 4,iconName = "gui_heka04.png",VipItem = false}
    };
    data.ListOfDecorationOption = {
        {index = 1,iconName = "gui_youdian01-vip.png",VipItem = true},
        {index = 2,iconName = "gui_youdian02.png",VipItem = false},
        {index = 3,iconName = "gui_youdian03.png",VipItem = false},
        {index = 4,iconName = "gui_youdian04.png",VipItem = false},
        {index = 5,iconName = "gui_youdian05.png",VipItem = false},
    };
    data.ListOfWordOption = {
        {index = 1,iconName = "gui_ribbon_01_vip.png",VipItem = true},
        {index = 2,iconName = "gui_youdian02.png",VipItem = false},
        {index = 3,iconName = "gui_youdian03.png",VipItem = false},
        {index = 4,iconName = "gui_youdian04.png",VipItem = false},
        {index = 5,iconName = "gui_youdian05.png",VipItem = false},
    };

    data.UserDecorationOptions = {
        [1] = -1,
        [2] = -1,
        [3] = -1,
    };
    data.Audio = {};
    
    self:setData(data);
end

function ChrismasData:SetUserDecorationOptionsByStepAndIndex(st,i)
    self:GetData().UserDecorationOptions[st] = i;
end

--[[
    在这个方法中初始化所有sys需要的数据
    包括:
        本地
        服务器
]]--
function ChrismasData:Init()
    self:initDebugData();
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