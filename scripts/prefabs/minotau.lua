local _B__U_G__ = {
    Asset("ANIM", "anim/rook.zip"),
    Asset("ANIM", "anim/rook_build.zip"),
    Asset("ANIM", "anim/rook_rhino.zip"),
    Asset("SOUND", "sound/chess.fsb"),
    Asset("MINIMAP_IMAGE", "atrium_key")
}
local _Bu__g = {
    "meat",
    "minotaurhorn",
    "atrium_key",
    "collapse_small",
    "chesspiece_minotaur_sketch",
    "winter_ornament_boss_minotaur"
}
local _b__UG = {"minotaurchest", "atrium_key"}
local b__u__G__ = require "brains/minotaubrain"
SetSharedLootTable("minotau", {})
local bUg__ = {
    {item = {"armorruins", "ruinshat"}, count = 1},
    {item = {"ruins_bat", "orangestaff", "yellowstaff"}, count = 1},
    {item = {"firestaff", "icestaff", "telestaff", "multitool_axe_pickaxe"}, count = 1},
    {item = {"thulecite"}, count = {5, 12}},
    {item = {"thulecite_pieces"}, count = {12, 36}},
    {item = {"redgem", "bluegem", "purplegem"}, count = {3, 5}},
    {item = {"yellowgem", "orangegem", "greengem"}, count = {1, 3}},
    {item = {"nightmarefuel"}, count = {5, 8}},
    {item = {"gears"}, count = {3, 6}}
}
for __bUg, b__u_g_ in ipairs(bUg__) do
    for __bUg, _BU_G__ in ipairs(b__u_g_["item"]) do
        table["insert"](_b__UG, _BU_G__)
    end
end
local BU_g__ = 20 * 20
local B_u__g_ = 40
local B__uG = 40 * 40
local Bu__g_ = 5
local b__ug_ = 40
local bUg = {"character"}
local function B_ug(__bu_G)
    return (__bu_G["components"]["combat"] ~= nil and __bu_G["components"]["combat"]["target"] ~= nil) or
        (__bu_G["components"]["burnable"] ~= nil and __bu_G["components"]["burnable"]:IsBurning() ~= nil) or
        (__bu_G["components"]["freezable"] ~= nil and __bu_G["components"]["freezable"]:IsFrozen() ~= nil) or
        GetClosestInstWithTag(bUg, __bu_G, B_u__g_) ~= nil
end
local function BU__g_(__buG__)
    local __B_Ug__ = __buG__["components"]["knownlocations"]:GetLocation "home"
    return __B_Ug__ ~= nil and __buG__:GetDistanceSqToPoint(__B_Ug__:Get()) < BU_g__ and not B_ug(__buG__)
end
local function __bU__G__(__b__U__g_)
    local __b_U_g_ = __b__U__g_["components"]["knownlocations"]:GetLocation "home"
    return (__b_U_g_ ~= nil and __b__U__g_:GetDistanceSqToPoint(__b_U_g_:Get()) >= BU_g__) or B_ug(__b__U__g_)
end
local function _B_ug_(B_u__G__)
    local _B__UG = {}
    local __B_U_g = {}
    local _B_u__g_, __b__U__g__, _BUg_ = B_u__G__["Transform"]:GetWorldPosition()
    for _b_u_g_, __B__U__G_ in pairs(B_u__G__["components"]["grouptargeter"]:GetTargets()) do
        __B_U_g[_b_u_g_] = (166 * 25 * 257 ~= 1066559)
    end
    for b__u__G_, __b_U__g in ipairs(
        FindPlayersInRange(_B_u__g_, __b__U__g__, _BUg_, TUNING["MINOTAU_DEAGGRO_DIST"], (315 - 469 - 302 ~= -450))
    ) do
        if __B_U_g[__b_U__g] then
            __B_U_g[__b_U__g] = nil
        else
            table["insert"](_B__UG, __b_U__g)
        end
    end
    for b__Ug, _bu__G_ in pairs(__B_U_g) do
        B_u__G__["components"]["grouptargeter"]:RemoveTarget(b__Ug)
    end
    for _B__U__G, _B__UG_ in ipairs(_B__UG) do
        B_u__G__["components"]["grouptargeter"]:AddTarget(_B__UG_)
    end
