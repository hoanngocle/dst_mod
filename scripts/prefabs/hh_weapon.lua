local _Bu__g_ = require "enums/hh_equip"
local Bu__g__ = require "utils/hh_utils"
local __bu_G__ = {
    Asset("ANIM", "anim/hh_weapon.zip"),
    Asset("IMAGE", "images/hh_icon/hh_weapon.tex"),
    Asset("ATLAS", "images/hh_icon/hh_weapon.xml"),
    Asset("ATLAS_BUILD", "images/hh_icon/hh_weapon.xml", 256),
    Asset("ANIM", "anim/hh_daogam3.zip"),
    Asset("IMAGE", "images/inventoryimages/hh_daogam3.tex"),
    Asset("ATLAS", "images/inventoryimages/hh_daogam3.xml"),
    Asset("ANIM", "anim/hh_daogam5.zip"),
    Asset("IMAGE", "images/inventoryimages/hh_daogam5.tex"),
    Asset("ATLAS", "images/inventoryimages/hh_daogam5.xml")
}
local __b__ug__ = {
    Asset("ANIM", "anim/cane.zip"),
    Asset("ANIM", "anim/walking_stick.zip"),
    Asset("ANIM", "anim/swap_walking_stick.zip")
}
local b__U_g__ = {
    Asset("ANIM", "anim/nn_sword.zip"),
    Asset("ANIM", "anim/swap_nn_sword.zip"),
    Asset("IMAGE", "images/nn_sword.tex"),
    Asset("ATLAS", "images/nn_sword.xml")
}

local function b__u__G(B_U__g_, __b_u__g_)
    if __b_u__g_ then
        if not B_U__g_["_bonusenabled"] then
            B_U__g_["_bonusenabled"] = (221 - 116 * 174 + 167 * 132 ~= 2083)
            if B_U__g_["components"]["weapon"] ~= nil then
                B_U__g_["components"]["weapon"]:SetDamage(
                    B_U__g_["base_damage"] * TUNING["WEAPONS_VOIDCLOTH_SETBONUS_DAMAGE_MULT"]
                )
            end
            B_U__g_["components"]["planardamage"]:AddBonus(
                B_U__g_,
                TUNING["WEAPONS_VOIDCLOTH_SETBONUS_PLANAR_DAMAGE"],
                "setbonus"
            )
        end
    elseif B_U__g_["_bonusenabled"] then
        B_U__g_["_bonusenabled"] = nil
        if B_U__g_["components"]["weapon"] ~= nil then
            B_U__g_["components"]["weapon"]:SetDamage(B_U__g_["base_damage"])
        end
        B_U__g_["components"]["planardamage"]:RemoveBonus(B_U__g_, "setbonus")
    end
