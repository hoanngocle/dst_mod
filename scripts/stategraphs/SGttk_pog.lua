require("stategraphs/commonstates")
local SpawnAt = require("ttk_batch19_houseutil").SpawnAt
local TTK_GetGroundPoints = require("ttk_batch19_houseutil").GetGroundPoints

local actionhandlers = 
{
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.PICK, "pick"), 
}

local function GetCombatDuration(inst)
    if inst.ttk_combatstarttime then
        return GetTime() - inst.ttk_combatstarttime
    end
    return 0
end
local events=
{
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnLocomote(false,true),
    EventHandler("doattack", function(inst, data) 
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then 
            local time = GetCombatDuration(inst)
            if time >= 7 and not inst.components.timer:TimerExists("skill2") then
                inst.sg:GoToState("skill2", data.target) 
            elseif time >= 3 and  not inst.components.timer:TimerExists("skill1") then
                inst.sg:GoToState("skill1", data.target) 
            else
                inst.sg:GoToState("attack", data.target) 
            end
        end
    end),

    EventHandler("doeat", function(inst) 
        if not inst.components.health:IsDead() then 
            inst.sg:GoToState("eat", true) 
        end
    end),
}
local HARVEST_MUSTTAGS  = {"pickable"}
local HARVEST_CANTTAGS  = {"INLIMBO", "FX"}
local HARVEST_ONEOFTAGS = {"plant", "lichen", "oceanvine", "kelp"}
local function HarvestPickable(inst, ent)
    if ent.components.pickable.picksound ~= nil then
        inst.SoundEmitter:PlaySound(ent.components.pickable.picksound)
    end
    local success, loot = ent.components.pickable:Pick(TheWorld)
    if loot ~= nil then
        for i, item in ipairs(loot) do
            Launch(item, inst, 1.5)
        end
    end
end
local function doaoework(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 8, HARVEST_MUSTTAGS, HARVEST_CANTTAGS, HARVEST_ONEOFTAGS)
    for _, ent in pairs(ents) do
        if ent:IsValid() and ent.components.pickable ~= nil then
            HarvestPickable(inst, ent)
        end
    end 
    SpawnAt("groundpoundring_fx",Vector3(x,y,z))
    local points = TTK_GetGroundPoints(Vector3(x,y,z),3)
    local map = TheWorld.Map
    for i, v1 in ipairs(points) do
        for i,v in ipairs(v1) do
            if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
                SpawnPrefab("groundpound_fx").Transform:SetPosition(v.x, 0, v.z)
            end
        end
    end
end

local function doringfx(inst,pt,points,fx1,fx2)
    SpawnPrefab(fx1 or "firering_fx").Transform:SetPosition(pt:Get())
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp")
    local map = TheWorld.Map
    for i, v1 in ipairs(points) do
        for i,v in ipairs(v1) do
            if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
                SpawnPrefab(fx2 or "firesplash_fx").Transform:SetPosition(v.x, 0, v.z)
            end
        end
    end   
end

local function dofireaoe(inst,fx)
    if inst:IsValid() then
        local pt = fx:GetPosition()
        local points = TTK_GetGroundPoints(pt,2)
        inst:DoAoe(pt,5.6,25) 
        doringfx(inst,pt,points,"firering_fx")
        inst:DoTaskInTime(0.3,function()
            inst:DoAoe(pt,5.6,25)
            doringfx(inst,pt,points,"firering_fx")
        end)
    end