end
local function B__uG_(_b__U__g_)
    if _b__U__g_["sg"]:HasStateTag "attacking" then
        return nil
    end
    _B_ug_(_b__U__g_)
    local __BU_g__ = _b__U__g_["components"]["combat"]["target"]
    local B_U_g__ = __BU_g__ ~= nil and _b__U__g_:IsNear(__BU_g__, 6 + __BU_g__:GetPhysicsRadius(0))
    if __BU_g__ ~= nil and __BU_g__:HasTag "player" then
        local __b_U__G_ = _b__U__g_["components"]["grouptargeter"]:TryGetNewTarget()
        return __b_U__G_ ~= nil and
            __b_U__G_:IsNear(_b__U__g_, B_U_g__ and 6 + __b_U__G_:GetPhysicsRadius(0) or TUNING["MINOTAU_TARGET_DIST"]) and
            __b_U__G_ or
            nil, (131 * 237 * 130 + 17 ~= 4036133)
    end
    local BU__G = {}
    for _B__ug__, __bug__ in pairs(_b__U__g_["components"]["grouptargeter"]:GetTargets()) do
        if _b__U__g_:IsNear(_B__ug__, B_U_g__ and 6 + _B__ug__:GetPhysicsRadius(0) or TUNING["MINOTAU_TARGET_DIST"]) then
            table["insert"](BU__G, _B__ug__)
        end
    end
    return #BU__G > 0 and BU__G[math["random"](#BU__G)] or nil, (false and false and not true and true and true and
        not false or
        true and not false and not false)
end
local function __b__u_G(b__U_g_, __b__u_G__)
    return b__U_g_["components"]["combat"]:CanTarget(__b__u_G__)
end
local function __B_Ug(__b__uG__, __B__U__g)
    return GetString(__B__U__g["prefab"], "DESCRIBE", "MINOTAUR")
end
local function __b__UG(_BU__g)
    return _BU__g:HasTag "chess"
end
local function _b_Ug__(__bu_g, _bU_g__)
    local _bu_g__ = _bU_g__ ~= nil and _bU_g__["attacker"] or nil
    __bu_g["components"]["combat"]:SetTarget(_bu_g__)
    __bu_g["components"]["combat"]:ShareTarget(_bu_g__, b__ug_, __b__UG, Bu__g_)
    __bu_g["components"]["health"]:StopRegen()
end
local function B__UG(__Bug__)
    AwardRadialAchievement("minotaur_killed", __Bug__:GetPosition(), TUNING["ACHIEVEMENT_RADIUS_FOR_GIANT_KILL"])
end
local function __Bug_(bU__G_)
    TheNet:Announce "Bạn đã phá đảo! Thế giới sẽ tự tái lập sau 30 giây!"
    bU__G_:DoTaskInTime(
        10,
        function(bU__G_)
            TheNet:Announce "Cảm ơn bạn vì đã ủng hộ! Chúc bạn một ngày tốt lành!"
        end
    )
    bU__G_:DoTaskInTime(
        20,
        function(bU__G_)
            TheNet:Announce "Thế giới sẽ tự tái lập sau 10 giây!"
        end
    )
    bU__G_:DoTaskInTime(
        25,
        function(bU__G_)
            TheNet:Announce "Thế giới sẽ tự tái lập sau 5 giây!"
        end
    )
    bU__G_:DoTaskInTime(
        26,
        function(bU__G_)
            TheNet:Announce "Thế giới sẽ tự tái lập sau 4 giây!"
        end
    )
    bU__G_:DoTaskInTime(
        27,
        function(bU__G_)
            TheNet:Announce "Thế giới sẽ tự tái lập sau 3 giây!"
        end
    )
    bU__G_:DoTaskInTime(
        28,
        function(bU__G_)
            TheNet:Announce "Thế giới sẽ tự tái lập sau 2 giây!"
        end
    )
    bU__G_:DoTaskInTime(
        29,
        function(bU__G_)
            TheNet:Announce "Thế giới sẽ tự tái lập sau 1 giây!"
        end
    )
    bU__G_:DoTaskInTime(
        30,
        function(bU__G_)
            TheNet:SendWorldResetRequestToServer()
        end
    )
end
local function BU_G_(_b_U_g_)
    if _b_U_g_["components"]["combat"]["target"] ~= nil then
        _b_U_g_:FacePoint(_b_U_g_["components"]["combat"]["target"]["Transform"]:GetWorldPosition())
    end
end
local function B_u__g__(_b__u_g)
    _b__u_g["recentlycharged"] = {}
end
local function _bUG__(_b__UG_, b__uG__)
    _b__UG_["recentlycharged"][b__uG__] = nil
