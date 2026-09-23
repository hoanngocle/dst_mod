local B__u_G = {
    {
        prefab = "nn_liquidluck",
        name = "Phúc Lạc Dược I",
        assets = {
            Asset("ANIM", "anim/hh_phuc_lac_duoc.zip"),
            Asset("IMAGE", "images/phuc_lac_duoc_inventory.tex"),
        },
        atlas = "images/phuc_lac_duoc_inventory.xml",
        image = "phuc_lac_duoc_1_inventory",
        bank = "hh_phuc_lac_duoc",
        build = "hh_phuc_lac_duoc",
        play_animation = "idle_phuc_lac_duoc_1",
        tags = {},
        maxsize = 1,
        foodtype = FOODTYPE["GOODIES"],
        hungervalue = 0,
        sanityvalue = 5,
        healthvalue = 0,
        oneaten = function(__B__u_g_, _b__U__G__)
            if _b__U__G__ and _b__U__G__["components"]["talker"] then
                _b__U__G__["components"]["talker"]:Say "Felix Felicis huh? Excellent!"
            end
        end,
        buff_id = "nn_liquidluck_buff",
        buff_duration = 30,
        buff_onattach = function(Bug__, __buG__)
            Bug__["wb_strengthen_probability"] = 0.05
        end,
        buff_onextend = function(_B__u_G__, __b__ug)
            _B__u_G__["components"]["timer"]:StopTimer "regenover"
            _B__u_G__["components"]["timer"]:StartTimer("regenover", _B__u_G__["param"]["buff_duration"])
        end,
        buff_ondetach = function(_bU_g, __B__ug_)
            _bU_g["wb_strengthen_probability"] = 0
        end
    },
    {
        prefab = "nn_liquidluck_2",
        name = "Phúc Lạc Dược II",
        assets = {
            Asset("ANIM", "anim/hh_phuc_lac_duoc.zip"),
            Asset("IMAGE", "images/phuc_lac_duoc_inventory.tex"),
        },
        atlas = "images/phuc_lac_duoc_inventory.xml",
        image = "phuc_lac_duoc_2_inventory",
        bank = "hh_phuc_lac_duoc",
        build = "hh_phuc_lac_duoc",
        play_animation = "idle_phuc_lac_duoc_2",
        tags = {},
        maxsize = 1,
        foodtype = FOODTYPE["GOODIES"],
        hungervalue = 0,
        sanityvalue = 15,
        healthvalue = 0,
        oneaten = function(__bu__g, __b_U__G_)
            if __b_U__G_ and __b_U__G_["components"]["talker"] then
                __b_U__G_["components"]["talker"]:Say "Felix Felicis huh? Excellent!"
            end
        end,
        buff_id = "nn_liquidluck_2_buff",
        buff_duration = 90,
        buff_onattach = function(__b__U__g_, B__u__g_)
            __b__U__g_["wb_strengthen_probability"] = 0.15
        end,
        buff_onextend = function(__B__U_g__, __bu_G_)
            __B__U_g__["components"]["timer"]:StopTimer "regenover"
            __B__U_g__["components"]["timer"]:StartTimer("regenover", __B__U_g__["param"]["buff_duration"])
        end,
        buff_ondetach = function(__BU__G, bU_G_)
            __BU__G["wb_strengthen_probability"] = 0
        end
    },
    {
        prefab = "nn_liquidluck_3",
        name = "Phúc Lạc Dược III",
        assets = {
            Asset("ANIM", "anim/hh_phuc_lac_duoc.zip"),
            Asset("IMAGE", "images/phuc_lac_duoc_inventory.tex"),
        },
        atlas = "images/phuc_lac_duoc_inventory.xml",
        image = "phuc_lac_duoc_3_inventory",
        bank = "hh_phuc_lac_duoc",
        build = "hh_phuc_lac_duoc",
        play_animation = "idle_phuc_lac_duoc_3",
        tags = {},
        maxsize = 1,
        foodtype = FOODTYPE["GOODIES"],
        hungervalue = 0,
        sanityvalue = 25,
        healthvalue = 0,
        oneaten = function(__bu__g, __b_U__G_)
            if __b_U__G_ and __b_U__G_["components"]["talker"] then
                __b_U__G_["components"]["talker"]:Say "Felix Felicis huh? Excellent!"
            end
        end,
        buff_id = "nn_liquidluck_3_buff",
        buff_duration = 270,
        buff_onattach = function(__b__U__g_, B__u__g_)
            __b__U__g_["wb_strengthen_probability"] = 0.25
        end,
        buff_onextend = function(__B__U_g__, __bu_G_)
            __B__U_g__["components"]["timer"]:StopTimer "regenover"
            __B__U_g__["components"]["timer"]:StartTimer("regenover", __B__U_g__["param"]["buff_duration"])
        end,
        buff_ondetach = function(__BU__G, bU_G_)
            __BU__G["wb_strengthen_probability"] = 0
        end
    }
}
for B_ug, __B__UG in ipairs(B__u_G) do
    if __B__UG["atlas"] == nil then
        __B__UG["atlas"] = "images/" .. __B__UG["bank"] .. ".xml"
    end
    if __B__UG["image"] == nil then
        __B__UG["image"] = __B__UG["bank"]
    end
