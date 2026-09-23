-- Five independent Lục Nguyên held swords. Tinh La keeps its established prefab.
local Elements = require("ttk_elemental_combat")
local repairvalues = require("ttk_tinhlakiem_repair")

local BASE_DAMAGE = 100
local MAX_USES = 1000

local DEFINITIONS = {
    {
        prefab = "ttk_votuongkiem", element = 1,
        archive = "ttk_lucnguyen_kim", bank = "xd_wxj", build = "xd_wxj",
        swap = "swap", fxcolour = { 1, 1, 1 },
    },
    {
        prefab = "ttk_thanhtrucphongvankiem", element = 2,
        archive = "ttk_lucnguyen_moc", bank = "xd_htz_qzj", build = "xd_htz_qzj",
        swap = "swap", fxcolour = { 80 / 255, 194 / 255, 147 / 255 },
    },
    {
        prefab = "ttk_phanthienkiem", element = 4,
        archive = "ttk_lucnguyen_hoa", bank = "xd_ftj", build = "xd_ftj",
        swap = "png", fxcolour = { 230 / 255, 133 / 255, 53 / 255 },
    },
    {
        prefab = "ttk_tienkiem", element = 5,
        archive = "ttk_lucnguyen_tho", bank = "xd_sword_red", build = "xd_sword_red",
        swap = "png", fxcolour = { 1, 193 / 255, 39 / 255 },
    },
    {
        prefab = "ttk_makiem", element = 6,
        archive = "ttk_lucnguyen_loi", bank = "xd_sword_mo", build = "xd_sword_mo",
        swap = "png", fxcolour = { 117 / 255, 58 / 255, 1 },
    },
}

local function MakeSword(def)
    local assets = {
        Asset("ANIM", "anim/" .. def.archive .. ".zip"),
        Asset("ATLAS", "images/inventoryimages/" .. def.prefab .. ".xml"),
        Asset("IMAGE", "images/inventoryimages/" .. def.prefab .. ".tex"),
    }
    local prefabs = def.element == 2 and { "ttk_lucnguyen_sword_2" } or nil

    local function OnEquip(inst, owner)
        local build, symbol = require("ttk_skins").GetEquipPresentation(inst, def.build, def.swap)
        owner.AnimState:OverrideSymbol("swap_object", build, symbol)
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
        Elements.Equip(inst, owner, def.element)
    end

    local function OnUnequip(inst, owner)
        Elements.Unequip(inst)
        owner.AnimState:ClearOverrideSymbol("swap_object")
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
    end

    local function OnEquipToModel(inst)
        Elements.Unequip(inst)
    end

    local function UpdateDamage(inst)
        if inst:IsValid() and inst.components.weapon ~= nil then
            require("ttk_weapon_damage").SetBase(inst, BASE_DAMAGE)
        end
    end

    local function CanRepair(inst, item, giver, count)
        return item ~= nil and item ~= inst and repairvalues[item.prefab] ~= nil
            and (count == nil or count == 1)
            and inst.components.finiteuses:GetPercent() < 1
    end

    local function OnRepair(inst, giver, item)
        inst.components.finiteuses:Repair(repairvalues[item.prefab])
        if giver ~= nil and giver.SoundEmitter ~= nil then
            giver.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
        end
    end

    local function OnSave(inst, data)
        if def.element == 2 and (inst._ttk_moc_hits or 0) > 0 then
            data.ttk_moc_hits = math.min(3, math.floor(inst._ttk_moc_hits))
        elseif def.element == 5 and (inst._ttk_tho_hits or 0) > 0 then
            data.ttk_tho_hits = math.min(4, math.floor(inst._ttk_tho_hits))
        end
    end

    local function OnLoad(inst, data)
        if type(data) ~= "table" then return end
        if def.element == 2 and type(data.ttk_moc_hits) == "number" then
            inst._ttk_moc_hits = math.max(0, math.min(3, math.floor(data.ttk_moc_hits)))
        elseif def.element == 5 and type(data.ttk_tho_hits) == "number" then
            inst._ttk_tho_hits = math.max(0, math.min(4, math.floor(data.ttk_tho_hits)))
        end
    end

    local function Fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        MakeInventoryPhysics(inst)
        MakeInventoryFloatable(inst)
        inst.AnimState:SetBank(def.bank)
        inst.AnimState:SetBuild(def.build)
        inst.AnimState:PlayAnimation("idle", true)
        inst:AddTag("sharp")
        inst:AddTag("pointy")
        inst:AddTag("weapon")
        inst:AddTag("nosteal")
        inst:AddTag("allow_action_on_impassable")
        inst:AddTag("alltrader")
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end

        inst.fxcolour = def.fxcolour
        inst:AddComponent("weapon")
        inst.components.weapon:SetDamage(BASE_DAMAGE)
        inst.components.weapon:SetRange(2)

        if def.element == 1 then
            -- Native special damage stays outside Solo's normal-damage critical math
            -- and flows through the target's ordinary planar defenses.
            inst:AddComponent("planardamage")
            inst.components.planardamage:SetBaseDamage(10)
        end

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(MAX_USES)
        inst.components.finiteuses:SetUses(MAX_USES)
        inst.components.finiteuses:SetOnFinished(inst.Remove)
        inst:ListenForEvent("percentusedchange", UpdateDamage)

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname =
            "images/inventoryimages/" .. def.prefab .. ".xml"
        inst.components.inventoryitem.imagename = def.prefab

        inst:AddComponent("equippable")
        inst.components.equippable:SetOnEquip(OnEquip)
        inst.components.equippable:SetOnUnequip(OnUnequip)
        inst.components.equippable:SetOnEquipToModel(OnEquipToModel)

        inst:AddComponent("trader")
        inst.components.trader.acceptnontradable = true
        inst.components.trader:SetAbleToAcceptTest(CanRepair)
        inst.components.trader.onaccept = OnRepair

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
        inst.OnRemoveEntity = Elements.Unequip
        MakeHauntableLaunch(inst)
        return inst
    end

    return Prefab(def.prefab, Fn, assets, prefabs)
end

local prefabs = {}
for _, def in ipairs(DEFINITIONS) do table.insert(prefabs, MakeSword(def)) end
return unpack(prefabs)
