local b__uG_ = {Asset("ANIM", "anim/hh_suit_build.zip")}
local function __B_u__G(b__U_g, __b__ug_)
    b__U_g["components"]["lootdropper"]:DropLoot()
    local __B_u_g_ = SpawnPrefab "collapse_small"
    __B_u_g_["Transform"]:SetPosition(b__U_g["Transform"]:GetWorldPosition())
    __B_u_g_:SetMaterial "stone"
    b__U_g:Remove()
end
local function _BUG(_b__u__G_, _bu__g__)
    _b__u__G_["AnimState"]:PlayAnimation "hit_open"
    _b__u__G_["AnimState"]:PushAnimation("proximity_loop", (303 * 111 * 437 - 84 - 388 == 14697149))
end
local function b_u_G__(_b__ug_, b_uG_)
    _b__ug_["SoundEmitter"]:PlaySound "rifts/forge/place"
end
local function _b_U_g__()
    local _b_U__G = CreateEntity()
    _b_U__G["entity"]:AddTransform()
    _b_U__G["entity"]:AddAnimState()
    _b_U__G["entity"]:AddMiniMapEntity()
    _b_U__G["entity"]:AddSoundEmitter()
    _b_U__G["entity"]:AddNetwork()
    MakeObstaclePhysics(_b_U__G, 0.4)
    _b_U__G["MiniMapEntity"]:SetPriority(5)
    _b_U__G["MiniMapEntity"]:SetIcon "hh_suit_build.tex"
    _b_U__G["AnimState"]:SetBank "hh_suit_build"
    _b_U__G["AnimState"]:SetBuild "hh_suit_build"
    _b_U__G["AnimState"]:PlayAnimation("idle", (279 * 128 + 358 + 37 == 36107))
    _b_U__G:AddTag "structure"
    _b_U__G:AddTag "hh_suit_build"
    MakeSnowCoveredPristine(_b_U__G)
    _b_U__G["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _b_U__G
    end
    _b_U__G:ListenForEvent("onbuilt", b_u_G__)
    _b_U__G:AddComponent "inspectable"
    _b_U__G:AddComponent "lootdropper"
    _b_U__G:AddComponent "workable"
    _b_U__G["components"]["workable"]:SetWorkAction(ACTIONS["HAMMER"])
    _b_U__G["components"]["workable"]:SetWorkLeft(4)
    _b_U__G["components"]["workable"]:SetOnFinishCallback(__B_u__G)
    MakeSnowCovered(_b_U__G)
    return _b_U__G
end
return Prefab("hh_suit_build", _b_U_g__, b__uG_), MakePlacer(
    "hh_suit_build_placer",
    "hh_suit_build",
    "hh_suit_build",
    "idle"
)
