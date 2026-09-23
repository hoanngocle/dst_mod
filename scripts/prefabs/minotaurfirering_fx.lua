local _bu_G = {}
local _Bu__g__ = {}
local function _BU_g__()
    local _b_U__g_ = CreateEntity()
    _b_U__g_["entity"]:AddTransform()
    _b_U__g_["entity"]:AddAnimState()
    _b_U__g_["entity"]:AddSoundEmitter()
    _b_U__g_["entity"]:AddNetwork()
    _b_U__g_["AnimState"]:SetBuild "dragonfly_ring_fx"
    _b_U__g_["AnimState"]:SetBank "dragonfly_ring_fx"
    _b_U__g_["AnimState"]:PlayAnimation "idle"
    _b_U__g_["AnimState"]:SetFinalOffset(-1)
    _b_U__g_["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
    _b_U__g_["AnimState"]:SetLayer(LAYER_BACKGROUND)
    _b_U__g_["AnimState"]:SetSortOrder(3)
    _b_U__g_["AnimState"]:SetMultColour(0, 0, 0, 1)
    _b_U__g_:AddTag "NOCLICK"
    _b_U__g_:AddTag "FX"
    _b_U__g_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _b_U__g_
    end
    _b_U__g_:ListenForEvent(
        "animover",
        function(_b_U__g_)
            _b_U__g_:Remove()
        end
    )
    return _b_U__g_
end
return Prefab("minotaurfirering_fx", _BU_g__, _bu_G, _Bu__g__)
