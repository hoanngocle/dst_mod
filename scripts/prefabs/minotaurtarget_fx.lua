local _bu_G = {Asset("ANIM", "anim/fx_wathgrithr_buff.zip")}
local _Bu__g__ = {}
local function _BU_g__()
    local _b_U__g_ = CreateEntity()
    _b_U__g_["entity"]:AddTransform()
    _b_U__g_["entity"]:AddAnimState()
    _b_U__g_["entity"]:AddSoundEmitter()
    _b_U__g_["entity"]:AddNetwork()
    _b_U__g_["AnimState"]:SetBuild "fx_wathgrithr_buff"
    _b_U__g_["AnimState"]:SetBank "fx_wathgrithr_buff"
    _b_U__g_["AnimState"]:PlayAnimation "quote_electric"
    _b_U__g_["AnimState"]:SetSortOrder(3)
    _b_U__g_["AnimState"]:SetMultColour(0, 0, 0, 1)
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
return Prefab("minotaurtarget_fx", _BU_g__, _bu_G, _Bu__g__)
