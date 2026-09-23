local _bU_g__ = {Asset("ANIM", "anim/dsc_seal.zip"), Asset("ATLAS", "images/dsc_seal.xml")}
local _b__U__g = {}
local function b__uG_()
    local __B_u__G = CreateEntity()
    __B_u__G["entity"]:AddTransform()
    __B_u__G["entity"]:AddAnimState()
    __B_u__G["entity"]:AddSoundEmitter()
    __B_u__G["entity"]:AddNetwork()
    MakeInventoryPhysics(__B_u__G)
    __B_u__G["AnimState"]:SetBank "shj_seal"
    __B_u__G["AnimState"]:SetBuild "shj_seal"
    __B_u__G["AnimState"]:PlayAnimation "idle"
    __B_u__G["entity"]:SetPristine()
    MakeInventoryFloatable(__B_u__G, "med", 0.25, 0.83)
    if not TheWorld["ismastersim"] then
        return __B_u__G
    end
    __B_u__G:AddComponent "inspectable"
    __B_u__G:AddComponent "inventoryitem"
    __B_u__G["components"]["inventoryitem"]["atlasname"] = "images/dsc_seal.xml"
    __B_u__G["components"]["inventoryitem"]["imagename"] = "dsc_seal"
    MakeHauntableLaunchAndSmash(__B_u__G)
    return __B_u__G
end
return Prefab("deepseacave_seal", b__uG_, _bU_g__, _b__U__g)
