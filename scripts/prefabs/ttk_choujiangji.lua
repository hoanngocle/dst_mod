require("prefabutil")
local prizes = require("ttk_slot_prizes")
local bosses = require("ttk_slot_bosses")

local assets = {
    Asset("ANIM", "anim/ttk_slot_machine.zip"),
    Asset("ANIM", "anim/ttk_choujiangji.zip"),
    Asset("ATLAS", "images/map_icons/ttk_choujiangji.xml"),
    Asset("IMAGE", "images/map_icons/ttk_choujiangji.tex"),
}
local prefabs = {"collapse_small", "ttk_lingshi2"}
local seen = {}
for _, group in pairs(prizes.groups) do
    for _, bundle in ipairs(group.bundles) do
        for _, item in ipairs(bundle.items) do
            if not seen[item.prefab] then
                seen[item.prefab] = true
                prefabs[#prefabs + 1] = item.prefab
            end
        end
    end
end

local function DispensePrize(inst, name)
    local item = SpawnPrefab(name)
    if item == nil then
        -- Do not silently eat a paid reward if another mod removes a prefab.
        item = SpawnPrefab("ttk_lingshi2")
        if item == nil then return end
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    local angle = math.random() * 2 * PI
    if item.components.inventoryitem ~= nil and item.components.health == nil then
        item.Transform:SetPosition(x + 2 * math.cos(angle), y + 2, z + 2 * math.sin(angle))
        if item.Physics ~= nil then item.Physics:SetVel(3 * math.cos(angle), 7, 3 * math.sin(angle)) end
        inst.SoundEmitter:PlaySound("choujiangji_sound/choujiangji_sound/slotmachine_reward")
    else
        local pos = Vector3(x, y, z)
        local offset = FindWalkableOffset(pos, angle, 4, 10)
        if offset ~= nil then pos = pos + offset end
        item.Transform:SetPosition(pos:Get())
        bosses.Prepare(item, pos)
        local fx = SpawnPrefab("collapse_small")
        if fx ~= nil then fx.Transform:SetPosition(pos:Get()) end
        if item.components.combat ~= nil then
            item:DoPeriodicTask(1, function(mob)
                if mob.components.health ~= nil and mob.components.health:IsDead() then return end
                if mob.components.combat ~= nil and mob.components.combat.target == nil then
                    local mx, my, mz = mob.Transform:GetWorldPosition()
                    local player = FindClosestPlayerInRangeSq(mx, my, mz, 25 * 25, true)
                    if player ~= nil then mob.components.combat:SetTarget(player) end
                end
            end)
        end
    end
    return item
end

local function ShouldAccept(inst, item)
    if not inst.components.ttk_slotmachine:CanAccept(item) then return false end
    inst.pendingprize = prizes.Pick(Prefabs)
    return inst.pendingprize ~= nil
end

local function OnAccept(inst, giver, item)
    if not TheWorld.ismastersim or item == nil or item.prefab ~= "ttk_lingshi2" then return end
    inst.components.ttk_slotmachine:Start(inst.pendingprize, giver)
    inst.pendingprize = nil
end

local function OnHammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("metal")
    end
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    MakeObstaclePhysics(inst, .8, 1.2)
    inst.AnimState:SetBank("slot_machine")
    inst.AnimState:SetBuild("xd_choujiangji")
    inst.AnimState:PlayAnimation("idle")
    inst.MiniMapEntity:SetIcon("ttk_choujiangji.tex")
    inst:AddTag("structure")
    inst:AddTag("trader")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst.DispensePrize = DispensePrize
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function()
        return inst.components.ttk_slotmachine.busy and "BUSY" or "GENERIC"
    end
    inst:AddComponent("lootdropper")
    inst:AddComponent("ttk_slotmachine")
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAccept)
    inst.components.trader.onaccept = OnAccept
    local accept = inst.components.trader.AcceptGift
    inst.components.trader.AcceptGift = function(self, giver, item, count)
        return accept(self, giver, item, 1)
    end
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst:ListenForEvent("ttk_slot_spin", function()
        -- Finish a paid spin even after everyone leaves the area.
        inst.entity:SetCanSleep(false)
        inst.components.workable:SetWorkable(false)
    end)
    inst:ListenForEvent("ttk_slot_done", function()
        inst.components.workable:SetWorkable(true)
        inst.entity:SetCanSleep(true)
    end)
    inst.OnLoad = function()
        inst:DoTaskInTime(0, function()
            inst.components.workable:SetWorkable(not inst.components.ttk_slotmachine.busy)
        end)
    end
    inst:SetStateGraph("SGttk_choujiangji")
    return inst
end

return Prefab("ttk_choujiangji", fn, assets, prefabs),
    MakePlacer("ttk_choujiangji_placer", "slot_machine", "xd_choujiangji", "idle")
