-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/xd_baihu_shadow_fx.zip")),
}
local NUM_VARIATIONS = 3
local MIN_SCALE = 1
local MAX_SCALE = 1.8
local function PlayShadowAnim(proxy, anim, scale, flip)
    local inst = CreateEntity()
    inst:AddTag("FX")
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.Transform:SetFromProxy(proxy.GUID)
    inst.AnimState:SetBank(Boss.Art("xd_baihu_shadow_fx"))
    inst.AnimState:SetBuild(Boss.Art("xd_baihu_shadow_fx"))
    inst.AnimState:SetScale(flip and -scale or scale, scale)
    inst.AnimState:SetMultColour(1, 1, 1, .5)
    inst.AnimState:PlayAnimation(anim)
    inst:ListenForEvent("animover", inst.Remove)
end
local function OnRandDirty(inst)
    if inst._complete or inst._rand:value() <= 0 then
        return
    end
    local flip = inst._rand:value() > 31
    local scale = MIN_SCALE + (MAX_SCALE - MIN_SCALE) * (flip and inst._rand:value() - 32 or inst._rand:value() - 1) / 30
    inst:DoTaskInTime(0, PlayShadowAnim, "shad"..inst.variation, scale, flip)
end
local function DisableNetwork(inst)
    inst.Network:SetClassifiedTarget(inst)
end
local function MakeShadowFX(name, num, prefabs)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddNetwork()
        inst:AddTag("FX")
        inst:AddTag("ttk_boss_baihu_shadow_fx")
        inst.variation = tostring(num or math.random(NUM_VARIATIONS))
        inst._rand = net_smallbyte(inst.GUID, "ttk_boss_baihu_shadow_fx._rand", "randdirty")
        if not TheNet:IsDedicated() then
            inst._complete = false
            inst:ListenForEvent("randdirty", OnRandDirty)
        end
        if num == nil then
            inst:SetPrefabName(name..inst.variation)
        end
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end
        inst.persists = false
        inst:DoTaskInTime(.5, DisableNetwork)
        inst:DoTaskInTime(1.5, inst.Remove)
        inst._rand:set(math.random(62))
        return inst
    end
    return Prefab(name, fn, assets, prefabs)
end
local ret = {}
local prefs = {}
for i = 1, NUM_VARIATIONS do
    local name = "ttk_boss_baihu_shadow_fx"..tostring(i)
    table.insert(prefs, name)
    table.insert(ret, MakeShadowFX(name, i))
end
table.insert(ret, MakeShadowFX("ttk_boss_baihu_shadow_fx", nil, prefs))
prefs = nil
return unpack(ret)
