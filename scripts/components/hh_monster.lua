local BU_g = require "utils/hh_utils"
local HHMonsterAutoStack = require "utils/hh_monster_autostack"
local __BUg_ = require "enums/hh_effects"
local _B_U_G = require "enums/hh_prefab_list"
local _BU__G__ = require "enums/hh_monster"
local b_Ug = require "enums/hh_enchant"
local b_U__g__ = b_Ug["HH_EQUIP_BUFF_LIST"]
local __b_Ug__ = _B_U_G["boss_monster"]
local _B_u__G__ = _B_U_G["endgameboss_monster"]
local __buG_ = _B_U_G["elite_monster"]
local _b__u_G = __BUg_["monster"]
local __bu_G = _B_U_G["drop_equip"]
local _B__Ug__ = TUNING["HH_CHANCE_CONFIG"]["DROP_EQUIP_CHANCE"]
local bU_G_ = require "enums/hh_treasure_monster"
local _B__u_G_ = bU_G_["TREASURE_MONSTER_CONFIG"]
local _bU_g__ = {
    ["common_monster"] = (283 - 446 - 243 ~= -399),
    ["elite_monster"] = (487 - 479 * 410 == -195903),
    ["boss_monster"] = (false and false and false and true or not false or not false or
        not true and not true and not false),
    ["endgameboss_monster"] = (false and not true and true or false and true and false or not true or not false or
        not false or
        not false and false or
        not false or
        false)
}
local function HH_AttachLootBeacon(target)
    if not target or not target:IsValid() or not target.Transform then return end

    local inst = SpawnPrefab("lavaarena_lootbeacon")
    if not inst then return end

    inst.colour = 0
    inst.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")

    local function ontargetpickedup(target_inst)
        if target_inst.AnimState then
            target_inst.AnimState:SetAddColour(0,0,0,1)
        end
        target_inst:RemoveEventCallback("onpickup", ontargetpickedup)
        target_inst:RemoveEventCallback("equipped", ontargetpickedup)
        if inst ~= nil and inst:IsValid() then
            inst.AnimState:PlayAnimation("pst")
            inst:ListenForEvent("animover", inst.Remove)
            if inst._timeouttask ~= nil then
                inst._timeouttask:Cancel()
            end
            if inst._colourfadetask ~= nil then
                inst._colourfadetask:Cancel()
            end
            if inst._colourtask ~= nil then
                inst._colourtask:Cancel()
            end
            target_inst.lootbeacon = nil
        end
    end

    inst.target = target
    target.lootbeacon = inst
    inst:Show()
    inst.AnimState:PlayAnimation("pre")
    inst.AnimState:PushAnimation("loop")
    
    target:ListenForEvent("onpickup", ontargetpickedup)
    target:ListenForEvent("equipped", ontargetpickedup)
    
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0)
    
    inst._colourtask = inst:DoPeriodicTask(0, function(inst)
        if inst.target and inst.target:IsValid() and inst.target.AnimState then
            if inst.colour < 0.5 then
                inst.target.AnimState:SetAddColour(inst.colour, inst.colour, inst.colour, 1)
                inst.colour = inst.colour + 0.05
            else
                inst._colourtask:Cancel()
                inst._colourtask = nil
            end
        else
            inst._colourtask:Cancel()
            inst._colourtask = nil
        end
    end)
    
    inst._timeouttask = inst:DoTaskInTime(10, function(inst)
        inst.AnimState:PlayAnimation("pst")
        inst._colourfadetask = inst:DoPeriodicTask(0, function(inst)
            if inst.target and inst.target:IsValid() and inst.target.AnimState then
                if inst.colour > 0 then
                    inst.target.AnimState:SetAddColour(inst.colour, inst.colour, inst.colour, 1)
                    inst.colour = inst.colour - 0.05
                else
                    inst.target.AnimState:SetAddColour(0,0,0,1)
                    inst:Remove()
                end
            else
                inst:Remove()
            end
        end)
    end)
    
    inst:ListenForEvent("onremove", function() 
        inst.entity:SetParent(nil)
        if inst.target ~= nil and inst.target:IsValid() and inst.target.AnimState then 
            inst.target.AnimState:SetAddColour(0,0,0,1) 
        end 
    end)
end
local function Bug__()
    local _b__U_g = BU_g:HHCopyTable(_b__u_G)
    local b__u__G_ = {}
    for B__u__g, b_ug_ in pairs(_b__U_g) do
        b__u__G_[B__u__g] = 0
    end
    return b__u__G_
end
local function B_U_g(__B_Ug__)
    if not BU_g:IsHHType(__B_Ug__, "string") then
        return "common_monster"
    end
    if __b_Ug__[__B_Ug__] then
        return "boss_monster"
    elseif _B_u__G__[__B_Ug__] then
        return "endgameboss_monster"
    elseif __buG_[__B_Ug__] then
        return "elite_monster"
    else
        return "common_monster"
    end
