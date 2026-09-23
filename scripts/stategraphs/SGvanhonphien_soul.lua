require("stategraphs/commonstates")

local events = {
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnAttack(),
	CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
}

local states = {
	State{
		name = "spawn",
        tags = {"busy"},

        onenter = function(inst, cb)
            inst:AddTag("notarget")
			inst.Physics:Stop()
            inst.AnimState:PlayAnimation("spawn")
			inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/spell/elemental/enter")
            if inst.Physics:GetCollisionGroup() == COLLISION.CHARACTERS then
                ToggleOffCharacterCollisions(inst)
            end
        end,

		timeline = {
			TimeEvent(0*FRAMES, function(inst) 
               
            end)
		},

        onexit = function(inst)
            if inst.Physics:GetCollisionGroup() == COLLISION.CHARACTERS then
                ToggleOnCharacterCollisions(inst)
            end
        end,

        events = {
			EventHandler("animover", function(inst)
				inst:RemoveTag("notarget")
				inst.sg:GoToState("idle")
			end),
        },
    },

    State{
        name = "idle",
        tags = { "idle", "canrotate", "canslide" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("idle", true)
            if not inst.play_sound then
                inst.play_sound = true
                inst.SoundEmitter:PlaySound(inst.sounds.idle, "idle_LP")
            end

        end,
        events =
        {

        },
    },
}

CommonStates.AddCombatStates(states, {
    attacktimeline = {
        TimeEvent(5*FRAMES, function(inst)
			inst.SoundEmitter:PlaySound(inst.sounds.attack)
			inst.components.combat:DoAttack(inst.components.combat.target)
		end),
        TimeEvent(16*FRAMES, function(inst)
			inst.SoundEmitter:PlaySound(inst.sounds.attack)
			inst.components.combat:DoAttack(inst.components.combat.target)
		end),
    },
    deathtimeline = {
        TimeEvent(0, function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.death)
			inst.SoundEmitter:KillSound("idle_LP")
			if inst.sg.statemem.wants_to_die then
				inst.SoundEmitter:KillSound(inst.sounds.attack)
            end
        end),
		TimeEvent(20*FRAMES, function(inst)
            inst.DynamicShadow:Enable(false)
        end),
    },
},{
    attack = "attack",
})

local function getidleanim(inst)
    return "idle"
end

CommonStates.AddSimpleWalkStates(states, getidleanim)
CommonStates.AddSimpleRunStates(states, getidleanim)

return StateGraph("vanhonphien_soul", states, events, "spawn")
