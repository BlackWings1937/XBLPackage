local JsonScriptConfig = {}

JsonScriptConfig.XBL_WELLCOME = "Xmas015";                                   -- 小伴龙欢迎 json

JsonScriptConfig.FIRST_CLICK_ACTIVITY_BTN = "Xmas014";                       -- 首次点击活动按钮
JsonScriptConfig.FIRST_ENTER_PRE_VIEW     = "Xmas015";                       -- 首次进入预热界面
JsonScriptConfig.CLICK_XBL = "Xmas054";                                      -- 点击小伴龙反馈
JsonScriptConfig.XBL_AUTO_LEAVE = "Xmas051"                                  -- 用户无操作自动离开前小伴龙说的话
JsonScriptConfig.XBL_NEXT_DAY_CAN_GET = "Xmas053";                           -- 小伴龙提示第二天才能领取

JsonScriptConfig.GET_GIFT_OP_JSON = "Xmas055"                                -- 当天已经解锁了的状态
JsonScriptConfig.UNLOCK_OP_JSON = {                                          -- 当天未解锁的op
    "Xmas016", 
    "Xmas021",
    "Xmas026",
    "Xmas031",
    "Xmas036",
    "Xmas041",
    "Xmas046",
}

JsonScriptConfig.GET_GIFTS_JSON = {                                          -- 获取礼物的 json 动画
    "Xmas017",
    "Xmas023",
    "Xmas028",
    "Xmas033",
    "Xmas038",
    "Xmas043",
    "Xmas048",
}

JsonScriptConfig.SHOW_GIFTS_JSON = {                                         -- 展示礼物的 json 动画
    "Xmas018",
    "Xmas024",
    "Xmas029",
    "Xmas034",
    "Xmas039",
    "Xmas044",
    "Xmas049",
}

JsonScriptConfig.DECORATION_GIFTS_JSON = {                                   -- 装饰礼物的 json 动画
    "Xmas018a",
    "Xmas024a",
    "Xmas029a",
    "Xmas034a",
    "Xmas039a",
    "Xmas044a",
    "Xmas049a",
}


JsonScriptConfig.PLAY_GIFTS_JSON = {                                         -- 玩礼物的 json 动画
    "Xmas019",
    "Xmas025",
    "Xmas030",
    "Xmas035",
    "Xmas040",
    "Xmas045",
    "Xmas050",
}

return JsonScriptConfig;