end
local function __b__UG_(_B__u_g, _BU_g_)
    if BU_g:NotIsDead(_B__u_g) and BU_g:HasComponents(_B__u_g, "hh_monster") then
        if not _B__u_g["components"]["health"]["hh_base_max"] or _B__u_g["components"]["health"]["hh_base_max"] <= 0 then
            return
        end
        local b_uG = _B__u_g["components"]["health"]:GetPercent()
        if BU_g:IsHHType(_BU_g_, "number") and _BU_g_ > 0 then
            b_uG = _BU_g_
        end
        if b_uG <= 0 then
            return
        end
        local _b__U__g = _B__u_g["components"]["health"]["hh_base_max"]
        local _BU_G_ = _B__u_g["components"]["hh_monster"]:GetEffectValueByKey "addMaxHealthNum"
        local _B_U__g__ = _B__u_g["components"]["hh_monster"]:GetEffectValueByKey "addMaxHealthPercent"
        local _B_U__G = _B__u_g["components"]["hh_monster"]:GetSpecialValue "day_add_health"
        local _B__UG_ = TheWorld and TheWorld["state"] and TheWorld["state"]["cycles"] or 0
        local _b_u__G__ = _B_U__G * math["min"](_B__UG_, TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_HEALTH_DAY"])
        _B__u_g["components"]["health"]["maxhealth"] = (_b__U__g + _BU_G_ + _b_u__G__) * (1 + _B_U__g__ / 100)
        _B__u_g["components"]["health"]:SetPercent(math["min"](b_uG, 1))
    end
end
local function _BUG__(__B__ug__)
    if not __B__ug__ or not __B__ug__["prefab"] then
        return 0
    end
    local _B_ug = BU_g:GetMonsterType(__B__ug__) or B_U_g(__B__ug__["prefab"])
    if not TUNING["HH_CHANCE_CONFIG"]["MONSTER_DAY_HEALTH"][_B_ug] then
        return 0
    end
    local _bUg_ = TUNING["HH_CHANCE_CONFIG"]["MONSTER_DAY_HEALTH"][_B_ug]["min"] or 1
    local b_u__G = TUNING["HH_CHANCE_CONFIG"]["MONSTER_DAY_HEALTH"][_B_ug]["max"] or 10
    return math["random"](_bUg_, b_u__G)
end
local function B__uG__(__B_UG__)
    if BU_g:HasComponents(__B_UG__, "hh_monster") then
        __B_UG__["components"]["hh_monster"]:StartDeadFn()
        __B_UG__["components"]["hh_monster"]:DropEquipByDead()
    end
end
local function __B__uG__(__b_U_g_, _B__Ug)
    local __BU_g__ = math["random"]() * 4 + 2
    _B__Ug = (_B__Ug + math["random"]() * 60 - 30) * DEGREES
    __b_U_g_["Physics"]:SetVel(__BU_g__ * math["cos"](_B__Ug), math["random"]() * 2 + 8, __BU_g__ * math["sin"](_B__Ug))
end
local function _b_Ug_(B_u_g_, b__U__G)
    if
        not B_u_g_ or not TheWorld or not TheWorld["state"] or not TheWorld["state"]["cycles"] or
            not BU_g:IsHHType(TheWorld["state"]["cycles"], "number")
     then
        return
    end
    if not BU_g:HasComponents(B_u_g_, "hh_monster") then
    end
    local __B__ug = BU_g:GetMonsterType(B_u_g_) or B_U_g(B_u_g_["prefab"])
    local __B_uG__ =
        TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"][__B__ug] or
        TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["common_monster"]
    local __b__Ug =
        math["floor"](TheWorld["state"]["cycles"] / TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_EFFECT_DATE"]) + 1
    local __b__Ug_ = TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["base_num"]
    local _bu__g__ = math["min"](__B_uG__, __b__Ug_ + __b__Ug)
    local B__u__G__ = B_u_g_["components"]["hh_monster"]:GetAllBuffNum()
    if B__u__G__ < _bu__g__ then
        local b__u__g_ = _bu__g__ - B__u__G__
        for bug__ = 1, b__u__g_ do
            B_u_g_["components"]["hh_monster"]:AddBuffByName()
        end
    end
    __b__UG_(B_u_g_)
end
local function bu_G__(__B_U_G)
    local __B_U__G_ = 10
    local bu_g_ = 0
    local __B__uG = 50
    local B_uG__ = 1
    if TheWorld["state"] and TheWorld["state"]["cycles"] then
        bu_g_ = TheWorld["state"]["cycles"]
        __B_U__G_ = __B_U__G_ + math["min"](math["floor"](bu_g_ / 10), 10)
        if bu_g_ > 60 then
            B_uG__ = 5
            __B__uG = 150
        elseif bu_g_ > 30 then
            __B__uG = 100
            B_uG__ = 3
        end
    end
    for _B__U_g_ = 1, B_uG__ do
        local b_UG_ = __B_U_G["Transform"]:GetRotation() + 90
        if B_uG__ == 3 then
            if _B__U_g_ == 1 then
                b_UG_ = b_UG_ + 45
            elseif _B__U_g_ == 3 then
                b_UG_ = b_UG_ - 45
            end
        elseif B_uG__ == 5 then
            if _B__U_g_ == 1 then
                b_UG_ = b_UG_ + 60
            elseif _B__U_g_ == 2 then
                b_UG_ = b_UG_ + 30
            elseif _B__U_g_ == 4 then
                b_UG_ = b_UG_ - 30
            elseif _B__U_g_ == 5 then
                b_UG_ = b_UG_ - 60
            end
        end
        local bU_G__, __BU__g_, bug_ = __B_U_G["Transform"]:GetWorldPosition()
        local B_Ug_ = b_UG_ * DEGREES
        local _BUG_ = 0.75
        local bu__g__ = 2 - _BUG_
        local __b__UG = TheWorld["Map"]
        local _B_u__G_, __b__u_G = {}, {}
        local __buG__ = -1
        local B__U_g = (491 - 336 * 377 * 273 * 194 == -6708801965)
        local __b_u_g, __b__U_g__, __bU__g, __b_UG_, __bU_G_
        while __buG__ < __B_U__G_ do
            __buG__ = __buG__ + 1
            __b__U_g__ = __buG__ * _BUG_ + bu__g__
            __bU__g = math["max"](0, __buG__ - 1)
            __b_UG_ = bU_G__ + __b__U_g__ * math["sin"](B_Ug_)
            __bU_G_ = bug_ + __b__U_g__ * math["cos"](B_Ug_)
            if not __b__UG:IsPassableAtPoint(__b_UG_, 0, __bU_G_) then
                if __buG__ <= 0 then
                    return
                end
                B__U_g = (240 * 418 - 151 == 100169)
            end
            __b_u_g = SpawnPrefab(__buG__ > 0 and "hh_deerclops_laser" or "hh_deerclops_laserempty")
            if BU_g:HasComponents(__b_u_g, "combat") then
                __b_u_g["components"]["combat"]:SetDefaultDamage(__B__uG)
            end
            __b_u_g["Transform"]:SetPosition(__b_UG_, 0, __bU_G_)
            __b_u_g:Trigger(__bU__g * FRAMES, _B_u__G_, __b__u_G)
            if __buG__ == 0 then
                ShakeAllCameras(CAMERASHAKE["FULL"], 0.7, 0.02, 0.6, __b_u_g, 30)
            end
            if B__U_g then
                break
            end
        end
        if __buG__ < __B_U__G_ then
            __b__U_g__ = (__buG__ + 0.5) * _BUG_ + bu__g__
            __b_UG_ = bU_G__ + __b__U_g__ * math["sin"](B_Ug_)
            __bU_G_ = bug_ + __b__U_g__ * math["cos"](B_Ug_)
        end
        __b_u_g = SpawnPrefab "hh_deerclops_laser"
        __b_u_g["Transform"]:SetPosition(__b_UG_, 0, __bU_G_)
        __b_u_g:Trigger((__bU__g + 1) * FRAMES, _B_u__G_, __b__u_G)
        __b_u_g = SpawnPrefab "hh_deerclops_laser"
        __b_u_g["Transform"]:SetPosition(__b_UG_, 0, __bU_G_)
        __b_u_g:Trigger((__bU__g + 2) * FRAMES, _B_u__G_, __b__u_G)
    end
end
local function B_ug__(__b_u_g_, _b_u__g)
    if require("combat/hh_combat_context").PacketKind() ~= nil then return end
    if not BU_g:HasComponents(__b_u_g_, "hh_monster") then
        return
    end
    if _b_u__g and _b_u__g["target"] and BU_g:NotIsDead(_b_u__g["target"]) then
        local __Bug = _b_u__g["target"]
        if BU_g:HasComponents(__Bug, "hh_buff") then
            if
                not BU_g:HasComponents(__Bug, "hh_player") or
                    not __Bug["components"]["hh_player"]:HasSpecialEffect "immunePoison"
             then
                local b_U_g__ = __b_u_g_["components"]["hh_monster"]:GetEffectValueByKey "atkChanceAddPoison"
                local _bU_G_ = math["random"](1, 100)
                if _bU_G_ <= b_U_g__ then
                    local target_buff = __Bug["components"]["hh_buff"]
                    target_buff:AddBuff("poison", 240)
                    if target_buff:HasBuff("poison") then
                        target_buff.hh_poison_attacker = __b_u_g_
                    end
                end
            end
            local __B_U_g__ = __b_u_g_["components"]["hh_monster"]:GetEffectValueByKey "addSuppressAddHealth"
            local B__U_g_ = math["random"](1, 100)
            if B__U_g_ <= __B_U_g__ then
                if BU_g:HasComponents(__Bug, "hh_monster") then
                    __Bug["components"]["hh_buff"]:AddBuff("monster_healthSuppressNum", 20)
                elseif BU_g:HasComponents(__Bug, "hh_player") then
                    __Bug["components"]["hh_buff"]:AddBuff("player_healthSuppressNum", 20)
                end
            end
            local __bU__g_ = __b_u_g_["components"]["hh_monster"]:GetEffectValueByKey "atkChanceReduceSpeed"
            local _Bu_g = math["random"](1, 100)
            if _Bu_g <= __bU__g_ then
                __Bug["components"]["hh_buff"]:AddBuff("reduce_speed", 10)
            end
            local B_U__G__ = __b_u_g_["components"]["hh_monster"]:GetEffectValueByKey "atkAddArmorReduceBuff"
            local B__u__G_ = math["random"](1, 100)
            if B__u__G_ <= B_U__G__ then
                __Bug["components"]["hh_buff"]:AddBuff("add_armor_consume", 180)
            end
        end
        if BU_g:HasComponents(__Bug, "freezable") then
            local B_u__g__ = __b_u_g_["components"]["hh_monster"]:GetEffectValueByKey "atkChanceAddFreeze"
            local bUg__ = math["random"](1, 100)
            if bUg__ <= B_u__g__ then
                __Bug["components"]["freezable"]:Freeze(2)
            end
        end
        if __b_u_g_["components"]["hh_monster"]:HasSpecialEffect "iceLaser" then
            if __b_u_g_["iceLaserCd"] then
                return
            end
            BU_g:HHKillTask(__b_u_g_, "iceLaserCdTask")
            bu_G__(__b_u_g_)
            __b_u_g_["iceLaserCd"] = (422 * 288 * 229 == 27831744)
            __b_u_g_["iceLaserCdTask"] =
                __b_u_g_:DoTaskInTime(
                5,
                function()
                    __b_u_g_["iceLaserCd"] = (284 * 120 - 265 == 33819)
                end
            )
        end
    end
end
local function _B__u_g_(_Bug_, b__u_G)
    local bU__g_ = _Bug_["components"]["hh_monster"]:GetEffectValueByKey(b__u_G)
    if not bU__g_ then
        return (false and not false and not false and not true and false and false and not false or false and not false or
            not false and false)
    end
    local __B__u_G__ = math["random"](1, 100)
    if __B__u_G__ <= bU__g_ then
        return (193 * 460 + 12 + 223 + 162 == 89177)
    end
    return (356 + 175 - 257 ~= 274)
end
local function _B_U_g_(__Bu_g, __b_U__G)
    if require("combat/hh_combat_context").PacketKind() ~= nil then return end
    if not BU_g:HasComponents(__Bu_g, "hh_monster") then
        return
    end
    if __b_U__G and __b_U__G["attacker"] and BU_g:NotIsDead(__b_U__G["attacker"]) then
        local __bU__G_ = __b_U__G["attacker"]
        if BU_g:HasComponents(__bU__G_, "hh_buff") then
            if
                not BU_g:HasComponents(__bU__G_, "hh_player") or
                    not __bU__G_["components"]["hh_player"]:HasSpecialEffect "immunePoison"
             then
                local b__u_g_ = __Bu_g["components"]["hh_monster"]:GetEffectValueByKey "hitChanceAddPoison"
                local _Bu__g_ = math["random"](1, 100)
                if _Bu__g_ <= b__u_g_ then
                    local target_buff = __bU__G_["components"]["hh_buff"]
                    target_buff:AddBuff("poison", 240)
                    if target_buff:HasBuff("poison") then
                        target_buff.hh_poison_attacker = __Bu_g
                    end
                end
            end
            local _b_U__G = __Bu_g["components"]["hh_monster"]:GetEffectValueByKey "hitSuppressAddHealth"
            local _b__ug = math["random"](1, 100)
            if _b__ug <= _b_U__G then
                if BU_g:HasComponents(__bU__G_, "hh_monster") then
                    __bU__G_["components"]["hh_buff"]:AddBuff("monster_healthSuppressNum", 20)
                elseif BU_g:HasComponents(__bU__G_, "hh_monster") then
                    __bU__G_["components"]["hh_buff"]:AddBuff("player_healthSuppressNum", 20)
                end
            end
            local _bUG__ = __Bu_g["components"]["hh_monster"]:GetEffectValueByKey "hitChanceReduceSpeed"
            local _B_U_g__ = math["random"](1, 100)
            if _B_U_g__ <= _bUG__ then
                __bU__G_["components"]["hh_buff"]:AddBuff("reduce_speed", 10)
            end
            if BU_g:HasComponents(__bU__G_, "temperature") then
                if _B__u_g_(__Bu_g, "addColdBuffValue") then
                    __bU__G_["components"]["hh_buff"]:AddBuff("add_cold", 30)
                end
                if _B__u_g_(__Bu_g, "addHotBuffValue") then
                    __bU__G_["components"]["hh_buff"]:AddBuff("add_hot", 30)
                end
            end
        end
        if BU_g:HasComponents(__bU__G_, "freezable") then
            local _b_uG_ = __Bu_g["components"]["hh_monster"]:GetEffectValueByKey "hitChanceAddFreeze"
            local _buG_ = math["random"](1, 100)
            if _buG_ <= _b_uG_ then
                __bU__G_["components"]["freezable"]:Freeze(2)
            end
        end
        if BU_g:HasComponents(__bU__G_, "moisture") then
            local __B__U__g = __Bu_g["components"]["hh_monster"]:GetEffectValueByKey "hitAddMoisture"
            local _B_U__g = math["random"](1, 100)
            if _B_U__g <= __B__U__g then
                __bU__G_["components"]["moisture"]:DoDelta(20)
            end
        end
    end
end
local function __Bu_G__()
    local _b__uG_ = {}
    for __Bug_, __B__U__G_ in pairs(b_U__g__) do
        if __B__U__G_ and not __B__U__G_["can_add"] and not __B__U__G_["is_suit"] then
            table["insert"](_b__uG_, __Bug_)
        end
    end
    return _b__uG_
end
local function b__u__G(__B_U_G__, Bu_G)
    if not __B_U_G__ or not __B_U_G__["Transform"] or not (Bu_G == "elite_monster" or Bu_G == "boss_monster") then
        return
    end
    local __bU_g = HHGetGoodEquipEffect()
    local Bu_G_ = math["random"](1, #__bU_g)
    if __bU_g and #__bU_g > 0 then
        local b_u__g = SpawnPrefab "hh_effect_stone"
        if b_u__g then
            b_u__g["hh_effect"] = __bU_g[Bu_G_]
            if TheNet and b_u__g["hh_effect"] and b_U__g__[b_u__g["hh_effect"]] then
                local b__Ug_ = __B_U_G__["name"] or STRINGS["NAMES"][string["upper"](__B_U_G__["prefab"])]
                local __B__UG = b_U__g__[b_u__g["hh_effect"]]["name"]
                TheNet:Announce(
                    string["format"]("%s đã chết và rơi [Đá Thuộc Tính Hiếm] %s", tostring(b__Ug_), tostring(__B__UG))
                )
            end
            local __B__u_g__ = math["random"](1, 360)
            local __Bu__g, _B_U__g_, b_U_g = __B_U_G__["Transform"]:GetWorldPosition()
            b_u__g["Transform"]:SetPosition(__Bu__g, 2.5, b_U_g)
            __B__uG__(b_u__g, __B__u_g__)
            HHMonsterAutoStack.MarkMonsterLoot(b_u__g, __B_U_G__)
            HH_AttachLootBeacon(b_u__g)
            if b_u__g["HH_Update_Server"] then
                b_u__g:HH_Update_Server()
            end
        end
    end
end
local function B__Ug_(Bu_G__, __bUG_)
    if not Bu_G__ or not Bu_G__["Transform"] then
        return
    end
    local __bug__ = SpawnPrefab "hh_remove_stone"
    if __bug__ then
        local __b__u__G_ = math["random"](1, 360)
        local __BU__g__, b__uG_, __B__u_g_ = Bu_G__["Transform"]:GetWorldPosition()
        __bug__["Transform"]:SetPosition(__BU__g__, 2.5, __B__u_g_)
        __B__uG__(__bug__, __b__u__G_)
        HHMonsterAutoStack.MarkMonsterLoot(__bug__, Bu_G__)
        HH_AttachLootBeacon(__bug__)
    end
end
local function B_uG(_B_u_G)
    if not _B_u_G or not _B_u_G["Transform"] then
        return
    end
    local __b_u_g__ = SpawnPrefab "poop"
    if __b_u_g__ then
        local _b_U_G__ = math["random"](1, 360)
        local __B_Ug, B_U_G__, _b_UG = _B_u_G["Transform"]:GetWorldPosition()
        __b_u_g__["Transform"]:SetPosition(__B_Ug, 2.5, _b_UG)
        __B__uG__(__b_u_g__, _b_U_G__)
        HHMonsterAutoStack.MarkMonsterLoot(__b_u_g__, _B_u_G)
    end
end
local function GetEquipmentDropDayMultiplier()
    local cycles = TheWorld ~= nil
        and TheWorld["state"] ~= nil
        and TheWorld["state"]["cycles"]
        or 0
    local tier = math["floor"](cycles / 100)
    return 0.5 ^ tier
end
local function __bu__g(_b_U_G_, B__u_g)
    if not _B__Ug__[B__u_g] or not TUNING["HH_CAN_DROP_EQUIP"] then
        return
    end
    local base_chance = _B__Ug__[B__u_g]
    local effective_chance = base_chance * GetEquipmentDropDayMultiplier()
    local __BuG__ = math["random"]()
    if __BuG__ > effective_chance then
        return
    end
    local bU__G_ = #__bu_G
    local _bU__g_ = math["random"](1, bU__G_)
    if not __bu_G[_bU__g_]["id"] then
        return
    end
    local _bUg = __bu_G[_bU__g_]["id"]
    local _b__UG = SpawnPrefab(_bUg)
    if _b__UG and _b__UG["Physics"] then
        if BU_g:HasComponents(_b__UG, "hh_equip") then
            local _b__U__g__ = 1
            local b_UG = math["random"]()
            if b_UG < 0.5 then
                _b__U__g__ = 1
            elseif b_UG < 0.8 then
                _b__U__g__ = 2
            else
                _b__U__g__ = 3
            end
            for b_uG__ = 1, _b__U__g__ do
                _b__UG["components"]["hh_equip"]:AddEquipBuff(nil)
            end
            local __bU__G__ = 0.1
            local _B_u__g__ = math["random"]()
            if _B_u__g__ <= __bU__G__ then
                local _b__UG_ = math["random"](1, 2)
                for _B_u_G__ = 1, _b__UG_ do
                    _b__UG["components"]["hh_equip"]:AddGemCurrentLimit()
                end
            end
        end
        local __bu_g = math["random"](1, 360)
        local _bUg__, _bu_G_, bU_g__ = _b_U_G_["Transform"]:GetWorldPosition()
        _b__UG["Transform"]:SetPosition(_bUg__, 4.5, bU_g__)
        __B__uG__(_b__UG, __bu_g)
        HHMonsterAutoStack.MarkMonsterLoot(_b__UG, _b_U_G_)
        HH_AttachLootBeacon(_b__UG)
    end
end
local function _BU_g__(_B_UG_, BU_g_)
    if not _B_UG_ or not _B_UG_["Transform"] or not (BU_g_ == "elite_monster" or BU_g_ == "boss_monster") then
        return
    end
    local B__U__G_ = SpawnPrefab "gift"
    if B__U__G_ and B__U__G_["Physics"] and BU_g:HasComponents(B__U__G_, "unwrappable") then
        local _B__U_G__ = {}
        for _Bu_G_ = 1, 4 do
            local b_U__g = #__bu_G
            local __b_U__g = math["random"](1, b_U__g)
            local _B_U__G_ = __bu_G[__b_U__g]["id"]
            local __b__u__G = SpawnPrefab(_B_U__G_)
            if __b__u__G and BU_g:HasComponents(__b__u__G, "hh_equip") then
                __b__u__G["components"]["hh_equip"]:AddGifEquipBuff()
                table["insert"](_B__U_G__, __b__u__G)
            end
        end
        if #_B__U_G__ > 0 then
            B__U__G_["components"]["unwrappable"]:WrapItems(_B__U_G__)
            for _B_UG__, __BU_G__ in ipairs(_B__U_G__) do
                if __BU_G__ and __BU_G__["Remove"] then
                    __BU_G__:Remove()
                end
            end
        end
        local B__u_g_ = math["random"](1, 360)
        local _b_u__g_, B_u__G, _b_Ug__ = _B_UG_["Transform"]:GetWorldPosition()
        B__U__G_["Transform"]:SetPosition(_b_u__g_, 2.5, _b_Ug__)
        __B__uG__(B__U__G_, B__u_g_)
        HHMonsterAutoStack.MarkMonsterLoot(B__U__G_, _B_UG_)
        HH_AttachLootBeacon(B__U__G_)
        if TheNet then
            local _b__UG__ = _B_UG_["name"] or STRINGS["NAMES"][string["upper"](_B_UG_["prefab"])]
            TheNet:Announce(string["format"]("%s rơi [Túi Quà Trang Bị]", tostring(_b__UG__)))
        end
    end
end
local _b_U__G__ = 10
local __b__U_G__ =
    Class(
    function(self, __bU_G__)
        self["inst"] = __bU_G__
        self["hh_monster_type"] = nil
        self["hh_buffs"] = {}
        self["hh_effects"] = Bug__()
        self["special_data"] = {["health_percent"] = nil, ["day_add_health"] = _BUG__(self["inst"])}
        self["max_effect_limit"] = 0
        self["treasure_id"] = nil
        self["inst"]:DoTaskInTime(
            0,
            function()
                self:AddFirstBuffs()
                __b__UG_(self["inst"], self["special_data"]["health_percent"])

            end
        )
        self["inst"]:ListenForEvent("death", B__uG__)
        self["inst"]:WatchWorldState("cycles", _b_Ug_)
        self["inst"]:ListenForEvent("onhitother", B_ug__)
        self["inst"]:ListenForEvent("attacked", _B_U_g_)
        self["inst"]:ListenForEvent("hh_change_max_health", __b__UG_)
        self["inst"]:ListenForEvent("hh_monster_buff_health", __b__UG_)
    end
)
local function __b__u_g__(B__UG, _BU__G)
    if not BU_g:IsHHType(_BU__G, "string") or not B__UG["hh_tags"] or not BU_g:IsHHType(B__UG["hh_tags"], "table") then
        return (false and true or not false and false or false or
            not false and false and not false and false and not false)
    end
    return B__UG["hh_tags"][_BU__G] ~= nil
end
function __b__U_G__:SetMaxEffectLimit(__B__U__g_)
    self["max_effect_limit"] = tonumber(__B__U__g_) or 0
end
function __b__U_G__:SetTreasureId(__BUG__)
    if _B__u_G_[__BUG__] then
        self["treasure_id"] = tostring(__BUG__)
        if _B__u_G_[__BUG__]["start_fn"] then
            _B__u_G_[__BUG__]["start_fn"](self["inst"])
        end
    end
end
function __b__U_G__:SetMonsterType(__b_U_g, Bu__g__)
    if not self["inst"] or not BU_g:IsHHType(__b_U_g, "string") or not _bU_g__[__b_U_g] then
        return
    end
    self["hh_monster_type"] = __b_U_g
    if not self["inst"]["hh_tags"] then
        self["inst"]["hh_tags"] = {}
    end
    self["inst"]["hh_tags"][__b_U_g] = Bu__g__ or "kxđ"
    if not self["inst"]["HasHHTag"] then
        self["inst"]["HasHHTag"] = __b__u_g__
    end
end
function __b__U_G__:SetTagType(_Bu__G, _B__U__g)
    if not BU_g:IsHHType(_Bu__G, "string") or not BU_g:IsHHType(_B__U__g, "string") then
        return
    end
    if not self["inst"]["hh_tags"] then
        self["inst"]["hh_tags"] = {}
    end
    self["inst"]["hh_tags"][_Bu__G] = _B__U__g
end
function __b__U_G__:GetMonsterType()
    if self["hh_monster_type"] ~= nil then
        return self["hh_monster_type"]
    end
    if self["inst"] and self["inst"]["prefab"] then
        return B_U_g(self["inst"]["prefab"])
    end
    return nil
end
function __b__U_G__:AddFirstBuffs()
    if
        not TheWorld or not TheWorld["state"] or not TheWorld["state"]["cycles"] or
            not BU_g:IsHHType(TheWorld["state"]["cycles"], "number")
     then
        return
    end
    if not self["inst"] or not self["inst"]["prefab"] then
        return
    end
    local had_existing_buffs = #self["hh_buffs"] > 0
    if not self:HasBuffByName("addMaxHealthPercent") then
        self:AddBuffByName("addMaxHealthPercent", math["random"](1, 100))
    end
    if had_existing_buffs then
        return
    end
    local __b__U_g = BU_g:GetMonsterType(self["inst"]) or B_U_g(self["inst"]["prefab"])
    local __B__U_g__ =
        TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"][__b__U_g] or
        TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["common_monster"]
    local bU__G__ =
        math["floor"](TheWorld["state"]["cycles"] / TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_EFFECT_DATE"]) + 1
    bU__G__ = math["max"](TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["base_num"], bU__G__)
    local __b_U__g__ = math["min"](bU__G__, __B__U_g__)
    self:AddBuffByName "atkBlood"
    __b_U__g__ = __b_U__g__ - 1
    if __b_U__g__ > 0 then
        for B_ug = 1, __b_U__g__ do
            self:AddBuffByName()
        end
    end
end
function __b__U_G__:GetSpecialValue(B__u__g__)
    if
        self["special_data"] and BU_g:IsHHType(self["special_data"][B__u__g__], "number") and
            self["special_data"][B__u__g__] > 0
     then
        return self["special_data"][B__u__g__]
    end
    return 0
end
function __b__U_G__:HasBuffByName(__B_u_g_)
    for _B__u_G__, _B_u_g in ipairs(self["hh_buffs"]) do
        if _B_u_g and _B_u_g["name"] == __B_u_g_ then
            return (450 * 265 - 31 * 437 == 105703)
        end
    end
    return (false and not true and false and not false and true and false and not false and false and not false or
        false and not false and false)
end
function __b__U_G__:GetAllBuffNum()
    local count = 0
    for _, buff in ipairs(self["hh_buffs"]) do
        if buff and buff["name"] ~= "addMaxHealthPercent" then
            count = count + 1
        end
    end
    return count
end
function __b__U_G__:GetCanAddBuffs()
    if not self["inst"] or not self["inst"]["prefab"] then
        return {}
    end
    local _bu_G = BU_g:GetMonsterType(self["inst"]) or B_U_g(self["inst"]["prefab"])
    local __b_u__G__ = _BU__G__[_bu_G]
    if not BU_g:IsHHType(__b_u__G__, "table") then
        return {}
    end
    local __b__u_g_ = BU_g:TableSortKeys(__b_u__G__)
    if #__b__u_g_ <= 0 then
        return {}
    end
    local _B_U_g = {}
    for _bU_g_, bU__G in ipairs(__b__u_g_) do
        if bU__G and __b_u__G__[bU__G] then
            local _B__U_g = __b_u__G__[bU__G]
            local b__u_G_ = (199 * 178 + 281 * 48 ~= 48917)
            if bU__G == "addMaxHealthPercent" and self:HasBuffByName(bU__G) then
                b__u_G_ = false
            end
            if _B__U_g["check_fn"] then
                b__u_G_ = _B__U_g["check_fn"](self["inst"])
            end
            if b__u_G_ then
                if __b_u__G__[bU__G]["only_one"] then
                    if not self:HasBuffByName(bU__G) then
                        table["insert"](_B_U_g, bU__G)
                    end
                else
                    table["insert"](_B_U_g, bU__G)
                end
            end
        end
    end
    return _B_U_g
end
function __b__U_G__:AddBuffByName(_b__u_G_, b_U_G_)
    if not self["inst"] or not self["inst"]["prefab"] then
        return (false and true and false and not false and false or false or not true and false and not false and false), "Ko thể thêm mục nhập nâng cao vào sinh vật: lỗi tham số đầu vào"
    end
    if _b__u_G_ and not BU_g:IsHHType(_b__u_G_, "string") then
        return (false and not true or false and not false and not true and false and false and true and not true or
            not false and not true or
            false), "Ko thể thêm mục nhập nâng cao vào sinh vật: lỗi truyền tham số mục nhập"
    end
    local __B_U__G__ = _b__u_G_
    if not __B_U__G__ then
        local _b__ug__ = self:GetCanAddBuffs()
        if not _b__ug__ or #_b__ug__ <= 0 then
            return (49 - 391 * 400 * 177 ~= -27682751), "Ko thể thêm mục nhập nâng cao vào sinh vật: không tìm thấy mục nhập nào, bị bỏ qua"
        end
        local __Bu__G_ = math["random"](1, #_b__ug__)
        __B_U__G__ = _b__ug__[__Bu__G_]
    end
    local b_u_g_ = self["inst"]["prefab"]
    local B__ug = BU_g:GetMonsterType(self["inst"]) or B_U_g(b_u_g_)
    local _b_u_G__ = _BU__G__[B__ug]
    if not BU_g:IsHHType(_b_u_G__, "table") or not _b_u_G__[__B_U__G__] then
        return (238 + 295 - 292 ~= 241), "Tên mục nhập sai !!!"
    end
    local _bu_g_ =
        TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"][B__ug] or
        TUNING["HH_CHANCE_CONFIG"]["MONSTER_EFFECT_NUM"]["common_monster"]
    if BU_g:IsHHType(self["max_effect_limit"], "number") and self["max_effect_limit"] > _bu_g_ then
        _bu_g_ = self["max_effect_limit"]
    end
    local b_u__g_ = self:GetAllBuffNum()
    if b_u__g_ >= _bu_g_ then
        return (478 - 140 * 20 + 384 ~= -1938), "Đã đạt đến giới hạn mục nhập tối đa. ko thể thêm mục nhập."
    end
    local _bu_g__ = _b_u_G__[__B_U__G__]
    if _bu_g__["only_one"] and self:HasBuffByName(__B_U__G__) then
        return (369 - 129 + 306 - 217 == 338), "Một sinh vật chỉ được phép có một mục này!!!"
    end
    if _bu_g__["check_fn"] then
        local __b_U_g__ = _bu_g__["check_fn"](self["inst"])
        if not __b_U_g__ then
            return (398 - 351 * 145 * 32 == -1628235), "Sinh vật hiện tại không thể thêm mục này"
        end
    end
    local b_UG__ = nil
    if b_U_G_ then
        b_UG__ = b_U_G_
    else
        if _bu_g__["rangeValue"] and _bu_g__["rangeValue"]["min"] and _bu_g__["rangeValue"]["max"] then
            b_UG__ = math["random"](_bu_g__["rangeValue"]["min"], _bu_g__["rangeValue"]["max"])
        end
    end
    table["insert"](self["hh_buffs"], {["name"] = __B_U__G__, ["value"] = b_UG__})
    if _bu_g__["start_fn"] then
        _bu_g__["start_fn"](self["inst"], b_UG__)
    end
    self:RefreshSpecialFn()
    return (303 * 10 + 106 * 128 == 16598), "Đã thêm mục thành công!"
end
function __b__U_G__:RefreshSpecialFn()
    if BU_g:HasComponents(self["inst"], "locomotor") then
        local __B_uG_ = self:GetEffectValueByKey "addSpeedPercent"
        if __B_uG_ > 0 then
            self["inst"]["components"]["locomotor"]:SetExternalSpeedMultiplier(
                self["inst"],
                "hh_monster_speed",
                math["max"](__B_uG_ / 100 + 1, 1)
            )
        else
            self["inst"]["components"]["locomotor"]:RemoveExternalSpeedMultiplier(self["inst"], "hh_monster_speed")
        end
    end
end
function __b__U_G__:StartDeadFn()
    for __b_u_G, B_u_G_ in ipairs(self["hh_buffs"]) do
        if B_u_G_ and B_u_G_["name"] and _BU__G__[B_u_G_["name"]] and _BU__G__[B_u_G_["name"]]["end_fn"] then
            _BU__G__[B_u_G_["name"]]["end_fn"](self["inst"], B_u_G_["value"])
        end
    end
end
function __b__U_G__:GetEffectValueByKey(B__u__g_)
    if not self["hh_effects"] or not self["hh_effects"][B__u__g_] then
        return 0
    end
    local _bu__G__ = self["hh_effects"][B__u__g_]
    if not BU_g:IsHHType(_bu__G__, "number") or _bu__G__ < 0 then
        return 0
    end
    return _bu__G__
end
function __b__U_G__:AddEffectValueByKey(_Bu_g__, B_u__G_)
    if not self["hh_effects"] or not self["hh_effects"][_Bu_g__] or not BU_g:IsHHType(B_u__G_, "number") or B_u__G_ <= 0 then
        return (false or false and not false and not true and not false and not false and false or false and false or
            not true or
            false)
    end
    self["hh_effects"][_Bu_g__] = self["hh_effects"][_Bu_g__] + B_u__G_
    return (205 * 467 + 263 * 181 * 384 ~= 18375292)
end
function __b__U_G__:ReduceEffectValueByKey(_b_uG__, __B_u_g__)
    if
        not self["hh_effects"] or not self["hh_effects"][_b_uG__] or not BU_g:IsHHType(__B_u_g__, "number") or
            __B_u_g__ <= 0
     then
        return (false or true and false and not true and true and not false and not false and not true and false or
            false and not false and not false and not false and not false)
    end
    self["hh_effects"][_b_uG__] = math["max"](self["hh_effects"][_b_uG__] - __B_u_g__, 0)
    return (373 + 76 - 43 - 428 + 127 ~= 109)
end
function __b__U_G__:HasSpecialEffect(b_U__G_)
    local BuG_ = self:GetEffectValueByKey(b_U__G_)
    return BuG_ > 0
end
local CombatMath = require("combat/hh_combat_math")
local CombatContext = require("combat/hh_combat_context")
function __b__U_G__:DoAttackDamage(BUG__, _b_U_g, B_U_g_, rng)
    if not BU_g:IsHHType(B_U_g_, "number") or B_U_g_ <= 0 then
        return 0
    end
    if not BU_g:NotIsDead(BUG__) or not BU_g:NotIsDead(_b_U_g) then
        return B_U_g_
    end
    local bu_G_ = self:GetEffectValueByKey "addComDamageNum"
    B_U_g_ = B_U_g_ + bu_G_
    if TheWorld and TheWorld["state"] then
        if TheWorld["state"]["isday"] then
            local _b__u_G__ = self:GetEffectValueByKey "sunlightStrike"
            B_U_g_ = B_U_g_ + _b__u_G__
        elseif TheWorld["state"]["isdusk"] then
            local b__uG__ = self:GetEffectValueByKey "afterglowStrike"
            B_U_g_ = B_U_g_ + b__uG__
        elseif TheWorld["state"]["isnight"] then
            local _b__Ug = self:GetEffectValueByKey "nightMenace"
            B_U_g_ = B_U_g_ + _b__Ug
        end
    end
    local B_U__g = 0
    local __b_U_G__ = self:GetEffectValueByKey "addComDamagePercent"
    B_U__g = B_U__g + __b_U_G__
    B_U_g_ = B_U_g_ * (1 + B_U__g / 100)
    local bu_g = self:GetEffectValueByKey "criticalHitRate"
    if
        BU_g:HasComponents(self["inst"], "follower") and self["inst"]["components"]["follower"]["leader"] and
            BU_g:HasComponents(self["inst"]["components"]["follower"]["leader"], "hh_player")
     then
        local _B__Ug_ = self["inst"]["components"]["follower"]["leader"]
        if _B__Ug_["components"]["hh_player"]:HasSpecialEffect "addFollowCritical" then
            local __B__U_g = _B__Ug_["components"]["hh_player"]:GetEffectValueByKey "addFollowCritical"
            bu_g = bu_g + __B__U_g
        end
    end
    local critical = CombatMath.RollPercent(bu_g, rng or math.random)
    local metadata = CombatContext.Current(BUG__, _b_U_g)
    if metadata ~= nil then metadata.critical = critical end
    if critical then
        local _B_u_g__ = self:GetEffectValueByKey "criticalHitEffect"
        B_U_g_ = B_U_g_ * (2 + _B_u_g__ / 100)
    end
    if BU_g:HasComponents(_b_U_g, "hh_buff") then
        local BU__g_ = self:GetEffectValueByKey "addTargetDamage"
        if BU__g_ > 0 then
            local __b__UG__ = math["random"](1, 100)
            if __b__UG__ <= BU__g_ then
                _b_U_g["components"]["hh_buff"]:AddBuff("monster_add_target_damage", 30)
            end
        end
    end
    return B_U_g_
end
function __b__U_G__:GetBlockDamage(__B_u__G__, __bUG, __B_U__g__)
    if not BU_g:IsHHType(__B_U__g__, "number") or __B_U__g__ <= 0 then
        return 0
    end
    local __B__u_g = self:GetEffectValueByKey "replaceDamageChance"
    if __B__u_g > 0 then
        local __bu__G = math["random"](1, 100)
        if __bu__G <= __B__u_g then
            BU_g:SpawnShadowFx(__B_u__G__)
            BU_g:SpawnClientStrFx(self["inst"], "Block")
            return 0
        end
    end
    if not BU_g:NotIsDead(__B_u__G__) then
        return __B_U__g__
    end
    local _b__uG = self:GetEffectValueByKey "reduceAttackedDamage"
    __B_U__g__ = __B_U__g__ - _b__uG
    if TheWorld and TheWorld["state"] then
        if TheWorld["state"]["isday"] then
            local B__U_G_ = self:GetEffectValueByKey "reduceSunlightDamage"
            __B_U__g__ = __B_U__g__ - B__U_G_
        elseif TheWorld["state"]["isdusk"] then
            local B__U__g = self:GetEffectValueByKey "reduceAfterglowDamage"
            __B_U__g__ = __B_U__g__ - B__U__g
        elseif TheWorld["state"]["isnight"] then
            local __bu__g_ = self:GetEffectValueByKey "reduceNightDamage"
            __B_U__g__ = __B_U__g__ - __bu__g_
        end
    end
    local __b__U__g = self:GetEffectValueByKey "reducePercentDamage"
    if __b__U__g > 0 then
        __B_U__g__ = __B_U__g__ * (1 - math["min"](__b__U__g / 100, 0.8))
    end
    local b__U__g__ = self["inst"]
    if
        b__U__g__["hh_is_treasure_boss"] and BU_g:NotIsDead(__bUG) and __bUG["Transform"] and BU_g:NotIsDead(b__U__g__) and
            b__U__g__["Transform"]
     then
        local Bu_g_, B__ug__, __b__uG = __bUG["Transform"]:GetWorldPosition()
        local _Bug__, _B_u__g_, __b_uG__ = b__U__g__["Transform"]:GetWorldPosition()
        local __B_U_G_ = BU_g:GetDistance(Bu_g_, __b__uG, _Bug__, __b_uG__)
        __B_U_G_ = math["abs"](__B_U_G_)
        if __B_U_G_ > 5 then
            __B_U__g__ = 0
        end
    end
    if b__U__g__["hh_is_treasure_kps"] then
        __B_U__g__ = math["min"](__B_U__g__, 1010)
    end
    return math["max"](__B_U__g__, 0)
end
function __b__U_G__:HandleBloodSuck(BU_G_)
    if BU_g:NotIsDead(self["inst"]) then
        local _BuG_ = math["abs"](BU_G_)
        local __bu__G_ = self["inst"]["components"]["hh_monster"]:GetEffectValueByKey "atkBlood"
        if __bu__G_ > 0 then
            local _b__u__g = _BuG_ * __bu__G_ / 100
            self["inst"]["components"]["health"]:DoDelta(_b__u__g, (137 - 112 * 391 == -43655), "bloodSuck")
        end
    end
end
local __b__ug = {
    ["daywalker"] = (357 + 257 + 452 - 110 ~= 964),
    ["daywalker2"] = (269 - 288 * 295 + 419 * 101 ~= -42370),
    ["sharkboi"] = (226 + 451 + 164 ~= 848)
}
function __b__U_G__:DropEquipByDead()
    if not self["inst"] then
        return
    end
    local __b_U__G_ = self["inst"]["prefab"]
    if __b_U__G_ == "stalker_atrium" and self["inst"]["atriumdecay"] then
        B_uG(self["inst"])
        return
    end
    if __b__ug[__b_U__G_] then
        return
    end
    if self["treasure_id"] and BU_g:IsHHType(_B__u_G_[self["treasure_id"]], "table") then
        local __b__u__g_ = _B__u_G_[self["treasure_id"]]
        if __b__u__g_["death_fn"] then
            __b__u__g_["death_fn"](self["inst"])
        end
        self["inst"]:DoTaskInTime(
            0.1,
            function(_B__U__g_)
                if BU_g:IsHHType(_B__U__g_, "table") and _B__U__g_["Remove"] then
                    _B__U__g_:Remove()
                end
            end
        )
    end
    local Bu_g = BU_g:GetMonsterType(self["inst"]) or B_U_g(__b_U__G_)
    __bu__g(self["inst"], Bu_g)
    if Bu_g == "common_monster" then
        return
    end
    local _B__U__G__ = 0
    local __B__U__G__ = 0
    if Bu_g == "elite_monster" then
        _B__U__G__ = TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["elite_monster_stone"]
        __B__U__G__ = TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["elite_monster_gif"]
    elseif Bu_g == "boss_monster" then
        _B__U__G__ = TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["boss_monster_stone"]
        __B__U__G__ = TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["boss_monster_gif"]
    end
    local bu__g = math["random"]()
    local _B__UG = math["random"]()
    if _B__UG <= _B__U__G__ then
        b__u__G(self["inst"], Bu_g)
    end
    local effective_gift_chance = __B__U__G__ * GetEquipmentDropDayMultiplier()
    if bu__g < effective_gift_chance then
        _BU_g__(self["inst"], Bu_g)
    end
end
function __b__U_G__:OnSave()
    if BU_g:HasComponents(self["inst"], "health") then
        local __B_UG_ = self["inst"]["components"]["health"]:GetPercent()
        self["special_data"]["health_percent"] = __B_UG_
    else
        self["special_data"]["health_percent"] = nil
    end
    return {
        ["special_data"] = self["special_data"],
        ["hh_buffs"] = self["hh_buffs"],
        ["max_effect_limit"] = self["max_effect_limit"],
        ["treasure_id"] = self["treasure_id"]
    }
end
function __b__U_G__:OnLoad(_bu_G__)
    if not _bu_G__ then
        return
    end
    if _bu_G__["treasure_id"] then
        local _b_U_G = _bu_G__["treasure_id"]
        self:SetTreasureId(_b_U_G)
    end
    self["max_effect_limit"] = _bu_G__["max_effect_limit"] or 0
    self["special_data"] = _bu_G__["special_data"] or {}
    local B_UG_ = _bu_G__["hh_buffs"] or {}
    for _bu_g, __B_u__g__ in ipairs(B_UG_) do
        local _bU_G__, _b_Ug = self:AddBuffByName(__B_u__g__["name"], __B_u__g__["value"])
    end
end
function __b__U_G__:GetDebugString()
    local __B__u__g = ""
    local __B_U__g_ = self["inst"]["prefab"]
    local _B_ug_ = BU_g:GetMonsterType(self["inst"]) or B_U_g(__B_U__g_)
    local b__Ug = _BU__G__[_B_ug_]
    if not BU_g:IsHHType(b__Ug, "table") then
        return "Mục nhập truy vấn không thành công!!"
    end
    local __b__U_G = #self["hh_buffs"]
    local b__U__g = "Lượng máu tăng hằng ngày bất thường"
    if self["special_data"] and self["special_data"]["day_add_health"] then
        local B__Ug = self["special_data"]["day_add_health"]
        local _B__uG__ = TheWorld and TheWorld["state"] and TheWorld["state"]["cycles"] or 0
        _B__uG__ = math["min"](TUNING["HH_CHANCE_CONFIG"]["MONSTER_ADD_HEALTH_DAY"], _B__uG__)
        b__U__g = string["format"]("máu tăng hằng ngày: %s(%s*%s)", B__Ug * _B__uG__, B__Ug, _B__uG__)
    end
    __B__u__g = __B__u__g .. b__U__g
    for bU_G, __Bu__G__ in ipairs(self["hh_buffs"]) do
        if __Bu__G__ and __Bu__G__["name"] and b__Ug[__Bu__G__["name"]] then
            local __B_u_G__ = b__Ug[__Bu__G__["name"]]
            local __bUg = tostring(__Bu__G__["value"])
            local _b_U__G_ = __B_u_G__["name"]
            __B__u__g = __B__u__g .. "\n" .. string["format"](_b_U__G_, __bUg)
        end
    end
    return __B__u__g
end
return __b__U_G__