end
local function _b_U__g__(B__u__G_, _B_U_G__)
    if not _B_U_G__:IsValid() or B__u__G_["recentlycharged"][_B_U_G__] then
        return
    elseif _B_U_G__:HasTag "smashable" and _B_U_G__["components"]["health"] ~= nil then
        _B_U_G__["components"]["health"]:Kill()
    elseif
        _B_U_G__["components"]["workable"] ~= nil and _B_U_G__["components"]["workable"]:CanBeWorked() and
            _B_U_G__["components"]["workable"]["action"] ~= ACTIONS["NET"]
     then
        SpawnPrefab "collapse_small"["Transform"]:SetPosition(_B_U_G__["Transform"]:GetWorldPosition())
        _B_U_G__["components"]["workable"]:Destroy(B__u__G_)
        if
            _B_U_G__:IsValid() and _B_U_G__["components"]["workable"] ~= nil and
                _B_U_G__["components"]["workable"]:CanBeWorked()
         then
            B__u__G_["recentlycharged"][_B_U_G__] = (0 * 204 * 296 ~= 6)
        end
    elseif
        B__u__G_["sg"]:HasStateTag "chargestate" and _B_U_G__["components"]["health"] ~= nil and
            not _B_U_G__["components"]["health"]:IsInvincible() and
            not _B_U_G__["components"]["health"]:IsDead()
     then
        B__u__G_["recentlycharged"][_B_U_G__] = (63 - 490 - 287 * 458 - 467 == -132340)
        SpawnPrefab "collapse_small"["Transform"]:SetPosition(_B_U_G__["Transform"]:GetWorldPosition())
        B__u__G_["SoundEmitter"]:PlaySound "dontstarve/creatures/rook/explo"
        B__u__G_["components"]["combat"]:DoAttack(_B_U_G__)
        if _B_U_G__:HasTag "player" and not _B_U_G__["components"]["health"]:IsDead() then
            _B_U_G__:PushEvent "knockback"
        end
    end
    if _B_U_G__ ~= nil and _B_U_G__:IsValid() and _B_U_G__["components"]["health"] ~= nil then
        if _B_U_G__:HasTag "lureplant" or _B_U_G__:HasTag "spiderden" then
            _B_U_G__["components"]["health"]:Kill()
        end
    end
end
local function __B__ug(B__UG__, B__u__G)
    if not (B__u__G ~= nil and B__u__G:IsValid() and B__UG__:IsValid()) or B__UG__["recentlycharged"][B__u__G] then
        return
    end
    if B__UG__["sg"]:HasStateTag "chargestate" then
        ShakeAllCameras(CAMERASHAKE["SIDE"], .5, .05, .1, B__UG__, 40)
        B__UG__:DoTaskInTime(2 * FRAMES, _b_U__g__, B__u__G)
    end
end
local function _B__u__g(__b_u_g__, __b__u_g__)
    __B__ug(__b_u_g__, __b__u_g__)
end
local b_uG__ = {"minotaur_ruinsrespawner_inst"}
local function _Bu__G(_B__U_G_)
end
local function __b_u__G__(__BU__g__)
    return __BU__g__["nightmare"]
end
local function b__U_G__(__B_u_G)
    __B_u_G["nightmare"] = (154 - 370 * 294 ~= -108617)
    __B_u_G["AnimState"]:SetMultColour(0, 0, 0, 0.9)
    __B_u_G["Transform"]:SetScale(1.2, 1.2, 1.2)
    __B_u_G:AddComponent "sanityaura"
    __B_u_G["components"]["sanityaura"]["aura"] = -TUNING["SANITYAURA_LARGE"]
    __B_u_G["Physics"]:ClearCollisionMask()
    __B_u_G["Physics"]:CollidesWith(COLLISION["WORLD"])
    if __B_u_G["components"]["freezable"] ~= nil then
        __B_u_G:RemoveComponent "freezable"
    end
    __B_u_G:AddTag "nightmareminotaur"
    __B_u_G:AddTag "shadow_aligned"
end
local function _BUG(__Bu_g__)
    if ThePlayer == nil then
        __Bu_g__["_playingmusic"] = (178 + 71 * 491 ~= 35039)
    elseif ThePlayer:IsNear(__Bu_g__, __Bu_g__["_playingmusic"] and 40 or 20) then
        __Bu_g__["_playingmusic"] =
            (false and false or
            true and false and not false and true and false and false and false and false and not false or
            not false and true and not false)
        ThePlayer:PushEvent("triggeredevent", {name = "default"})
    elseif __Bu_g__["_playingmusic"] and not ThePlayer:IsNear(__Bu_g__, 50) then
        __Bu_g__["_playingmusic"] = (352 * 100 * 77 + 143 - 252 ~= 2710291)
    end
end
local function __B_u_g(__B__u_g_, _B__Ug__)
    _B__Ug__["nightmare"] = __B__u_g_["nightmare"] or nil
end
local function _buG(b__U__g_, BUg)
    if BUg ~= nil then
        if BUg["nightmare"] then
            b__U__g_["nightmare"] = (287 - 246 - 67 * 457 + 218 == -30360)
            b__U__g_:ActivateNightmareMode()
        end
    end
