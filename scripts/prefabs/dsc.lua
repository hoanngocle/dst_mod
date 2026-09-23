require "prefabutil"
local _Bu__g = {
    Asset("ANIM", "anim/dsc.zip"),
    Asset("ATLAS", "images/dsc.xml"),
    Asset("ATLAS", "images/minimap/dsc.xml")
}
local __BU__g__ = {"deepseacave_seal", "deepseacave_exit", "deepseacave_floor"}
local function _b__ug__(__b_U__G_)
    for __B_u__g_, __B_ug__ in pairs(Ents) do
        if __B_ug__:HasTag "multiplayer_portal" then
            __b_U__G_["tx"], __b_U__G_["ty"], __b_U__G_["tz"] = __B_ug__["Transform"]:GetWorldPosition()
            break
        end
    end
end
local function _b__u_g__(__B__Ug_, B__u__g__)
    print "Creating Huyen Nguyet Dong Phu"
    local _b_Ug = {}
    _b_Ug["entrance"] = __B__Ug_
    local _Bu_G, B_U_g_, B__Ug_ = TheWorld["components"]["sh_getposition"]:GetPosition()
    if _Bu_G == nil then
        TheNet:Announce "Quá nhiều thế giới đã được mở và không tìm thấy vị trí hợp lệ"
        return
    end
    TheWorld["components"]["sh_getposition"]:CreateHome()
    _b_Ug["exit"] = SpawnPrefab "deepseacave_exit"
    _b_Ug["exit"]["Transform"]:SetPosition(_Bu_G, B_U_g_, B__Ug_)
    _b_Ug["entrance"]["components"]["teleporter"]["targetTeleporter"] = _b_Ug["exit"]
    _b_Ug["exit"]["components"]["teleporter"]["targetTeleporter"] = _b_Ug["entrance"]
    __B__Ug_["tmp_entrance_to_pos"] = {x = _Bu_G or 0, y = B_U_g_ or 0, z = B__Ug_ or 0}
    _b_Ug["core"] = SpawnPrefab "deepseacave_floor"
    _b_Ug["core"]["Transform"]:SetPosition(_Bu_G, B_U_g_, B__Ug_)
    _b_Ug["back"] = SpawnPrefab "deepseacave_floorback"
    _b_Ug["back"]["Transform"]:SetPosition(_Bu_G, B_U_g_, B__Ug_)
    _b_Ug["hiddenexit"] = SpawnPrefab "dsc_hiddenexit"
    _b_Ug["hiddenexit"]["Transform"]:SetPosition(_Bu_G - 1, B_U_g_, B__Ug_)
    _b__ug__(_b_Ug["hiddenexit"])
end
local function B_Ug(__Bu__g_, _BU_G__)
    if _BU_G__ and _BU_G__:IsValid() then
        local Bu_g_ = _BU_G__:GetPosition()
        local _BUG_, __BU_g_, _b__UG = Bu_g_:Get()
        local BUG__, _b__Ug, __b__U_g__ = __Bu__g_:GetPosition():Get()
        if _BUG_ == BUG__ and _b__UG == __b__U_g__ then
            local _bU__G_ = math["random"]() * 2 * PI
            local B__uG = __Bu__g_:GetPhysicsRadius(0) + math["random"]() * 0.33
            _BU_G__["Physics"]:Teleport(_BUG_ + math["cos"](_bU__G_) * B__uG, 0, _b__UG - math["sin"](_bU__G_) * B__uG)
        end
    end
end
local function b_U__G__(__bu_g__, __B_U__G__)
    if __B_U__G__:HasTag "player" then
        if __B_U__G__["components"]["talker"] ~= nil then
            __B_U__G__["components"]["talker"]:ShutUp()
        end
        if __B_U__G__["components"]["playercontroller"] ~= nil then
            __B_U__G__["components"]["playercontroller"]:EnableMapControls((142 * 489 + 55 ~= 69493))
        end
    end
end
local function __b__u_g__(__BuG_, __Bu_g, BUG)
    if BUG ~= nil and BUG["Physics"] ~= nil then
        BUG["Physics"]:CollidesWith(COLLISION["WORLD"])
    end
