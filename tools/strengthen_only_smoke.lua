TheWorld:DoTaskInTime(2,function()
 local ok,err=pcall(function()
  local forge=assert(SpawnPrefab("hh_lo_ren"))
  local rpc=MOD_RPC.hh_lo_ren.strengthen
  local handler=MOD_RPC_HANDLERS[rpc.namespace][rpc.id]
  local function attempt(level,probability,protection,magic,legacy_flag)
   local player=assert(SpawnPrefab("wilson"))
   local item=assert(SpawnPrefab("spear"))
   local s=assert(item.components.wb_strengthen)
   assert(s.DoIncrease==nil)
   s:SetLevel(level)
   s.GetProbability=function() return probability end
   local stones=SpawnPrefab("wb_enhancegem");stones.components.stackable:SetStackSize(30)
   player.components.inventory:GiveItem(stones)
   local purple=SpawnPrefab("purplegem");player.components.inventory:GiveItem(purple)
   if protection then player.components.inventory:GiveItem(SpawnPrefab("wb_strengthen_strengthen_protectpaper")) end
   if magic then player.components.inventory:GiveItem(SpawnPrefab("nn_magicpaper")) end
   forge.components.container:GiveItem(item,1)
   forge.components.container:Open(player)
   handler(player,forge,item,legacy_flag)
   forge.components.container:Close(player)
   local _,remaining=player.components.inventory:Has("wb_enhancegem",1)
   assert(remaining==(level>=13 and 30 or 30-level-1),"wrong stone cost")
   assert(player.components.inventory:Has("purplegem",1),"purple gems must never be consumed")
   if level>=13 then assert(s.level==13 and item:IsValid())
   elseif probability==1 then assert(s.level==level+1 and s.do_mode=="strengthen")
   elseif level>=9 then
    assert(item:IsValid()==protection,"destruction protection changed")
    if protection then assert(s.level==(magic and level or level-1)) end
   else assert(item:IsValid() and s.level==(magic and level or level-1)) end
   if protection then assert(not player.components.inventory:Has("wb_strengthen_strengthen_protectpaper",1)) end
   if magic then assert(not player.components.inventory:Has("nn_magicpaper",1)) end
   if item:IsValid() then item:Remove() end
   player:Remove()
  end
  attempt(0,1,false,false,true)
  attempt(13,1,false,false,true)
  attempt(5,0,false,false,false)
  attempt(5,0,false,true,false)
  attempt(9,0,false,false,false)
  attempt(9,0,true,false,false)
  attempt(9,0,true,true,false)
  local old=SpawnPrefab("spear")
  local s=old.components.wb_strengthen
  s:OnLoad({do_mode="increase",level=6})
  assert(s.do_mode=="strengthen" and s.level==6)
  assert(math.abs(old.components.weapon.damage-50)<.01,"legacy damage must use strengthening")
  local saved=old:GetSaveRecord()
  local loaded=assert(SpawnSaveRecord(saved))
  assert(loaded.components.wb_strengthen.do_mode=="strengthen")
  assert(loaded.components.wb_strengthen.level==6)
  loaded:Remove();old:Remove();forge:Remove()
 end)
 print(ok and "PHAM_NHAN_STRENGTHEN_SMOKE_PASS" or ("PHAM_NHAN_STRENGTHEN_SMOKE_FAIL "..tostring(err)))
end)