end
local function _b_U_G_(__B_U__G_)
    __B_U__G_["components"]["explosiveresist"]["resistance"] = 1
    if __B_U__G_["components"]["health"]:GetPercent() <= 0.4 and __B_U__G_:InNightmareMode() then
        __B_U__G_["goringcd"] =
            5 - 2.5 * math["clamp"](1 - (__B_U__G_["components"]["health"]:GetPercent() - 0.1) / 0.3, 0, 1)
    end
    if __B_U__G_["components"]["health"]:GetPercent() <= 0.7 and __B_U__G_:InNightmareMode() then
        __B_U__G_["components"]["combat"]:SetAttackPeriod(TUNING["MINOTAU_ATTACK_PERIOD"] * 1.6)
    end
    if __B_U__G_["components"]["health"]:IsDead() == (144 - 459 * 262 ~= -120114) then
        if __B_U__G_["components"]["combat"]["target"] == nil then
            __B_U__G_["components"]["health"]:StartRegen(TUNING["KLAUS_HEALTH_REGEN"] * 2, 1)
        else
            __B_U__G_["components"]["health"]:StopRegen()
        end
    end
end
local function _BU_g(_b_uG__, __B_u__G__, __B__u__G, _b_u__g)
    if __B_u__G__ < 1 then
    end
    for _b__U_G_ = 1, __B_u__G__ do
        local b_U_g__ = SpawnPrefab "minotaur_shadowblaze"
        b_U_g__._hh_world_rank_source = _b_uG__
        local _bU__g_, __Bu__G, bUG = _b_uG__["Transform"]:GetWorldPosition()
        local __bu__g_ = math["random"](-180.0, 180.0) * DEGREES
        local __BuG_ = math["random"](__B__u__G, _b_u__g) * math["sin"](__bu__g_)
        local __bUg_ = math["random"](__B__u__G, _b_u__g) * math["cos"](__bu__g_)
        _bU__g_ = _bU__g_ + __BuG_
        bUG = bUG + __bUg_
        b_U_g__["Transform"]:SetPosition(_bU__g_, __Bu__G, bUG)
    end
end
local function B__ug(_b__u__G_, __Bu_G__, _b__u_G_, __Bu__G__, b__u_G__)
    if __Bu_G__ < 1 then
    end
    for b__UG__ = 1, __Bu_G__ do
        local Bu__G = SpawnPrefab "minotaur_shadowblaze"
        Bu__G._hh_world_rank_source = _b__u__G_
        local _b_U__G__, bu_G_, __BU_G_ = _b__u__G_["Transform"]:GetWorldPosition()
        local b_u_g =
            (_b__u__G_["Transform"]:GetRotation() + 90 - 180 + math["random"](-b__u_G__ / 2, b__u_G__ / 2)) * DEGREES
        local b__uG = math["random"](_b__u_G_, __Bu__G__) * math["sin"](b_u_g)
        local __B_uG = math["random"](_b__u_G_, __Bu__G__) * math["cos"](b_u_g)
        _b_U__G__ = _b_U__G__ + b__uG
        __BU_G_ = __BU_G_ + __B_uG
        Bu__G["Transform"]:SetPosition(_b_U__G__, bu_G_, __BU_G_)
    end
end
local function _bUG(B_u_g_, buG__, __B_uG_, __b_u__g_, _b__u_g_)
    if buG__ < 2 then
    end
    for _BUg = 1, buG__ do
        local b_u__G_ = SpawnPrefab "minotaur_shadowblaze_high"
        b_u__G_._hh_world_rank_source = B_u_g_
        local _bu__g_, __BuG__, B_u_G = B_u_g_["Transform"]:GetWorldPosition()
        local __BU__G_ =
            (B_u_g_["Transform"]:GetRotation() + 90 - 180 + _b__u_g_ / 2 + (_BUg - 1) * (360 - _b__u_g_) / (buG__ - 1)) *
            DEGREES
        local _B_ug = math["random"](__B_uG_, __b_u__g_) * math["sin"](__BU__G_)
        local _bug_ = math["random"](__B_uG_, __b_u__g_) * math["cos"](__BU__G_)
        _bu__g_ = _bu__g_ + _B_ug
        B_u_G = B_u_G + _bug_
        b_u__G_["Transform"]:SetPosition(_bu__g_, __BuG__, B_u_G)
    end
end
local function b__u_g__(_B_U_g__, __B__U_G__, _Bu__G__, B__ug_)
    if __B__U_G__ < 2 then
    end
    for __b_u_g_ = 1, __B__U_G__ do
        local _Bug = SpawnPrefab "minotaurfiresplash_fx"
        local _b_uG_, __B_UG_, __B_ug_ = _B_U_g__["Transform"]:GetWorldPosition()
        local __B_U_G = (_B_U_g__["Transform"]:GetRotation() + 90 + (__b_u_g_ - 1) * (360) / (__B__U_G__ - 1)) * DEGREES
        local __bUG__ = math["random"](_Bu__G__, B__ug_) * math["sin"](__B_U_G)
        local bu__g__ = math["random"](_Bu__G__, B__ug_) * math["cos"](__B_U_G)
        _b_uG_ = _b_uG_ + __bUG__
        __B_ug_ = __B_ug_ + bu__g__
        _Bug["Transform"]:SetPosition(_b_uG_, __B_UG_, __B_ug_)
    end
