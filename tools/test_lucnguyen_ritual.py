"""Exercise the real altar and weapon callbacks, including persistence and shots."""
import runpy
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
lua = runpy.run_path(str(ROOT / 'tools/test_lucnguyen_prefab.py'))['lua']
lua.execute(r'''
TheWorld.ismastersim=true
GLOBAL=_G; PrefabFiles={}; posts={}
local function noop() end
Action=function(t) return t end; ActionHandler=noop
AddAction=noop; AddComponentAction=noop; AddStategraphActionHandler=noop
AddComponentPostInit=noop
AddPrefabPostInit=function(name,fn) posts[name]=fn end
RegisterInventoryItemAtlas=noop; AddMinimapAtlas=noop; AddRecipe2=noop
Ingredient=function(...) return {...} end; Vector3=noop; TECH={MAGIC_TWO=2}
STRINGS={NAMES={},RECIPE_DESC={},CHARACTERS={GENERIC={DESCRIBE={}}}}
package.loaded.containers={params={}}
SpawnPrefab=function() return nil end
''')
lua.execute((ROOT / 'main/ttk_rituals.lua').read_text(encoding='utf-8'))
lua.execute(r'''
local item=ttk_lucnguyenkiemdong.fn(); item.prefab='ttk_lucnguyenkiemdong'
local accepts=require('containers').params.ttk_lbjlt.itemtestfn
assert(accepts(nil,item),'altar must accept Luc Nguyen')
assert(accepts(nil,{prefab='lucmachthankiem'}) and accepts(nil,{prefab='vanhonphien'}))
assert(not accepts(nil,{prefab='spear'}))
local altar,player=CreateEntity(),CreateEntity()
altar.components.container={GetItemInSlot=function() return item end}
posts.ttk_lbjlt(altar)
function player:GetDistanceSqToInst() return 0 end
local stones,spent=0,0
player.components.inventory={
 Has=function(_,name,n) assert(name=='ttk_lingshi3');return stones>=n end,
 ConsumeByName=function(_,name,n) stones=stones-n;spent=spent+n end,
}
assert(not altar:Refine(player) and spent==0)
stones=456
for level,cost in ipairs({1,1,1,3,6,12,33,99,300}) do
 local before=spent
 assert(altar:Refine(player),'refinement must succeed')
 assert(item._ttk_ritual_level==level and spent-before==cost)
 assert(not altar:Refine(player),'busy altar must reject duplicate clicks')
 altar:Tick()
end
assert(stones==0 and not altar:Refine(player))
assert(item.components.weapon.damage==50,'ritual must not mutate Solo base damage')
local function shot(w)
 local p=ttk_lucnguyen_primary_projectile.fn()
 w.components.weapon.onprojectilelaunched(w,player,CreateEntity(),p)
 return p
end
local p=shot(item)
assert(math.abs(p._base_damage-72.5)<1e-8 and p.components.weapon.damage==p._base_damage)
local volley=require('ttk_lucnguyen_rules').RollVolley(p._base_damage,function(a,b) return a end)
assert(math.abs(volley[1].damage-7.25)<1e-8,'auxiliary uses refined snapshot once')
local data={};item:OnSave(data)
local restored=ttk_lucnguyenkiemdong.fn();restored:OnLoad(data);restored:OnLoad(data)
assert(restored._ttk_ritual_level==9 and math.abs(shot(restored)._base_damage-72.5)<1e-8)
restored.components.weapon:SetDamage(100)
assert(math.abs(shot(restored)._base_damage-145)<1e-8,'Solo enhanced damage multiplied once')
restored:TTKApplyRitualLevel(1)
assert(p._base_damage==72.5,'in-flight snapshot remains unchanged')
restored:OnLoad({});assert(shot(restored)._base_damage==100,'legacy save defaults to zero')
''')
print('PASS: altar acceptance/costs/busy/max, ritual shots/volley, Solo damage and save-load.')
