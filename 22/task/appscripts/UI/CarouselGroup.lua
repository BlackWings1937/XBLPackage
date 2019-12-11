
local SelectGroupBase = requirePack("appscripts.UI.Base.SelectGroup.SelectGroupBase");

local CarouselGroup = class("CarouselGroup",function() 
    return SelectGroupBase.new();
end);

g_tConfigTable.CREATE_NEW(CarouselGroup);

function CarouselGroup:ctor()
    self.content_ = cc.Node:create();
    self:addChild(self.content_);
    self.listOfItems_ = {};

    self.offset_ = 0;
    self.spacing_ = 0;

    self.speed_ = 1;

    self.tagOfMoving_ = 1001;
end

function CarouselGroup:SetSpeed(v)
    self.speed_ = v;
end

function CarouselGroup:getSpeed()
    return self.speed_;
end

function CarouselGroup:startMove()
    local seq = cc.Sequence:create(
        cc.DelayTime:create(0.016),
        cc.CallFunc:create(function()
            self:update(); 
        end) );
    seq:setTag(self.tagOfMoving_);
    self:runAction(seq);
end

function CarouselGroup:stopMove()
    self:stopActionByTag(self.tagOfMoving_);
end

function CarouselGroup:update()
    local x,y = self.content_:getPosition();
    x = x - 0.016*self.speed_;
    self.content_:setPosition(cc.p(x,y));
    self:updateContentPos(cc.p(x,y));
end

function CarouselGroup:updateContentPos(pos)

end

--[[
    getposByIndex()
    getItemposFirstIndexwho
    getsortlist 
    getindexlist
    update every one pos
]]--
function CarouselGroup:OnItemClick(item)

end

function CarouselGroup:Update(list)

end

return CarouselGroup;