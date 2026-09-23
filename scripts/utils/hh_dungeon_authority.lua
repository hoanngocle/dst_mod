-- Vanilla world.lua sets ismastershard only for the authoritative master
-- shard.  Vanilla forest.lua/cave.lua identify the world with their tags.
-- Dungeon gameplay is therefore restricted to the authoritative Forest world.
return function(world)
    return world ~= nil
        and world.ismastersim == true
        and world.ismastershard == true
        and world:HasTag("forest")
end
