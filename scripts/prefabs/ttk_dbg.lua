
local assets =
{
    Asset("ANIM", "anim/ttk_dbg.zip"),
    Asset("ANIM", "anim/ttk_ui_6x6.zip"),
	Asset("ATLAS", "images/inventoryimages/ttk_dbg.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_dbg.tex"),
}

local prefabs = { "collapse_small", "sand_puff", "collapsed_treasurechest", "chestupgrade_stacksize_fx",

}

local function onopen(inst)
    
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function onclose(inst)
    
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function AddDecor(inst, data)
    if inst:HasTag("burnt") or data == nil or data.slot == nil or data.item == nil then
        return
    end
    if data.slot > 8 then
        return
    end
    if data.item.replica.inventoryitem then
        local atlas, bgimage, bgatlas
        local image = FunctionOrValue(data.item.drawimageoverride, data.item, nil) or (#(data.item.components.inventoryitem.imagename or "") > 0 and data.item.components.inventoryitem.imagename) or data.item.prefab or nil
        if image ~= nil then
            atlas = FunctionOrValue(data.item.drawatlasoverride, data.item, nil) or (#(data.item.components.inventoryitem.atlasname or "") > 0 and data.item.components.inventoryitem.atlasname) or nil
            if data.item.inv_image_bg ~= nil and data.item.inv_image_bg.image ~= nil and data.item.inv_image_bg.image:len() > 4 and data.item.inv_image_bg.image:sub(-4):lower() == ".tex" then
                bgimage = data.item.inv_image_bg.image:sub(1, -5)
                bgatlas = data.item.inv_image_bg.atlas ~= GetInventoryItemAtlas(data.item.inv_image_bg.image) and data.item.inv_image_bg.atlas or nil
            end
        end
        if not atlas and image then
            atlas =  GetInventoryItemAtlas(image..".tex")
        end
        if atlas and image then
            inst.AnimState:OverrideSymbol("slot_"..data.slot, resolvefilepath_soft(atlas), image..".tex")
        end
    end
end

local function RemoveDecor(inst, data)
    inst.AnimState:ClearOverrideSymbol("slot_"..data.slot)
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    if inst.components.container then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst:Remove()
end

local function onhit(inst, worker)
    inst.components.container:DropEverything()
    inst.components.container:Close()
end

local function RefreshDecor(inst)
    for slot = 1, 8 do
        inst.AnimState:ClearOverrideSymbol("slot_" .. slot)
        local item = inst.components.container:GetItemInSlot(slot)
        if item ~= nil then AddDecor(inst, {slot = slot, item = item}) end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst)

    inst.AnimState:SetBank("xd_dbg")
    inst.AnimState:SetBuild("xd_dbg")
    inst.AnimState:PlayAnimation("idle",true)

    inst.MiniMapEntity:SetIcon("ttk_dbg.tex")

    inst:AddTag("ttk_dbg")
    MakeSnowCoveredPristine(inst)

    inst:AddTag("structure")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then

        return inst
    end
    inst:AddComponent("inspectable")

    inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("ttk_dbg")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("timer")

    inst:ListenForEvent("itemget", AddDecor)
    inst:ListenForEvent("itemlose", RemoveDecor)


	inst.OnSave = function(inst,data)
		
	end
	inst.OnLoad = function(inst,data)
		if data then
		end
	end
    inst.OnLoadPostPass = RefreshDecor
    inst.TTKRefreshDecor = RefreshDecor
    inst:ListenForEvent("restoredfromcollapsed", RefreshDecor)
    MakeSnowCovered(inst)
    AddHauntableDropItemOrWork(inst)
    require("ttk_chestupgrade")(inst)
    return inst
end

return  Prefab("ttk_dbg", fn, assets, prefabs),
    MakePlacer("ttk_dbg_placer", "xd_dbg", "xd_dbg", "idle")
