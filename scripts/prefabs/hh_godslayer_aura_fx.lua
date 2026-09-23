local PRE_ANIM = "bernie_fire_reg_pre"
local LOOP_ANIM = "bernie_fire_reg"
local POST_ANIM = "bernie_fire_reg_pst"

local function OnAnimOver(inst)
    if inst.AnimState:IsCurrentAnimation(POST_ANIM) then
        inst:Remove()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("aura_dark1")
    inst.AnimState:SetBuild("aura_dark1")
    inst.AnimState:SetMultColour(107 / 255, 52 / 255, 124 / 255, 1)
    inst.Transform:SetScale(0.35, 0.35, 0.35)
    inst.AnimState:SetFinalOffset(-3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    function inst:StartFresh()
        self.AnimState:PlayAnimation(PRE_ANIM, false)
        self.AnimState:PushAnimation(LOOP_ANIM, true)
    end

    function inst:StartRestore()
        self.AnimState:PlayAnimation(LOOP_ANIM, true)
    end

    function inst:PlayPost()
        if self:IsValid() and not self.AnimState:IsCurrentAnimation(POST_ANIM) then
            self.AnimState:PlayAnimation(POST_ANIM, false)
        end
    end

    inst:ListenForEvent("animover", OnAnimOver)
    return inst
end

return Prefab("hh_godslayer_aura_fx", fn)
