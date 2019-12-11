local  ActivityItemBase = requirePack("task.appscripts.Base.ActivityItems.ActivityItemBase");
local  JsonScriptUtil   = requirePack("task.appscripts.JsonScriptUtil");
local  ArmatureUtil = requirePack("task.appscripts.ArmatureUtil");

local ActivityItem = class("ActivityItem",function() 
    return ActivityItemBase.new();
end)

g_tConfigTable.CREATE_NEW(ActivityItem);


ActivityItem.STR_ITEM_ARMATURE_NAME = "";
ActivityItem.SetItemArmatureName = function(v) ActivityItem.STR_ITEM_ARMATURE_NAME = v; end
ActivityItem.GetItemArmatureName = function() return ActivityItem.STR_ITEM_ARMATURE_NAME; end

ActivityItem.STR_ITEM_GIFT_ARMATURE_NAME = "";
ActivityItem.SetItemGiftArmatureName = function(v) ActivityItem.STR_ITEM_GIFT_ARMATURE_NAME = v; end
ActivityItem.GetItemGiftArmatureName = function() return ActivityItem.STR_ITEM_GIFT_ARMATURE_NAME; end

ActivityItem.STR_ITEM_IMAGE_NAME = "";
ActivityItem.SetItemImageName = function(v) ActivityItem.STR_ITEM_IMAGE_NAME = v;  end
ActivityItem.GetItemImageName = function() return ActivityItem.STR_ITEM_IMAGE_NAME; end


ActivityItem.EnumOfItemStatus = {
    ["E_LOCK"] = 1,                    -- 锁定状态
    ["E_TODAY"] = 2,                   -- 当日状态
    ["E_UNLOCKED"] = 3,                -- 解锁状态
    ["E_GETED"] = 4,                   -- 获取状态
}

function ActivityItem:ctor()
    self.btnUserClick_ = nil;                   -- 用户点击按钮 [透明区域]
    self.btnArmture_ = nil;                     -- 用户点击按钮动画
    self.btnImage_ = nil;                       -- 用户点击按钮图片
    self.giftArmature_ = nil;                   -- 礼物动画

    self.status_ = 1;                           -- item状态         
    
    self.active_ = true;                        -- 当前item 显示隐藏状态
end


-- ----- 事件 -----
function ActivityItem:onUserClickActivityBtn()
    if self.active_ then 
        if self.status_ == ActivityItem.EnumOfItemStatus.E_TODAY or self.status_ == ActivityItem.EnumOfItemStatus.E_UNLOCKED then 
            -- todo user get gift here ..
            if self.data_ ~= nil then 
                self:GetParent():OnUserGetGiftByIndex(self.data_.index);
                print("onUserClickActivityBtn1");

                self:GetParent():CallBaiduRecord("xmas19_click_qiandao"..self.data_.index);     -- 解锁礼物盒统计
            end
        elseif self.status_ == ActivityItem.EnumOfItemStatus.E_GETED then 
            if self.data_ ~= nil then 
                self:GetParent():OnUserPlayGiftByIndex(self.data_.index);
                print("onUserClickActivityBtn2");

                self:GetParent():CallBaiduRecord("xmas19_click_item"..self.data_.index);        -- 点击礼物

            end
        elseif self.status_ == ActivityItem.EnumOfItemStatus.E_LOCK then 
            if self.data_ ~= nil then 
                self:GetParent():OnUserGetGiftFailByIndex(self.data_.index);
                print("onUserClickActivityBtn3");

            end
        end
    end
end

-- ----- 私有方法 -----
function ActivityItem:setGiftArmatureVisible(v)
    if self.giftArmature_ ~= nil then 
        self.giftArmature_:setVisible(v);
    end
end

