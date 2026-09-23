require "prefabutil"
local __bu__g = {
    proximity_loop = "",
    door_open = "dontstarve/quagmire/common/safe/open",
    door_close = "wintersfeast2019/winters_feast/oven/start",
    cooking_loop = "wintersfeast2019/winters_feast/oven/LP",
    finish = "wintersfeast2019/winters_feast/oven/done",
    picked = "dontstarve/quagmire/common/cooking/dish_place",
    hit = "dontstarve/wilson/hit_metal",
    place = "wintersfeast2019/winters_feast/table/place"
}
local function __b_U__G_(b__u__g)
    if b__u__g["_firefx"] ~= nil then
        b__u__g["_firefx"]:Remove()
        b__u__g["_firefx"] = nil
    end
end
local function __b__U__g_(__B_u_G)
    __b_U__G_(__B_u_G)
    __B_u_G["_firefx"] = SpawnPrefab "wintersfeastoven_fire"
    __B_u_G["_firefx"]["entity"]:SetParent(__B_u_G["entity"])
end
local function B__u__g_(bU_G, __bU__G_)
    bU_G["Light"]:Enable(__bU__G_ or (191 + 144 + 381 + 169 + 71 == 958))
end
local function __B__U_g__(__bUG)
    if
        not __bUG:HasTag "burnt" and not __bUG["AnimState"]:IsCurrentAnimation "idle" and
            not __bUG["AnimState"]:IsCurrentAnimation "idle"
     then
        if __bUG["AnimState"]:IsCurrentAnimation "idle" then
            __bUG["AnimState"]:PushAnimation("idle", true)
            __bUG:DoTaskInTime(
                __bUG["AnimState"]:GetCurrentAnimationLength() - __bUG["AnimState"]:GetCurrentAnimationTime(),
                function(__bUG)
                    __bUG["SoundEmitter"]:PlaySound(__bu__g["door_open"])
                end
            )
        elseif __bUG["AnimState"]:IsCurrentAnimation "hit_door_closed" or __bUG["AnimState"]:IsCurrentAnimation "place" then
            __bUG["AnimState"]:PushAnimation("idle", true)
            __bUG["AnimState"]:PushAnimation("idle", true)
            __bUG:DoTaskInTime(
                math["max"](
                    0,
                    __bUG["AnimState"]:GetCurrentAnimationLength() - __bUG["AnimState"]:GetCurrentAnimationTime()
                ),
                function(__bUG)
                    __bUG["SoundEmitter"]:PlaySound(__bu__g["door_open"])
                end
            )
        else
            __bUG["AnimState"]:PlayAnimation "idle"
            __bUG["AnimState"]:PushAnimation("idle", true)
            __bUG["SoundEmitter"]:PlaySound(__bu__g["door_open"])
        end
        __bUG["SoundEmitter"]:KillSound "cooking_loop"
        __bUG["SoundEmitter"]:PlaySound(__bu__g["proximity_loop"], "cooking_loop")
    end
end
local function __bu_G_(_b_u_G_)
    if not _b_u_G_:HasTag "burnt" then
        _b_u_G_["AnimState"]:PushAnimation("idle", true)
        _b_u_G_["AnimState"]:PushAnimation("idle", true)
        _b_u_G_["SoundEmitter"]:KillSound "cooking_loop"
        _b_u_G_:DoTaskInTime(
            math["max"](
                0,
                _b_u_G_["AnimState"]:GetCurrentAnimationLength() - _b_u_G_["AnimState"]:GetCurrentAnimationTime()
            ),
            function(_b_u_G_)
                _b_u_G_["SoundEmitter"]:PlaySound(__bu__g["door_close"])
            end
        )
    end
end
local function __BU__G(buG, b__U_G_)
    if
        buG["components"]["pickable"] and buG["components"]["pickable"]["caninteractwith"] and
            buG["components"]["pickable"]["product"]
     then
        buG["components"]["lootdropper"]:SetLoot({buG["components"]["pickable"]["product"]})
    end
    buG["components"]["lootdropper"]:DropLoot()
    local BU_G__ = SpawnPrefab "collapse_small"
    BU_G__["Transform"]:SetPosition(buG["Transform"]:GetWorldPosition())
    BU_G__:SetMaterial "metal"
    buG:Remove()
end
local function bU_G_(__b__u__g_, __Bu_G__)
    if not __b__u__g_["AnimState"]:IsCurrentAnimation "cook_done" then
        if __b__u__g_["components"]["pickable"] ~= nil and __b__u__g_["components"]["pickable"]["caninteractwith"] then
            __b__u__g_["AnimState"]:PlayAnimation "idle"
            __b__u__g_["AnimState"]:PushAnimation("idle", true)
            __b__u__g_["SoundEmitter"]:PlaySound(__bu__g["hit"])
        elseif __b__u__g_["components"]["prototyper"] ~= nil and __b__u__g_["components"]["prototyper"]["on"] then
            __b__u__g_["AnimState"]:PlayAnimation "idle"
            __b__u__g_["AnimState"]:PushAnimation("idle", true)
            __b__u__g_["SoundEmitter"]:PlaySound(__bu__g["hit"])
        elseif
            __b__u__g_["components"]["madsciencelab"] == nil or
                not __b__u__g_["components"]["madsciencelab"]:IsMakingScience()
         then
            __b__u__g_["AnimState"]:PlayAnimation "idle"
            __b__u__g_["AnimState"]:PushAnimation("idle", true)
            __b__u__g_["SoundEmitter"]:PlaySound(__bu__g["hit"])
        end
    end
