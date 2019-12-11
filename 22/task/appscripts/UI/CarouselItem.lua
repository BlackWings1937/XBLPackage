
local SpriteUtil = requirePack("appscripts.Utils.SpriteUtil");
local PathsUtil = requirePack("appscripts.Utils.PathsUtil"); 

local FramesItem = requirePack("appscripts.UI.FramesItem");
local SelectItem = requirePack("appscripts.UI.Base.SelectGroup.SelectItem");

local CarouselItem = class("CarouselItem",function()
    return SelectItem.new();
end);

g_tConfigTable.CREATE_NEW(CarouselItem);

function CarouselItem:ctor()
    self.fiOfSelect_ = nil; 
    self.spIcon_ = nil;
    self.spVipIcon_ = nil;
    self.spSelectPreIcon_ = nil;
end

function CarouselItem:Selected()
    if self.fiOfSelect_ ~= nil then 
        self.fiOfSelect_:Index(2);
    end
    if self.spSelectPreIcon_ ~= nil then 
        self.spSelectPreIcon_:setVisible(true);
    end
end

function CarouselItem:UnSelect()
    if self.fiOfSelect_ ~= nil then 
        self.fiOfSelect_:Index(1);
    end

    if self.spSelectPreIcon_ ~= nil then 
        self.spSelectPreIcon_:setVisible(false);
    end
end

function CarouselItem:Init(
    unselectedBgPath,
    selectedBgPath,
    iconPath,
    vipIconPath,
    selectPreIconPath)

    self.fiOfSelect_ = FramesItem.new();
    self.fiOfSelect_:Init({unselectedBgPath,selectedBgPath}); 
    self:addChild(self.fiOfSelect_);
    local cs = self.fiOfSelect_:getContentSize();
    self:setContentSize(cs);

    self.spIcon_ = ccui.Button:create( 
        iconPath, 
        iconPath
    );
    self:addChild(self.spIcon_);
    self.spIcon_:addClickEventListener(function()	
        -- todo on user click next
        print("self.spIcon_");	
    end)

    self.spVipIcon_ = SpriteUtil.Create(
        vipIconPath
    );
    self:addChild(self.spVipIcon_);
    self.spVipIcon_:setPosition(cc.p(-cs.width/2,cs.height/2));

    self.spSelectPreIcon_ = SpriteUtil.Create(
        selectPreIconPath
    );
    self:addChild(self.spSelectPreIcon_);
    self.spSelectPreIcon_:setPosition(cc.p(cs.width/2,-cs.height/2));

end


return CarouselItem;