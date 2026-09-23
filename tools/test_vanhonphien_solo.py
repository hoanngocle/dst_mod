"""Exercise banner impact routing with DST's actual projectile component."""
from pathlib import Path
from zipfile import ZipFile
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / '.superpowers/vinhhang-runtime'))
from lupa.lua51 import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)
lua.globals().package.path = str(ROOT / 'scripts/?.lua').replace('\\', '/') + ';' + lua.globals().package.path
with ZipFile("C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip") as game:
    lua.execute(game.read('scripts/class.lua').decode())
    lua.globals().Projectile = lua.execute(game.read('scripts/components/projectile.lua').decode())
lua.execute(r'''
COLLISION={LIMITS=1}
TheNet={GetPVPEnabled=function() return false end}
local function entity(player)
 local e={components={},tags=player and {player=true} or {}}
 function e:IsValid() return not self.removed end
 function e:HasTag(t) return self.tags[t] end
 function e:AddTag(t) self.tags[t]=true end
 function e:RemoveTag(t) self.tags[t]=nil end
 function e:StopUpdatingComponent() end
 e.Physics={CollidesWith=function() end,Stop=function() end}
 e.components.health={IsDead=function() return e.dead or false end}
 e.components.combat={CanTarget=function() return true end,IsAlly=function() return false end}
 return e
end
local owner=entity(true)
local soul=entity(); soul.owner=owner
local target=entity(); local ally=entity(); ally.owner=owner
local weapon=entity(); weapon.components.combat=nil
weapon.components.inventoryitem={owner=soul}; weapon.components.weapon={}
local vanilla_hits,player_hits,impacts=0,0,0
function soul.components.combat:DoAttack(t,w,p) vanilla_hits=vanilla_hits+1 end
local combat=owner.components.combat
combat.areahitrange=8; combat.areahitdamagepercent=.25; combat.areahitdisabled=true; combat.AOEarc=90
local oldcheck=function() return false end; combat.areahitcheck=oldcheck
function combat:DoAttack(t,w,p)
 assert(t==target and w==weapon and p.components.projectile)
 assert(self.ignorehitrange and self.areahitrange==3 and self.areahitdamagepercent==1)
 assert(not self.areahitdisabled and self.AOEarc==nil)
 assert(self.areahitcheck(target,owner) and not self.areahitcheck(ally,owner))
 player_hits=player_hits+1
 if self.fail then error('impact failure') end
end
local function shot()
 local e=entity(); local p=Projectile(e); e.components.projectile=p
 p.owner=weapon; p.onhit=function() impacts=impacts+1 end
 p.onmiss=function() e.missed=true end
 return p
end
local attack=require('vanhonphien_attack')
local function fire(p,t) return attack.Hit(p,t,Projectile.Hit) end
fire(shot(),target)
assert(vanilla_hits==1 and player_hits==0 and impacts==1,'standalone route changed')
owner.components.hh_player={}
fire(shot(),target)
assert(vanilla_hits==1 and player_hits==1 and impacts==2,'Solo hit did not use owner exactly once')
assert(combat.areahitrange==8 and combat.areahitdamagepercent==.25 and combat.areahitdisabled)
assert(combat.AOEarc==90 and combat.areahitcheck==oldcheck and combat.ignorehitrange==nil)
local bad=shot(); fire(bad,ally); assert(bad.inst.missed and player_hits==1)
owner.dead=true; bad=shot(); fire(bad,target); assert(bad.inst.missed and player_hits==1); owner.dead=false
soul.dead=true; bad=shot(); fire(bad,target); assert(bad.inst.missed and player_hits==1); soul.dead=false
combat.fail=true
local ok,err=pcall(fire,shot(),target)
assert(not ok and string.find(err,'impact failure'))
assert(combat.areahitrange==8 and combat.areahitdisabled and combat.AOEarc==90 and combat.ignorehitrange==nil)
combat.fail=false; owner.components.hh_player=nil
fire(shot(),target); assert(vanilla_hits==2,'pet attack callback leaked after exception')
local forwarded=0
local banner=entity(); soul.components.entitytracker={GetEntity=function(_,key) assert(key=='banner'); return banner end}
package.loaded.ttk_weapon_damage={ForwardAttack=function(c,w,a,t,p)
 assert(c==banner and w==weapon.components.weapon and a==owner and t==target and p=='projectile')
 forwarded=forwarded+1
end}
attack.OnAttack(soul,weapon,owner,target,'projectile'); assert(forwarded==1)
banner.removed=true; attack.OnAttack(soul,weapon,owner,target,'projectile'); assert(forwarded==1)
''')
print('PASS: vanilla projectile impact, Solo owner attribution, filtering, area scope, error restoration')
