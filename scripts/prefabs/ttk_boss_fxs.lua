-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local function PlaySound(inst, sound,yinl)
    if yinl then
        inst.SoundEmitter:PlaySound(sound,nil, yinl)
    else
        inst.SoundEmitter:PlaySound(sound)
    end
end
local function MakeFx(t)
    local assets =
    {
        Asset("ANIM", Boss.ArtPath("anim/"..t.build..".zip"))
    }
    if t.addbuild  then
        table.insert(assets,Asset("ANIM", Boss.ArtPath("anim/"..t.addbuild..".zip")))
    end
    local function startfx(proxy)
        local inst = CreateEntity(t.name)
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        local parent = proxy.entity:GetParent()
        if parent ~= nil then
            inst.entity:SetParent(parent.entity)
        end
        if t.nameoverride == nil and t.description == nil then
            inst:AddTag("FX")
        end
        inst.entity:SetCanSleep(false)
        inst.persists = false
        inst.Transform:SetFromProxy(proxy.GUID)
        if t.autorotate and parent ~= nil then
            inst.Transform:SetRotation(parent.Transform:GetRotation())
        end
        if t.sound ~= nil then
            inst.entity:AddSoundEmitter()
            if t.update_while_paused then
                inst:DoStaticTaskInTime(t.sounddelay or 0, PlaySound, t.sound,t.yinl)
            else
                inst:DoTaskInTime(t.sounddelay or 0, PlaySound, t.sound,t.yinl)
            end
        end
        if t.sound2 ~= nil then
            if inst.SoundEmitter == nil then
                inst.entity:AddSoundEmitter()
            end
            if t.update_while_paused then
                inst:DoStaticTaskInTime(t.sounddelay2 or 0, PlaySound, t.sound2)
            else
                inst:DoTaskInTime(t.sounddelay2 or 0, PlaySound, t.sound2)
            end
        end
        inst.AnimState:SetBank(Boss.Art(t.bank))
        inst.AnimState:SetBuild(Boss.Art(t.build))
        inst.AnimState:PlayAnimation(FunctionOrValue(t.anim))
        if t.update_while_paused then
            inst.AnimState:AnimateWhilePaused(true)
        end
        if t.tint ~= nil then
            inst.AnimState:SetMultColour(t.tint.x, t.tint.y, t.tint.z, t.tintalpha or 1)
        elseif t.tintalpha ~= nil then
            inst.AnimState:SetMultColour(1, 1, 1, t.tintalpha)
        end
        if t.transform ~= nil then
            inst.AnimState:SetScale(t.transform:Get())
        end
        if t.nameoverride ~= nil then
            if inst.components.inspectable == nil then
                inst:AddComponent("inspectable")
            end
            inst.components.inspectable.nameoverride = t.nameoverride
            inst.name = t.nameoverride
        end
        if t.description ~= nil then
            if inst.components.inspectable == nil then
                inst:AddComponent("inspectable")
            end
            inst.components.inspectable.descriptionfn = t.description
        end
        if t.bloom then
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        end
		if t.animqueue then
	        inst:ListenForEvent("animqueueover", inst.Remove)
	    else
	        inst:ListenForEvent("animover", inst.Remove)
	    end
        if t.fn ~= nil then
            if t.fntime ~= nil then
                if t.update_while_paused then
                    inst:DoStaticTaskInTime(t.fntime, t.fn)
                else
                    inst:DoTaskInTime(t.fntime, t.fn)
                end
            else
                t.fn(inst)
            end
        end
        if TheWorld then
            TheWorld:PushEvent("fx_spawned", inst)
        end
    end
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddNetwork()
        if not TheNet:IsDedicated() then
            if t.update_while_paused then
                inst:DoStaticTaskInTime(0, startfx, inst)
            else
                inst:DoTaskInTime(0, startfx, inst)
            end
        end
        if t.twofaced then
            inst.Transform:SetTwoFaced()
        elseif t.eightfaced then
            inst.Transform:SetEightFaced()
        elseif t.sixfaced then
            inst.Transform:SetSixFaced()
        elseif not t.nofaced then
            inst.Transform:SetFourFaced()
        end
        inst:AddTag("FX")
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end
        inst.persists = false
        inst:DoTaskInTime(1, inst.Remove)
        return inst
    end
    return Prefab(t.name, fn, assets)
