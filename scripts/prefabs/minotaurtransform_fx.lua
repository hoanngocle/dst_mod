local _bu_G = {Asset("ANIM", "anim/shadow_rook.zip")}
local _Bu__g__ = {}
local function _BU_g__()
    local _b_U__g_ = CreateEntity()
    _b_U__g_["entity"]:AddTransform()
    _b_U__g_["entity"]:AddAnimState()
    _b_U__g_["entity"]:AddSoundEmitter()
    _b_U__g_["entity"]:AddNetwork()
    _b_U__g_["AnimState"]:SetBuild "shadow_rook"
    _b_U__g_["AnimState"]:SetBank "shadow_rook"
    _b_U__g_["AnimState"]:PlayAnimation "transform"
    _b_U__g_["AnimState"]:SetSortOrder(3)
    _b_U__g_["AnimState"]:HideSymbol "bottom_head"
    _b_U__g_["AnimState"]:HideSymbol "top_head"
    _b_U__g_["AnimState"]:HideSymbol "big_horn"
    _b_U__g_["AnimState"]:HideSymbol "mouth_space"
    _b_U__g_["AnimState"]:HideSymbol "base"
    _b_U__g_["AnimState"]:HideSymbol "small_horn_rgt"
    _b_U__g_["AnimState"]:HideSymbol "small_horn_lft"
    _b_U__g_:AddTag "NOCLICK"
    _b_U__g_:AddTag "FX"
    _b_U__g_["Transform"]:SetScale(1.2, 1.2, 1.2)
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
return Prefab("minotaurtransform_fx", _BU_g__, _bu_G, _Bu__g__)
