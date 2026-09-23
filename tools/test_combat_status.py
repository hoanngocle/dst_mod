"""Status packet integration against installed DST combat, with a fake clock."""
import unittest
import test_combat_pipeline as pipeline


class StatusTests(unittest.TestCase):
    def setUp(self):
        fixture = pipeline.PipelineTests()
        fixture.setUp()
        self.lua = fixture.lua
        with pipeline.ZipFile(pipeline.GAME) as game:
            self.lua.globals().NativeFreezable = self.lua.execute(
                game.read('scripts/components/freezable.lua').decode())
        # Load the real ownership functions without the unrelated UI imports.
        source = (pipeline.ROOT / 'scripts/utils/hh_utils.lua').read_text(encoding='utf-8')
        start = source.index('local function IsValidShadowRelationEntity(')
        end = source.index('-- The vanilla Health:Kill()', start)
        self.lua.execute('local __B__UG__=utils\n' + source[start:end])
        self.lua.execute(r'''
now=0 tasks={} GetTime=function() return now end
function schedule(delay,fn,period)
 local t={at=now+delay,fn=fn,period=period}
 function t:Cancel() self.cancelled=true end
 tasks[#tasks+1]=t; return t
end
function advance(time)
 while true do
  local nexttask
  for _,t in ipairs(tasks) do
   if not t.cancelled and t.at<=time and (not nexttask or t.at<nexttask.at) then nexttask=t end
  end
  if not nexttask then break end
  now=nexttask.at
  if nexttask.period then nexttask.at=now+nexttask.period else nexttask.cancelled=true end
  nexttask.fn()
 end
 now=time
end
local original_entity=entity
for i=1,100 do
 local name,value=debug.getupvalue(HHMonster._ctor,i)
 if name==nil then break end
 if name=='_B_U_g_' then monster_attacked=value end
 if name=='B_ug__' then monster_onhitother=value end
end
function entity(kind,effects)
 local e=original_entity(kind,effects)
 e.tags={hostile=kind~='hh_player',player=kind=='hh_player'}; function e:HasTag(tag) return self.tags[tag] or false end
 function e:DoTaskInTime(delay,fn) return schedule(delay,function() fn(self) end) end
 function e:DoPeriodicTask(period,fn) return schedule(period,function() fn(self) end,period) end
 function e:PushEvent(name,data)
  self.events[name]=data
  if name=='onhitother' and self.components.hh_player then player_onhitother(self,data) end
  if self.test_monster_events and self.components.hh_monster then
   if name=='attacked' then monster_attacked(self,data) end
   if name=='onhitother' then monster_onhitother(self,data) end
  end
 end
 local h=e.components.health; h.inst=e; h.GetMaxWithPenalty=function(s) return s.maxhealth end
 local c=e.components.hh_monster
 if e.components.hh_player then e.components.hh_player.hh_effects.healthSuppressNum=0 end
 if c then c.hh_effects.healthSuppressNum=0 end
 if c then c.GetMonsterType=function() return e.monster_type or 'normal_monster' end end
 return e
end
TUNING.HH_FORMAT_CONFIG={BUFF={}}
utils.CheckSuitEffect=function() return false end
utils.RelayKillToOwner=function() end
BuffDefs=require('enums/hh_buff')
function buffcarrier(e)
 local b={active={}}; e.components.hh_buff=b
 function b:AddBuff(name,duration)
  if self.active[name] then self.active[name]:Cancel(); BuffDefs[name].stop_fn(e) end
  if BuffDefs[name].check_fn and BuffDefs[name].check_fn(e) then return end
  BuffDefs[name].start_fn(e)
  self.active[name]=e:DoTaskInTime(duration,function() BuffDefs[name].stop_fn(e); self.active[name]=nil end)
 end
end
function primary(a,t,damage)
 if not t.components.combat then install(t) end
 return t.components.combat:GetAttacked(a,damage)
end
function native_freezable(e)
 local combat=e.components.combat or install(e)
 combat.SetTarget=function(self,target) self.target=target end
 combat.BlankOutAttacks=function() end
 e.entity={IsVisible=function() return true end}
 e.AddTag=function(self,tag) self.tags[tag]=true end
 e.RemoveTag=function(self,tag) self.tags[tag]=nil end
 e.ListenForEvent=function() end
 e.RemoveEventCallback=function() end
 e.StopBrain=function() end
 e.RestartBrain=function() end
 -- Native timer callbacks receive the owning entity and trailing arguments.
 e.DoTaskInTime=function(self,delay,fn,...)
  local args={...}; return schedule(delay,function() fn(self,unpack(args)) end)
 end
 e.components.freezable=NativeFreezable(e)
 return e.components.freezable
end
''')

    def check(self, code):
        try:
            self.lua.execute(code)
        except Exception as error:
            self.fail(str(error))

    def test_poison_stacks_tick_capture_and_expiry(self):
        self.check('''
local a,t=entity('hh_player',{atkAddPoisonChance=100}),entity()
primary(a,t,100); advance(2); assert(t.components.health.currenthealth==9880,'one poison tick is 20')
advance(10); assert(t.components.health.currenthealth==9800,'five ticks through t=10')
advance(12); assert(t.components.health.currenthealth==9800,'no tick beyond expiry')
local v=entity(); primary(a,v,100)
for i=1,5 do primary(a,v,100) end
advance(14); assert(v.components.health.currenthealth==9300,'six hits cap at five poison stacks')
advance(21); primary(a,v,200)
advance(30); assert(v.components.health.currenthealth==8300,'capped refresh preserves captured values')
advance(32); assert(v.components.health.currenthealth==8300)
''')

    def test_poison_bypasses_armor_but_honors_pool_invincibility_and_no_lifesteal(self):
        self.check('''
local a,t=entity('hh_player',{atkAddPoisonChance=100,bloodSuck=100}),entity('hh_player',{absorbDamage=50})
a.components.health.maxhealth=1000; a.components.health.currenthealth=100
t.components.inventory={ApplyDamage=function(_,d,at,w,sp) return d*.2,sp end}
primary(a,t,100); assert(t.components.health.currenthealth==9990)
local healed=a.components.health.currenthealth; advance(2)
assert(t.components.health.currenthealth==9980,'poison 20 reduced to 10, armor bypassed')
assert(a.components.health.currenthealth==healed,'poison cannot lifesteal')
t.components.health.invincible=true; advance(4); assert(t.components.health.currenthealth==9980)
''')

    def test_heal_reduction_refreshes_without_stacking(self):
        self.check('''
local a,t=entity('hh_player',{addSuppressAddHealth=100}),entity('hh_monster')
buffcarrier(t); hooks.health(t.components.health); primary(a,t,100)
t.components.health:DoDelta(100); assert(t.components.health.currenthealth==9910)
advance(4); primary(a,t,100); t.components.health:DoDelta(100); assert(t.components.health.currenthealth==9820)
advance(6); t.components.health:DoDelta(100); assert(t.components.health.currenthealth==9830)
advance(9); t.components.health:DoDelta(100); assert(t.components.health.currenthealth==9930)
''')

    def test_freeze_boss_slow_and_shared_five_second_icd(self):
        self.check('''
local a,t,b=entity('hh_player',{atkChanceAddFreeze=100}),entity(),entity('hh_monster')
local frozen=0; local freezable=native_freezable(t)
local freeze=freezable.Freeze
freezable.Freeze=function(self,duration) assert(duration==2); frozen=frozen+1; freeze(self,duration) end
b.monster_type='boss_monster'; local speed=1
b.components.freezable={Freeze=function() error('boss frozen') end}
b.components.locomotor={SetExternalSpeedMultiplier=function(_,source,key,value) speed=value end,RemoveExternalSpeedMultiplier=function() speed=1 end}
primary(a,t,1); primary(a,b,1); assert(frozen==1 and speed==.8)
advance(2); assert(speed==1); primary(a,t,1); primary(a,b,1); assert(frozen==1 and speed==1)
advance(5); primary(a,t,1); primary(a,b,1); assert(frozen==2 and speed==.8)
''')

    def test_native_freeze_releases_at_two_seconds_without_thaw_tail(self):
        self.check('''
local Status=require('combat/hh_combat_status')
local t=entity(); local f=native_freezable(t)
Status.ApplyFreezeOrSlow(t)
assert(f:IsFrozen()); advance(1.99); assert(f:IsFrozen())
advance(2); assert(not f:IsFrozen(),'native thawing tail must not extend the two-second freeze')
assert(f.wearofftask==nil,'completed freeze task must be cleared')
advance(5); Status.ApplyFreezeOrSlow(t); assert(f:IsFrozen())
advance(7); assert(not f:IsFrozen(),'reopened ICD must use another exact two-second freeze')
''')

    def test_native_freeze_refresh_cancels_old_expiry_and_preserves_external_freeze(self):
        self.check('''
local Status=require('combat/hh_combat_status')
local t=entity(); local f=native_freezable(t)
Status.ApplyFreezeOrSlow(t); local first=f.wearofftask
advance(1); f:Freeze(6) -- A later vanilla source owns the new duration.
assert(first.cancelled,'native StartWearingOff must cancel the old mod timer')
advance(2); assert(f:IsFrozen(),'old mod expiry must not unfreeze a newer external freeze')
advance(5); Status.ApplyFreezeOrSlow(t); local latest=f.wearofftask
advance(7); assert(not f:IsFrozen() and f.wearofftask==nil)
assert(latest.cancelled,'completed fake-clock task should be consumed')
''')

    def test_native_freeze_component_removal_cancels_timer_safely(self):
        self.check('''
local Status=require('combat/hh_combat_status')
local t=entity(); local f=native_freezable(t)
Status.ApplyFreezeOrSlow(t); local task=f.wearofftask
f:OnRemoveFromEntity(); t.components.freezable=nil
assert(task.cancelled,'component removal must cancel its mod expiry timer')
advance(10)
local removed=entity(); local g=native_freezable(removed)
Status.ApplyFreezeOrSlow(removed); removed.IsValid=function() return false end
advance(12) -- A removed entity must not receive Unfreeze/brain/event work.
assert(g:IsFrozen(),'invalid actor was mutated by stale timer')
''')

    def test_splash_uses_pre_mitigation_damage_and_secondary_armor_without_recursion(self):
        self.check('''
local a,t,v=entity('hh_player',{addSplashDamageAOE=60,criticalHitRate=100,atkAddPoisonChance=100,targetPercentDamage=3,killUnderThreshold=100,bloodSuck=10}),entity(),entity()
a.components.health.currenthealth=100; a.components.health.maxhealth=1000
local exclusions={}; for _,tag in ipairs({'player','companion','wall','structure','INLIMBO'}) do local e=entity(); e.tags[tag]=true; install(e); exclusions[#exclusions+1]=e end
v.components.inventory={ApplyDamage=function(_,d,at,w,sp) return d*.2,sp end}; install(v)
TheSim={FindEntities=function(_,x,y,z,radius) assert(radius==3); local out={v}; for _,e in ipairs(exclusions) do out[#out+1]=e end; return out end}
-- Primary final=1000 (base 500 with crit), splash must be 600 before its own armor.
primary(a,t,500); assert(v.components.health.currenthealth==9880,'splash armor or recursion')
for _,e in ipairs(exclusions) do assert(e.components.health.currenthealth==10000) end
advance(2); assert(v.components.health.currenthealth==9880,'secondary poison forbidden')
assert(a.components.health.currenthealth==212,'primary 100 plus splash 12; heavy wound/execute/poison excluded')
''')

    def test_heavy_wound_current_health_boss_rate_armor_and_immunity(self):
        self.check('''
for _,row in ipairs({{'normal_monster',false,9603},{'boss_monster',false,9801},{'normal_monster',true,9900}}) do
 local a,t=entity('hh_player',{targetPercentDamage=3}),entity('hh_monster',{immuneTearing=row[2] and 1 or 0})
 t.monster_type=row[1]; primary(a,t,100); assert(t.components.health.currenthealth==row[3],row[1])
end
local a,t=entity('hh_player',{targetPercentDamage=3}),entity()
t.components.inventory={ApplyDamage=function(_,d,at,w,sp) return d*.2,sp end}
primary(a,t,100); assert(math.abs(t.components.health.currenthealth-9920.12)<.0001)
''')

    def test_execute_excludes_boss_and_respects_health_floor(self):
        self.check('''
local a=entity('hh_player',{killUnderThreshold=100})
local boss=entity('hh_monster'); boss.monster_type='boss_monster'; primary(a,boss,100); assert(boss.components.health.currenthealth==9900)
local t=entity(); t.components.health.currenthealth=1000; t.components.health.floor=1; primary(a,t,100); assert(t.components.health.currenthealth==1)
local dead=entity(); dead.components.health.currenthealth=1000; primary(a,dead,100); assert(dead.components.health.currenthealth==0)
''')

    def test_lifesteal_event_and_second_caps_and_packet_allowlist(self):
        self.check('''
local a=entity('hh_player',{bloodSuck=100}); local h=a.components.health; h.maxhealth=1000; h.currenthealth=0.5
local p=a.components.hh_player
p:HandleBloodSuck(10000,'primary'); assert(h.currenthealth==150.5)
for i=1,6 do p:HandleBloodSuck(10000,'splash') end
assert(h.currenthealth==900.5)
advance(1); p:HandleBloodSuck(10000,'primary'); assert(h.currenthealth==1050.5)
for _,kind in ipairs({'poison','heavy_wound','execute'}) do p:HandleBloodSuck(10000,kind) end
assert(h.currenthealth==1050.5)
''')

    def test_primary_lifesteal_excludes_post_defense_pierce_even_on_overkill(self):
        self.check('''
for _,hp in ipairs({10000,100}) do
 local a,t=entity('hh_player',{bloodSuck=10,trueDamageNum=40}),entity()
 a.components.health.currenthealth=100; a.components.health.maxhealth=1000; t.components.health.currenthealth=hp
 t.components.inventory={ApplyDamage=function(_,d,at,w,sp) return d*.2,sp end}
 primary(a,t,1000)
 local want=hp==100 and (100+10/3) or 120
 assert(math.abs(a.components.health.currenthealth-want)<.00001,'lifesteal must use normal post-defense share')
end
''')

    def test_packet_damage_uses_only_its_approved_sources(self):
        # Each row isolates one source; changing a direct multiplier must not
        # silently alter poison or pierce, and adversity must not alter splash.
        self.check('''
for _,row in ipairs({
 {attack=0,adversity=0,crit=0,burst=0,primary=9860,splash=9940},
 {attack=0,adversity=1,crit=0,burst=0,primary=9810,splash=9940},
 {attack=20,adversity=0,crit=0,burst=0,primary=9840,splash=9928},
 {attack=0,adversity=0,crit=100,burst=500,primary=8210,splash=8950},
 {attack=20,adversity=1,crit=100,burst=500,primary=6985,splash=8740},
}) do
 local a,t,v=entity('hh_player',{addComDamage=20,addComDamagePercent=row.attack,spiritFade=row.adversity,
  criticalHitRate=row.crit,criticalHitEffect=150,moreDamage8To500=row.burst,trueDamageNum=40,
  atkAddPoisonChance=100,addSplashDamageAOE=60}),entity(),entity()
 a.components.sanity={GetPercent=function() return 0 end}
 install(v); TheSim={FindEntities=function() return {v} end}
 rolls(row.burst>0 and {8} or {}); primary(a,t,80)
 assert(t.components.health.currenthealth==row.primary,'direct and additive pierce total')
 assert(t.components.combat.special.hh_armor_pierce==40,'pierce changed with an excluded source')
 assert(v.components.health.currenthealth==row.splash,'splash source isolation')
 local before=t.components.health.currenthealth; advance(now+2)
 assert(t.components.health.currenthealth==before-20,'poison stack changed with an excluded source')
 assert(v.components.health.currenthealth==row.splash,'splash created poison or recursive damage')
 t._hh_combat_poison.task:Cancel()
end
''')

    def test_poison_captures_base_plus_flat_before_all_direct_only_bonuses(self):
        self.check('''
local a,t=entity('hh_player',{addComDamage=20,addComDamagePercent=20,spiritFade=1,
 criticalHitRate=100,criticalHitEffect=150,moreDamage8To500=500,atkAddPoisonChance=100}),entity()
a.components.sanity={GetPercent=function() return 0 end}
rolls({8}); primary(a,t,80); assert(t.components.health.currenthealth==7025)
advance(2); assert(t.components.health.currenthealth==7005,'poison must tick for 20, not 34 from direct pre-crit')
''')

    def test_splash_includes_attack_critical_and_burst_but_excludes_adversity(self):
        self.check('''
local a,t,v=entity('hh_player',{addComDamage=20,addComDamagePercent=20,spiritFade=1,
 criticalHitRate=100,criticalHitEffect=150,moreDamage8To500=500,addSplashDamageAOE=60}),entity(),entity()
a.components.sanity={GetPercent=function() return 0 end}
install(v); TheSim={FindEntities=function() return {v} end}
rolls({8}); primary(a,t,80); assert(t.components.health.currenthealth==7025)
assert(v.components.health.currenthealth==8740,'60% splash must use 2100, not direct 2975')
''')

    def test_ranged_primary_splashes_at_target_without_allies_or_recursive_procs(self):
        self.check('''
local a,t,v,ally=entity('hh_player',{criticalHitRate=100,trueDamageNum=40,atkAddPoisonChance=100,
 addSplashDamageAOE=60,targetPercentDamage=3,killUnderThreshold=15}),entity(),entity(),entity()
ally.components.follower={GetLeader=function() return a end}
t.Transform.GetWorldPosition=function() return 10,0,0 end
install(v); install(ally); local queries=0
TheSim={FindEntities=function(_,x,y,z,radius)
 assert(x==10 and radius==3,'ranged splash must remain target-centered'); queries=queries+1
 return {v,ally}
end}
local weapon={components={weapon={projectile='arrow'}}}
install(t):GetAttacked(a,100,weapon)
assert(v.components.health.currenthealth==9880,'ranged primary must produce the same 120 splash as melee')
assert(ally.components.health.currenthealth==10000 and queries==1)
advance(2); assert(v.components.health.currenthealth==9880 and queries==1,'secondary hit must not recurse or poison')
''')

    def test_dodged_primary_cannot_produce_any_auxiliary_packet_or_healing(self):
        self.check('''
local a,t=entity('hh_player',{criticalHitRate=1,moreDamage8To500=500,trueDamageNum=40,atkAddPoisonChance=1,
 atkChanceAddFreeze=1,addSuppressAddHealth=1,addSplashDamageAOE=60,targetPercentDamage=3,bloodSuck=100}),
 entity('hh_player',{chanceDodgeAttack=70})
a.components.health.currenthealth=100
t.components.freezable={Freeze=function() error('dodged hit froze') end}
TheSim={FindEntities=function() error('dodged hit splashed') end}
rolls({70}); assert(primary(a,t,100)==false and #trace==1)
advance(10); assert(t.components.health.currenthealth==10000 and a.components.health.currenthealth==100)
assert(t._hh_combat_poison==nil and t.components.combat.calls==nil)
''')

    def test_redirected_splash_heals_actual_recipient_once(self):
        self.check('''
local a,t,v,dest=entity('hh_player',{addSplashDamageAOE=60,bloodSuck=10}),entity(),entity(),entity()
a.components.health.currenthealth=100; a.components.health.maxhealth=1000
install(v).redirectdamagefn=function() return dest end; install(dest)
dest.components.inventory={ApplyDamage=function(_,d,at,w,sp) return d*.2,sp end}
TheSim={FindEntities=function() return {v} end}
primary(a,t,1000)
assert(dest.components.health.currenthealth==9880 and v.components.health.currenthealth==10000)
assert(a.components.health.currenthealth==212,'redirected splash actual damage earns 12 once')
''')

    def test_execute_ignores_armor_and_primary_death_threshold_prevention(self):
        self.check('''
local a=entity('hh_player',{killUnderThreshold=15})
local armored=entity(); armored.components.health.currenthealth=1500
armored.components.inventory={ApplyDamage=function(_,d,at,w,sp) return d*.01,sp end}
primary(a,armored,100); assert(armored.components.health.currenthealth==0,'execute must bypass armor')
-- Keep the real death-threshold component and hh_api DoDelta/SetVal guard.
local t=entity('hh_player'); t.tags.player=true
require('guild/hh_rank_defs').RANK.S=3
t.components.hh_rank={GetRank=function() return 3 end}
local Threshold=require('components/hh_death_threshold')
t.components.hh_death_threshold=Threshold(t)
local h=t.components.health
h.SetVal=function(s,value) s.currenthealth=math.max(0,value) end
h.DoDelta=function(s,value) local old=s.currenthealth; s:SetVal(old+value); return s.currenthealth-old end
hooks.health(h)
primary(a,t,20000)
assert(h.currenthealth==1,'execute must not kill after the primary activates death prevention')
assert(t.components.hh_death_threshold._activation_serial==1)
''')

    def test_poison_success_chance_and_each_stack_captures_its_own_hit(self):
        self.check('''
local a,t=entity('hh_player',{atkAddPoisonChance=1}),entity()
rolls({2}); primary(a,t,100); advance(2); assert(t.components.health.currenthealth==9900)
rolls({1}); primary(a,t,100)
rolls({1}); primary(a,t,200)
advance(4); assert(t.components.health.currenthealth==9540,'captured values are 20 + 40')
advance(12); assert(t.components.health.currenthealth==9300,'two stacks tick five times')
''')

    def test_invincible_primary_has_no_status_splash_or_healing(self):
        self.check('''
local a,t=entity('hh_player',{atkAddPoisonChance=100,atkChanceAddFreeze=100,addSplashDamageAOE=60,targetPercentDamage=3,killUnderThreshold=100,bloodSuck=100}),entity()
a.components.health.currenthealth=100; t.components.health.invincible=true
t.components.freezable={Freeze=function() error('blocked hit froze') end}
TheSim={FindEntities=function() error('blocked hit splashed') end}
primary(a,t,100); advance(10)
assert(t.components.health.currenthealth==10000 and a.components.health.currenthealth==100)
''')

    def test_boss_registry_fallback_and_hp_do_not_misclassify(self):
        self.check('''
local Status=require('combat/hh_combat_status')
local a,b,n=entity('hh_player',{killUnderThreshold=100}),entity('hh_monster'),entity()
require('enums/hh_prefab_list').boss_monster[b.prefab]=true
Status.TryExecute(a,b); assert(b.components.health.currenthealth==10000)
n.components.health.maxhealth=10000000; n.components.health.currenthealth=1500000
Status.TryExecute(a,n); assert(n.components.health.currenthealth==0,'large HP does not mean boss')
''')

    def test_packet_context_restores_after_auxiliary_engine_error(self):
        self.check('''
local a,t=entity('hh_player'),entity()
install(t,function() error('auxiliary engine error') end)
local ok=pcall(function() Context.WithPacket('splash',function() t.components.combat:GetAttacked(a,100) end) end)
assert(not ok and Context.PacketKind()==nil and Context.Current(a,t)==nil)
''')

    def test_auxiliary_packets_do_not_trigger_real_monster_reactive_listener(self):
        self.check('''
for _,kind in ipairs({'poison','splash','heavy_wound'}) do
 local a,t=entity('hh_player'),entity('hh_monster',{hitChanceAddPoison=100,hitChanceAddFreeze=100,hitChanceReduceSpeed=100})
 t.test_monster_events=true; install(t)
 local buffs,freezes=0,0
 a.components.hh_buff={AddBuff=function() buffs=buffs+1 end,HasBuff=function() return true end}
 a.components.freezable={Freeze=function() freezes=freezes+1 end}
 Context.WithPacket(kind,function() t.components.combat:GetAttacked(a,kind=='poison' and 0 or 100,nil,nil,kind=='poison' and {hh_poison=20} or nil) end)
 assert(buffs==0 and freezes==0,kind..' triggered reactive monster statuses')
 -- The same real listener must still react to an ordinary primary.
 primary(a,t,100); assert(buffs==2 and freezes==1,'primary monster reactions must remain')
end
''')

    def test_auxiliary_monster_attack_does_not_trigger_real_outgoing_listener(self):
        self.check('''
local a,t=entity('hh_monster',{atkChanceAddPoison=100,atkChanceAddFreeze=100}),entity()
a.test_monster_events=true; install(t)
local buffs,freezes=0,0
t.components.hh_buff={AddBuff=function() buffs=buffs+1 end,HasBuff=function() return true end}
t.components.freezable={Freeze=function() freezes=freezes+1 end}
Context.WithPacket('splash',function() t.components.combat:GetAttacked(a,100) end)
assert(buffs==0 and freezes==0,'auxiliary monster offense triggered statuses')
''')

    def test_splash_is_centered_on_primary_target(self):
        self.check('''
local a,t,near_attacker,near_target=entity('hh_player',{addSplashDamageAOE=60}),entity(),entity(),entity()
t.Transform.GetWorldPosition=function() return 10,0,0 end
install(near_attacker); install(near_target)
TheSim={FindEntities=function(_,x,y,z,radius)
 assert(radius==3)
 return x==10 and {near_target} or {near_attacker}
end}
primary(a,t,1000)
assert(near_target.components.health.currenthealth==9400 and near_attacker.components.health.currenthealth==10000,'splash center must follow target')
''')

    def test_execute_sources_enable_fixed_fifteen_percent_threshold(self):
        self.check('''
local Status=require('combat/hh_combat_status')
for _,raw in ipairs({1,15,30}) do
 local a=entity('hh_player',{killUnderThreshold=raw})
 for _,row in ipairs({{3000,3000},{1501,1501},{1500,0}}) do
  local t=entity(); t.components.health.currenthealth=row[1]
  Status.TryExecute(a,t)
  assert(t.components.health.currenthealth==row[2],'execute must always use fixed 15%, raw='..raw)
 end
end
''')

    def test_splash_aggregate_is_capped_at_sixty_percent(self):
        self.check('''
local a,t,v=entity('hh_player',{addSplashDamageAOE=80}),entity(),entity()
install(v); TheSim={FindEntities=function() return {v} end}
primary(a,t,1000)
assert(v.components.health.currenthealth==9400,'80 raw splash must cap at 60%')
''')

    def test_splash_excludes_owned_followers_allies_and_neutral_combatants(self):
        self.check('''
local a,t,pet,shadow,enemy_follower,enemy,neutral,ally=entity('hh_player',{addSplashDamageAOE=60}),entity(),entity(),entity(),entity(),entity(),entity(),entity()
local other_player=entity('hh_player')
pet.components.follower={GetLeader=function() return other_player end}
shadow.components.follower={GetLeader=function() return pet end}
enemy_follower.components.follower={GetLeader=function() return enemy end}
neutral.tags.hostile=nil
local ac=install(a); ac.IsAlly=function(_,v) return v==ally end; ac.CanTarget=function() return true end
local protected={pet,shadow,neutral,ally}; local entities={pet,shadow,enemy_follower,enemy,neutral,ally}
for _,e in ipairs(entities) do install(e) end
TheSim={FindEntities=function() return entities end}
primary(a,t,1000)
for _,e in ipairs(protected) do assert(e.components.health.currenthealth==10000,'splash hit a protected or neutral target') end
assert(enemy.components.health.currenthealth==9400 and enemy_follower.components.health.currenthealth==9400,'hostile followers are still enemies')
''')


if __name__ == '__main__':
    unittest.main()
