local _bu_G = {Asset("ANIM", "anim/atrium_gate_overload_fx.zip")}
local _Bu__g__ = {}
local function _BU_g__()
    local _b_U__g_ = CreateEntity()
    _b_U__g_["entity"]:AddTransform()
    _b_U__g_["entity"]:AddAnimState()
    _b_U__g_["entity"]:AddSoundEmitter()
    _b_U__g_["entity"]:AddNetwork()
    _b_U__g_["AnimState"]:SetBuild "deer_ice_burst"
    _b_U__g_["AnimState"]:SetBank "deer_ice_burst"
    _b_U__g_["AnimState"]:PlayAnimation "loop"
    _b_U__g_["AnimState"]:SetMultColour(0, 0, 0, 1)
    _b_U__g_["AnimState"]:SetSortOrder(3)
    _b_U__g_:AddTag "NOCLICK"
    _b_U__g_:AddTag "FX"
    _b_U__g_["Transform"]:SetScale(2.5, 2.5, 2.5)
    _b_U__g_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _b_U__g_
    end
    _b_U__g_:SetStateGraph "SGminotaurteleport"
    return _b_U__g_
end
return Prefab("minotaurteleport_fx", _BU_g__, _bu_G, _Bu__g__)