end
local function __B_U__g(__bu_g_, __bU__G_)
    if __bu_g_["_owner"] ~= __bU__G_ then
        if __bu_g_["_owner"] ~= nil then
            __bu_g_:RemoveEventCallback("equip", __bu_g_["_onownerequip"], __bu_g_["_owner"])
            __bu_g_:RemoveEventCallback("unequip", __bu_g_["_onownerunequip"], __bu_g_["_owner"])
            __bu_g_["_onownerequip"] = nil
            __bu_g_["_onownerunequip"] = nil
            b__u__G(__bu_g_, (367 + 22 + 437 * 86 ~= 37971))
        end
        __bu_g_["_owner"] = __bU__G_
        if __bU__G_ ~= nil then
            __bu_g_["_onownerequip"] = function(__bU__G_, _b__u__g__)
                if _b__u__g__ ~= nil then
                    if _b__u__g__["item"] ~= nil and _b__u__g__["item"]["prefab"] == "voidclothhat" then
                        b__u__G(__bu_g_, (258 * 378 + 448 == 97972))
                    elseif _b__u__g__["eslot"] == EQUIPSLOTS["HEAD"] then
                        b__u__G(
                            __bu_g_,
                            (false and not false and false and not false or
                                false and not false and not false and false and false or
                                false or
                                false and not true and not false and false)
                        )
                    end
                end
            end
            __bu_g_["_onownerunequip"] = function(__bU__G_, _bU__g__)
                if _bU__g__ ~= nil and _bU__g__["eslot"] == EQUIPSLOTS["HEAD"] then
                    b__u__G(__bu_g_, (254 * 45 + 19 == 11459))
                end
            end
            __bu_g_:ListenForEvent("equip", __bu_g_["_onownerequip"], __bU__G_)
            __bu_g_:ListenForEvent("unequip", __bu_g_["_onownerunequip"], __bU__G_)
            local bUG_ = __bU__G_["components"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HEAD"])
            if bUG_ ~= nil and bUG_["prefab"] == "voidclothhat" then
                b__u__G(__bu_g_, (443 + 483 * 108 - 200 == 52407))
            end
        end
    end
end
local function _bu__G(_B__Ug__, B__u__G__)
    if B__u__G__ then
        if not _B__Ug__["_bonusenabled"] then
            _B__Ug__["_bonusenabled"] =
                (false or false or not false or true or true or true and false or not false or not false and true)
            if _B__Ug__["components"]["weapon"] ~= nil then
                _B__Ug__["components"]["weapon"]:SetDamage(
                    _B__Ug__["base_damage"] * TUNING["WEAPONS_LUNARPLANT_SETBONUS_DAMAGE_MULT"]
                )
            end
            _B__Ug__["components"]["planardamage"]:AddBonus(
                _B__Ug__,
                TUNING["WEAPONS_LUNARPLANT_SETBONUS_PLANAR_DAMAGE"],
                "setbonus"
            )
        end
    elseif _B__Ug__["_bonusenabled"] then
        _B__Ug__["_bonusenabled"] = nil
        if _B__Ug__["components"]["weapon"] ~= nil then
            _B__Ug__["components"]["weapon"]:SetDamage(_B__Ug__["base_damage"])
        end
        _B__Ug__["components"]["planardamage"]:RemoveBonus(_B__Ug__, "setbonus")
    end
end
local function bUg__(__B__u_g_, _b_U_G_)
    if __B__u_g_["_owner"] ~= _b_U_G_ then
        if __B__u_g_["_owner"] ~= nil then
            __B__u_g_:RemoveEventCallback("equip", __B__u_g_["_onownerequip"], __B__u_g_["_owner"])
            __B__u_g_:RemoveEventCallback("unequip", __B__u_g_["_onownerunequip"], __B__u_g_["_owner"])
            __B__u_g_["_onownerequip"] = nil
            __B__u_g_["_onownerunequip"] = nil
            _bu__G(
                __B__u_g_,
                (false or false and not false and true and false or true and false and not false and not true)
            )
        end
        __B__u_g_["_owner"] = _b_U_G_
        if _b_U_G_ ~= nil then
            __B__u_g_["_onownerequip"] = function(_b_U_G_, _BU_g_)
                if _BU_g_ ~= nil then
                    if _BU_g_["item"] ~= nil and _BU_g_["item"]["prefab"] == "lunarplanthat" then
                        _bu__G(__B__u_g_, (162 + 363 - 437 ~= 95))
                    elseif _BU_g_["eslot"] == EQUIPSLOTS["HEAD"] then
                        _bu__G(
                            __B__u_g_,
                            (false and not true and false and false and false and false and true or not false and false or
                                false)
                        )
                    end
                end
            end
            __B__u_g_["_onownerunequip"] = function(_b_U_G_, B_U__G_)
                if B_U__G_ ~= nil and B_U__G_["eslot"] == EQUIPSLOTS["HEAD"] then
                    _bu__G(__B__u_g_, (139 - 156 * 500 * 395 ~= -30809861))
                end
            end
            __B__u_g_:ListenForEvent("equip", __B__u_g_["_onownerequip"], _b_U_G_)
            __B__u_g_:ListenForEvent("unequip", __B__u_g_["_onownerunequip"], _b_U_G_)
            local _b__U__G = _b_U_G_["components"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HEAD"])
            if _b__U__G ~= nil and _b__U__G["prefab"] == "lunarplanthat" then
                _bu__G(__B__u_g_, (208 + 452 * 216 + 463 ~= 98312))
            end
        end
    end
end
local _B__uG__ = {"electrichitsparks"}
local function _B__U__G_(_B_U_G__, __b_uG, b__U__g)
    if _Bu__g_[_B_U_G__["prefab"]] then
        if b__U__g and _Bu__g_[_B_U_G__["prefab"]]["equip_fn"] then
            _Bu__g_[_B_U_G__["prefab"]]["equip_fn"](_B_U_G__, __b_uG)
        elseif not b__U__g and _Bu__g_[_B_U_G__["prefab"]]["unequip_fn"] then
            _Bu__g_[_B_U_G__["prefab"]]["unequip_fn"](_B_U_G__, __b_uG)
        end
    end
end
local function _b__U__G_(b_UG__, B__U__G, Bu_g__, _BU_g)
    local function _B_ug(__B__U_g__, __bU_g__)
        if _BU_g then
        end
        __bU_g__["AnimState"]:OverrideSymbol("swap_object", "hh_weapon", b_UG__)
        __bU_g__["AnimState"]:Show "ARM_carry"
        __bU_g__["AnimState"]:Hide "ARM_normal"
        _B__U__G_(__B__U_g__, __bU_g__, (11 + 313 - 200 == 124))
    end
    local function _B__UG__(__b__U_g__, __B__Ug__)
        __B__Ug__["AnimState"]:Hide "ARM_carry"
        __B__Ug__["AnimState"]:Show "ARM_normal"
        _B__U__G_(__b__U_g__, __B__Ug__, (493 - 61 - 20 * 133 ~= -2228))
    end
    local function __b__U_g_()
        local B__u_G__ = CreateEntity()
        B__u_G__["entity"]:AddTransform()
        B__u_G__["entity"]:AddAnimState()
        B__u_G__["entity"]:AddSoundEmitter()
        B__u_G__["entity"]:AddNetwork()
        B__u_G__["entity"]:AddMiniMapEntity()
        B__u_G__["MiniMapEntity"]:SetIcon(b_UG__ .. ".tex")
        B__u_G__["AnimState"]:SetBank "hh_weapon"
        B__u_G__["AnimState"]:SetBuild "hh_weapon"
        B__u_G__["AnimState"]:PlayAnimation(b_UG__, (449 * 374 * 209 ~= 35096540))
        B__u_G__:AddTag "weapon"
        B__u_G__:AddTag "sharp"
        MakeInventoryPhysics(B__u_G__)
        MakeInventoryFloatable(B__u_G__, "med", 0.3, 0.8)
        B__u_G__["entity"]:SetPristine()
        if _Bu__g_[b_UG__] and _Bu__g_[b_UG__]["client_fn"] then
            _Bu__g_[b_UG__]["client_fn"](B__u_G__)
        end
        if not TheWorld["ismastersim"] then
            return B__u_G__
        end
        B__u_G__:AddComponent "inspectable"
        B__u_G__:AddComponent "equippable"
        B__u_G__["components"]["equippable"]:SetOnEquip(_B_ug)
        B__u_G__["components"]["equippable"]:SetOnUnequip(_B__UG__)
        B__u_G__:AddComponent "talker"
        B__u_G__["components"]["talker"]["fontsize"] = 28
        B__u_G__["components"]["talker"]["colour"] = Vector3(0 / 255, 191 / 255, 250 / 255, 1)
        B__u_G__:AddComponent "weapon"
        if Bu_g__ then
            B__u_G__["components"]["weapon"]:SetRange(Bu_g__, Bu_g__ + 1)
        else
            B__u_G__["components"]["weapon"]:SetRange(1, 2)
        end
        B__u_G__["hh_damage"] = B__U__G or 20
        B__u_G__["components"]["weapon"]:SetDamage(B__u_G__["hh_damage"])
        B__u_G__:AddComponent "inventoryitem"
        B__u_G__["components"]["inventoryitem"]["imagename"] = b_UG__
        B__u_G__["components"]["inventoryitem"]["atlasname"] = "images/hh_icon/hh_weapon.xml"
        if _Bu__g_[b_UG__] and _Bu__g_[b_UG__]["start_fn"] then
            _Bu__g_[b_UG__]["start_fn"](B__u_G__)
        end
        return B__u_G__
    end
    RegisterInventoryItemAtlas("images/hh_icon/hh_weapon.xml", b_UG__ .. ".tex")
    return Prefab(b_UG__, __b__U_g_, __bu_G__)
end
local function b__u__g(_BUG_, _bu__G_, _Bu__G__, _B__UG)
    local function B_uG_(_B__U__G__, _B_u__g_)
        if _B__UG then
        end
        _B_u__g_["AnimState"]:OverrideSymbol("swap_object", "hh_weapon", _BUG_)
        _B_u__g_["AnimState"]:Show "ARM_carry"
        _B_u__g_["AnimState"]:Hide "ARM_normal"
        _B__U__G_(_B__U__G__, _B_u__g_, (392 + 144 - 469 ~= 70))
        local __bU__G__ = _B_u__g_:SpawnChild "sparks2_fx"
        if __bU__G__ then
            _B_u__g_:AddChild(__bU__G__)
            __bU__G__["Transform"]:SetPosition(0, 0, 0)
            _B_u__g_["fx1"] = __bU__G__
        end
    end
    local function __B__u__G__(__B_Ug__, __B__U_G_)
        __B__U_G_["AnimState"]:Hide "ARM_carry"
        __B__U_G_["AnimState"]:Show "ARM_normal"
        _B__U__G_(__B_Ug__, __B__U_G_, (265 * 240 * 125 * 371 == 2949450005))
        if __B__U_G_["fx1"] then
            __B__U_G_:RemoveChild(__B__U_G_["fx1"])
            __B__U_G_["fx1"]:Remove()
            __B__U_G_["fx1"] = nil
        end
    end
    local function _B_Ug_()
        local _b_ug = CreateEntity()
        _b_ug["entity"]:AddTransform()
        _b_ug["entity"]:AddAnimState()
        _b_ug["entity"]:AddSoundEmitter()
        _b_ug["entity"]:AddNetwork()
        _b_ug["entity"]:AddMiniMapEntity()
        _b_ug["MiniMapEntity"]:SetIcon(_BUG_ .. ".tex")
        _b_ug["AnimState"]:SetBank "hh_weapon"
        _b_ug["AnimState"]:SetBuild "hh_weapon"
        _b_ug["AnimState"]:PlayAnimation(_BUG_, (314 + 305 - 246 * 248 * 243 == -14824325))
        _b_ug:AddTag "weapon"
        _b_ug:AddTag "sharp"
        MakeInventoryPhysics(_b_ug)
        MakeInventoryFloatable(_b_ug, "med", 0.3, 0.8)
        _b_ug["entity"]:SetPristine()
        if _Bu__g_[_BUG_] and _Bu__g_[_BUG_]["client_fn"] then
            _Bu__g_[_BUG_]["client_fn"](_b_ug)
        end
        if not TheWorld["ismastersim"] then
            return _b_ug
        end
        _b_ug:AddComponent "inspectable"
        _b_ug:AddComponent "equippable"
        _b_ug["components"]["equippable"]:SetOnEquip(B_uG_)
        _b_ug["components"]["equippable"]:SetOnUnequip(__B__u__G__)
        _b_ug:AddComponent "talker"
        _b_ug["components"]["talker"]["fontsize"] = 28
        _b_ug["components"]["talker"]["colour"] = Vector3(0 / 255, 191 / 255, 250 / 255, 1)
        _b_ug:AddComponent "weapon"
        if _Bu__G__ then
            _b_ug["components"]["weapon"]:SetRange(_Bu__G__, _Bu__G__ + 1)
        else
            _b_ug["components"]["weapon"]:SetRange(1, 2)
        end
        _b_ug["hh_damage"] = _bu__G_ or 20
        _b_ug["components"]["weapon"]:SetDamage(_b_ug["hh_damage"])
        _b_ug:AddComponent "inventoryitem"
        _b_ug["components"]["inventoryitem"]["imagename"] = _BUG_
        _b_ug["components"]["inventoryitem"]["atlasname"] = "images/hh_icon/hh_weapon.xml"
        if _Bu__g_[_BUG_] and _Bu__g_[_BUG_]["start_fn"] then
            _Bu__g_[_BUG_]["start_fn"](_b_ug)
        end
        return _b_ug
    end
    RegisterInventoryItemAtlas("images/hh_icon/hh_weapon.xml", _BUG_ .. ".tex")
    return Prefab(_BUG_, _B_Ug_, __bu_G__)
end
local function _bU__G(bU__G_, _b_Ug, B__U__G_, b_U__G_)
    local function _b_u_g(__b_u__g, __B__U_G__)
        if b_U__G_ then
        end
        __B__U_G__["AnimState"]:OverrideSymbol("swap_object", "hh_weapon", bU__G_)
        __B__U_G__["AnimState"]:Show "ARM_carry"
        __B__U_G__["AnimState"]:Hide "ARM_normal"
        _B__U__G_(__b_u__g, __B__U_G__, (351 * 148 + 121 * 202 * 56 ~= 1420710))
        if __b_u__g["fx0"] ~= nil then
            __b_u__g["fx0"]:Remove()
            __b_u__g["fx0"] = nil
        end
        __b_u__g["fx0"] = SpawnPrefab "cane_victorian_fx"
        if __b_u__g["fx0"] then
            __b_u__g["fx0"]["entity"]:AddFollower()
            __b_u__g["fx0"]["entity"]:SetParent(__B__U_G__["entity"])
            __b_u__g["fx0"]["Follower"]:FollowSymbol(__B__U_G__["GUID"], "swap_object", 0, -60, 0)
        end
        local b__uG__ = __B__U_G__:SpawnChild "sparks2_fx"
        if b__uG__ then
            __B__U_G__:AddChild(b__uG__)
            b__uG__["Transform"]:SetPosition(0, 0, 0)
            __B__U_G__["fx1"] = b__uG__
        end
        local Bug_ = __B__U_G__:SpawnChild "sparks1_fx"
        if Bug_ then
            __B__U_G__:AddChild(b__uG__)
            Bug_["Transform"]:SetPosition(0, -1, 0)
            __B__U_G__["fx2"] = Bug_
        end
        __B_U__g(__b_u__g, __B__U_G__)
    end
    local function bu__g(__B_u__g__, __BUg)
        __BUg["AnimState"]:Hide "ARM_carry"
        __BUg["AnimState"]:Show "ARM_normal"
        _B__U__G_(__B_u__g__, __BUg, (478 + 353 - 341 - 35 * 64 == -1748))
        if __B_u__g__["fx0"] ~= nil then
            __B_u__g__["fx0"]:Remove()
            __B_u__g__["fx0"] = nil
        end
        if __BUg["fx1"] then
            __BUg:RemoveChild(__BUg["fx1"])
            __BUg["fx1"]:Remove()
            __BUg["fx1"] = nil
        end
        if __BUg["fx2"] then
            __BUg:RemoveChild(__BUg["fx2"])
            __BUg["fx2"]:Remove()
            __BUg["fx2"] = nil
        end
        __B_U__g(__B_u__g__, nil)
    end
    local function __BUg_()
        local B__U__G__ = CreateEntity()
        B__U__G__["entity"]:AddTransform()
        B__U__G__["entity"]:AddAnimState()
        B__U__G__["entity"]:AddSoundEmitter()
        B__U__G__["entity"]:AddNetwork()
        B__U__G__["entity"]:AddMiniMapEntity()
        B__U__G__["MiniMapEntity"]:SetIcon(bU__G_ .. ".tex")
        B__U__G__["AnimState"]:SetBank "hh_weapon"
        B__U__G__["AnimState"]:SetBuild "hh_weapon"
        B__U__G__["AnimState"]:PlayAnimation(bU__G_, (253 - 392 + 495 + 429 == 785))
        B__U__G__:AddTag "weapon"
        B__U__G__:AddTag "sharp"
        MakeInventoryPhysics(B__U__G__)
        MakeInventoryFloatable(B__U__G__, "med", 0.3, 0.8)
        B__U__G__["entity"]:SetPristine()
        if _Bu__g_[bU__G_] and _Bu__g_[bU__G_]["client_fn"] then
            _Bu__g_[bU__G_]["client_fn"](B__U__G__)
        end
        if not TheWorld["ismastersim"] then
            return B__U__G__
        end
        B__U__G__:AddComponent "inspectable"
        B__U__G__:AddComponent "equippable"
        B__U__G__["components"]["equippable"]:SetOnEquip(_b_u_g)
        B__U__G__["components"]["equippable"]:SetOnUnequip(bu__g)
        B__U__G__:AddComponent "talker"
        B__U__G__["components"]["talker"]["fontsize"] = 28
        B__U__G__["components"]["talker"]["colour"] = Vector3(0 / 255, 191 / 255, 250 / 255, 1)
        B__U__G__:AddComponent "weapon"
        if B__U__G_ then
            B__U__G__["components"]["weapon"]:SetRange(B__U__G_, B__U__G_ + 1)
        else
            B__U__G__["components"]["weapon"]:SetRange(1, 2)
        end
        B__U__G__["hh_damage"] = _b_Ug or 20
        B__U__G__["components"]["weapon"]:SetDamage(B__U__G__["hh_damage"])
        B__U__G__["base_damage"] = 51
        local _Bu_g__ = B__U__G__:AddComponent "planardamage"
        _Bu_g__:SetBaseDamage(TUNING["SWORD_LUNARPLANT_PLANAR_DAMAGE"])
        local b__u_G__ = B__U__G__:AddComponent "damagetypebonus"
        b__u_G__:AddBonus("lunar_aligned", B__U__G__, TUNING["WEAPONS_VOIDCLOTH_VS_LUNAR_BONUS"])
        B__U__G__:AddComponent "shadowlevel"
        B__U__G__["components"]["shadowlevel"]:SetDefaultLevel(TUNING["VOIDCLOTH_SCYTHE_SHADOW_LEVEL"])
        B__U__G__:AddComponent "inventoryitem"
        B__U__G__["components"]["inventoryitem"]["imagename"] = bU__G_
        B__U__G__["components"]["inventoryitem"]["atlasname"] = "images/hh_icon/hh_weapon.xml"
        if _Bu__g_[bU__G_] and _Bu__g_[bU__G_]["start_fn"] then
            _Bu__g_[bU__G_]["start_fn"](B__U__G__)
        end
        return B__U__G__
    end
    RegisterInventoryItemAtlas("images/hh_icon/hh_weapon.xml", bU__G_ .. ".tex")
    return Prefab(bU__G_, __BUg_, __bu_G__)
end
local function _b__ug_(__bUg__, b_ug_, _Bu__G_, B__U_g_)
    local function B__U__g_(bU__g_, _B_u_G__)
        if B__U_g_ then
        end
        _B_u_G__["AnimState"]:OverrideSymbol("swap_object", "hh_weapon", __bUg__)
        _B_u_G__["AnimState"]:Show "ARM_carry"
        _B_u_G__["AnimState"]:Hide "ARM_normal"
        _B__U__G_(bU__g_, _B_u_G__, (353 - 276 * 385 - 151 == -106058))
        if bU__g_["fx0"] ~= nil then
            bU__g_["fx0"]:Remove()
            bU__g_["fx0"] = nil
        end
        bU__g_["fx0"] = SpawnPrefab "cane_victorian_fx"
        if bU__g_["fx0"] then
            bU__g_["fx0"]["entity"]:AddFollower()
            bU__g_["fx0"]["entity"]:SetParent(_B_u_G__["entity"])
            bU__g_["fx0"]["Follower"]:FollowSymbol(_B_u_G__["GUID"], "swap_object", 0, -60, 0)
        end
        local __b__u__G_ = _B_u_G__:SpawnChild "sparks2_fx"
        if __b__u__G_ then
            _B_u_G__:AddChild(__b__u__G_)
            __b__u__G_["Transform"]:SetPosition(0, 0, 0)
            _B_u_G__["fx1"] = __b__u__G_
        end
        local b_u_g__ = _B_u_G__:SpawnChild "sparks1_fx"
        if b_u_g__ then
            _B_u_G__:AddChild(__b__u__G_)
            b_u_g__["Transform"]:SetPosition(0, -1, 0)
            _B_u_G__["fx2"] = b_u_g__
        end
        bUg__(bU__g_, _B_u_G__)
    end
    local function __b_Ug_(__BuG, __b__U__G)
        __b__U__G["AnimState"]:Hide "ARM_carry"
        __b__U__G["AnimState"]:Show "ARM_normal"
        _B__U__G_(__BuG, __b__U__G, (74 * 377 + 153 * 364 - 295 ~= 83295))
        if __BuG["fx0"] ~= nil then
            __BuG["fx0"]:Remove()
            __BuG["fx0"] = nil
        end
        if __b__U__G["fx1"] then
            __b__U__G:RemoveChild(__b__U__G["fx1"])
            __b__U__G["fx1"]:Remove()
            __b__U__G["fx1"] = nil
        end
        if __b__U__G["fx2"] then
            __b__U__G:RemoveChild(__b__U__G["fx2"])
            __b__U__G["fx2"]:Remove()
            __b__U__G["fx2"] = nil
        end
        bUg__(__BuG, nil)
    end
    local function bu_G_()
        local _B__ug = CreateEntity()
        _B__ug["entity"]:AddTransform()
        _B__ug["entity"]:AddAnimState()
        _B__ug["entity"]:AddSoundEmitter()
        _B__ug["entity"]:AddNetwork()
        _B__ug["entity"]:AddMiniMapEntity()
        _B__ug["MiniMapEntity"]:SetIcon(__bUg__ .. ".tex")
        _B__ug["AnimState"]:SetBank "hh_weapon"
        _B__ug["AnimState"]:SetBuild "hh_weapon"
        _B__ug["AnimState"]:PlayAnimation(__bUg__, (474 - 16 - 348 ~= 115))
        _B__ug:AddTag "weapon"
        _B__ug:AddTag "sharp"
        MakeInventoryPhysics(_B__ug)
        MakeInventoryFloatable(_B__ug, "med", 0.3, 0.8)
        _B__ug["entity"]:SetPristine()
        if _Bu__g_[__bUg__] and _Bu__g_[__bUg__]["client_fn"] then
            _Bu__g_[__bUg__]["client_fn"](_B__ug)
        end
        if not TheWorld["ismastersim"] then
            return _B__ug
        end
        _B__ug:AddComponent "inspectable"
        _B__ug:AddComponent "equippable"
        _B__ug["components"]["equippable"]:SetOnEquip(B__U__g_)
        _B__ug["components"]["equippable"]:SetOnUnequip(__b_Ug_)
        _B__ug:AddComponent "talker"
        _B__ug["components"]["talker"]["fontsize"] = 28
        _B__ug["components"]["talker"]["colour"] = Vector3(0 / 255, 191 / 255, 250 / 255, 1)
        _B__ug:AddComponent "weapon"
        if _Bu__G_ then
            _B__ug["components"]["weapon"]:SetRange(_Bu__G_, _Bu__G_ + 1)
        else
            _B__ug["components"]["weapon"]:SetRange(1, 2)
        end
        _B__ug["hh_damage"] = b_ug_ or 20
        _B__ug["components"]["weapon"]:SetDamage(_B__ug["hh_damage"])
        _B__ug["base_damage"] = 51
        local __b__uG = _B__ug:AddComponent "planardamage"
        __b__uG:SetBaseDamage(TUNING["SWORD_LUNARPLANT_PLANAR_DAMAGE"])
        local __B_u__G = _B__ug:AddComponent "damagetypebonus"
        __B_u__G:AddBonus("shadow_aligned", _B__ug, TUNING["WEAPONS_LUNARPLANT_VS_SHADOW_BONUS"])
        _B__ug:AddComponent "lunarplant_tentacle_weapon"
        _B__ug:AddComponent "inventoryitem"
        _B__ug["components"]["inventoryitem"]["imagename"] = __bUg__
        _B__ug["components"]["inventoryitem"]["atlasname"] = "images/hh_icon/hh_weapon.xml"
        if _Bu__g_[__bUg__] and _Bu__g_[__bUg__]["start_fn"] then
            _Bu__g_[__bUg__]["start_fn"](_B__ug)
        end
        return _B__ug
    end
    RegisterInventoryItemAtlas("images/hh_icon/hh_weapon.xml", __bUg__ .. ".tex")
    return Prefab(__bUg__, bu_G_, __bu_G__)
end
local function _buG_(b_ug, BU_G, _B_u_G_, b_u_G__)
    local function B__U_g__(b_u__g_, B__uG)
        if b_u_G__ then
        end
        B__uG["AnimState"]:OverrideSymbol("swap_object", "hh_daogam3", "swap")
        B__uG["AnimState"]:Show "ARM_carry"
        B__uG["AnimState"]:Hide "ARM_normal"
        _B__U__G_(
            b_u__g_,
            B__uG,
            (false and not false or not false and false and not true and not false and false or false or not true or
                true and not false)
        )
        if b_u__g_["fx00"] ~= nil then
            b_u__g_["fx00"]:Remove()
            b_u__g_["fx00"] = nil
        end
        b_u__g_["fx00"] = SpawnPrefab("deer_ice_charge")
        if b_u__g_["fx00"] then
            b_u__g_["fx00"]["AnimState"]:SetBuild("hh_purple_deer_ice_charge")
            b_u__g_["fx00"]["entity"]:AddFollower()
            b_u__g_["fx00"]["entity"]:SetParent(B__uG["entity"])
            b_u__g_["fx00"]["Follower"]:FollowSymbol(B__uG["GUID"], "swap_object", 10, -100, 0)
        end
        if b_u__g_["fx0"] ~= nil then
            b_u__g_["fx0"]:Remove()
            b_u__g_["fx0"] = nil
        end
        b_u__g_["fx0"] = SpawnPrefab("hh_daogam_sparkle_fx")
        if b_u__g_["fx0"] then
            b_u__g_["fx0"]["entity"]:AddFollower()
            b_u__g_["fx0"]["entity"]:SetParent(B__uG["entity"])
            b_u__g_["fx0"]["Follower"]:FollowSymbol(B__uG["GUID"], "swap_object", 0, -60, 0)
        end
        local _B_U__G = B__uG:SpawnChild "sparks2_fx"
        if _B_U__G then
            _B_U__G["AnimState"]:SetBuild("hh_purple_mosling_spin_fx")
            B__uG:AddChild(_B_U__G)
            _B_U__G["Transform"]:SetPosition(0, 0, 0)
            B__uG["fx1"] = _B_U__G
        end
        local _B_u_g = B__uG:SpawnChild "sparks1_fx"
        if _B_u_g then
            _B_u_g["AnimState"]:SetBuild("hh_purple_electric_fx")
            B__uG:AddChild(_B_u_g)
            _B_u_g["Transform"]:SetPosition(0, -1, 0)
            B__uG["fx2"] = _B_u_g
        end
        bUg__(b_u__g_, B__uG)
    end
    local function _bu_g(__b__ug, __b_u__G_)
        __b_u__G_["AnimState"]:Hide "ARM_carry"
        __b_u__G_["AnimState"]:Show "ARM_normal"
        _B__U__G_(
            __b__ug,
            __b_u__G_,
            (true and false and not false and false or not true and true and false and not false and not false)
        )
        if __b__ug["fx00"] ~= nil then
            __b__ug["fx00"]:Remove()
            __b__ug["fx00"] = nil
        end
        if __b__ug["fx0"] ~= nil then
            __b__ug["fx0"]:Remove()
            __b__ug["fx0"] = nil
        end
        if __b_u__G_["fx1"] then
            __b_u__G_:RemoveChild(__b_u__G_["fx1"])
            __b_u__G_["fx1"]:Remove()
            __b_u__G_["fx1"] = nil
        end
        if __b_u__G_["fx2"] then
            __b_u__G_:RemoveChild(__b_u__G_["fx2"])
            __b_u__G_["fx2"]:Remove()
            __b_u__G_["fx2"] = nil
        end
        bUg__(__b__ug, nil)
    end
    local function __B__u_G()
        local _b_U_G = CreateEntity()
        _b_U_G["entity"]:AddTransform()
        _b_U_G["entity"]:AddAnimState()
        _b_U_G["entity"]:AddSoundEmitter()
        _b_U_G["entity"]:AddNetwork()
        _b_U_G["entity"]:AddMiniMapEntity()
        _b_U_G["MiniMapEntity"]:SetIcon("hh_daogam3.tex")
        _b_U_G["AnimState"]:SetBank("xd_skin_xuanyuan")
        _b_U_G["AnimState"]:SetBuild("hh_daogam3")
        _b_U_G["AnimState"]:PlayAnimation("idle", true)
        _b_U_G:AddTag "weapon"
        _b_U_G:AddTag "sharp"
        MakeInventoryPhysics(_b_U_G)
        MakeInventoryFloatable(_b_U_G, "med", 0.3, 0.8)
        _b_U_G["entity"]:SetPristine()
        if _Bu__g_[b_ug] and _Bu__g_[b_ug]["client_fn"] then
            _Bu__g_[b_ug]["client_fn"](_b_U_G)
        end
        if not TheWorld["ismastersim"] then
            return _b_U_G
        end
        _b_U_G:AddComponent "inspectable"
        _b_U_G:AddComponent "equippable"
        _b_U_G["components"]["equippable"]:SetOnEquip(B__U_g__)
        _b_U_G["components"]["equippable"]:SetOnUnequip(_bu_g)
        _b_U_G:AddComponent "talker"
        _b_U_G["components"]["talker"]["fontsize"] = 28
        _b_U_G["components"]["talker"]["colour"] = Vector3(0 / 255, 191 / 255, 250 / 255, 1)
        _b_U_G:AddComponent "weapon"
        if _B_u_G_ then
            _b_U_G["components"]["weapon"]:SetRange(_B_u_G_, _B_u_G_ + 1)
        else
            _b_U_G["components"]["weapon"]:SetRange(1, 2)
        end
        _b_U_G["hh_damage"] = BU_G or 20
        _b_U_G["components"]["weapon"]:SetDamage(_b_U_G["hh_damage"])
        _b_U_G["base_damage"] = 10
        local bu__G_ = _b_U_G:AddComponent "planardamage"
        bu__G_:SetBaseDamage(TUNING["SWORD_LUNARPLANT_PLANAR_DAMAGE"] / 3)
        local _b_u_g__ = _b_U_G:AddComponent "damagetypebonus"
        _b_u_g__:AddBonus("shadow_aligned", _b_U_G, TUNING["WEAPONS_LUNARPLANT_VS_SHADOW_BONUS"])
        _b_u_g__:AddBonus("lunar_aligned", _b_U_G, TUNING["WEAPONS_VOIDCLOTH_VS_LUNAR_BONUS"])
        _b_U_G:AddTag("shadowalign")
        _b_U_G:AddTag("lunaralign")
        _b_U_G:AddTag("hh_daogam3_item")
        _b_U_G:AddComponent "lunarplant_tentacle_weapon"
        _b_U_G:AddComponent "inventoryitem"
        _b_U_G["components"]["inventoryitem"]["imagename"] = "hh_daogam3"
        _b_U_G["components"]["inventoryitem"]["atlasname"] = "images/inventoryimages/hh_daogam3.xml"
        if _Bu__g_[b_ug] and _Bu__g_[b_ug]["start_fn"] then
            _Bu__g_[b_ug]["start_fn"](_b_U_G)
        end
        return _b_U_G
    end
    RegisterInventoryItemAtlas("images/inventoryimages/hh_daogam3.xml", "hh_daogam3.tex")
    return Prefab(b_ug, __B__u_G, __bu_G__)
end
local function __b_Ug(_b__u_g__, B__UG__, _B__u_g_, b_U__G__)
    local function _b_uG_(b__U__g__, __B_uG)
        if b__U__g__.components.finiteuses ~= nil and b__U__g__.components.finiteuses:GetPercent() < 0.01 then
            b__U__g__:DoTaskInTime(0, function()
                if __B_uG ~= nil and __B_uG.components.inventory ~= nil and b__U__g__.components.equippable ~= nil then
                    local item = __B_uG.components.inventory:Unequip(b__U__g__.components.equippable.equipslot)
                    if item ~= nil then
                        __B_uG.components.inventory:GiveItem(item)
                    end
                    if __B_uG.components.talker ~= nil then
                        __B_uG.components.talker:Say("Kiếm chưa được sửa chữa, không thể cầm lên!")
                    end
                end
            end)
            return
        end
        if b_U__G__ then
        end
        __B_uG["AnimState"]:OverrideSymbol("swap_object", "hh_weapon", _b__u_g__)
        __B_uG["AnimState"]:Show "ARM_carry"
        __B_uG["AnimState"]:Hide "ARM_normal"
        _B__U__G_(b__U__g__, __B_uG, (310 + 78 + 113 == 501))
        if b__U__g__["fx00"] ~= nil then
            b__U__g__["fx00"]:Remove()
            b__U__g__["fx00"] = nil
        end
        if b__U__g__["fx0"] ~= nil then
            b__U__g__["fx0"]:Remove()
            b__U__g__["fx0"] = nil
        end
        if b__U__g__["fx00"] ~= nil then
            b__U__g__["fx00"]:Remove()
            b__U__g__["fx00"] = nil
        end
        b__U__g__["fx00"] = SpawnPrefab "deer_ice_charge"
        if b__U__g__["fx00"] then
            b__U__g__["fx00"]["entity"]:AddFollower()
            b__U__g__["fx00"]["entity"]:SetParent(__B_uG["entity"])
            b__U__g__["fx00"]["Follower"]:FollowSymbol(__B_uG["GUID"], "swap_object", 10, -100, 0)
        end
        if b__U__g__["fx0"] ~= nil then
            b__U__g__["fx0"]:Remove()
            b__U__g__["fx0"] = nil
        end
        b__U__g__["fx0"] = SpawnPrefab "cane_victorian_fx"
        if b__U__g__["fx0"] then
            b__U__g__["fx0"]["entity"]:AddFollower()
            b__U__g__["fx0"]["entity"]:SetParent(__B_uG["entity"])
            b__U__g__["fx0"]["Follower"]:FollowSymbol(__B_uG["GUID"], "swap_object", 0, -60, 0)
        end
        local __Bu__g = __B_uG:SpawnChild "sparks2_fx"
        if __Bu__g then
            __B_uG:AddChild(__Bu__g)
            __Bu__g["Transform"]:SetPosition(0, 0, 0)
            __B_uG["fx1"] = __Bu__g
        end
        local __B__u_G__ = __B_uG:SpawnChild "sparks1_fx"
        if __B__u_G__ then
            __B_uG:AddChild(__Bu__g)
            __B__u_G__["Transform"]:SetPosition(0, -1, 0)
            __B_uG["fx2"] = __B__u_G__
        end
    end
    local function BU__G__(_bu__g_, _b_U_G__)
        _b_U_G__["AnimState"]:Hide "ARM_carry"
        _b_U_G__["AnimState"]:Show "ARM_normal"
        _B__U__G_(_bu__g_, _b_U_G__, (370 * 328 - 168 * 251 == 79200))
        if _bu__g_["fx00"] ~= nil then
            _bu__g_["fx00"]:Remove()
            _bu__g_["fx00"] = nil
        end
        if _bu__g_["fx0"] ~= nil then
            _bu__g_["fx0"]:Remove()
            _bu__g_["fx0"] = nil
        end
        if _b_U_G__["fx1"] then
            _b_U_G__:RemoveChild(_b_U_G__["fx1"])
            _b_U_G__["fx1"]:Remove()
            _b_U_G__["fx1"] = nil
        end
        if _b_U_G__["fx2"] then
            _b_U_G__:RemoveChild(_b_U_G__["fx2"])
            _b_U_G__["fx2"]:Remove()
            _b_U_G__["fx2"] = nil
        end
    end
    local function _B_U__g()
        local __Bu_G = CreateEntity()
        __Bu_G["entity"]:AddTransform()
        __Bu_G["entity"]:AddAnimState()
        __Bu_G["entity"]:AddSoundEmitter()
        __Bu_G["entity"]:AddNetwork()
        __Bu_G["entity"]:AddMiniMapEntity()
        __Bu_G["MiniMapEntity"]:SetIcon(_b__u_g__ .. ".tex")
        __Bu_G["AnimState"]:SetBank "hh_weapon"
        __Bu_G["AnimState"]:SetBuild "hh_weapon"
        __Bu_G["AnimState"]:PlayAnimation(_b__u_g__, (328 + 403 * 401 + 14 == 161945))
        __Bu_G:AddTag "weapon"
        __Bu_G:AddTag "sharp"
        MakeInventoryPhysics(__Bu_G)
        MakeInventoryFloatable(__Bu_G, "med", 0.3, 0.8)
        __Bu_G["entity"]:SetPristine()
        if _Bu__g_[_b__u_g__] and _Bu__g_[_b__u_g__]["client_fn"] then
            _Bu__g_[_b__u_g__]["client_fn"](__Bu_G)
        end
        if not TheWorld["ismastersim"] then
            return __Bu_G
        end
        __Bu_G:AddComponent "inspectable"
        __Bu_G:AddComponent "equippable"
        __Bu_G["components"]["equippable"]:SetOnEquip(_b_uG_)
        __Bu_G["components"]["equippable"]:SetOnUnequip(BU__G__)
        __Bu_G:AddComponent "talker"
        __Bu_G["components"]["talker"]["fontsize"] = 28
        __Bu_G["components"]["talker"]["colour"] = Vector3(0 / 255, 191 / 255, 250 / 255, 1)
        __Bu_G:AddComponent "weapon"
        if _B__u_g_ then
            __Bu_G["components"]["weapon"]:SetRange(_B__u_g_, _B__u_g_ + 1)
        else
            __Bu_G["components"]["weapon"]:SetRange(1, 2)
        end
        __Bu_G["hh_damage"] = 0
        __Bu_G["components"]["weapon"]:SetDamage(__Bu_G["hh_damage"])
        __Bu_G["base_damage"] = 0
        local B_U_g__ = __Bu_G:AddComponent "planardamage"
        B_U_g__:SetBaseDamage(0)
        __Bu_G:AddComponent "inventoryitem"
        __Bu_G["components"]["inventoryitem"]["imagename"] = _b__u_g__
        __Bu_G["components"]["inventoryitem"]["atlasname"] = "images/hh_icon/hh_weapon.xml"
        if _Bu__g_[_b__u_g__] and _Bu__g_[_b__u_g__]["start_fn"] then
            _Bu__g_[_b__u_g__]["start_fn"](__Bu_G)
        end
        return __Bu_G
    end
    RegisterInventoryItemAtlas("images/hh_icon/hh_weapon.xml", _b__u_g__ .. ".tex")
    return Prefab(_b__u_g__, _B_U__g, __bu_G__)
end
local function B__u_G(__B_uG__, buG, __BU_g__, _b_u__g__)
    local function b_u_g(bUg, _B_ug__)
        if _b_u__g__ then
        end
        _B_ug__["AnimState"]:OverrideSymbol("swap_object", "swap_walking_stick", "swap_object")
        _B_ug__["AnimState"]:Show "ARM_carry"
        _B_ug__["AnimState"]:Hide "ARM_normal"
        if _B_ug__["components"]["maprevealable"] ~= nil then
            _B_ug__["components"]["maprevealable"]:AddRevealSource(bUg, "compassbearer")
        end
        _B_ug__:AddTag "compassbearer"
        _B__U__G_(bUg, _B_ug__, (403 + 233 * 400 + 284 ~= 93896))
    end
    local function bu__G__(_b__U_G__, bug)
        bug["AnimState"]:Hide "ARM_carry"
        bug["AnimState"]:Show "ARM_normal"
        if bug["components"]["maprevealable"] ~= nil then
            bug["components"]["maprevealable"]:RemoveRevealSource(_b__U_G__)
        end
        bug:RemoveTag "compassbearer"
        _B__U__G_(_b__U_G__, bug, (184 * 184 - 61 == 33799))
    end
    local function __B__u__G()
        local _b__ug__ = CreateEntity()
        _b__ug__["entity"]:AddTransform()
        _b__ug__["entity"]:AddAnimState()
        _b__ug__["entity"]:AddSoundEmitter()
        _b__ug__["entity"]:AddNetwork()
        _b__ug__["entity"]:AddMiniMapEntity()
        _b__ug__["AnimState"]:SetBank "walking_stick"
        _b__ug__["AnimState"]:SetBuild "walking_stick"
        _b__ug__["AnimState"]:PlayAnimation "idle"
        _b__ug__:AddTag "weapon"
        _b__ug__:AddTag "sharp"
        MakeInventoryPhysics(_b__ug__)
        MakeInventoryFloatable(_b__ug__, "med", 0.3, 0.8)
        _b__ug__["entity"]:SetPristine()
        if _Bu__g_[__B_uG__] and _Bu__g_[__B_uG__]["client_fn"] then
            _Bu__g_[__B_uG__]["client_fn"](_b__ug__)
        end
        if not TheWorld["ismastersim"] then
            return _b__ug__
        end
        _b__ug__:AddComponent "inspectable"
        _b__ug__:AddComponent "equippable"
        _b__ug__["components"]["equippable"]:SetOnEquip(b_u_g)
        _b__ug__["components"]["equippable"]:SetOnUnequip(bu__G__)
        _b__ug__["components"]["equippable"]["walkspeedmult"] = 1.25
        _b__ug__:AddComponent "talker"
        _b__ug__["components"]["talker"]["fontsize"] = 28
        _b__ug__["components"]["talker"]["colour"] = Vector3(0 / 255, 191 / 255, 250 / 255, 1)
        _b__ug__:AddComponent "weapon"
        if __BU_g__ then
            _b__ug__["components"]["weapon"]:SetRange(__BU_g__, __BU_g__ + 1)
        else
            _b__ug__["components"]["weapon"]:SetRange(1, 2)
        end
        _b__ug__["hh_damage"] = buG or 20
        _b__ug__["components"]["weapon"]:SetDamage(_b__ug__["hh_damage"])
        _b__ug__:AddComponent "inventoryitem"
        _b__ug__["components"]["inventoryitem"]["imagename"] = "nn_staff_dis"
        _b__ug__["components"]["inventoryitem"]["atlasname"] = "images/nn_staff_dis.xml"
        if _Bu__g_[__B_uG__] and _Bu__g_[__B_uG__]["start_fn"] then
            _Bu__g_[__B_uG__]["start_fn"](_b__ug__)
        end
        return _b__ug__
    end
    RegisterInventoryItemAtlas("images/nn_staff_dis.xml", "nn_staff_dis.tex")
    return Prefab(__B_uG__, __B__u__G, __b__ug__)
end
local function __b__u_G__(B_ug_, __Bu__G, __b_ug_, B_u_g)
    local function __B__ug(__buG, _B__U_G)
        if B_u_g then
        end
        _B__U_G["AnimState"]:OverrideSymbol("swap_object", "swap_dn", "swap_dn")
        _B__U_G["AnimState"]:Show "ARM_carry"
        _B__U_G["AnimState"]:Hide "ARM_normal"
        _B__U__G_(__buG, _B__U_G, (478 - 264 - 441 == -227))
    end
    local function __b__Ug__(_b_Ug__, B__U__g__)
        B__U__g__["AnimState"]:Hide "ARM_carry"
        B__U__g__["AnimState"]:Show "ARM_normal"
        _B__U__G_(_b_Ug__, B__U__g__, (362 * 138 + 387 + 195 - 67 ~= 50471))
    end
    local function _BuG__()
        local _B__u_G_ = CreateEntity()
        _B__u_G_["entity"]:AddTransform()
        _B__u_G_["entity"]:AddAnimState()
        _B__u_G_["entity"]:AddSoundEmitter()
        _B__u_G_["entity"]:AddNetwork()
        _B__u_G_["entity"]:AddMiniMapEntity()
        _B__u_G_["MiniMapEntity"]:SetIcon "nn_sword.tex"
        _B__u_G_["AnimState"]:SetBank "dn"
        _B__u_G_["AnimState"]:SetBuild "dn"
        _B__u_G_["AnimState"]:PlayAnimation "idle"
        _B__u_G_:AddTag "weapon"
        _B__u_G_:AddTag "sharp"
        MakeInventoryPhysics(_B__u_G_)
        MakeInventoryFloatable(_B__u_G_, "med", 0.3, 0.8)
        _B__u_G_["Transform"]:SetScale(1.2, 1.2, 1.2)
        _B__u_G_["entity"]:SetPristine()
        if _Bu__g_[B_ug_] and _Bu__g_[B_ug_]["client_fn"] then
            _Bu__g_[B_ug_]["client_fn"](_B__u_G_)
        end
        if not TheWorld["ismastersim"] then
            return _B__u_G_
        end
        _B__u_G_:AddComponent "inspectable"
        _B__u_G_:AddComponent "equippable"
        _B__u_G_["components"]["equippable"]:SetOnEquip(__B__ug)
        _B__u_G_["components"]["equippable"]:SetOnUnequip(__b__Ug__)
        _B__u_G_:AddComponent "talker"
        _B__u_G_["components"]["talker"]["fontsize"] = 28
        _B__u_G_["components"]["talker"]["colour"] = Vector3(0 / 255, 191 / 255, 250 / 255, 1)
        _B__u_G_:AddComponent "weapon"
        if __b_ug_ then
            _B__u_G_["components"]["weapon"]:SetRange(__b_ug_, __b_ug_ + 1)
        else
            _B__u_G_["components"]["weapon"]:SetRange(1, 2)
        end
        _B__u_G_["hh_damage"] = __Bu__G or 20
        _B__u_G_["components"]["weapon"]:SetDamage(_B__u_G_["hh_damage"])
        _B__u_G_:AddComponent "inventoryitem"
        _B__u_G_["components"]["inventoryitem"]["imagename"] = "nn_sword"
        _B__u_G_["components"]["inventoryitem"]["atlasname"] = "images/nn_sword.xml"
        if _Bu__g_[B_ug_] and _Bu__g_[B_ug_]["start_fn"] then
            _Bu__g_[B_ug_]["start_fn"](_B__u_G_)
        end
        return _B__u_G_
    end
    RegisterInventoryItemAtlas("images/nn_sword.xml", "nn_sword.tex")
    return Prefab(B_ug_, _BuG__, b__U_g__)
end

local function MakeHHDaogam4()
    local assets = {
        Asset("ANIM", "anim/nn_staff_fire.zip"),
        Asset("ANIM", "anim/swap_nn_staff_fire.zip"),
        Asset("IMAGE", "images/hh_daogam4.tex"),
        Asset("ATLAS", "images/hh_daogam4.xml"),
    }
    local function onequip(inst, owner)
        if inst.components.finiteuses ~= nil and inst.components.finiteuses:GetPercent() < 0.01 then
            inst:DoTaskInTime(0, function()
                if owner ~= nil and owner.components.inventory ~= nil and inst.components.equippable ~= nil then
                    local item = owner.components.inventory:Unequip(inst.components.equippable.equipslot)
                    if item ~= nil then
                        owner.components.inventory:GiveItem(item)
                        if owner.components.talker ~= nil then
                            owner.components.talker:Say("Không thể cầm khi độ bền bằng 0!")
                        end
                    end
                end
            end)
            return
        end
        owner["AnimState"]:OverrideSymbol("swap_object", "swap_soulstaff", "swap_soulstaff")
        owner["AnimState"]:Show "ARM_carry"
        owner["AnimState"]:Hide "ARM_normal"
        if inst.fx00 ~= nil then
            inst.fx00:Remove()
            inst.fx00 = nil
        end
        inst.fx00 = SpawnPrefab("deer_ice_charge")
        if inst.fx00 then
            inst.fx00.AnimState:SetBuild("hh_purple_deer_ice_charge")
            inst.fx00.entity:AddFollower()
            inst.fx00.entity:SetParent(owner.entity)
            inst.fx00.Follower:FollowSymbol(owner.GUID, "swap_object", 10, -100, 0)
        end
        if inst.fx0 ~= nil then
            inst.fx0:Remove()
            inst.fx0 = nil
        end
        inst.fx0 = SpawnPrefab("hh_daogam_sparkle_fx")
        if inst.fx0 then
            inst.fx0.entity:AddFollower()
            inst.fx0.entity:SetParent(owner.entity)
            inst.fx0.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -60, 0)
        end
        local sparks2 = owner:SpawnChild("sparks2_fx")
        if sparks2 then
            sparks2.AnimState:SetBuild("hh_purple_mosling_spin_fx")
            owner:AddChild(sparks2)
            sparks2.Transform:SetPosition(0, 0, 0)
            owner.fx1 = sparks2
        end
        local sparks1 = owner:SpawnChild("sparks1_fx")
        if sparks1 then
            sparks1.AnimState:SetBuild("hh_purple_electric_fx")
            owner:AddChild(sparks1)
            sparks1.Transform:SetPosition(0, -1, 0)
            owner.fx2 = sparks1
        end
    end
    local function onunequip(inst, owner)
        owner["AnimState"]:Hide "ARM_carry"
        owner["AnimState"]:Show "ARM_normal"
        if inst.fx00 ~= nil then
            inst.fx00:Remove()
            inst.fx00 = nil
        end
        if inst.fx0 ~= nil then
            inst.fx0:Remove()
            inst.fx0 = nil
        end
        if owner.fx1 then
            owner:RemoveChild(owner.fx1)
            owner.fx1:Remove()
            owner.fx1 = nil
        end
        if owner.fx2 then
            owner:RemoveChild(owner.fx2)
            owner.fx2:Remove()
            owner.fx2 = nil
        end
    end
    local function fn()
        local inst = CreateEntity()
        inst["entity"]:AddTransform()
        inst["entity"]:AddAnimState()
        inst["entity"]:AddSoundEmitter()
        inst["entity"]:AddNetwork()
        inst["entity"]:AddMiniMapEntity()
        inst["AnimState"]:SetBank "soulstaff"
        inst["AnimState"]:SetBuild "soulstaff"
        inst["AnimState"]:PlayAnimation "idle"
        inst:AddTag "weapon"
        inst:AddTag "sharp"
        MakeInventoryPhysics(inst)
        MakeInventoryFloatable(inst, "med", 0.3, 0.8)
        inst["entity"]:SetPristine()
        if _Bu__g_["hh_daogam4"] and _Bu__g_["hh_daogam4"]["client_fn"] then
            _Bu__g_["hh_daogam4"]["client_fn"](inst)
        end
        if not TheWorld["ismastersim"] then
            return inst
        end
        inst:AddComponent "inspectable"
        inst:AddComponent "equippable"
        inst["components"]["equippable"]:SetOnEquip(onequip)
        inst["components"]["equippable"]:SetOnUnequip(onunequip)
        inst["components"]["equippable"]["walkspeedmult"] = 1.15
        inst:AddComponent "talker"
        inst["components"]["talker"]["fontsize"] = 28
        inst["components"]["talker"]["colour"] = Vector3(0 / 255, 191 / 255, 250 / 255, 1)
        inst:AddComponent "weapon"
        inst["components"]["weapon"]:SetRange(8, 10)
        inst["hh_damage"] = 55
        inst["components"]["weapon"]:SetDamage(inst["hh_damage"])

        local bu__G_ = inst:AddComponent "planardamage"
        bu__G_:SetBaseDamage(TUNING["SWORD_LUNARPLANT_PLANAR_DAMAGE"] / 3)
        local _b_u_g__ = inst:AddComponent "damagetypebonus"
        _b_u_g__:AddBonus("shadow_aligned", inst, TUNING["WEAPONS_LUNARPLANT_VS_SHADOW_BONUS"])
        _b_u_g__:AddBonus("lunar_aligned", inst, TUNING["WEAPONS_VOIDCLOTH_VS_LUNAR_BONUS"])
        inst:AddTag("shadowalign")
        inst:AddTag("lunaralign")
        inst:AddTag("hh_daogam4_item")

        inst:AddComponent "inventoryitem"
        inst["components"]["inventoryitem"]["imagename"] = "hh_daogam4"
        inst["components"]["inventoryitem"]["atlasname"] = "images/hh_daogam4.xml"
        if _Bu__g_["hh_daogam4"] and _Bu__g_["hh_daogam4"]["start_fn"] then
            _Bu__g_["hh_daogam4"]["start_fn"](inst)
        end
        return inst
    end
    RegisterInventoryItemAtlas("images/hh_daogam4.xml", "hh_daogam4.tex")
    return Prefab("hh_daogam4", fn, assets)
end

local function make_hh_daogam5()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("hh_daogam5.tex")
    inst.AnimState:SetBank("hh_daogam5")
    inst.AnimState:SetBuild("hh_daogam5")
    inst.AnimState:PlayAnimation("idle", true)
    inst:AddTag("weapon")
    inst:AddTag("sharp")
    inst:AddTag("shadowalign")
    inst:AddTag("lunaralign")
    inst:AddTag("hh_daogam5_item")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "med", 0.3, 0.8)
    inst.entity:SetPristine()
    
    if _Bu__g_["hh_daogam5"] and _Bu__g_["hh_daogam5"]["client_fn"] then
        _Bu__g_["hh_daogam5"]["client_fn"](inst)
    end
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    inst:AddComponent("equippable")
    
    inst.components.equippable:SetOnEquip(function(inst, owner)
        inst:DoTaskInTime(0, function()
            if inst.components.finiteuses and inst.components.finiteuses:GetUses() <= 0 then
                local item = owner.components.inventory:Unequip(inst.components.equippable.equipslot)
                if item ~= nil then
                    owner.components.inventory:GiveItem(item)
                end
                if owner.components.talker ~= nil then
                    owner.components.talker:Say("Kiếm chưa được sửa chữa, không thể cầm lên!")
                end
                return
            end
        end)

        owner.AnimState:OverrideSymbol("swap_object", "hh_daogam5", "swap")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
        if inst.fx00 ~= nil then
            inst.fx00:Remove()
            inst.fx00 = nil
        end
        inst.fx00 = SpawnPrefab("deer_ice_charge")
        if inst.fx00 then
            inst.fx00.AnimState:SetBuild("hh_purple_deer_ice_charge")
            inst.fx00.entity:AddFollower()
            inst.fx00.entity:SetParent(owner.entity)
            inst.fx00.Follower:FollowSymbol(owner.GUID, "swap_object", 10, -100, 0)
        end
        if inst.fx0 ~= nil then inst.fx0:Remove() inst.fx0 = nil end
        inst.fx0 = SpawnPrefab("hh_daogam_sparkle_fx")
        if inst.fx0 then
            inst.fx0.entity:AddFollower()
            inst.fx0.entity:SetParent(owner.entity)
            inst.fx0.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -60, 0)
        end
        local sparks2 = owner:SpawnChild("sparks2_fx")
        if sparks2 then
            sparks2.AnimState:SetBuild("hh_purple_mosling_spin_fx")
            owner:AddChild(sparks2)
            sparks2.Transform:SetPosition(0, 0, 0)
            owner.fx1 = sparks2
        end
        local sparks1 = owner:SpawnChild("sparks1_fx")
        if sparks1 then
            sparks1.AnimState:SetBuild("hh_purple_electric_fx")
            owner:AddChild(sparks1)
            sparks1.Transform:SetPosition(0, -1, 0)
            owner.fx2 = sparks1
        end
    end)
    
    inst.components.equippable:SetOnUnequip(function(inst, owner)
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
        if inst.fx00 ~= nil then inst.fx00:Remove() inst.fx00 = nil end
        if inst.fx0 ~= nil then inst.fx0:Remove() inst.fx0 = nil end
        if owner.fx1 then owner:RemoveChild(owner.fx1) owner.fx1:Remove() owner.fx1 = nil end
        if owner.fx2 then owner:RemoveChild(owner.fx2) owner.fx2:Remove() owner.fx2 = nil end
    end)
    
    inst:AddComponent("talker")
    inst.components.talker.fontsize = 28
    inst.components.talker.colour = Vector3(0, 191/255, 250/255, 1)
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetRange(1, 2)
    inst.hh_damage = 51
    inst.components.weapon:SetDamage(51)
    inst.components.weapon:SetOnAttack(function(inst, attacker, target)
        if inst.components.finiteuses then
            inst.components.finiteuses:Use(1)
        end
    end)
    
    inst.base_damage = 51
    
    local pdamage = inst:AddComponent("planardamage")
    pdamage:SetBaseDamage(TUNING.SWORD_LUNARPLANT_PLANAR_DAMAGE)
    
    local dbonus = inst:AddComponent("damagetypebonus")
    dbonus:AddBonus("shadow_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS)
    dbonus:AddBonus("lunar_aligned", inst, TUNING.WEAPONS_VOIDCLOTH_VS_LUNAR_BONUS)
    
    inst:AddComponent("lunarplant_tentacle_weapon")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "hh_daogam5"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/hh_daogam5.xml"
    
    if _Bu__g_["hh_daogam5"] and _Bu__g_["hh_daogam5"]["start_fn"] then
        _Bu__g_["hh_daogam5"]["start_fn"](inst)
    end
    return inst
end

RegisterInventoryItemAtlas("images/inventoryimages/hh_daogam5.xml", "hh_daogam5.tex")

local assets_hh_quat_long_vu = {
    Asset("ANIM", "anim/hh_quat_long_vu.zip"),
    Asset("IMAGE", "images/inventoryimages/hh_quat_long_vu_inventory.tex"),
    Asset("ATLAS", "images/inventoryimages/hh_quat_long_vu_inventory.xml"),
}

local function make_hh_quat_long_vu()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("hh_quat_long_vu_inventory.tex")
    
    inst.AnimState:SetBank("hh_quat_long_vu")
    inst.AnimState:SetBuild("hh_quat_long_vu")
    inst.AnimState:PlayAnimation("idle", true)
    
    inst:AddTag("weapon")
    inst:AddTag("sharp")
    
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "med", 0.3, 0.8)
    inst.entity:SetPristine()
    
    if _Bu__g_["hh_quat_long_vu"] and _Bu__g_["hh_quat_long_vu"]["client_fn"] then
        _Bu__g_["hh_quat_long_vu"]["client_fn"](inst)
    end
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(function(inst, owner)
        owner.AnimState:OverrideSymbol("swap_object", "hh_quat_long_vu", "swap")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end)
    inst.components.equippable:SetOnUnequip(function(inst, owner)
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
    end)
    
    inst:AddComponent("talker")
    inst.components.talker.fontsize = 28
    inst.components.talker.colour = Vector3(0 / 255, 191 / 255, 250 / 255, 1)
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetRange(1, 2)
    inst.hh_damage = 10
    inst.components.weapon:SetDamage(inst.hh_damage)
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "hh_quat_long_vu_inventory"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/hh_quat_long_vu_inventory.xml"
    
    if _Bu__g_["hh_quat_long_vu"] and _Bu__g_["hh_quat_long_vu"]["start_fn"] then
        _Bu__g_["hh_quat_long_vu"]["start_fn"](inst)
    end
    
    return inst
end

RegisterInventoryItemAtlas("images/inventoryimages/hh_quat_long_vu_inventory.xml", "hh_quat_long_vu_inventory.tex")

return Prefab("hh_daogam5", make_hh_daogam5, __bu_G__), _buG_("hh_daogam3", 10, 6), Prefab("hh_quat_long_vu", make_hh_quat_long_vu, assets_hh_quat_long_vu), MakeHHDaogam4()
