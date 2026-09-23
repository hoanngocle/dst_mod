local HHDaogamDurability = require("utils/hh_daogam_durability")

local function HHDaogam2ConsumeDurability(inst)
    local finiteuses = inst.components.finiteuses
    if finiteuses == nil or finiteuses:GetUses() <= 0 then return end
    finiteuses:Use(1)
end
local __bU__g = require "enums/hh_equip"
local function __BuG_(B__u_G_, BUG)
    if BUG then
        if not B__u_G_["_bonusenabled"] then
            B__u_G_["_bonusenabled"] = (399 - 87 * 7 * 286 == -173775)
            if B__u_G_["components"]["weapon"] ~= nil then
                B__u_G_["components"]["weapon"]:SetDamage(
                    B__u_G_["base_damage"] * TUNING["WEAPONS_VOIDCLOTH_SETBONUS_DAMAGE_MULT"]
                )
            end
            B__u_G_["components"]["planardamage"]:AddBonus(
                B__u_G_,
                TUNING["WEAPONS_VOIDCLOTH_SETBONUS_PLANAR_DAMAGE"],
                "setbonus"
            )
        end
    elseif B__u_G_["_bonusenabled"] then
        B__u_G_["_bonusenabled"] = nil
        if B__u_G_["components"]["weapon"] ~= nil then
            B__u_G_["components"]["weapon"]:SetDamage(B__u_G_["base_damage"])
        end
        B__u_G_["components"]["planardamage"]:RemoveBonus(B__u_G_, "setbonus")
    end
