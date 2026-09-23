local function SpawnCollapseFx(inst)
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("metal")
    end
end

local function ShouldCollapse(inst)
    local container = inst.components.container
    if container == nil or not container.infinitestacksize then
        return false
    end

    local overstacks = 0
    for _, item in pairs(container.slots) do
        local stackable = item.components.stackable
        if stackable ~= nil then
            local maxsize = stackable.originalmaxsize or stackable.maxsize
            overstacks = overstacks + math.ceil(stackable:StackSize() / maxsize)
            if overstacks >= TUNING.COLLAPSED_CHEST_EXCESS_STACKS_THRESHOLD then
                return true
            end
        end
    end
    return false
end

local function ConvertToCollapsed(inst, drop_loot)
    local pile = SpawnPrefab("collapsed_treasurechest")
    if pile == nil or pile.SetChest == nil then
        if pile ~= nil then
            pile:Remove()
        end
        inst.components.workable:SetWorkLeft(1)
        return false
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    if drop_loot and inst.components.lootdropper ~= nil then
        inst.components.lootdropper:DropLoot()
    end
    inst.components.container:Close()
    inst.components.workable:SetWorkLeft(3)
    pile.Transform:SetPosition(x, y, z)
    pile:SetChest(inst, false)
    return true
end

local function DefaultHammered(inst)
    if inst.components.lootdropper ~= nil then
        inst.components.lootdropper:DropLoot()
    end
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    SpawnCollapseFx(inst)
    inst:Remove()
end

local function OnUpgradedHit(inst)
    if inst.components.container ~= nil then
        inst.components.container:DropEverything(nil, true)
        inst.components.container:Close()
    end
    inst.AnimState:PlayAnimation("idle")
end

local function OnUpgradedHammered(inst)
    local container = inst.components.container
    if container ~= nil then
        container:DropEverything(nil, true)
    end

    if ShouldCollapse(inst) then
        if TheWorld.Map:IsPassableAtPoint(inst.Transform:GetWorldPosition()) then
            container:DropEverythingUpToMaxStacks(TUNING.COLLAPSED_CHEST_MAX_EXCESS_STACKS_DROPS)
            if not container:IsEmpty() then
                ConvertToCollapsed(inst, true)
                return
            end
        else
            container:DropEverythingUpToMaxStacks(TUNING.COLLAPSED_CHEST_EXCESS_STACKS_THRESHOLD)
            if not container:IsEmpty() then
                inst.components.workable:SetWorkLeft(1)
                inst.AnimState:PlayAnimation("idle")
                return
            end
        end
    elseif container ~= nil then
        container:DropEverything()
    end

    DefaultHammered(inst)
end

local function OnRestored(inst)
    inst.AnimState:PlayAnimation("idle")
    if inst.components.workable ~= nil then
        inst.components.workable:SetWorkLeft(3)
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")
end

local function ApplyUpgrade(inst, from_item)
    if inst._ttk_stack_upgraded then
        return
    end
    inst._ttk_stack_upgraded = true

    if inst.components.container ~= nil then
        inst.components.container:Close()
        inst.components.container:EnableInfiniteStackSize(true)
    end

    if from_item then
        local fx = SpawnPrefab("chestupgrade_stacksize_fx")
        if fx ~= nil then
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
    end

    inst.components.upgradeable.upgradetype = nil
    if inst.components.lootdropper ~= nil then
        inst.components.lootdropper:SetLoot({ "alterguardianhatshard" })
    end
    if inst.components.workable ~= nil then
        inst.components.workable:SetOnWorkCallback(OnUpgradedHit)
        inst.components.workable:SetOnFinishCallback(OnUpgradedHammered)
    end
    inst:ListenForEvent("restoredfromcollapsed", OnRestored)
end

local function OnUpgrade(inst, performer, upgraded_from_item)
    if inst.components.upgradeable.numupgrades >= 1 then
        ApplyUpgrade(inst, upgraded_from_item ~= nil)
    end
end

local function DropUpgradeShard(inst)
    if inst.components.lootdropper ~= nil then
        inst.components.lootdropper:SpawnLootPrefab("alterguardianhatshard")
    end
end

local function OnDeconstruct(inst)
    if not inst._ttk_stack_upgraded then
        return
    end

    local container = inst.components.container
    if container ~= nil then
        container:DropEverything(nil, true)
        if ShouldCollapse(inst) then
            if TheWorld.Map:IsPassableAtPoint(inst.Transform:GetWorldPosition()) then
                container:DropEverythingUpToMaxStacks(TUNING.COLLAPSED_CHEST_MAX_EXCESS_STACKS_DROPS)
                if not container:IsEmpty() then
                    if ConvertToCollapsed(inst, false) then
                        DropUpgradeShard(inst)
                    end
                    inst.no_delete_on_deconstruct = true
                    return
                end
            else
                container:DropEverythingUpToMaxStacks(TUNING.COLLAPSED_CHEST_EXCESS_STACKS_THRESHOLD)
                if not container:IsEmpty() then
                    inst.no_delete_on_deconstruct = true
                    return
                end
            end
        else
            container:DropEverything()
        end
    end
    DropUpgradeShard(inst)
    inst.no_delete_on_deconstruct = nil
end

return function(inst)
    local upgradeable = inst:AddComponent("upgradeable")
    upgradeable.upgradetype = UPGRADETYPES.CHEST
    upgradeable:SetOnUpgradeFn(OnUpgrade)

    inst:ListenForEvent("ondeconstructstructure", OnDeconstruct)

    local old_onload = inst.OnLoad
    inst.OnLoad = function(inst, data, newents)
        if old_onload ~= nil then
            old_onload(inst, data, newents)
        end
        if inst.components.upgradeable ~= nil
            and inst.components.upgradeable.numupgrades ~= nil
            and inst.components.upgradeable.numupgrades > 0
        then
            ApplyUpgrade(inst, false)
        end
    end
end