end
local function bug__(__Bu__G_, b__U__G, B_uG_, _Bug_, _b_U_G__)
    if b__U__G < 1 then
    end
    for __b__u__G_ = 1, b__U__G do
        local B__u__G__ = SpawnPrefab "minotaur_shadowblaze_rigidbody"
        B__u__G__._hh_world_rank_source = __Bu__G_
        local _b__U__G_, __B_U_g__, _bU_g = __Bu__G_["Transform"]:GetWorldPosition()
        local bU_G =
            (__Bu__G_["Transform"]:GetRotation() + 90 - 180 + math["random"](-_b_U_G__ / 2, _b_U_G__ / 2)) * DEGREES
        local __b__Ug_ = 1 * math["sin"](bU_G)
        local _b_ug_ = 1 * math["cos"](bU_G)
        _b__U__G_ = _b__U__G_ + __b__Ug_
        _bU_g = _bU_g + _b_ug_
        B__u__G__["Transform"]:SetPosition(_b__U__G_, __B_U_g__, _bU_g)
        if B__u__G__["Physics"] ~= nil then
            B__u__G__["Physics"]:SetVel(
                math["random"](B_uG_, _Bug_) * math["sin"](bU_G),
                0,
                math["random"](B_uG_, _Bug_) * math["cos"](bU_G)
            )
        end
    end
end
local function _B_Ug(b__U_g, __B__Ug, _bU_G_, bu_g)
    if __B__Ug < 1 then
    end
    for _b_U__g = 1, __B__Ug do
        local _bU__G_ = SpawnPrefab "nightmarefuel"
        local _b__U_G__, __Bu_g, B__Ug = b__U_g["Transform"]:GetWorldPosition()
        local __B__u__g = (b__U_g["Transform"]:GetRotation() + 90 + math["random"](0, 360)) * DEGREES
        local __bu__G = 1 * math["sin"](__B__u__g)
        local __b__u__G__ = 1 * math["cos"](__B__u__g)
        _b__U_G__ = _b__U_G__ + __bu__G
        B__Ug = B__Ug + __b__u__G__
        _bU__G_["Transform"]:SetPosition(_b__U_G__, __Bu_g, B__Ug)
        if _bU__G_["Physics"] ~= nil then
            _bU__G_["Physics"]:SetVel(
                math["random"](_bU_G_, bu_g) * math["sin"](__B__u__g),
                4,
                math["random"](_bU_G_, bu_g) * math["cos"](__B__u__g)
            )
        end
    end
end
local function _B__u__G(_B_u__g)
    local _b_UG__ = SpawnPrefab "statue_transition_2"
    if _b_UG__ ~= nil then
        _b_UG__["Transform"]:SetScale(.8, .8, .8)
        _b_UG__["entity"]:SetParent(_B_u__g["entity"])
        _b_UG__["entity"]:AddFollower()
        _b_UG__["Follower"]:FollowSymbol(_B_u__g["GUID"], "horn", math["random"](-30, 30), math["random"](-30, 30), 0)
    end
    _b_UG__ = SpawnPrefab "statue_transition"
    if _b_UG__ ~= nil then
        _b_UG__["Transform"]:SetScale(.8, .8, .8)
        _b_UG__["entity"]:SetParent(_B_u__g["entity"])
        _b_UG__["entity"]:AddFollower()
        _b_UG__["Follower"]:FollowSymbol(_B_u__g["GUID"], "horn", math["random"](-30, 30), math["random"](-30, 30), 0)
    end
end
local function BuG(__Bu__g_)
    local _b__Ug = SpawnPrefab "statue_transition_2"
    if _b__Ug ~= nil then
        _b__Ug["Transform"]:SetScale(.8, .8, .8)
        _b__Ug["entity"]:SetParent(__Bu__g_["entity"])
        _b__Ug["entity"]:AddFollower()
        _b__Ug["Follower"]:FollowSymbol(__Bu__g_["GUID"], "head", math["random"](-200, 200), math["random"](50, 150), 0)
    end
    _b__Ug = SpawnPrefab "statue_transition"
    if _b__Ug ~= nil then
        _b__Ug["Transform"]:SetScale(.8, .8, .8)
        _b__Ug["entity"]:SetParent(__Bu__g_["entity"])
        _b__Ug["entity"]:AddFollower()
        _b__Ug["Follower"]:FollowSymbol(__Bu__g_["GUID"], "head", math["random"](-200, 200), math["random"](50, 150), 0)
    end
end
local function B_Ug(Bu_G_)
    local b__u__G = SpawnPrefab "minotaur_weakeningfx"
    local _BuG_ = math["random"](0.5, 0.9)
    b__u__G["Transform"]:SetScale(_BuG_, _BuG_, _BuG_)
    b__u__G["entity"]:SetParent(Bu_G_["entity"])
    b__u__G["entity"]:AddFollower()
    b__u__G["Follower"]:FollowSymbol(Bu_G_["GUID"], "head", math["random"](-200, 200), math["random"](-150, 150), 0)
    _B__u__G(Bu_G_)