end
local prefs = {}
local function FinalOffset3(inst)
    inst.AnimState:SetFinalOffset(3)
end
local function FinalOffset2(inst)
    inst.AnimState:SetFinalOffset(2)
end
local function FinalOffset1(inst)
    inst.AnimState:SetFinalOffset(-1)
end
local function FinalOffset4(inst)
    inst.AnimState:SetFinalOffset(1)
end
local function Bloom(inst)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)
end
local fx ={
    {
        name = "ttk_boss_sand_puff_large_front",
        bank = "sand_puff",
        build = "xd_sand_puff",
        anim = "forage_out",
        transform = Vector3(2.5, 2.5, 2.5),
        fn = function(inst)
            inst.AnimState:SetFinalOffset(2)
            inst.AnimState:Hide("back")
        end,
    },
    {
        name = "ttk_boss_sand_puff_large_back",
        bank = "sand_puff",
        build = "xd_sand_puff",
        anim = "forage_out",
        transform = Vector3(2.5, 2.5, 2.5),
        fn = function(inst)
            inst.AnimState:Hide("front")
        end,
    },
    {
        name = "ttk_boss_wolf_zmyh_front",
        bank = "sand_puff",
        build = "xd_wolf_zmyh_fx",
        anim = "forage_out",
        transform = Vector3(2.5, 2.5, 2.5),
        fn = function(inst)
            inst.AnimState:SetFinalOffset(2)
            inst.AnimState:Hide("back")
        end,
    },
    {
        name = "ttk_boss_wolf_zmyh_back",
        bank = "sand_puff",
        build = "xd_wolf_zmyh_fx",
        anim = "forage_out",
        transform = Vector3(2.5, 2.5, 2.5),
        fn = function(inst)
            inst.AnimState:Hide("front")
        end,
    },
    {
        name = "ttk_boss_htz_wingpuff_front",
        bank = "sand_puff",
        build = "xd_htz_wingpuff",
        anim = "forage_out",
        fn = function(inst)
            inst.AnimState:SetFinalOffset(2)
            inst.AnimState:Hide("back")
        end,
    },
    {
        name = "ttk_boss_htz_wingpuff_back",
        bank = "sand_puff",
        build = "xd_htz_wingpuff",
        anim = "forage_out",
        fn = function(inst)
            inst.AnimState:Hide("front")
        end,
    },
    {
        name = "ttk_boss_ht_sand_puff_front",
        bank = "sand_puff",
        build = "xd_ht_sand_puff",
        anim = "forage_out",
        fn = function(inst)
            inst.AnimState:SetFinalOffset(2)
            inst.AnimState:Hide("back")
        end,
    },
    {
        name = "ttk_boss_ht_sand_puff_back",
        bank = "sand_puff",
        build = "xd_ht_sand_puff",
        anim = "forage_out",
        fn = function(inst)
            inst.AnimState:Hide("front")
        end,
    },
    {
        name = "ttk_boss_luoshen_sand_puff_front",
        bank = "sand_puff",
        build = "xd_luoshen_sand_puff",
        anim = "forage_out",
        fn = function(inst)
            inst.AnimState:SetFinalOffset(2)
            inst.AnimState:Hide("back")
        end,
    },
    {
        name = "ttk_boss_luoshen_sand_puff_back",
        bank = "sand_puff",
        build = "xd_luoshen_sand_puff",
        anim = "forage_out",
        fn = function(inst)
            inst.AnimState:Hide("front")
        end,
    },
    {
        name = "ttk_boss_dhxl_puff_front",
        bank = "sand_puff",
        build = "xd_dhxl_puff",
        anim = "forage_out",
        fn = function(inst)
            inst.AnimState:SetFinalOffset(2)
            inst.AnimState:Hide("back")
        end,
    },
    {
        name = "ttk_boss_dhxl_puff_back",
        bank = "sand_puff",
        build = "xd_dhxl_puff",
        anim = "forage_out",
        fn = function(inst)
            inst.AnimState:Hide("front")
        end,
    },
    {
        name = "ttk_boss_ws_fx",
        bank = "xd_ws_fx",
        build = "xd_ws_fx",
        anim = "idle",
        fn = function(inst)
            inst.Transform:SetFourFaced()
            inst.AnimState:SetTime(0.28)
        end,
    },
    {
        name = "ttk_boss_bigspawn_fx_medium_static",
        bank = "spawn_fx",
        build = "puff_spawning",
        anim = "medium",
        sound = "dontstarve/common/spawn/spawnportal_spawnplayer",
        fn = FinalOffset1,
        transform = Vector3(1.7, 1.7, 1.7),
        update_while_paused = true
    },
    {
        name = "ttk_boss_bigspawn_fx_medium_static_new",
        bank = "spawn_fx",
        build = "puff_spawning",
        anim = "medium",
        sound = "dontstarve/creatures/together/toad_stool/infection_post",
        yinl = 0.3,
        fn = FinalOffset1,
        transform = Vector3(1.7, 1.7, 1.7),
        update_while_paused = true
    },
    {
        name = "ttk_boss_pawn_fx_medium_static_3",
        bank = "spawn_fx",
        build = "puff_spawning",
        anim = "medium",
        sound = "dontstarve/common/spawn/spawnportal_spawnplayer",
        fn = FinalOffset1,
        update_while_paused = true,
        yinl = 0.3,
    },
    {
        name = "ttk_boss_recall_flower",
        bank = "wendy_recall_flower",
        build = "xd_recall_flower",
        anim = "wendy_recall_flower",
        fn = FinalOffset4,
    },
    {
        name = "ttk_boss_explode_small",
        bank = "explode",
        build = "explode",
        anim = "small",
        sound = "dontstarve/common/blackpowder_explo",
        transform = Vector3(2, 2, 2),
        fn = function(inst)
        end,
    },
    {
        name = "ttk_boss_explode_jxsq",
        bank = "explode",
        build = "explode",
        anim = "small",
        yinl = 0.65,
        sound = "dontstarve/common/blackpowder_explo",
        fn = function(inst)
        end,
    },
    {
        name = "ttk_boss_explode_verysmall",
        bank = "explode",
        build = "explode",
        anim = "small",
        sound = "dontstarve/common/blackpowder_explo",
        transform = Vector3(0.5, 0.5, 0.5),
        yinl = 0.3,
        fn = function(inst)
        end,
    },
    {
        name = "ttk_boss_die_fx",
        bank = "die_fx",
        build = "die",
        anim = "small",
        sound = "dontstarve/common/deathpoof",
        fn = function(inst)
            inst.AnimState:SetMultColour(43/255, 0/255, 3/255, .85)
        end,
    },
    {
        name = "ttk_boss_shadowdie_fx",
        bank = "die_fx",
        build = "die",
        anim = "small",
        sound = "dontstarve/common/deathpoof",
        fn = function(inst)
            inst.AnimState:SetMultColour(0/255, 0/255, 0/255, .5)
        end,
    },
    {
        name = "ttk_boss_shadow_merm_spawn_fx",
        bank = "merm_spawn_fx",
        build = "merm_spawn_fx",
        anim = "splash",
        fn = function(inst)
            inst.AnimState:SetFinalOffset(-1)
            inst.AnimState:SetMultColour(0/255, 0/255, 0/255, .5)
        end,
    },
    {
        name = "ttk_boss_motidie_fx",
        bank = "die_fx",
        build = "die",
        anim = "small",
        sound = "dontstarve/common/deathpoof",
        fn = function(inst)
            inst.AnimState:SetMultColour(0/255, 0/255, 0/255, .85)
        end,
    },
    {
        name = "ttk_boss_stalke_hitfx",
        bank = "stalker_minion",
        build = "stalker_minion",
        anim = "hit",
        fn = function(inst)
            inst.AnimState:OverrideSymbol("fx_flames", "stalker_shadow_build", "fx_flames")
            inst.AnimState:OverrideSymbol("shield_minion", "stalker_shadow_build", "shield_minion")
            inst.AnimState:OverrideSymbol("fx_dark_minion", "stalker_shadow_build", "fx_dark_minion")
            inst.AnimState:HideSymbol("legs")
            inst.AnimState:HideSymbol("insidebones")
        end,
    },
    {
        name = "ttk_boss_statue_transition_2_big",
        bank = "die_fx",
        build = "die",
        anim = "small",
        sound = "dontstarve/common/deathpoof",
        tint = Vector3(0, 0, 0),
        transform = Vector3(2.5, 2.5, 2.5),
        tintalpha = 0.6,
    },
    {
        name = "ttk_boss_splash_yellow",
        bank = "pond_splash_fx",
        build = "pond_splash_fx",
        anim = "pond_splash",
        sound = "turnoftides/common/together/water/splash/medium",
        fn = function(inst)
            inst.Transform:SetScale(2,2,2)
            inst.AnimState:SetFinalOffset(1)
            inst.AnimState:SetAddColour(250/255,250/255, 180/255, 1)
        end,
    },
    {
        name = "ttk_boss_bianhua_fx",
        bank = "die_fx",
        build = "die",
        anim = "small",
        sound = "dontstarve/common/deathpoof",
        fn = function(inst)
            inst.AnimState:SetFinalOffset(1)
            inst.AnimState:SetAddColour(1/255,1/255, 1/255, 1)
        end,
    },
    {
        name = "ttk_boss_db_bianhua_fx",
        bank = "die_fx",
        build = "die",
        anim = "small",
        sound = "dontstarve/common/deathpoof",
        fn = function(inst)
            inst.AnimState:SetFinalOffset(1)
            inst.AnimState:SetMultColour(162/255,82/255, 206/255, 1)
        end,
    },
    {
        name = "ttk_boss_bianhua_fx_big",
        bank = "die_fx",
        build = "die",
        anim = "small",
        sound = "dontstarve/common/deathpoof",
        transform = Vector3(1.5, 1.5, 1.5),
        fn = function(inst)
            inst.AnimState:SetFinalOffset(1)
            inst.AnimState:SetAddColour(1/255,1/255, 1/255, 1)
        end,
    },
    {
        name = "ttk_boss_bianhua_fx_explo",
        bank = "die_fx",
        build = "die",
        anim = "small",
        sound = "dontstarve/common/blackpowder_explo",
        transform = Vector3(1.5, 1.5, 1.5),
        fn = function(inst)
            inst.AnimState:SetFinalOffset(1)
            inst.AnimState:SetAddColour(1/255,1/255, 1/255, 1)
        end,
    },
    {
        name = "ttk_boss_bs_smoke",
        bank = "xd_bs_smoke",
        build = "xd_bs_smoke",
        anim = "idle",
        sound = "xd_wukong_sound/xd_wukong_sound/yw",
        transform = Vector3(2.2, 2.2, 2.2),
        fn = FinalOffset4,
    },
    {
        name = "ttk_boss_bs_smoke_shadow",
        bank = "xd_bs_smoke",
        build = "xd_bs_smoke",
        anim = "idle",
        sound = "xd_wukong_sound/xd_wukong_sound/yw",
        transform = Vector3(4, 4, 4),
        tint = Vector3(0, 0, 0,0.7),
        fn = FinalOffset4,
    },
    {
        name = "ttk_boss_jilian_fx",
        bank = "heal_fx",
        build = "xd_jilian_fx",
        anim = "heal_buff",
        sound = "dontstarve/HUD/get_gold",
        transform = Vector3(1.3, 1.3, 1.3),
        fn = FinalOffset4,
    },
    {
        name = "ttk_boss_shengge_fx",
        bank = "heal_fx",
        build = "spider_heal_fx",
        anim = "heal_buff",
        fn = function(inst)
            inst.AnimState:SetAddColour(255/255, 238/255, 114/255,1)
            inst.AnimState:SetFinalOffset(1)
        end,
    },
    {
        name = "ttk_boss_spawn_fx_medium_static",
        bank = "spawn_fx",
        build = "puff_spawning",
        anim = "medium",
        fn = FinalOffset1,
        update_while_paused = true
    },
    {
        name = "ttk_boss_bigspawn_fx_medium_static_nosound",
        bank = "spawn_fx",
        build = "puff_spawning",
        anim = "medium",
        fn = FinalOffset1,
        transform = Vector3(1.7, 1.7, 1.7),
        update_while_paused = true
    },
    {
        name = "ttk_boss_petspawn_fx",
        bank = "spawn_fx",
        build = "puff_spawning",
        anim = "medium",
        fn = FinalOffset1,
        sound = "dontstarve/common/spawn/spawnportal_spawnplayer",
        yinl = 0.3,
        update_while_paused = true
    },
    {
        name = "ttk_boss_dodgeattack_fx",
        bank = "xd_dodgeattack_fx",
        build = "xd_dodgeattack_fx",
        anim = "idle",
        fn = FinalOffset4,
        sound = "xd_wukong_sound/xd_wukong_sound/tttb",
        yinl = 0.7,
        update_while_paused = true
    },
    {
        name = "ttk_boss_time_st_brockfx",
        bank = "xd_time_st_brockfx",
        build = "xd_time_st_brockfx",
        anim = "idle",
        fn = FinalOffset4,
        sound = "xd_wukong_sound/xd_wukong_sound/ds",
        yinl = 0.7,
        update_while_paused = true
    },
    {
        name = "ttk_boss_sword_red_hitfx",
        bank = "xd_sword_red",
        build = "xd_sword_red",
        anim = "attackhit",
        update_while_paused = true
    },
    {
        name = "ttk_boss_sword_blue_hitfx",
        bank = "xd_sword_blue",
        build = "xd_sword_blue",
        anim = "hit",
        update_while_paused = true
    },
    {
        name = "ttk_boss_ring_fx",
        bank = "bearger_ring_fx",
        build = "bearger_ring_fx",
        anim = "idle",
        update_while_paused = true,
        transform = Vector3(1.5, 1.5, 1.5),
        fn = function(inst)
            inst.AnimState:SetFinalOffset(3)
            inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
            inst.AnimState:SetLayer( LAYER_BACKGROUND )
            inst.AnimState:SetSortOrder( 3 )
        end,
    },
    {
        name = "ttk_boss_pet4_ring_fx",
        bank = "bearger_ring_fx",
        build = "bearger_ring_fx",
        anim = "idle",
        update_while_paused = true,
        transform = Vector3(0.6, 0.6, 0.6),
        fn = function(inst)
            inst.AnimState:SetFinalOffset(3)
            inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
            inst.AnimState:SetLayer( LAYER_BACKGROUND )
            inst.AnimState:SetSortOrder( 3 )
        end,
    },
    {
        name = "ttk_boss_fire_ring_fx",
        bank = "dragonfly_ring_fx",
        build = "dragonfly_ring_fx",
        anim = "idle",
        update_while_paused = true,
        transform = Vector3(0.7, 0.7, 0.7),
        fn = function(inst)
            inst.AnimState:SetFinalOffset(3)
            inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
            inst.AnimState:SetLayer( LAYER_BACKGROUND )
            inst.AnimState:SetSortOrder( 3 )
        end,
    },
    {
        name = "ttk_boss_spider_puff_front",
        bank = "xd_spider_puff",
        build = "xd_spider_puff",
        anim = "forage_out",
        sound = "dontstarve/common/deathpoof",
        yinl = 1,
        transform = Vector3(1.5, 1.5, 1.5),
        fn = function(inst)
            inst.AnimState:SetFinalOffset(2)
            inst.AnimState:Hide("back")
        end,
    },
    {
        name = "ttk_boss_spider_puff_back",
        bank = "xd_spider_puff",
        build = "xd_spider_puff",
        anim = "forage_out",
        transform = Vector3(1.5, 1.5, 1.5),
        fn = function(inst)
            inst.AnimState:Hide("front")
        end,
    },
    {
        name = "ttk_boss_spider_puff_white_front",
        bank = "xd_spider_puff",
        build = "xd_spider_puff_white",
        anim = "forage_out",
        sound = "dontstarve/common/deathpoof",
        yinl = 1,
        transform = Vector3(1.5, 1.5, 1.5),
        fn = function(inst)
            inst.AnimState:SetFinalOffset(2)
            inst.AnimState:Hide("back")
        end,
    },
    {
        name = "ttk_boss_spider_puff_white_back",
        bank = "xd_spider_puff",
        build = "xd_spider_puff_white",
        anim = "forage_out",
        transform = Vector3(1.5, 1.5, 1.5),
        fn = function(inst)
            inst.AnimState:Hide("front")
        end,
    },
    {
        name = "ttk_boss_xyzz_spider_puff_front",
        bank = "xd_spider_puff",
        build = "xd_xyzz_spider_puff",
        anim = "forage_out",
        sound = "dontstarve/common/deathpoof",
        yinl = 1,
        transform = Vector3(3, 3, 3),
        fn = function(inst)
            inst.AnimState:SetFinalOffset(2)
            inst.AnimState:Hide("back")
        end,
    },
    {
        name = "ttk_boss_xyzz_spider_puff_back",
        bank = "xd_spider_puff",
        build = "xd_xyzz_spider_puff",
        anim = "forage_out",
        transform = Vector3(3, 3, 3),
        fn = function(inst)
            inst.AnimState:Hide("front")
        end,
    },
    {
        name = "ttk_boss_zuichunyan_green_leaves_chop",
        bank = "tree_leaf_fx",
        build = "xd_zuichunyan_green_leaves_chop",
        anim = "chop",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "ttk_boss_zuichunyan_green_leaves_fall",
        bank = "tree_leaf_fx",
        build = "xd_zuichunyan_green_leaves_chop",
        anim = "fall",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "ttk_boss_zuichunyan_purple_leaves_chop",
        bank = "tree_leaf_fx",
        build = "xd_zuichunyan_purple_leaves_chop",
        anim = "chop",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "ttk_boss_zuichunyan_purple_leaves_fall",
        bank = "tree_leaf_fx",
        build = "xd_zuichunyan_purple_leaves_chop",
        anim = "fall",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "ttk_boss_chenpingan_mume_leaves_chop",
        bank = "tree_leaf_fx",
        build = "xd_chenpingan_mumeleaf",
        anim = "chop",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "ttk_boss_chenpingan_mume_leaves_fall",
        bank = "tree_leaf_fx",
        build = "xd_chenpingan_mumeleaf",
        anim = "fall",
        sound = "dontstarve_DLC001/fall/leaf_rustle",
    },
    {
        name = "ttk_boss_yunxiao_fls_raise",
        bank = "blocker_sanity_fx",
        build = "blocker_sanity_fx",
        anim = "raise",
        fn = function(inst)
            inst.AnimState:SetAddColour(250/255,250/255, 180/255, 0.85)
        end,
    },
    {
        name = "ttk_boss_yunxiao_fls_lower",
        bank = "blocker_sanity_fx",
        build = "blocker_sanity_fx",
        anim = "lower",
        fn = function(inst)
            inst.AnimState:SetAddColour(250/255,250/255, 180/255, 0.85)
        end,
    },
    {
        name = "ttk_boss_sand_splash_fx",
        bank = "sand_spike",
        build = "sand_splash_fx",
        anim = "med_break",
        fn = FinalOffset4,
        sound = "dontstarve/creatures/together/antlion/sfx/break_spike",
        update_while_paused = true,
    },
	{
		name = "ttk_boss_sword_explosion_fx",
		bank = "missile_fx",
		build = "xd_sword_explosion_fx",
		anim = "impact",
		sound = "xd_pog_sound/xd_pog_sound/green_skill2",
        yinl = 0.5,
	},
    {
        name = "ttk_boss_firesplash_fx",
        bank = "dragonfly_ground_fx",
        build = "dragonfly_ground_fx",
        anim = "idle",
        bloom = true,
        tint = Vector3(0, 0, 0),
        tintalpha = 1,
    },
}
for j = 0, 3, 3 do
    for i = 1, 3 do
        table.insert(fx, {
            name = "ttk_boss_shield"..tostring(j + i),
            bank = "stalker_shield",
            build = "stalker_shield",
            anim = "idle"..tostring(i),
            sound = "dontstarve/creatures/together/stalker/shield",
            transform = j > 0 and Vector3(-1, 1, 1) or nil,
            fn = function(inst)
                inst.AnimState:SetFinalOffset(2)
                inst.AnimState:SetAddColour(255/255, 222/255, 69/255,1)
            end,
        })
    end
end
for j = 0, 3, 3 do
    for i = 1, 3 do
        table.insert(fx, {
            name = "ttk_boss_whiteshield"..tostring(j + i),
            bank = "stalker_shield",
            build = "stalker_shield",
            anim = "idle"..tostring(i),
            sound = "dontstarve/creatures/together/stalker/shield",
            transform = j > 0 and Vector3(-1, 1, 1) or nil,
            fn = function(inst)
                inst.AnimState:SetFinalOffset(2)
                inst.AnimState:SetAddColour(255/255, 255/255, 255/255,1)
            end,
        })
    end
end
for k, v in pairs(fx) do
    table.insert(prefs, MakeFx(v))
end
return unpack(prefs)