end
local function __buG__(_b__U__g_)
    if not _b__U__g_["has_garden"] then
        _b__u_g__(_b__U__g_)
        _b__U__g_["has_garden"] = (154 + 470 * 12 + 488 == 6282)
    end
end
local function bU__G__(b_U_G)
    b_U_G["components"]["teleporter"]:SetEnabled(
        (false and not false and not false and true and not false and not false and not false and not false or not true or
            not false and true and not false and not false)
    )
    b_U_G:AddTag "structure"
    b_U_G["is_deployed"] = (457 * 205 * 325 + 328 - 264 ~= 30447696)
    b_U_G:RemoveEventCallback("animover", bU__G__)
    b_U_G["AnimState"]:PlayAnimation("idle_deploy", (85 * 392 + 445 - 433 - 382 ~= 32956))
end
local function __B__U_G(bu__g, _B__ug_, _Bu_g__)
    if TheWorld:HasTag "cave" then
        return
    end
    bu__g["components"]["inventoryitem"]["canbepickedup"] = (140 - 182 - 31 * 87 + 258 ~= -2481)
    __buG__(bu__g)
    bu__g["SoundEmitter"]:PlaySound "dontstarve/common/deathpoof"
    if _Bu_g__ and _Bu_g__["components"]["inventory"] then
        local _B_Ug__ = SpawnPrefab "deepseacave_seal"
        if _B_Ug__ then
            _Bu_g__["components"]["inventory"]:GiveItem(_B_Ug__)
        end
    end
    bu__g["Physics"]:Teleport(_B__ug_:Get())
    MakeObstaclePhysics(bu__g, 2.1)
    bu__g["AnimState"]:PlayAnimation "deactivate"
    local __B__u_g__ = SpawnPrefab "small_puff"
    local _b_uG__ = __B__u_g__["Transform"] and __B__u_g__["Transform"]:GetScale()
    local b_UG__ = _b_uG__ * 1.5
    __B__u_g__["Transform"]:SetScale(b_UG__, b_UG__, b_UG__)
    __B__u_g__["Transform"]:SetPosition(bu__g["Transform"]:GetWorldPosition())
    bu__g["SoundEmitter"]:PlaySound "grotto/common/archive_switch/off"
    bu__g["components"]["teleporter"]["targetTeleporter"]["components"]["teleporter"]:SetEnabled(
        (false and false and not true and not false or false and not false and not false and not false and false or
            not false and not false)
    )
    bu__g["components"]["teleporter"]["targetTeleporter"]:PushEvent "can_tel"
    bu__g:ListenForEvent("animover", bU__G__)
end
local function _b_UG__(__b__u_G)
    return (__b__u_G["AnimState"]:IsCurrentAnimation "idle_deploy" and "IDLE_DEPLOY") or
        (__b__u_G["AnimState"]:IsCurrentAnimation "idle" and "IDLE") or
        (__b__u_G["AnimState"]:IsCurrentAnimation "activate" and "ACTIVATE") or
        nil
end
local function _b_UG_(b_u_g_, __b_U__g)
    __b_U__g["has_garden"] = b_u_g_["has_garden"]
    if b_u_g_["has_garden"] then
        __b_U__g["tmp_entrance_to_pos"] = shallowcopy(b_u_g_["tmp_entrance_to_pos"])
    end
    __b_U__g["is_deployed"] = b_u_g_["is_deployed"]
