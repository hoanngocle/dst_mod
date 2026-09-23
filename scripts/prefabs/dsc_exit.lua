local __BU__g__ = {Asset("ANIM", "anim/dsc_exit.zip")}
local function _b__ug__(__B_ug__, __B__Ug_)
    if __B__Ug_ and __B__Ug_["sg"] then
        __B__Ug_["sg"]:GoToState "arrive"
    end
end
local function _b__u_g__(B__u__g__)
    B__u__g__["components"]["childspawner"]:ReleaseAllChildren()
end
local function B_Ug(_b_Ug)
    if _b_Ug["releasefishtask"] ~= nil then
        _b_Ug["releasefishtask"]:Cancel()
        _b_Ug["releasefishtask"] = nil
    end
end
local function b_U__G__(_Bu_G)
    local B_U_g_ = TheWorld["state"]["season"]
    if B_U_g_ == SEASONS["WINTER"] then
        _Bu_G["releasefishtask"] = _Bu_G:DoTaskInTime(0.1, _b__u_g__)
    end
end
local function __b__u_g__(B__Ug_, __Bu__g_)
    if __Bu__g_ == SEASONS["WINTER"] then
        B__Ug_["components"]["childspawner"]:StartSpawning()
    else
        B__Ug_["components"]["childspawner"]:StopSpawning()
    end
end
local function __buG__(_BU_G__, Bu_g_)
    if Bu_g_ and Bu_g_:IsValid() then
        local _BUG_ = Bu_g_:GetPosition()
        if _BUG_ == _BU_G__:GetPosition() then
            local __BU_g_, _b__UG, BUG__ = _BUG_:Get()
            local _b__Ug = math["random"]() * 2 * PI
            local __b__U_g__ = _BU_G__:GetPhysicsRadius(0) + math["random"]() * 0.33
            Bu_g_["Physics"]:Teleport(
                __BU_g_ + math["cos"](_b__Ug) * __b__U_g__,
                0,
                BUG__ - math["sin"](_b__Ug) * __b__U_g__
            )
        end
    end
end
local function bU__G__(_bU__G_, B__uG)
    if B__uG:HasTag "player" then
        if B__uG["components"]["talker"] ~= nil then
            B__uG["components"]["talker"]:ShutUp()
        end
        if B__uG["components"]["playercontroller"] ~= nil then
            B__uG["components"]["playercontroller"]:EnableMapControls((326 + 53 + 446 - 500 + 171 == 496))
            B__uG:DoTaskInTime(
                13 * FRAMES,
                function()
                    local __bu_g__, __B_U__G__, __BuG_ = B__uG["Transform"]:GetWorldPosition()
                    if TheWorld["Map"]:IsGardenAtPoint(__bu_g__, __B_U__G__, __BuG_) then
                        B__uG["components"]["playercontroller"]:EnableMapControls((35 + 144 - 66 - 129 ~= -16))
                    end
                end
            )
        end
    end
end
local function __B__U_G(__Bu_g, BUG, _b__U__g_)
    _b__U__g_["sg"]["statemem"]["teleportarrivestate"] = "idle"
end
local function _b_UG__(b_U_G)
    b_U_G:RemoveTag "no_access"
    b_U_G["AnimState"]:Hide "hay"
end
local function _b_UG_(bu__g)
    bu__g:AddTag "no_access"
    bu__g["AnimState"]:Show "hay"
end
local function B__u__G__(_B__ug_)
    return (_B__ug_:HasTag "no_access" and "NO_ACCESS") or nil
end
local function _b_U__g(_Bu_g__, __B__u_g__)
    if _Bu_g__:HasTag "no_access" then
        __B__u_g__["sealed"] = (154 * 52 + 222 + 41 ~= 8276)
    else
        __B__u_g__["sealed"] =
            (false and not true and false and not true or not false and not false and false or false or
            not true and not false and not false and false)
    end
