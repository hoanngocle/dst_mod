"""Real Lua combat methods, with the installed DST GetAttacked at the boundary."""
from pathlib import Path
import os
import sys
import unittest
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path(os.environ.get('PHAM_NHAN_PIPELINE_BASELINE', str(ROOT)))
sys.path.insert(0, str(ROOT.parents[1] / '.superpowers/solo-combat-audit/lua-runtime'))
from lupa.lua51 import LuaRuntime

GAME = Path("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip")


class PipelineTests(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.globals().package.path = ROOT.joinpath('scripts/?.lua').as_posix() + ';' + self.lua.globals().package.path
        self.lua.globals().package.path = SOURCE.joinpath('scripts/?.lua').as_posix() + ';' + self.lua.globals().package.path
        with ZipFile(GAME) as game:
            self.lua.execute(game.read('scripts/class.lua').decode())
            self.lua.globals().sp_source = game.read('scripts/components/spdamageutil.lua').decode()
            combat = game.read('scripts/components/combat.lua').decode()
            start = combat.index('function Combat:GetAttacked(')
            self.lua.globals().combat_source = combat[start:combat.index('\nfunction ', start + 1)]
            start = combat.index('function Combat:ApplyConditionExternalDamageTakenMultiplier(')
            self.lua.globals().condition_source = combat[start:combat.index('\nfunction ', start + 1)]
        self.lua.execute(r'''
package.preload['components/spdamageutil'] = function() return assert(loadstring(sp_source))() end
utils = {
 IsHHType=function(_,v,t) return type(v)==t end,
 HasComponents=function(_,v,k) return v~=nil and v.components~=nil and v.components[k]~=nil end,
 SpawnClientStrFx=function() end, SpawnExplodeFx=function() end, SpawnShadowFx=function() end,
 IsValidCombat=function() return false end, GetKillCreditPlayer=function() return nil end,
 NotIsDead=function(self,v) return v~=nil and v:IsValid() and self:HasComponents(v,'health') and not v.components.health:IsDead() end,
}
package.preload['utils/hh_utils']=function() return utils end
package.preload['guild/hh_rank_defs']=function() return {RANK={A='A',B='B'}} end
package.preload['enums/hh_effects']=function() return {player={},monster={}} end
package.preload['enums/hh_items']=function() return {} end
package.preload['enums/hh_enchant']=function() return {HH_EQUIP_BUFF_LIST={},HH_GEM_BUFF_LIST={},HH_SUIT_LIST={},HH_SUIT_RECIPE={}} end
package.preload['enums/hh_prefab_list']=function() return {boss_monster={},endgameboss_monster={},elite_monster={}} end
package.preload['enums/hh_monster']=function() return {} end
package.preload['enums/hh_treasure_monster']=function() return {TREASURE_MONSTER_CONFIG={}} end
package.preload['utils/hh_monster_autostack']=function() return {} end
TUNING={HH_CHANCE_CONFIG={ATK_10s_HEALTH=0,DROP_EQUIP_CHANCE=0}}
TheWorld={state={},ismastersim=true,components={}}
STRINGS={} DEGREES=math.pi/180 GetTime=function() return 0 end
SpawnPrefab=function() return nil end
HHPlayer=require('components/hh_player') HHMonster=require('components/hh_monster')
-- Keep the real constructor's registered onhitother callback without spawning
-- inventory containers or scheduling unrelated world initialization tasks.
for i=1,100 do
 local name,value=debug.getupvalue(HHPlayer._ctor,i)
 if name==nil then break end
 if name=='_b__U__g' then player_onhitother=value end
end
Context=require('combat/hh_combat_context')
Combat={} assert(loadstring('local SpDamageUtil=require("components/spdamageutil"); '..combat_source))()
assert(loadstring(condition_source))()
hooks={} AddComponentPostInit=function(name,fn) hooks[name]=fn end
function entity(kind,effects)
 local e={prefab=kind or 'target',components={},events={},Transform={GetWorldPosition=function() return 0,0,0 end}}
 function e:IsValid() return true end
 function e:HasTag() return false end
 function e:IsInLimbo() return false end
 function e:DoPeriodicTask() return {Cancel=function() end} end
 function e:PushEvent(name,data)
  self.events[name]=data
  if name=='onhitother' and self._onhitother~=nil then self._onhitother(self,data) end
 end
 e.components.health={currenthealth=10000,maxhealth=10000,
  IsDead=function(s) return s.currenthealth<=0 end, IsInvincible=function(s) return s.invincible end,
  GetPercent=function(s) return s.currenthealth/s.maxhealth end,
  DoDelta=function(s,n) local old=s.currenthealth; s.currenthealth=math.max(s.floor or 0,old+n); return s.currenthealth-old end}
 if kind=='hh_player' or kind=='hh_monster' then
  local cls=kind=='hh_player' and HHPlayer or HHMonster
  local c=setmetatable({inst=e,hh_effects=effects or {},hh_suit_effects={}}, {__index=cls})
  e.components[kind]=c
 end
 return e
end
function install(e,original)
 local c={inst=e,externaldamagetakenmultipliers={Get=function() return 1 end},
  ApplyConditionExternalDamageTakenMultiplier=Combat.ApplyConditionExternalDamageTakenMultiplier,
  ShouldRecoil=function(_,a,w,d) return false,d end}
 c.GetAttacked=original or function(s,a,d,w,st,sp,...)
  s.calls=(s.calls or 0)+1; s.normal=d; s.special=sp; s.metadata=Context.Current(a,e)
  return Combat.GetAttacked(s,a,d,w,st,sp,...)
 end
 e.components.combat=c; hooks.combat(c); return c
end
function rolls(values)
 trace={}; rng_phase='offense'; local i=0
 math.random=function(lo,hi)
  assert(lo==1 and hi==100,'percentage rolls must use [1,100]')
  i=i+1; table.insert(trace,rng_phase); assert(values[i], 'unexpected RNG'); return values[i]
 end
end
''')
        api = (SOURCE / 'main/hh_api.lua').read_text(encoding='utf-8')
        begin = api.index('local HH_FOLLOWER_CRITICAL_PREFABS')
        end = api.index('        return (218 * 480 * 238 ~= 24904329)', begin)
        health = api.index('AddComponentPostInit(\n    "health",')
        self.lua.execute('local cffUucfkn=utils\n' + api[health:begin])
        self.lua.execute('local cffUucfkn=utils\n' + api[begin:end] + '\nend)')

    def check(self, code):
        try:
            self.lua.execute(code)
        except Exception as error:
            self.fail(str(error))

    def test_achievement_effects_contribute_without_exceeding_combat_caps(self):
        self.check('''
local player=entity('hh_player',{
 trueDamageNum=35, absorbDamage=70, addSplashDamageAOE=55, criticalHitRate=5,
})
player.ttk_achievement_effects={
 trueDamageNum=20, absorbDamage=20, addSplashDamageAOE=20, criticalHitRate=7,
}
local effects=player.components.hh_player
assert(effects:GetEffectValueByKey('trueDamageNum')==40)
assert(effects:GetEffectValueByKey('absorbDamage')==80)
assert(effects:GetEffectValueByKey('addSplashDamageAOE')==60)
assert(effects:GetEffectValueByKey('criticalHitRate')==12)

effects.hh_effects.trueDamageNum=nil
player.ttk_achievement_effects.trueDamageNum=55
assert(effects:GetEffectValueByKey('trueDamageNum')==40,
 'achievement-only fallback must obey the combat cap')
''')

    def test_missing_health_and_dead_entities_skip_procs(self):
        self.check('''
for _,mode in ipairs({'missing','attacker_dead','target_dead'}) do
 local a,t=entity('hh_player',{criticalHitRate=100}),entity()
 if mode=='missing' then a.components.health=nil elseif mode=='attacker_dead' then a.components.health.currenthealth=0 else t.components.health.currenthealth=0 end
 assert(a.components.hh_player:DoAttackDamage(a,t,100)==100)
 local c=install(t,function(s,_,damage) s.normal=damage; return true end)
 assert(c:GetAttacked(a,100)==true and c.normal==100)
end
''')

    def test_dodge_precedes_all_offensive_rng(self):
        self.check('''
local a=entity('hh_player',{criticalHitRate=1,moreDamage8To500=500})
local t=entity('hh_player',{chanceDodgeAttack=70}) local c=install(t)
local original=t.components.hh_player.TryDodge
if original then t.components.hh_player.TryDodge=function(self,...)
 rng_phase='dodge'; local result=original(self,...); rng_phase='offense'; return result
end end
rolls({70}); assert(c:GetAttacked(a,100)==false); assert(c.calls==nil)
assert(#trace==1 and trace[1]=='dodge')
rolls({71,2,100}); assert(c:GetAttacked(a,100)==true and c.calls==1)
''')

    def test_all_critical_paths_use_inclusive_one_to_hundred(self):
        self.check('''
for _,kind in ipairs({'hh_player','hh_monster','hh_igris_shadow'}) do
 for _,roll in ipairs({1,2}) do
  local a,t=entity(kind,{criticalHitRate=1}),entity()
  if kind=='hh_igris_shadow' then a.components.follower={leader=entity('hh_player',{addFollowCritical=1})} end
  rolls({roll}); local c=install(t); c:GetAttacked(a,100)
  assert(c.normal==(roll==1 and 200 or 100),kind)
  assert(c.metadata.critical==(roll==1),kind..' metadata')
  assert(Context.Current(a,t)==nil)
 end
end
''')

    def test_dodge_overcap_still_rolls_and_caps_at_seventy(self):
        self.check('''
local a,t=entity(),entity('hh_player',{chanceDodgeAttack=100})
local c=install(t)
rolls({71}); assert(c:GetAttacked(a,100)==true,'roll 71 must hit at the 70% cap')
assert(#trace==1 and c.calls==1,'overcap dodge must still consume RNG')
rolls({70}); assert(c:GetAttacked(a,100)==false,'roll 70 must dodge')
assert(#trace==1 and c.calls==1)
''')

    def test_only_exact_unavoidable_stimulus_bypasses_dodge(self):
        self.check('''
local function packed(...) return {n=select('#',...),...} end
local a,t=entity(),entity('hh_player',{chanceDodgeAttack=100})
local weapon={prefab='audit_weapon'}; local input={planar=7}
local tail={marker='tail'}; local seen
local c=install(t,function(s,att,d,w,st,sp,...)
 seen={att=att,d=d,w=w,st=st,sp=sp,tail=packed(...)}
 return true,nil,'kept',nil
end)
rolls({})
local result=packed(c:GetAttacked(a,100,weapon,'hh_unavoidable',input,tail,nil))
assert(result.n==4 and result[1]==true and result[2]==nil and result[3]=='kept' and result[4]==nil)
assert(seen.att==a and seen.d==100 and seen.w==weapon and seen.st=='hh_unavoidable')
assert(seen.sp~=input and seen.sp.planar==7 and input.planar==7,
 'the existing defensive packet copy must preserve caller values')
assert(seen.tail.n==2 and seen.tail[1]==tail and seen.tail[2]==nil and #trace==0)

seen=nil; rolls({1})
assert(c:GetAttacked(a,100,weapon,'ordinary',input)==false and seen==nil)
assert(#trace==1,'ordinary stimuli must remain dodgeable')

local boss=entity('hh_monster'); boss.prefab='deerclops'
seen=nil; rolls({1})
assert(c:GetAttacked(boss,100,weapon,'boss_attack',input)==false and seen==nil)
assert(#trace==1,'boss identity alone must not bypass dodge')
''')

    def test_piercing_preserves_external_damage_multiplier(self):
        self.check('''
for _,row in ipairs({{armor=1,planar=0,want=9300},{armor=.2,planar=20,want=9680}}) do
 local a,t=entity('hh_player',{trueDamageNum=40}),entity()
 local c=install(t); c.externaldamagetakenmultipliers.Get=function() return .5 end
 t.components.inventory={ApplyDamage=function(_,d,att,w,sp) return d*row.armor,sp end}
 local input=row.planar>0 and {planar=row.planar} or nil
 c:GetAttacked(a,1000,nil,nil,input)
 assert(t.components.health.currenthealth==row.want,'pierce must preserve non-armor mitigation')
 if input then assert(input.planar==20 and input.hh_armor_pierce==nil) end
end
''')

    def test_follower_flat_defense_is_applied_once_across_primary_packets(self):
        self.check('''
for _,row in ipairs({{flat=100,normal=6500/7,pierce=2600/7,hp=8700},{flat=2000,normal=0,pierce=0,hp=10000}}) do
 local a,t=entity('hh_player',{trueDamageNum=40}),entity()
 t.components.follower={leader=entity('hh_player',{addFollowReduceDamage=row.flat})}
 local c=install(t); c:GetAttacked(a,1000)
 assert(math.abs(c.normal-row.normal)<.00001 and math.abs((c.special.hh_armor_pierce or 0)-row.pierce)<.00001,'follower defense must subtract once before allocation')
 assert(t.components.health.currenthealth==row.hp)
end
''')

    def test_piercing_preserves_conditional_defense_on_redirect_receiver(self):
        self.check('''
local a,t,dest=entity('hh_player',{trueDamageNum=40}),entity(),entity()
local weapon={components={}}
local source=install(t); local receiver=install(dest)
source.redirectdamagefn=function() return dest end
source.conditionexternaldamagetakenmultipliers={function() error('redirect source must not mitigate') end}
receiver.externaldamagetakenmultipliers.Get=function() return .5 end
receiver.conditionexternaldamagetakenmultipliers={function(victim,att,w)
 assert(victim==dest and att==a and w==weapon,'conditional defense needs the original attacker and weapon')
 return .5
end}
local input={planar=20}; source:GetAttacked(a,1000,weapon,nil,input)
assert(dest.components.health.currenthealth==9630,'1000*.5*.5 + 400*.5*.5 + 20 = 370')
assert(t.components.health.currenthealth==10000 and input.planar==20 and input.hh_armor_pierce==nil)
''')

    def test_piercing_does_not_apply_damage_type_resistance_twice(self):
        self.check('''
local a,t=entity('hh_player',{trueDamageNum=40}),entity()
local c=install(t); c.externaldamagetakenmultipliers.Get=function() return .5 end
t.components.damagetyperesist={GetResist=function() return .5 end}
c:GetAttacked(a,1000)
assert(t.components.health.currenthealth==9650,'one .5 type-resist and one .5 external factor must apply')
''')

    def test_piercing_preserves_conditional_defense_without_redirect(self):
        self.check('''
local a,t=entity('hh_player',{trueDamageNum=40}),entity()
local c=install(t); local weapon={components={}}
c.externaldamagetakenmultipliers.Get=function() return .5 end
c.conditionexternaldamagetakenmultipliers={function(victim,att,w)
 assert(victim==t and att==a and w==weapon)
 return .5
end}
c:GetAttacked(a,1000,weapon,nil,{planar=20})
assert(t.components.health.currenthealth==9630,'conditional defense must also apply without a redirect')
''')

    def test_follower_flat_offense_is_applied_once_across_primary_packets(self):
        self.check('''
local a,t=entity('hh_player',{trueDamageNum=40}),entity()
a.components.follower={leader=entity('hh_player',{addFollowDamage=100})}
local c=install(t); c:GetAttacked(a,1000)
assert(math.abs(c.normal-7500/7)<.00001 and math.abs(c.special.hh_armor_pierce-3000/7)<.00001,'follower offense must add once before allocation')
assert(t.components.health.currenthealth==8500)
''')

    def test_critical_then_highest_burst_tier_and_token_metadata(self):
        self.check('''
local a,t=entity('hh_player',{criticalHitRate=1,criticalHitEffect=150,moreDamage8To500=500,moreDamage30To150=150}),entity()
rolls({1,8}); local c=install(t); c:GetAttacked(a,100)
assert(c.normal==1750 and #trace==2)
assert(c.metadata.critical and c.metadata.burst and c.metadata.burst_multiplier==5)
''')

    def test_primary_exposes_independent_direct_poison_pierce_and_splash_bases(self):
        # Reusing the direct total for another packet would amplify that packet.
        self.check('''
local a,t=entity('hh_player',{addComDamage=20,addComDamagePercent=20,spiritFade=1,
 criticalHitRate=100,criticalHitEffect=150,moreDamage8To500=500,trueDamageNum=40}),entity()
a.components.sanity={GetPercent=function() return 0 end}
local weapon={components={}}
rolls({8})
local normal,pierce,hit=a.components.hh_player:ResolvePrimaryHit(t,80,weapon)
assert(normal==2975,'normal hit must retain the full direct multiplier')
assert(pierce==40,'only base plus flat may feed the additional pierce packet')
assert(hit.base_damage==100 and hit.direct_pre_crit==170 and hit.normal_final==2975)
assert(hit.poison_base==100 and hit.pierce_base==100 and hit.splash_final==2100)
assert(hit.weapon==weapon and #trace==1 and Context.Current(a,t)==nil)
''')

    def test_additive_pierce_keeps_the_full_unarmored_and_armored_normal_hit(self):
        self.check('''
for _,row in ipairs({{armor=1,hp=8210},{armor=.2,hp=9610}}) do
 local a,t=entity('hh_player',{criticalHitRate=100,criticalHitEffect=150,moreDamage8To500=500,trueDamageNum=40}),entity()
 t.components.inventory={ApplyDamage=function(_,d,at,w,sp) return d*row.armor,sp end}
 rolls({8}); local c=install(t); c:GetAttacked(a,100)
 assert(c.normal==1750 and c.special.hh_armor_pierce==40)
 assert(t.components.health.currenthealth==row.hp,'armor must apply only to the normal 1750')
end
''')

    def test_pierce_copies_packets_and_honors_immunity(self):
        self.check('''
local a,t=entity('hh_player',{trueDamageNum=40}),entity()
local input={planar=12}; local c=install(t); c:GetAttacked(a,1000,nil,nil,input)
assert(c.normal==1000 and c.special.hh_armor_pierce==400)
assert(input.hh_armor_pierce==nil and input.planar==12 and c.special~=input)
local immune=entity('hh_monster',{immuneTrue=1}); local ci=install(immune)
ci:GetAttacked(a,1000); assert(ci.normal==1000 and (ci.special==nil or ci.special.hh_armor_pierce==nil))
a.components.hh_player.hh_effects.criticalHitRate=100
ci:GetAttacked(a,1000); assert(ci.normal==2000 and (ci.special==nil or ci.special.hh_armor_pierce==nil))
local sp=require('components/spdamageutil'); assert(sp._SpTypeMap.hh_armor_pierce)
assert(sp.GetSpDamageForType(a,'hh_armor_pierce')==0 and sp.GetSpDefenseForType(t,'hh_armor_pierce')==0)
''')

    def test_percentage_defense_then_vanilla_armor(self):
        self.check('''
local a,t=entity(),entity('hh_player',{absorbDamage=80,reduceAttackedDamage=999,sanReplaceDamageChance=100,reflexiveInjury=99})
t.components.inventory={ApplyDamage=function(_,d,att,w,sp) return d*.2,sp end}
local c=install(t); c:GetAttacked(a,1000); assert(math.abs(t.components.health.currenthealth-9960)<.001)
local p=entity('hh_player',{trueDamageNum=40}); c:GetAttacked(p,1000)
assert(c.normal==200 and c.special.hh_armor_pierce==400)
assert(math.abs(t.components.health.currenthealth-9520)<.001)
''')

    def test_player_pool_and_armor_do_not_reduce_true_damage(self):
        # A broad hh_* reduction would incorrectly turn 400 piercing into 80.
        self.check('''
for _,row in ipairs({
 {armor=1,external=1,conditional=1,normal=200,pierce=400,hp=9400},
 {armor=.2,external=1,conditional=1,normal=40,pierce=400,hp=9560},
 {armor=.2,external=.5,conditional=.5,normal=10,pierce=100,hp=9890},
}) do
 local a,t=entity('hh_player',{trueDamageNum=40}),entity('hh_player',{absorbDamage=80})
 local c=install(t); local weapon={components={}}
 c.externaldamagetakenmultipliers.Get=function() return row.external end
 c.conditionexternaldamagetakenmultipliers={function(victim,att,w)
  assert(victim==t and att==a and w==weapon)
  return row.conditional
 end}
 t.components.inventory={ApplyDamage=function(_,d,att,w,sp)
  return d*row.armor,sp
 end}
 c:GetAttacked(a,1000,weapon)
 assert(c.normal==200,'the player pool must reduce the normal hit once')
 assert(c.special.hh_armor_pierce==row.pierce,'only non-armor defense may reduce true damage')
 assert(math.abs(a.events.onhitother.damage-row.pierce-row.normal)<.00001,'normal mitigation order')
 assert(t.components.health.currenthealth==row.hp,'true-damage defense boundary')
end
''')

    def test_player_pool_still_reduces_poison_but_not_planar(self):
        # Excluding all special packets would also let poison bypass the pool.
        self.check('''
for _,row in ipairs({{kind='primary',normal=1000,hp=9860},{kind='poison',normal=0,hp=9900}}) do
 local a,t=entity(),entity('hh_player',{absorbDamage=80})
 t.components.inventory={ApplyDamage=function(_,d,att,w,sp) return d*.2,sp end}
 local c=install(t); local input={hh_poison=400,planar=20}
 local function hit() return c:GetAttacked(a,row.normal,nil,nil,input) end
 if row.kind=='poison' then Context.WithPacket('poison',hit) else hit() end
 assert(c.special.hh_poison==80 and c.special.planar==20)
 assert(input.hh_poison==400 and input.planar==20,'caller packet must stay unchanged')
 assert(t.components.health.currenthealth==row.hp,'poison keeps pool mitigation and bypasses only armor')
 assert(Context.PacketKind()==nil)
end
''')

    def test_monster_percentage_reduction_applies_to_pierce(self):
        self.check('''
local a,t=entity('hh_player',{trueDamageNum=40}),entity('hh_monster',{reducePercentDamage=80})
local c=install(t); c:GetAttacked(a,1000)
assert(math.abs(c.normal-200)<.001 and math.abs(c.special.hh_armor_pierce-80)<.001)
assert(t.components.health.currenthealth==9720)
''')

    def test_monster_full_block_reuses_one_defense_outcome_for_pierce(self):
        self.check('''
local a=entity('hh_player',{trueDamageNum=40,bloodSuck=100,atkAddPoisonChance=100})
local t=entity('hh_monster',{replaceDamageChance=100})
a.components.health.currenthealth=5000
a._onhitother=player_onhitother
local monster=t.components.hh_monster
local block=monster.GetBlockDamage; local defense_calls=0
monster.GetBlockDamage=function(self,...)
 defense_calls=defense_calls+1; rng_phase='defense'
 local result=block(self,...); rng_phase='offense'; return result
end
rolls({1})
local c=install(t); local before=t.components.health.currenthealth
c:GetAttacked(a,1000)
assert(c.normal==0 and (c.special.hh_armor_pierce or 0)==0,'full block must zero normal and piercing')
assert(t.components.health.currenthealth==before,'full block must produce zero HP delta')
assert(defense_calls==1 and #trace==1 and trace[1]=='defense','monster defense must run and roll once')
assert(t._hh_combat_poison==nil,'blocked hit must not apply status')
assert(a.components.health.currenthealth==5000 and a.components.hh_player._hh_lifesteal_budget==nil,
 'blocked hit must not heal or consume lifesteal budget')
''')

    def test_monster_nonzero_defense_factor_applies_once_to_pierce(self):
        self.check('''
local a=entity('hh_player',{trueDamageNum=40})
local t=entity('hh_monster',{replaceDamageChance=50,reduceAttackedDamage=200,reducePercentDamage=50})
local monster=t.components.hh_monster
local block=monster.GetBlockDamage; local defense_calls=0
monster.GetBlockDamage=function(self,...)
 defense_calls=defense_calls+1; rng_phase='defense'
 local result=block(self,...); rng_phase='offense'; return result
end
rolls({100})
local c=install(t); c:GetAttacked(a,1000)
assert(c.normal==400 and c.special.hh_armor_pierce==160,
 'piercing must reuse (1000-200)*.5 / 1000 exactly once')
assert(t.components.health.currenthealth==9440,'normal 400 plus piercing 160')
assert(defense_calls==1 and #trace==1 and trace[1]=='defense','no second monster defense roll')
''')

    def test_defense_shim_has_no_legacy_procs_or_suit_amplification(self):
        self.check('''
local a,t=entity(),entity('hh_player',{absorbDamage=80,chanceDodgeAttack=70,sanReplaceDamageChance=100,reflexiveInjury=99})
local c=t.components.hh_player; c.HasSuitEffect=function() return true end
t.components.sanity={DoDelta=function() error('sanity shield') end}
a.components.combat={GetBrambleFx=function() error('reflection') end}
rolls({}); assert(c:GetBlockDamage(t,a,1000)==200 and #trace==0)
''')

    def test_world_rank_scales_each_packet_once_and_restores_marker(self):
        self.check('''
local a,t=entity('hh_player',{trueDamageNum=40}),entity()
TheWorld.components.hh_world={ResolveWorldRankDamageSource=function(_,x) return x end,GetWorldRankDamageMultiplier=function() return 2 end}
local c=install(t,function(s,att,d,w,st,sp)
 assert(t._hh_world_rank_combat_damage_source==a)
 assert(d==2000 and sp.hh_armor_pierce==800)
 return true,nil,'tail',nil
end)
local function packed(...) return {n=select('#',...),...} end
local r=packed(c:GetAttacked(a,1000)); assert(r.n==4 and r[1] and r[2]==nil and r[3]=='tail' and r[4]==nil)
assert(t._hh_world_rank_combat_damage_source==nil and Context.Current(a,t)==nil)
''')

    def test_original_owns_invincible_redirect_planar_and_health_floor(self):
        self.check('''
local a=entity('hh_player',{trueDamageNum=40})
local t=entity(); t.components.health.invincible=true
local c=install(t); assert(c:GetAttacked(a,1000)==false); assert(t.components.health.currenthealth==10000)
local dest=entity(); local redirected
dest.components.combat={GetAttacked=function(_,att,d,w,st,sp) redirected={d,sp.hh_armor_pierce} end}
t.components.health.invincible=false; c.redirectdamagefn=function() return dest end
assert(c:GetAttacked(a,1000)); assert(redirected[1]==1000 and redirected[2]==400 and t.components.health.currenthealth==10000)
c.redirectdamagefn=nil; local planar_calls=0
t.components.planarentity={AbsorbDamage=function(_,d,att,w,sp) planar_calls=planar_calls+1; return d/2,sp end}
c:GetAttacked(a,1000); assert(planar_calls==1 and t.components.health.currenthealth==9100)
t.components.health.floor=1; c:GetAttacked(a,100000); assert(t.components.health.currenthealth==1)
''')

    def test_context_and_world_marker_restore_after_original_error(self):
        self.check('''
local a,t=entity('hh_player'),entity()
TheWorld.components.hh_world={ResolveWorldRankDamageSource=function(_,x) return x end,GetWorldRankDamageMultiplier=function() return 2 end}
local c=install(t,function() error('engine failure') end)
local ok,err=pcall(c.GetAttacked,c,a,100); assert(not ok and string.find(err,'engine failure'))
assert(Context.Current(a,t)==nil and t._hh_world_rank_combat_damage_source==nil)
''')

    def test_vanilla_redirect_preserves_packet_bases_without_reroll_or_rescale(self):
        self.check('''
local a,t,dest=entity('hh_player',{criticalHitRate=1,trueDamageNum=40}),entity(),entity()
TheWorld.components.hh_world={ResolveWorldRankDamageSource=function(_,x) return x end,GetWorldRankDamageMultiplier=function() return 2 end}
local dc=install(dest)
local health_delta=dest.components.health.DoDelta
dest.components.health.DoDelta=function(self,n,...)
 assert(dest._hh_world_rank_combat_damage_source==a)
 return health_delta(self,n,...)
end
local c=install(t); c.redirectdamagefn=function() return dest end
local weapon={components={}}; local input={planar=10}
rolls({1}); assert(c:GetAttacked(a,1000,weapon,nil,input))
assert(#trace==1 and dc.normal==4000 and dc.special.hh_armor_pierce==800)
assert(dc.metadata==c.metadata and dc.metadata.weapon==weapon)
assert(dc.metadata.base_damage==1000 and dc.metadata.pierce_base==1000 and dc.metadata.poison_base==1000)
assert(dc.metadata.normal_final==2000 and dc.metadata.splash_final==2000)
assert(input.planar==10 and input.hh_armor_pierce==nil)
assert(dest.components.health.currenthealth==5180 and t.components.health.currenthealth==10000)
assert(dest._hh_world_rank_combat_damage_source==nil and Context.Current(a,dest)==nil)
''')

    def test_health_hook_does_not_subtract_vit_again(self):
        self.check('''
local a,t=entity(),entity('hh_player',{absorbDamage=80,reduceAttackedDamage=999})
local h=t.components.health; h.inst=t; hooks.health(h)
t.components.inventory={ApplyDamage=function(_,d,att,w,sp) return d*.2,sp end}
install(t):GetAttacked(a,1000)
assert(math.abs(h.currenthealth-9960)<.001,'VIT must not subtract after armor')
''')

    def test_onhitother_has_no_second_flat_penetration_packet(self):
        self.check('''
local a,t=entity('hh_player',{trueDamageNum=40}),entity()
local direct=0; t.components.health.DoHHDelta=function() direct=direct+1 end
install(t)
assert(type(player_onhitother)=='function')
player_onhitother(a,{target=t,damage=1000,damageresolved=1000})
assert(direct==0,'penetration must only use the primary special-damage packet')
''')

    def test_lucnguyen_observes_actual_critical_in_new_pipeline(self):
        self.check('''
local Bridge=require('ttk_lucnguyen_combat'); Bridge.InstallSoloObserver(utils)
for _,rate in ipairs({100,0}) do
 local a,t=entity('hh_player',{criticalHitRate=rate,moreDamage8To500=500}),entity()
 Bridge.InstallSoloComponent(a.components.hh_player)
 local token={}; local weapon={components={}}
 Bridge.BeginPrimary(a,t,weapon,token,100)
 rolls({8}); install(t):GetAttacked(a,100,weapon)
 Bridge.ObserveLanded(a,a.events.onhitother)
 assert((Bridge.EndPrimary(token)~=nil)==(rate==100),'burst alone must not be observed as crit')
end
''')


if __name__ == '__main__':
    unittest.main()
