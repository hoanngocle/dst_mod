local _bu_G = {Asset("ANIM", "anim/atrium_gate_overload_fx.zip")}
local _Bu__g__ = {}
local function _BU_g__()
    local _b_U__g_ = CreateEntity()
    _b_U__g_["entity"]:AddTransform()
    _b_U__g_["entity"]:AddAnimState()
    _b_U__g_["entity"]:AddSoundEmitter()
    _b_U__g_["entity"]:AddNetwork()
    _b_U__g_["AnimState"]:SetBuild "atrium_gate"
    _b_U__g_["AnimState"]:SetBank "atrium_gate"
    _b_U__g_["AnimState"]:PlayAnimation "overload_pre"
    _b_U__g_["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
    _b_U__g_["AnimState"]:SetLayer(LAYER_BACKGROUND)
    _b_U__g_["AnimState"]:SetSortOrder(3)
    _b_U__g_["AnimState"]:SetMultColour(0, 0, 0, 1)
    _b_U__g_["AnimState"]:HideSymbol "key"
    _b_U__g_["AnimState"]:HideSymbol "atrium_gate01"
    _b_U__g_["AnimState"]:HideSymbol "atrium_gate01_0"
    _b_U__g_["AnimState"]:HideSymbol "atrium_gate01_1"
    _b_U__g_["AnimState"]:HideSymbol "atrium_gate01_2"
    _b_U__g_["AnimState"]:HideSymbol "atrium_gate01_3"
    _b_U__g_["AnimState"]:HideSymbol "atrium_gate01_4"
    _b_U__g_["AnimState"]:HideSymbol "atrium_gate01_5"
    _b_U__g_:AddTag "NOCLICK"
    _b_U__g_:AddTag "FX"
    _b_U__g_["Transform"]:SetScale(1.3, 1.3, 1.3)
    _b_U__g_["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _b_U__g_
    end
    local _B__ug, __B_u_G__, _bu_g_ = _b_U__g_["Transform"]:GetWorldPosition()
    _b_U__g_:SetStateGraph "SGminotaurteleportpost"
    return _b_U__g_
end
return Prefab("minotaurteleportpost_fx", _BU_g__, _bu_G, _Bu__g__)