end
local function B_ug(_b_Ug)
    if _b_Ug and _b_Ug["components"]["container"] == nil then
        return nil
    end
    local __b_ug__ = _b_Ug["components"]["container"]
    local _BUG_ = __b_ug__:GetItemInSlot(1)
    local bU__G_ = {}
    if _BUG_ == nil then
        return bU__G_
    end
    local __B__u_g__ = _BUG_["components"]["wb_strengthen"]
    if __B__u_g__ == nil then
        return bU__G_
    end
    bU__G_["name"] = __B__u_g__["original_name"] or _BUG_["name"]
    bU__G_["do_mode"] = "strengthen"
    bU__G_["item_id"] = tostring(_BUG_.Network:GetNetworkID())
    local is_hh_daogam6 = _BUG_["prefab"] == "hh_daogam6"
    local source_morph = is_hh_daogam6 and _BUG_["components"]["hh_morphweapon"] or nil
    bU__G_["level"] = __B__u_g__["level"]
    bU__G_["isweapon"] = _BUG_:HasTag "weapon"
    bU__G_["isarmor"] = _BUG_:HasTag "armor"
    bU__G_["c_level"] = __B__u_g__["level"]
    bU__G_["c_damage"] =
        ((__B__u_g__["buffs_status"]["damage"] and __B__u_g__["buffs_status"]["damage"]["level_damage"]) or 0)
    if is_hh_daogam6 then
        bU__G_["c_damage"] = (_BUG_["components"]["weapon"] and _BUG_["components"]["weapon"]["damage"]) or 0
    end
    bU__G_["c_absorb_percent"] =
        ((__B__u_g__["buffs_status"]["absorb_percent"] and
        __B__u_g__["buffs_status"]["absorb_percent"]["level_absorb_percent"]) or
        0)
    -- Unenhanced items have no strengthening buff yet; preview their base stats.
    if __B__u_g__.level == 0 then
        local weapon, armor = _BUG_.components.weapon, _BUG_.components.armor
        if weapon and type(weapon.damage) == "number" then bU__G_.c_damage = weapon.damage end
        if armor then bU__G_.c_absorb_percent = armor.absorb_percent end
    end
    bU__G_["c_prizebuff_count"] = #__B__u_g__["prize_buff_list"]
    local _Bug = SpawnPrefab(_BUG_["prefab"])
    if is_hh_daogam6 and source_morph and _Bug["components"]["hh_morphweapon"] then
        _Bug["components"]["hh_morphweapon"]:SetMode(source_morph["current_mode"])
    end
    local __B__u__G__ = _Bug["components"]["wb_strengthen"]
    __B__u__G__["do_mode"] = "strengthen"
    __B__u__G__:SetLevel(__B__u_g__["level"] + 1)
    bU__G_["n_level"] = __B__u__G__["level"]
    bU__G_["n_damage"] =
        ((__B__u__G__["buffs_status"]["damage"] and __B__u__G__["buffs_status"]["damage"]["level_damage"]) or 0)
    if is_hh_daogam6 then
        bU__G_["n_damage"] = (_Bug["components"]["weapon"] and _Bug["components"]["weapon"]["damage"]) or 0
    end
    bU__G_["n_absorb_percent"] =
        ((__B__u__G__["buffs_status"]["absorb_percent"] and
        __B__u__G__["buffs_status"]["absorb_percent"]["level_absorb_percent"]) or
        0)
    bU__G_["n_prizebuff_count"] = #__B__u__G__["prize_buff_list"]
    if _b_Ug["components"]["container"]["opencount"] == 1 then
        for b__U__G_, __b__U_g__ in pairs(_b_Ug["components"]["container"]["openlist"]) do
            bU__G_["probability"] = __B__u_g__:GetProbability(b__U__G_, "strengthen", __B__u_g__["level"] + 1)
            if bU__G_["do_mode"] == "strengthen" then
                local __b__U_G, __b_Ug_ = b__U__G_["components"]["inventory"]:Has("wb_enhancegem", 1)
                bU__G_["redgem_count"] = __b_Ug_ or 0
                bU__G_.has_protection = b__U__G_.components.inventory:Has("wb_strengthen_strengthen_protectpaper", 1)
                bU__G_.has_magic = b__U__G_.components.inventory:Has("nn_magicpaper", 1)
            end
        end
    end
    _Bug:Remove()
    _Bug = nil
    return bU__G_
