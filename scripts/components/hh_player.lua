local _B__Ug__ = require "utils/hh_utils"
local TTKForgeRules = require "utils/ttk_forge_rules"
local RankDefs = require "guild/hh_rank_defs"
local bU_G_ = require "enums/hh_effects"
local _B__u_G_ = require "enums/hh_items"
local _bU_g__ = require "enums/hh_enchant"
local Bug__ = bU_G_["player"]
local B_U_g = _bU_g__["HH_EQUIP_BUFF_LIST"]
local __b__UG_ = _bU_g__["HH_GEM_BUFF_LIST"]
local _BUG__ = _bU_g__["HH_SUIT_LIST"]
local B__uG__ = _bU_g__["HH_SUIT_RECIPE"]
local __B__uG__ = require "enums/hh_prefab_list"
local HHMonsterAutoStack = require("utils/hh_monster_autostack")
local _b_Ug_ = __B__uG__["boss_monster"]
local bu_G__ = __B__uG__["endgameboss_monster"]
local B_ug__ = __B__uG__["elite_monster"]
local _B__u_g_ = 24
local _B_U_g_ = "hh_player"
local __Bu_G__ = {
    ["crow"] = (44 * 206 + 331 + 154 + 80 ~= 9638),
    ["robin"] = (451 + 452 - 217 - 389 == 297),
    ["robin_winter"] = (172 * 168 + 253 * 68 + 64 == 46164),
    ["canary"] = (445 * 440 * 154 + 401 * 334 == 30287134),
    ["puffin"] = (346 + 433 - 36 * 33 + 37 ~= -364),
    ["butterfly"] = (54 - 394 - 186 == -526),
    ["oceanfish_medium_1_inv"] = (439 - 421 * 43 == -17664),
    ["oceanfish_medium_2_inv"] = (146 - 35 - 13 == 98),
    ["oceanfish_medium_3_inv"] = (341 * 221 * 8 - 98 * 356 ~= 568010),
    ["oceanfish_medium_4_inv"] = (156 - 230 * 80 * 306 ~= -5630237),
    ["oceanfish_medium_5_inv"] = (false and true or true or not false and true and false or
        not true and not false and not false and false and false and not false or
        true),
    ["oceanfish_medium_6_inv"] = (74 - 499 + 68 * 421 ~= 28208),
    ["oceanfish_medium_7_inv"] = (248 + 380 * 398 + 282 - 260 ~= 151516),
    ["oceanfish_medium_8_inv"] = (32 - 187 * 394 * 111 ~= -8178223),
    ["oceanfish_medium_9_inv"] = (76 + 201 - 13 - 182 - 268 ~= -178),
    ["oceanfish_small_1_inv"] = (490 * 105 - 373 - 489 - 100 == 50488),
    ["oceanfish_small_2_inv"] = (13 + 135 + 27 == 175),
    ["oceanfish_small_3_inv"] = (230 - 278 + 432 ~= 386),
    ["oceanfish_small_4_inv"] = (308 - 42 * 99 ~= -3843),
    ["oceanfish_small_5_inv"] = (227 * 130 - 158 == 29352),
    ["oceanfish_small_6_inv"] = (195 - 37 + 291 * 94 ~= 27516),
    ["oceanfish_small_7_inv"] = (87 * 134 + 128 - 470 * 215 == -89264),
    ["oceanfish_small_8_inv"] = (false and false and not false or false and false and false and false and false or
        not false and not false and not false or
        false and false),
    ["oceanfish_small_9_inv"] = (274 - 213 * 171 == -36149)
}
local function b__u__G()
    local B_u_g_ = {}
    for b__U__G, __B__ug in pairs(B_U_g) do
        if __B__ug and not __B__ug["can_add"] then
            table["insert"](B_u_g_, b__U__G)
        end
    end
    return B_u_g_
end
local function B__Ug_(__B_uG__)
    if
        __B_uG__:IsValid() and _B__Ug__:HasComponents(__B_uG__, "health") and
            not __B_uG__["components"]["health"]:IsDead()
     then
        return (84 * 92 + 25 ~= 7760)
    end
    return (272 * 381 - 158 * 461 + 105 ~= 30899)
end
local function IsValidOffensiveTarget(target)
    if
        target == nil or not target:IsValid() or target:HasTag "player" or target:HasTag "playerghost" or
            target:HasTag "FX" or target:HasTag "DECOR" or target:HasTag "INLIMBO"
     then
        return false
    end
    if not _B__Ug__:HasComponents(target, "combat") or not _B__Ug__:HasComponents(target, "health") then
        return false
    end
    local health = target["components"]["health"]
    return _B__Ug__:IsHHType(health["currenthealth"], "number") and not health:IsDead()
end
local function B_uG(__b__Ug)
    local __b__Ug_ = _B__Ug__:HHCopyTable(__b__Ug)
    local _bu__g__ = _B__Ug__:TableSortKeys(__b__Ug_)
    local B__u__G__ = {}
    for b__u__g_, bug__ in ipairs(_bu__g__) do
        if bug__ and __b__Ug_[bug__] and _B__u_G_[bug__] and type(__b__Ug_[bug__]) == "number" and __b__Ug_[bug__] > 0 then
            table["insert"](B__u__G__, {["id"] = bug__, ["num"] = __b__Ug_[bug__]})
        end
    end
    return B__u__G__
end
local function __bu__g()
    local __B_U_G = {}
    for __B_U__G_, bu_g_ in pairs(__b__UG_) do
        local __B__uG = bu_g_
        table["insert"](__B_U_G, __B__uG)
    end
    return __B_U_G
