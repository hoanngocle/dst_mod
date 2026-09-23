"""Canonical combat catalog and real equipment transactions in DST's Lua 5.1."""
from pathlib import Path
import sys
import unittest
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / '.superpowers/solo-combat-audit/lua-runtime'))
from lupa.lua51 import LuaRuntime, LuaError

GAME = Path("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip")


class CatalogTests(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.globals().package.path = ROOT.joinpath('scripts/?.lua').as_posix() + ';' + self.lua.globals().package.path
        with ZipFile(GAME) as game:
            self.lua.execute(game.read('scripts/class.lua').decode())
        self.lua.execute('''
for _,name in ipairs({'widget','image','text','imagebutton','truescrollarea','uianim'}) do
 package.preload['widgets/'..name]=function() return {} end
end
TUNING={HH_CHANCE_CONFIG={DROP_EQUIP_CHANCE=0,ATK_10s_HEALTH=1}}
EQUIPSLOTS={HANDS='hands',BODY='body',HEAD='head'}
STRINGS={NAMES={}} TheWorld={ismastersim=true,state={},components={}}
GetTime=function() return 0 end SpawnPrefab=function() return nil end
''')
        tuning = (ROOT / 'main/hh_tunning.lua').read_text(encoding='utf-8')
        self.lua.execute(tuning[tuning.index('TUNING["HH_FORMAT_CONFIG"]'):tuning.index('\nTUNING[', tuning.index('TUNING["HH_FORMAT_CONFIG"]') + 1)])
        begin = tuning.index('TUNING["HH_LEVELING"]')
        self.lua.execute(tuning[begin:tuning.index('\nTUNING[', begin + 1)])
        self.lua.execute('''
utils=require('utils/hh_utils')
-- Native RPC, visual effects, and world entities do not exist in this harness.
utils.HHClientRpc=function() end utils.SpawnClientStrFx=function() end utils.SpawnExplodeFx=function() end
catalog=require('enums/hh_enchant') affixes=catalog.HH_EQUIP_BUFF_LIST gems=catalog.HH_GEM_BUFF_LIST
registry=require('enums/hh_effects') items=require('enums/hh_items') buffs=require('enums/hh_buff')
monsters=require('enums/hh_monster') treasures=require('enums/hh_treasure_monster')
HHPlayer=require('components/hh_player') HHEquip=require('components/hh_equip')
HHLeveling=require('components/hh_leveling') HHMonster=require('components/hh_monster')
Math=require('combat/hh_combat_math')
for i=1,100 do
 local name,value=debug.getupvalue(HHPlayer._ctor,i)
 if name==nil then break end
 if name=='b_uG' then update_move_speed=value end
end
function entity(slot)
 local e={prefab='test',components={},events={},removed=false}
 function e:IsValid() return not self.removed end
 function e:HasTag(tag) return tag=='player' and self.components.hh_player~=nil end
 function e:PushEvent(n,data) if self.events[n] then self.events[n](self,data) end end
 function e:ListenForEvent(n,fn) self.events[n]=fn end
 function e:Remove() self.removed=true end
 function e:DoTaskInTime() return {Cancel=function() end} end
 function e:DoPeriodicTask() return {Cancel=function() end} end
 e.Transform={GetWorldPosition=function() return 0,0,0 end}
 if slot then
  e.components.equippable={equipslot=slot,GetWalkSpeedMult=function() return 1 end,IsEquipped=function() return false end}
  e.components.weapon={}
  e.components.wb_strengthen={GetLevel=function() return 10 end}
  e.components.hh_equip=HHEquip(e); e.components.hh_equip:SetEquipBuffLimit(4)
 end
 return e
end
function player()
 local p=entity()
 p.components.health={currenthealth=100,maxhealth=100,IsDead=function() return false end,
  GetPercent=function(s) return s.currenthealth/s.maxhealth end,DoDelta=function(s,n) s.currenthealth=s.currenthealth+n end}
 p.components.sanity={GetPercent=function() return 1 end,DoDelta=function() error('deleted sanity lifesteal') end}
 p.components.hunger={GetPercent=function() return 1 end}
 local effects={} for key in pairs(registry.player) do effects[key]=0 end
 p.components.hh_player=setmetatable({inst=p,hh_effects=effects,hh_items={},hh_suit_effects={}}, {__index=HHPlayer})
 return p
end
function equip_effect(p,id,value)
 local def=assert(affixes[id],'missing affix '..id)
 def.on_equip_fn(entity(EQUIPSLOTS.HANDS),p,value)
end
function forge_pair(donor,receiver)
 local p=player(); local c=p.components.hh_player
 local slots={[2]=donor,[3]=receiver}; local costs={hh_essence=20,nightmarefuel=20}
 c.CanUseForge=function() return true end
 c.forge_container={components={container={GetItemInSlot=function(_,i) return slots[i] end,
  Has=function(_,k,n) return costs[k]>=n end,ConsumeByName=function(_,k,n) costs[k]=costs[k]-n end}}}
 return c,costs
end
function close(a,b) assert(math.abs(a-b)<1e-8,tostring(a)..' ~= '..tostring(b)) end
weapon_groups={'more_damage_30_150','true_damage_small','blood_outburst','add_damage_small',
 'atk_add_poison_small','atk_add_freeze_small','atk_speed_small'}
''')

    def check(self, code):
        try:
            self.lua.execute(code)
        except LuaError as error:
            if "in function 'assert'" in str(error):
                self.fail(str(error))
            raise

    def test_burst_tiers_expose_real_chance_multiplier_and_names(self):
        self.check('''
for _,r in ipairs({{'more_damage_30_150','moreDamage30To150',30,150,'I'},
 {'more_damage_20_200','moreDamage20To200',20,200,'II'},
 {'more_damage_15_300','moreDamage10To300',10,300,'III'},
 {'more_damage_8_500','moreDamage8To500',8,500,'IV'}}) do
 assert(registry.player[r[2]],'missing player effect '..r[2])
 local d=assert(affixes[r[1]],'missing burst '..r[1])
 assert(d.name:find('Bạo Phát '..r[5],1,true),'wrong displayed burst tier')
 local p,t=player(),player(); equip_effect(p,r[1],d.value_range and d.value_range.min)
 assert(p.components.hh_player:GetEffectValueByKey(r[2])==r[4])
 close(p.components.hh_player:DoAttackDamage(p,t,100,function() return r[3] end),r[4])
 close(p.components.hh_player:DoAttackDamage(p,t,100,function() return r[3]+1 end),100)
end
''')

    def test_armor_pierce_and_dragon_ranges_produce_percentage_damage(self):
        self.check('''
for _,r in ipairs({{'small',3,5},{'med',6,10},{'big',11,15},{'special',16,20}}) do
 local id='true_damage_'..r[1]; local d=affixes[id]
 assert(d.value_range.min==r[2] and d.value_range.max==r[3],id..' range')
 local p=player(); equip_effect(p,id,r[3])
 assert(p.components.hh_player:GetEffectValueByKey('trueDamageNum')==r[3])
 local dragon=r[1]=='special' and 'special_bhtg' or 'add_damage_'..r[1]
 d=affixes[dragon]; assert(d.value_range.min==r[2] and d.value_range.max==r[3],dragon..' range')
 p=player(); equip_effect(p,dragon,r[3]); local t=player()
 close(p.components.hh_player:DoAttackDamage(p,t,200),200*(1+r[3]/100))
 assert(p.components.hh_player:GetEffectValueByKey('targetPercentDamage')==(r[1]=='special' and 3 or 0))
end
''')

    def test_burst_tiers_use_only_the_real_legendary_pool_at_equal_weight(self):
        source = (ROOT / 'main/hh_rpc.lua').read_text(encoding='utf-8')
        start = source.index('_G["HHGetGoodEquipEffect"] = function()')
        end = source.index('_G["HHSpawnComEffectStone"] = function()', start)
        self.lua.execute('local uFkUkCfKf=affixes\n' + source[start:end])
        self.check('''
local common,good,rare=HHGetComEquipEffect(),HHGetGoodEquipEffect(),HHGetRareEquipEffect()
local tiers={'more_damage_30_150','more_damage_20_200','more_damage_15_300','more_damage_8_500'}
for _,id in ipairs(tiers) do
 assert(affixes[id].can_add==false and affixes[id].only_compound==true,id..' is not legendary')
 for _,pool in ipairs({common,good}) do
  for _,candidate in ipairs(pool) do assert(candidate~=id,id..' leaked into lower rarity') end
 end
 local count=0;for _,candidate in ipairs(rare) do if candidate==id then count=count+1 end end
 assert(count==1,id..' must occur exactly once in the rare pool')
end
local selected={};SpawnPrefab=function(name) assert(name=='hh_effect_stone');return {} end
for index=1,#rare do
 math.random=function(lo,hi) assert(lo==1 and hi==#rare);return index end
 local stone=HHSpawnRareEffectStone();selected[stone.hh_effect]=(selected[stone.hh_effect] or 0)+1
end
for _,id in ipairs(tiers) do assert(selected[id]==1,id..' does not have equal rare-stone weight') end
''')

    def test_poison_and_freeze_chances_reach_canonical_player_keys(self):
        self.check('''
for i,tier in ipairs({'small','med','big','special'}) do
 for _,r in ipairs({{'atk_add_poison_','atkAddPoisonChance',10},{'atk_add_freeze_','atkChanceAddFreeze',5}}) do
  local p=player(); equip_effect(p,r[1]..tier)
  assert(p.components.hh_player:GetEffectValueByKey(r[2])==i*r[3],r[1]..tier)
 end
end
''')

    def test_all_seven_groups_are_hand_only_and_exclusive(self):
        self.check('''
for group,ids in pairs({burst={'more_damage_30_150','more_damage_8_500'},
 armor_pierce={'true_damage_small','true_damage_special'},adversity={'blood_outburst','spirit_fade','hunger_assault'},
 dragon_damage={'add_damage_small','special_bhtg'},poison={'atk_add_poison_small','atk_add_poison_special'},
 freeze={'atk_add_freeze_small','atk_add_freeze_special'},attack_speed={'atk_speed_small','atk_speed_special'}}) do
 for _,id in ipairs(ids) do
  local def=assert(affixes[id],id)
  assert(def.slot=='hand' and def.exclusive_group==group,id..' metadata')
  for _,slot in ipairs({EQUIPSLOTS.BODY,EQUIPSLOTS.HEAD}) do
   local e=entity(slot); assert(not e.components.hh_equip:AddEquipBuff(id),id..' must reject '..slot)
  end
 end
 local e=entity(EQUIPSLOTS.HANDS); assert(e.components.hh_equip:AddEquipBuff(ids[1]))
 assert(not e.components.hh_equip:AddEquipBuff(ids[2]),group..' duplicate allowed')
 assert(e.components.hh_equip:GetEffectsNum()==1)
 for _,id in ipairs(e.components.hh_equip:GetAllBuffByEquip()) do
  assert(affixes[id].exclusive_group~=group,'random candidate conflict '..group)
 end
end
''')

    def test_nonweapon_hands_reject_explicit_stones_without_consumption(self):
        self.check('''
for _,id in ipairs(weapon_groups) do
 local e=entity(EQUIPSLOTS.HANDS);e.components.weapon=nil
 local c=player().components.hh_player
 local stone=entity();stone.prefab='hh_effect_stone';stone.hh_effect=id
 stone.HasTag=function(_,tag) return tag=='hh_add_stone' end
 c.ui_container={components={container={GetItemInSlot=function(_,i) return i==25 and e or stone end}}}
 assert(not c:AddEquipEffect(),'nonweapon HANDS accepted '..id)
 assert(not stone.removed and e.components.hh_equip:GetEffectsNum()==0,'invalid stone mutated receiver')
end
''')

    def test_nonweapon_hands_excludes_all_weapon_random_candidates(self):
        self.check('''
local e=entity(EQUIPSLOTS.HANDS);e.components.weapon=nil
for _,id in ipairs(e.components.hh_equip:GetAllBuffByEquip()) do
 assert(affixes[id].exclusive_group==nil,'nonweapon random weapon candidate '..id)
end
assert(e.components.hh_equip:GetEffectsNum()==0)
''')

    def test_nonweapon_hands_rejects_refresh_without_mutation_or_cost(self):
        self.check('''
for _,id in ipairs(weapon_groups) do
 local e=entity(EQUIPSLOTS.HANDS);e.components.weapon=nil
 local value=affixes[id].value_range and affixes[id].value_range.min or 1
 e.components.hh_equip.equip_buff_list={{name=id,value=value}}
 local c=player().components.hh_player;c.hh_items.ac_refreshStone=1
 c.ui_container={components={container={GetItemInSlot=function() return e end}}}
 assert(not c:UpdateEffectValue(),'nonweapon refresh accepted '..id)
 assert(c.hh_items.ac_refreshStone==1 and e.components.hh_equip:GetEffectValue(id)==value)
end
''')

    def test_nonweapon_hands_rejects_inheritance_without_mutation_or_cost(self):
        self.check('''
for _,id in ipairs(weapon_groups) do
 local donor,receiver=entity(EQUIPSLOTS.HANDS),entity(EQUIPSLOTS.HANDS)
 assert(donor.components.hh_equip:AddEquipBuff(id));receiver.components.weapon=nil
 local c,costs=forge_pair(donor,receiver)
 assert(not c:EquipEffectInherit(),'nonweapon inheritance accepted '..id)
 assert(not donor.removed and receiver.components.hh_equip:GetEffectsNum()==0)
 assert(costs.hh_essence==20 and costs.nightmarefuel==20,'invalid inheritance consumed materials')
end
''')

    def test_second_group_stone_is_not_consumed(self):
        self.check('''
local p,e=player(),entity(EQUIPSLOTS.HANDS); local c=p.components.hh_player
assert(e.components.hh_equip:AddEquipBuff('true_damage_small'))
local stone=entity();stone.prefab='hh_effect_stone';stone.hh_effect='true_damage_med'
stone.HasTag=function(_,tag) return tag=='hh_add_stone' end
c.ui_container={components={container={GetItemInSlot=function(_,i) return i==25 and e or stone end}}}
assert(not c:AddEquipEffect(),'second penetration tier must reject')
assert(not stone.removed and e.components.hh_equip:GetEffectsNum()==1,'rejection consumed stone or changed item')
''')

    def test_inherit_rejects_slot_and_duplicate_groups_atomically(self):
        self.check('''
for _,slot in ipairs({EQUIPSLOTS.BODY,EQUIPSLOTS.HEAD,EQUIPSLOTS.HANDS}) do
 local a,b=entity(EQUIPSLOTS.HANDS),entity(slot)
 a.components.hh_equip.equip_buff_list={{name='true_damage_small',value=3}}
 if slot==EQUIPSLOTS.HANDS then table.insert(a.components.hh_equip.equip_buff_list,{name='true_damage_med',value=6}) end
 local c,costs=forge_pair(a,b)
 assert(not c:EquipEffectInherit(),'invalid inherited catalog accepted')
 assert(not a.removed and b.components.hh_equip:GetEffectsNum()==0)
 assert(costs.hh_essence==20 and costs.nightmarefuel==20,'inherit consumed materials')
end
local a,b=entity(EQUIPSLOTS.HANDS),entity(EQUIPSLOTS.HANDS)
assert(a.components.hh_equip:AddEquipBuff('true_damage_small',4))
local c,costs=forge_pair(a,b);assert(c:EquipEffectInherit())
assert(a.removed and costs.hh_essence==0 and costs.nightmarefuel==0 and b.components.hh_equip:GetEffectValue('true_damage_small')==4)
''')

    def test_refresh_rejects_invalid_receiver_before_mutation_or_cost(self):
        self.check('''
for _,slot in ipairs({EQUIPSLOTS.BODY,EQUIPSLOTS.HEAD,EQUIPSLOTS.HANDS}) do
 local e=entity(slot); local c=player().components.hh_player
 e.components.hh_equip.equip_buff_list={{name='true_damage_small',value=3}}
 if slot==EQUIPSLOTS.HANDS then table.insert(e.components.hh_equip.equip_buff_list,{name='true_damage_med',value=6}) end
 c.ui_container={components={container={GetItemInSlot=function() return e end}}}
 c.hh_items.ac_refreshStone=1
 assert(not c:UpdateEffectValue(),'refresh accepted invalid slot/group')
 assert(c.hh_items.ac_refreshStone==1 and e.components.hh_equip:GetEffectValue('true_damage_small')==3)
end
''')

    def test_speed_ranges_gems_and_server_client_caps(self):
        self.check('''
for _,r in ipairs({{'small',5,10},{'med',15,25},{'big',30,45},{'special',50,70}}) do
 local d=affixes['atk_speed_'..r[1]];assert(d.value_range.min==r[2] and d.value_range.max==r[3])
end
assert(affixes.add_speed.value_range.min==5 and affixes.add_speed.value_range.max==25)
local p=player();gems.strideBead.on_equip_fn(nil,p);gems.baconOmeletteSpeed.on_equip_fn(nil,p)
assert(p.components.hh_player:GetEffectValueByKey('addSpeedPercent')==9)
for _,r in ipairs({{-50,1},{0,1},{50,1.5},{100,2},{500,2}}) do
 p.components.hh_player.hh_effects.atk_speed=r[1];close(utils:GetWeaponAtkSpeed(p),r[2])
 local client=entity();client.components.hh_client={GetValue=function(_,k) assert(k=='hh_atk_speed');return tostring(r[1]) end}
 close(utils:GetWeaponAtkSpeed(client),r[2])
end
local external={vanilla=1.25}
p.components.locomotor={SetExternalSpeedMultiplier=function(_,_,key,n) external[key]=n end,
 RemoveExternalSpeedMultiplier=function(_,_,key) external[key]=nil end}
p.components.hh_player.hh_effects.addSpeedPercent=500; update_move_speed(p)
assert(external.hh_equip_speed==1.5 and external.vanilla==1.25)
''')

    def test_attack_gems_coexist_and_splash_is_twenty_per_gem(self):
        self.check('''
local e,p=entity(EQUIPSLOTS.HANDS),player();local c=e.components.hh_equip
c.gem_current_limit=3;c.gem_max_limit=3
assert(c:AddNewGem('treasure_atk'));assert(c:AddNewGem('baconOmeletteBlessAtk'))
for _,id in ipairs(c.gems_list) do gems[id].on_equip_fn(e,p) end
close(p.components.hh_player:DoAttackDamage(p,player(),100),135)
gems.treasure_atk.un_equip_fn(e,p);close(p.components.hh_player:DoAttackDamage(p,player(),100),120)
for i=1,4 do gems.baconOmeletteAOE.on_equip_fn(e,p) end
assert(p.components.hh_player:GetEffectValueByKey('addSplashDamageAOE')==60,'aggregate splash cap')
''')

    def test_str_vit_boundaries_and_reversible_penetration_cap(self):
        self.check('''
for _,r in ipairs({{0,0},{1,.1},{200,20},{500,20}}) do
 local p=player();local level=HHLeveling(p);level.stat_str=r[1];level:ApplyAllStats()
 close(p.components.hh_player:GetEffectValueByKey('trueDamageNum'),r[2])
end
local p=player();local level=HHLeveling(p)
for i=1,500 do level.stat_str=i;level:ApplyStat('str') end
close(p.components.hh_player:GetEffectValueByKey('trueDamageNum'),20)
p.components.hh_player:AddEffectValueByKey('trueDamageNum',30)
assert(p.components.hh_player:GetEffectValueByKey('trueDamageNum')==40)
p.components.hh_player:ReduceEffectValueByKey('trueDamageNum',30)
close(p.components.hh_player:GetEffectValueByKey('trueDamageNum'),20)
for _,r in ipairs({{0,0},{1,1},{80,80},{200,80}}) do
 p=player();level=HHLeveling(p);level.stat_vit=r[1];level:ApplyAllStats()
 close(p.components.hh_player:GetPhamNhanReduction(),r[2])
 close(p.components.hh_player:GetBlockDamage(p,player(),100),100-r[2])
end
''')

    def test_adversity_uses_attackers_resource_before_critical_only_once(self):
        self.check('''
for _,r in ipairs({{'blood_outburst','health'},{'spirit_fade','sanity'},{'hunger_assault','hunger'}}) do
 for _,v in ipairs({{1,100},{.5,125},{0,150},{-.1,150},{1.1,100}}) do
  local p,t=player(),player();equip_effect(p,r[1]);p.components[r[2]].GetPercent=function() return v[1] end
  t.components[r[2]].GetPercent=function() error('target resources must not be read') end
  close(p.components.hh_player:DoAttackDamage(p,t,100),v[2])
 end
end
''')

    def test_other_penetration_and_defense_producers_use_percentage_pools(self):
        self.check('''
local p=player();gems.baconOmeletteTrueDamage.on_equip_fn(nil,p)
assert(p.components.hh_player:GetEffectValueByKey('trueDamageNum')==20)
gems.baconOmeletteTrueDamage.un_equip_fn(nil,p)
catalog.HH_SUIT_LIST.suit_zqrf.start_fn(p)
assert(p.components.hh_player:GetEffectValueByKey('trueDamageNum')==10)
catalog.HH_SUIT_LIST.suit_zqrf.stop_fn(p)
for _,r in ipairs({{'reduce_damage_small',5},{'reduce_damage_mid',10},{'reduce_damage_big',15}}) do
 p=player();equip_effect(p,r[1],r[2]);assert(p.components.hh_player:GetPhamNhanReduction()==r[2],r[1])
end
p=player();gems.resistDamageGem.on_equip_fn(nil,p);assert(p.components.hh_player:GetPhamNhanReduction()==5)
p=player();equip_effect(p,'special_sgsy',1);assert(p.components.hh_player:GetPhamNhanReduction()==80)
local defs=require('ttk_boss_defs').bosses;assert(defs.baihu.gain==4 and defs.baihu.stat=='trueDamageNum')
assert(defs.stalke_fuben.stat=='absorbDamage')
''')

    def test_dungeon_player_bonuses_join_caps_and_expire_reversibly(self):
        self.check('''
local p=player();local c=p.components.hh_player
local external={vanilla=1.25}
p.components.locomotor={SetExternalSpeedMultiplier=function(_,_,key,n) external[key]=n end,
 RemoveExternalSpeedMultiplier=function(_,_,key) external[key]=nil end}
p.events.handle_equip_to_player=update_move_speed
local d=require('components/hh_dungeon_effects')(p)
c:AddEffectValueByKey('absorbDamage',75);c:AddEffectValueByKey('atk_speed',95);c:AddEffectValueByKey('addSpeedPercent',45)
d:AddEffect('player_guard',10);d:AddEffect('player_allround',10)
d:AddEffect('player_speed',10);d:AddEffect('player_attack_speed',10)
assert(c:GetPhamNhanReduction()==80 and c:GetEffectValueByKey('atk_speed')==107)
assert(external.hh_equip_speed==1.5 and external.vanilla==1.25)
close(utils:GetWeaponAtkSpeed(p),2)
GetTime=function() return 11 end;d:Update()
assert(c:GetPhamNhanReduction()==75 and c:GetEffectValueByKey('atk_speed')==95)
close(external.hh_equip_speed,1.45)
''')

    def test_deleted_runtime_offense_cannot_trigger_from_injected_old_keys(self):
        self.check('''
local p,t=player(),player();local c=p.components.hh_player
for _,key in ipairs({'soakStrike','sunlightStrike','afterglowStrike','nightMenace','addHitPigDamage','attackToAddHealth','restoreSpirit'}) do
 c.hh_effects[key]=100
end
TheWorld.state.isday=true;t.HasHHTag=function() return true end
p.components.moisture={GetMoisturePercent=function() return 100 end}
p.components.hh_buff={AddBuff=function() assert(false,'deleted attack healing proc') end}
close(c:DoAttackDamage(p,t,100),100)
c:HandleBloodSuck(100,'primary')
''')

    def test_deleted_player_keys_sources_and_sets_are_absent(self):
        self.check('''
for _,key in ipairs({'soakStrike','sunlightStrike','afterglowStrike','nightMenace','sanReplaceDamageChance',
 'reflexiveInjury','reflexiveInjuryByPercent','attackToAddHealth','restoreSpirit','hitSuppressAddHealth',
 'hitChanceAddFreeze','atkChanceAddPoison','hitChanceAddPoison','atkSpeedatkSpeed','immuneBramble','reduceBrambleDamage'}) do
 assert(registry.player[key]==nil,'deleted player key '..key)
end
for key in pairs(registry.player) do assert(not key:match('^addHit.*Damage$'),key) end
for _,id in ipairs({'damageBoostGem','retaliateGem','shadowNightBead','twilightBead','dayShineBead',
 'spiderVengeance','insectStrikeCrystal','shadowStrikeLuminary','bossStrikeGem'}) do
 assert(items[id]==nil and gems[id]==nil,'deleted gem '..id)
end
for _,id in ipairs({'san_replace_damage_small','san_replace_damage_big','reflexive_injury_small','reflexive_injury_med',
 'reflexive_injury_big','reflexive_injury_special','add_day_damage','add_dusk_damage','add_night_damage','atk_add_san','immune_bramble'}) do
 assert(affixes[id]==nil,'deleted affix '..id)
end
for _,id in ipairs({'suit_bhtg','suit_fyyy','suit_yhby'}) do
 assert(catalog.HH_SUIT_LIST[id]==nil and buffs[id]==nil and buffs[id..'_cd']==nil,id)
 for _,slot in ipairs({'hand','body','hat'}) do
  local mark='z_'..id..'_'..slot
  assert(registry.player[mark]==nil and affixes[mark]==nil,mark)
  for _,recipe in ipairs(catalog.HH_SUIT_RECIPE) do assert(recipe.id~=mark,mark..' recipe') end
 end
end
assert(affixes.special_bhtg and items.aa_punchStone and items.ac_refreshStone,'shared forge catalog retained')
''')

    def test_deleted_gem_material_routes_are_absent(self):
        self.check('''
local fan=entity()
function fan:AddComponent(name)
 if name=='container' then self.components.container={WidgetSetup=function() end}
 elseif name=='spellcaster' then self.components.spellcaster={SetSpellFn=function(s,fn) s.spell=fn end} end
end
require('enums/hh_equip').hh_quat_long_vu.start_fn(fan)
local materials
for i=1,100 do
 local name,value=debug.getupvalue(fan.components.spellcaster.spell,i)
 if name==nil then break end
 if name=='BU__G__' then materials=value end
end
assert(materials,'real forge material catalog missing')
for _,material in ipairs({'steelwool','lightninggoathorn','silk','stinger'}) do
 assert(materials[material]==nil,'deleted gem material '..material)
end
assert(materials.gears=='ab_decoderStone' and materials.horn=='aa_punchStone'
 and materials.greengem=='ac_refreshStone','shared forge stones removed')
''')

    def test_deleted_attack_heal_buff_cannot_register_or_schedule_healing(self):
        self.check('''
local p=player();local scheduled={};local visuals=0
p.StartUpdatingComponent=function() end
p.DoPeriodicTask=function(_,period,fn) scheduled[#scheduled+1]=fn;return {Cancel=function() end} end
utils.TableToStr=function() return '{}' end
utils.SpawnClientStrFx=function() visuals=visuals+1 end
local component=require('components/hh_buff')(p)
assert(not component:AddBuff('buff_10s_1_health',120),'removed attack-heal buff still registers')
assert(not component:HasBuff('buff_10s_1_health') and #scheduled==0 and visuals==0)
assert(TUNING.HH_FORMAT_CONFIG.BUFF.buff_10s_1_health==nil,'removed attack-heal description remains')
assert(component:AddBuff('add_health',10),'generic health buff removed')
assert(#scheduled==1);scheduled[1]()
assert(p.components.health.currenthealth==101 and visuals==0,'generic health regeneration changed')
''')

    def test_player_suppression_tooltips_name_healing_reduction_not_burning(self):
        self.check('''
assert(registry.player.addSuppressAddHealth.name=='Giảm Hồi Máu','player suppression uses burning label')
assert(registry.player.immuneSuppressNum.name=='Miễn Giảm Hồi Máu','player immunity uses burning label')
assert(affixes.health_suppress_num.name=='Giảm Hồi Máu','suppression affix uses burning label')
assert(affixes.immune_suppress.name=='Miễn Giảm Hồi Máu','immunity affix uses burning label')
for _,desc in ipairs({string.format(affixes.health_suppress_num.desc,30),affixes.immune_suppress.desc,
 gems.elementBead.name,gems.eightPigGem.name}) do
 assert(desc:find('Giảm Hồi Máu',1,true),'suppression tooltip missing canonical mechanic')
 assert(not desc:find('thiêu đốt',1,true),'suppression tooltip still claims burning')
end
assert(gems.treasure_fireGem.name:find('thiêu đốt',1,true),'unrelated fire damage description changed')
''')

    def test_player_gem_guide_matches_percentage_bonuses(self):
        source = (ROOT / 'main/hh_tunning.lua').read_text(encoding='utf-8')
        start = source.index('TUNING["HH_UI_TEXT"] = {')
        end = source.index('TUNING["WW_INFERNALSTAFF"]', start)
        self.lua.execute('local function ffguncfKk() return "" end\n' + source[start:end])
        self.check('''
local guide=TUNING.HH_UI_TEXT.UI_ITEMS.ui_role_4
for _,expected in ipairs({'Bảo★Sát: Tăng 15% sát thương đòn chính',
 'Siêu★Sát: Tăng 20% sát thương đòn chính','Siêu★Xuyên: 20% sát thương đòn chính bỏ qua giáp',
 'Miễn Giảm Hồi Máu'}) do
 assert(guide:find(expected,1,true),'stale player gem guide: '..expected)
end
assert(not guide:find('thiêu đốt',1,true),'gem immunity still claims burning')
''')

    def test_player_gem_guide_omits_deleted_gems_and_material_routes(self):
        source = (ROOT / 'main/hh_tunning.lua').read_text(encoding='utf-8')
        start = source.index('TUNING["HH_UI_TEXT"] = {')
        end = source.index('TUNING["WW_INFERNALSTAFF"]', start)
        self.lua.execute('local function ffguncfKk() return "" end\n' + source[start:end])
        self.check('''
local guide=TUNING.HH_UI_TEXT.UI_ITEMS
assert(guide.ui_role_2:find('Đá giảm thương: Giảm 5% sát thương nhận vào',1,true),'defense gem guide still claims flat mitigation')
local all=guide.ui_role_2..guide.ui_role_3..guide.ui_role_6
for _,deleted in ipairs({'Đá sát thương','Đá phản đòn','Đá tối','Đá chiều','Đá sáng',
 'Đá nhện','Đá côn trùng','Đá bóng tối','Đá Boss','Sừng Dê:','Tơ Nhện:','Nọc ong:','Lông Cừu:'}) do
 assert(not all:find(deleted,1,true),'deleted guide entry '..deleted)
end
for _,kept in ipairs({'Đá bền bỉ','Đá sức mạnh','Đá giảm thương','Đá chí mạng','Đá thú chí',
 'Đá thú sát','Đá thú ngự','Bánh Răng:','Sừng Bò:','Ngọc Lục:','Ngọc Đỏ:','Đá Cát:'}) do
 assert(all:find(kept,1,true),'surviving guide entry removed '..kept)
end
''')

    def test_deleted_flat_tag_description_is_absent(self):
        self.check("assert(TUNING.HH_FORMAT_CONFIG.EQUIP_EFFECT.add_hit_damage_fish==nil,'deleted fish damage description')")

    def test_custom_reflection_visual_helper_is_absent(self):
        self.check("assert(utils.SpawnBrambleFx==nil,'deleted custom reflection helper remains')")

    def test_boss_food_bonuses_join_capped_player_reads(self):
        self.lua.execute('''
env={} PrefabFiles={} Assets={}
Asset=function() return {} end RegisterInventoryItemAtlas=function() end
STRINGS.CHARACTERS={GENERIC={DESCRIBE={}}}
component_hooks={}
AddComponentPostInit=function(name,fn) component_hooks[name]=fn end
AddPlayerPostInit=function() end
''')
        self.lua.execute((ROOT / 'main/ttk_boss_food.lua').read_text(encoding='utf-8'))
        self.check('''
local p=player();local c=p.components.hh_player
local progress=require('components/ttk_bossprogress')(p);p.components.ttk_bossprogress=progress
progress.counts.baihu=10;progress.counts.stalke_fuben=10
c:AddEffectValueByKey('trueDamageNum',30);c:AddEffectValueByKey('absorbDamage',75)
component_hooks.hh_player(c)
assert(c:GetEffectValueByKey('trueDamageNum')==40,'boss-food bypasses penetration cap: '..c:GetEffectValueByKey('trueDamageNum'))
assert(c:GetEffectValueByKey('absorbDamage')==80,'boss-food bypasses mitigation cap')
c:ReduceEffectValueByKey('trueDamageNum',30);c:ReduceEffectValueByKey('absorbDamage',75)
assert(c:GetEffectValueByKey('trueDamageNum')==40,'raw food bonus should survive unequip')
assert(c:GetEffectValueByKey('absorbDamage')==progress:GetEffectBonus('absorbDamage'))
''')

    def test_six_treasure_bosses_award_one_stone_at_every_reward_boundary(self):
        self.check('''
local bosses={'mutateddeerclops_boss','mutatedbearger_boss','mutatedwarg_boss',
 'hh_beetle_pig_boss','hh_sharkboi_boss','hh_dual_wield_pig_boss'}
local probes={{0,'restore_use_1s_2_percent'},{.1,'restore_use_1s_2_percent'},
 {.100001,'armor_immune_amount'},{.2,'armor_immune_amount'},
 {.200001,'add_critical_hit_rate_special'},{.3,'add_critical_hit_rate_special'},
 {.300001,'true_damage_special'},{.35,'true_damage_special'},{.4,'true_damage_special'},
 {.400001,'true_damage_special'},{.5,'true_damage_special'},
 {.500001,'atk_speed_special'},{.6,'atk_speed_special'},
 {.600001,'special_xwsh'},{.7,'special_xwsh'},
 {.700001,'special_zqrf'},{.8,'special_zqrf'},
 {.800001,'special_sgsy'},{.9,'special_sgsy'},
 {.900001,'special_bhtg'},{1,'special_bhtg'}}
for _,boss in ipairs(bosses) do
 for _,probe in ipairs(probes) do
  local awarded={}
  HHSpawnStoneById=function(id) awarded[#awarded+1]=id;return nil end
  math.random=function() return probe[1] end
  treasures.TREASURE_MONSTER_CONFIG[boss].death_fn(entity())
  assert(#awarded==1,boss..' must award one stone at '..probe[1])
  assert(awarded[1]==probe[2],boss..' wrong reward at '..probe[1])
 end
end
''')

    def test_treasure_pig_modifier_producer_drops_custom_reflection(self):
        self.check('''
local pig=entity();local requested={}
pig.components.hh_monster={SetMaxEffectLimit=function() end,
 AddBuffByName=function(_,name) requested[name]=true end}
treasures.TREASURE_MONSTER_CONFIG.pig_buff.start_fn(pig)
assert(requested.addReboundDamageNum==nil,'treasure pig still produces custom rebound')
assert(requested.hitAddPoison and requested.hitChanceAddFreeze,'monster poison/freeze must remain')
''')

    def test_monster_reflection_removed_but_status_registries_preserved(self):
        self.check('''
assert(registry.monster.reboundDamageNum==nil and registry.monster.reboundDamagePercent==nil)
for _,entries in pairs(monsters) do
 if type(entries)=='table' then assert(entries.addReboundDamageNum==nil and entries.reboundDamagePercent==nil) end
end
for _,key in ipairs({'atkChanceAddPoison','hitChanceAddPoison','atkChanceAddFreeze','hitChanceAddFreeze'}) do
 assert(registry.monster[key],key..' monster status removed')
end
local victim,attacker=player(),player();victim.components.hh_player=nil
local c=setmetatable({inst=victim,hh_effects={reboundDamageNum=100,reboundDamagePercent=100}}, {__index=HHMonster})
attacker.components.combat={GetBrambleFx=function() error('deleted custom reflection fired') end}
close(c:GetBlockDamage(victim,attacker,100),100)
''')


if __name__ == '__main__':
    unittest.main()
