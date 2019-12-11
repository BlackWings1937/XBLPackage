local SelectItem = class("SelectItem",function()
    return cc.Node:create(); 
end);

g_tConfigTable.CREATE_NEW(SelectItem);

function SelectItem:ctor()
    self.parent_ = nil;
end

function SelectItem:Selected()

end

function SelectItem:UnSelect()

end


function SelectItem:setGroup(v)
    self.parent_ = v;
end

function SelectItem:getGroup()
    return self.parent_;
end




return SelectItem;