function ActivityItem:updateShowObjByIndex(i)
    if self.btnImage_ ~= nil then 
        self.btnImage_:removeFromParent();
    end
    local pathOfImage = g_tConfigTable.imagePath..ActivityItem.GetItemImageName()..i..".png";
    self.btnImage_ = cc.Sprite:create(pathOfImage);
    self:GetParent():addChild(self.btnImage_,JsonScriptUtil.INT_MAX_ENGINE_ZORDER);

    if self.btnImage_ == nil then 
        print("Error:ActivityItem btnImage_ create Fail index at:"..i.." pathAt:"..pathOfImage); 
        print(debug.traceback(  ));
    end

    self.btnArmture_ = JsonScriptUtil.GetNpcByName(self:GetParent(), ActivityItem.GetItemArmatureName()..i); 
    if self.btnArmture_ == nil then
        print("Error:ActivityItem btnArmture_ == nil Check BgConfig for PrepareLayer index at:"..i); 
        print(debug.traceback(  ));
    end

    self.giftArmature_ = JsonScriptUtil.GetNpcByName(self:GetParent(), ActivityItem.GetItemGiftArmatureName()..i); 
    if self.giftArmature_ == nil then
       -- self.giftArmature_ = cc.Node:create();
       -- self.btnImage_:addChild(self.giftArmature_);
        print("Warning:ActivityItem giftArmature_ == nil Check BgConfig for PrepareLayer index at:"..i); 
        --print(debug.traceback(  ));
    end

    local x,y = self.btnArmture_:getPosition();
    self.btnImage_:setPosition(cc.p(x,y));
    self.btnUserClick_:setPosition(cc.p(x,y));
    self.btnImage_:setScale(0.427);
    self.btnImage_:setZOrder(self.btnArmture_:getZOrder()-1);
    self.btnUserClick_:setScale(0.427);
end

function ActivityItem:updateByStatus(st)
    self.status_ = st;
    if self.status_ == ActivityItem.EnumOfItemStatus.E_LOCK then 
        self.btnImage_:setVisible(false);
        self.btnArmture_:setVisible(true);
        self.btnArmture_:playByIndex(1,LOOP_NO);
    elseif self.status_ == ActivityItem.EnumOfItemStatus.E_TODAY then 
        self.btnImage_:setVisible(false);
        self.btnArmture_:setVisible(true);
        self.btnArmture_:playByIndex(6,LOOP_NO);
    elseif self.status_ == ActivityItem.EnumOfItemStatus.E_UNLOCKED then 
        self.btnImage_:setVisible(false);
        self.btnArmture_:setVisible(true);
        self.btnArmture_:playByIndex(0,LOOP_NO);
    elseif self.status_ == ActivityItem.EnumOfItemStatus.E_GETED then 
        self.btnImage_:setVisible(true);
        self.btnArmture_:setVisible(true);
        self.btnArmture_:playByIndex(4,LOOP_NO);
    end
    self:setGiftArmatureVisible(false);
end

-- ----- 重写基类方法 实现具体的活动 -----
--[[
    更新图标方法 - [子类重写实现各种活动效果]
]]--
function ActivityItem:Update(data)
    self.data_ = data;
    self.active_ = true;
    local itemIndex = self.data_.index;
    local status = self.data_.status;
    self:updateShowObjByIndex(itemIndex);
    self:updateByStatus(status);
end

--[[
    删除item前需要撤销节点 - [子类重写实现各种活动效果]
]]--
function ActivityItem:Dispose()
    self.btnUserClick_:removeFromParent();
    self.btnImage_:removeFromParent();
end


--[[
    初始化方法
    参数:
    n:item母节点
]]--
function ActivityItem:Init(n)
    ActivityItemBase.Init(self,n);
    self.btnUserClick_ = ccui.Button:create(g_tConfigTable.imagePath.."btnBlackBtn.png",g_tConfigTable.imagePath.."btnBlackBtn.png");
    self:GetParent():addChild(self.btnUserClick_,JsonScriptUtil.INT_MAX_ENGINE_ZORDER+1);
    self.btnUserClick_:addClickEventListener(function(sender)
        print(".btnUserClick_:addClickEventListener");
        self:onUserClickActivityBtn();
    end);
end

--[[
    隐藏item
]]--
function ActivityItem:Hide()
    self.active_ = false;
    if self.btnImage_ ~= nil and self.btnArmture_ ~= nil then 
        self.btnImage_:setVisible(self.active_);
        self.btnArmture_:setVisible(self.active_);
        self:setGiftArmatureVisible(true);
    end
end

return ActivityItem;