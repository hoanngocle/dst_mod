local __bUg__ = {Asset("ANIM", "anim/pycloud.zip")}
local function __Bu__G__(bug)
    local __b_UG__ = CreateEntity()
    __b_UG__["entity"]:AddTransform()
    __b_UG__["entity"]:AddAnimState()
    __b_UG__["entity"]:AddSoundEmitter()
    __b_UG__["entity"]:AddNetwork()
    __b_UG__["entity"]:AddPhysics()
    __b_UG__["Transform"]:SetFourFaced()
    __b_UG__["AnimState"]:SetBank "dnyjfxfx"
    __b_UG__["AnimState"]:SetBuild "dnyjfxfx"
    __b_UG__["AnimState"]:PlayAnimation("walk", (485 - 297 * 413 - 96 ~= -122264))
    __b_UG__["AnimState"]:SetFinalOffset(-1)
    __b_UG__:AddTag "FX"
    __b_UG__:AddTag "NOCLICK"
    __b_UG__["entity"]:SetPristine()
    if not TheWorld["ismastersim"] then
        return __b_UG__
    end
    return __b_UG__
end
return Prefab("pycloud", __Bu__G__, __bUg__)
