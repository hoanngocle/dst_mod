local assets_stool = {
    Asset("ANIM", "anim/vault_chair_stool.zip"),
    Asset("ANIM", "anim/ttk_stool.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_stool.xml")
}

local function SetVariation(inst, variation)
    if inst.variation ~= variation then
        if inst.variation > 1 then
            inst.AnimState:Hide("MOSS" .. tostring(inst.variation - 1))
        end
        if variation > 1 then
            inst.AnimState:Show("MOSS" .. tostring(variation - 1))
        end
        inst.variation = variation
    end
end

local function OnSave(inst, data)
    data.variation = inst.variation ~= 1 and inst.variation or nil
end

local function OnLoad(inst, data, ents)
    if data and data.variation then
        inst:SetVariation(data.variation)
    end
end

local function DisplayNameFn(inst)
    return STRINGS.NAMES.TTK_STOOL
end

local function table_AbleToAcceptDecor(inst, item, giver)
    return item ~= nil
end

local function table_OnDecorGiven(inst, item, giver)
    if item then
        inst.SoundEmitter:PlaySound("wintersfeast2019/winters_feast/table/food")
        if item.Physics then
            item.Physics:SetActive(false)
        end
        if item.Follower then
            item.Follower:FollowSymbol(inst.GUID, "swap_object")
        end
    end
end

local function table_OnDecorTaken(inst, item)
    
    if item then
        if item.Physics then
            item.Physics:SetActive(true)
        end
        if item.Follower then
            item.Follower:StopFollowing()
        end
    end
end

local function stool_GetStatus(inst)
    return inst.components.sittable:IsOccupied() and "OCCUPIED" or nil
end

local function stool_DescriptionFn(inst) 
    inst.components.inspectable.nameoverride = inst.components.sittable:IsOccupied() and "stone_chair" or "relic"
    
end

local HEAL_INTERVAL = 10
local HEAL_HEALTH = 5
local HEAL_SANITY = 2
local HEAL_HUNGER = 2

local function StartHeal(inst)
    if inst._sittask then
        inst._sittask:Cancel()
        inst._sittask = nil
    end
    local occ = inst.components.sittable and inst.components.sittable.occupier
    if occ and occ:IsValid() then
        inst._sittask =
            inst:DoPeriodicTask(
            HEAL_INTERVAL,
            function()
                if not (occ and occ:IsValid()) then
                    if inst._sittask then
                        inst._sittask:Cancel()
                        inst._sittask = nil
                    end
                    return
                end
                if occ.components and occ.components.health and not occ.components.health:IsDead() then
                    occ.components.health:DoDelta(HEAL_HEALTH, false, "sit_heal")
                end
                if occ.components and occ.components.sanity then
                    occ.components.sanity:DoDelta(HEAL_SANITY)
                end
                if occ.components and occ.components.hunger then
                    occ.components.hunger:DoDelta(HEAL_HUNGER)
                end
            end
        )
    end
end

local function StopHeal(inst)
    if inst._sittask then
        inst._sittask:Cancel()
        inst._sittask = nil
    end
end

local function fn_stool()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:SetDeploySmartRadius(0.875) 

    MakeObstaclePhysics(inst, 0.25)

    inst.Transform:SetFourFaced()

    inst:AddTag("structure")
    inst:AddTag("faced_chair")
    inst:AddTag("rotatableobject")

    inst.AnimState:SetBank("vault_chair_stool")
    inst.AnimState:SetBuild("xd_stool")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(-1)

    for i = 1, 3 do
        inst.AnimState:Hide("MOSS" .. tostring(i))
    end

    inst.displaynamefn = DisplayNameFn

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("sittable")

    inst:ListenForEvent(
        "becomeunsittable",
        function()
            StartHeal(inst)
        end
    )
    inst:ListenForEvent(
        "becomesittable",
        function()
            StopHeal(inst)
        end
    )
    inst:ListenForEvent(
        "onremove",
        function()
            StopHeal(inst)
        end
    )

    inst:AddComponent("savedrotation")
    inst.components.savedrotation.dodelayedpostpassapply = true

    MakeHauntable(inst)

    inst.variation = 1
    inst.SetVariation = SetVariation
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("ttk_stool", fn_stool, assets_stool), MakePlacer(
    "ttk_stool_placer",
    "vault_chair_stool",
    "xd_stool",
    "idle",
    nil,
    nil,
    nil,
    nil,
    15,
    "four"
)