end
local function __B__UG(__BUG__)
    local BU__g_ = B_ug(__BUG__)
    __BUG__._strengthen_revision = (__BUG__._strengthen_revision or 0) + 1
    BU__g_.revision = __BUG__._strengthen_revision
    local __b_U_G, _b_uG = pcall(json["encode"], BU__g_)
    if __b_U_G then
        __BUG__["_container_data"]:set(_b_uG)
        if TheWorld["ismastersim"] then
            __BUG__:PushEvent "watch_container_data"
        end
    end
end
local _b_u__G = {}
local function _b_ug_()
    local B__u__G = CreateEntity()
    B__u__G["a"] = 1
    B__u__G["_container_data"] =
        net_string(B__u__G["GUID"], "hh_lo_ren._container_data", "watch_container_data")
    B__u__G["entity"]:AddTransform()
    B__u__G["entity"]:AddAnimState()
    B__u__G["entity"]:AddSoundEmitter()
    B__u__G["entity"]:AddMiniMapEntity()
    B__u__G["entity"]:AddLight()
    B__u__G["entity"]:AddNetwork()
    B__u__G["MiniMapEntity"]:SetIcon "lo_ren.tex"
    B__u__G:AddTag "structure"
    MakeObstaclePhysics(B__u__G, 0.8, 1.2)
    B__u__G["Light"]:Enable(
        (false and true or not false and not false and not true and not false and false and false and false and false or
            not false and false and true)
    )
    B__u__G["Light"]:SetRadius(2)
    B__u__G["Light"]:SetFalloff(1.5)
    B__u__G["Light"]:SetIntensity(.5)
    B__u__G["Light"]:SetColour(80 / 255, 180 / 255, 1)
    B__u__G["AnimState"]:SetBank "lo_ren"
    B__u__G["AnimState"]:SetBuild "lo_ren"
    B__u__G["AnimState"]:PlayAnimation("idle", (344 + 440 + 144 ~= 936))
    B__u__G["AnimState"]:SetFinalOffset(1)
    MakeSnowCoveredPristine(B__u__G)
    B__u__G["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return B__u__G
    end
    require("utils/hh_lam_phuong_visuals").Install(B__u__G)
    B__u__G:AddComponent "inspectable"
    B__u__G:AddComponent "container"
    B__u__G["components"]["container"]:WidgetSetup "hh_lo_ren"
    B__u__G["components"]["container"]["onopenfn"] = __B__U_g__
    B__u__G["components"]["container"]["onclosefn"] = __bu_G_
    B__u__G["components"]["container"]["skipclosesnd"] = (485 + 198 - 386 * 365 == -140207)
    B__u__G["components"]["container"]["skipopensnd"] =
        (false or false and true or not false and true and not false and not false or not true or
        not false and false and not false and true and not false)
    B__u__G:AddComponent "lootdropper"
    B__u__G:AddComponent "workable"
    B__u__G["components"]["workable"]:SetWorkAction(ACTIONS["HAMMER"])
    B__u__G["components"]["workable"]:SetWorkLeft(4)
    B__u__G["components"]["workable"]:SetOnWorkCallback(bU_G_)
    B__u__G["components"]["workable"]:SetOnFinishCallback(__BU__G)
    B__u__G:AddComponent "hauntable"
    B__u__G["components"]["hauntable"]:SetHauntValue(TUNING["HAUNT_TINY"])
    MakeSnowCovered(B__u__G)
    __B__UG(B__u__G)
    B__u__G["UpdateContainerData"] = function()
        return __B__UG(B__u__G)
    end
    B__u__G:ListenForEvent("itemget", B__u__G["UpdateContainerData"])
    B__u__G:ListenForEvent("itemlose", B__u__G["UpdateContainerData"])
    B__u__G:ListenForEvent(
        "onopen",
        function(B__u__G, b__U_g_)
            if B__u__G["UpdateContainerData"] then
                B__u__G["UpdateContainerData"](B__u__G)
                b__U_g_["doer"]:ListenForEvent("itemget", B__u__G["UpdateContainerData"])
                b__U_g_["doer"]:ListenForEvent("itemlose", B__u__G["UpdateContainerData"])
            end
        end
    )
    B__u__G:ListenForEvent(
        "onclose",
        function(B__u__G, __b_u_G_)
            if B__u__G["UpdateContainerData"] then
                __b_u_G_["doer"]:RemoveEventCallback("itemget", B__u__G["UpdateContainerData"])
                __b_u_G_["doer"]:RemoveEventCallback("itemlose", B__u__G["UpdateContainerData"])
            end
        end
    )
    if TUNING["PROTOTYPER_TREES"]["hh_lo_ren_ONE"] then
        B__u__G:AddComponent "prototyper"
        B__u__G["components"]["prototyper"]["trees"] = TUNING["PROTOTYPER_TREES"]["hh_lo_ren_ONE"]
    end
    return B__u__G
end

RegisterInventoryItemAtlas("images/lo_ren.xml", "lo_ren.tex")

return Prefab(
    "hh_lo_ren",
    _b_ug_,
    {Asset("ANIM", "anim/lo_ren.zip")},
    {"wintersfeastoven_fire", "collapse_small"}
), MakePlacer("hh_lo_ren_placer", "lo_ren", "lo_ren", "idle")