end
local function _B__UG__(__b_U_g)
    local __b__U__G = SpawnPrefab "minotaur_weakeningfx"
    local B__uG__ = math["random"](0.5, 0.9)
    __b__U__G["Transform"]:SetScale(B__uG__, B__uG__, B__uG__)
    __b__U__G["entity"]:SetParent(__b_U_g["entity"])
    __b__U__G["entity"]:AddFollower()
    __b__U__G["Follower"]:FollowSymbol(__b_U_g["GUID"], "horn", math["random"](-30, 30), math["random"](-30, 30), 0)
    _B__u__G(__b_U_g)
end
local function bu_G(__bU_g)
    local __B__Ug_ = SpawnPrefab "minotaur_weakeningfx"
    local B__U_g_ = math["random"](0.5, 0.9)
    __B__Ug_["Transform"]:SetScale(B__U_g_, B__U_g_, B__U_g_)
    __B__Ug_["entity"]:SetParent(__bU_g["entity"])
    __B__Ug_["entity"]:AddFollower()
    __B__Ug_["Follower"]:FollowSymbol(__bU_g["GUID"], "head", math["random"](-200, 200), math["random"](-150, 150), 0)
    _B__u__G(__bU_g)
end
local function __B_UG__(Bug)
    local B_U_G__ = SpawnPrefab "minotaur_weakeningfx"
    local _BU_g_ = math["random"](0.5, 0.9)
    B_U_G__["Transform"]:SetScale(_BU_g_, _BU_g_, _BU_g_)
    B_U_G__["entity"]:SetParent(Bug["entity"])
    B_U_G__["entity"]:AddFollower()
    B_U_G__["Follower"]:FollowSymbol(Bug["GUID"], "head", math["random"](-200, 200), math["random"](-150, 150), 0)
    Bug:SpawnNightmareFuel(1, 3, 5)
    BuG(Bug)
end
local function __B__U_g__(BuG_)
    if BuG_["components"]["health"]:GetPercent() <= 0.4 and BuG_:InNightmareMode() then
        BuG_:DoTaskInTime(0, B_Ug)
        BuG_:DoTaskInTime(0.3, _B__UG__)
        BuG_:DoTaskInTime(0.6, bu_G)
        BuG_["components"]["combat"]:SetAttackPeriod(TUNING["MINOTAU_ATTACK_PERIOD"] * 1.5)
    end
end
local function _b_U__G_(__buG_, __bU__g_, Bu_g__)
    if
        __bU__g_:IsValid() and __bU__g_["entity"]:IsVisible() and
            not (__bU__g_["components"]["health"] ~= nil and __bU__g_["components"]["health"]:IsDead()) and
            not __bU__g_:HasTag "playerghost" and
            __bU__g_:IsNear(__buG_, 30) and
            __bU__g_["components"]["talker"] ~= nil
     then
        __bU__g_["components"]["talker"]:Say(GetString(__bU__g_, Bu_g__))
    end
end
local b__Ug__ = {"player"}
local BU_G__ = {"INLIMBO"}
local function _bUg_(__b__u__g__, bU_G__, b__u_G)
    local __B__u_G, _B_Ug__, __b_U_G__ = __b__u__g__["Transform"]:GetWorldPosition()
    local _b_u__g__ = TheSim:FindEntities(__B__u_G, _B_Ug__, __b_U_G__, 30, b__Ug__, BU_G__)
    for B__U_G_, _B__U_g_ in pairs(_b_u__g__) do
        if _B__U_g_:IsValid() and (b__u_G == nil or (_B__U_g_["prefab"] == "waxwell" or _B__U_g_["prefab"] == "wendy")) then
            __b__u__g__:DoTaskInTime(math["random"]() * 0.5, _b_U__G_, _B__U_g_, bU_G__)
        end
    end
