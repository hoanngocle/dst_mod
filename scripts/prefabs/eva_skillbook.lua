local Router = require "util/eva_skillpanel"

local function Atlas(definition)
    return definition.atlas or (GetInventoryItemAtlas ~= nil
        and GetInventoryItemAtlas(definition.texture)
        or "images/inventoryimages.xml")
end

local function GetOwner(book)
    return book._eva_skill_owner ~= nil and book._eva_skill_owner:value() or nil
end

local function ReticuleTargetAllowWater()
    local player = ThePlayer
    local map = TheWorld.Map
    local pos = Vector3()
    for radius = 11.5, 0, -0.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(radius, 0, 0)
        if map:IsPassableAtPoint(pos.x, 0, pos.z, true)
            and not map:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function ConfigureImmediate(book, skill)
    book._eva_selected_skill = skill
    book.components.spellbook:SetSpellName(Router.SKILLS[skill].label)
    book.components.spellbook:SetSpellAction(nil)
    if TheWorld.ismastersim and book.components.aoespell ~= nil then
        book.components.aoespell:SetSpellFn(nil)
    end
end

local function ConfigurePointSkill(book, skill)
    local definition = Router.SKILLS[skill]
    book._eva_selected_skill = skill
    book.components.spellbook:SetSpellName(definition.label)
    book.components.spellbook:SetSpellAction(nil)
    local targeting = book.components.aoetargeting
    targeting:SetRange(definition.range)
    targeting:SetAllowWater(true)
    targeting:SetAllowRiding(false)
    targeting:SetDeployRadius(0)
    targeting:SetShouldRepeatCastFn(nil)
    targeting.reticule.reticuleprefab = "reticuleaoesummontarget_1"
    targeting.reticule.pingprefab = "reticuleaoeping"
    targeting.reticule.targetfn = ReticuleTargetAllowWater
    targeting.reticule.mousetargetfn = nil
    targeting.reticule.updatepositionfn = nil
    if TheWorld.ismastersim then
        targeting:SetTargetFX("reticuleaoesummontarget_1")
        book.components.aoespell:SetSpellFn(function(inst, doer, pos)
            return Router.CastAt(inst, doer, skill, pos.x, pos.z)
        end)
    end
end

local function ExecuteImmediate(book, skill)
    local owner = GetOwner(book)
    if owner == ThePlayer and Router.CanUsePanel(owner, TheFrontEnd)
        and Router.IsSkillUnlocked(owner, skill) then
        Router.RequestImmediate(skill)
    end
end

local function StartPointTargeting(book)
    local owner = GetOwner(book)
    if owner == ThePlayer and Router.CanUsePanel(owner, TheFrontEnd)
        and Router.IsSkillUnlocked(owner, book._eva_selected_skill)
        and owner.components.playercontroller ~= nil then
        owner.components.playercontroller:StartAOETargetingUsing(book)
    end
end

local SPELLS = {
    {
        label = Router.SKILLS.life.label,
        tooltip = Router.SKILLS.life.tooltip,
        atlas = Atlas(Router.SKILLS.life),
        normal = Router.SKILLS.life.texture,
        onselect = function(book) ConfigureImmediate(book, "life") end,
        execute = function(book) ExecuteImmediate(book, "life") end,
    },
    {
        label = Router.SKILLS.wings.label,
        tooltip = Router.SKILLS.wings.tooltip,
        atlas = Atlas(Router.SKILLS.wings),
        normal = Router.SKILLS.wings.texture,
        onselect = function(book) ConfigureImmediate(book, "wings") end,
        execute = function(book) ExecuteImmediate(book, "wings") end,
    },
    {
        label = Router.SKILLS.array.label,
        tooltip = Router.SKILLS.array.tooltip,
        atlas = Atlas(Router.SKILLS.array),
        normal = Router.SKILLS.array.texture,
        onselect = function(book) ConfigurePointSkill(book, "array") end,
        execute = StartPointTargeting,
    },
    {
        label = Router.SKILLS.harvest.label,
        tooltip = Router.SKILLS.harvest.tooltip,
        atlas = Atlas(Router.SKILLS.harvest),
        normal = Router.SKILLS.harvest.texture,
        onselect = function(book) ConfigurePointSkill(book, "harvest") end,
        execute = StartPointTargeting,
    },
    {
        label = Router.SKILLS.daydu.label,
        tooltip = Router.SKILLS.daydu.tooltip,
        atlas = Atlas(Router.SKILLS.daydu),
        normal = Router.SKILLS.daydu.texture,
        onselect = function(book) ConfigurePointSkill(book, "daydu") end,
        execute = StartPointTargeting,
    },
}

local function InstallReplicaOwnerGuard(inst)
    local replica = inst.replica ~= nil and inst.replica.inventoryitem or nil
    if replica == nil or replica._eva_owner_guard then return end
    local original = replica.IsGrandOwner
    replica.IsGrandOwner = function(self, player)
        local owner = GetOwner(inst)
        if owner ~= nil then return player ~= nil and player == owner end
        return original ~= nil and original(self, player) or false
    end
    replica._eva_owner_guard = true
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst._eva_skill_owner = net_entity(inst.GUID, "eva_skillbook.owner")
    inst:AddTag("eva_skillbook")
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst:AddComponent("spellbook")
    inst.components.spellbook:SetRadius(100)
    inst.components.spellbook:SetFocusRadius(102)
    inst.components.spellbook:SetItems(SPELLS)
    inst.components.spellbook:SetCanUseFn(function(book, user)
        return GetOwner(book) == user
    end)

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetRange(12)
    inst.components.aoetargeting:SetAllowWater(true)
    inst.components.aoetargeting:SetAllowRiding(false)
    inst.components.aoetargeting.reticule.validcolour = {0.78, 0.62, 1, 1}
    inst.components.aoetargeting.reticule.invalidcolour = {0.55, 0.1, 0.2, 1}
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting.reticule.twinstickmode = 1
    inst.components.aoetargeting.reticule.twinstickrange = 8

    inst.entity:SetPristine()

    inst.GetEvaOwner = GetOwner

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = InstallReplicaOwnerGuard
        inst:DoTaskInTime(0, InstallReplicaOwnerGuard)
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.cangoincontainer = false
    inst:AddComponent("aoespell")

    inst.BindToOwner = function(book, owner)
        book._eva_skill_owner:set(owner)
        book.components.inventoryitem:SetOwner(owner)
        book:RemoveFromScene()
        book.entity:SetParent(owner.entity)
        if book.Network ~= nil then book.Network:SetClassifiedTarget(owner) end
        InstallReplicaOwnerGuard(book)
    end
    inst.persists = false
    return inst
end

return Prefab("eva_skillbook", fn, nil, {
    "reticuleaoesummontarget_1",
    "reticuleaoeping",
})
