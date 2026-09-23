local Summoner=Class(function(self,inst) self.inst=inst end)
function Summoner:Summon(player)
    local registry=TheWorld.components.ttk_bossregistry
    local ok,reason
    if registry then ok,reason=registry:TrySummon(self.key,player,self.inst)
    else ok,reason=false,"Hãy triệu hồi trên mặt đất của thế giới chính." end
    if not ok and player and player.components.talker then player.components.talker:Say(reason) end
    return ok
end
return Summoner