end
local function __b_U__G_(_b_uG__, b_UG__)
    if b_UG__ ~= nil then
        if b_UG__["sealed"] then
            _b_uG__["components"]["teleporter"]:SetEnabled((469 * 75 * 168 - 220 * 41 ~= 5900380))
            _b_UG_(_b_uG__)
        end
    end
end
local function __B_u__g_()
    local _B_Ug__ = CreateEntity()
    _B_Ug__["entity"]:AddTransform()
    _B_Ug__["entity"]:AddAnimState()
    _B_Ug__["entity"]:AddSoundEmitter()
    _B_Ug__["entity"]:AddNetwork()
    MakeObstaclePhysics(_B_Ug__, 1)
    _B_Ug__["AnimState"]:SetBank "dsc_exit"
    _B_Ug__["AnimState"]:SetBuild "dsc_exit"
    _B_Ug__["AnimState"]:SetDeltaTimeMultiplier(0.5)
    _B_Ug__["AnimState"]:PlayAnimation("idle", (279 * 291 - 176 == 81013))
    _B_Ug__["AnimState"]:Hide "hay"
    _B_Ug__["Transform"]:SetScale(0.9, 0.9, 0.9)
    _B_Ug__:AddTag "garden_exit"
    _B_Ug__:AddTag "garden_part"
    _B_Ug__:AddTag "nonpackable"
    _B_Ug__:AddTag "antlion_sinkhole_blocker"
    _B_Ug__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _B_Ug__
    end
    _B_Ug__["Physics"]:SetCollisionCallback(__buG__)
    _B_Ug__:AddComponent "inspectable"
    _B_Ug__["components"]["inspectable"]["getstatus"] = B__u__G__
    _B_Ug__:AddComponent "teleporter"
    _B_Ug__["components"]["teleporter"]["onActivate"] = bU__G__
    _B_Ug__["components"]["teleporter"]["onActivateByOther"] = __B__U_G
    _B_Ug__["components"]["teleporter"]["offset"] = 0
    _B_Ug__["components"]["teleporter"]["travelcameratime"] = 3 * FRAMES
    _B_Ug__["components"]["teleporter"]["travelarrivetime"] = 29 * FRAMES
    _B_Ug__:AddComponent "childspawner"
    _B_Ug__["components"]["childspawner"]:SetRegenPeriod(TUNING["OCEANFISH_SHOAL"]["CHILD_REGENPERIOD"])
    _B_Ug__["components"]["childspawner"]:SetSpawnPeriod(TUNING["OCEANFISH_SHOAL"]["CHILD_SPAWNPERIOD"])
    _B_Ug__["components"]["childspawner"]:SetMaxChildren(TUNING["OCEANFISH_SHOAL"]["MAX_CHILDREN"])
    _B_Ug__["components"]["childspawner"]:SetSpawnedFn(_b__ug__)
    _B_Ug__["components"]["childspawner"]:StartRegen()
    _B_Ug__["components"]["childspawner"]["spawnradius"] = TUNING["OCEANFISH_SHOAL"]["SPAWNRADIUS"]
    _B_Ug__["components"]["childspawner"]["childname"] = "oceanfish_medium_6"
    _B_Ug__["components"]["childspawner"]:StopSpawning()
    _B_Ug__["OnEntitySleep"] = B_Ug
    _B_Ug__["OnEntityWake"] = b_U__G__
    _B_Ug__:WatchWorldState("season", __b__u_g__)
    _B_Ug__:ListenForEvent("can_tel", _b_UG__)
    _B_Ug__:ListenForEvent("cannot_tel", _b_UG_)
    _B_Ug__["OnSave"] = _b_U__g
    _B_Ug__["OnLoad"] = __b_U__G_
    MakeHauntableLaunch(_B_Ug__)
    return _B_Ug__
end
return Prefab("deepseacave_exit", __B_u__g_, __BU__g__)
