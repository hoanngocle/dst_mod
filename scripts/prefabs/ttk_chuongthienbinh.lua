-- Adapted from Tu Tien 19.7 ordinary bottle; capacity matches the unique bottle.
local assets =
{
    Asset("ANIM", "anim/ttk_chuongthienbinh.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_chuongthienbinh.xml"),
}

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    owner.AnimState:OverrideSymbol("swap_object", skin_build or "xd_ztp", "swap")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end
local HORTICULTURE_CANT_TAGS = { "magicgrowth", "player", "FX", "leif", "pickable", "stump", "withered", "barren", "INLIMBO", "silviculture", "tree", "winter_tree" }

local function trygrowth(inst, maximize)
    if not inst:IsValid()
		or inst:IsInLimbo()
        or (inst.components.witherable ~= nil and inst.components.witherable:IsWithered()) then
        return false
    end
    if inst.components.growable ~= nil then
        if inst.components.growable.magicgrowable or ((inst:HasTag("tree") or inst:HasTag("winter_tree")) and not inst:HasTag("stump")) then
            if inst.components.simplemagicgrower ~= nil then
                inst.components.simplemagicgrower:StartGrowing()
                return true
            elseif inst.components.growable.domagicgrowthfn ~= nil then
                inst.magic_growth_delay = maximize and 2 or nil
                if math.random() < 0.25 then
                    inst.force_oversized = true
                end
                inst.components.growable:DoMagicGrowth()
                return true
            else
                return inst.components.growable:DoGrowth()
            end
        end
    end
	return false
end
local function GrowNext(spell)
	while #spell._targets > 0 do
		local target = table.remove(spell._targets, 1)
		if target:IsValid() and trygrowth(target, spell._maximize) then
			if spell._count > 1 then
				spell._count = spell._count - 1
				spell:DoTaskInTime(0.05 + 0.1 * math.random(), GrowNext)
				return
			end
			break
		end
	end
	spell:Remove()
end

local function do_book_horticulture_spell(x, z, max_targets, maximize)
	local ents = TheSim:FindEntities(x, 0, z, 4, {"farm_plant"}, HORTICULTURE_CANT_TAGS)
	local targets = {}
	for i, v in ipairs(ents) do
		if  v.components.growable ~= nil then
			table.insert(targets, v)
		end
	end
	if #targets == 0 then
        return false
	end
	local spell = SpawnPrefab("book_horticulture_spell")
	spell.Transform:SetPosition(x, 0, z)
	spell._targets = targets
	spell._count = max_targets
	spell._maximize = maximize

	GrowNext(spell)
	return true
end

-- Fixed costs are independent of the 200-point capacity.
local function onuse(inst, target, pos, caster)
    if not (target and target:IsValid() and caster) then return false end
    local uses = inst.components.finiteuses
    local cost = target:HasTag("farm_plant") and 50 or 100
    if uses:GetUses() < cost then
        if caster.components.talker then
            caster.components.talker:Say("Cần đặt bình ngoài trời vào ban đêm để tích thêm linh khí.")
        end
        return false
    end
    local success = false
    if target:HasTag("farm_plant") then
        local x, y, z = target.Transform:GetWorldPosition()
        success = do_book_horticulture_spell(x, z, 3, true)
    elseif target:HasTag("xd_ztpuseable") and target.use_ztp then
        success = target:use_ztp(inst, caster) ~= false
    end
    if success then uses:Use(cost) end
    return success
end

local function can_cast_fn(doer, target, pos)
    return target ~= nil and (target:HasTag("farm_plant") or target:HasTag("xd_ztpuseable"))
end

local function onremovelight(inst)
	if inst.moonlight ~= nil then
        inst.moonlight:Remove()
		
		inst.moonlight = nil
	end
end

local function UpdateLight(inst,phase)
    if inst.components.inventoryitem.owner ~= nil then
        inst.Light:Enable(false)
    elseif phase == "night" then
        inst.Light:Enable(true)
    else
        onremovelight(inst)
        inst.Light:Enable(false)
    end
end

local function oncreatlight(inst)
    if inst.moonlight == nil then
	    inst.moonlight = inst:SpawnChild("positronbeam_front")
	    
        inst.moonlight.AnimState:SetDeltaTimeMultiplier(0.8)
    end
end

local function OnPickup(inst)
    inst.Light:Enable(false)
	onremovelight(inst)
end

local function addfiniteuses(inst)
	local owner = inst.components.inventoryitem.owner
	if not owner and TheWorld.state.phase == "night" and inst.components.finiteuses:GetPercent() < 1   then
        oncreatlight(inst)
		inst.components.finiteuses:Repair(0.6)
        
	end
end

local function PercentChanged(inst, data)
    if data and data.percent ~= nil then
        local rad = data.percent
        rad = Remap(rad, 0, 1, 0.4, 1)
        inst.Light:SetRadius(rad)
        if data.percent >= 1 then
            onremovelight(inst)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("xd_ztp")
    inst.AnimState:SetBuild("xd_ztp")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst)

    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(0.5)
    inst.Light:SetColour(40/255, 209/255, 104/255)
    inst.Light:Enable(false)

    inst:AddTag("xd_ztp") 
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.fxcolour = {40/255,119/255,204/255}

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(200)
    inst.components.finiteuses:SetUses(0)
    inst.components.finiteuses.doesnotstartfull  = true

    inst:AddComponent("inspectable")
    inst.components.inspectable.descriptionfn = function(item)
        return string.format("Linh khí: %.1f / 200. Đặt ngoài trời ban đêm để nạp. Thúc tối đa 3 cây trồng, tốn 50 linh khí.", item.components.finiteuses:GetUses())
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/ttk_chuongthienbinh.xml"
    inst.components.inventoryitem:ChangeImageName("ttk_chuongthienbinh")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickup)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(onuse)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.can_cast_fn = can_cast_fn

    inst:ListenForEvent("percentusedchange", PercentChanged)
    inst:WatchWorldState("phase", UpdateLight)
    inst:ListenForEvent("ondropped", function()
        inst.Light:Enable(false)
        inst:DoTaskInTime(0,function()
            UpdateLight(inst, TheWorld.state.phase)
        end)
    end)
	UpdateLight(inst, TheWorld.state.phase)

    if not TheWorld:HasTag("cave") then
        inst:DoPeriodicTask(1,addfiniteuses,1)
    end

    inst.OnLoad = function (inst,data)
        if inst.components.finiteuses  and inst.components.finiteuses:GetPercent() > 1 then
            inst.components.finiteuses:SetPercent(1)
        end
    end

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("ttk_chuongthienbinh", fn, assets, {"book_horticulture_spell", "positronbeam_front"})