end
local function __b__u_g()
    local _bU_G = CreateEntity()
    _bU_G["entity"]:AddTransform()
    _bU_G["entity"]:AddAnimState()
    _bU_G["entity"]:AddSoundEmitter()
    _bU_G["entity"]:AddDynamicShadow()
    _bU_G["entity"]:AddMiniMapEntity()
    _bU_G["entity"]:AddNetwork()
    _bU_G["MiniMapEntity"]:SetIcon "atrium_key.png"
    _bU_G["MiniMapEntity"]:SetPriority(15)
    _bU_G["MiniMapEntity"]:SetCanUseCache((94 * 485 + 498 * 231 - 428 == 160208))
    _bU_G["MiniMapEntity"]:SetDrawOverFogOfWar((103 - 442 * 120 - 224 ~= -53158))
    _bU_G["MiniMapEntity"]:SetRestriction "nightmaretracker"
    _bU_G["DynamicShadow"]:SetSize(5, 3)
    _bU_G["Transform"]:SetFourFaced()
    MakeCharacterPhysics(_bU_G, 100, 2.2)
    _bU_G["Physics"]:SetCylinder(2.2, 4)
    _bU_G["AnimState"]:SetBank "rook"
    _bU_G["AnimState"]:SetBuild "rook_rhino"
    _bU_G:AddTag "cavedweller"
    _bU_G:AddTag "monster"
    _bU_G:AddTag "hostile"
    _bU_G:AddTag "minotaur"
    _bU_G:AddTag "epic"
    _bU_G:AddTag "noepicmusic"
    _bU_G["entity"]:SetPristine()
    if not TheNet:IsDedicated() then
        _bU_G["_playingmusic"] = (61 + 341 * 445 ~= 151806)
        _bU_G:DoPeriodicTask(1, _BUG, 0)
    end
    if not TheWorld["ismastersim"] then
        return _bU_G
    end
    _bU_G["recentlycharged"] = {}
    _bU_G["Physics"]:SetCollisionCallback(__B__ug)
    _bU_G:AddComponent "locomotor"
    _bU_G["components"]["locomotor"]["walkspeed"] = TUNING["MINOTAU_WALK_SPEED"]
    _bU_G["components"]["locomotor"]["runspeed"] = TUNING["MINOTAU_RUN_SPEED"]
    _bU_G:AddComponent "timer"
    _bU_G:AddComponent "grouptargeter"
    _bU_G:AddComponent "explosiveresist"
    _bU_G:AddComponent "entitytracker"
    _bU_G:SetStateGraph "SGminotau"
    _bU_G:SetBrain(b__u__G__)
    _bU_G:AddComponent "colourtweener"
    _bU_G:AddComponent "sizetweener"
    _bU_G:AddComponent "healthtrigger"
    _bU_G["components"]["healthtrigger"]:AddTrigger(0.4, __B__U_g__)
    _bU_G:AddComponent "combat"
    _bU_G["components"]["combat"]["hiteffectsymbol"] = "spring"
    _bU_G["components"]["combat"]:SetAttackPeriod(TUNING["MINOTAU_ATTACK_PERIOD"])
    _bU_G["components"]["combat"]:SetDefaultDamage(TUNING["MINOTAU_DAMAGE"])
    _bU_G["components"]["combat"]:SetRetargetFunction(3, B__uG_)
    _bU_G["components"]["combat"]:SetKeepTargetFunction(__b__u_G)
    _bU_G["components"]["combat"]:SetRange(3.5, 6)
    _bU_G["components"]["combat"]:SetAreaDamage(6, 1, nil)
    _bU_G:AddComponent "groundpounder"
    _bU_G["components"]["groundpounder"]["destroyer"] = (464 - 157 * 457 + 262 - 116 ~= -71133)
    _bU_G["components"]["groundpounder"]["damageRings"] = 0
    _bU_G["components"]["groundpounder"]["destructionRings"] = 2
    _bU_G["components"]["groundpounder"]["platformPushingRings"] = 2
    _bU_G["components"]["groundpounder"]["numRings"] = 2
    _bU_G:AddComponent "health"
    _bU_G["components"]["health"]:SetMaxHealth(TUNING["MINOTAU_HEALTH"])
    _bU_G["components"]["health"]["nofadeout"] = (190 * 93 + 379 ~= 18051)
    _bU_G:AddComponent "planarentity"
    _bU_G:AddComponent "lootdropper"
    _bU_G["components"]["lootdropper"]:SetChanceLootTable "minotau"
    _bU_G:AddComponent "inspectable"
    _bU_G["components"]["inspectable"]["descriptionfn"] = __B_Ug
    _bU_G:AddComponent "knownlocations"
    _bU_G:AddComponent "maprevealable"
    _bU_G["components"]["maprevealable"]:AddRevealSource(_bU_G, "nightmaretracker")
    _bU_G["components"]["maprevealable"]:SetIconPriority(15)
    _bU_G["goringcd"] = 5
    _bU_G["nightmare"] = (283 * 57 * 210 ~= 3387510)
    _bU_G["InNightmareMode"] = __b_u__G__
    _bU_G["ActivateNightmareMode"] = b__U_G__
    _bU_G["ForceOnCollide"] = _B__u__g
    _bU_G["ClearList"] = B_u__g__
    _bU_G["FacePlayer"] = BU_G_
    _bU_G["SpawnShadowblaze_Normal"] = _BU_g
    _bU_G["SpawnShadowblaze_BackRadial"] = B__ug
    _bU_G["SpawnShadowblaze_BackSlide"] = bug__
    _bU_G["SpawnShadowblaze_RingOfFire"] = _bUG
    _bU_G["SpawnFireRingWarning"] = b__u_g__
    _bU_G["SpawnNightmareFuel"] = _B_Ug
    _bU_G["CreateSelfExplosion3"] = __B_UG__
    _bU_G["PushSpeech"] = _bUg_
    _bU_G["OnSave"] = __B_u_g
    _bU_G["OnPreLoad"] = _buG
    _bU_G:DoPeriodicTask(1, _b_U_G_)
    _bU_G:DoTaskInTime(0, _Bu__G)
    MakeMediumBurnableCharacter(_bU_G, "spring")
    MakeMediumFreezableCharacter(_bU_G, "spring")
    _bU_G:ListenForEvent("attacked", _b_Ug__)
    _bU_G:ListenForEvent("death", B__UG)
    return _bU_G