end
function MakeFood(_b_u__G, _b_ug_)
    STRINGS["NAMES"][string["upper"](_b_u__G)] = _b_ug_["name"]
    local b__u__g = {}
    if _b_ug_["assets"] then
        for bU_G, __bU__G_ in ipairs(_b_ug_["assets"]) do
            table["insert"](b__u__g, __bU__G_)
        end
    end
    if _b_ug_["atlas"] then
        table["insert"](b__u__g, Asset("ATLAS", _b_ug_["atlas"]))
    end
    local function __B_u_G()
        local __bUG = CreateEntity()
        __bUG["entity"]:AddTransform()
        __bUG["entity"]:AddAnimState()
        __bUG["entity"]:AddSoundEmitter()
        __bUG["entity"]:AddNetwork()
        MakeInventoryPhysics(__bUG)
        __bUG["AnimState"]:SetBank(_b_ug_["bank"])
        __bUG["AnimState"]:SetBuild(_b_ug_["build"])
        __bUG["AnimState"]:PlayAnimation(_b_ug_["play_animation"])
        for _b_u_G_, buG in ipairs(_b_ug_["tags"]) do
            __bUG:AddTag(buG)
        end
        MakeInventoryFloatable(__bUG)
        __bUG["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return __bUG
        end
        __bUG:AddComponent "edible"
        __bUG["components"]["edible"]["foodtype"] = FOODTYPE["GOODIES"]
        __bUG["components"]["edible"]["hungervalue"] = _b_ug_["hungervalue"] or 0
        __bUG["components"]["edible"]["sanityvalue"] = _b_ug_["sanityvalue"] or 0
        __bUG["components"]["edible"]["healthvalue"] = _b_ug_["healthvalue"] or 0
        if _b_ug_["buff_id"] and _b_ug_["buff_duration"] > 1 then
            __bUG["components"]["edible"]["oneaten"] = function(__bUG, b__U_G_)
                if _b_ug_["oneaten"] then
                    _b_ug_["oneaten"](__bUG, b__U_G_)
                end
                if
                    b__U_G_["components"]["debuffable"] ~= nil and b__U_G_["components"]["debuffable"]:IsEnabled() and
                        not (b__U_G_["components"]["health"] ~= nil and b__U_G_["components"]["health"]:IsDead()) and
                        not b__U_G_:HasTag "playerghost"
                 then
                    b__U_G_["components"]["debuffable"]:AddDebuff(_b_ug_["buff_id"], _b_ug_["buff_id"])
                end
            end
        end
        __bUG:AddComponent "tradable"
        __bUG:AddComponent "inspectable"
        __bUG:AddComponent "inventoryitem"
        __bUG["components"]["inventoryitem"]["imagename"] = _b_ug_["image"]
        __bUG["components"]["inventoryitem"]["atlasname"] = _b_ug_["atlas"]
        if _b_ug_["maxsize"] ~= 1 then
            __bUG:AddComponent "stackable"
            __bUG["components"]["stackable"]["maxsize"] = _b_ug_["maxsize"] or TUNING["STACK_SIZE_LARGEITEM"]
        end
        MakeHauntableLaunch(__bUG)
        return __bUG
    end
    return Prefab(_b_u__G, __B_u_G, b__u__g)
end
function MakeFoodBuff(BU_G__, __b__u__g_)
    local function __Bu_G__()
        local _b_Ug = CreateEntity()
        _b_Ug["entity"]:AddTransform()
        _b_Ug["entity"]:AddNetwork()
        _b_Ug:AddTag "CLASSIFIED"
        _b_Ug:AddTag "NOCLICK"
        _b_Ug:AddTag "NOBLOCK"
        _b_Ug["param"] = __b__u__g_
        _b_Ug["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return _b_Ug
        end
        _b_Ug["persists"] = (239 - 381 - 486 + 286 * 136 == 38273)
        _b_Ug:AddComponent "debuff"
        _b_Ug["components"]["debuff"]:SetAttachedFn(
            function(_b_Ug, __b_ug__, ...)
                __b__u__g_["buff_onattach"](_b_Ug, __b_ug__, ...)
                return __b_ug__:AddChild(_b_Ug)
            end
        )
        _b_Ug["components"]["debuff"]:SetDetachedFn(
            function(_b_Ug, _BUG_, ...)
                __b__u__g_["buff_ondetach"](_b_Ug, _BUG_, ...)
                return _b_Ug:Remove()
            end
        )
        _b_Ug["components"]["debuff"]:SetExtendedFn(__b__u__g_["buff_onextend"])
        _b_Ug["components"]["debuff"]["keepondespawn"] = (26 - 489 - 98 - 308 == -869)
        _b_Ug:AddComponent "timer"
        _b_Ug["components"]["timer"]:StartTimer("buffover", __b__u__g_["buff_duration"])
        _b_Ug:ListenForEvent(
            "timerdone",
            function(_b_Ug, bU__G_)
                if bU__G_["name"] == "buffover" then
                    _b_Ug["components"]["debuff"]:Stop()
                end
            end
        )
        _b_Ug:Hide()
        return _b_Ug
    end
    return Prefab(BU_G__, __Bu_G__)
end
local __b__ug__ = {}
for __B__u_g__, _Bug in ipairs(B__u_G) do
    table["insert"](__b__ug__, MakeFood(_Bug["prefab"], _Bug))
    if _Bug["buff_id"] then
        table["insert"](__b__ug__, MakeFoodBuff(_Bug["buff_id"], _Bug))
    end
end
return unpack(__b__ug__)