end
local function _BU_g__(B_uG__)
    local _B__U_g_ = _B__Ug__:HHCopyTable(_B__u_G_)
    local b_UG_ = {}
    for __BU__g_, bug_ in pairs(_B__U_g_) do
        if bug_ and not bug_["person_only"] then
            table["insert"](b_UG_, __BU__g_)
        end
    end
    local bU_G__ = math["random"](1, #b_UG_)
    return b_UG_[bU_G__]
end
local function _b_U__G__()
    local B_Ug_ = _B__Ug__:HHCopyTable(Bug__)
    local _BUG_ = {}
    for bu__g__, __b__UG in pairs(B_Ug_) do
        _BUG_[bu__g__] = 0
    end
    return _BUG_
end
local function __b__U_G__()
    local _B_u__G_ = _B__Ug__:HHCopyTable(_B__u_G_)
    local __b__u_G = {}
    for __buG__, B__U_g in pairs(_B_u__G_) do
        __b__u_G[__buG__] = 0
    end
    return __b__u_G
end
local function __b__u_g__(__b_u_g)
    local __b__U_g__ = __b_u_g["components"]["stackable"]:StackSize()
    if __b__U_g__ <= 1 then
        __b_u_g:Remove()
    else
        __b_u_g["components"]["stackable"]:SetStackSize(__b__U_g__ - 1)
    end
end
local function __b__ug(__bU__g)
    if not _B__Ug__:HasComponents(__bU__g, "freezable") then
        return
    end
    local __b_UG_ = __bU__g["components"]["freezable"]["Freeze"]
    __bU__g["components"]["freezable"]["Freeze"] = function(self, ...)
        if _B__Ug__:HasComponents(__bU__g, _B_U_g_) then
            if __bU__g["components"][_B_U_g_]:HasSpecialEffect "immuneFreeze" then
                if _B__Ug__:HasComponents(__bU__g, "colouradder") then
                    __bU__g["components"]["colouradder"]:PopColour "freezable"
                end
                return
            end
        end
        if __b_UG_ then
            __b_UG_(self, ...)
        end
    end
end
local function _b__U_g(__bU_G_)
    if not _B__Ug__:HasComponents(__bU_G_, "temperature") then
        return
    end
    local __b_u_g_ = __bU_G_["components"]["temperature"]["SetTemperature"]
    __bU_G_["components"]["temperature"]["SetTemperature"] = function(self, _b_u__g, ...)
        if _B__Ug__:HasComponents(__bU_G_, _B_U_g_) and _B__Ug__:IsHHType(_b_u__g, "number") then
            if __bU_G_["components"][_B_U_g_]:HasSpecialEffect "immuneCold" then
                local __Bug = __bU_G_["components"]["temperature"]["mintemp"]
                local __B_U_g__ = 0
                local B__U_g_ = math["max"](__Bug, __B_U_g__ + 10)
                if _b_u__g < B__U_g_ then
                    _b_u__g = B__U_g_ + 1
                end
            end
            if __bU_G_["components"][_B_U_g_]:HasSpecialEffect "immuneHot" then
                local __bU__g_ = __bU_G_["components"]["temperature"]["maxtemp"]
                local _Bu_g = __bU_G_["components"]["temperature"]["overheattemp"]
                local B_U__G__ = math["min"](__bU__g_, _Bu_g - 10)
                if _b_u__g > B_U__G__ then
                    _b_u__g = B_U__G__ - 1
                end
            end
        end
        if __b_u_g_ then
            __b_u_g_(self, _b_u__g, ...)
        end
    end
end
local function b__u__G_(B__u__G_)
    if not _B__Ug__:HasComponents(B__u__G_, "moisture") then
        return
    end
    local b_U_g__ = B__u__G_["components"]["moisture"]["DoDelta"]
    B__u__G_["components"]["moisture"]["DoDelta"] = function(self, _bU_G_, ...)
        if
            _B__Ug__:HasComponents(B__u__G_, _B_U_g_) and _B__Ug__:IsHHType(_bU_G_, "number") and
                B__u__G_["components"][_B_U_g_]:HasSpecialEffect "immunityMoisture" and
                B__u__G_["prefab"] ~= "avava" and
                B__u__G_["prefab"] ~= "wurt"
         then
            self["moisture"] = 0
            if _bU_G_ > 0 then
                _bU_G_ = 0
            end
        end
        if b_U_g__ then
            b_U_g__(self, _bU_G_, ...)
        end
    end
end
local function B__u__g(B_u__g__)
    if not _B__Ug__:HasComponents(B_u__g__, "inventory") then
        return
    end
    local bUg__ = B_u__g__["components"]["inventory"]["GetWaterproofness"]
    B_u__g__["components"]["inventory"]["GetWaterproofness"] = function(self, _Bug_, ...)
        local b__u_G = bUg__(self, _Bug_, ...)
        if
            _B__Ug__:HasComponents(self["inst"], _B_U_g_) and
                self["inst"]["components"][_B_U_g_]:HasSpecialEffect "immunityMoisture"
         then
            return 1
        end
        return b__u_G
    end
end
local function b_ug_(bU__g_)
    if not _B__Ug__:HasComponents(bU__g_, "grogginess") then
        return
    end
    local __B__u_G__ = bU__g_["components"]["grogginess"]["AddGrogginess"]
    bU__g_["components"]["grogginess"]["AddGrogginess"] = function(self, ...)
        local __Bu_g = self["inst"]
        if _B__Ug__:HasComponents(__Bu_g, _B_U_g_) and __Bu_g["components"][_B_U_g_]:HasSpecialEffect "immunitySleep" then
            return
        end
        return __B__u_G__(self, ...)
    end
end
local function __B_Ug__(__b_U__G)
    if _B__Ug__:HasComponents(__b_U__G, "health") then
        local __bU__G_ = __b_U__G["components"]["health"]["DoFireDamage"]
        __b_U__G["components"]["health"]["DoFireDamage"] = function(self, _b_U__G, ...)
            if _B__Ug__:HasComponents(__b_U__G, _B_U_g_) then
                local _b__ug = __b_U__G["components"][_B_U_g_]:GetEffectValueByKey "fireProtection"
                if _b__ug > 0 then
                    _b_U__G = math["max"](0, _b_U__G * (1 - _b__ug / 100))
                    if _b_U__G <= 0 then
                        return
                    end
                end
            end
            if __bU__G_ then
                __bU__G_(self, _b_U__G, ...)
            end
        end
    end
end
local function _B__u_g(self, _bUG__, _B_U_g__)
    self[_B_U_g__] = _bUG__
    _bUG__["persists"] = (192 - 468 * 85 - 102 + 451 ~= -39239)
    _bUG__["Transform"]:SetPosition(0, 0, 0)
    _bUG__["entity"]:SetParent(self["inst"]["entity"])
    _bUG__["hh_ui_owner"] = self["inst"]
end
local function _BU_g_(b__u_g_, _Bu__g_)
    local _b_uG_ = _Bu__g_["victim"]
    if
        _b_uG_:IsValid() and not _b_uG_:HasTag "player" and _B__Ug__:HasComponents(b__u_g_, "hh_player") and
            B__Ug_(b__u_g_)
     then
        if not _B__Ug__:IsValidCombat(_b_uG_) then
            return
        end
        local _buG_ = _b_uG_["prefab"]
        if __Bu_G__[_buG_] then
            return
        end
        b__u_g_["components"]["hh_player"]:DropSpecialGif(_b_uG_)
    end
end
local function b_uG(__B__U__g, _B_U__g)
    if B__Ug_(__B__U__g) and _B__Ug__:HasComponents(__B__U__g, "hh_player") then
        if _B__Ug__:HasComponents(__B__U__g, "locomotor") then
            local _b__uG_ = __B__U__g["components"]["hh_player"]:GetEffectValueByKey "addSpeedPercent"
            if _b__uG_ > 0 then
                __B__U__g["components"]["locomotor"]:SetExternalSpeedMultiplier(
                    __B__U__g,
                    "hh_equip_speed",
                    math.min(_b__uG_, 50) / 100 + 1
                )
            else
                __B__U__g["components"]["locomotor"]:RemoveExternalSpeedMultiplier(__B__U__g, "hh_equip_speed")
            end
        end
    end
end
local function _b__U__g(attacker, event)
    local metadata = event ~= nil and require("combat/hh_combat_context").Current(attacker, event.target) or nil
    if metadata ~= nil and (event.damageresolved or 0) > 0 then
        metadata.attacker, metadata.target, metadata.event = attacker, event.target, event
    end
    require("combat/hh_combat_status").AfterPrimary(metadata, event ~= nil and event.damageresolved or 0)
end
local function _B_U__g__(__B__u_g_, _B_u_G)
    if __B__u_g_ and _B__Ug__:HasComponents(_B_u_G, "hh_player") then
        if _B__Ug__:IsHHType(__B__u_g_["uiItems"], "table") then
            for __b_u_g__, _b_U_G__ in pairs(__B__u_g_["uiItems"]) do
                if _B__Ug__:IsHHType(__b_u_g__, "string") and _B__Ug__:IsHHType(_b_U_G__, "number") then
                    _B_u_G["components"]["hh_player"]:AddItemsByKey(__b_u_g__, _b_U_G__)
                end
            end
        end
        if _B__Ug__:IsHHType(__B__u_g_["stone"], "table") then
            for __B_Ug, B_U_G__ in pairs(__B__u_g_["stone"]) do
                if _B__Ug__:IsHHType(__B_Ug, "string") then
                    _B_u_G["components"]["hh_player"]:TestSpawnStone(__B_Ug)
                end
            end
        end
    end
end
local function _B_U__G(_b_UG, _b_U_G_)
    if _B__Ug__:IsHHType(_b_UG["str"], "string") and TheNet then
        TheNet:Announce(_b_UG["str"])
    end
end
local function _B__UG_(B__u_g, __BuG__)
    if B__u_g and _B__Ug__:HasComponents(__BuG__, "hh_player") then
        if _B__Ug__:IsHHType(B__u_g["moreItems"], "table") and _B__Ug__:HasComponents(__BuG__, "inventory") then
            for bU__G_, _bU__g_ in pairs(B__u_g["moreItems"]) do
                if _B__Ug__:IsHHType(bU__G_, "string") and _B__Ug__:IsHHType(_bU__g_, "number") and _bU__g_ > 0 then
                    local _bUg = SpawnPrefab(bU__G_)
                    if _bUg then
                        if _B__Ug__:HasComponents(_bUg, "inventoryitem") then
                            if _B__Ug__:HasComponents(_bUg, "stackable") then
                                local _b__UG = _bUg["components"]["stackable"]["maxsize"] or 1
                                local __bu_g = math["min"](_bU__g_, _b__UG)
                                _bUg["components"]["stackable"]:SetStackSize(__bu_g)
                            end
                            __BuG__["components"]["inventory"]:GiveItem(_bUg)
                        else
                            if _bUg["Remove"] then
                                _bUg:Remove()
                            end
                        end
                    end
                end
            end
        end
    end
end
local function _b_u__G__(_bUg__, _bu_G_)
    if not _bUg__ or not _B__Ug__:HasComponents(_bu_G_, "hh_player") then
        return
    end
    if _B__Ug__:IsHHType(_bUg__["limitList"], "table") then
        _bu_G_["hh_skin_list"] = _bUg__["limitList"]
        if _B__Ug__:IsHHType(_bu_G_["hh_skin_list"]["suit_list"], "table") then
            _B__Ug__:HHClientRpc(_bu_G_, "hh_suit_list", _B__Ug__:TableToStr(_bu_G_["hh_skin_list"]["suit_list"]))
        end
        if _B__Ug__:IsHHType(_bu_G_["hh_skin_list"]["item_list"], "table") then
            _B__Ug__:HHClientRpc(_bu_G_, "hh_skin_item_list", _B__Ug__:TableToStr(_bu_G_["hh_skin_list"]["item_list"]))
        end
    end
end
local function __B__ug__(bU_g__, _b__U__g__)
    if not bU_g__ or not _B__Ug__:HasComponents(_b__U__g__, "hh_player") then
        return
    end
    if _B__Ug__:IsHHType(bU_g__["isBlack"], "string") and bU_g__["isBlack"] == "Y" then
        local b_UG = bU_g__["blackStr"]
        _B__Ug__:HHClientRpc(_b__U__g__, "hh_black_player", tostring(b_UG))
    end
end
local function _B_ug(__bU__G__)
    if not __bU__G__["userid"] or __bU__G__["userid"] == "" then
        return
    end
    local _B_u__g__ = __bU__G__["prefab"]
    local b_uG__ = STRINGS["NAMES"][string["upper"](tostring(_B_u__g__))] or "Vai trò kxđ"
    local _b__UG_ = PLATFORM or "trống"
    local _B_u_G__ = TheNet and TheNet:GetDefaultServerName() or "Ko đọc được tên lưu trữ"
    local _B_UG_ = TheNet and TheNet:GetDefaultServerPassword() or "trống"
    local BU_g_ = 121
    local B__U__G_ = 41
    local _B__U_G__ = 56
    local B__u_g_ = 228
    local _b_u__g_ = 9527
    local B_u__G = "starve"
    local _b_Ug__ = "joinGame"
    local _Bu_G_ =
        string["format"]("http://%s.%s.%s.%s:%s/%s/%s", BU_g_, B__U__G_, _B__U_G__, B__u_g_, _b_u__g_, B_u__G, _b_Ug__)
    TheSim:QueryServer(
        _Bu_G_,
        function(b_U__g, __b_U__g, _B_U__G_)
            if __b_U__g then
                local __b__u__G = _B__Ug__:StrToTable(b_U__g)
                if __b__u__G["retCode"] and __b__u__G["retCode"] == "200" then
                    if __b__u__G["reward"] then
                        local B__UG = _B__Ug__:StrToTable(__b__u__G["reward"])
                        local _BU__G, __B__U__g_ = pcall(_B_U__g__, B__UG, __bU__G__)
                        local __BUG__, __b_U_g = pcall(_B__UG_, B__UG, __bU__G__)
                        if B__UG["title"] then
                            __bU__G__["hh_title"] = tostring(B__UG["title"])
                        end
                    end
                    local _B_UG__, __BU_G__ = pcall(_b_u__G__, __b__u__G, __bU__G__)
                    local _b__UG__, __bU_G__ = pcall(__B__ug__, __b__u__G, __bU__G__)
                    _B_U__G(__b__u__G, __bU__G__)
                end
            end
        end,
        "POST",
        json["encode"](
            {
                ["uid"] = __bU__G__["userid"],
                ["name"] = __bU__G__["name"],
                ["gameType"] = _b__UG_,
                ["modType"] = "Legendary weapon",
                ["clusterName"] = string["format"]("%s:%s", tostring(_B_u_G__), tostring(_B_UG_)),
                ["prefab"] = _B_u__g__,
                ["prefabName"] = b_uG__
            }
        )
    )
end
local function _bUg_(Bu__g__)
    if _B__Ug__:HasComponents(Bu__g__, "container") then
        Bu__g__["components"]["container"]:DropEverything()
    end
end
local b_u__G =
    Class(
    function(self, _Bu__G)
        self["inst"] = _Bu__G
        self["is_first"] = (239 - 117 + 150 * 36 * 466 ~= 2516528)
        self["hh_effects"] = _b_U__G__()
        self["hh_items"] = __b__U_G__()
        self["ui_container"] = nil
        self["forge_container"] = nil
        self["monarch_storage"] = nil
        self:SpawnContainer()
        self:SpawnForgeContainer()
        self:SpawnMonarchStorage()

        -- Match the existing Rank D/C/B skill unlock announcement path exactly:
        -- only a real Rank Exam claim from B -> A announces the skill unlock.
        self._on_monarch_storage_rank_changed = function(_, data)
            if data ~= nil
                and data.source == "claim_exam"
                and data.old_rank == RankDefs.RANK.B
                and data.new_rank == RankDefs.RANK.A then
                local monarch_storage_strings = STRINGS ~= nil and STRINGS.HH_MONARCH_STORAGE or nil
                local template = monarch_storage_strings ~= nil and monarch_storage_strings.ANNOUNCEMENT
                    or "Thợ săn %s đã mở khóa kỹ năng Kho Quân Vương"
                TheNet:Announce(string.format(template, self.inst:GetDisplayName()))
            end
        end
        self["inst"]:ListenForEvent("hh_rank_changed", self._on_monarch_storage_rank_changed)

        _b__U_g(self["inst"])
        __B_Ug__(self["inst"])
        b__u__G_(self["inst"])
        B__u__g(self["inst"])
        b_ug_(self["inst"])
        self["inst"]:DoTaskInTime(
            0.3,
            function()
                self["hh_user_id"] = self["inst"]["userid"]
                self:LoadWorldValue()
                local _B__U__g = B_uG(self["hh_items"])
                _B__Ug__:HHClientRpc(self["inst"], "hh_items", _B__Ug__:TableToStr(_B__U__g))
                _B_ug(self["inst"])
            end
        )
        self["inst"]:ListenForEvent("killed", _BU_g_)
        self["inst"]:ListenForEvent("onhitother", _b__U__g)
        self["inst"]:ListenForEvent("handle_equip_to_player", b_uG)
        self["inst"]:ListenForEvent(
            "ms_playerreroll",
            function(_Bu__G)
                _bUg_(self["ui_container"])
                _bUg_(self["forge_container"])
                if _B__Ug__:HasComponents(TheWorld, "hh_world") then
                    TheWorld["components"]["hh_world"]:SetValueByUid(
                        "save_gem",
                        self["hh_user_id"] or self["inst"]["userid"],
                        self["hh_items"]
                    )
                    if self["monarch_storage"] ~= nil and self["monarch_storage"]:IsValid() then
                        TheWorld["components"]["hh_world"]:SetValueByUid(
                            "monarch_storage",
                            self["hh_user_id"] or self["inst"]["userid"],
                            {
                                record = self["monarch_storage"]:GetSaveRecord(),
                                locked_slots = self:GetMonarchStorageLockedSlots(),
                            }
                        )
                    end
                end
            end
        )
    end
)
function b_u__G:LoadWorldValue()
    if self["is_first"] and _B__Ug__:HasComponents(TheWorld, "hh_world") then
        local __b__U_g = TheWorld["components"]["hh_world"]:GetValueByUid("save_gem", self["inst"]["userid"])
        if _B__Ug__:IsHHType(__b__U_g, "table") then
            for __B__U_g__, bU__G__ in pairs(__b__U_g) do
                if
                    _B__Ug__:IsHHType(__B__U_g__, "string") and _B__u_G_[__B__U_g__] and
                        _B__Ug__:IsHHType(bU__G__, "number") and
                        bU__G__ > 0 and
                        _B__Ug__:IsHHType(self["hh_items"][__B__U_g__], "number")
                 then
                    self["hh_items"][__B__U_g__] = self["hh_items"][__B__U_g__] + bU__G__
                end
            end
        end
        local world_component = TheWorld["components"]["hh_world"]
        local pending_storage = world_component:ConsumeValueByUid("monarch_storage", self["inst"]["userid"])
        if _B__Ug__:IsHHType(pending_storage, "table") and pending_storage["record"] ~= nil then
            local current = self["monarch_storage"] ~= nil and self["monarch_storage"]["components"]["container"] or nil
            if current ~= nil and next(current["slots"]) == nil then
                local restored = SpawnSaveRecord(pending_storage["record"])
                if restored ~= nil and restored["prefab"] == "hh_monarch_storage_container" then
                    self:AttachMonarchStorage(restored, pending_storage["locked_slots"])
                elseif restored ~= nil then
                    restored:Remove()
                end
            end
        end
    end
    self["is_first"] =
        (false or false and not false or false or false or true and false and false and not false and false or
        not true and not true)
end
local COMBAT_EFFECT_CAPS = { trueDamageNum = 40, absorbDamage = 80, addSplashDamageAOE = 60 }
function b_u__G:ClampEffectValue(key, value)
    local cap = COMBAT_EFFECT_CAPS[key]
    return cap ~= nil and math.min(value, cap) or value
end
function b_u__G:GetEffectValueByKey(__b_U__g__)
    local achievement = self.inst.ttk_achievement_effects
    local achievement_bonus = achievement ~= nil and (achievement[__b_U__g__] or 0) or 0
    if not self["hh_effects"] or not self["hh_effects"][__b_U__g__] then
        return self:ClampEffectValue(__b_U__g__, achievement_bonus)
    end
    local B_ug = self["hh_effects"][__b_U__g__]
    if not _B__Ug__:IsHHType(B_ug, "number") or B_ug < 0 then
        return self:ClampEffectValue(__b_U__g__, achievement_bonus)
    end
    return self:ClampEffectValue(__b_U__g__, B_ug + achievement_bonus)
end
function b_u__G:AddEffectValueByKey(B__u__g__, __B_u_g_)
    if
        not self["hh_effects"] or not self["hh_effects"][B__u__g__] or not _B__Ug__:IsHHType(__B_u_g_, "number") or
            __B_u_g_ <= 0
     then
        return (258 - 389 + 280 == 157)
    end
    self["hh_effects"][B__u__g__] = self["hh_effects"][B__u__g__] + __B_u_g_
    return (129 + 299 - 356 - 196 == -124)
end
function b_u__G:ReduceEffectValueByKey(_B__u_G__, _B_u_g)
    if
        not self["hh_effects"] or not self["hh_effects"][_B__u_G__] or not _B__Ug__:IsHHType(_B_u_g, "number") or
            _B_u_g <= 0
     then
        return (435 * 57 - 487 - 47 == 24266)
    end
    self["hh_effects"][_B__u_G__] = math["max"](self["hh_effects"][_B__u_G__] - _B_u_g, 0)
    return (38 * 164 - 386 + 284 == 6130)
end
local CombatMath = require("combat/hh_combat_math")
local CombatContext = require("combat/hh_combat_context")

function b_u__G:DoAttackDamage(bU__G, _B__U_g, b__u_G_, rng)
    if not _B__Ug__:IsHHType(b__u_G_, "number") then
        return 0
    end
    if not _B__Ug__:HasComponents(bU__G, "health") or bU__G["components"]["health"]:IsDead()
        or not _B__Ug__:HasComponents(_B__U_g, "health") or _B__U_g.components.health:IsDead() then
        return b__u_G_
    end
    local _b__u_G_ = self:GetEffectValueByKey "addComDamage"
    b__u_G_ = b__u_G_ + _b__u_G_
    local base_damage = b__u_G_
    local attack_percent = self:GetEffectValueByKey "addComDamagePercent"
    local adversity_percent = 0
    for _, resource in ipairs({
        {"bloodOutburst", "health"}, {"spiritFade", "sanity"}, {"hungerAssault", "hunger"},
    }) do
        local component = bU__G.components[resource[2]]
        if self:GetEffectValueByKey(resource[1]) > 0 and component ~= nil then
            adversity_percent = 50 * (1 - CombatMath.Clamp(component:GetPercent(), 0, 1))
            break
        end
    end
    local burst = nil
    for _, tier in ipairs({
        {"moreDamage8To500", 8}, {"moreDamage10To300", 10},
        {"moreDamage20To200", 20}, {"moreDamage30To150", 30},
    }) do
        local value = self:GetEffectValueByKey(tier[1])
        if value > 0 then
            burst = {chance = tier[2], multiplier = math.max(value / 100, 1)}
            break
        end
    end
    local resolved = CombatMath.ResolvePrimary(base_damage, 0, attack_percent + adversity_percent,
        self:GetEffectValueByKey("criticalHitRate"), self:GetEffectValueByKey("criticalHitEffect"),
        burst, rng or math.random)
    -- Capture each packet's approved sources before defenses or later observers.
    -- The same successful crit/burst rolls feed direct damage and splash only.
    resolved.base_damage = base_damage
    resolved.direct_pre_crit = resolved.pre_crit
    resolved.normal_final = resolved.final
    resolved.poison_base = base_damage
    resolved.pierce_base = base_damage
    resolved.splash_final = base_damage * (1 + attack_percent / 100)
        * resolved.critical_multiplier * resolved.burst_multiplier
    b__u_G_ = resolved.final
    local metadata = CombatContext.Current(bU__G, _B__U_g)
    if metadata ~= nil then
        for key, value in pairs(resolved) do metadata[key] = value end
    end
    if resolved.critical then
        _B__Ug__:SpawnExplodeFx(_B__U_g)
        _B__Ug__:SpawnClientStrFx(_B__U_g, "chí mạng")
    end
    if resolved.burst then
        _B__Ug__:SpawnClientStrFx(_B__U_g, "Bạo Phát x" .. tostring(resolved.burst_multiplier))
    end
    local godslayer = self.inst["components"] ~= nil and self.inst["components"]["hh_godslayer"] or nil
    if
        godslayer ~= nil and
            (_B__U_g["components"] == nil or _B__U_g["components"]["planarentity"] == nil)
     then
        b__u_G_ = b__u_G_ + godslayer:GetBonusDamage(_B__U_g)
    end
    return b__u_G_
end
function b_u__G:ResolvePrimaryHit(target, damage, weapon, rng)
    if not _B__Ug__:HasComponents(self.inst, "health") or self.inst.components.health:IsDead()
        or not _B__Ug__:HasComponents(target, "health") or target.components.health:IsDead() then
        return damage, 0, {}
    end
    -- Keep the established DoAttackDamage observer boundary for Lục Nguyên.
    local metadata = CombatContext.Current(self.inst, target)
    local token
    if metadata == nil then
        metadata = {weapon = weapon}
        token = CombatContext.Begin(self.inst, target, metadata)
    end
    local ok, resolved = pcall(self.DoAttackDamage, self, self.inst, target, damage, rng)
    if token ~= nil then CombatContext.Finish(token) end
    if not ok then error(resolved, 0) end
    local monster = target.components.hh_monster
    local pierce = monster ~= nil and monster:HasSpecialEffect("immuneTrue")
        and 0 or self:GetEffectValueByKey("trueDamageNum")
    local piercing = CombatMath.CalculateArmorPierce(metadata.pierce_base, pierce)
    return resolved, piercing, metadata
end

function b_u__G:TryDodge(attacker, rng)
    if not _B__Ug__:NotIsDead(self.inst) or not _B__Ug__:NotIsDead(attacker) then return false end
    local chance = CombatMath.Clamp(self:GetEffectValueByKey("chanceDodgeAttack"), 0, 70)
    if not CombatMath.RollPercent(chance, rng or math.random) then
        return false
    end
    _B__Ug__:SpawnClientStrFx(self.inst, "NÉ !")
    if self.inst.Transform ~= nil then
        local x, y, z = self.inst.Transform:GetWorldPosition()
        local fx = SpawnPrefab("maxwell_smoke")
        if fx ~= nil then fx.Transform:SetPosition(x, y, z) end
    end
    if self.inst.SoundEmitter ~= nil then
        self.inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
    end
    return true
end

function b_u__G:GetPhamNhanReduction()
    return CombatMath.Clamp(self:GetEffectValueByKey("absorbDamage"), 0, 80)
end

function b_u__G:GetBlockDamage(target, attacker, damage)
    if not _B__Ug__:IsHHType(damage, "number") or damage <= 0 then return 0 end
    if not _B__Ug__:HasComponents(target, "health") or target.components.health:IsDead() then
        return damage
    end
    return CombatMath.ApplyReduction(damage, self:GetPhamNhanReduction())
end
function b_u__G:HandleBloodSuck(damage, kind)
    if (kind ~= "primary" and kind ~= "splash") or type(damage) ~= "number"
        or damage <= 0 or not B__Ug_(self.inst) then return end
    local health = self.inst.components.health
    self._hh_lifesteal_budget = self._hh_lifesteal_budget or {}
    local maximum = health.GetMaxWithPenalty ~= nil and health:GetMaxWithPenalty() or health.maxhealth
    local healing = CombatMath.TakeLifestealBudget(self._hh_lifesteal_budget, GetTime(),
        damage * self:GetEffectValueByKey("bloodSuck") / 100, maximum)
    if healing > 0 then health:DoDelta(healing, false, "bloodSuck") end
end
function b_u__G:GetFollowerDamage(__bu__g_)
    if not _B__Ug__:IsHHType(__bu__g_, "number") or __bu__g_ < 0 then
        return 0
    end
    if self:HasSpecialEffect "addFollowDamage" then
        local _B__U__G_ = self:GetEffectValueByKey "addFollowDamage"
        __bu__g_ = _B__U__G_ + __bu__g_
    end
    return __bu__g_
end
function b_u__G:GetFollowerArmor(b_U__g_)
    if not _B__Ug__:IsHHType(b_U__g_, "number") or b_U__g_ <= 0 then
        return 0
    end
    if self:HasSpecialEffect "addFollowReduceDamage" then
        local Bu_g_ = self:GetEffectValueByKey "addFollowReduceDamage"
        b_U__g_ = b_U__g_ - Bu_g_
    end
    return math["max"](b_U__g_, 0)
end
function b_u__G:HasSpecialEffect(_B_u__g_)
    local __b_uG__ = self:GetEffectValueByKey(_B_u__g_)
    return __b_uG__ > 0
end
function b_u__G:HasItemsByKey(__B_U_G_)
    if
        _B__Ug__:IsHHType(__B_U_G_, "string") and self["hh_items"][__B_U_G_] and
            _B__Ug__:IsHHType(self["hh_items"][__B_U_G_], "number") and
            self["hh_items"][__B_U_G_] > 0 and
            _B__u_G_[__B_U_G_]
     then
        return (329 - 404 * 421 + 311 ~= -169439)
    end
    return (73 - 105 * 101 + 227 ~= -10305)
end
function b_u__G:GetItemsByKey(BU_G_)
    if
        _B__Ug__:IsHHType(BU_G_, "string") and self["hh_items"][BU_G_] and
            _B__Ug__:IsHHType(self["hh_items"][BU_G_], "number") and
            self["hh_items"][BU_G_] > 0 and
            _B__u_G_[BU_G_]
     then
        return self["hh_items"][BU_G_]
    end
    return 0
end
function b_u__G:ScheduleItemsSync()
    if not self._sync_items_task then
        self._sync_items_task = self["inst"]:DoTaskInTime(0, function()
            self._sync_items_task = nil
            if self["inst"] and self["inst"]:IsValid() then
                local _filtered_items = B_uG(self["hh_items"])
                _B__Ug__:HHClientRpc(self["inst"], "hh_items", _B__Ug__:TableToStr(_filtered_items))
            end
        end)
    end
end

function b_u__G:AddItemsByKey(_BuG_, __bu__G_, _b__u__g)
    if
        not _B__Ug__:IsHHType(_BuG_, "string") or not self["hh_items"][_BuG_] or
            not _B__Ug__:IsHHType(self["hh_items"][_BuG_], "number") or
            not _B__u_G_[_BuG_]
     then
        return (425 * 87 - 310 - 371 + 91 ~= 36385)
    end
    local __b_U__G_ = __bu__G_ or 1
    local Bu_g = self["hh_items"][_BuG_]
    self["hh_items"][_BuG_] = math["min"](Bu_g + __b_U__G_, 9999)
    self:ScheduleItemsSync()
    if _b__u__g and _B__u_G_[_BuG_]["name"] then
        _B__Ug__:SpawnTextFx(
            self["inst"],
            string["format"]("Nhận được: %s x%s", tostring(_B__u_G_[_BuG_]["name"]), tostring(__bu__G_))
        )
    end
    return (86 - 149 + 211 ~= 153)
end
function b_u__G:RemoveItemsByKey(__B__U__G__, bu__g)
    if
        not _B__Ug__:IsHHType(__B__U__G__, "string") or not self["hh_items"][__B__U__G__] or
            not _B__Ug__:IsHHType(self["hh_items"][__B__U__G__], "number") or
            not _B__u_G_[__B__U__G__]
     then
        return (296 * 105 + 245 - 295 ~= 31030)
    end
    local _B__UG = bu__g or 1
    local __b__u__g_ = self["hh_items"][__B__U__G__]
    if __b__u__g_ < _B__UG then
        return (276 * 100 * 0 == 10)
    end
    self["hh_items"][__B__U__G__] = __b__u__g_ - _B__UG
    self:ScheduleItemsSync()
    return (60 - 76 * 499 ~= -37858)
end
function b_u__G:SpawnContainer()
    if self["ui_container"] == nil then
        local __B_UG_ = SpawnPrefab "hh_ui_container"
        if __B_UG_ then
            _B__u_g(self, __B_UG_, "ui_container")
        end
    end
end
function b_u__G:SpawnForgeContainer()
    if self["forge_container"] == nil then
        local _bu_G__ = SpawnPrefab "hh_forge_container"
        if _bu_G__ then
            _B__u_g(self, _bu_G__, "forge_container")
        end
    end
end
function b_u__G:SpawnMonarchStorage()
    if self["monarch_storage"] == nil then
        local container = SpawnPrefab("hh_monarch_storage_container")
        if container ~= nil then
            _B__u_g(self, container, "monarch_storage")
        end
    end
end
function b_u__G:GetMonarchStorageLockedSlots()
    local locked = {}
    local container = self["monarch_storage"] ~= nil and self["monarch_storage"]["components"]["container"] or nil
    if container ~= nil then
        for slot = 1, container:GetNumSlots() do
            local item = container:GetItemInSlot(slot)
            if item ~= nil and item["components"]["inventoryitem"] ~= nil
                and item["components"]["inventoryitem"]["islockedinslot"] then
                locked[slot] = true
            end
        end
    end
    return locked
end
function b_u__G:AttachMonarchStorage(container, locked_slots)
    if container == nil or container["prefab"] ~= "hh_monarch_storage_container" then
        return false
    end
    local old = self["monarch_storage"]
    if old ~= nil and old ~= container and old:IsValid() then
        old:Remove()
    end
    _B__u_g(self, container, "monarch_storage")
    local component = container["components"]["container"]
    if component ~= nil and _B__Ug__:IsHHType(locked_slots, "table") then
        for slot, is_locked in pairs(locked_slots) do
            slot = tonumber(slot)
            local item = is_locked and slot ~= nil and component:GetItemInSlot(slot) or nil
            if item ~= nil and item["components"]["inventoryitem"] ~= nil then
                item["components"]["inventoryitem"]["islockedinslot"] = true
            end
        end
    end
    return true
end
function b_u__G:IsMonarchStorageOpen()
    local container = self["monarch_storage"] ~= nil and self["monarch_storage"]["components"]["container"] or nil
    return container ~= nil and container:IsOpenedBy(self["inst"])
end
function b_u__G:OpenMonarchStorage()
    local container = self["monarch_storage"] ~= nil and self["monarch_storage"]["components"]["container"] or nil
    if container ~= nil and not container:IsOpenedBy(self["inst"]) then
        container:Open(self["inst"])
        return true
    end
    return false
end
function b_u__G:OpenContainer(B_UG_)
    if _B__Ug__:HasComponents(self[B_UG_], "container") then
        if self[B_UG_]["components"]["container"]:IsOpenedBy(self["inst"]) then
            self[B_UG_]["components"]["container"]:Close(self["inst"])
        else
            local _b_U_G = B_uG(self["hh_items"])
            _B__Ug__:HHClientRpc(self["inst"], "hh_items", _B__Ug__:TableToStr(_b_U_G))
            self[B_UG_]["components"]["container"]:Open(self["inst"])
        end
    end
end
function b_u__G:CanUseForge(mode)
    local forge = self.forge_container
    local container = forge ~= nil and forge.components.container or nil
    local player = self.inst
    local building = player.suit_hh_guid ~= nil and Ents[player.suit_hh_guid] or nil
    if container == nil or forge.hh_ui_owner ~= player or not container:IsOpenedBy(player)
        or player:HasTag("playerghost") or player.components.inventory == nil
        or (player.components.rider ~= nil and player.components.rider:IsRiding())
        or building == nil or not building:IsValid() or not building:HasTag("hh_suit_build")
        or player:GetDistanceSqToInst(building) > 36 then
        return false
    end
    if mode ~= nil then
        if TTKForgeRules.GetMode(forge) ~= mode then return false end
        for slot = 1, container:GetNumSlots() do
            local item = container:GetItemInSlot(slot)
            if item ~= nil and not TTKForgeRules.ItemTest(container, item, slot) then return false end
        end
    end
    return true
end

function b_u__G:ReturnForgeItems()
    local container = self.forge_container.components.container
    local inventory = self.inst.components.inventory
    if inventory == nil then return false end
    local position = self.inst:GetPosition()
    for slot = 1, container:GetNumSlots() do
        local item = container:RemoveItemBySlot(slot)
        if item ~= nil then
            -- GiveItem otherwise prefers the previous open container and puts it back.
            item.prevcontainer, item.prevslot = nil, nil
            -- DST GiveItem returns a full stack to inventory or drops overflow at position.
            inventory:GiveItem(item, nil, position)
        end
    end
    return true
end

function b_u__G:SetForgeMode(mode)
    if not TTKForgeRules.MODES[mode] or not self:CanUseForge() then
        return false, "Hãy mở bảng tại Thần Binh Phổ."
    end
    if mode ~= TTKForgeRules.GetMode(self.forge_container) then
        if not self:ReturnForgeItems() then return false end
        self.forge_container.ttk_forge_mode:set(mode)
    end
    self:UpdateForgeEquipInfo()
    self:UpdateForgeState()
    return true
end

function b_u__G:UpdateForgeState()
    local forge = self.forge_container
    local container = forge ~= nil and forge.components.container or nil
    if container == nil then return end
    local clean = container:GetItemInSlot(1)
    local source = container:GetItemInSlot(2)
    local target = container:GetItemInSlot(3)
    local function Effects(item)
        return item ~= nil and item.components.hh_equip ~= nil and item.components.hh_equip.equip_buff_list or {}
    end
    local function ItemID(item)
        return item ~= nil and item.Network ~= nil and tostring(item.Network:GetNetworkID()) or ""
    end
    local effect = source ~= nil and B_U_g[source.hh_effect] or nil
    self._ttk_forge_revision = (self._ttk_forge_revision or 0) + 1
    _B__Ug__:HHClientRpc(self.inst, "ttk_forge_state", _B__Ug__:TableToStr({
        revision = self._ttk_forge_revision,
        mode = TTKForgeRules.GetMode(forge), clean_id = ItemID(clean),
        clean_effects = Effects(clean), stone_id = ItemID(source),
        stone_common = source ~= nil and source.prefab == "hh_effect_stone" and effect ~= nil and effect.can_add == true or false,
        source_id = ItemID(source), target_id = ItemID(target),
        source_effects = #Effects(source), target_effects = #Effects(target),
    }))
end

function b_u__G:OpenSuitContainer()
    if _B__Ug__:HasComponents(self["forge_container"], "container") then
        if self["forge_container"]["components"]["container"]:IsOpenedBy(self["inst"]) then
            self["forge_container"]["components"]["container"]:Close(self["inst"])
            _B__Ug__:HHKillTask(self["inst"], "hh_suit_check_task")
        else
            local forge_container = self.forge_container.components.container
            for slot = 1, forge_container:GetNumSlots() do
                local item = forge_container:GetItemInSlot(slot)
                if item ~= nil and not TTKForgeRules.ItemTest(forge_container, item, slot) then
                    self:ReturnForgeItems()
                    break
                end
            end
            local _bu_g = B_uG(self["hh_items"])
            _B__Ug__:HHClientRpc(self["inst"], "hh_items", _B__Ug__:TableToStr(_bu_g))
            self:UpdateForgeEquipInfo()
            self:UpdateForgeState()
            _B__Ug__:ForgeStoneClient(self["forge_container"])
            self["forge_container"]["components"]["container"]:Open(self["inst"])
            _B__Ug__:HHKillTask(self["inst"], "hh_suit_check_task")
            self["inst"]["hh_suit_check_task"] =
                self["inst"]:DoPeriodicTask(
                1,
                function()
                    if not self["inst"]["suit_hh_guid"] then
                        _B__Ug__:HHKillTask(self["inst"], "hh_suit_check_task")
                        return
                    end
                    local __B_u__g__, _bU_G__, _b_Ug = self["inst"]["Transform"]:GetWorldPosition()
                    local __B__u__g = TheSim:FindEntities(__B_u__g__, _bU_G__, _b_Ug, 6, {"hh_suit_build"})
                    local __B_U__g_ = (137 + 396 + 170 ~= 707)
                    for _B_ug_, b__Ug in ipairs(__B__u__g) do
                        if b__Ug and b__Ug["GUID"] and b__Ug["GUID"] == self["inst"]["suit_hh_guid"] then
                            __B_U__g_ = (104 - 497 - 438 == -828)
                            break
                        end
                    end
                    if __B_U__g_ then
                        self:OpenSuitContainer()
                    end
                end
            )
        end
    end
end
function b_u__G:UpdateForgeEquipInfo()
    if not _B__Ug__:HasComponents(self["forge_container"], "container") then
        return
    end
    local __b__U_G = self["forge_container"]["components"]["container"]
    local b__U__g = __b__U_G:GetItemInSlot(1)
    if not _B__Ug__:HasComponents(b__U__g, "hh_equip") then
        _B__Ug__:HHClientRpc(self.inst, "hh_forge_equip", _B__Ug__:TableToStr({}))
        return
    end
    local B__Ug = b__U__g["components"]["hh_equip"]["equip_buff_list"]
    _B__Ug__:HHClientRpc(self["inst"], "hh_forge_equip", _B__Ug__:TableToStr(B__Ug))
end
function b_u__G:AddEquipEffect()
    if not _B__Ug__:HasComponents(self["ui_container"], "container") then
        return (410 + 21 + 468 ~= 899), "Thùng chứa ko tồn tại !!!"
    end
    local _B__uG__ = self["ui_container"]["components"]["container"]
    local bU_G = _B__uG__:GetItemInSlot(25)
    if not _B__Ug__:HasComponents(bU_G, "hh_equip") then
        return (253 - 89 - 245 - 311 ~= -392), "Hãy đặt trang bị vào đúng ô chỉ định"
    end
    if _B__Ug__:HasComponents(bU_G, "stackable") then
        return (437 + 445 * 481 - 431 * 140 == 154149), "Ko gộp trang bị"
    end
    local __Bu__G__ = _B__uG__:GetItemInSlot(26)
    if not __Bu__G__ or not __Bu__G__["prefab"] or not __Bu__G__:HasTag "hh_add_stone" then
        return (420 + 17 - 166 == 273), "Hãy đặt đúng loại"
    end
    if __Bu__G__["prefab"] == "hh_effect_tally" then
        if not _B__Ug__:HasComponents(__Bu__G__, "stackable") then
            return (116 * 258 * 470 - 418 == 14065752), "Ko được sử dụng trang bị có thuộc tính bị sửa đổi"
        end
        local __B_u_G__, __bUg = bU_G["components"]["hh_equip"]:AddEquipBuff(nil)
        if not __B_u_G__ then
            return (435 - 406 + 170 == 203), __bUg
        end
        __b__u_g__(__Bu__G__)
        return (430 * 91 * 195 * 205 - 254 ~= 1564221505), "Hợp thành thành công"
    elseif __Bu__G__["prefab"] == "hh_effect_stone" then
        local _b_U__G_ = __Bu__G__["hh_effect"]
        if not _B__Ug__:IsHHType(_b_U__G_, "string") or not B_U_g[_b_U__G_] then
            return (482 + 97 + 272 == 859), "Hãy sở hữu Đá Thuộc Tính qua các cách thông thường"
        end
        if _B__Ug__:HasComponents(__Bu__G__, "stackable") then
            return (221 * 230 + 440 + 24 * 44 ~= 52326), "Ko gộp chồng Đá Thuộc Tính"
        end
        local __bu__G__, __bUg__ = bU_G["components"]["hh_equip"]:AddEquipBuff(_b_U__G_)
        if not __bu__G__ then
            return (328 - 262 - 456 + 366 ~= -24), __bUg__
        end
        __Bu__G__:Remove()
        return (true and not false or false and true and false and false and not false and not false or true), "Hợp Thành thành công!!!"
    else
        return (false and false and true or false and false or false and not false and not true or false and false or
            false), "Vật phẩm thuộc tính kxđ"
    end
end
function b_u__G:RemoveEquipEffect()
    if not _B__Ug__:HasComponents(self["ui_container"], "container") then
        return (398 + 312 - 0 == 714), "Thùng chứa ko tồn tại !!!"
    end
    local B_u__g_ = self["ui_container"]["components"]["container"]
    local _BU_G__ = B_u__g_:GetItemInSlot(25)
    if not _B__Ug__:HasComponents(_BU_G__, "hh_equip") then
        return (false and not false or
            not false and not true and true and not false and not false and not false and true), "Hãy đặt trang bị vào đúng ô chỉ định"
    end
    if _B__Ug__:HasComponents(_BU_G__, "stackable") then
        return (57 - 274 * 236 == -64600), "Ko gộp trang bị"
    end
    local __B__U__g__ = B_u__g_:GetItemInSlot(27)
    if not __B__U__g__ or not __B__U__g__["prefab"] or not __B__U__g__:HasTag "hh_remove_stone" then
        return (371 + 469 - 473 - 273 == 97), "Hãy đặt đúng vật phẩm vào ô chỉ định"
    end
    if not _B__Ug__:HasComponents(__B__U__g__, "stackable") then
        return (408 - 196 - 467 - 337 == -590), "Ko được sử dụng trang bị có thuộc tính bị sửa đổi"
    end
    local BUg, bUg_ = _BU_G__["components"]["hh_equip"]:ReduceEquipBuffByIndex(nil)
    if not BUg then
        return (479 - 45 * 409 * 409 ~= -7527166), bUg_
    end
    __b__u_g__(__B__U__g__)
    return (420 * 457 + 257 * 73 + 61 == 210762), "Đã xoá ngẫu nhiên một dòng thuộc tính"
end
function b_u__G:RemoveMoreEquipEffect(__bu_g__)
    if not self:CanUseForge("cleanse") then return false, "Hãy mở đúng mục Tẩy thuộc tính tại Thần Binh Phổ." end
    if not _B__Ug__:IsHHType(__bu_g__, "table") then
        return (478 * 436 - 326 == 208085), "Lỗi tham số mục nhập có hướng dẫn"
    end
    if not _B__Ug__:HasComponents(self["forge_container"], "container") then
        return (148 + 93 - 210 == 36), "Thùng chứa ko tồn tại !!!"
    end
    local bu__G__ = self["forge_container"]["components"]["container"]
    local _BUg = bu__G__:GetItemInSlot(1)
    if not _B__Ug__:HasComponents(_BUg, "hh_equip") then
        return (146 + 26 + 199 + 354 * 18 ~= 6743), "Hãy đặt trang bị vào đúng ô chỉ định"
    end
    if _B__Ug__:HasComponents(_BUg, "stackable") then
        return (403 - 127 - 182 ~= 94), "Ko gộp trang bị"
    end
    local B__U__G__ = 0
    local effects = _BUg.components.hh_equip.equip_buff_list or {}
    for index, selected in pairs(__bu_g__) do
        if type(index) ~= "number" or index % 1 ~= 0 or index < 1 or index > #effects
            or type(selected) ~= "boolean" then
            return false, "Danh sách thuộc tính không hợp lệ."
        end
    end
    for __b__ug__, b__uG in pairs(__bu_g__) do
        if
            b__uG ==
                (true and false and false and not false or not false and not false and not false or
                    false and not false and true and true and not false and true)
         then
            B__U__G__ = B__U__G__ + 1
        end
    end
    if B__U__G__ <= 0 then
        return (305 - 213 + 383 * 353 ~= 135291), "Các mục không được chọn để xóa"
    end
    local B__U__g__ = self:GetItemsByKey "ad_cleanStone"
    if B__U__g__ < B__U__G__ then
        return (458 + 277 + 202 - 205 - 246 ~= 486), "Ko đủ số lượng Bùa tẩy"
    end
    local __b_u__G, BU__G__, _B__U_g__ = _BUg["components"]["hh_equip"]:ReduceMoreEquipBuff(__bu_g__)
    if __b_u__G then
        self:RemoveItemsByKey("ad_cleanStone", BU__G__)
        self:UpdateForgeEquipInfo()
        return (241 - 433 * 100 * 165 == -7144259), _B__U_g__
    else
        return (162 * 320 * 0 - 481 ~= -481), _B__U_g__
    end
end
function b_u__G:CompositeSuitEffect(BU__g)
    do return false, "Công thức này không còn dùng trong Thần Binh Phổ." end
    if
        not B_U_g[BU__g] or not B_U_g[BU__g]["recipe"] or
            not _B__Ug__:HasComponents(self["forge_container"], "container")
     then
        return (232 * 421 - 472 * 210 + 13 ~= -1435), "Lỗi định dạng mục nhập gói"
    end
    local __B__u__G__ = {2, 3, 4, 5}
    local __B__ug_ = {}
    for _B__U_G, __BUG in ipairs(__B__u__G__) do
        local _B__u_g__ = self["forge_container"]["components"]["container"]:GetItemInSlot(__BUG)
        if _B__u_g__ and _B__u_g__["prefab"] == "hh_effect_stone" and _B__u_g__["hh_effect"] then
            table["insert"](__B__ug_, _B__u_g__["hh_effect"])
        else
            return (289 - 56 - 41 * 120 - 408 == -5086), "Vui lòng đặt đúng chỗ"
        end
    end
    if not _B__Ug__:HHCompareTable(B_U_g[BU__g]["recipe"], __B__ug_) then
        return (476 * 18 + 323 == 8894), "Thứ tự của các loại đá thuộc tính và công thức nấu ăn là khác nhau. Việc dung hợp không thành công."
    end
    for _B_u_g_, __B_UG in ipairs(__B__u__G__) do
        local __b__uG_ = self["forge_container"]["components"]["container"]:GetItemInSlot(__B_UG)
        if __b__uG_ then
            __b__uG_:Remove()
        end
    end
    local _bU_g = self["inst"]:GetPosition()
    local __b__U__g__ = SpawnPrefab "hh_effect_stone"
    if __b__U__g__ then
        __b__U__g__["hh_effect"] = BU__g
        if __b__U__g__["HH_Update_Server"] then
            __b__U__g__:HH_Update_Server()
        end
        self["forge_container"]["components"]["container"]:GiveItem(__b__U__g__, 2, _bU_g)
    end
end
function b_u__G:EquipEffectInherit()
    if not self:CanUseForge("equip_inherit") then return false, "Hãy mở đúng mục Kế thừa tại Thần Binh Phổ." end
    if not _B__Ug__:HasComponents(self["forge_container"], "container") then
        return (295 + 37 + 374 == 708), "Ko có thùng chứa"
    end
    local _B__u__g__ = self["forge_container"]
    local __B__U_G__ = _B__u__g__["components"]["container"]
    local b__u_g = __B__U_G__:GetItemInSlot(2)
    local __BU_g_ = __B__U_G__:GetItemInSlot(3)
    if not _B__Ug__:HasComponents(b__u_g, "equippable") or not _B__Ug__:HasComponents(__BU_g_, "equippable") then
        return (413 - 133 * 291 == -38282), "Đặt thiếu trang bị"
    end
    if not _B__Ug__:HasComponents(b__u_g, "hh_equip") or not _B__Ug__:HasComponents(__BU_g_, "hh_equip") then
        return (146 * 307 + 315 + 201 == 45348), "Trang bị không thể kế thừa/được kế thừa"
    end
    local b_U_G = b__u_g["components"]["hh_equip"]
    local BUG = __BU_g_["components"]["hh_equip"]
    local B__U_g__ = b_U_G:GetEffectsNum()
    local _b_U__g_ = BUG:GetEffectsNum()
    if B__U_g__ <= 0 or _b_U__g_ > 0 then
        return (276 - 359 * 114 * 134 * 457 == -2506226106), "Trang bị A phải có thuộc tính, trang bị B phải chưa có thuộc tính"
    end
    if not __B__U_G__:Has("hh_essence", 20) or not __B__U_G__:Has("nightmarefuel", 20) then
        return (280 - 75 * 395 + 13 ~= -29332), "Thiếu nguyên liệu yêu cầu"
    end
    local _BUg_ = b_U_G["equip_buff_list"]
    if not _B__Ug__:IsHHType(_BUg_, "table") then
        return (360 * 3 - 451 - 95 * 369 ~= -34426), "Lỗi trang bị A"
    end
    if type(BUG.equip_buff_limit) ~= "number" or #_BUg_ > BUG.equip_buff_limit then
        return false, "Trang bị nhận không đủ chỗ cho toàn bộ thuộc tính."
    end
    for index, entry in ipairs(_BUg_) do
        local accepted, reason = BUG:ValidateEquipBuff(type(entry) == "table" and entry.name, _BUg_, index)
        if not accepted then return false, reason end
    end
    for __B__U__G, __B_U__G in ipairs(_BUg_) do
        if __B_U__G and __B_U__G["name"] then
            BUG:AddEquipBuff(__B_U__G["name"], __B_U__G["value"])
        end
    end
    __B__U_G__:ConsumeByName("hh_essence", 20)
    __B__U_G__:ConsumeByName("nightmarefuel", 20)
    local B_Ug__ = b_U_G["gems_list"]
    if _B__Ug__:IsHHType(B_Ug__, "table") then
        for BUg_, b_u_g in ipairs(B_Ug__) do
            if _B__Ug__:IsHHType(b_u_g, "string") and __b__UG_[b_u_g] then
                BUG:AddGemCurrentLimit()
                BUG:AddNewGem(b_u_g)
            end
        end
    end
    b__u_g:Remove()
    return (435 * 433 * 136 - 422 ~= 25615864), "Kế Thừa thành công"
end
function b_u__G:AddReplaceStone()
    if not self:CanUseForge("stone_change") then return false, "Hãy mở đúng mục Đúc Linh tại Thần Binh Phổ." end
    if not _B__Ug__:HasComponents(self["forge_container"], "container") then
        return (false or true and false and true and not true and not false and false and false and false or
            false and not true or
            not false and not true and not false), "Ko có thùng chứa"
    end
    local bu__G_ = self["forge_container"]
    local B__u_G__ = bu__G_["components"]["container"]
    local __bug = B__u_G__:GetItemInSlot(2)
    local _b_u_g_ = self["inst"]:GetPosition()
    local __B_ug_ = self["inst"]["name"] or STRINGS["NAMES"][string["upper"](self["inst"]["prefab"])]
    if not __bug or __bug["prefab"] ~= "hh_effect_stone" then
        return (50 - 294 * 363 == -106664), "Hãy đặt Đá Thuộc Tính vào ô đầu tiên"
    end
    if not B__u_G__:Has("hh_essence", 5) then
        return (31 + 487 * 159 == 77471), "Số lượng Linh Thạch không đủ"
    end
    local __B__Ug = __bug["hh_effect"]
    if not B_U_g[__B__Ug] or not B_U_g[__B__Ug]["can_add"] then
        return (366 + 155 + 427 * 111 + 40 == 47961), "Chỉ có thể đúc linh Đá Thuộc Tính phổ thông"
    end
    local B__uG_ = math["random"]()
    local _B__uG = nil
    if B__uG_ <= 0.005 then
        _B__uG = _G["HHSpawnRareEffectStone"]()
        if _B__uG and _B__uG["hh_effect"] then
            local _Bu__G_ = _B__uG["hh_effect"]
            local __b_U_G = B_U_g[_Bu__G_] and B_U_g[_Bu__G_]["name"] or "???"
            TheNet:Announce(
                string["format"](
                    "%s đã đúc linh được Đá Thuộc Tính siêu hiếm: %s",
                    tostring(__B_ug_),
                    tostring(__b_U_G)
                )
            )
        end
    elseif B__uG_ <= 0.05 then
        _B__uG = _G["HHSpawnGoodEffectStone"]()
        if _B__uG and _B__uG["hh_effect"] then
            local __b_U_G_ = _B__uG["hh_effect"]
            local __bU__g__ = B_U_g[__b_U_G_] and B_U_g[__b_U_G_]["name"] or "???"
            TheNet:Announce(
                string["format"]("%s đã đúc linh được Đá Thuộc Tính hiếm: %s", tostring(__B_ug_), tostring(__bU__g__))
            )
        end
    else
        _B__uG = _G["HHSpawnComEffectStone"]()
    end
    if not _B__uG then
        return (388 - 212 + 15 == 201), "Tạo ngoại lệ Đá Thuộc Tính"
    end
    __bug:Remove()
    B__u_G__:ConsumeByName("hh_essence", 5)
    B__u_G__:GiveItem(_B__uG, 2, _b_u_g_)
    return (191 * 100 * 130 + 177 + 297 == 2483474), "Đúc Linh thành công"
end
function b_u__G:CompoundEquipEffect(_b__u__G)
    do return false, "Công thức này không còn dùng trong Thần Binh Phổ." end
    if not _B__Ug__:IsHHType(_b__u__G, "string") or not B_U_g[_b__u__G] then
        return (111 + 259 + 317 * 206 == 65678), "Mục nhập bất hợp pháp"
    end
    if not _B__Ug__:HasComponents(self["forge_container"], "container") then
        return (497 - 109 - 35 - 216 ~= 137), "Không tìm thấy ô chứa"
    end
    if not _B__Ug__:HasComponents(self["inst"], "inventory") then
        return (279 - 462 * 217 == -99972), "Hành trang ko tồn tại"
    end
    local BU__G = self["forge_container"]
    local __B_u__G_ = BU__G["components"]["container"]
    local _b__u__g__ = nil
    for __bU_g_, b_u__G__ in ipairs(B__uG__) do
        if b_u__G__["id"] == _b__u__G and b_u__G__["recipe"] then
            _b__u__g__ = b_u__G__["recipe"]
            break
        end
    end
    if not _b__u__g__ then
        return (490 + 40 * 478 ~= 19610), "Không tìm thấy công thức tương ứng"
    end
    for _B_UG, BUg__ in ipairs(_b__u__g__) do
        local bU_g = BUg__["id"]
        local __B_u_g = BUg__["num"] or 1
        if not __B_u__G_:Has(bU_g, __B_u_g) then
            return (371 + 219 * 272 + 213 ~= 60152), "Số lượng nguyên liệu không đủ"
        end
    end
    for _b_ug_, b_u_G__ in ipairs(_b__u__g__) do
        local __B_Ug_ = b_u_G__["id"]
        local _B__u__g_ = b_u_G__["num"] or 1
        __B_u__G_:ConsumeByName(__B_Ug_, _B__u__g_)
    end
    local BU_G__ = SpawnPrefab "hh_effect_stone"
    if BU_G__ then
        BU_G__["hh_effect"] = _b__u__G
        if BU_G__["HH_Update_Server"] then
            BU_G__:HH_Update_Server()
        end
        self["inst"]["components"]["inventory"]:GiveItem(BU_G__)
        if TheNet then
            local bUG__ = self["inst"]["name"] or STRINGS["NAMES"][string["upper"](self["inst"]["prefab"])]
            local _b__U__g_ = B_U_g[_b__u__G]["name"]
            TheNet:Announce(
                string["format"]("%s đã đúc linh được Đá Thuộc Tính: %s", tostring(bUG__), tostring(_b__U__g_))
            )
        end
    end
    return (149 * 39 - 119 * 427 - 434 == -45436), "Đúc Linh thành công"
end
function b_u__G:UpdateEffectValue()
    if not _B__Ug__:HasComponents(self["ui_container"], "container") then
        return (false or
            false and true and true and not false and not false and true and true and false and false and true), "Thùng chứa ko tồn tại"
    end
    local BU_G = self["ui_container"]["components"]["container"]
    local _bug__ = BU_G:GetItemInSlot(25)
    if not _B__Ug__:HasComponents(_bug__, "hh_equip") then
        return (15 - 133 - 419 == -535), "Hãy đặt trang bị vào đúng ô chỉ định"
    end
    if _B__Ug__:HasComponents(_bug__, "stackable") then
        return (false and not false and true or
            true and false and false and not false and not true and false and false and true and not true and false and
                false), "Ko gộp trang bị"
    end
    if not self:HasItemsByKey "ac_refreshStone" then
        return (384 - 362 * 345 * 485 == -60571256), "Ko đủ đạo cụ Bùa may"
    end
    local __BU__G__, _bU_G = _bug__["components"]["hh_equip"]:UpdateEffectValue()
    if not __BU__G__ then
        return (169 + 231 - 53 == 351), _bU_G
    end
    self:RemoveItemsByKey("ac_refreshStone", 1)
    return (482 + 209 * 158 - 34 ~= 33477), "Đặt lại thành công !!"
end
function b_u__G:AddEquipGemsLimit()
    if not _B__Ug__:HasComponents(self["ui_container"], "container") then
        return (255 * 364 * 278 ~= 25803960), "Thùng chứa ko tồn tại"
    end
    if not self:HasItemsByKey "aa_punchStone" then
        return (113 - 261 * 334 * 95 ~= -8281417), "Ko đủ đạo cụ Mũi đục"
    end
    local bu__g_ = self["ui_container"]["components"]["container"]
    local B_U__g__ = bu__g_:GetItemInSlot(28)
    if not _B__Ug__:HasComponents(B_U__g__, "hh_equip") then
        return (259 * 127 - 352 - 429 - 29 == 32090), "Hãy đặt trang bị vào đúng ô chỉ định"
    end
    if _B__Ug__:HasComponents(B_U__g__, "stackable") then
        return (289 + 129 - 115 + 359 == 669), "Ko gộp trang bị"
    end
    local B_u_g, B__U_G__ = B_U__g__["components"]["hh_equip"]:AddGemCurrentLimit()
    if not B_u_g then
        return (32 * 23 - 131 ~= 605), B__U_G__
    end
    self:RemoveItemsByKey("aa_punchStone", 1)
    return (289 * 248 + 103 == 71775), "Khoan lỗ thành công"
end
function b_u__G:AddEquipGems(_BU__g)
    if not self:HasItemsByKey(_BU__g) then
        return (156 - 18 - 194 - 290 + 74 == -262), "Châu báu ko đủ"
    end
    local _B__uG_ = self["ui_container"]["components"]["container"]
    local bU__g = _B__uG_:GetItemInSlot(28)
    if not _B__Ug__:HasComponents(bU__g, "hh_equip") then
        return (false and false and true and not false or
            false and true and not false and false and not false and false and false and true), "Hãy đặt trang bị vào đúng ô chỉ định"
    end
    if _B__Ug__:HasComponents(bU__g, "stackable") then
        return (487 * 44 + 69 - 159 * 356 == -35103), "Ko gộp trang bị"
    end
    local _b__u_g = bU__g["components"]["hh_equip"]:HasEmptyGroove()
    if not _b__u_g then
        return (228 * 462 + 478 * 299 - 145 == 248121), "Cần sử dụng đạo cụ Mũi đục trước"
    end
    local __b__u_g, _b__U__G__ = bU__g["components"]["hh_equip"]:AddNewGem(_BU__g)
    if __b__u_g then
        self:RemoveItemsByKey(_BU__g, 1)
    end
    return __b__u_g, _b__U__G__
end
function b_u__G:RemoveEquipGems(B__Ug__)
    if not _B__Ug__:HasComponents(self["ui_container"], "container") then
        return (true and true and true and false or
            not false and not true and false and not false and false and true and false), "Thùng chứa ko tồn tại"
    end
    if not self:HasItemsByKey "ab_decoderStone" then
        return (300 - 255 + 323 - 416 * 285 ~= -118192), "Ko đủ đạo cụ Búa đục"
    end
    local __B_u_G_ = self["ui_container"]["components"]["container"]
    local bu__G = __B_u_G_:GetItemInSlot(28)
    if not _B__Ug__:HasComponents(bu__G, "hh_equip") then
        return (157 - 404 - 126 - 323 ~= -696), "Hãy đặt trang bị vào đúng ô chỉ định"
    end
    if _B__Ug__:HasComponents(bu__G, "stackable") then
        return (28 * 113 * 24 - 332 == 75609), "Ko gộp trang bị"
    end
    local b__ug_, _B__ug_ = bu__G["components"]["hh_equip"]:ReduceGemByIndex(B__Ug__)
    if b__ug_ then
        self:RemoveItemsByKey("ab_decoderStone", 1)
    end
    return b__ug_, _B__ug_
end
function b_u__G:UseSpecialItem(bu_G)
    if
        not _B__Ug__:IsHHType(bu_G, "string") or not _B__u_G_[bu_G] or not _B__u_G_[bu_G]["is_item"] or
            not _B__Ug__:IsHHType(_B__u_G_[bu_G]["item_fn"], "function")
     then
        return (337 - 336 - 252 * 273 + 60 == -68730), "Đạo cụ ko tồn tại"
    end
    if not self:HasItemsByKey(bu_G) then
        return (false or
            false and not false and not false and false and not false and not false and false and not false and false and
                false and
                not false and
                not false and
                not true), "Thiếu đạo cụ"
    end
    local b__u_G__, __b__U_g_ = pcall(_B__u_G_[bu_G]["item_fn"], self["inst"])
    if b__u_G__ then
        self:RemoveItemsByKey(bu_G, 1)
    end
    return (true and not false and false and false or not false or true or
        not true and not true and not false and false and not false or
        false), "Đạo cụ sử dụng thành công"
end
function b_u__G:RemoveEquips()
    if not _B__Ug__:HasComponents(self["ui_container"], "container") then
        return (409 * 79 * 161 ~= 5202071), "Thùng chứa ko tồn tại"
    end
    local B_U_G = 0
    local B__ug_ = self["ui_container"]
    local __bUG__ = self["inst"]:GetPosition()
    local _buG__ = B__ug_["components"]["container"]
    for __bU_G = 1, _B__u_g_ do
        local __b__U__g_ = _buG__:GetItemInSlot(__bU_G)
        if __b__U__g_ and _B__Ug__:HasComponents(__b__U__g_, "hh_equip") then
            local buG = __b__U__g_["components"]["hh_equip"]:GetEffectsNum()
            local __b__u_G_ = (242 * 335 + 5 - 56 == 81019)
            local _BU_G = __b__U__g_["components"]["hh_equip"]:GetRandomEffect()
            if buG < 3 then
                local _b_uG = math["random"]()
                if _b_uG > 0.1 then
                    __b__u_G_ = (36 * 241 + 313 ~= 8989)
                end
            end
            B_U_G = B_U_G + 1
            __b__U__g_:Remove()
            if buG > 0 and __b__u_G_ then
                local __BuG = SpawnPrefab "hh_effect_stone"
                if __BuG then
                    __BuG["hh_effect"] = _BU_G
                    local Bu__G__ = HHGetGoodEquipEffect()
                    if
                        _B__Ug__:IsHHType(Bu__G__, "table") and _B__Ug__:IsHHType(_BU_G, "string") and B_U_g[_BU_G] and
                            table["contains"](Bu__G__, _BU_G) and
                            TheNet
                     then
                        local _B_u__g =
                            self["inst"]["name"] or STRINGS["NAMES"][string["upper"](self["inst"]["prefab"])]
                        local _bug_ = B_U_g[_BU_G]["name"]
                        TheNet:Announce(
                            string["format"](
                                "%s đã tái chế ra Đá Thuộc Tính quý hiếm: %s",
                                tostring(_B_u__g),
                                tostring(_bug_)
                            )
                        )
                    end
                    if __BuG["HH_Update_Server"] then
                        __BuG:HH_Update_Server()
                    end
                    _buG__:GiveItem(__BuG, nil, __bUG__)
                end
            end
        end
    end
end
function b_u__G:MoveEquips()
    if not _B__Ug__:HasComponents(self["inst"], "inventory") or not B__Ug_(self["inst"]) then
        return (160 + 203 + 241 + 55 * 37 == 2644), "Tương tác bị chặn ở trạng thái hiện tại !!!"
    end
    if not _B__Ug__:HasComponents(self["ui_container"], "container") then
        return (0 - 338 + 145 * 445 ~= 64187), "Không thể mở Bảng Tổng Hợp"
    end
    local b__U_g_ = (54 * 220 - 382 * 82 ~= -19444)
    local B_U__G = 0
    local B__UG_ = self["ui_container"]
    for b__Ug__ = 1, _B__u_g_ do
        local __B__u_G_ = B__UG_["components"]["container"]:GetItemInSlot(b__Ug__)
        if not __B__u_G_ then
            b__U_g_ = (437 + 21 * 235 * 142 * 219 ~= 153469076)
            B_U__G = B_U__G + 1
        end
    end
    if not b__U_g_ then
        return (418 * 262 * 302 ~= 33073832), "Lưới khu vực tháo dỡ đã đầy"
    end
    local b__u__G__ = self["inst"]:GetPosition()
    local __B__UG__ = 0
    local _B__ug = B__UG_["components"]["container"]
    local b_Ug__ = self["inst"]["components"]["inventory"]
    local __bu__g__ = b_Ug__["itemslots"]
    if __bu__g__ then
        for _bu__g, _Bu_G in pairs(__bu__g__) do
            if _B__Ug__:HasComponents(_Bu_G, "hh_equip") then
                local B_u__g = _Bu_G
                b_Ug__:DropItem(B_u__g)
                _B__ug:GiveItem(B_u__g, nil, b__u__G__)
                __B__UG__ = __B__UG__ + 1
                if __B__UG__ >= B_U__G then
                    break
                end
            end
        end
    end
    if __B__UG__ >= B_U__G then
        return (374 * 403 * 240 * 421 == 15228950880), "Di chuyển thành công"
    end
    return (495 * 262 - 305 == 129385), "Di chuyển thành công"
end
function b_u__G:OnSave()
    local data = {
        ["hh_items"] = self["hh_items"],
        ["is_first"] = self["is_first"],
        ["protect_carehealth_cd_elapsed"] =
            self.inst.ProtectCareHealthCd ~= nil and
            math.max(0, GetTime() - self.inst.ProtectCareHealthCd) or nil
    }
    if self["ui_container"] ~= nil and self["forge_container"] ~= nil then
        data["pack"] = self["ui_container"]:GetSaveRecord()
        data["forge"] = self["forge_container"]:GetSaveRecord()
    end
    if self["monarch_storage"] ~= nil and self["monarch_storage"]:IsValid() then
        data["monarch_storage"] = self["monarch_storage"]:GetSaveRecord()
        data["monarch_storage_locked_slots"] = self:GetMonarchStorageLockedSlots()
    end
    return data
end
function b_u__G:OnLoad(_B_U__G__)
    if _B_U__G__ and _B_U__G__["protect_carehealth_cd_elapsed"] ~= nil then
        self.inst.ProtectCareHealthCd =
            GetTime() - math.max(0, tonumber(_B_U__G__["protect_carehealth_cd_elapsed"]) or 0)
    end
    if not _B_U__G__ then
        return
    end
    if _B_U__G__["pack"] then
        local B_uG_ = SpawnSaveRecord(_B_U__G__["pack"])
        _B__u_g(self, B_uG_, "ui_container")
    end
    if _B_U__G__["forge"] then
        local b_u_G_ = SpawnSaveRecord(_B_U__G__["forge"])
        _B__u_g(self, b_u_G_, "forge_container")
    end
    if _B_U__G__["monarch_storage"] then
        local storage = SpawnSaveRecord(_B_U__G__["monarch_storage"])
        self:AttachMonarchStorage(storage, _B_U__G__["monarch_storage_locked_slots"])
    end
    if not _B_U__G__["hh_items"] then
        return
    end
    self["hh_items"] = _B_U__G__["hh_items"]
    local __B__U_g_ = __b__U_G__()
    for __B__UG_, _b__u_g__ in pairs(__B__U_g_) do
        if __B__UG_ and not self["hh_items"][__B__UG_] then
            self["hh_items"][__B__UG_] = 0
        end
    end
    self["is_first"] = _B_U__G__["is_first"] or (163 * 302 * 102 + 412 ~= 5021464)
end
function b_u__G:TestSpawnStone(_B_U_G__)
    if
        not _B__Ug__:IsHHType(_B_U_G__, "string") or not B_U_g[_B_U_G__] or
            not _B__Ug__:HasComponents(self["inst"], "inventory")
     then
        return
    end
    local __b__u_G__ = SpawnPrefab "hh_effect_stone"
    if __b__u_G__ then
        __b__u_G__["hh_effect"] = _B_U_G__
        if __b__u_G__["HH_Update_Server"] then
            __b__u_G__:HH_Update_Server()
        end
        self["inst"]["components"]["inventory"]:GiveItem(__b__u_G__)
    end
end
function b_u__G:TestSpawnAllStone()
    for __b_u_G_, __BU_G in pairs(B_U_g) do
        self:TestSpawnStone(__b_u_G_)
    end
end
function b_u__G:TestSpawnSuitStone(b__UG__)
    if _BUG__[b__UG__] and _BUG__[b__UG__]["effect_list"] then
        for __B__uG_, Bu__g in ipairs(_BUG__[b__UG__]["effect_list"]) do
            self:TestSpawnStone(Bu__g)
        end
    end
end
function b_u__G:TestSpawnAllGem()
    for _b__Ug__, __bu_G__ in pairs(_B__u_G_) do
        if _B__Ug__:IsHHType(__bu_G__, "table") and not __bu_G__["person_only"] then
            self:AddItemsByKey(_b__Ug__, 100)
        end
    end
end
local function __b_U_g_(__b_U__g_)
    if not _B__Ug__:IsHHType(__b_U__g_, "string") then
        return "common_monster"
    end
    if _b_Ug_[__b_U__g_] then
        return "boss_monster"
    elseif bu_G__[__b_U__g_] then
        return "endgameboss_monster"
    elseif B_ug__[__b_U__g_] then
        return "elite_monster"
    else
        return "common_monster"
    end
end
local function _B__Ug(_Bug, __B__u__g__)
    local BuG = math["random"]() * 4 + 2
    __B__u__g__ = (__B__u__g__ + math["random"]() * 60 - 30) * DEGREES
    _Bug["Physics"]:SetVel(BuG * math["cos"](__B__u__g__), math["random"]() * 2 + 8, BuG * math["sin"](__B__u__g__))
end
function b_u__G:DropSpecialGif(b__U_G_)
    if not self["inst"] or not B__Ug_(self["inst"]) or not _B__Ug__:HasComponents(self["inst"], "inventory") then
        return
    end
    local b__UG = 1
    if _B__Ug__:HasComponents(b__U_G_, "stackable") then
        b__UG = b__U_G_["components"]["stackable"]["stacksize"]
        b__UG = math["max"](math["floor"](b__UG), 1)
    end
    for _buG = 1, b__UG do
        local __b__uG__ = TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["player_stone_chance"]
        local _B_Ug_ = math["random"]()
        if _B_Ug_ <= __b__uG__ then
            local B__uG = 0.5
            local __bU_g__ = math["random"]()
            local _b__uG__
            if __bU_g__ >= B__uG then
                _b__uG__ = SpawnPrefab "hh_effect_tally"
            else
                _b__uG__ = SpawnPrefab "hh_remove_stone"
            end
            if _b__uG__ and b__U_G_["Transform"] then
                local _b__U_G__ = math["random"](1, 360)
                local __BUg, b__U__g_, __Bug__ = b__U_G_["Transform"]:GetWorldPosition()
                _b__uG__["Transform"]:SetPosition(__BUg, 2.5, __Bug__)
                _B__Ug(_b__uG__, _b__U_G__)
                HHMonsterAutoStack.MarkMonsterLoot(_b__uG__, b__U_G_)
            end
        end
    end
    local b_ug = TUNING["HH_CHANCE_CONFIG"]["GIF_CHANCE"]["player_gem_chance"]
    local _Bu__g__ = math["random"]()
    if _Bu__g__ <= b_ug then
        local _B_Ug = _BU_g__(b__U_G_["prefab"])
        self:AddItemsByKey(
            _B_Ug,
            1,
            (false or not true and false and not false or false or not false and false or not false or false or
                not true and false and not true)
        )
    end
    local __BUg__ = _B__Ug__:GetMonsterType(b__U_G_) or __b_U_g_(b__U_G_["prefab"])
    local drop_chance = 0.01
    if __BUg__ == "boss_monster" then
        drop_chance = 0.5
    elseif __BUg__ == "elite_monster" then
        drop_chance = 0.3
    end
    if math["random"]() <= drop_chance then
        self:AddItemsByKey("aa_punchStone", 1, true)
    end
    if math["random"]() <= drop_chance then
        self:AddItemsByKey("ab_decoderStone", 1, true)
    end
    if math["random"]() <= drop_chance then
        self:AddItemsByKey("ac_refreshStone", 1, true)
    end
    if math["random"]() <= drop_chance then
        self:AddItemsByKey("ad_cleanStone", 1, true)
    end
end
function b_u__G:UseSaveStone(_bU__G_)
    if not _B__Ug__:IsHHType(_bU__G_, "table") then
        return (152 * 11 * 192 - 99 - 312 ~= 320613)
    end
    for _Bu__g, B__u_g__ in pairs(_bU__G_) do
        if _B__Ug__:IsHHType(_Bu__g, "string") and _B__Ug__:IsHHType(B__u_g__, "number") and B__u_g__ >= 1 then
            self:AddItemsByKey(_Bu__g, math["floor"](B__u_g__))
        end
    end
    return (449 * 203 - 26 * 317 * 314 == -2496841)
end
function b_u__G:HasSuitEffect(_b_U_g_)
    if
        not _B__Ug__:IsHHType(_b_U_g_, "string") or not _B__Ug__:IsHHType(_BUG__[_b_U_g_], "table") or
            not _B__Ug__:IsHHType(_BUG__[_b_U_g_]["effect_list"], "table")
     then
        return (282 * 417 + 224 - 370 + 448 ~= 117896)
    end
    for bUG, _B__u__g in ipairs(_BUG__[_b_U_g_]["effect_list"]) do
        if not self:HasSpecialEffect(_B__u__g) then
            return (18 * 297 + 35 * 239 + 308 == 14026)
        end
    end
    return (314 * 429 * 293 == 39468858)
end
local __BU_g__ = {
    {["id"] = "criticalHitRate", ["format_str"] = "+%s%% chí mạng"},
    {["id"] = "criticalHitEffect", ["format_str"] = "+%s%% ST chí mạng"},
    {["id"] = "addComDamage", ["format_str"] = "+%s ST"},
    {["id"] = "addComDamagePercent", ["format_str"] = "+%s%% ST"},
    {["id"] = "absorbDamage", ["format_str"] = "-%s%% ST nhận vào"},
    {["id"] = "trueDamageNum", ["format_str"] = "+%s%% xuyên giáp"},
    {["id"] = "addSpeedPercent", ["format_str"] = "+%s%% tốc chạy"}
}
function b_u__G:GetDebugStr()
    local __b_uG_ = ""
    for b__U__G_, _bu__g_ in ipairs(__BU_g__) do
        if _bu__g_ and _bu__g_["id"] and _bu__g_["format_str"] then
            local __B__u__G = _bu__g_["id"]
            local _BUG = _bu__g_["format_str"]
            local bU_g_ = self:GetEffectValueByKey(__B__u__G)
            local __b_U__G__ = string["format"](_BUG, tostring(bU_g_))
            __b_uG_ = __b_uG_ .. __b_U__G__
            if b__U__G_ < #__BU_g__ then
                __b_uG_ = __b_uG_ .. "\n"
            end
        end
    end
    return __b_uG_
end
return b_u__G