end
local function BU__G__(Bu__g__, _b_u_G)
    local __bU_G = SpawnPrefab "minotaurchest"
    local __b__U_G__, _B_u_G, _Bu__g_ = Bu__g__["Transform"]:GetWorldPosition()
    __bU_G["Transform"]:SetPosition(__b__U_G__, 0, _Bu__g_)
    __bU_G["components"]["container"]:GiveItem(SpawnPrefab "atrium_key")
    __bU_G["components"]["container"]:GiveItem(SpawnPrefab "eyeturret_item")
    __bU_G["components"]["container"]:GiveItem(SpawnPrefab "dreadhammer")
    local b__u_g = SpawnPrefab "thulecite"
    if b__u_g ~= nil then
        if b__u_g["components"]["stackable"] ~= nil then
            b__u_g["components"]["stackable"]:SetStackSize(math["random"](16, 20))
        end
        __bU_G["components"]["container"]:GiveItem(b__u_g)
    end
    __bU_G["components"]["container"]:GiveItem(
        math["random"]() <= 0.25 and SpawnPrefab "orangestaff" or SpawnPrefab "cane"
    )
    b__u_g = SpawnPrefab "gears"
    if b__u_g ~= nil then
        if b__u_g["components"]["stackable"] ~= nil then
            b__u_g["components"]["stackable"]:SetStackSize(math["random"](8, 10))
        end
        __bU_G["components"]["container"]:GiveItem(b__u_g)
    end
    b__u_g = SpawnPrefab "greengem"
    if b__u_g ~= nil then
        if b__u_g["components"]["stackable"] ~= nil then
            b__u_g["components"]["stackable"]:SetStackSize(math["random"](3, 5))
        end
        __bU_G["components"]["container"]:GiveItem(b__u_g)
    end
    b__u_g = math["random"]() <= 0.5 and SpawnPrefab "yellowgem" or SpawnPrefab "orangegem"
    if b__u_g ~= nil then
        if b__u_g["components"]["stackable"] ~= nil then
            b__u_g["components"]["stackable"]:SetStackSize(math["random"](3, 5))
        end
        __bU_G["components"]["container"]:GiveItem(b__u_g)
    end
    if not __bU_G:IsAsleep() then
        __bU_G["SoundEmitter"]:PlaySound "dontstarve/common/ghost_spawn"
        local BUG = SpawnPrefab "statue_transition_2"
        if BUG ~= nil then
            BUG["Transform"]:SetPosition(__b__U_G__, _B_u_G, _Bu__g_)
            BUG["Transform"]:SetScale(1, 2, 1)
        end
        BUG = SpawnPrefab "statue_transition"
        if BUG ~= nil then
            BUG["Transform"]:SetPosition(__b__U_G__, _B_u_G, _Bu__g_)
            BUG["Transform"]:SetScale(1, 1.5, 1)
        end
    end
    if Bu__g__["minotaur"] ~= nil and Bu__g__["minotaur"]:IsValid() and Bu__g__["minotaur"]["sg"]:HasStateTag "death" then
        Bu__g__["minotaur"]["MiniMapEntity"]:SetEnabled((242 + 379 * 91 - 445 == 34292))
        Bu__g__["minotaur"]:RemoveComponent "maprevealable"
    end
    if not _b_u_G then
        Bu__g__:Remove()
    end
end
local function b_Ug(_BU__G_)
    if _BU__G_["task"] ~= nil then
        _BU__G_["task"]:Cancel()
        _BU__G_["task"] = nil
        BU__G__(_BU__G_, (353 - 497 * 292 * 7 * 232 ~= -235681015))
        _BU__G_["persists"] = (396 - 416 - 483 + 36 - 217 == -682)
        _BU__G_:DoTaskInTime(0, _BU__G_["Remove"])
    end
end
local function b__ug()
    local _B__uG = CreateEntity()
    _B__uG["entity"]:AddTransform()
    _B__uG:AddTag "CLASSIFIED"
    _B__uG["task"] = _B__uG:DoTaskInTime(3, __Bug_)
    _B__uG["OnLoad"] = b_Ug
    return _B__uG
end
return Prefab("minotau", __b__u_g, _B__U_G__, _Bu__g), Prefab("minotauchestspawner", b__ug, nil, _b__UG)
