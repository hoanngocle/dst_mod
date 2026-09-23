-- Always-on integrations:
-- Open gifts everywhere (3036001095), by hamurlik.
-- No Grass Gekko (1686705509), by Jupiter.

GLOBAL.TUNING.GRASSGEKKO_MORPH_CHANCE = 0

AddComponentPostInit("giftreceiver", function(self)
    -- Prevent the builder from replacing or clearing the player's gift machine.
    self.SetGiftMachine = function() end
end)

AddPlayerPostInit(function(inst)
    if inst.components.giftreceiver ~= nil then
        inst.components.giftreceiver.giftmachine = inst
    end
end)