end

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst, playanim)
            inst.components.locomotor:StopMoving()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle_loop", true)
            else
                inst.AnimState:PlayAnimation("idle_loop", true)
            end
            inst.sg:SetTimeout(2 + 2*math.random())
        end,

        timeline = 
        {
            
        },
        ontimeout=function(inst)
            local rand = math.random()
            if rand < 0.2 then
                inst.sg:GoToState("cute")
            elseif rand < 0.4 then
                inst.sg:GoToState("belly")
            elseif rand < 0.6 then
                inst.sg:GoToState("tailchase")
            else
                inst.sg:GoToState("idle")
            end
        end,
    },
    
    State{
        name = "cute",
        tags = {"canrotate"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("emote_cute")
        end,
        timeline = 
        {
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/jiao") end),
            TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/jiao") end),
        },
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{  
        name = "pick",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("emote_tailchase_pre")
            inst.AnimState:PushAnimation("emote_tailchase_loop",false)
            inst.AnimState:PushAnimation("emote_tailchase_pst",false)
        end,
        timeline = 
        {
            TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/jiao") end),
            TimeEvent(0.792, function(inst) doaoework(inst) end),
            TimeEvent(41*FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/jiao") end),
        },
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{  
        name = "tailchase",
        tags = {"canrotate","preoccupied"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("emote_tailchase_pre")
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("tailchase_loop") end),
        },
    },

    State{
        name = "tailchase_loop",
        tags = {"canrotate","preoccupied"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("emote_tailchase_loop")
        end,
        
        timeline = 
        {
            TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/jiao") end),
        },
        events=
        
        {
            EventHandler("animover", function(inst) 
                if math.random()<0.3 then
                    inst.sg:GoToState("tailchase_loop") 
                else
                    inst.sg:GoToState("tailchase_pst") 
                end
            end),

        },
    },

    State{
        name = "tailchase_pst",
        tags = {"canrotate","preoccupied"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("emote_tailchase_pst")
        end,
        timeline = 
        {
            TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/jiao") end),
        },
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },   
    
    State{
        name = "belly",
        tags = {"canrotate"},
        
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("emote_belly")

            inst.bellysoundtask = inst:DoTaskInTime(math.random()*(81/30), function() inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/jiao")   end )
        end,

        onexit = function(inst)
            inst.bellysoundtask:Cancel()
            inst.bellysoundtask = nil
        end,        

        timeline=
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/jiao") end),
            TimeEvent(45*FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/jiao") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },    

    State{
        name = "walk_start",
        tags = {"moving", "canrotate","walk"},

        onenter = function(inst) 
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        events =
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
        },
    },
        
    State{            
        name = "walk",
        tags = {"moving", "canrotate","walk"},
        
        onenter = function(inst) 
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_loop")
        end,
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
        },
        timeline=
        {
            TimeEvent(FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(8*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(15*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(23*FRAMES, function(inst) PlayFootstep(inst) end),
        },
    },      
    
    State{            
        name = "walk_stop",
        tags = {"canrotate","walk"},
        
        onenter = function(inst) 
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pst")			
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
        },
    },

    State{
        name = "eat",
        tags = {"preoccupied"},
        
        onenter = function(inst,data)            
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat_pre")
            if data then
                inst.sg.statemem.doeat = true
            end
        end,
        
        timeline=
        {
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/eat") end),
            
        },
        events=
        {
            EventHandler("animover", function(inst)                
                if inst:PerformBufferedAction() then
                    inst.sg:GoToState("eat_loop")
                elseif inst.sg.statemem.doeat then
                    inst.sg:GoToState("eat_loop")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },      
    
    State{
        name = "eat_loop",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat_loop", true)
            inst.sg:SetTimeout(1+math.random()*1)
        end,
        
        ontimeout = function(inst)
            inst.sg:GoToState("idle", "eat_pst")
        end,       
    },

    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)            
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    }, 
    
    State{
        name = "gohome",
        tags = { "busy",},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("emote_beg")
        end,

        timeline =
        {
            TimeEvent(0.2, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door") 
            end),
            TimeEvent(0.63, function(inst)
                inst:PerformBufferedAction() inst.sg:GoToState("idle") 
            end),
        },
    },

    State{
        name = "skill1",
        tags = {"attack", "busy"},

        onenter = function(inst,target)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("emote_beg")
            inst.components.combat:StartAttack()
            inst.sg.statemem.target = target
        end,

        timeline =
        {
            TimeEvent(14* FRAMES, function(inst)
                if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                    local fx = SpawnAt("ttk_pog_fire",inst.sg.statemem.target,nil,Vector3(0,4,0))
                    fx.Physics:SetMotorVel(0, -4/0.7, 0)
                    fx.damagefn = function(fx)
                        dofireaoe(inst,fx)
                    end
                end
                
            end),
            TimeEvent(32* FRAMES, function(inst)
                if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                    local fx = SpawnAt("ttk_pog_fire",inst.sg.statemem.target,nil,Vector3(0,4,0))
                    fx.Physics:SetMotorVel(0, -4/0.7, 0)
                    fx.damagefn = function(fx)
                        dofireaoe(inst,fx)
                    end
                end
                
            end),
            TimeEvent(50* FRAMES, function(inst)
                if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                    local fx = SpawnAt("ttk_pog_fire",inst.sg.statemem.target,nil,Vector3(0,4,0))
                    fx.Physics:SetMotorVel(0, -4/0.7, 0)
                    fx.damagefn = function(fx)
                        dofireaoe(inst,fx)
                    end
                end
                
            end),
        },
        events=
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle") 
            end),
        },   
        onexit = function(inst)
            inst.components.timer:StartTimer("skill1",10)
		end,
    },

    State{
        name = "skill2",
        tags = {"attack", "busy"},

        onenter = function(inst,target)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("emote_stretch")
            
            inst.sg.statemem.target = target
        end,

        timeline =
        {
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/jiao") end), 
            TimeEvent(21* FRAMES, function(inst)
                inst:AddDebuff("ttk_pog_fire_buff","ttk_pog_fire_buff")
                inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/jiao")
            end),
        },
        events=
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle") 
            end),
        },   
        onexit = function(inst)
            inst.components.timer:StartTimer("skill2",25)
		end,
    },
}
CommonStates.AddCombatStates(states,
{
	hittimeline = {},

	attacktimeline =
	{
        TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/jiao") end),
        
        TimeEvent(16*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
	},

	deathtimeline =
	{
        TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/jiao") end),
	},
},
{attack="attack"})

CommonStates.AddFrozenStates(states)
  
return StateGraph("ttk_pog", states, events, "idle", actionhandlers)
