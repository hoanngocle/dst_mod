-- Callback-level regression checks; no live game or rendering is simulated.
local function noop() end
local function api() return setmetatable({}, {__index=function() return noop end}) end
package.preload.prefabutil = function() return {} end
TheWorld = {ismastersim=true}
TUNING.STACK_SIZE_SMALLITEM=40; TUNING.PERISH_FAST=2880; TUNING.SANITYAURA_TINY=1
ACTIONS={DIG={}}; DEPLOYMODE={PLANT={}}
function MakeInventoryPhysics() end
function MakeInventoryFloatable() end
function MakeObstaclePhysics() end
function MakeSmallBurnable() end
function MakeSmallPropagator() end
function MakeHauntableLaunch() end
function MakeHauntableWork() end
function MakeHauntableLaunchAndPerish() end
function MakePlacer() return {} end
function Prefab(name,fn,assets) return {name=name,fn=fn,assets=assets} end
function net_tinybyte()
    return {n=1,value=function(self) return self.n end,set=function(self,n) self.n=n end}
end
function CreateEntity()
    local e={components={},tags={},listeners={},watchers={},entity=api(),Transform=api(),AnimState=api(),MiniMapEntity=api()}
    function e:AddTag(t) self.tags[t]=true end
    function e:RemoveTag(t) self.tags[t]=nil end
    function e:HasTag(t) return self.tags[t] end
    function e:IsValid() return not self.removed end
    function e:Remove() self.removed=true end
    function e:ListenForEvent(k,fn,source) self.listeners[k]={fn=fn,source=source} end
    function e:RemoveEventCallback(k,fn,source) self.listeners[k]=nil end
    function e:WatchWorldState(k,fn) self.watchers[k]=fn end
    function e:AddComponent(k)
        local c=api(); self.components[k]=c
        if k=='pickable' then
            function c:SetUp(product) self.product=product; self.ready=true end
            function c:MakeEmpty() self.ready=false end
            function c:Regen() self.ready=true end
            function c:CanBePicked() return self.ready end
        elseif k=='debuff' then
            function c:SetAttachedFn(fn) self.attached=fn end
            function c:SetDetachedFn(fn) self.detached=fn end
            function c:SetExtendedFn(fn) self.extended=fn end
            function c:Stop() self.stopped=true; self.detached(e,self.target) end
        elseif k=='timer' then
            function c:StartTimer(k,t) self[k]=t end
            function c:StopTimer(k) self[k]=nil end
        elseif k=='edible' then
            function c:SetOnEatenFn(fn) self.oneaten=fn end
        elseif k=='perishable' then
            function c:SetPerishTime(t) self.duration=t end
        end
    end
    return e
end
local seed,flower,essence = dofile(MODROOT..'/scripts/prefabs/ttk_luoshen_hua.lua')
local plant = flower.fn()
assert(plant:HasTag('xd_ztpuseable'))
assert(not plant.components.pickable:CanBePicked(), 'Immature flower must not yield essence')
for stage=2,5 do
    assert(plant:use_ztp({},{})); assert(plant._stage_net:value()==stage)
end
assert(not plant:HasTag('xd_ztpuseable'))
assert(not plant:use_ztp({},{}))
assert(plant.components.pickable:CanBePicked())
assert(plant.components.pickable.product=='ttk_luoshen_huayin')
local data={}; plant:OnSave(data)
local loaded=flower.fn(); loaded:OnLoad(data)
assert(loaded._stage_net:value()==5 and not loaded:HasTag('xd_ztpuseable'))
plant._soil_cycles=2; plant._growth_cycles=7
plant.components.pickable:MakeEmpty(); plant.watchers.cycles(plant)
assert(plant.components.pickable:CanBePicked())
local q,p,buff = dofile(MODROOT..'/scripts/prefabs/ttk_luoshen_food.lua')
local dish=q.fn(); assert(dish.components.edible.healthvalue==200 and dish:HasTag('preparedfood'))
assert(dish.components.perishable.duration==7200)
local owner=CreateEntity(); owner.components.health={IsDead=function() return false end,DoDelta=function(_,n) healed=(healed or 0)+n end}
local target=CreateEntity(); target.components.health={IsDead=function() return false end}
local b=buff.fn(); b.components.debuff.target=owner; b.components.debuff.attached(b,owner)
assert(b.components.timer.buffover==480)
b.listeners.onattackother.fn(owner,{target=target}); assert(healed==2)
target.components.health.IsDead=function() return true end
b.listeners.onattackother.fn(owner,{target=target}); assert(healed==2)
b.components.timer.buffover=1; b.components.debuff.extended(b,owner)
assert(b.components.timer.buffover==480)
b.listeners.timerdone.fn(b,{name='buffover'})
assert(b.removed and b.listeners.onattackother==nil)
TheWorld.ismastersim=false
assert(q.fn().components.edible==nil)
assert(flower.fn().components.pickable==nil)
print('PASS: flower maturity/save/regrowth, food prefab, buff heal/refresh/cleanup, client boundaries')