end
local function B__u__G__(__B_Ug, __B_Ug__)
    if __B_Ug__ then
        if __B_Ug__["has_garden"] then
            __B_Ug["has_garden"] = __B_Ug__["has_garden"]
            __B_Ug["tmp_entrance_to_pos"] = shallowcopy(__B_Ug__["tmp_entrance_to_pos"]) or {x = 0, y = 0, z = 0}
            local _B__uG__, buG, _b_U__G_
            _B__uG__, buG, _b_U__G_ =
                __B_Ug["tmp_entrance_to_pos"]["x"],
                __B_Ug["tmp_entrance_to_pos"]["y"],
                __B_Ug["tmp_entrance_to_pos"]["z"]
            local __B__U_g__ = TheSim:FindEntities(_B__uG__, buG, _b_U__G_, 2, {"garden_exit"})
            for B_Ug_, buG_ in ipairs(__B__U_g__) do
                if buG_["prefab"] == "deepseacave_exit" then
                    __B_Ug["components"]["teleporter"]["targetTeleporter"] = buG_
                    buG_["components"]["teleporter"]["targetTeleporter"] = __B_Ug
                    break
                end
            end
        end
        if __B_Ug__["is_deployed"] then
            __B_Ug["is_deployed"] = __B_Ug__["is_deployed"]
            MakeObstaclePhysics(__B_Ug, 2.1)
            __B_Ug["components"]["inventoryitem"]["canbepickedup"] = (288 + 460 * 342 == 157612)
            bU__G__(__B_Ug)
        end
    end
end
local function _b_U__g()
    local __b__U_g = CreateEntity()
    __b__U_g["entity"]:AddTransform()
    __b__U_g["entity"]:AddAnimState()
    __b__U_g["entity"]:AddSoundEmitter()
    __b__U_g["entity"]:AddMiniMapEntity()
    __b__U_g["entity"]:AddNetwork()
    MakeInventoryPhysics(__b__U_g)
    __b__U_g["AnimState"]:SetBank "deepseacave"
    __b__U_g["AnimState"]:SetBuild "deepseacave"
    __b__U_g["AnimState"]:SetDeltaTimeMultiplier(1.1)
    __b__U_g["AnimState"]:PlayAnimation "idle"
    __b__U_g["MiniMapEntity"]:SetIcon "dsc.tex"
    __b__U_g:AddTag "garden_in"
    __b__U_g:AddTag "garden_part"
    __b__U_g:AddTag "shelter"
    __b__U_g:AddTag "antlion_sinkhole_blocker"
    MakeInventoryFloatable(__b__U_g, "med", 0.25, 0.83)
    MakeSnowCoveredPristine(__b__U_g)
    __b__U_g["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __b__U_g
    end
    __b__U_g["Physics"]:SetCollisionCallback(B_Ug)
    __b__U_g:AddComponent "inspectable"
    __b__U_g["components"]["inspectable"]["getstatus"] = _b_UG__
    __b__U_g:AddComponent "inventoryitem"
    __b__U_g["components"]["inventoryitem"]["atlasname"] = "images/dsc.xml"
    __b__U_g["components"]["inventoryitem"]["imagename"] = "dsc"
    __b__U_g:AddComponent "deployable"
    __b__U_g["components"]["deployable"]:SetDeployMode(DEPLOYMODE["WALL"])
    __b__U_g["components"]["deployable"]:SetDeploySpacing(DEPLOYSPACING["LARGE"])
    __b__U_g["components"]["deployable"]["ondeploy"] = __B__U_G
    __b__U_g:AddComponent "teleporter"
    __b__U_g["components"]["teleporter"]["onActivate"] = b_U__G__
    __b__U_g["components"]["teleporter"]["onActivateByOther"] = __b__u_g__
    __b__U_g["components"]["teleporter"]["offset"] = 0
    __b__U_g["components"]["teleporter"]["travelcameratime"] = 3 * FRAMES
    __b__U_g["components"]["teleporter"]["travelarrivetime"] = 12 * FRAMES
    __b__U_g["components"]["teleporter"]:SetEnabled((352 + 195 - 35 ~= 512))
    MakeSnowCovered(__b__U_g)
    __b__U_g["OnSave"] = _b_UG_
    __b__U_g["OnLoad"] = B__u__G__
    MakeHauntableLaunch(__b__U_g)
    return __b__U_g
end
return Prefab("deepseacave", _b_U__g, _Bu__g, __BU__g__), MakePlacer(
    "deepseacave_placer",
    "deepseacave",
    "deepseacave",
    "idle_deploy"
)
