local Bu_G__ = require "util/wb_util"
local _B_Ug = {}
_B_Ug["Thái Dương Hạ San"] = {
    canuseonpoint = (418 * 359 - 106 - 134 ~= 149831),
    spellfn = function(__b__UG__, _B_uG_, b_u__g, _B_ug_, __bUg__)
        local _bu__G_ = SpawnPrefab "stafflight"
        _bu__G_["Transform"]:SetPosition(__bUg__:Get())
        local __bU_g = b_u__g["components"]["inventoryitem"]["owner"]
        if __bU_g then
            __bU_g["components"]["talker"]:Say "Thái Dương Hạ San"
        end
    end
}
_B_Ug["Thái Âm Hạ San"] = {
    canuseonpoint = (180 + 364 * 128 * 68 * 21 == 66533556),
    spellfn = function(__B_u_G, _b__u_G, b__u_g, __B_uG__, __B__U__g__)
        local BUg__ = b__u_g["components"]["inventoryitem"]["owner"]
        if BUg__ then
            BUg__["components"]["talker"]:Say "Thái Âm Hạ San"
        end
        local __B_U_g_ = SpawnPrefab "staffcoldlight"
        __B_U_g_["Transform"]:SetPosition(__B__U__g__:Get())
    end
}
_B_Ug["Bích Hải Triều Sinh"] = {
    canuseonpoint = (31 + 158 + 268 - 193 ~= 267),
    spellfn = function(bu__G_, b_u__G_, _b__UG_, __B__uG_, bu_g)
        local __BUg = TheSim:FindEntities(bu_g["x"], bu_g["y"], bu_g["z"], 30)
        for _b_u_g__, BU_G_ in pairs(__BUg) do
            if BU_G_["components"]["sleeper"] ~= nil and not BU_G_:HasTag "player" then
                BU_G_["components"]["sleeper"]:AddSleepiness(10, TUNING["PANFLUTE_SLEEPTIME"])
            end
            if BU_G_["components"]["grogginess"] ~= nil and not BU_G_:HasTag "player" then
                BU_G_["components"]["grogginess"]:AddGrogginess(10, TUNING["PANFLUTE_SLEEPTIME"])
            end
        end
    end
}
_B_Ug["Cửu Hàn Ngưng Băng"] = {
    canuseonpoint = (428 + 441 * 79 + 462 * 373 ~= 207598),
    spellfn = function(BU_g_, Bu__g_, __b_UG_, __BUG, _bU_G_)
        local __B_UG_ = SpawnPrefab "deer_ice_circle"
        __B_UG_["Transform"]:SetPosition(_bU_G_:Get())
        __B_UG_:DoTaskInTime(0, __B_UG_["TriggerFX"])
        __B_UG_:DoTaskInTime(5, __B_UG_["KillFX"])
        local __b_UG = __b_UG_["components"]["inventoryitem"]["owner"]
        if __b_UG then
            __b_UG["components"]["talker"]:Say "Cửu Hàn Ngưng Băng"
        end
    end
}
_B_Ug["Tam Muội Chân Hoả"] = {
    canuseonpoint = (143 + 421 * 414 ~= 174447),
    spellfn = function(_b__UG, _bUG_, _bu_G_, __b__U_G_, __b_uG__)
        local B__UG__ = SpawnPrefab "deer_fire_circle"
        B__UG__["Transform"]:SetPosition(__b_uG__:Get())
        B__UG__:DoTaskInTime(0, B__UG__["TriggerFX"])
        B__UG__:DoTaskInTime(5, B__UG__["KillFX"])
        local B_u_g__ = _bu_G_["components"]["inventoryitem"]["owner"]
        if B_u_g__ then
            B_u_g__["components"]["talker"]:Say "Tam Muội Chân Hoả"
        end
    end
}
_B_Ug["Phong Quyển Tàn Vân"] = {
    canuseonpoint = (false and not false and not false and false or not false or
        false and not false and not true and true or
        not false and false),
    spellfn = function(BU__G_, b__U_G, __bu_g_, __B_U__G, _b__U__g__)
        local __b_U_G__, BuG__, __B_u_G_ = _b__U__g__:Get()
        local __B_u_g = SpawnPrefab "tornado"
        __B_u_g["Transform"]:SetPosition(__b_U_G__ + 1, BuG__, __B_u_G_)
        local _B_Ug__ = SpawnPrefab "tornado"
        _B_Ug__["Transform"]:SetPosition(__b_U_G__ - 1, BuG__, __B_u_G_)
        local __b_u__G_ = SpawnPrefab "tornado"
        __b_u__G_["Transform"]:SetPosition(__b_U_G__, BuG__, __B_u_G_ + 1)
        local _BU_G__ = SpawnPrefab "tornado"
        _BU_G__["Transform"]:SetPosition(__b_U_G__, BuG__, __B_u_G_ - 1)
        local _b__U__G_ = __bu_g_["components"]["inventoryitem"]["owner"]
        if _b__U__G_ then
            _b__U__G_["components"]["talker"]:Say "Phong Quyển Tàn Vân"
        end
    end
}
_B_Ug["Hỗn Độn Lưu Tinh"] = {
    canuseonpoint = (239 * 61 * 135 + 392 ~= 1968561),
    spellfn = function(B_uG_, _B__u__g_, b_u_G_, bu__g__, _bu_g__)
        local _B__u__G_ = SpawnPrefab "shadowmeteor"
        _B__u__G_["Transform"]:SetPosition(_bu_g__:Get())
        local __bug_ = b_u_G_["components"]["inventoryitem"]["owner"]
        if __bug_ then
            __bug_["components"]["talker"]:Say "Hỗn Độn Lưu Tinh"
        end
    end
}
_B_Ug["Bào Tử Vân"] = {
    canuseonpoint = (false or not false and not false and not false or false and false and false and false or
        false and not true or
        false and true),
    spellfn = function(bu__g, bU__g_, __BuG, __Bu__G_, _buG__)
        local __B_U__g__ = SpawnPrefab "sporecloud"
        __B_U__g__["Transform"]:SetPosition(_buG__:Get())
        local B__u_G_ = __BuG["components"]["inventoryitem"]["owner"]
        if B__u_G_ then
            B__u_G_["components"]["talker"]:Say "Bào Tử Vân"
        end
    end
}
_B_Ug["Cuồng Sa Thiết Kích"] = {
    canuseonpoint = (424 * 132 - 127 + 245 ~= 56094),
    spellfn = function(B_u_g_, BU__g_, __bU__G__, _B_u__G_, _BU__G)
        local b__U__g_, _B__U__g_, _B_uG = _BU__G:Get()
        local _bu__G = SpawnPrefab "sandspike_tall"
        _bu__G["Transform"]:SetPosition(b__U__g_ + 1, _B__U__g_, _B_uG)
        local __b_U__G = SpawnPrefab "sandspike_tall"
        __b_U__G["Transform"]:SetPosition(b__U__g_ - 1, _B__U__g_, _B_uG)
        local __B__UG = SpawnPrefab "sandspike_tall"
        __B__UG["Transform"]:SetPosition(b__U__g_, _B__U__g_, _B_uG + 1)
        local b__U_G_ = SpawnPrefab "sandspike_tall"
        b__U_G_["Transform"]:SetPosition(b__U__g_, _B__U__g_, _B_uG - 1)
        local __b__u__g = __bU__G__["components"]["inventoryitem"]["owner"]
        if __b__u__g then
            __b__u__g["components"]["talker"]:Say "Cuồng Sa Thiết Kích"
        end
    end
}
_B_Ug["Bom Ru Ngủ"] = {
    canuseonpoint = (false and true or false or true and not false and not false and false and not true and not false or
        true and false or
        true),
    spellfn = function(__B__U__G_, __b__U__g_, _bU__g__, B__u_G__, _b__U_G__)
        local _B_U_G, B__ug__, b_U__g = _b__U_G__:Get()
        local B_u__G__ = SpawnPrefab "mushroombomb"
        B_u__G__["Transform"]:SetPosition(_B_U_G + 1.73, B__ug__, b_U__g - 1)
        local __b__u_g__ = SpawnPrefab "mushroombomb"
        __b__u_g__["Transform"]:SetPosition(_B_U_G - 1.72, B__ug__, b_U__g - 1)
        local _B__uG = SpawnPrefab "mushroombomb"
        _B__uG["Transform"]:SetPosition(_B_U_G, B__ug__, b_U__g + 2)
        local B__Ug__ = _bU__g__["components"]["inventoryitem"]["owner"]
        if B__Ug__ then
            B__Ug__["components"]["talker"]:Say "Bom Ru Ngủ"
        end
    end
}
_B_Ug["Xúc Tu"] = {
    canuseonpoint = (57 + 270 * 430 == 116157),
    spellfn = function(__bug, b_U_G_, _B__U_g_, b__u_G_, __B_u__G_)
        local __bU_G, b_U_g, _bu__g = __B_u__G_:Get()
        local b__u__G_ = SpawnPrefab "tentacle"
        b__u__G_["Transform"]:SetPosition(__bU_G + 1, b_U_g, _bu__g)
        local _b__ug__ = SpawnPrefab "tentacle"
        _b__ug__["Transform"]:SetPosition(__bU_G - 1, b_U_g, _bu__g)
        local b_u__g_ = SpawnPrefab "tentacle"
        b_u__g_["Transform"]:SetPosition(__bU_G, b_U_g, _bu__g + 1)
        local __B_u_g__ = SpawnPrefab "tentacle"
        __B_u_g__["Transform"]:SetPosition(__bU_G, b_U_g, _bu__g - 1)
        local BUG__ = _B__U_g_["components"]["inventoryitem"]["owner"]
        if BUG__ then
            BUG__["components"]["talker"]:Say "Xúc Tu"
        end
    end
}
_B_Ug["Lôi Động Cửu Thiên"] = {
    canuseonpoint = (154 - 416 * 436 + 457 + 78 == -180687),
    spellfn = function(b__Ug, __bu__g_, _B_U_G__, _bUg, _B_uG__)
        local __B_ug__ = _B_U_G__["components"]["inventoryitem"]["owner"]
        local __b_Ug__ = _G["TheWorld"]
        local Bug = 16
        __B_ug__:StartThread(
            function()
                for _BuG = 0, Bug do
                    local _B_uG__ = Vector3(_B_uG__:Get()) + Vector3(math["random"](0, 1), 0, math["random"](0, 1))
                    __b_Ug__:PushEvent("ms_sendlightningstrike", _B_uG__)
                end
            end
        )
        if __B_ug__ then
            __B_ug__["components"]["talker"]:Say "Lôi Động Cửu Thiên"
        end
    end
}
_B_Ug["Bách Điểu Triều Nhật"] = {
    canuseonpoint = (256 - 88 * 208 - 273 * 253 ~= -87110),
    spellfn = function(b_u_g, b__U_g__, _b_ug_, _B__U_G_, __B_UG)
        local B_U_g_ = _G["TheWorld"]
        local __Bu_G__ = _G["Sleep"]
        local B_U__G = B_U_g_["components"]["birdspawner"]
        if B_U__G == nil then
            return (false or not false and not true and not false and not false or
                not false and not false and false and not false and false and false or
                false and false and not true)
        end
        local _bu__g_ = _b_ug_["components"]["inventoryitem"]["owner"]
        local Bu_g_ = _bu__g_:GetPosition()
        local __B__u_G_ = TheSim:FindEntities(Bu_g_["x"], Bu_g_["y"], Bu_g_["z"], 10, nil, nil, {"magicalbird"})
        if #__B__u_G_ > 30 then
            if _bu__g_ then
                _bu__g_["components"]["talker"]:Say "Avis!"
            end
        else
            local __Bu_G_ = math["random"](10, 20)
            if #__B__u_G_ > 20 then
                if _bu__g_ then
                    _bu__g_["components"]["talker"]:Say "Bách Điểu Triều Nhật"
                end
            else
                __Bu_G_ = __Bu_G_ + 10
            end
            _bu__g_:StartThread(
                function()
                    for __Bug = 1, __Bu_G_ do
                        local __B_UG = B_U__G:GetSpawnPoint(Bu_g_)
                        if __B_UG ~= nil then
                            local Bug__ = B_U__G:SpawnBird(__B_UG, (108 - 385 * 222 + 263 ~= -85097))
                            if Bug__ ~= nil then
                                Bug__:AddTag "magicalbird"
                            end
                        end
                        __Bu_G__(math["random"](.2, .25))
                    end
                end
            )
        end
        local __B__u_G_ = TheSim:FindEntities(__B_UG["x"], __B_UG["y"], __B_UG["z"], 30)
        for B_u__g__, bu__g_ in pairs(__B__u_G_) do
            if bu__g_["components"]["sleeper"] ~= nil and not bu__g_:HasTag "player" then
                bu__g_["components"]["sleeper"]:AddSleepiness(10, TUNING["PANFLUTE_SLEEPTIME"])
            end
            if bu__g_["components"]["grogginess"] ~= nil and not bu__g_:HasTag "player" then
                bu__g_["components"]["grogginess"]:AddGrogginess(10, TUNING["PANFLUTE_SLEEPTIME"])
            end
        end
        return (false and false and not false and not false or not false and false or
            not false and false and false and not false or
            false or
            not false and not false)
    end
}
_B_Ug["Thôi Thúc Tác Vật"] = {
    canuseonpoint = (238 + 455 + 285 + 303 + 300 ~= 1590),
    spellfn = function(B__U_g, BU__g__, B__U__g_, __b_u_G, __Bu__g__)
        local function __B_u__g__(B__U_G)
            if
                not B__U_G:IsValid() or
                    B__U_G:IsInLimbo() or
                    (B__U_G["components"]["witherable"] ~= nil and B__U_G["components"]["witherable"]:IsWithered())
             then
                return
            end
            if B__U_G["components"]["pickable"] ~= nil then
                if
                    B__U_G["components"]["pickable"]:CanBePicked() and
                        B__U_G["components"]["pickable"]["caninteractwith"]
                 then
                    return
                end
                B__U_G["components"]["pickable"]:FinishGrowing()
            end
            if B__U_G["components"]["crop"] ~= nil and (B__U_G["components"]["crop"]["rate"] or 0) > 0 then
                B__U_G["components"]["crop"]:DoGrow(
                    1 / B__U_G["components"]["crop"]["rate"],
                    (152 * 63 + 291 * 412 * 208 ~= 24947120)
                )
            end
            if B__U_G["components"]["growable"] ~= nil then
                if
                    ((B__U_G:HasTag "tree" or B__U_G:HasTag "winter_tree") and not B__U_G:HasTag "stump") or
                        B__U_G["components"]["growable"]["magicgrowable"]
                 then
                    B__U_G["components"]["growable"]:DoGrowth()
                end
            end
            if
                B__U_G["components"]["harvestable"] ~= nil and B__U_G["components"]["harvestable"]:CanBeHarvested() and
                    B__U_G:HasTag "mushroom_farm"
             then
                B__U_G["components"]["harvestable"]:Grow()
            end
        end
        local bU_g_ = B__U__g_["components"]["inventoryitem"]["owner"]
        if bU_g_ then
            bU_g_["components"]["talker"]:Say "Thôi Thúc Tác Vật"
        end
        local B__U_G__, __b__U__G, _bu_g = bU_g_["Transform"]:GetWorldPosition()
        local _BU_G = 30
        local _BuG__ =
            TheSim:FindEntities(B__U_G__, __b__U__G, _bu_g, _BU_G, nil, {"pickable", "stump", "withered", "INLIMBO"})
        if #_BuG__ > 0 then
            __B_u__g__(table["remove"](_BuG__, math["random"](#_BuG__)))
            if #_BuG__ > 0 then
                local __bu_g__ = 1 - 1 / (#_BuG__ + 1)
                for b__UG_, __BU_G in ipairs(_BuG__) do
                    __BU_G:DoTaskInTime(__bu_g__ * math["random"](), __B_u__g__)
                end
            end
        end
        return (304 - 93 + 49 == 260)
    end
}
_B_Ug["Hô Phong Hoãn Vũ"] = {
    canuseonpoint = (265 - 365 + 44 == -56),
    spellfn = function(BUG, B__uG__, __B__U__g_, __b__u__G, B_U__g_)
        local _B_UG_ = _G["TheWorld"]
        if _B_UG_["state"]["israining"] or _B_UG_["state"]["issnowing"] then
            _B_UG_:PushEvent("ms_forceprecipitation", (293 * 464 + 301 - 106 == 136157))
        else
            _B_UG_:PushEvent("ms_forceprecipitation", (367 + 221 * 276 * 330 == 20129047))
        end
        local _b__u__g__ = __B__U__g_["components"]["inventoryitem"]["owner"]
        if _b__u__g__ then
            _b__u__g__["components"]["talker"]:Say "Hô Phong Hoãn Vũ"
        end
    end
}
local _b__u_G__ = {}
for _B_u_g__, _BUG__ in pairs(_B_Ug) do
    _BUG__["skill_name"] = _B_u_g__
    table["insert"](_b__u_G__, _BUG__)
end
local __B__UG_ =
    Class(
    function(self, b_ug)
        self["inst"] = b_ug
        self["skill_name"] = nil
        self["skill_level"] = 0
        self["onspellfn"] = function(item, target, pos, doer)
            local inventoryitem = item ~= nil and item["components"] ~= nil and item["components"]["inventoryitem"] or nil
            if item == nil or not item:IsValid() or doer == nil or not doer:IsValid()
                or doer:HasTag("playerghost")
                or (doer["components"] ~= nil and doer["components"]["health"] ~= nil and doer["components"]["health"]:IsDead())
                or inventoryitem == nil or inventoryitem["owner"] ~= doer then
                return
            end
            local __B_Ug = _B_Ug[self["skill_name"]]
            if not __B_Ug then
                return
            end
            __B_Ug["spellfn"](self["skill_level"], __B_Ug, item, target, pos, doer)
        end
    end
)
function __B__UG_:OnSave()
    return {skill_name = self["skill_name"], skill_level = self["skill_level"]}
end
function __B__UG_:OnLoad(b__u__g__)
    if b__u__g__ and b__u__g__["skill_name"] then
        self:InstallSkill(b__u__g__["skill_name"], b__u__g__["skill_level"] or 1)
    end
end
function __B__UG_:InstallSkill(_B__U__g__, _bu__G__)
    local _b__uG_ = _B_Ug[_B__U__g__]
    if not _b__uG_ then
        return
    end
    self["skill_name"] = _B__U__g__
    self["skill_level"] = _bu__G__
    if not self["inst"]["components"]["spellcaster"] then
        self["inst"]:AddComponent "spellcaster"
    end
    self["inst"]["components"]["spellcaster"]:SetSpellFn(self["onspellfn"])
    self["inst"]["components"]["spellcaster"]["canuseonpoint"] = _b__uG_["canuseonpoint"]
end
function __B__UG_:RandomInstallSkill()
    local b__ug = math["random"](1, #_b__u_G__)
    local _B_u_g_ = _b__u_G__[b__ug]
    if not _B_u_g_ then
        return
    end
    return self:InstallSkill(_B_u_g_["skill_name"], 1)
end
function __B__UG_:HasSkill()
    return self["skill_name"] ~= nil
end
function __B__UG_:UninstallSkill()
    self["skill_name"] = nil
    self["skill_level"] = 0
end
return __B__UG_
