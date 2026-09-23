require "prefabutil"

local cooking = require("cooking")

local assets =
{
    Asset("ANIM", "anim/portable_spicer.zip"),
    Asset("ANIM", "anim/cook_pot_food.zip"),
    Asset("ANIM", "anim/plate_food.zip"),
    Asset("ANIM", "anim/spices.zip"),
    Asset("ANIM", "anim/ui_cookpot_1x2.zip"),
    Asset("ANIM", "anim/ttk_yunxiao_portable_spicer.zip"),
	Asset("ATLAS", "images/inventoryimages/ttk_yunxiao_portable_spicer.xml"),
    Asset("ATLAS", "images/inventoryimages/ttk_yunxiao_portableslot.xml")
}

local prefabs =
{
    "collapse_small",
    "ash",
}
for k, v in pairs(cooking.recipes.portablespicer) do
    table.insert(prefabs, v.name)

	if v.overridebuild then
        table.insert(assets, Asset("ANIM", "anim/"..v.overridebuild..".zip"))
	end
end

local function onhammered(inst)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    if inst.components.stewer:IsDone() then inst.components.stewer:Harvest(nil) end
    inst.components.container:DropEverything()
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")

    inst:Remove()
end

local function onhit(inst)
    if not inst:HasTag("burnt") then
        if inst.components.stewer:IsCooking() then
            inst.AnimState:PlayAnimation("hit_cooking")
            inst.AnimState:PushAnimation("cooking_loop", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/spicer/lid_close")
        elseif inst.components.stewer:IsDone() then
            inst.AnimState:PlayAnimation("hit_full")
            inst.AnimState:PushAnimation("idle_full", false)
        else
            if inst.components.container ~= nil and inst.components.container:IsOpen() then
                inst.components.container:Close()
                
            else
                inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/spicer/lid_close")
            end
            inst.AnimState:PlayAnimation("hit_empty")
            inst.AnimState:PushAnimation("idle_empty", false)
        end
    end
end

local function startcookfn(inst)
    if not inst:HasTag("burnt") then
        if inst.components.container:IsOpen() then
            inst.AnimState:PlayAnimation("cooking_pre")
            inst.AnimState:PushAnimation("cooking_loop", true)
            
        else
            inst.AnimState:PlayAnimation("cooking_loop", true)
        end
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/spicer/cooking_LP", "snd")
    end
end

local function onopen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("open")
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/spicer/lid_open")
        
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        if not inst.components.stewer:IsCooking() then
            inst.AnimState:PlayAnimation("close")
            inst.SoundEmitter:KillSound("snd")
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/spicer/lid_close")
    end
end

local function spoilfn(inst)
    if not inst:HasTag("burnt") then
        inst.components.stewer.product = inst.components.stewer.spoiledproduct
        inst.AnimState:OverrideSymbol("swap_cooked", "cook_pot_food", inst.components.stewer.product)
        inst.AnimState:ClearOverrideSymbol("swap_garnish")
    end
end

local function ShowProduct(inst)
    if not inst:HasTag("burnt") then
        local product = inst.components.stewer.product
        local recipe = cooking.GetRecipe(inst.prefab, product)
        if recipe ~= nil then
            product = recipe.basename or product
            if recipe.spice ~= nil then
                inst.AnimState:OverrideSymbol("swap_plate", "plate_food", "plate")
                inst.AnimState:OverrideSymbol("swap_garnish", "spices", string.lower(recipe.spice))
            else
                inst.AnimState:ClearOverrideSymbol("swap_plate")
                inst.AnimState:ClearOverrideSymbol("swap_garnish")
            end
        else
            inst.AnimState:ClearOverrideSymbol("swap_plate")
            inst.AnimState:ClearOverrideSymbol("swap_garnish")
        end

        local build =
            (recipe ~= nil and recipe.overridebuild) or
            ((IsModCookingProduct(inst.prefab, product) or IsModCookingProduct("portablespicer", product)) and product) or
            "cook_pot_food"
        local overridesymbol = recipe ~= nil and recipe.overridesymbolname or product
        inst.AnimState:OverrideSymbol("swap_cooked", build, overridesymbol)
    end
end

local function donecookfn(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("cooking_pst")
        inst.AnimState:PushAnimation("idle_full", false)
        ShowProduct(inst)
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/spicer/cooking_pst")
    end
end

local function continuedonefn(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("idle_full")
        ShowProduct(inst)
    end
end

local function continuecookfn(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("cooking_loop", true)
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/spicer/cooking_LP", "snd")
    end
end

local function harvestfn(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("close")
        inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/spicer/lid_close")
    end
end

local function getstatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst.components.stewer:IsDone() and "DONE")
        or (not inst.components.stewer:IsCooking() and "EMPTY")
        or (inst.components.stewer:GetTimeToCook() > 15 and "COOKING_LONG")
        or "COOKING_SHORT"
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)
    RemovePhysicsColliders(inst)
    SpawnPrefab("ash").Transform:SetPosition(inst.Transform:GetWorldPosition())
    if inst.components.workable ~= nil then
        inst:RemoveComponent("workable")
    end
    inst.persists = false
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:ListenForEvent("animover", ErodeAway)
    inst.AnimState:PlayAnimation("burnt_collapse")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) 
    inst:SetPhysicsRadiusOverride(.5)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst.MiniMapEntity:SetIcon("ttk_yunxiao_portable_spicer.tex")

    inst:AddTag("structure")
    
    inst:AddTag("spicer")

    inst:AddTag("stewer")

    inst.AnimState:SetBank("portable_spicer")
    inst.AnimState:SetBuild("xd_yunxiao_portable_spicer")
    inst.AnimState:PlayAnimation("idle_empty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stewer")
    inst.components.stewer.keepspoilage = true
    inst.components.stewer.onstartcooking = startcookfn
    inst.components.stewer.oncontinuecooking = continuecookfn
    inst.components.stewer.oncontinuedone = continuedonefn
    inst.components.stewer.ondonecooking = donecookfn
    inst.components.stewer.onharvest = harvestfn
    inst.components.stewer.onspoil = spoilfn
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("ttk_yunxiao_portable_spicer")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    require("ttk_spicer_batch")(inst)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(5)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:SetOnBurntFn(OnBurnt)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("ttk_yunxiao_portable_spicer", fn, assets, prefabs),
    MakePlacer("ttk_yunxiao_portable_spicer_placer", "portable_spicer", "xd_yunxiao_portable_spicer", "idle_empty")
