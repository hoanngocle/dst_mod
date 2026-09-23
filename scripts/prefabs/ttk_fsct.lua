require "prefabutil"

local assets = {
    Asset("ANIM", "anim/ttk_fsct.zip"),
    Asset("ATLAS", "images/map_icons/ttk_fsct.xml"),
    Asset("IMAGE", "images/map_icons/ttk_fsct.tex"),
}

local function OnHaunt(inst, haunter)
    if haunter == nil or not haunter:IsValid() or not haunter:HasTag("playerghost") then
        return false
    end
    TheWorld:PushEvent("ms_sendlightningstrike", inst:GetPosition())
    haunter:PushEvent("respawnfromghost", {source = inst})
    return true
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank("xd_fsct")
    inst.AnimState:SetBuild("xd_fsct")
    inst.AnimState:PlayAnimation("idle")
    inst.MiniMapEntity:SetIcon("ttk_fsct.tex")
    inst:AddTag("structure")
    MakeSnowCoveredPristine(inst)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    MakeSnowCovered(inst)
    -- No charges, recharge timer or haunt cooldown: all ghosts can use the altar.
    MakeHauntable(inst, 0, 0)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)
    return inst
end

return Prefab("ttk_fsct", fn, assets),
    MakePlacer("ttk_fsct_placer", "xd_fsct", "xd_fsct", "idle")
