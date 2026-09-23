local _bU_g__ = {
    Asset("ANIM", "anim/dsc_floorback.zip"),
    Asset("ANIM", "anim/dsc_floorback1.zip"),
    Asset("ANIM", "anim/dsc_floorbackquag.zip")
}
local function _b__U__g(__B_u__G)
    print "!!!!JLSDJOIAOPIFNOSKN"
    __B_u__G["AnimState"]:PlayAnimation "eat_item"
    __B_u__G:DoTaskInTime(
        7,
        function()
            __B_u__G["AnimState"]:PlayAnimation "deep"
        end
    )
end
local function b__uG_()
    local _BUG = CreateEntity()
    _BUG["entity"]:AddTransform()
    _BUG["entity"]:AddAnimState()
    _BUG["entity"]:AddNetwork()
    _BUG["AnimState"]:SetBank "dsc_floorback"
    _BUG["AnimState"]:SetBuild "dsc_floorback1"
    _BUG["AnimState"]:AddOverrideBuild "dsc_floorbackquag"
    _BUG["AnimState"]:SetOrientation(ANIM_ORIENTATION["OnGround"])
    _BUG["AnimState"]:SetLayer(LAYER_BACKGROUND)
    _BUG["AnimState"]:SetSortOrder(-2)
    _BUG["AnimState"]:PlayAnimation "deep"
    _BUG["scale"] = 4.1 / 7 * 13
    _BUG["AnimState"]:SetScale(_BUG["scale"], _BUG["scale"])
    _BUG["AnimState"]:OverrideShade(1)
    _BUG:AddTag "NOBLOCK"
    _BUG:AddTag "NOCLICK"
    _BUG:AddTag "garden_tile"
    _BUG:AddTag "garden_part"
    _BUG:AddTag "antlion_sinkhole_blocker"
    _BUG:AddTag "nonpackable"
    _BUG:AddTag "deepseacave_floorback"
    _BUG:ListenForEvent("change_back", _b__U__g)
    _BUG["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return _BUG
    end
    return _BUG
end
return Prefab("deepseacave_floorback", b__uG_, _bU_g__)