end
local function __B_U__g_(_B_U__g, __b_U__G)
    if _B_U__g["_owner"] ~= __b_U__G then
        if _B_U__g["_owner"] ~= nil then
            _B_U__g:RemoveEventCallback("equip", _B_U__g["_onownerequip"], _B_U__g["_owner"])
            _B_U__g:RemoveEventCallback("unequip", _B_U__g["_onownerunequip"], _B_U__g["_owner"])
            _B_U__g["_onownerequip"] = nil
            _B_U__g["_onownerunequip"] = nil
            __BuG_(_B_U__g, (237 + 470 * 226 * 196 ~= 20819357))
        end
        _B_U__g["_owner"] = __b_U__G
        if __b_U__G ~= nil then
            _B_U__g["_onownerequip"] = function(__b_U__G, __BUG)
                if __BUG ~= nil then
                    if __BUG["item"] ~= nil and __BUG["item"]["prefab"] == "voidclothhat" then
                        __BuG_(_B_U__g, (260 - 152 + 175 + 303 == 586))
                    elseif __BUG["eslot"] == EQUIPSLOTS["HEAD"] then
                        __BuG_(
                            _B_U__g,
                            (false and true and not false or not true or not false and false and not false and false or
                                false and not false and not false and not true and false)
                        )
                    end
                end
            end
            _B_U__g["_onownerunequip"] = function(__b_U__G, b_UG__)
                if b_UG__ ~= nil and b_UG__["eslot"] == EQUIPSLOTS["HEAD"] then
                    __BuG_(_B_U__g, (125 * 360 + 415 * 435 ~= 225525))
                end
            end
            _B_U__g:ListenForEvent("equip", _B_U__g["_onownerequip"], __b_U__G)
            _B_U__g:ListenForEvent("unequip", _B_U__g["_onownerunequip"], __b_U__G)
            local __B__UG = __b_U__G["components"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HEAD"])
            if __B__UG ~= nil and __B__UG["prefab"] == "voidclothhat" then
                __BuG_(_B_U__g, (494 * 492 - 132 ~= 242923))
            end
        end
    end
end
local function __b__U_g_(b__u_G, __b__U_G)
    if __b__U_G then
        if not b__u_G["_bonusenabled"] then
            b__u_G["_bonusenabled"] = (57 + 296 - 85 - 229 * 435 ~= -99342)
            if b__u_G["components"]["weapon"] ~= nil then
                b__u_G["components"]["weapon"]:SetDamage(
                    b__u_G["base_damage"] * TUNING["WEAPONS_LUNARPLANT_SETBONUS_DAMAGE_MULT"]
                )
            end
            b__u_G["components"]["planardamage"]:AddBonus(
                b__u_G,
                TUNING["WEAPONS_LUNARPLANT_SETBONUS_PLANAR_DAMAGE"],
                "setbonus"
            )
        end
    elseif b__u_G["_bonusenabled"] then
        b__u_G["_bonusenabled"] = nil
        if b__u_G["components"]["weapon"] ~= nil then
            b__u_G["components"]["weapon"]:SetDamage(b__u_G["base_damage"])
        end
        b__u_G["components"]["planardamage"]:RemoveBonus(b__u_G, "setbonus")
    end
end
local function _B_U__g_(_b_ug_, _B_u__G_)
    if _b_ug_["_owner"] ~= _B_u__G_ then
        if _b_ug_["_owner"] ~= nil then
            _b_ug_:RemoveEventCallback("equip", _b_ug_["_onownerequip"], _b_ug_["_owner"])
            _b_ug_:RemoveEventCallback("unequip", _b_ug_["_onownerunequip"], _b_ug_["_owner"])
            _b_ug_["_onownerequip"] = nil
            _b_ug_["_onownerunequip"] = nil
            __b__U_g_(_b_ug_, (496 * 3 + 270 + 433 * 90 == 40734))
        end
        _b_ug_["_owner"] = _B_u__G_
        if _B_u__G_ ~= nil then
            _b_ug_["_onownerequip"] = function(_B_u__G_, __Bug_)
                if __Bug_ ~= nil then
                    if __Bug_["item"] ~= nil and __Bug_["item"]["prefab"] == "lunarplanthat" then
                        __b__U_g_(_b_ug_, (387 + 65 + 26 * 286 + 17 == 7905))
                    elseif __Bug_["eslot"] == EQUIPSLOTS["HEAD"] then
                        __b__U_g_(_b_ug_, (14 * 227 - 30 - 378 - 58 ~= 2712))
                    end
                end
            end
            _b_ug_["_onownerunequip"] = function(_B_u__G_, _b_U_g)
                if _b_U_g ~= nil and _b_U_g["eslot"] == EQUIPSLOTS["HEAD"] then
                    __b__U_g_(
                        _b_ug_,
                        (true and false or not false and false and false and false and not false and false and not false)
                    )
                end
            end
            _b_ug_:ListenForEvent("equip", _b_ug_["_onownerequip"], _B_u__G_)
            _b_ug_:ListenForEvent("unequip", _b_ug_["_onownerunequip"], _B_u__G_)
            local _b_uG = _B_u__G_["components"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HEAD"])
            if _b_uG ~= nil and _b_uG["prefab"] == "lunarplanthat" then
                __b__U_g_(_b_ug_, (154 + 135 * 307 - 412 == 41187))
            end
        end
    end
end
local __b_u_G_ = {Asset("ANIM", "anim/nn_shield.zip"), Asset("ANIM", "anim/swap_nn_shield.zip")}
local _bU_g_ = {Asset("ANIM", "anim/hh_weapon.zip"), Asset("ANIM", "anim/hh_daogam.zip"), Asset("ANIM", "anim/hh_daogam2.zip"), Asset("ANIM", "anim/hh_purple_warg_mutated_breath_fx.zip"), Asset("ATLAS", "images/inventoryimages/hh_daogam2.xml"), Asset("IMAGE", "images/inventoryimages/hh_daogam2.tex")}
local bug__ = {"lunarplanttentacle", "flamethrower_fx", "reticulearcline", "reticulearclineping"}
local function b__U__g__()
    return Vector3(ThePlayer["entity"]:LocalToWorldSpace(6.5, 0, 0))
end
local function bU__G__(__B__ug_, bu_g)
    if bu_g ~= nil then
        local _bu_G__, __b_u__g_, B_U__g__ = __B__ug_["Transform"]:GetWorldPosition()
        local BUg__ = bu_g["x"] - _bu_G__
        local b_u_g__ = bu_g["z"] - B_U__g__
        local Bu_g_ = BUg__ * BUg__ + b_u_g__ * b_u_g__
        if Bu_g_ <= 0 then
            return __B__ug_["components"]["reticule"]["targetpos"]
        end
        Bu_g_ = 6.5 / math["sqrt"](Bu_g_)
        return Vector3(_bu_G__ + BUg__ * Bu_g_, 0, B_U__g__ + b_u_g__ * Bu_g_)
    end
end
local function __B_U__G(B_u__G, b_UG_, Bu__g_, b_u_g_, __b__Ug, __bu__G)
    local _b_u__g, _B_Ug_, bu_G = B_u__G["Transform"]:GetWorldPosition()
    Bu__g_["Transform"]:SetPosition(_b_u__g, 0, bu_G)
    local __b_Ug_ = -math["atan2"](b_UG_["z"] - bu_G, b_UG_["x"] - _b_u__g) / DEGREES
    if b_u_g_ and __bu__G ~= nil then
        local _B_ug__ = Bu__g_["Transform"]:GetRotation()
        local B_U__G__ = __b_Ug_ - _B_ug__
        __b_Ug_ =
            Lerp(
            (B_U__G__ > 180 and _B_ug__ + 360) or (B_U__G__ < -180 and _B_ug__ - 360) or _B_ug__,
            __b_Ug_,
            __bu__G * __b__Ug
        )
    end
    Bu__g_["Transform"]:SetRotation(__b_Ug_)
end
local function __Bu__G(B_uG_, _b__ug_)
    if B_uG_.components.finiteuses ~= nil and B_uG_.components.finiteuses:GetPercent() < 0.01 then
        B_uG_:DoTaskInTime(0, function()
            if _b__ug_ ~= nil and _b__ug_.components.inventory ~= nil and B_uG_.components.equippable ~= nil then
                local item = _b__ug_.components.inventory:Unequip(B_uG_.components.equippable.equipslot)
                if item ~= nil then
                    _b__ug_.components.inventory:GiveItem(item)
                end
                if _b__ug_.components.talker ~= nil then
                    _b__ug_.components.talker:Say("Kiếm chưa được sửa chữa, không thể cầm lên!")
                end
            end
        end)
        return
    end
    _b__ug_["AnimState"]:OverrideSymbol("lantern_overlay", "swap_moonfire_shield", "swap_shield")
    _b__ug_["AnimState"]:OverrideSymbol("swap_shield", "swap_moonfire_shield", "swap_shield")
    _b__ug_["AnimState"]:HideSymbol "swap_object"
    _b__ug_["AnimState"]:Show "ARM_carry"
    _b__ug_["AnimState"]:Hide "ARM_normal"
    _b__ug_["AnimState"]:Show "lantern_overlay"
    B_uG_:ListenForEvent("blocked", B_uG_["_onblocked"], _b__ug_)
    B_uG_:ListenForEvent("attacked", B_uG_["_onblocked"], _b__ug_)
    _b__ug_:ListenForEvent("onattackother", B_uG_["_weaponused_callback"])
    B_uG_["_hitcount"] = 0
    if B_uG_["components"]["rechargeable"]:GetTimeToCharge() < 2 then
        B_uG_["components"]["rechargeable"]:Discharge(2)
    end
    if B_uG_["fx0"] ~= nil then
        B_uG_["fx0"]:Remove()
        B_uG_["fx0"] = nil
    end
    B_uG_["fx0"] = SpawnPrefab "cane_victorian_fx"
    if B_uG_["fx0"] then
        B_uG_["fx0"]["entity"]:AddFollower()
        B_uG_["fx0"]["entity"]:SetParent(_b__ug_["entity"])
        B_uG_["fx0"]["Follower"]:FollowSymbol(_b__ug_["GUID"], "swap_object", 0, -60, 0)
    end
    local B_u__G__ = _b__ug_:SpawnChild "sparks2_fx"
    if B_u__G__ then
        _b__ug_:AddChild(B_u__G__)
        B_u__G__["Transform"]:SetPosition(0, 0, 0)
        _b__ug_["fx1"] = B_u__G__
    end
    local _B_u_G_ = _b__ug_:SpawnChild "sparks1_fx"
    if _B_u_G_ then
        _b__ug_:AddChild(B_u__G__)
        _B_u_G_["Transform"]:SetPosition(0, -1, 0)
        _b__ug_["fx2"] = _B_u_G_
    end
    _B_U__g_(B_uG_, _b__ug_)
end
local function B_U_g__(B_u_g, __b_U_G_)
    __b_U_G_["AnimState"]:Hide "ARM_carry"
    __b_U_G_["AnimState"]:Show "ARM_normal"
    B_u_g:RemoveEventCallback("blocked", B_u_g["_onblocked"], __b_U_G_)
    B_u_g:RemoveEventCallback("attacked", B_u_g["_onblocked"], __b_U_G_)
    __b_U_G_:RemoveEventCallback("onattackother", B_u_g["_weaponused_callback"])
    __b_U_G_["AnimState"]:ClearOverrideSymbol "lantern_overlay"
    __b_U_G_["AnimState"]:ClearOverrideSymbol "swap_shield"
    __b_U_G_["AnimState"]:Hide "lantern_overlay"
    __b_U_G_["AnimState"]:ShowSymbol "swap_object"
    B_u_g["_hitcount"] = nil
    if B_u_g["fx0"] ~= nil then
        B_u_g["fx0"]:Remove()
        B_u_g["fx0"] = nil
    end
    if __b_U_G_["fx1"] then
        __b_U_G_:RemoveChild(__b_U_G_["fx1"])
        __b_U_G_["fx1"]:Remove()
        __b_U_G_["fx1"] = nil
    end
    if __b_U_G_["fx2"] then
        __b_U_G_:RemoveChild(__b_U_G_["fx2"])
        __b_U_G_["fx2"]:Remove()
        __b_U_G_["fx2"] = nil
    end
    _B_U__g_(B_u_g, nil)
end
local function B_ug__(_B__U_G__, _B_u_G__)
    if _B__U_G__.components.finiteuses ~= nil and _B__U_G__.components.finiteuses:GetPercent() < 0.01 then
        _B__U_G__:DoTaskInTime(0, function()
            if _B_u_G__ ~= nil and _B_u_G__.components.inventory ~= nil and _B__U_G__.components.equippable ~= nil then
                local item = _B_u_G__.components.inventory:Unequip(_B__U_G__.components.equippable.equipslot)
                if item ~= nil then
                    _B_u_G__.components.inventory:GiveItem(item)
                end
                if _B_u_G__.components.talker ~= nil then
                    _B_u_G__.components.talker:Say("Kiếm chưa được sửa chữa, không thể cầm lên!")
                end
            end
        end)
        return
    end
    _B_u_G__["AnimState"]:OverrideSymbol("swap_object", "hh_daogam2", "swap")
    _B_u_G__["AnimState"]:Show "ARM_carry"
    _B_u_G__["AnimState"]:Hide "ARM_normal"
    _B__U_G__:ListenForEvent("blocked", _B__U_G__["_onblocked"], _B_u_G__)
    _B__U_G__:ListenForEvent("attacked", _B__U_G__["_onblocked"], _B_u_G__)
    _B__U_G__["_hitcount"] = 0
    if _B__U_G__["components"]["rechargeable"]:GetTimeToCharge() < 2 then
        _B__U_G__["components"]["rechargeable"]:Discharge(2)
    end
    if _B__U_G__["fx00"] ~= nil then
        _B__U_G__["fx00"]:Remove()
        _B__U_G__["fx00"] = nil
    end
    if _B__U_G__["fx0"] ~= nil then
        _B__U_G__["fx0"]:Remove()
        _B__U_G__["fx0"] = nil
    end
    if _B__U_G__["fx00"] ~= nil then
        _B__U_G__["fx00"]:Remove()
        _B__U_G__["fx00"] = nil
    end
    _B__U_G__["fx00"] = SpawnPrefab "deer_ice_charge"
    if _B__U_G__["fx00"] then
        _B__U_G__["fx00"]["entity"]:AddFollower()
        _B__U_G__["fx00"]["entity"]:SetParent(_B_u_G__["entity"])
        _B__U_G__["fx00"]["Follower"]:FollowSymbol(_B_u_G__["GUID"], "swap_object", 10, -100, 0)
    end
    if _B__U_G__["fx0"] ~= nil then
        _B__U_G__["fx0"]:Remove()
        _B__U_G__["fx0"] = nil
    end
    _B__U_G__["fx0"] = SpawnPrefab "cane_victorian_fx"
    if _B__U_G__["fx0"] then
        _B__U_G__["fx0"]["entity"]:AddFollower()
        _B__U_G__["fx0"]["entity"]:SetParent(_B_u_G__["entity"])
        _B__U_G__["fx0"]["Follower"]:FollowSymbol(_B_u_G__["GUID"], "swap_object", 0, -60, 0)
    end
    local b_uG = _B_u_G__:SpawnChild "sparks2_fx"
    if b_uG then
        _B_u_G__:AddChild(b_uG)
        b_uG["Transform"]:SetPosition(0, 0, 0)
        _B_u_G__["fx1"] = b_uG
    end
    local __B__U_G__ = _B_u_G__:SpawnChild "sparks1_fx"
    if __B__U_G__ then
        _B_u_G__:AddChild(b_uG)
        __B__U_G__["Transform"]:SetPosition(0, -1, 0)
        _B_u_G__["fx2"] = __B__U_G__
    end
    _B_U__g_(_B__U_G__, _B_u_G__)
end
local function Bu_G(_bu_G_, _bU__G__)
    _bU__G__["AnimState"]:Hide "ARM_carry"
    _bU__G__["AnimState"]:Show "ARM_normal"
    _bu_G_:RemoveEventCallback("blocked", _bu_G_["_onblocked"], _bU__G__)
    _bu_G_:RemoveEventCallback("attacked", _bu_G_["_onblocked"], _bU__G__)
    _bu_G_["_hitcount"] = nil
    if _bu_G_["fx00"] ~= nil then
        _bu_G_["fx00"]:Remove()
        _bu_G_["fx00"] = nil
    end
    if _bu_G_["fx0"] ~= nil then
        _bu_G_["fx0"]:Remove()
        _bu_G_["fx0"] = nil
    end
    if _bU__G__["fx1"] then
        _bU__G__:RemoveChild(_bU__G__["fx1"])
        _bU__G__["fx1"]:Remove()
        _bU__G__["fx1"] = nil
    end
    if _bU__G__["fx2"] then
        _bU__G__:RemoveChild(_bU__G__["fx2"])
        _bU__G__["fx2"]:Remove()
        _bU__G__["fx2"] = nil
    end
    _B_U__g_(_bu_G_, nil)
end
local function __BU__G_(_B_U__G_)
    return not TheWorld["Map"]:IsPointNearHole(_B_U__G_)
end
local function __BU__g__(_bug__, __B__u_g, _B__uG__)
    local BU__G_
    if _B__uG__ ~= nil and _B__uG__:IsValid() then
        BU__G_ = _B__uG__:GetPosition()
    else
        BU__G_ = __B__u_g:GetPosition()
        _B__uG__ = nil
    end
    local _B_ug_ =
        FindWalkableOffset(
        BU__G_,
        math["random"]() * 2 * PI,
        2,
        3,
        (348 + 271 - 380 * 284 == -107293),
        (364 - 250 - 126 ~= -2),
        __BU__G_,
        (421 + 199 - 425 ~= 195),
        (216 - 467 + 141 - 418 ~= -518)
    )
    if _B_ug_ ~= nil then
        local _BU_g__ = SpawnPrefab "lunarplanttentacle"
        if _BU_g__ ~= nil then
            _BU_g__["owner"] = __B__u_g
            _BU_g__["Transform"]:SetPosition(BU__G_["x"] + _B_ug_["x"], 0, BU__G_["z"] + _B_ug_["z"])
            _BU_g__["components"]["combat"]:SetTarget(_B__uG__)
        end
    end
end
local function __b__ug__(__b__U_g, _B_U_g, Bu__G__)
    local _b__UG = SpawnPrefab "flamethrower_fx"
    _b__UG._hh_daogam2_purple_build = true
    _b__UG["entity"]:SetParent(_B_U_g["entity"])
    _b__UG:SetFlamethrowerAttacker(_B_U_g)

    _b__UG:DoTaskInTime(1, _b__UG["KillFX"])
end
local function B__u_G(b__ug__, b_Ug__, __B_u_G__)
    b__ug__["components"]["parryweapon"]:EnterParryState(b_Ug__, b_Ug__:GetAngleToPoint(__B_u_G__), 2)
    b__ug__["components"]["rechargeable"]:Discharge(TUNING["MOONFIRE_SHIELD_CD"])
end
local function __BUG__(_B__uG, _bU__G_, _B__u__g)
    local mana = _bU__G_.components.hh_mana
    if mana == nil or not mana:CanSpend(10) then return false end
    mana:Spend(10, "hh_daogam2_counterattack")
    _B__uG["components"]["rechargeable"]:Discharge(TUNING["MOONFIRE_SHIELD_CD"])
    _bU__G_:PushEvent("combat_parry", {direction = _bU__G_:GetAngleToPoint(_B__u__g), duration = 2.1, weapon = _B__uG})
end
local function b__U_g(BU__G__, _BUg_, bUg_, B__ug__)
    _BUg_:ShakeCamera(CAMERASHAKE["SIDE"], 0.1, 0.03, 0.3)
    if BU__G__["components"]["rechargeable"]:GetPercent() < TUNING["MOONFIRE_SHIELD_GP"] then
        BU__G__["components"]["rechargeable"]:SetPercent(TUNING["MOONFIRE_SHIELD_GP"])
    end
end
local function _b_U__g__(_b_U__G_, B_U_G_, _bUG, _b__u__G_)
    B_U_G_:ShakeCamera(CAMERASHAKE["SIDE"], 0.1, 0.03, 0.3)
    if _b_U__G_["components"]["rechargeable"]:GetPercent() < TUNING["MOONFIRE_SHIELD_GP_SUPER"] then
        _b_U__G_["components"]["rechargeable"]:SetPercent(TUNING["MOONFIRE_SHIELD_GP_SUPER"])
    end
    local _Bu_g__ = {min = 8, max = 16}
    local __B__u_G__ = 0.5
    local Bu__G_ = SpawnPrefab "flamethrower_fx"
    Bu__G_._hh_daogam2_purple_build = true
    Bu__G_["entity"]:SetParent(B_U_G_["entity"])
    Bu__G_:SetFlamethrowerAttacker(B_U_G_)
    Bu__G_:DoTaskInTime(0.3, Bu__G_["KillFX"])

end
local function bu__G_(_b_u_g__)
    _b_u_g__["components"]["aoetargeting"]:SetEnabled((373 + 288 * 163 - 130 + 141 == 47337))
end
local function __B__ug__(_buG__)
    _buG__["components"]["aoetargeting"]:SetEnabled((295 + 64 - 39 * 59 == -1942))
end
local function bu_g_(_b_u__G_, b_u_G__)
    local __bUg =
        math["abs"](b_u_G__["components"]["edible"]:GetHealth(_b_u__G_)) *
        _b_u__G_["components"]["eater"]["healthabsorption"]
    local b_UG =
        math["abs"](b_u_G__["components"]["edible"]:GetHunger(_b_u__G_)) *
        _b_u__G_["components"]["eater"]["hungerabsorption"]

end
local function B_u__G_(__b_U_g_, __b_U_G__, _b_U__g_)
    if __b_U_g_["_hitcount"] then
        __b_U_g_["_hitcount"] = __b_U_g_["_hitcount"] + 1
        if __b_U_g_["_hitcount"] >= 3 then
            __b_U_g_["_hitcount"] = 0
            __BU__g__(__b_U_g_, __b_U_G__, _b_U__g_)
        end
    end
end
local function __BU__g_(BUg_, B__U_g_, __bU_G)
    HHDaogam2ConsumeDurability(BUg_)

    if BUg_["_hitcount"] then
        BUg_["_hitcount"] = BUg_["_hitcount"] + 1
        if BUg_["_hitcount"] >= 3 then
            BUg_["_hitcount"] = 0
            __BU__g__(BUg_, B__U_g_, __bU_G)
        end
    end
    if __bU_G ~= nil and __bU_G:IsValid() and B__U_g_ ~= nil and B__U_g_:IsValid() then
        B__U_g_["SoundEmitter"]:PlaySound "dontstarve/common/together/moonbase/beam_stop_fail"
        B__U_g_["AnimState"]:PlayAnimation "lunge_pst"
    end
end
local function __buG_(__bUG, __B_uG, BUg)
    BUg["_hitcount"] = 0
end
local function _B__U__g__(Bu_G__)
    Bu_G__:AddComponent "equippable"
    Bu_G__["components"]["equippable"]:SetOnEquip(__Bu__G)
    Bu_G__["components"]["equippable"]:SetOnUnequip(B_U_g__)
    Bu_G__:AddComponent "eater"
    Bu_G__["components"]["eater"]:SetOnEatFn(bu_g_)
    Bu_G__["components"]["eater"]:SetAbsorptionModifiers(4.0, 1.75, 0)
    Bu_G__["components"]["eater"]:SetCanEatRawMeat((44 * 426 - 493 - 86 == 18165))
    Bu_G__["components"]["eater"]:SetStrongStomach((261 + 149 + 475 + 456 ~= 1350))
    Bu_G__["components"]["eater"]:SetCanEatHorrible((485 * 73 - 107 + 265 + 413 == 35976))
end
local function __B__u_G_(B__u_g_)
    B__u_g_:AddComponent "equippable"
    B__u_g_["components"]["equippable"]:SetOnEquip(B_ug__)
    B__u_g_["components"]["equippable"]:SetOnUnequip(Bu_G)
    B__u_g_:AddComponent "eater"
    B__u_g_["components"]["eater"]:SetOnEatFn(bu_g_)
    B__u_g_["components"]["eater"]:SetAbsorptionModifiers(4.0, 1.75, 0)
    B__u_g_["components"]["eater"]:SetCanEatRawMeat(
        (true or not false and true and not false or true and false and not false or not false and true and not true or
            not false and not false and not false)
    )
    B__u_g_["components"]["eater"]:SetStrongStomach((53 - 137 + 439 == 355))
    B__u_g_["components"]["eater"]:SetCanEatHorrible((390 + 48 * 272 ~= 13455))
end
local function _b__u_g(__B__U_g__)
    __B__U_g__:RemoveComponent "equippable"
    __B__U_g__:RemoveComponent "eater"
end
local function _b_u_g(__BU_g__)
    if __BU_g__["components"]["equippable"] ~= nil then
        _b__u_g(__BU_g__)
        __BU_g__["AnimState"]:PlayAnimation "idle"
        __BU_g__:AddTag "broken"
        __BU_g__["components"]["inspectable"]["nameoverride"] = "BROKEN_FORGEDITEM"
    end
    if __BU_g__["_hitcount"] then
        __BU_g__["_hitcount"] = 0
    end
end
local function __bu__g_(__bu__g__)
    if __bu__g__["components"]["equippable"] == nil then
        _B__U__g__(__bu__g__)
        __bu__g__["AnimState"]:PlayAnimation("idle", (305 - 98 - 167 - 11 == 29))
        __bu__g__:RemoveTag "broken"
        __bu__g__["components"]["inspectable"]["nameoverride"] = nil
    end
    if __bu__g__["_hitcount"] then
        __bu__g__["_hitcount"] = 0
    end
end
local function _B__u__G_(Bu_G_)
    if Bu_G_["components"]["equippable"] == nil then
        __B__u_G_(Bu_G_)
        Bu_G_["AnimState"]:PlayAnimation("idle", (380 + 84 - 305 + 211 - 347 ~= 29))
        Bu_G_:RemoveTag "broken"
        Bu_G_["components"]["inspectable"]["nameoverride"] = nil
    end
    if Bu_G_["_hitcount"] then
        Bu_G_["_hitcount"] = 0
    end
end
local function __B__uG__()
    local B__u__g__ = CreateEntity()
    B__u__g__["entity"]:AddTransform()
    B__u__g__["entity"]:AddAnimState()
    B__u__g__["entity"]:AddNetwork()
    B__u__g__["entity"]:AddSoundEmitter()
    B__u__g__["entity"]:AddMiniMapEntity()
    B__u__g__["MiniMapEntity"]:SetIcon "hh_daogam2.tex"
    MakeInventoryPhysics(B__u__g__)
    B__u__g__["AnimState"]:SetBank "xd_skin_xuanyuan"
    B__u__g__["AnimState"]:SetBuild "hh_daogam2"
    B__u__g__["AnimState"]:PlayAnimation("idle", true)
    B__u__g__:AddTag "hh_daogam2_item"
    B__u__g__:AddTag "handfed"
    B__u__g__:AddTag "fedbyall"

    if __bU__g["hh_daogam2"] and __bU__g["hh_daogam2"]["client_fn"] then
        __bU__g["hh_daogam2"]["client_fn"](B__u__g__)
    end
    B__u__g__:AddTag "super_lunar_shield"
    B__u__g__:AddTag "eatsrawmeat"
    B__u__g__:AddTag "strongstomach"
    B__u__g__:AddTag "weapon"
    B__u__g__:AddTag "parryweapon"
    B__u__g__:AddTag "rechargeable"
    MakeInventoryFloatable(B__u__g__, nil, 0.2, {1.1, 0.6, 1.1})
    B__u__g__["entity"]:SetPristine()
    B__u__g__:AddComponent "aoetargeting"
    B__u__g__["components"]["aoetargeting"]:SetAlwaysValid((461 * 381 * 401 * 5 + 389 ~= 352160596))
    B__u__g__["components"]["aoetargeting"]:SetAllowRiding((435 + 167 + 128 + 57 + 379 == 1173))
    B__u__g__["components"]["aoetargeting"]["reticule"]["reticuleprefab"] = "reticulearcline"
    B__u__g__["components"]["aoetargeting"]["reticule"]["pingprefab"] = "reticulearclineping"
    B__u__g__["components"]["aoetargeting"]["reticule"]["targetfn"] = b__U__g__
    B__u__g__["components"]["aoetargeting"]["reticule"]["mousetargetfn"] = bU__G__
    B__u__g__["components"]["aoetargeting"]["reticule"]["updatepositionfn"] = __B_U__G
    B__u__g__["components"]["aoetargeting"]["reticule"]["validcolour"] = {1, .75, 0, 1}
    B__u__g__["components"]["aoetargeting"]["reticule"]["invalidcolour"] = {.5, 0, 0, 1}
    B__u__g__["components"]["aoetargeting"]["reticule"]["ease"] =
        (false or not false or true and true or not false and false and true and false or
        not true and not false and true)
    B__u__g__["components"]["aoetargeting"]["reticule"]["mouseenabled"] = (88 * 120 + 187 == 10747)
    if not TheWorld["ismastersim"] then
        return B__u__g__
    end
    B__u__g__:AddTag "heavyarmor"
    B__u__g__:AddComponent "weapon"
    B__u__g__["components"]["weapon"]:SetDamage(68)
    B__u__g__["base_damage"] = 68
    B__u__g__["components"]["weapon"]:SetOnAttack(__BU__g_)
    B__u__g__:AddComponent("finiteuses")
    B__u__g__.components.finiteuses:SetMaxUses(HHDaogamDurability.MAX_USES)
    B__u__g__.components.finiteuses:SetUses(HHDaogamDurability.MAX_USES)
    B__u__g__.components.finiteuses:SetOnFinished(HHDaogamDurability.OnFinished)
    B__u__g__.components.finiteuses:SetIgnoreCombatDurabilityLoss(true)
    B__u__g__:AddTag("hh_daogam_item")
    B__u__g__:ListenForEvent("percentusedchange", function(item, data) if data ~= nil and data.percent < 1 then item:AddTag("hh_daogam_damaged") else item:RemoveTag("hh_daogam_damaged") end end)

    B__u__g__:AddComponent "armor"
    B__u__g__["components"]["armor"]:InitIndestructible(0.9)
    -- Keep armor as the 90% absorption provider, but expose the one true
    -- durability value to inventoryitem replication/UI.  inventoryitem.lua
    -- prefers armor over finiteuses when serializing the usage percentage.
    B__u__g__.components.armor.GetPercent = function(armor)
        local finiteuses = armor.inst.components.finiteuses
        return finiteuses ~= nil and finiteuses:GetPercent() or 1
    end
    B__u__g__:AddComponent "planardefense"
    B__u__g__["components"]["planardefense"]:SetBaseDefense(TUNING["ARMOR_LUNARPLANT_PLANAR_DEF"] * 2)
    B__u__g__["_hitcount"] = nil
    B__u__g__:AddComponent "planardamage"
    B__u__g__["components"]["planardamage"]:SetBaseDamage(30)
    local __B__U__g__ = B__u__g__:AddComponent "damagetypebonus"
    __B__U__g__:AddBonus("shadow_aligned", B__u__g__, TUNING["WEAPONS_LUNARPLANT_VS_SHADOW_BONUS"])
    __B__U__g__:AddBonus("lunar_aligned", B__u__g__, TUNING["WEAPONS_VOIDCLOTH_VS_LUNAR_BONUS"])
    B__u__g__:AddComponent "inspectable"
    B__u__g__:AddComponent "inventoryitem"
    B__u__g__["components"]["inventoryitem"]["atlasname"] = "images/inventoryimages/hh_daogam2.xml"
    B__u__g__["components"]["inventoryitem"]["imagename"] = "hh_daogam2"
    __B__u_G_(B__u__g__)
    B__u__g__:AddComponent "aoespell"
    B__u__g__["components"]["aoespell"]:SetSpellFn(__BUG__)
    B__u__g__:AddComponent "parryweapon"
    B__u__g__["components"]["parryweapon"]:SetParryArc(178)
    B__u__g__["components"]["parryweapon"]:SetOnParryFn(_b_U__g__)
    B__u__g__["components"]["parryweapon"]:SetOnPreParryFn(__b__ug__)
    B__u__g__:AddComponent "rechargeable"
    B__u__g__["components"]["rechargeable"]:SetOnDischargedFn(bu__G_)
    B__u__g__["components"]["rechargeable"]:SetOnChargedFn(__B__ug__)
    MakeHauntableLaunch(B__u__g__)

    B__u__g__["_onblocked"] = function(_b__u_G__, B_u_G__)
        HHDaogam2ConsumeDurability(B__u__g__)
        __buG_(_b__u_G__, B_u_G__, B__u__g__)
    end
    if __bU__g["hh_daogam2"] and __bU__g["hh_daogam2"]["start_fn"] then
        __bU__g["hh_daogam2"]["start_fn"](B__u__g__)
    end
    -- Keep hh_daogam2's hover description independent from optional legacy entries.
    B__u__g__.GetHHSpDesc01 = function()
        return {title = "Bị động", desc = "Sau 3 đòn đánh sẽ gọi xúc tu gây 85 ST"}
    end
    B__u__g__.GetHHSpDesc02 = function()
        return {
            title = "Chủ động",
            desc = "Nhấn " .. STRINGS.RMB .. " để thi triển Phản Kích Hắc Ảnh (tốn 10 mana, cd: 10s)"
        }
    end
    B__u__g__.GetHHSpDesc03 = function()
        return {title = "Đặc biệt", desc = "Đỡ đòn hoàn hảo sẽ giảm 80% thời gian hồi chiêu"}
    end
    B__u__g__.GetHHSpDesc04 = function() return {title = "Sửa chữa", desc = HHDaogamDurability.GetRepairDescription()} end
    B__u__g__.GetHHSpDesc05 = function() return {title = "Hệ đồ", desc = "Tối Thượng", rainbow = true} end
    RegisterInventoryItemAtlas("images/inventoryimages/hh_daogam2.xml", "hh_daogam2.tex")
    return B__u__g__
end
return Prefab("hh_daogam2", __B__uG__, _bU_g_)




