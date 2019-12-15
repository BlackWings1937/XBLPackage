local PathsUtil = requirePack("appscripts.Utils.PathsUtil"); 
local SpriteUtil = requirePack("appscripts.Utils.SpriteUtil"); 
local ButtonUtil = requirePack("appscripts.Utils.ButtonUtil"); 

local StickerProcessBar = requirePack("appscripts.UI.StickerProcessBar");
local CarouselItem = requirePack("appscripts.UI.CarouselItem");
local CarouselGroup = requirePack("appscripts.UI.CarouselGroup");


local BaseView = requirePack("appscripts.MVC.Base.BaseView");


local ChrismasView = class("ChrismasView",function() 
    return BaseView.new();
end);
g_tConfigTable.CREATE_NEW(ChrismasView);

function ChrismasView:ctor()
    -- 定义所有使用过的成员在这里..
    self.spBg_ = nil ;                    -- 背景图
    self.processBar_ = nil;               -- 进度条

    self.btnNext_ = nil;                  -- 下一步按钮
    
end

--[[
    方法 定义界面初始化
    包括:
        创建所有需要的显示对象 
        注册所有要使用的UI事件
]]--
function ChrismasView:Init()


    self.spBg_ = SpriteUtil.Create( PathsUtil.ImagePath("bg.png"));
    self:addChild(self.spBg_);
    self.spBg_:setPosition(cc.p(768/2,1024/2));
    self.spBg_:setScale(1);

    self.backBtn_ = ButtonUtil.Create(
        PathsUtil.ImagePath("gui_next_icon.png"), 
        PathsUtil.ImagePath("gui_next_icon.png"),
        function()
            print("backbtn..."); 
        end
    );
    self:addChild(self.backBtn_);
    self.backBtn_:setPosition(cc.p(30,1024-30));

    self.processBar_ = StickerProcessBar.new();
    self.processBar_:Init(
        PathsUtil.ImagePath("gui_granule.png"),
        PathsUtil.ImagePath("gui_granule_bg.png"),
        PathsUtil.ImagePath("gui_progress_bg.png"),
        1,
        4,
        12,
        0
    );
    self:addChild(self.processBar_);
    self.processBar_:setPosition(SpriteUtil.ToCocosPoint(131,203));--SpriteUtil.ToCocosPoint(131,7)

    local spStarIconBg = SpriteUtil.Create( PathsUtil.ImagePath("gui_acquire_icon_bg.png"));
    local spStarIcon = SpriteUtil.Create( PathsUtil.ImagePath("gui_acquire_icon.png"));
    self:addChild(spStarIconBg);
    self:addChild(spStarIcon);
    spStarIconBg:setPosition(SpriteUtil.ToCocosPoint(380,203));
    spStarIcon:setPosition(SpriteUtil.ToCocosPoint(380,203));

    self.btnNext_ =  ccui.Button:create( 
        PathsUtil.ImagePath("gui_next_icon.png"), 
        PathsUtil.ImagePath("gui_next_icon.png"));
    self.btnNext_:setScale(0.42);--debug
    self:addChild(self.btnNext_,100001);
    self.btnNext_:setPosition(SpriteUtil.ToCocosPoint(375,723));
    self.btnNext_:addClickEventListener(function()	
        -- todo on user click next
        print("self.btnNext_ next");	
    end)
    
    self.carouselBg_ = SpriteUtil.Create(PathsUtil.ImagePath("gui_UI_bg.png"));
    self.carouselBg_:setPosition(SpriteUtil.ToCocosPoint(375,1000));
    self:addChild(self.carouselBg_);
    local ccc = SpriteUtil.GetContentSize(self.carouselBg_ );
    print("ccc:" .. ccc.width .. "height:" .. ccc.height);


    --[[]]--
    self.carouselGroup_ = CarouselGroup.new();
    self.carouselGroup_:SetOffset(2);
    self.carouselGroup_:SetSpacing(30);
    self.carouselGroup_:SetItemSize(cc.size(160,160));
    self.carouselGroup_:SetSpeed(100);
    self.carouselGroup_:SetCreateItemCallBack(function(d)
        local item = CarouselItem.new();
        item:SetData(d)
        item:Init(
            PathsUtil.ImagePath("gui_default.png"),
            PathsUtil.ImagePath("gui_select01.png"),
            PathsUtil.ImagePath(d.iconName),
            PathsUtil.ImagePath("gui_vip_icon.png"),
            PathsUtil.ImagePath("gui_needover.png")
        );
        
        return item;
    end);
    self:addChild(self.carouselGroup_);
    self.carouselGroup_:setPosition(cc.p(0,80));
    self.carouselGroup_:Update(
        {
            {iconName = "gui_heka01_vip.png"},
            {iconName = "gui_heka02.png"},
            {iconName = "gui_heka03.png"},
            {iconName = "gui_heka04.png"},
        }
    );
    self.carouselGroup_:startMove();
    self.carouselGroup_:SetOnUserSelectItemCallBack(function(item)
        print("item click");
        dump(self:GetData());
    end);

end

--[[
    方法 撤销界面       
    包括:
        删除所有持有的显示对象 
        注销所有持有的UI事件
]]--
function ChrismasView:Dispose()

end

return ChrismasView;


    --[[
    local item = CarouselItem.new();
    item:Init(
        PathsUtil.ImagePath("gui_default.png"),
        PathsUtil.ImagePath("gui_select01.png"),
        PathsUtil.ImagePath("gui_heka01_vip.png"),
        PathsUtil.ImagePath("gui_vip_icon.png"),
        PathsUtil.ImagePath("gui_needover.png"));
    self:addChild(item);
    item:setPosition(cc.p(200,200));]]--