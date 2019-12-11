
local SpriteUtil = {}

SpriteUtil.scaleAdapt_ = 1;

SpriteUtil.SetScaleAdapt = function(v)
    SpriteUtil.scaleAdapt_ = v;
end

SpriteUtil.Create = function(p)
    local sp = cc.Sprite:create(p);
    sp:setScale(SpriteUtil.scaleAdapt_);
    return sp;
end

SpriteUtil.GetContentSize = function(sp)
    local scale = sp:getScale();
    local contentSize = sp:getContentSize();
    return cc.size(contentSize.width*scale,contentSize.height*scale);
end

SpriteUtil.contentSize_ = cc.p(0,0)
SpriteUtil.SetContentSize = function(v)
    SpriteUtil.contentSize_ = v;
end

SpriteUtil.ToCocosPoint = function(x,y) 
    local v = cc.p(x,y);
    v.y = SpriteUtil.contentSize_.height - v.y;
    return v;
end

SpriteUtil.ToFlashPoint = function(x,y)
    local v = cc.p(x,y);
    v.y = SpriteUtil.contentSize_.height - v.y;
    return v;
end



return SpriteUtil;