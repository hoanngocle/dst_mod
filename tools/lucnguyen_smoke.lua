TheWorld:DoTaskInTime(2, function()
 local ok,err=pcall(function()
  local w=assert(SpawnPrefab("ttk_lucnguyenkiemdong"))
  assert(AllRecipes.ttk_lucnguyenkiemdong)
  local held_names={"ttk_votuongkiem","ttk_thanhtrucphongvankiem","ttk_tinhlakiem",
   "ttk_phanthienkiem","ttk_tienkiem","ttk_makiem"}
  for _,name in ipairs(held_names) do assert(AllRecipes[name],"missing recipe "..name) end
  local kim=assert(SpawnPrefab("ttk_votuongkiem"))
  local thuy=assert(SpawnPrefab("ttk_tinhlakiem"))
  assert(kim.components.planardamage and kim.components.planardamage:GetDamage()==10)
  assert(kim.components.weapon.damage==100 and kim.components.finiteuses:GetUses()==1000)
  assert(thuy.components.weapon.damage==100 and thuy.components.finiteuses:GetUses()==300)
  assert(w.components.weapon.damage==50 and w.components.finiteuses:GetUses()==1000)
  local owner=assert(SpawnPrefab("pigman")); owner.Transform:SetPosition(0,0,0)
  local target=assert(SpawnPrefab("beefalo")); target.Transform:SetPosition(4,0,0)
  target.components.health:SetMaxHealth(10000); target.components.health:SetCurrentHealth(10000)
  target.components.locomotor:Stop(); target:StopBrain()
  owner:StopBrain(); owner.components.locomotor:Stop()
  owner.entity:SetCanSleep(false); target.entity:SetCanSleep(false)
  local Elements=require("ttk_elemental_combat")
  assert(Elements.ApplySlow(target,.25,2))
  assert(math.abs(target.components.locomotor.externalspeedmultiplier-.75)<.001,
   "Thủy slow must apply one 0.75 external multiplier")
  local owner_health=owner.components.health.currenthealth
  assert(Elements.ApplyShield(owner,10,3))
  owner.components.combat:GetAttacked(target,5)
  assert(owner.components.health.currenthealth==owner_health,
   "Thổ shield must absorb final defended damage")
  assert(owner._ttk_elemental_shield and owner._ttk_elemental_shield.remaining<10)
  if owner.components.inventory==nil then owner:AddComponent("inventory") end
  owner.components.inventory:GiveItem(w)
  local altar=assert(SpawnPrefab("ttk_lbjlt"))
  altar.Transform:SetPosition(0,0,0)
  owner.components.inventory:RemoveItem(w,true)
  assert(altar.components.container:CanTakeItemInSlot(w,1),"altar rejects Luc Nguyen")
  altar.components.container:GiveItem(w,1)
  local ritualstone=assert(SpawnPrefab("ttk_lingshi3"))
  owner.components.inventory:GiveItem(ritualstone)
  assert(altar:Refine(owner) and w._ttk_ritual_level==1,"altar refinement failed")
  assert(not owner.components.inventory:Has("ttk_lingshi3",1),"refinement cost not consumed")
  local savedritual={}; w:OnSave(savedritual)
  local ritualcopy=assert(SpawnPrefab("ttk_lucnguyenkiemdong"))
  ritualcopy:OnLoad(savedritual)
  assert(ritualcopy._ttk_ritual_level==1,"ritual level not restored")
  ritualcopy:Remove()
  altar.components.container:RemoveItem(w,true)
  owner.components.inventory:GiveItem(w)
  altar:Remove()
  local launched=w.components.weapon.onprojectilelaunched
  w.components.weapon:SetOnProjectileLaunched(function(item,attacker,victim,projectile)
   launched(item,attacker,victim,projectile)
   assert(math.abs(projectile._base_damage-52.5)<.001,"ritual launch snapshot incorrect")
   if projectile and projectile:IsValid() then projectile.entity:SetCanSleep(false) end
  end)
  w.components.finiteuses:SetUses(2)
  local health=target.components.health.currenthealth
  w.components.weapon:LaunchProjectile(owner,target)
  assert(w.components.finiteuses:GetUses()==1,"primary launch must consume one shot")
  TheWorld:DoTaskInTime(1,function()
   local ok2,err2=pcall(function()
    assert(target.components.health.currenthealth<health,"primary projectile must damage target")
    w.components.weapon:LaunchProjectile(owner,target)
    assert(w.components.finiteuses:GetUses()==0 and w:IsValid(),"last shot must retain empty weapon")
    local data=w.components.finiteuses:OnSave(); assert(data.uses==0)
    local restored=assert(SpawnPrefab("ttk_lucnguyenkiemdong"));restored.components.finiteuses:OnLoad(data)
    assert(restored.components.finiteuses:GetUses()==0)
    local stone=SpawnPrefab("ttk_lingshi1")
    assert(restored.components.trader:AbleToAccept(stone,owner))
    restored.components.trader:AcceptGift(owner,stone)
    assert(restored.components.finiteuses:GetUses()==100,"one stone restores 100")
    restored:Remove()
    local swords={}
    for i=1,6 do
     local s=assert(SpawnPrefab("ttk_lucnguyen_sword_"..i));swords[i]=s
     s:Launch({owner=owner,target=target,damage=5,element=i,index=i,count=6,weapon=w})
    end
    local h=target.components.health.currenthealth
    TheWorld:DoTaskInTime(4,function()
     local ok3,err3=pcall(function()
      for _,s in ipairs(swords) do assert(not s:IsValid(),"sword lifecycle leak") end
      assert(target.components.health.currenthealth<h,"homing swords must hit")
      w:Remove();kim:Remove();thuy:Remove();owner:Remove();target:Remove()
     end)
     print(ok3 and "TTK_LUCNGUYEN_SMOKE_PASS" or ("TTK_LUCNGUYEN_SMOKE_FAIL "..tostring(err3)))
    end)
   end)
   if not ok2 then print("TTK_LUCNGUYEN_SMOKE_FAIL "..tostring(err2)) end
  end)
 end)
 if not ok then print("TTK_LUCNGUYEN_SMOKE_FAIL "..tostring(err)) end
end)
