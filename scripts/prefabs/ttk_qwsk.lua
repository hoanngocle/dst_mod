
local assets =
{
    Asset("ANIM", "anim/ttk_qwsk.zip"),
    Asset("ANIM", "anim/cook_pot_food.zip"),
    Asset("ANIM", "anim/plate_food.zip"),
    Asset("ANIM", "anim/spices.zip"),
	Asset("ATLAS", "images/inventoryimages/ttk_qwsk.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_qwsk.tex"),
}
local cooking = require("cooking")
local spicedfoods = require("spicedfoods")
local foods = {}
for k, v in pairs(spicedfoods) do
    table.insert(foods, v.name)
end

local prefabs = {"collapse_small", "ttk_hyf_fullfx", "ttk_hyf_frontfx_small"}
for _, food in ipairs(foods) do table.insert(prefabs, food) end

local function SetBuild(inst)
    if inst.fooddata then
        if inst.fooddata.spicename then
            inst.AnimState:OverrideSymbol("swap_garnish", "spices", inst.fooddata.spicename)
        end
        if inst.fooddata.foodbuild and inst.fooddata.foodsymbol then
            inst.AnimState:OverrideSymbol("swap_food", inst.fooddata.foodbuild, inst.fooddata.foodsymbol)
        end
        inst.AnimState:OverrideSymbol("plate", "plate_food", "plate")
        inst.components.activatable.inactive = true
    else
        inst.AnimState:ClearOverrideSymbol("swap_food")
        inst.AnimState:ClearOverrideSymbol("swap_garnish")
        inst.AnimState:ClearOverrideSymbol("plate")
        inst.components.activatable.inactive = false
    end
end

local function spawanfx(inst)
    if inst then
        local s  = 0.4
        local fx = SpawnPrefab("ttk_hyf_fullfx")
        if fx == nil then return end
        fx.entity:SetParent(inst.entity)
        fx.entity:AddFollower()
        fx.Follower:FollowSymbol(inst.GUID, "plate", 0, 0, 0)
        fx.Transform:SetScale(s, s, s)
        local fx = SpawnPrefab("ttk_hyf_frontfx_small")
        if fx == nil then return end
        fx.entity:SetParent(inst.entity)
        fx.entity:AddFollower()
        fx.Follower:FollowSymbol(inst.GUID, "plate", 0, 0, 0)
        fx.Transform:SetScale(s, s, s)
    end
end

local function OnDay(inst)
    if #foods == 0 then return end
    local food = foods[math.random(#foods)]
    if cooking.recipes.portablespicer[food] then
        local data = cooking.recipes.portablespicer[food]
        inst.fooddata = {
            prefab = food,
            count = math.random(2),
            spicename = data.spice ~= nil and string.lower(data.spice) or nil,
            foodbuild = data.overridebuild or "cook_pot_food",
            foodsymbol = data.basename or data.name
        }
        spawanfx(inst)
        SetBuild(inst)
    end
end

local function onuse(inst,doer)
    if inst.fooddata and inst.fooddata.prefab then
        for k = 1,inst.fooddata.count or 1 do
            local new = SpawnPrefab(inst.fooddata.prefab)
            if new then
                if doer and doer.components.inventory then
                    doer.components.inventory:GiveItem(new,nil,inst:GetPosition())
                else
                    LaunchAt(new, inst)
                end
            end
        end
    end
    inst.fooddata = nil
    SetBuild(inst)
end

local function onhammered(inst, worker)
    if inst.fooddata ~= nil then onuse(inst) end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if inst.fooddata then
        onuse(inst)
    end
end

local s  = 1.2

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("xd_qwsk")
    inst.AnimState:SetBuild("xd_qwsk")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon("ttk_qwsk.tex")

    inst:AddTag("structure")
    inst.GetActivateVerb = function() return "TTK_GET_FOOD" end

    MakeSnowCoveredPristine(inst)
    inst.Transform:SetScale(s, s, s)
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then

        return inst
    end
    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("activatable")
    inst.components.activatable.inactive = false
    inst.components.activatable.OnActivate = function(inst, doer) onuse(inst, doer); return true end

    inst:WatchWorldState("cycles", OnDay)

	inst.OnSave = function(inst,data)
		data.fooddata = inst.fooddata
	end
	inst.OnLoad = function(inst,data)
		if data then
            if data.fooddata then
                inst.fooddata = data.fooddata
                SetBuild(inst)
            end
		end
	end
    MakeSnowCovered(inst)
    AddHauntableDropItemOrWork(inst)

    return inst
end

return  Prefab("ttk_qwsk", fn, assets, prefabs),
    MakePlacer("ttk_qwsk_placer", "xd_qwsk", "xd_qwsk", "idle",nil,nil,nil,s)
