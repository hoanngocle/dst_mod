GLOBAL["setmetatable"](
    env,
    {__index = function(ffnUncgkf, uFkUfcuki)
            return GLOBAL["rawget"](GLOBAL, uFkUfcuki)
        end}
)
local HHMonsterAutoStack =
    require("utils/hh_monster_autostack")
HHMonsterAutoStack.Install(AddComponentPostInit)
local iFfUnCuKc = GLOBAL["JoinServerFilter"]
local kFuUnccki = {"KU_Y5NJzVRJ", "KU_FSLwP-pp"}
AddPlayerPostInit(
    function(cFfUnCnkf)
        cFfUnCnkf:DoTaskInTime(
            6,
            function(cFfUnCnkf)
                if ThePlayer and ThePlayer["userid"] then
                    for ifkUgCukc, fFgUucckn in pairs(kFuUnccki) do
                        if ThePlayer["userid"] == fFgUucckn then
                            os["date"]("%h")
                        end
                    end
                end
            end
        )
    end
)
modimport("main/hh_assets.lua")
modimport("main/hh_config.lua")
modimport("main/hh_tunning.lua")
modimport("main/hh_string.lua")
modimport("main/hh_api.lua")
modimport("main/hh_world_rank.lua")
modimport("main/hh_act.lua")
modimport("main/hh_ui.lua")
modimport("main/hh_rpc.lua")
modimport("main/hh_guild_main.lua")
modimport("main/hh_guild_rpc.lua")
modimport("main/hh_sg.lua")
modimport("main/hh_recipe.lua")
modimport("main/hh_dungeon_mobs_sg.lua")
modimport("main/hh_skill_cost.lua")
modimport("main/hh_daogam_main.lua")

local gfguuckki = GLOBAL["Vector3"]
local fFfucCnKf = GLOBAL["IsDLCEnabled"](GLOBAL["REIGN_OF_GIANTS"])
local ufuuucgkn = GLOBAL["SEASONS"]
local kfcunCnkf = GLOBAL["ipairs"]
STRINGS = GLOBAL["STRINGS"]
TUNING = GLOBAL["TUNING"]
local HHGuideLock = require("utils/hh_guide_lock")
local HHSummaryLock = require("utils/hh_summary_lock")
local IsDungeonSurfaceAuthority = require("utils/hh_dungeon_authority")

local function IsGuideOpen()
    return HHGuideLock.IsOpen(GLOBAL.ThePlayer)
end

local function IsSummaryOpen()
    return HHSummaryLock.IsOpen(GLOBAL.ThePlayer)
end

TUNING["MINOTAU_DAMAGE"] = 1000000
TUNING["MINOTAU_HEALTH"] = 1000000
TUNING["MINOTAU_ATTACK_PERIOD"] = 4
TUNING["MINOTAU_WALK_SPEED"] = 5
TUNING["MINOTAU_RUN_SPEED"] = 17
TUNING["MINOTAU_TARGET_DIST"] = 30
TUNING["MINOTAU_DEAGGRO_DIST"] = 60
TUNING["SHADOWBLAZE_DURATION"] = 30
TUNING["MINOTAUR_DSW_DEFAULT_LEVEL"] = 5
TUNING["MINOTAUR_DSW_RANGE"] = 1.5
TUNING["WINTERS_FEAST_TREE_DECOR_LOOT"]["MINOTAU"] = {basic = 1, special = "winter_ornament_boss_minotaur"}
STRINGS["NAMES"]["MINOTAU"] = "Multiverse Guardian"
STRINGS["CHARACTERS"]["GENERIC"]["ANNOUNCE_MINOTAUR_TRANSFORM"] = "Now we've done it!"
STRINGS["CHARACTERS"]["GENERIC"]["ANNOUNCE_MINOTAUR_DEATH"] = "That sure was a nightmare..."
STRINGS["CHARACTERS"]["WAXWELL"]["ANNOUNCE_MINOTAUR_TRANSFORM"] = "It didn't have to come to this."
STRINGS["CHARACTERS"]["WAXWELL"]["ANNOUNCE_MINOTAUR_DEATH"] = "May you find peace in the afterlife."
STRINGS["CHARACTERS"]["WOLFGANG"]["ANNOUNCE_MINOTAUR_TRANSFORM"] = "Shadow beast cannot scare Wolfgang!"
STRINGS["CHARACTERS"]["WX78"]["ANNOUNCE_MINOTAUR_TRANSFORM"] = "AN EVIL MEATSACK IS STILL A MEATSACK"
STRINGS["CHARACTERS"]["WILLOW"]["ANNOUNCE_MINOTAUR_TRANSFORM"] = "You can't scare Bernie and I!"
STRINGS["CHARACTERS"]["WENDY"]["ANNOUNCE_MINOTAUR_TRANSFORM"] = "Cursed to remain even after death..."
STRINGS["CHARACTERS"]["WENDY"]["ANNOUNCE_MINOTAUR_DEATH"] = "Be free, cursed soul."
STRINGS["CHARACTERS"]["WOODIE"]["ANNOUNCE_MINOTAUR_TRANSFORM"] = "Down for a rematch, aren'tcha?"
STRINGS["CHARACTERS"]["WICKERBOTTOM"]["ANNOUNCE_MINOTAUR_TRANSFORM"] =
    "The beast has become one with the ectoplasmic residue."
STRINGS["CHARACTERS"]["WATHGRITHR"]["ANNOUNCE_MINOTAUR_TRANSFORM"] = "Thou shall be felled as Fenrir was!"
STRINGS["CHARACTERS"]["WEBBER"]["ANNOUNCE_MINOTAUR_TRANSFORM"] = "We're not afraid of you!"
STRINGS["CHARACTERS"]["WINONA"]["ANNOUNCE_MINOTAUR_TRANSFORM"] =
    "The bigger they are, the harder they fall. Bring it on!"
STRINGS["CHARACTERS"]["WORTOX"]["ANNOUNCE_MINOTAUR_TRANSFORM"] = "Hyuyuyu! Let's dance with death till our last breath!"
STRINGS["CHARACTERS"]["WORMWOOD"]["ANNOUNCE_MINOTAUR_TRANSFORM"] = "Friend turning dark"
STRINGS["CHARACTERS"]["WARLY"]["ANNOUNCE_MINOTAUR_TRANSFORM"] = "Spicing things up now are we?"
STRINGS["CHARACTERS"]["WURT"]["ANNOUNCE_MINOTAUR_TRANSFORM"] = "GLORP! Beast came back to life!"
STRINGS["CHARACTERS"]["WALTER"]["ANNOUNCE_MINOTAUR_TRANSFORM"] = "Wow! He got all big and shadowy!"
STRINGS["CHARACTERS"]["WANDA"]["ANNOUNCE_MINOTAUR_TRANSFORM"] = "A time anomaly?! I must dismantle you for my answers!"
STRINGS["CHARACTERS"]["WANDA"]["DESCRIBE"]["DREADHAMMER"] = "It oozes with horror, and countless possibilities..."
STRINGS["CHARACTERS"]["WANDA"]["ANNOUNCE_DREADHAMMER_FAIL"] = "Does this tool need a bit more time, or more whacking?"

local function uFguuCikc(ufkUnCkKn, iFuUfciKu)
    local cFgUucgKn = (339 - 90 + 102 - 470 == -119)
    for gfcUgcgKg, nfkUfcgKk in kfcunCnkf(CONSTRUCTION_PLANS[ufkUnCkKn["prefab"]] or {}) do
        if ufkUnCkKn["components"]["constructionsite"]:GetMaterialCount(nfkUfcgKk["type"]) < nfkUfcgKk["amount"] then
            cFgUucgKn = (67 - 17 - 195 ~= -145)
            break
        end
    end
    if cFgUucgKn then
        ReplacePrefab(ufkUnCkKn, "minotau")
    end
end
AddPrefabPostInit(
    "minotaur",
    function(nFfugCnKg)
        if not TheWorld["ismastersim"] then
            return nFfugCnKg
        end
        nFfugCnKg:AddComponent("constructionsite")
        nFfugCnKg["components"]["constructionsite"]:SetConstructionPrefab("construction_container")
        nFfugCnKg["components"]["constructionsite"]:SetOnConstructedFn(uFguuCikc)
    end
)
if true then -- Thông báo sự kiện luôn bật.
    local ufiUcCcKc = GLOBAL["TheNet"]
    local ffuugCikk = GLOBAL["AllRecipes"]
    local cFcucCnkg = GLOBAL["RECIPETABS"]
    local nFiUnCnKu = GLOBAL["STRINGS"]
    local nFfUucfKu = GLOBAL["TUNING"]
    local iFcUkcnkn = GLOBAL["TECH"]
    local iFfUcCiku = GLOBAL["CUSTOM_RECIPETABS"]
    local kfuugCnKk = GLOBAL["Ingredient"]
    local gFiUfciKc = GLOBAL["SpawnPrefab"]
    local iFnuickKg = GLOBAL
    local iFgUfcnkn = GLOBAL
    AddSimPostInit(
        function()
            if  nFiUnCnKu["NAMES"]["ALTERGUARDIAN_PHASE1"] then
                nFiUnCnKu["NAMES"]["ALTERGUARDIAN_PHASE1"] = "Celestial Champion Phase 1"
                nFiUnCnKu["NAMES"]["ALTERGUARDIAN_PHASE2"] = "Celestial Champion Phase 2"
                nFiUnCnKu["NAMES"]["ALTERGUARDIAN_PHASE3"] = "Celestial Champion Phase 3"
                nFiUnCnKu["NAMES"]["SHENANIGANS"] = "Phật Tổ Như Lai"
                nFiUnCnKu["NAMES"]["DARKNESS"] = "Địa Mẫu Nương Nương"
                nFiUnCnKu["NAMES"]["MULTIPLAYER_PORTAL"] = "Quỷ Môn Quan"
                nFiUnCnKu["NAMES"]["MULTIPLAYER_PORTAL_MOONROCK"] = "Nam Thiên Môn"
                nFiUnCnKu["NAMES"]["SHADOWRIFT_PORTAL"] = "Shadows Rifts"
                nFiUnCnKu["NAMES"]["LUNARRIFT_PORTAL"] = "Lunar Rifts"
                nFiUnCnKu["NAMES"]["LUNARRIFT_CRYSTAL_SMALL"] = "Ryftstal"
                nFiUnCnKu["NAMES"]["LUNARRIFT_CRYSTAL_BIG"] = "Ryftstal"
                nFiUnCnKu["NAMES"]["SHADOWTHRALL_HANDS"] = "Ink Blight Jitters"
                nFiUnCnKu["NAMES"]["SHADOWTHRALL_HORNS"] = "Ink Blight Rasp"
                nFiUnCnKu["NAMES"]["SHADOWTHRALL_WINGS"] = "Ink Blight Shriek"
                nFiUnCnKu["NAMES"]["SHADOWTHRALL_MOUTH"] = "Ink Blight Rictus"
            end
        end
    )
    
    local function FormatBossName(inst)
        local upper_name = inst:GetDisplayName() or ""
        local utf8_lower = {"a","á","à","ả","ã","ạ","ă","ắ","ằ","ẳ","ẵ","ặ","â","ấ","ầ","ẩ","ẫ","ậ","e","é","è","ẻ","ẽ","ẹ","ê","ế","ề","ể","ễ","ệ","i","í","ì","ỉ","ĩ","ị","o","ó","ò","ỏ","õ","ọ","ô","ố","ồ","ổ","ỗ","ộ","ơ","ớ","ờ","ở","ỡ","ợ","u","ú","ù","ủ","ũ","ụ","ư","ứ","ừ","ử","ữ","ự","y","ý","ỳ","ỷ","ỹ","ỵ","đ"}
        local utf8_upper = {"A","Á","À","Ả","Ã","Ạ","Ă","Ắ","Ằ","Ẳ","Ẵ","Ặ","Â","Ấ","Ầ","Ẩ","Ẫ","Ậ","E","É","È","Ẻ","Ẽ","Ẹ","Ê","Ế","Ề","Ể","Ễ","Ệ","I","Í","Ì","Ỉ","Ĩ","Ị","O","Ó","Ò","Ỏ","Õ","Ọ","Ô","Ố","Ồ","Ổ","Ỗ","Ộ","Ơ","Ớ","Ờ","Ở","Ỡ","Ợ","U","Ú","Ù","Ủ","Ũ","Ụ","Ư","Ứ","Ừ","Ử","Ữ","Ự","Y","Ý","Ỳ","Ỷ","Ỹ","Ỵ","Đ"}
        for i = 1, #utf8_lower do
            upper_name = string.gsub(upper_name, utf8_lower[i], utf8_upper[i])
        end
        upper_name = string.upper(upper_name)
        
        local target_prefabs = {
            ["mutateddeerclops"] = true,
            ["mutatedbearger"] = true,
            ["hh_sharkboi"] = true,
            ["walrus"] = true,
            ["krampus"] = true,
        }
        
        if target_prefabs[inst.prefab] then
            return "★ " .. upper_name .. " ★"
        else
            return inst:GetDisplayName()
        end
    end

    local gFcunckku = {}
    gFcunckku["reflash"] = " vừa tái sinh."
    gFcunckku["iscoming"] = " đã đến."
    gFcunckku["appeared"] = " vừa xuất hiện."
    gFcunckku["summoned"] = " vừa được triệu hồi."
    gFcunckku["killed"] = " đã bị tiêu diệt."
    gFcunckku["gotkilledby"] = " đã bị tiêu diệt bởi "
    AddPrefabPostInit(
        "forest",
        function(nFuUucfkk)
            nFuUucfkk:WatchWorldState(
                "isspring",
                function(nFuUucfkk)
                    if TheWorld["state"]["isspring"] then
                        ufiUcCcKc:Announce("Mùa Xuân" .. gFcunckku["iscoming"])
                    end
                end
            )
            nFuUucfkk:WatchWorldState(
                "issummer",
                function(nFuUucfkk)
                    if TheWorld["state"]["issummer"] then
                        ufiUcCcKc:Announce("Mùa Hạ" .. gFcunckku["iscoming"])
                    end
                end
            )
            nFuUucfkk:WatchWorldState(
                "isautumn",
                function(nFuUucfkk)
                    if TheWorld["state"]["isautumn"] then
                        ufiUcCcKc:Announce("Mùa Thu" .. gFcunckku["iscoming"])
                    end
                end
            )
            nFuUucfkk:WatchWorldState(
                "iswinter",
                function(nFuUucfkk)
                    if TheWorld["state"]["iswinter"] then
                        ufiUcCcKc:Announce("Mùa Đông" .. gFcunckku["iscoming"])
                    end
                end
            )
        end
    )
    AddPrefabPostInit(
        "klaus",
        function(kFiUicfKc)
            local function gFuUnCkkg(kFiUicfKc, ifuuccnki)
                local kfnuicikn =
                    kFiUicfKc["components"]["combat"] and kFiUicfKc["components"]["combat"]["lastattacker"]
                if kfnuicikn ~= nil then
                    ufiUcCcKc:Announce(
                        FormatBossName(kFiUicfKc) .. gFcunckku["gotkilledby"] .. kfnuicikn["name"],
                        nil,
                        nil,
                        "item_drop"
                    )
                else
                    ufiUcCcKc:Announce(kFiUicfKc:GetDisplayName() .. gFcunckku["killed"], nil, nil, "item_drop")
                end
            end
            local function ifgUcCnkg(kFiUicfKc)
                if kFiUicfKc:IsUnchained() then
                    kFiUicfKc:ListenForEvent("attacked", gFuUnCkkg)
                end
            end
            kFiUicfKc:ListenForEvent("death", ifgUcCnkg)
        end
    )
    AddPrefabPostInit(
        "glommer",
        function(cfiUkCgKc)
            local function cfgUgCuku(cfiUkCgKc)
                if cfiUkCgKc:HasTag("companion") then
                    local kfguiCuKc = cfiUkCgKc["components"]["follower"]["leader"]
                    if kfguiCuKc["components"]["inventoryitem"]:IsHeld() then
                        local cfnUccikf = kfguiCuKc["components"]["inventoryitem"]["owner"]
                        if
                            cfnUccikf["prefab"] == "backpack" or cfnUccikf["prefab"] == "krampus_sack" or
                                cfnUccikf["prefab"] == "piggyback" or
                                cfnUccikf["prefab"] == "icepack" or
                                cfnUccikf["prefab"] == "klaus_sack" or
                                cfnUccikf["prefab"] == "backcub" or
                                cfnUccikf["prefab"] == "giantsfoot" or
                                cfnUccikf["prefab"] == "boltwingout" or
                                cfnUccikf["prefab"] == "kam_lan_cassock"
                         then
                            cfnUccikf = cfnUccikf["components"]["inventoryitem"]["owner"]
                        end
                        ufiUcCcKc:Announce(cfnUccikf["name"] .. " đang sở hữu " .. cfiUkCgKc["name"])
                    end
                else
                    ufiUcCcKc:Announce(cfiUkCgKc["name"] .. " vừa xuất thế. Tới và lấy nó nào!")
                end
            end
            cfiUkCgKc:ListenForEvent("startfollowing", cfgUgCuku)
        end
    )
    local kFkufcnkf = {"klaus_sack", "daywalker", "daywalker2"}
    for nFfUkCikg, fffUiCckg in pairs(kFkufcnkf) do
        AddPrefabPostInit(
            fffUiCckg,
            function(kFgUkCcKu)
                if not iFgUfcnkn["TheWorld"]["ismastersim"] then
                    return kFgUkCcKu
                end
                kFgUkCcKu:DoTaskInTime(
                    .5,
                    function(kFgUkCcKu)
                        ufiUcCcKc:SystemMessage(kFgUkCcKu:GetDisplayName() .. gFcunckku["reflash"])
                    end
                )
            end
        )
    end
    AddPrefabPostInit(
        "toadstool_cap",
        function(cFuUgCkkn)
            cFuUgCkkn:ListenForEvent(
                "ms_spawntoadstool",
                function()
                    ufiUcCcKc:SystemMessage(cFuUgCkkn:GetDisplayName() .. gFcunckku["reflash"])
                end
            )
        end
    )
    AddPrefabPostInit(
        "beequeenhive",
        function(kFuUuCnKk)
            kFuUuCnKk:ListenForEvent(
                "timerdone",
                function()
                    if kFuUuCnKk:GetDisplayName() == "Tổ Ong Chúa" then
                        ufiUcCcKc:Announce(kFuUuCnKk:GetDisplayName() .. gFcunckku["reflash"])
                    end
                end
            )
        end
    )
    AddPrefabPostInit(
        "atrium_gate",
        function(cfcukccKc)
            cfcukccKc:ListenForEvent(
                "timerdone",
                function()
                    if cfcukccKc["components"]["trader"]["enabled"] == (43 - 408 * 144 - 188 - 175 == -59072) then
                        ufiUcCcKc:Announce(cfcukccKc:GetDisplayName() .. gFcunckku["reflash"])
                    end
                end
            )
        end
    )
    AddPrefabPostInit(
        "dragonfly_spawner",
        function(kfcUuCiKg)
            kfcUuCiKg:ListenForEvent(
                "timerdone",
                function()
                    ufiUcCcKc:Announce("Dragonfly" .. gFcunckku["reflash"])
                end
            )
        end
    )
    AddPrefabPostInit(
        "terrarium",
        function(fFfUkCcKu)
            fFfUkCcKu:ListenForEvent(
                "timerdone",
                function()
                    if fFfUkCcKu["components"]["trader"]["enabled"] == (237 - 108 + 118 * 156 * 113 == 2080233) then
                        ufiUcCcKc:Announce("Terrarium" .. gFcunckku["reflash"])
                    end
                end
            )
        end
    )
    AddPrefabPostInit(
        "icefishing_hole",
        function(nFcuccikf)
            nFcuccikf:DoTaskInTime(
                .5,
                function(nFcuccikf)
                    ufiUcCcKc:SystemMessage("Frostjaw" .. gFcunckku["reflash"])
                end
            )
        end
    )
    AddPrefabPostInit(
        "walrus_camp",
        function(gFnuiCnkf)
            local function fFcugcnki(gFnuiCnkf, iFgufckKg)
                if iFgufckKg["name"] == "walrus" then
                    ufiUcCcKc:SystemMessage("MacTusk" .. gFcunckku["reflash"])
                end
            end
            gFnuiCnkf:ListenForEvent("timerdone", fFcugcnki)
        end
    )
    local kfcuicikg = {
        "deerclops",
        "moose",
        "bearger",
        "antlion",
        "malbatross",
        "mutateddeerclops",
        "mutatedbearger",
        "mutatedwarg",
        "lordfruitfly",
        "myth_nian",
        "myth_siving_boss",
        "tigershark",
        "twister",
        "mothergoose",
        "mock_dragonfly",
        "moonmaw_dragonfly"
    }
    for nFkUnccKi, nfuUkcikk in pairs(kfcuicikg) do
        AddPrefabPostInit(
            nfuUkcikk,
            function(fFfUgcgki)
                if not iFgUfcnkn["TheWorld"]["ismastersim"] then
                    return fFfUgcgki
                end
                fFfUgcgki:DoTaskInTime(
                    .5,
                    function(fFfUgcgki)
                        ufiUcCcKc:Announce(FormatBossName(fFfUgcgki) .. gFcunckku["appeared"])
                    end
                )
            end
        )
    end
    local ffkuccgkf = {"prime_mate", "lunarrift_portal", "lunarrift_crystal_big", "shadowrift_portal"}
    for ffiuuCkKn, kfiufcikk in pairs(ffkuccgkf) do
        AddPrefabPostInit(
            kfiufcikk,
            function(fFnUfCkKi)
                if not iFgUfcnkn["TheWorld"]["ismastersim"] then
                    return fFnUfCkKi
                end
                fFnUfCkKi:DoTaskInTime(
                    .5,
                    function(fFnUfCkKi)
                        ufiUcCcKc:SystemMessage(FormatBossName(fFnUfCkKi) .. gFcunckku["appeared"])
                    end
                )
            end
        )
    end
    local nfgUgcnKk = {"beequeen", "toadstool", "toadstool_dark", "stalker_atrium", "eyeofterror"}
    for kFkugCkKn, kffUgcukg in pairs(nfgUgcnKk) do
        AddPrefabPostInit(
            kffUgcukg,
            function(kFnUnCkkc)
                if not iFgUfcnkn["TheWorld"]["ismastersim"] then
                    return kFnUnCkkc
                end
                kFnUnCkkc:DoTaskInTime(
                    .5,
                    function(kFnUnCkkc)
                        ufiUcCcKc:Announce(FormatBossName(kFnUnCkkc) .. gFcunckku["summoned"])
                    end
                )
            end
        )
    end
    AddPrefabPostInit(
        "twinofterror1",
        function(nfgunckKk)
            nfgunckKk:DoTaskInTime(
                .5,
                function(nfgunckKk)
                    ufiUcCcKc:Announce("Twins of Terror" .. gFcunckku["summoned"])
                end
            )
        end
    )
    AddPrefabPostInit(
        "shadow_bishop",
        function(kfgunCcKi)
            kfgunCcKi:DoTaskInTime(
                .5,
                function(kfgunCcKi)
                    ufiUcCcKc:Announce("Shadow Pieces" .. gFcunckku["summoned"])
                end
            )
        end
    )
    AddPrefabPostInit(
        "alterguardian_phase1",
        function(fffUkcnkf)
            fffUkcnkf:DoTaskInTime(
                .5,
                function(fffUkcnkf)
                    ufiUcCcKc:Announce("Celestial Champion" .. gFcunckku["summoned"])
                end
            )
        end
    )
    AddPrefabPostInit(
        "rhino3_red",
        function(fFkUgcikn)
            fFkUgcikn:DoTaskInTime(
                .5,
                function(fFkUgcikn)
                    ufiUcCcKc:Announce("Tê Ngưu Tam Đại Vương" .. gFcunckku["summoned"])
                end
            )
        end
    )
    AddPrefabPostInit(
        "minotau",
        function(uFnUkCkkg)
            uFnUkCkkg:DoTaskInTime(
                .5,
                function(uFnUkCkkg)
                    ufiUcCcKc:Announce("〖 ENDGAME BOSS 〗: Multiverse Guardian" .. gFcunckku["summoned"])
                end
            )
        end
    )
    local nFgUicukc = {
        "deerclops",
        "moose",
        "bearger",
        "dragonfly",
        "antlion",
        "beequeen",
        "eyeofterror",
        "twinofterror1",
        "twinofterror2",
        "shadow_rook",
        "shadow_bishop",
        "shadow_knight",
        "toadstool",
        "toadstool_dark",
        "stalker_atrium",
        "minotaur",
        "minotau",
        "worm_boss_dirt",
        "malbatross",
        "crabking",
        "alterguardian_phase1",
        "alterguardian_phase2",
        "alterguardian_phase3",
        "mutateddeerclops",
        "mutatedbearger",
        "mutatedwarg",
        "shadowthrall_horns",
        "shadowthrall_hands",
        "shadowthrall_wings",
        "shadowthrall_mouth",
        "lordfruitfly",
        "lunarthrall_plant",
        "walrus",
        "prime_mate",
        "leif",
        "leif_sparse",
        "warg",
        "spiderqueen",
        "spat",
        "koalefant_summer",
        "koalefant_winter",
        "chester",
        "myth_nian",
        "rhino3_red",
        "rhino3_blue",
        "rhino3_yellow",
        "blackbear",
        "myth_goldfrog",
        "myth_siving_boss",
        "siving_foenix",
        "siving_moenix",
        "tigershark",
        "twister",
        "kraken",
        "adult_flytrap",
        "spider_monkey",
        "pigbandit",
        "antqueen",
        "ancient_herald",
        "pugalisk",
        "ancient_hulk",
        "mothergoose",
        "mock_dragonfly",
        "moonmaw_dragonfly",
        "hoodedwidow",
        "medal_beequeenhivegrown",
        "medal_spacetime_devourer",
        "medal_rage_krampus",
        "medal_beequeen",
        "walrus_adc"
    }
    for cFuUiCuKn, nFcUucuKc in pairs(nFgUicukc) do
        AddPrefabPostInit(
            nFcUucuKc,
            function(gFcuiccki)
                gFcuiccki:ListenForEvent(
                    "death",
                    function()
                        local gFfUuCukc =
                            gFcuiccki["components"]["combat"] and gFcuiccki["components"]["combat"]["lastattacker"]
                        if gFfUuCukc ~= nil then
                            ufiUcCcKc:Announce(
                                FormatBossName(gFcuiccki) .. gFcunckku["gotkilledby"] .. gFfUuCukc["name"],
                                nil,
                                nil,
                                "item_drop"
                            )
                        else
                            ufiUcCcKc:Announce(gFcuiccki:GetDisplayName() .. gFcunckku["killed"], nil, nil, "item_drop")
                        end
                    end
                )
            end
        )
    end
end
local function kFkugCcKu(kfnUnCcKf)
    local cfgukcgku = kfnUnCcKf["components"]["inventory"]:ReferenceAllItems()
    local cfiUiCcKf = 0
    for kfiUcCgKf, cfgufcckc in kfcunCnkf(cfgukcgku) do
        if cfgufcckc["prefab"] == "hh_treasure_tally" then
            if cfgufcckc["components"]["stackable"] then
                cfiUiCcKf = cfiUiCcKf + cfgufcckc["components"]["stackable"]:StackSize()
            else
                cfiUiCcKf = cfiUiCcKf + 1
            end
            for iFcunCkKf = 1, cfiUiCcKf do
                cfgufcckc:SpawnTreasureFn(kfnUnCcKf)
            end
        end
    end
    if kfnUnCcKf["components"]["talker"] then
        kfnUnCcKf["components"]["talker"]:Say("Bạn vừa mở " .. cfiUiCcKf .. " kho báu!", 5)
    end
end
AddPlayerPostInit(
    function(nFnuiCuKn)
        if not TheWorld["ismastersim"] then
            return nFnuiCuKn
        end
        nFnuiCuKn:ListenForEvent("motatcakhobau", kFkugCcKu)
    end
)
local nFuUfccKk = {}
function apply_negative_effects(ffcUccnKn)
    if ffcUccnKn["LastResSource"] and ffcUccnKn["LastResSource"]:HasTag("fire_rez_mod") then
        ffcUccnKn["components"]["hunger"]["current"] = ffcUccnKn["components"]["hunger"]["max"] * .2
        ffcUccnKn["components"]["sanity"]["current"] = ffcUccnKn["components"]["sanity"]["max"] * .5
        ffcUccnKn["components"]["health"]:SetCurrentHealth(ffcUccnKn["components"]["health"]["maxhealth"] * .1)
        ffcUccnKn["components"]["health"]:ForceUpdateHUD((359 * 73 - 427 * 226 - 68 == -70354))
    end
end
function save_last_respawn_source(cfuuncfki, cFfufCgkn)
    if cFfufCgkn then
        cfuuncfki["LastResSource"] = cFfufCgkn["source"]
    end
end
AddPlayerPostInit(
    function(gfkunCiki)
        gfkunCiki:ListenForEvent("respawnfromghost", save_last_respawn_source)
        gfkunCiki:ListenForEvent("ms_respawnedfromghost", apply_negative_effects)
    end
)
local fFnUkCiKk = function(gfnUicnKf, kFuUfCnKn)
    if (gfnUicnKf["components"]["fueled"] ~= nil) then
        gfnUicnKf["components"]["fueled"]:DoDelta(TUNING["LARGE_FUEL"])
    end
    gfnUicnKf["SoundEmitter"]:PlaySound("dontstarve/common/lightningrod")
    GLOBAL["TheWorld"]:PushEvent("ms_sendlightningstrike", GLOBAL["Vector3"](gfnUicnKf["Transform"]:GetWorldPosition()))
    return (27 + 418 + 49 + 379 + 295 ~= 1174)
end
for cffuccuki, fFuUicukk in kfcunCnkf(nFuUfccKk) do
    AddPrefabPostInit(
        fFuUicukk,
        function(cFiufcfkg)
            if (cFiufcfkg["components"]["hauntable"] ~= nil) then
                cFiufcfkg:RemoveComponent("hauntable")
            end
            cFiufcfkg:AddComponent("hauntable")
            cFiufcfkg["components"]["hauntable"]:SetOnHauntFn(fFnUkCiKk)
            cFiufcfkg["components"]["hauntable"]:SetHauntValue(TUNING["HAUNT_INSTANT_REZ"])
            cFiufcfkg:AddTag("resurrector")
            cFiufcfkg:AddTag("fire_rez_mod")
        end
    )
end
local fffUucfkn = {"playerghost", "INLIMBO"}
local gfkUuCckn = {"maprevealer"}
AddClassPostConstruct(
    "components/lunarthrall_plantspawner",
    function(self)
        local cFgUicfkk = self["FindHerd"]
        function self:FindHerd()
            local kfuuicgkc = cFgUicfkk(self)
            if kfuuicgkc ~= nil then
                local fFcukcfkg = kfuuicgkc:GetPosition()

                if kfuuicgkc ~= nil then
                    local ufcUuckku =
                        TheSim:FindEntities(
                        fFcukcfkg["x"],
                        fFcukcfkg["y"],
                        fFcukcfkg["z"],
                        TUNING["DEERCLOPSEYEBALL_SENTRYWARD_RADIUS"],
                        nil,
                        fffUucfkn
                    )
                    for ufkUfCuKi, gFuUgCfkg in pairs(ufcUuckku) do
                        if
                            gFuUgCfkg["prefab"] == "deerclopseyeball_sentryward" and gFuUgCfkg["_active"] and
                                gFuUgCfkg["_active"]:value() == (382 * 455 * 147 ~= 25550077)
                         then
                            kfuuicgkc = nil
                            break
                        end
                    end
                end
            end
            return kfuuicgkc
        end
    end
)
local cFiUgCfKc = {
    "wb_strengthen_strengthen_6_levelpaper",
    "wb_strengthen_strengthen_7_levelpaper",
    "wb_strengthen_strengthen_8_levelpaper",
    "wb_strengthen_strengthen_9_levelpaper",
    "wb_strengthen_strengthen_10_levelpaper",
    "wb_strengthen_strengthen_11_levelpaper",
    "wb_strengthen_strengthen_12_levelpaper",
    "opalpreciousgem"
}
local cfiUncnki = {"nn_liquidluck", "nn_liquidluck_2", "nn_liquidluck_3"}
local nfiufckkg = {"hh_quat_long_vu"}
for uffUcckkf, kFfUfcnkc in kfcunCnkf(cFiUgCfKc) do
    AddPrefabPostInit(
        kFfUfcnkc,
        function(cFnUiCukf)
            cFnUiCukf:AddTag("hh_add_stone")
        end
    )
end
for ufuUfCgKi, nffUcCgkc in pairs(nfiufckkg) do
    AddPrefabPostInit(
        nffUcCgkc,
        function(nFguucgKg)
            nFguucgKg:AddTag("hh_limit")
        end
    )
end
for kffuncnKi, kFkuiccKu in pairs(cfiUncnki) do
    AddPrefabPostInit(
        kFkuiccKu,
        function(ifuUnCuki)
            ifuUnCuki:AddTag("preparedfood")
        end
    )
end
local function iFcufCnKg(gFnUucnKu, kFuUgCgKk)
    if
        gFnUucnKu["_playerlink"] and gFnUucnKu["_playerlink"]:IsValid() and
            gFnUucnKu["_playerlink"]["components"]["sanity"]
     then
        gFnUucnKu["_playerlink"]["components"]["sanity"]:RemoveSanityPenalty(gFnUucnKu)
    end
    gFnUucnKu["_playerlink"] = kFuUgCgKk
    if gFnUucnKu["_playerlink"] and gFnUucnKu["_playerlink"]["components"]["sanity"] then
        gFnUucnKu["_playerlink"]["components"]["sanity"]:AddSanityPenalty(gFnUucnKu, 0.25)
    end
end
local function ffnUfCiKk(iFnuuCiKk)
    if
        iFnuuCiKk["_playerlink"] and iFnuuCiKk["_playerlink"]:IsValid() and
            iFnuuCiKk["_playerlink"]["components"]["sanity"]
     then
        iFnuuCiKk["_playerlink"]["components"]["sanity"]:RemoveSanityPenalty(iFnuuCiKk)
    end
end
AddPrefabPostInit(
    "hh_daogam4",
    function(gFkufcuKn)
        gFkufcuKn["_playerlink"] = nil
        if gFkufcuKn["components"]["inventoryitem"] then
        end
    end
)
local function cFkukckkc(nfuUcCikk)
    if nfuUcCikk["author"] and nfuUcCikk["author"]:IsValid() and nfuUcCikk["author"]["components"]["sanity"] then
        nfuUcCikk["author"]["components"]["sanity"]:RemoveSanityPenalty(nfuUcCikk)
        nfuUcCikk["author"]["components"]["sanity"]:DoDelta(-30)
        nfuUcCikk["author"]["components"]["health"]:DoDelta(-30)
    end
end
local function ufgUuccKf(iFfUfcgkn, kfkUgcnkk)
    if iFfUfcgkn["author"] and iFfUfcgkn["author"]:IsValid() and iFfUfcgkn["author"]["components"]["sanity"] then
        iFfUfcgkn["author"]["components"]["sanity"]:RemoveSanityPenalty(iFfUfcgkn)
    end
    if
        kfkUgcnkk and kfkUgcnkk["leader"] and kfkUgcnkk["leader"]:IsValid() and
            kfkUgcnkk["leader"]["components"]["sanity"]
     then
        kfkUgcnkk["leader"]["components"]["sanity"]:AddSanityPenalty(iFfUfcgkn, 0.1)
        iFfUfcgkn["author"] = kfkUgcnkk["leader"]
        kfkUgcnkk["leader"]:ListenForEvent("onremove", cFkukckkc, iFfUfcgkn)
    end
end
local function ufiUnciki(fFcUncuku, fFuUnCcKc)
    if fFcUncuku["author"] == fFuUnCcKc["attacker"] then
        fFcUncuku["components"]["health"]["_ignore_maxdamagetakenperhit"] = (224 * 258 * 444 + 261 - 12 ~= 25659904)
        fFcUncuku["components"]["health"]:Kill()
    end
end
AddPrefabPostInit(
    "nn_golem",
    function(ufuucciKk)
        ufuucciKk:ListenForEvent("attacked", ufiUnciki)
        ufuucciKk:ListenForEvent("startfollowing", ufgUuccKf)
    end
)
local function gfkUcCfKi(cFfuiCgKu)
    for uFiUfcgKi, uFkuuCnku in kfcunCnkf(cFfuiCgKu["components"]["commander"]:GetAllSoldiers()) do
        if uFkuuCnku:IsAsleep() then
            uFkuuCnku:Remove()
        end
    end
    cFfuiCgKu:Remove()
end
local function kfgugCuKn(kFcUucfkg)
    if kFcUucfkg["_sleeptask"] ~= nil then
        kFcUucfkg["_sleeptask"]:Cancel()
    end
    kFcUucfkg["_sleeptask"] =
        not (kFcUucfkg["components"]["health"]:IsDead()) and kFcUucfkg:DoTaskInTime(10, gfkUcCfKi) or nil
end
AddPrefabPostInit(
    "mutatedbearger",
    function(gffunciKi)
        if not TheWorld["ismastersim"] then
            return gffunciKi
        end
        gffunciKi:AddComponent("commander")
        gffunciKi["components"]["commander"]:SetTrackingDistance(30)
        gffunciKi["OnEntitySleep"] = kfgugCuKn
    end
)
AddPrefabPostInit(
    "mutateddeerclops",
    function(ifnUkcfki)
        if not TheWorld["ismastersim"] then
            return ifnUkcfki
        end
        ifnUkcfki:AddComponent("commander")
        ifnUkcfki["components"]["commander"]:SetTrackingDistance(30)
        ifnUkcfki["OnEntitySleep"] = kfgugCuKn
    end
)
local function ffguiCfkg(nFgUiCnkg, kFgUfcukf)
    nFgUiCnkg["components"]["lootdropper"]:DropLoot()
    if nFgUiCnkg["components"]["container"] ~= nil then
        nFgUiCnkg["components"]["container"]:DropEverything()
    end
    local uFgunCkkk = SpawnPrefab("collapse_small")
    uFgunCkkk["Transform"]:SetPosition(nFgUiCnkg["Transform"]:GetWorldPosition())
    uFgunCkkk:SetMaterial("wood")
    nFgUiCnkg:Remove()
    return
end
local function iFkuucfkn(kFcugcfKf, kFgunccKu)
    if kFcugcfKf["components"]["container"] ~= nil then
        kFcugcfKf["components"]["container"]:DropEverything(nil, (490 - 365 - 398 - 7 == -280))
        kFcugcfKf["components"]["container"]:Close()
    end
    kFcugcfKf["AnimState"]:PlayAnimation("hit")
    kFcugcfKf["AnimState"]:PushAnimation("closed", (329 - 91 * 22 + 411 == -1255))
end
local function gFnucckkn(kFiuncuKk, cFkUicckn)
    return kFiuncuKk["_chestupgrade_stacksize"] and "UPGRADED_STACKSIZE" or nil
end
local function gFcUfcnKc(nfuuiCuKc)
    if nfuuiCuKc["components"]["container"] ~= nil then
        nfuuiCuKc["components"]["container"]:DropEverything()
        nfuuiCuKc["components"]["container"]:Close()
    end
    SpawnPrefab("ash")["Transform"]:SetPosition(nfuuiCuKc["Transform"]:GetWorldPosition())
    SpawnPrefab("alterguardianhatshard")["Transform"]:SetPosition(nfuuiCuKc["Transform"]:GetWorldPosition())
    nfuuiCuKc:Remove()
end
local function kFfunCuku(iFgUnCgki, fFguiCnkk, fFiUiciKg)
    local uFfuccgkf = iFgUnCgki["components"]["upgradeable"]["numupgrades"]
    if uFfuccgkf == 1 then
        iFgUnCgki["_chestupgrade_stacksize"] = (29 * 130 * 461 - 335 == 1737635)
        if iFgUnCgki["components"]["container"] ~= nil then
            iFgUnCgki["components"]["container"]:Close()
            iFgUnCgki["components"]["container"]:EnableInfiniteStackSize((405 * 347 * 132 + 198 - 252 == 18550566))
            iFgUnCgki["components"]["inspectable"]["getstatus"] = gFnucckkn
        end
        if fFiUiciKg then
            local gFiUgckKn, fFuUucnKg, cFiUgCgKf = iFgUnCgki["Transform"]:GetWorldPosition()
            local gFnunCuKc = SpawnPrefab("chestupgrade_stacksize_taller_fx")
            gFnunCuKc["Transform"]:SetPosition(gFiUgckKn, fFuUucnKg, cFiUgCgKf)
        end
    end
    iFgUnCgki["components"]["upgradeable"]["upgradetype"] = nil
    if iFgUnCgki["components"]["lootdropper"] ~= nil then
        iFgUnCgki["components"]["lootdropper"]:SetLoot({"alterguardianhatshard"})
    end
    if iFgUnCgki["components"]["workable"] ~= nil then
        iFgUnCgki["components"]["workable"]:SetOnWorkCallback(iFkuucfkn)
        iFgUnCgki["components"]["workable"]:SetOnFinishCallback(ffguiCfkg)
    end
    if iFgUnCgki["components"]["burnable"] ~= nil then
        iFgUnCgki["components"]["burnable"]:SetOnBurntFn(gFcUfcnKc)
    end
    iFgUnCgki:ListenForEvent("restoredfromcollapsed", OnRestoredFromCollapsed)
end
local function uFiUuccku(nfgUiciKf, gfnufCukc, ffuUnCgKn)
    if nfgUiciKf["components"]["upgradeable"] ~= nil and nfgUiciKf["components"]["upgradeable"]["numupgrades"] > 0 then
        kFfunCuku(nfgUiciKf)
    end
end
local function fFcUkCfkk(ffuUgCcKc)
end
local function fFcUkCfkk(ffuUgCcKc)
    local ffcuiCcKf = ffuUgCcKc:AddComponent("upgradeable")
    ffcuiCcKf["upgradetype"] = UPGRADETYPES["CHEST"]
    ffcuiCcKf:SetOnUpgradeFn(kFfunCuku)
    ffuUgCcKc["OnLoad"] = uFiUuccku
end

AddPrefabPostInit("researchlab3", fFcUkCfkk)

CONSTRUCTION_PLANS["ruinsrelic_vase"] = {Ingredient("opalpreciousgem", 1), Ingredient("ice", 999)}

FUELTYPE["ESSENCE"] = "HH_ESSENCE"
local ufnuccgkc = GLOBAL
local nFuUucuKf = ufnuccgkc["require"]
local ifuufccku = nFuUucuKf "widgets/redux/loadingwidget"
if not ufnuccgkc["TheNet"]:IsDedicated() then
    ufnuccgkc["GetLoaderAtlasAndTex"] = function(gFkUkcfkn)
        return "images/ttk_loading_screen.xml", "loading_screen.tex"
    end
    local ffguiCfkn = {Asset("ATLAS", "images/ttk_loading_screen.xml"), Asset("IMAGE", "images/ttk_loading_screen.tex")}
    for _, asset in ipairs(ffguiCfkn) do table.insert(Assets, asset) end
    -- Loading widgets run before normal mod assets and survive prefab resets.
    -- Use a lowercase private prefab, re-registering before each preload.
    local loading_prefab = Prefab("ttk_loading_screen", function() end, ffguiCfkn)
    local function LoadLoadingScreen()
        RegisterPrefabs(loading_prefab)
        TheSim:LoadPrefabs({"ttk_loading_screen"})
    end
    LoadLoadingScreen()
    local old_keep_alive = ifuufccku.KeepAlive
    ifuufccku.KeepAlive = function(self, ...)
        LoadLoadingScreen()
        return old_keep_alive(self, ...)
    end
    local nFuUfCfkc = ifuufccku["SetEnabled"]
    ifuufccku["SetEnabled"] = function(self, kFkunCuKu)
        if kFkunCuKu then
            if self["legacy_fg"] then
                self["root_classic"]:RemoveChild(self["legacy_fg"])
                self["legacy_fg"]:Kill()
                self["legacy_fg"] = nil
            end
            if self["bg"] then
                self["bg"]:SetTexture(GetLoaderAtlasAndTex())
            end
        end
        nFuUfCfkc(self, kFkunCuKu)
    end
end
local iFnufcckf = {
    LOADING_TIPS = {
        TIPS_1 = "Mỗi lần thăng cấp, bạn nhận Điểm Thuộc Tính để phân bổ vào STR, AGI, VIT, SEN hoặc INT - Solo Leveling",
        TIPS_2 = "INT tăng giới hạn và tốc độ hồi Mana, đồng thời rút ngắn thời gian hồi của các kỹ năng bóng ma - Solo Leveling",
        TIPS_3 = "Khi lên cấp, Máu, Đói, Tinh Thần và Mana còn thiếu sẽ được hồi dần trong thời gian ngắn - Solo Leveling",
        TIPS_4 = "Khi EXP bị phong ấn, mọi EXP mới nhận sẽ bị chặn cho đến khi phong ấn hết hạn - Solo Leveling",
        TIPS_5 = "Mana tự hồi theo thời gian, nhưng Trỗi Dậy và các kỹ năng sử dụng Mana vẫn cần đủ tài nguyên để kích hoạt - Solo Leveling",
        TIPS_6 = "Mỗi Hầm Ngục có ngẫu nhiên từ 2 đến 10 làn sóng; hãy kiểm tra số đợt trước khi bước vào - Solo Leveling",
        TIPS_7 = "Làn sóng cuối luôn là trận Boss và lối thoát bị khoá cho đến khi Boss bị đánh bại - Solo Leveling",
        TIPS_8 = "Mỗi làn sóng thường triệu hồi 10 quái vật, còn làn sóng cuối chỉ triệu hồi một Boss - Solo Leveling",
        TIPS_9 = "Hầm Ngục từ 6 làn sóng trở lên nguy hiểm hơn và có thể gọi Igris, Sharkboi hoặc Beru làm Boss - Solo Leveling",
        TIPS_10 = "Quái thường trong Hầm Ngục có thể rơi Giấy Thuộc Tính và Lục Bảo Thạch, còn Boss mang phần thưởng cao hơn - Solo Leveling",
        TIPS_11 = "Nếu không có người tham gia trong một ngày, Hầm Ngục sẽ tự làm mới và bước vào thời gian chờ trước khi mở lại - Solo Leveling",
        TIPS_12 = "Hiệu ứng Hầm Ngục có thời hạn và có thể tăng EXP, sát thương, tốc độ hoặc chống chịu cho người chơi và Bóng ma - Solo Leveling",
        TIPS_13 = "Trỗi Dậy chỉ gọi được Bóng ma đã sở hữu và đang sẵn sàng; mỗi lần triệu hồi cần Mana và ít nhất 20 Tinh Thần - Solo Leveling",
        TIPS_14 = "Đa số Bóng ma tồn tại tối đa 3 phút; sau khi bị hạ hoặc thu hồi, chúng cần hồi phục trước lần Trỗi Dậy tiếp theo - Solo Leveling",
        TIPS_15 = "Bóng ma nhận EXP theo hoạt động của mình, lên cấp và nhận thêm Điểm Kỹ Năng ở mỗi mốc cấp chia hết cho 5 - Solo Leveling",
        TIPS_16 = "Igris và Beru thiên về chiến đấu, Fruitfly chăm cây, Mặc Ảnh khai thác tài nguyên và Hắc Ảnh bảo vệ chủ nhân - Solo Leveling",
        TIPS_17 = "Điểm Kỹ Năng của Bóng ma dùng để mở thiên phú theo chuỗi; hãy đạt đúng cấp và mở lần lượt từng thiên phú - Solo Leveling",
        TIPS_18 = "Thần Binh Phổ cho phép Đúc Linh Đá Thuộc Tính, Thanh Tẩy dòng đã ép và Kế Thừa thuộc tính sang trang bị mới - Solo Leveling",
        TIPS_19 = "Đá Cường Hoá nâng trang bị từng cấp; các mốc +3, +6 và +9 lần lượt mở thêm 1, 2 và 3 lỗ khảm - Solo Leveling",
        TIPS_20 = "Cường Hoá từ +6 đến +9 có thể tụt cấp, còn +10 đến +13 có thể mất trang bị; Bùa Ma Thuật và Bùa Bảo Vệ giúp chống lại hai rủi ro tương ứng - Solo Leveling"
    }
}
SetLoadingTipCategoryWeights(LOADING_SCREEN_TIP_CATEGORY_WEIGHTS_START, {OTHER = 1000})
SetLoadingTipCategoryWeights(LOADING_SCREEN_TIP_CATEGORY_WEIGHTS_END, {OTHER = 1000})
for nFiuiCnKi, cfnUfCnkf in pairs(iFnufcckf["LOADING_TIPS"]) do
    AddLoadingTip(
        STRINGS["UI"]["LOADING_SCREEN_OTHER_TIPS"],
        nFiuiCnKi,
        cfnUfCnkf,
        {scoreboard = CONTROL_SHOW_PLAYER_STATUS}
    )
end
TUNING["MOONFIRE_SHIELD_CD"] = 10
TUNING["MOONFIRE_SHIELD_GP"] = 0.7
TUNING["MOONFIRE_SHIELD_GP_SUPER"] = 0.8
AddComponentPostInit(
    "parryweapon",
    function(self)
        local nFkUgCuki = self["TryParry"]
        self["TryParry"] = function(self, iFiUkCikf, nFkUucfkk, ...)
            return nFkUucfkk and nFkUgCuki(self, iFiUkCikf, nFkUucfkk, ...)
        end
    end
)
ACTIONS["CASTAOE"]["stroverridefn"] = function(uFcucCgKi)
    if uFcucCgKi["invobject"] ~= nil and uFcucCgKi["doer"] ~= nil and uFcucCgKi["invobject"]:HasTag("lunar_shield") then
        return subfmt("Kim Chung Trạo")
    elseif
        uFcucCgKi["invobject"] ~= nil and uFcucCgKi["doer"] ~= nil and
            uFcucCgKi["invobject"]:HasTag("super_lunar_shield")
     then
        return subfmt("Tru Tâm Toả")
    end
    return uFcucCgKi["invobject"] ~= nil and uFcucCgKi["invobject"]["components"]["spellbook"] ~= nil and
        uFcucCgKi["invobject"]["components"]["spellbook"]:GetSpellName() or
        nil
end
local cFnUgCcKn = Action({priority = 10, mount_valid = (140 - 22 - 366 == -248)})
cFnUgCcKn["id"] = "SEAL"
cFnUgCcKn["strfn"] = function(ufkUgcnkf)
    local cFuUkcnKk = ufkUgcnkf["invobject"] or ufkUgcnkf["target"]
    return cFuUkcnKk and cFuUkcnKk["USEITEM_TYPE"] or "Dùng"
end
cFnUgCcKn["fn"] = function(kfiUuCkKi)
    if kfiUuCkKi["invobject"] and kfiUuCkKi["invobject"]["components"]["nn_useitem"] then
        kfiUuCkKi["invobject"]["components"]["nn_useitem"]:Use(kfiUuCkKi["target"], kfiUuCkKi["doer"])
        return (160 + 480 - 495 == 145)
    end
end
AddAction(cFnUgCcKn)
AddComponentAction(
    "USEITEM",
    "nn_useitem",
    function(nFfUuCfkc, iFfUuCnKc, kFiugCckg, kFiUnCukc)
        if
            kFiugCckg and nFfUuCfkc["nn_useitem_needfn"] ~= nil and
                nFfUuCfkc["nn_useitem_needfn"](nFfUuCfkc, kFiugCckg, iFfUuCnKc)
         then
            table["insert"](kFiUnCukc, cFnUgCcKn)
        end
    end
)
AddStategraphActionHandler(
    "wilson",
    ActionHandler(
        cFnUgCcKn,
        function(kfcucccKg, kFguicuki)
            local iffucCcKi = kFguicuki["invobject"] or kFguicuki["target"]
            if iffucCcKi then
                return iffucCcKi["onuseitemsgname"] or "dolongaction"
            end
            return "dolongaction"
        end
    )
)
AddStategraphActionHandler(
    "wilson_client",
    ActionHandler(
        cFnUgCcKn,
        function(fFnUgcnKn, ifgUcCcKc)
            local kFnucCnkf = ifgUcCcKc["invobject"] or ifgUcCcKc["target"]
            if kFnucCnkf then
                return kFnucCnkf["onuseitemsgname"] or "dolongaction"
            end
            return "dolongaction"
        end
    )
)
STRINGS["ACTIONS"]["SEAL"] = {USE = "Sử dụng", SEALING = "Phong Ấn", GIVE = STRINGS["ACTIONS"]["GIVE"]["GENERIC"]}
local nFuUucuKf = GLOBAL["require"]
local gfguuckki = GLOBAL["Vector3"]
local nFnUccukf = nFuUucuKf("containers")
local nffucciKf = {}
local iffUiCgkg = nFnUccukf["widgetsetup"]
function nFnUccukf.widgetsetup(fFgugCgku, ffiUkCfKk, ufuufcnKg, ...)
    local ffgUuCnkf = nffucciKf[ffiUkCfKk or fFgugCgku["inst"]["prefab"]]
    if ffgUuCnkf ~= nil then
        for nFnUcCuku, nFcugcnkg in pairs(ffgUuCnkf) do
            fFgugCgku[nFnUcCuku] = nFcugcnkg
        end
        fFgugCgku:SetNumSlots(fFgugCgku["widget"]["slotpos"] ~= nil and #fFgugCgku["widget"]["slotpos"] or 0)
    else
        iffUiCgkg(fFgugCgku, ffiUkCfKk, ufuufcnKg, ...)
    end
end
local function iFgukcuKf()
    local nfuugcfKn = {
        widget = {
            slotpos = {
                gfguuckki(0, 64 + 32 + 8 + 4, 0),
                gfguuckki(0, 32 + 4, 0),
                gfguuckki(0, -(32 + 4), 0),
                gfguuckki(0, -(64 + 32 + 8 + 4), 0)
            },
            animbank = "ui_cookpot_1x4",
            animbuild = "ui_cookpot_1x4",
            pos = gfguuckki(150, 0, 0),
            side_align_tip = 100,
            buttoninfo = {text = "Dung Hợp", position = gfguuckki(0, -165, 0)}
        },
        type = "eliminate"
    }
    return nfuugcfKn
end
nffucciKf["eliminate"] = iFgukcuKf()
for cfkUccnKu, fFfucCukk in pairs(nffucciKf) do
    nFnUccukf["MAXITEMSLOTS"] =
        math["max"](
        nFnUccukf["MAXITEMSLOTS"],
        fFfucCukk["widget"]["slotpos"] ~= nil and #fFfucCukk["widget"]["slotpos"] or 0
    )
end
local function kFkugCkkk(nFcUnCfKn, ffcUgCkkk)
    local fFnuccgki = ffcUgCkkk["components"]["container"]
    local ffuUicfkf = (345 * 160 * 395 + 256 - 353 ~= 21803903)
    for gfnugckKk = 1, fFnuccgki:GetNumSlots() do
        local kfiufcnKn = fFnuccgki:GetItemInSlot(gfnugckKk)
        if kfiufcnKn then

            if fFnuccgki:Has("nn_liquidluck_2", 3) and fFnuccgki:Has("purebrilliance", 2) then
                ffuUicfkf = (155 * 499 * 260 ~= 20109706)
                fFnuccgki:ConsumeByName("nn_liquidluck_2", 3)
                fFnuccgki:ConsumeByName("purebrilliance", 2)
                fFnuccgki:GiveItem(GLOBAL["SpawnPrefab"]("nn_liquidluck_3", 1))
            end
            if fFnuccgki:Has("nn_liquidluck", 3) and fFnuccgki:Has("purebrilliance", 1) then
                ffuUicfkf = (155 * 499 * 260 ~= 20109706)
                fFnuccgki:ConsumeByName("nn_liquidluck", 3)
                fFnuccgki:ConsumeByName("purebrilliance", 1)
                fFnuccgki:GiveItem(GLOBAL["SpawnPrefab"]("nn_liquidluck_2", 1))
            end

        end
    end
    if ffuUicfkf then
        if nFcUnCfKn and nFcUnCfKn["components"] and nFcUnCfKn["components"]["talker"] then
            nFcUnCfKn["components"]["talker"]:Say("Thành công!")
        end
    else
        if nFcUnCfKn and nFcUnCfKn["components"] and nFcUnCfKn["components"]["talker"] then
            nFcUnCfKn["components"]["talker"]:Say("Có gì đó sai sai!")
        end
    end
end
function nffucciKf.eliminate.widget.buttoninfo.fn(gfnUkcukc)
    if GLOBAL["TheWorld"]["ismastersim"] then
        kFkugCkkk(gfnUkcukc["components"]["container"]["opener"], gfnUkcukc)
    else
        SendModRPCToServer(GLOBAL["MOD_RPC"]["eliminate"]["eliminate"], gfnUkcukc)
    end
end
AddModRPCHandler("eliminate", "eliminate", kFkugCkkk)
AddAction("eliminating", "eliminating", kFkugCkkk)
local function ifcukCukc(gfiUkckKf)
    if not GLOBAL["TheWorld"]["ismastersim"] then
        gfiUkckKf:DoTaskInTime(
            0,
            function()
                if gfiUkckKf["replica"] then
                    if gfiUkckKf["replica"]["container"] then
                        gfiUkckKf["replica"]["container"]:WidgetSetup("eliminate")
                    end
                end
            end
        )
        return gfiUkckKf
    end
    if GLOBAL["TheWorld"]["ismastersim"] then
        if not gfiUkckKf["components"]["container"] then
            gfiUkckKf:AddComponent("container")
            gfiUkckKf["components"]["container"]:WidgetSetup("eliminate")
            gfiUkckKf["components"]["container"]:EnableInfiniteStackSize(true)
        end
    end
end
AddPrefabPostInit("researchlab3", ifcukCukc)
local ufnuccgkc = GLOBAL
local fFcUuccKi = ufnuccgkc["TUNING"]
local nFgUccgKg = ufnuccgkc["TheNet"]
local iFcUkciKu = ufnuccgkc["TheWorld"]
local gfiUnCikn = ufnuccgkc["ThePlayer"]
local ufiUfCiKi = ufnuccgkc["Ingredient"]
local cfkuicukf = env["AddClassPostConstruct"]
local gfguuckki = ufnuccgkc["Vector3"]
local nFgUicuKg = ufnuccgkc["SendModRPCToServer"]
local kfcUucuKc = ufnuccgkc["SendModRPCToClient"]
local iFiUuCnku = ufnuccgkc["GetModRPC"]
local nfcufCiki = ufnuccgkc["AddModRPCHandler"]
local gFkuucnKc = ufnuccgkc["SpawnPrefab"]
local ufiufcgkf = ufnuccgkc["AllRecipes"]
local cfcuucnkf = ufnuccgkc["BUTTONFONT"]
local fFguuCuKi = ufnuccgkc["NEWFONT"]
local cfgUncnkc = ufnuccgkc["ANCHOR_LEFT"]
local kFnufCnKk = ufnuccgkc["ANCHOR_MIDDLE"]
local nFfUiCukc = ufnuccgkc["TheInput"]
local uFgUgcgKn = ufnuccgkc["STRINGS"]
local nfkuncnKc = ufnuccgkc["RECIPETABS"]
local uFcuuckkg = ufnuccgkc["TECH"]
local cfnufCiku = ufnuccgkc["json"]
local iFgUfcfkf = ufnuccgkc["net_string"]
local kFfUfCfKu = ufnuccgkc["pcall"]
local fFkUgCukn = ufnuccgkc["RPC"]
local cFuUicnkn = ufnuccgkc["ACTIONS"]
local fffugcgKf = ufnuccgkc["SendRPCToServer"]
local ufiuuCgkk = ufnuccgkc["BufferedAction"]
local uFfUiCikg = ufnuccgkc["EQUIPSLOTS"]
local gFfUgCfKf = nFgUccgKg:GetIsServer() or nFgUccgKg:IsDedicated()
local ifgUucuKu = nFuUucuKf "widgets/templates"
local kfcuucnki = nFuUucuKf("widgets/image")
local cFfufcfKg = nFuUucuKf("widgets/imagebutton")
local kfnUfCkkf = nFuUucuKf("widgets/text")
local ifcUgcuki = nFuUucuKf("widgets/widget")
local gFfUfcgKg = nFuUucuKf("widgets/itemslot")
local gFkUuCcKf = GetModConfigData("wb_strengthen_weapon_base") or 5
local ffiUgCiKi = nFuUucuKf("util/wb_util")
local kfuuucfKu = nFuUucuKf("components/wb_strengthen")
kfuuucfKu["BUFFS_CONFIG"]["damage"]["weapon_base"] = gFkUuCcKf
fFcUuccKi["WB_STRENGTHEN_BLACKLIST"] =
    fFcUuccKi["WB_STRENGTHEN_BLACKLIST"] or
    {
        "fxyq",
        "philosopherstone",
        "nz_damask",
        "monster_book",
        "unsolved_book",
        "oldfish_mymod_weapon_thirty",
        "armorskeleton",

        "hh_quat_long_vu"
    }
fFcUuccKi["WB_STRENGTHEN_WHITELIST"] = fFcUuccKi["WB_STRENGTHEN_WHITELIST"] or {}
function CheckCanStrengthen(ffcufCkkn)
    if ffiUgCiKi["Includes"](fFcUuccKi["WB_STRENGTHEN_BLACKLIST"], ffcufCkkn["prefab"]) then
        return (26 * 346 - 293 + 389 == 9102)
    end
    if ffiUgCiKi["Includes"](fFcUuccKi["WB_STRENGTHEN_WHITELIST"], ffcufCkkn["prefab"]) then
        return (466 + 421 * 299 ~= 126355)
    end
    local nfnuuccKu = {"armor", "weapon", "tool", "equippable"}
    for uFkukccku, uffUucikn in kfcunCnkf(nfnuuccKu) do
        if ffcufCkkn:HasTag(uffUucikn) then
            return (348 * 443 * 218 + 116 ~= 33607878)
        end
    end
end
if gFfUgCfKf then
    AddPrefabPostInitAny(
        function(ufuuccckc)
            if (ufuuccckc["components"]["tool"] and not ufuuccckc:HasTag("tool")) then
                ufuuccckc:AddTag("tool")
            end
            if (ufuuccckc["components"]["weapon"] and not ufuuccckc:HasTag("weapon")) then
                ufuuccckc:AddTag("weapon")
            end
            if (ufuuccckc["components"]["armor"] and not ufuuccckc:HasTag("armor")) then
                ufuuccckc:AddTag("armor")
            end
            if (ufuuccckc["components"]["finiteuses"] and not ufuuccckc:HasTag("finiteuses")) then
                ufuuccckc:AddTag("finiteuses")
            end
            if (ufuuccckc["components"]["equippable"] and not ufuuccckc:HasTag("equippable")) then
                ufuuccckc:AddTag("equippable")
            end
            if (ufuuccckc["components"]["equippable"]) then
                if ufuuccckc["components"]["equippable"]["equipslot"] == uFfUiCikg["HANDS"] then
                    ufuuccckc:AddTag("equippable-hands")
                end
                if ufuuccckc["components"]["equippable"]["equipslot"] == uFfUiCikg["HEAD"] then
                    ufuuccckc:AddTag("equippable-head")
                end
                if ufuuccckc["components"]["equippable"]["equipslot"] == uFfUiCikg["BODY"] then
                    ufuuccckc:AddTag("equippable-body")
                end
                if ufuuccckc["components"]["equippable"]["equipslot"] == uFfUiCikg["NECK"] then
                    ufuuccckc:AddTag("equippable-neck")
                end
            end
            if ufuuccckc["components"]["inventoryitem"] ~= nil and CheckCanStrengthen(ufuuccckc) then
                ufuuccckc:AddComponent("wb_strengthen")
            end
        end
    )
    local uFnufCckn = {
        {"wb_strengthen_strengthen_6_levelpaper", 0.02},
        {"wb_strengthen_strengthen_7_levelpaper", 0.01},
        {"wb_strengthen_strengthen_8_levelpaper", 0.005},
        {"wb_strengthen_strengthen_9_levelpaper", 0.001},
        {"wb_strengthen_strengthen_10_levelpaper", 0.0001},
        {"wb_strengthen_strengthen_11_levelpaper", 0.00001},
        {"wb_strengthen_strengthen_12_levelpaper", 0.000001}
    }
    AddPrefabPostInit(
        "wetpouch",
        function(nfguuCcku)
            if not nfguuCcku["components"]["unwrappable"] then
                return
            end
            if not nfguuCcku["components"]["unwrappable"]["onunwrappedfn"] then
                return
            end
            nfguuCcku["components"]["unwrappable"]:SetOnUnwrappedFn(
                ffiUgCiKi["Wrap"](
                    nfguuCcku["components"]["unwrappable"]["onunwrappedfn"],
                    function(nFcUiCikf, nfguuCcku, kfcUuCgkf, cfkucckKc, ...)
                        local uFfuiCckn = math["random"](1, #uFnufCckn)
                        local ifguccfkg = uFnufCckn[uFfuiCckn]
                        if math["random"]() < (#uFnufCckn * ifguccfkg[2]) then
                            local kFgunCikf = nfguuCcku["components"]["inventoryitem"]:GetMoisture()
                            local kFiuucfku = nfguuCcku["components"]["inventoryitem"]:IsWet()
                            local ufcuuCkKk = gFkuucnKc(ifguccfkg[1])
                            if ufcuuCkKk ~= nil then
                                if ufcuuCkKk["Physics"] ~= nil then
                                    ufcuuCkKk["Physics"]:Teleport(kfcUuCgkf:Get())
                                else
                                    ufcuuCkKk["Transform"]:SetPosition(kfcUuCgkf:Get())
                                end
                                if ufcuuCkKk["components"]["inventoryitem"] ~= nil then
                                    ufcuuCkKk["components"]["inventoryitem"]:InheritMoisture(kFgunCikf, kFiuucfku)
                                end
                            end
                            if cfkucckKc ~= nil and cfkucckKc["SoundEmitter"] ~= nil then
                                cfkucckKc["SoundEmitter"]:PlaySound("dontstarve/common/together/packaged")
                            end
                            nfguuCcku:Remove()
                            return
                        end
                        return nFcUiCikf(nfguuCcku, kfcUuCgkf, cfkucckKc, ...)
                    end
                )
            )
        end
    )
    cfkuicukf(
        "components/wb_strengthen",
        function(self)
            self["DoFail"] =
                ffiUgCiKi["Wrap"](
                self["DoFail"],
                function(cfnUgCckk, cFkUfckki, kffUfCikg, nfkuicnkf, iFgUiCiku, ...)
                    cfnUgCckk(cFkUfckki, kffUfCikg, nfkuicnkf, iFgUiCiku, ...)
                    local ifkucCgKu = math["random"]()
                    if iFgUiCiku >= 10 then
                        local fFguccgku = nil
                        if ifkucCgKu < 0.0001 then
                            fFguccgku = gFkuucnKc("wb_strengthen_" .. nfkuicnkf .. "_" .. 12 .. "_levelpaper")
                        elseif ifkucCgKu < 0.001 then
                            fFguccgku = gFkuucnKc("wb_strengthen_" .. nfkuicnkf .. "_" .. 11 .. "_levelpaper")
                        elseif ifkucCgKu < 0.01 then
                            fFguccgku = gFkuucnKc("wb_strengthen_" .. nfkuicnkf .. "_" .. 10 .. "_levelpaper")
                        end
                        if fFguccgku then
                            kffUfCikg["components"]["inventory"]:GiveItem(fFguccgku)
                        end
                    end
                end
            )
            local function kfguucnKn(gfgUnCfKu, iFgUgcnku, kFuUncfKk, nffUucukk, nfiuuCfKg)
                local kfkunCckk = gfgUnCfKu["__protectpaper_dofailsayfn"]
                local kfkUkCkki = gfgUnCfKu["__protectpaper_isprotect"]
                local ufcuiCkKu = gfgUnCfKu["__magicpaper_isprotect"]
                if kfkUkCkki == (160 * 212 - 15 + 121 - 349 ~= 33687) then
                    return iFgUgcnku["components"]["talker"]:Say(
                        "May mà có Bùa Bảo Vệ, ko thì mất trang bị rồi!",
                        2.5,
                        (25 - 63 * 329 + 36 + 70 == -20591),
                        (489 - 375 - 41 ~= 76),
                        (426 + 199 + 402 - 254 - 150 == 632),
                        {0, 0, 0, 1}
                    )
                elseif kfkunCckk then
                    return kfkunCckk(gfgUnCfKu, iFgUgcnku, kFuUncfKk, nffUucukk, nfiuuCfKg)
                else
                    gfgUnCfKu:DoSay(iFgUgcnku, kFuUncfKk, nffUucukk, nfiuuCfKg)
                end
                if ufcuiCkKu == (158 * 481 - 205 - 36 - 475 == 75282) then
                    return iFgUgcnku["components"]["talker"]:Say(
                        "May mà có Bùa Ma Thuật, ko thì tụt cấp trang bị rồi!",
                        2.5,
                        (240 * 390 * 302 * 68 == 1922169609),
                        (432 * 332 + 220 * 39 ~= 152010),
                        (49 * 459 + 310 - 382 == 22424),
                        {0, 0, 0, 1}
                    )
                elseif kfkunCckk then
                    return kfkunCckk(gfgUnCfKu, iFgUgcnku, kFuUncfKk, nffUucukk, nfiuuCfKg)
                else
                    gfgUnCfKu:DoSay(iFgUgcnku, kFuUncfKk, nffUucukk, nfiuuCfKg)
                end
            end
            self["DoFail"] =
                ffiUgCiKi["Wrap"](
                self["DoFail"],
                function(kFuUgCkkn, kfgukCnKu, ifiUicnku, kfiUccnKn, iFfukcgki, cFguiccKi, ...)
                    kfgukCnKu["__protectpaper_dofailplayer"] = ifiUicnku
                    kfgukCnKu["__protectpaper_dofailmode"] = kfiUccnKn
                    kfgukCnKu["__protectpaper_dofailsayfn"] = cFguiccKi
                    kfgukCnKu["__protectpaper_infail"] =
                        (true and false or not true and true and false and not false or true or not false or false)
                    kfgukCnKu["__magicpaper_dofailplayer"] = ifiUicnku
                    kfgukCnKu["__magicpaper_dofailmode"] = kfiUccnKn
                    kfgukCnKu["__magicpaper_dofailsayfn"] = cFguiccKi
                    kfgukCnKu["__magicpaper_infail"] = (443 - 124 - 97 * 324 == -31109)
                    local inventory = ifiUicnku ~= nil and ifiUicnku["components"] ~= nil
                        and ifiUicnku["components"]["inventory"] or nil
                    local protection_prefab = kfiUccnKn ~= nil
                        and "wb_strengthen_" .. kfiUccnKn .. "_protectpaper"
                        or nil
                    local level_before = kfgukCnKu["level"]
                    local has_protection = false
                    local has_magic = false
                    if kfiUccnKn == "strengthen"
                        and iFfukcgki >= 10
                        and iFfukcgki <= 13
                        and level_before >= 9
                        and level_before <= 12
                        and inventory ~= nil then
                        has_protection = inventory:Has(protection_prefab, 1)
                        has_magic = inventory:Has("nn_magicpaper", 1)
                    end
                    local preserve_both_charms = has_protection
                        and has_magic
                    if preserve_both_charms then
                        inventory:ConsumeByName(protection_prefab, 1)
                        if GLOBAL.TheWorld ~= nil and GLOBAL.TheWorld.ismastersim then
                            ifiUicnku:PushEvent("ttk_strengthen_protection_used", { prefab=protection_prefab })
                        end
                        inventory:ConsumeByName("nn_magicpaper", 1)
                        kfgukCnKu["__bothpaper_preserve_fail"] = true
                        kfgukCnKu["__protectpaper_isprotect"] = true
                        kfgukCnKu["__magicpaper_isprotect"] = true
                    end
                    kFuUgCkkn(kfgukCnKu, ifiUicnku, kfiUccnKn, iFfukcgki, kfguucnKn, ...)
                    kfgukCnKu["__protectpaper_dofailplayer"] = nil
                    kfgukCnKu["__protectpaper_dofailmode"] = nil
                    kfgukCnKu["__protectpaper_dofailsayfn"] = nil
                    kfgukCnKu["__protectpaper_isprotect"] = nil
                    kfgukCnKu["__protectpaper_infail"] = nil
                    kfgukCnKu["__magicpaper_dofailplayer"] = nil
                    kfgukCnKu["__magicpaper_dofailmode"] = nil
                    kfgukCnKu["__magicpaper_dofailsayfn"] = nil
                    kfgukCnKu["__magicpaper_isprotect"] = nil
                    kfgukCnKu["__magicpaper_infail"] = nil
                    kfgukCnKu["__bothpaper_preserve_fail"] = nil
                end
            )
            self["SetLevel"] =
                ffiUgCiKi["Wrap"](
                self["SetLevel"],
                function(cFguccikf, ...)
                    if self["__bothpaper_preserve_fail"] == true then
                        return
                    end
                    return cFguccikf(...)
                end
            )
            self["inst"]["Remove"] =
                ffiUgCiKi["Wrap"](
                self["inst"]["Remove"],
                function(ffgUcCikf, ...)
                    if self["__bothpaper_preserve_fail"] == true then
                        return
                    end
                    if self["__protectpaper_infail"] == (456 - 458 + 190 == 188) then
                        local gfkUkCgkn = self["__protectpaper_dofailplayer"]
                        local uffUkCcKk = self["__protectpaper_dofailmode"]
                        if gfkUkCgkn["components"]["inventory"]:Has("wb_strengthen_" .. uffUkCcKk .. "_protectpaper", 1) then
                            gfkUkCgkn["components"]["inventory"]:ConsumeByName(
                                "wb_strengthen_" .. uffUkCcKk .. "_protectpaper",
                                1
                            )
                            if GLOBAL.TheWorld ~= nil and GLOBAL.TheWorld.ismastersim then
                                gfkUkCgkn:PushEvent("ttk_strengthen_protection_used", {
                                    prefab="wb_strengthen_" .. uffUkCcKk .. "_protectpaper" })
                            end
                            self["__protectpaper_isprotect"] = (468 + 226 * 296 + 493 ~= 67865)
                            return
                        end
                    end
                    return ffgUcCikf(...)
                end
            )
            self["DownLevel"] =
                ffiUgCiKi["Wrap"](
                self["DownLevel"],
                function(cFcUkCcku, ...)
                    if self["__bothpaper_preserve_fail"] == true then
                        return
                    end
                    if self["__magicpaper_infail"] == (491 + 259 + 496 - 489 - 168 == 589) then
                        local ffuUuCikg = self["__magicpaper_dofailplayer"]
                        local iFcufcfKc = self["__magicpaper_dofailmode"]
                        if ffuUuCikg["components"]["inventory"]:Has("nn_magicpaper", 1) then
                            ffuUuCikg["components"]["inventory"]:ConsumeByName("nn_magicpaper", 1)
                            self["__magicpaper_isprotect"] = (326 + 347 + 368 * 85 == 31953)
                            return
                        end
                    end
                    return cFcUkCcku(...)
                end
            )
            self["GetProbability"] =
                ffiUgCiKi["Wrap"](
                self["GetProbability"],
                function(kFguuciki, uFcuccnkn, ufiUuCkkn, cfcuuCckc, iFgugCkkf, ...)
                    local nfcUkCfkc = 0
                    if ufiUuCkkn and ufiUuCkkn["components"]["debuffable"] then
                        local kfiUcCckn = ufiUuCkkn["components"]["debuffable"]:GetDebuff("nn_liquidluck_buff")
                        local nfuUkCnKi = ufiUuCkkn["components"]["debuffable"]:GetDebuff("nn_liquidluck_2_buff")
                        local buff_3 = ufiUuCkkn["components"]["debuffable"]:GetDebuff("nn_liquidluck_3_buff")
                        if kfiUcCckn and cfcuuCckc == "strengthen" then
                            nfcUkCfkc = nfcUkCfkc + (kfiUcCckn["wb_strengthen_probability"] or 0)
                        elseif nfuUkCnKi and cfcuuCckc == "strengthen" then
                            nfcUkCfkc = nfcUkCfkc + (nfuUkCnKi["wb_strengthen_probability"] or 0)
                        elseif buff_3 and cfcuuCckc == "strengthen" then
                            nfcUkCfkc = nfcUkCfkc + (buff_3["wb_strengthen_probability"] or 0)
                        end
                    end
                    return kFguuciki(uFcuccnkn, ufiUuCkkn, cfcuuCckc, iFgugCkkf, ...) + nfcUkCfkc
                end
            )
        end
    )
end
local nFuUkCfKg = {SUPERLOW = 0.01, LOW = 0.10, MED = 0.5, HIGH = 1}
local ufiuucfKc = {
    oceanfish_medium_8_inv = nFuUkCfKg["HIGH"],
    oceanfish_small_8_inv = nFuUkCfKg["HIGH"],
    oceanfish_small_7_inv = nFuUkCfKg["HIGH"],
    oceanfish_small_6_inv = nFuUkCfKg["HIGH"]
}
local function fffUucuKk(uFkunCnkf)
    local cfnUgcckk = GLOBAL["SpawnPrefab"]("wb_strengthen_strengthen_6_levelpaper")
    local nfgUicikn, uFfukCkku, gffUkCnKg = uFkunCnkf["Transform"]:GetWorldPosition()
    cfnUgcckk["components"]["inventoryitem"]:DoDropPhysics(
        nfgUicikn,
        uFfukCkku,
        gffUkCnKg,
        (321 - 496 + 242 * 473 - 354 ~= 113943)
    )
end
local function kfuUccnkn(ffnugckki)
    local cFiUnCgkc = GLOBAL["SpawnPrefab"]("wb_strengthen_strengthen_7_levelpaper")
    local ifuUgCuki, fFcUfcikf, fFuuicnkg = ffnugckki["Transform"]:GetWorldPosition()
    cFiUnCgkc["components"]["inventoryitem"]:DoDropPhysics(ifuUgCuki, fFcUfcikf, fFuuicnkg, (270 + 152 * 66 ~= 10308))
end
local function uFgukCukk(ffkUiCuKf)
    local gFiUgCnkc = GLOBAL["SpawnPrefab"]("wb_strengthen_strengthen_8_levelpaper")
    local cFnUcCgku, ufuukCnku, gfnuncuKk = ffkUiCuKf["Transform"]:GetWorldPosition()
    gFiUgCnkc["components"]["inventoryitem"]:DoDropPhysics(
        cFnUcCgku,
        ufuukCnku,
        gfnuncuKk,
        (212 + 99 - 198 * 51 * 218 ~= -2201051)
    )
end
local function kfuUuCgkn(nFkUgCnKf)
    local cFuuicckg = GLOBAL["SpawnPrefab"]("wb_strengthen_strengthen_9_levelpaper")
    local cfcufCgkk, gffukCnKk, fFkUfCkKi = nFkUgCnKf["Transform"]:GetWorldPosition()
    cFuuicckg["components"]["inventoryitem"]:DoDropPhysics(
        cfcufCgkk,
        gffukCnKk,
        fFkUfCkKi,
        (281 - 240 * 293 * 171 ~= -12024431)
    )
end
AddPlayerPostInit(
    function(gFcuuccKn)
        if not GLOBAL["TheWorld"]["ismastersim"] then
            return
        end
        gFcuuccKn:ListenForEvent(
            "murdered",
            function(gFcuuccKn, uFkuuckku)
                if uFkuuckku and uFkuuckku["victim"] and ufiuucfKc[uFkuuckku["victim"]["prefab"]] then
                    if math["random"]() < 0.001 then
                        kfuUuCgkn(gFcuuccKn)
                    elseif math["random"]() < 0.005 then
                        uFgukCukk(gFcuuccKn)
                    elseif math["random"]() < 0.01 then
                        kfuUccnkn(gFcuuccKn)
                    elseif math["random"]() < 0.02 then
                        fffUucuKk(gFcuuccKn)
                    end
                end
            end
        )
    end
)
local nfiugcukf = {
    "asparagus_oversized",
    "carrot_oversized",
    "corn_oversized",
    "dragonfruit_oversized",
    "durian_oversized",
    "garlic_oversized",
    "onion_oversized",
    "pepper_oversized",
    "pomegranate_oversized",
    "potato_oversized",
    "pumpkin_oversized",
    "tomato_oversized",
    "watermelon_oversized",
    "eggplant_oversized"
}
for gfiuiCfKi, fFcukCfKk in kfcunCnkf(nfiugcukf) do
    AddPrefabPostInit(
        fFcukCfKk,
        function(kfkUfccKk)
            if kfkUfccKk["components"]["lootdropper"] then
                if math["random"]() < 0.001 then
                    kfkUfccKk["components"]["lootdropper"]:AddChanceLoot("wb_strengthen_strengthen_9_levelpaper", 1)
                elseif math["random"]() < 0.005 then
                    kfkUfccKk["components"]["lootdropper"]:AddChanceLoot("wb_strengthen_strengthen_8_levelpaper", 1)
                elseif math["random"]() < 0.01 then
                    kfkUfccKk["components"]["lootdropper"]:AddChanceLoot("wb_strengthen_strengthen_7_levelpaper", 1)
                elseif math["random"]() < 0.02 then
                    kfkUfccKk["components"]["lootdropper"]:AddChanceLoot("wb_strengthen_strengthen_6_levelpaper", 1)
                end
            end
        end
    )
end
local nFnUccukf = nFuUucuKf("containers")
cfkuicukf(
    "widgets/containerwidget",
    function(self)
        self["Open"] =
            ffiUgCiKi["Wrap"](
            self["Open"],
            function(cfcuuckkg, self, nFkUiccki, ...)
                local kfuUnCgKc = nFnUccukf["params"][nFkUiccki["prefab"]]
                if kfuUnCgKc and kfuUnCgKc["onbeforeopen"] ~= nil then
                    kfuUnCgKc["onbeforeopen"](self, nFkUiccki, ...)
                end
                cfcuuckkg(self, nFkUiccki, ...)
                if kfuUnCgKc and kfuUnCgKc["onopen"] ~= nil then
                    kfuUnCgKc["onopen"](self, nFkUiccki, ...)
                end
            end
        )
        self["Close"] =
            ffiUgCiKi["Wrap"](
            self["Close"],
            function(nFiUgCgKc, self, ...)
                if self["isopen"] then
                    local nfnucCkKc =
                        self["inst"] and self["inst"]["container"] and
                        nFnUccukf["params"][self["inst"]["container"]["prefab"]]
                    if nfnucCkKc and nfnucCkKc["onbeforeclose"] ~= nil then
                        nfnucCkKc["onbeforeclose"](self, ...)
                    end
                    nFiUgCgKc(self, ...)
                    if nfnucCkKc and nfnucCkKc["onclose"] ~= nil then
                        nfnucCkKc["onclose"](self, ...)
                    end
                end
            end
        )
    end
)
local function nfiuiCckf(kFcugCgKi, ifnUicuKu)
    nFnUccukf["params"][kFcugCgKi] = ifnUicuKu
    nFnUccukf["MAXITEMSLOTS"] =
        math["max"](
        nFnUccukf["MAXITEMSLOTS"],
        ifnUicuKu["widget"]["slotpos"] ~= nil and #ifnUicuKu["widget"]["slotpos"] or 0
    )
end
nfiuiCckf("hh_lo_ren", {
    widget = {slotpos = {gfguuckki(-245,35,0)}, pos = gfguuckki(0,0,0), top_align_tip = 50},
    openlimit = 1,
    usespecificslotsforitems = true,
    type = "cooker",
    itemtestfn = function(container,item) return item ~= nil and CheckCanStrengthen(item) end,
    onbeforeopen = function(self,container,owner)
        if self.isopen then return end
        self.strengthen_ui = self:AddChild(nFuUucuKf("widgets/hh_ui/ttk_strengthen_ui")(owner,container))
        self.strengthen_ui:MoveToBack()
    end,
    onopen = function(self,container,owner)
        if not self.isopen then return end
        if owner and owner.components.playeractionpicker then
            owner.components.playeractionpicker:RegisterContainer(container)
        end
        self.strengthen_ui:AttachContainerWidget(self)
        self.DoUpdateRender = function()
            local ok,data = pcall(cfnufCiku.decode,container._container_data:value())
            self.strengthen_ui:Refresh(ok and type(data)=="table" and data or {})
        end
        self.DoUpdateRender()
        self.inst:ListenForEvent("watch_container_data",self.DoUpdateRender,container)
    end,
    onbeforeclose = function(self)
        if self.isopen and self.strengthen_ui then
            self.inst:RemoveEventCallback("watch_container_data",self.DoUpdateRender,self.container)
            self.strengthen_ui:Kill()
            self.strengthen_ui,self.DoUpdateRender=nil,nil
        end
    end,
})
nfiuiCckf(
    "wb_strengthen_levelpaper_container",
    {
        widget = {
            slotpos = {gfguuckki(0, 20, 0)},
            animbank = "ui_bundle_2x2",
            animbuild = "ui_bundle_2x2",
            pos = gfguuckki(200, 0, 0),
            side_align_tip = 120,
            buttoninfo = {
                text = "Gói",
                position = gfguuckki(0, -100, 0),
                validfn = function(iFcugcckn)
                    return iFcugcckn["replica"]["container"] ~= nil and not iFcugcckn["replica"]["container"]:IsEmpty()
                end,
                fn = function(nfcuuCuKk, fFnuccikn)
                    if nfcuuCuKk["components"]["container"] ~= nil then
                        ufiuuCgkk(fFnuccikn, nfcuuCuKk, cFuUicnkn["WRAPBUNDLE"]):Do()
                    elseif nfcuuCuKk["replica"]["container"] ~= nil and not nfcuuCuKk["replica"]["container"]:IsBusy() then
                        fffugcgKf(
                            fFkUgCukn["DoWidgetButtonAction"],
                            cFuUicnkn["WRAPBUNDLE"]["code"],
                            nfcuuCuKk,
                            cFuUicnkn["WRAPBUNDLE"]["mod_name"]
                        )
                    end
                end
            }
        },
        openlimit = 1,
        type = "cooker",
        itemtestfn = function(nFiuccfku, cfgUgciKi, ufgUnCikc)
            if cfgUgciKi == nil then
                return (349 * 405 + 399 * 206 == 223544)
            end
            return CheckCanStrengthen(cfgUgciKi)
        end,
        onbeforeopen = function(self, ffnUkcfkg, cFfUcCckk)
            if self["isopen"] then
                return
            end
            self["label"] = self:AddChild(kfnUfCkkf(fFguuCuKi, 38, "Trang Bị", {0, 0, 0, 1}))
            self["label"]:SetPosition(0, -50, 0)
            self["label"]:SetHAlign(kFnufCnKk)
        end,
        onbeforeclose = function(self)
            if self["isopen"] and self["label"] then
                self["label"]:Kill()
            end
        end
    }
)

nfiuiCckf("wb_handsskill_paper_container", nFnUccukf["params"]["wb_strengthen_levelpaper_container"])
nfcufCiki(
    "hh_lo_ren",
    "strengthen",
    function(uFfUcCkKg, gFfucCiki, kFcUuccKc, ifnUkcgki, revision)
        if GLOBAL.TheWorld == nil or not GLOBAL.TheWorld.ismastersim then return end
        if not gFfucCiki or not gFfucCiki:IsValid() or gFfucCiki.prefab ~= "hh_lo_ren"
            or not uFfUcCkKg or not uFfUcCkKg:IsValid() then return end
        local station = gFfucCiki.components.container
        if not station or not station.openlist[uFfUcCkKg]
            or station:GetItemInSlot(1) ~= kFcUuccKc
            or uFfUcCkKg:GetDistanceSqToInst(gFfucCiki) > 16 then return end
        if revision ~= nil and revision ~= gFfucCiki._strengthen_revision then return end
        if kFcUuccKc == nil then
            return
        end
        if not kFcUuccKc["components"]["wb_strengthen"] then
            return
        end
        local iFnUnCgKi = kFcUuccKc["components"]["wb_strengthen"]
        -- The legacy RPC boolean is ignored: this forge only strengthens equipment.
        local kFuUfcikk = iFnUnCgKi["level"] + 1
        if kFuUfcikk > 13 then
            return uFfUcCkKg["components"]["talker"]:Say("Mức cường hoá cao nhất là +13")
        end
        local inventory = uFfUcCkKg["components"]["inventory"]
        if inventory:Has("wb_enhancegem", kFuUfcikk) then
            inventory:ConsumeByName("wb_enhancegem", kFuUfcikk)
            uFfUcCkKg:PushEvent("ttk_strengthen_gems_spent", { amount=kFuUfcikk })
            iFnUnCgKi:DoStrengthen(uFfUcCkKg)
            gFfucCiki:PushEvent("hh_lam_phuong_forge")
        end
        -- Acknowledge even when inventory changed after the displayed snapshot.
        gFfucCiki:UpdateContainerData()
    end
)
AddPrefabPostInit("dragonfly", function(inst)
    inst:ListenForEvent("death", function(inst, data)
        local hh_utils = require("utils/hh_utils")
        local credited_player = data ~= nil and hh_utils:GetKillCreditPlayer(data.afflicter) or nil
        if credited_player ~= nil then
            if math.random() <= 0.20 then
                credited_player.components.hh_player:AddItemsByKey("treasure_fireGem", 1, true)
                local killer_name = credited_player.name or credited_player.prefab or "Unknown"
                if hh_utils and hh_utils.NetSay then
                    hh_utils:NetSay(string.format("%s đã giết Dragonfly và nhận 1 viên Châu Báu quý hiếm", tostring(killer_name)))
                end
            end
        end
    end)
end)

------------------"Bảo★Lửa"----------------------
AddComponentPostInit("burnable", function(self, inst)
    local old_Ignite = self.Ignite
    if old_Ignite then
        self.Ignite = function(self, immediate, source, doer)
            old_Ignite(self, immediate, source, doer)
            local attacker = doer
            if not attacker and source then
                if source:HasTag("player") then
                    attacker = source
                elseif source.components and source.components.inventoryitem then
                    attacker = source.components.inventoryitem.owner
                elseif source.components and source.components.projectile then
                    attacker = source.components.projectile.owner
                elseif source.components and source.components.complexprojectile then
                    attacker = source.components.complexprojectile.attacker
                else
                    attacker = source.owner or source.caster or source.instigator
                end
            end
            
            if attacker and attacker:HasTag("player") then
                self.attacker = attacker
            end
            
            if attacker and attacker:HasTag("player") and attacker.components and attacker.components.inventory then
                local has_fire_gem = false
                local has_super_fire_gem = false
                
                if source and source.components and source.components.hh_equip and source.components.hh_equip.gems_list then
                    for _, gem in pairs(source.components.hh_equip.gems_list) do
                        if gem == "treasure_fireGem" then has_fire_gem = true end
                        if gem == "baconOmeletteFire" then has_super_fire_gem = true end
                    end
                end
                
                if attacker.components.inventory.equipslots then
                    for _, equip in pairs(attacker.components.inventory.equipslots) do
                        if equip and equip.components and equip.components.hh_equip and equip.components.hh_equip.gems_list then
                            for _, gem in pairs(equip.components.hh_equip.gems_list) do
                                if gem == "treasure_fireGem" then has_fire_gem = true end
                                if gem == "baconOmeletteFire" then has_super_fire_gem = true end
                            end
                        end
                    end
                end
                
                self.fire_gem_damage_mult = nil
                if self.inst.components.health == nil then
                    self.controlled_burn = nil
                end
                
                if has_super_fire_gem then
                    self.fire_gem_damage_mult = 1.50
                    if self.inst.components.health == nil then
                        self.controlled_burn = { damage = 1.50 }
                    end
                    self.stokeablefire = self.inst.components.health == nil
                elseif has_fire_gem then
                    self.fire_gem_damage_mult = 1.30
                    if self.inst.components.health == nil then
                        self.controlled_burn = { damage = 1.30 }
                    end
                    self.stokeablefire = self.inst.components.health == nil
                end
            end
        end
    end
    
    local old_Extinguish = self.Extinguish
    if old_Extinguish then
        self.Extinguish = function(self, ...)
            self.fire_gem_damage_mult = nil
            self.attacker = nil
            return old_Extinguish(self, ...)
        end
    end
end)

AddComponentPostInit("health", function(self, inst)
    local old_DoDelta = self.DoDelta
    if old_DoDelta then
        self.DoDelta = function(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...)
            if cause == "fire" and amount and amount < 0 then
                local mult = nil
                
                if afflicter and afflicter.components.burnable and afflicter.components.burnable.fire_gem_damage_mult then
                    mult = afflicter.components.burnable.fire_gem_damage_mult
                end
                
                if not mult and self.inst.components.burnable and self.inst.components.burnable.fire_gem_damage_mult then
                    mult = self.inst.components.burnable.fire_gem_damage_mult
                end
                
                if mult then
                    amount = amount * mult
                end
            end
            return old_DoDelta(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...)
        end
    end
end)


----------------

AddComponentPostInit("combat", function(self, inst)
    local old_GetAttacked = self.GetAttacked
    if old_GetAttacked then
        self.GetAttacked = function(self, attacker, damage, weapon, stimulus, spdamage, ...)
            if attacker and attacker.prefab and type(attacker.prefab) == "string" then
                local p = attacker.prefab
                local is_spell = false
                local owner = nil
                
                if string.find(p, "willow") and (string.find(p, "shadow") or string.find(p, "lunar") or string.find(p, "fire") or string.find(p, "flame")) then
                    is_spell = true
                    owner = attacker.owner or attacker.caster or attacker.instigator or 
                                  (attacker.components.projectile and attacker.components.projectile.owner) or
                                  (attacker.components.complexprojectile and attacker.components.complexprojectile.attacker)
                elseif attacker:HasTag("player") and p == "willow" then
                    if spdamage and type(spdamage) == "table" and spdamage.planar then
                        is_spell = true
                        owner = attacker
                    end
                end
                
                if is_spell then
                    if owner and owner:HasTag("player") and owner.components and owner.components.inventory then
                        local has_super = false
                        local has_rare = false
                        
                        if attacker and attacker.components and attacker.components.hh_equip and attacker.components.hh_equip.gems_list then
                            for _, gem in pairs(attacker.components.hh_equip.gems_list) do
                                if gem == "baconOmeletteFire" then has_super = true end
                                if gem == "treasure_fireGem" then has_rare = true end
                            end
                        end
                        
                        if owner.components.inventory.equipslots then
                            for _, equip in pairs(owner.components.inventory.equipslots) do
                                if equip and equip.components and equip.components.hh_equip and equip.components.hh_equip.gems_list then
                                    for _, gem in pairs(equip.components.hh_equip.gems_list) do
                                        if gem == "baconOmeletteFire" then has_super = true end
                                        if gem == "treasure_fireGem" then has_rare = true end
                                    end
                                end
                            end
                        end
                        
                        local mult = 1
                        if has_super then
                            mult = 1.25
                        elseif has_rare then
                            mult = 1.15
                        end
                            
                        if mult > 1 then
                            if damage and type(damage) == "number" then
                                damage = damage * mult
                            end
                            if spdamage and type(spdamage) == "table" and spdamage.planar then
                                local new_spdamage = {}
                                for k, v in pairs(spdamage) do new_spdamage[k] = v end
                                new_spdamage.planar = new_spdamage.planar * mult
                                spdamage = new_spdamage
                            end
                        end
                    end
                end
            end
            return old_GetAttacked(self, attacker, damage, weapon, stimulus, spdamage, ...)
        end
    end
end)

AddPrefabPostInit('world', function(inst)
    if not IsDungeonSurfaceAuthority(inst) then
        return
    end

    if not inst.components.dungeon_manager then
        inst:AddComponent('dungeon_manager')
    end
end)

-- [DUNGEON LOGIC: PLAYER DEATH AND ESCAPE BLOCK]
AddPlayerPostInit(function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
    
    inst:AddComponent("dungeon_cooldown") -- Simple timer component
    
    inst:ListenForEvent("ms_becameghost", function(player)
        if player:HasTag("in_solo_dungeon") then
            if player.components.inventory then
                player.components.inventory:DropEverything()
            end
            
            if not player._punished_by_dungeon then
                GLOBAL.TheNet:Announce("Người chơi " .. (player.name or "Ai đó") .. " đã thất bại trong việc chinh phục hầm ngục")
            end
            

            player:DoTaskInTime(5, function()
                if GLOBAL.TheWorld.components.dungeon_manager then
                    GLOBAL.TheWorld.components.dungeon_manager:LeaveDungeon(player)
                end
                
                if player.components.dungeon_cooldown then
                    player.components.dungeon_cooldown:StartTimer(16 * 60)
                end
            end)
        end
    end)
end)

-- Removed BlockDungeonEscape to allow Wortox blink and magic
AddComponentAction("SCENE", "teleporter", function(inst, doer, actions, right)
    if doer:HasTag("in_solo_dungeon") then
        for i, v in ipairs(actions) do
            if v == GLOBAL.ACTIONS.JUMPIN then
                table.remove(actions, i)
            end
        end
    end
end)
local function SayDungeonRestriction(doer, message, buffered_action)
    -- BufferedAction:IsValid is also evaluated by client prediction. Only the
    -- master simulation may enter the Talker pipeline, otherwise the client
    -- prints text without the server stategraph voice/mouth transition.
    if GLOBAL.TheWorld == nil or not GLOBAL.TheWorld.ismastersim
        or doer == nil or doer.components == nil
        or doer.components.talker == nil then
        return
    end
    if buffered_action ~= nil and buffered_action._hh_dungeon_restriction_spoken then
        return
    end
    if buffered_action ~= nil then
        buffered_action._hh_dungeon_restriction_spoken = true
    end
    doer.components.talker:Say(message)
end

local old_ActionFn = GLOBAL.BufferedAction
GLOBAL.BufferedAction = function(doer, target, action, invobject, pos, recipe, distance, forced, rotation)
    local ba = old_ActionFn(doer, target, action, invobject, pos, recipe, distance, forced, rotation)
    local old_isvalid = ba.IsValid
    ba.IsValid = function(self)
        if self.doer and self.doer:HasTag("in_solo_dungeon") then
            if self.action == GLOBAL.ACTIONS.JUMPIN then
                SayDungeonRestriction(self.doer, "Phép thuật dịch chuyển bị phong ấn!", self)
                return false
            end
            
            if self.action == GLOBAL.ACTIONS.REVIVE or self.action == GLOBAL.ACTIONS.RESURRECT then
                SayDungeonRestriction(self.doer, "Trong hầm ngục nguy hiểm không thể có cơ hội thứ 2", self)
                return false
            end
            
            if self.action == GLOBAL.ACTIONS.HAUNT and self.target and self.target.prefab == "amulet" then
                SayDungeonRestriction(self.doer, "Trong hầm ngục nguy hiểm không thể có cơ hội thứ 2", self)
                return false
            end
        end
        
        if self.target and self.target:HasTag("in_solo_dungeon") and (self.action == GLOBAL.ACTIONS.REVIVE or self.action == GLOBAL.ACTIONS.RESURRECT) then
            SayDungeonRestriction(self.doer, "Trong hầm ngục nguy hiểm không thể có cơ hội thứ 2", self)
            return false
        end
        
        return old_isvalid(self)
    end
    return ba
end

local OpenShadowSummonWheel = nil
local OpenShadowRecallWheel = nil

-- Kỹ năng Trỗi Dậy (Skill Wheel activation path)
local function TryOpenShadowSummon()
    if IsGuideOpen() or IsSummaryOpen() then
        return
    end
    if GLOBAL.ThePlayer and GLOBAL.TheFrontEnd then
        local active_screen = GLOBAL.TheFrontEnd:GetActiveScreen()
        if active_screen and active_screen.name == 'HUD' then
            local netvar = GLOBAL.ThePlayer.hh_shadows_cd
            local encoded = netvar ~= nil and netvar:value() or ""
            if encoded == "" then
                GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_hotkey_feedback"), "arise_no_shadows")
                return
            end
            
            local cd_netvar = GLOBAL.ThePlayer.hh_arise_cd
            local cooldown = cd_netvar ~= nil and cd_netvar:value() or 0
            if cooldown > 0 then
                GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_hotkey_feedback"), "arise_cooldown")
                return
            end
            
            if OpenShadowSummonWheel ~= nil then
                OpenShadowSummonWheel()
            end
        end
    end
end

-- Kỹ năng Thu Hồi (Skill Wheel activation path)
local function TryOpenShadowRecall()
    if IsGuideOpen() or IsSummaryOpen() then
        return
    end
    if GLOBAL.ThePlayer and GLOBAL.TheFrontEnd then
        local active_screen = GLOBAL.TheFrontEnd:GetActiveScreen()
        if active_screen and active_screen.name == 'HUD' then
            local netvar = GLOBAL.ThePlayer.hh_shadows_cd
            local encoded = netvar ~= nil and netvar:value() or ""
            if not string.find(encoded, ":%-1") then
                GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_hotkey_feedback"), "recall_no_active")
                return
            end
            
            local cd_netvar = GLOBAL.ThePlayer.hh_recall_cd
            local cooldown = cd_netvar ~= nil and cd_netvar:value() or 0
            if cooldown > 0 then
                GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_hotkey_feedback"), "recall_cooldown")
                return
            end
            
            if OpenShadowRecallWheel ~= nil then
                OpenShadowRecallWheel()
            end
        end
    end
end

-- Kỹ năng Hoán Đổi (Skill Wheel activation path)
local function TryShadowSwap()
    if IsGuideOpen() or IsSummaryOpen() then
        return
    end
    if GLOBAL.ThePlayer and GLOBAL.TheFrontEnd and GLOBAL.TheFrontEnd:GetActiveScreen() and GLOBAL.TheFrontEnd:GetActiveScreen().name == "HUD" then
        GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_swap"))
    end
end

-- Ra lệnh Fruit Fly Bóng Ma tới vị trí con trỏ (Hotkey L).
-- Hỗ trợ mặt đất trong HUD và bản đồ lớn; bỏ qua mọi HUD widget/minimap.
GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_L, function()
    if IsGuideOpen() or IsSummaryOpen() then
        return
    end
    if not (GLOBAL.ThePlayer and GLOBAL.TheFrontEnd) then
        return
    end

    local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    if screen == nil then
        return
    end

    local x, y, z
    if screen.name == "HUD" then
        if GLOBAL.TheInput:GetHUDEntityUnderMouse() ~= nil then
            return
        end
        local pos = GLOBAL.TheInput:GetWorldPosition()
        if pos ~= nil then
            x, y, z = pos.x, pos.y, pos.z
        end
    elseif screen.name == "MapScreen" and screen.GetWorldPositionAtCursor ~= nil then
        x, y, z = screen:GetWorldPositionAtCursor()
    end

    if x ~= nil and y ~= nil and z ~= nil then
        GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_command_fruitfly"), x, y, z)
    end
end)

-- Global tracking icons do not provide an action by themselves, so the stock Hoverer
-- has no target name to render. WX-78's scout drone registers its tracked proxies in
-- GlobalMapIconsDB; use the same public lookup path instead of world-scene mouse picking.
local HH_FRUITFLY_MAPICON_HIT_RADIUS = 24 -- screen pixels

local HH_DUNGEON_GATE_MAPICON_HIT_RADIUS = 24 -- screen pixels

local function GetDungeonGateMapIconHoverText(screen)
    if screen.GetCursorPosition == nil or screen.minimap == nil or
        GLOBAL.FindClosestMapIconInRange == nil then
        return nil
    end

    local cursor_x, cursor_y = screen:GetCursorPosition()
    local screen_width = GLOBAL.TheSim:GetScreenSize()
    if screen_width == nil or screen_width <= 0 then
        return nil
    end

    local world_x, world_z = screen.minimap:MapPosToWorldPos(cursor_x, cursor_y, 0)
    local edge_x, edge_z = screen.minimap:MapPosToWorldPos(
        cursor_x + (2 * HH_DUNGEON_GATE_MAPICON_HIT_RADIUS / screen_width),
        cursor_y,
        0
    )
    if world_x == nil or world_z == nil or edge_x == nil or edge_z == nil then
        return nil
    end

    local dx, dz = edge_x - world_x, edge_z - world_z
    local range = math.sqrt(dx * dx + dz * dz)
    local target = GLOBAL.FindClosestMapIconInRange(
        "dungeon_gate",
        world_x,
        0,
        world_z,
        range
    )
    if target == nil or not target:IsValid() then
        return nil
    end

    return target:GetDisplayName()
end

local function GetFruitflyMapIconHoverText(screen, owner)
    if screen.GetCursorPosition == nil or screen.minimap == nil or
        GLOBAL.FindClosestMapIconInRange == nil then
        return nil
    end

    local cursor_x, cursor_y = screen:GetCursorPosition()
    local screen_width = GLOBAL.TheSim:GetScreenSize()
    if screen_width == nil or screen_width <= 0 then
        return nil
    end

    -- Map coordinates are normalized to [-1, 1]. Convert a fixed pixel radius to
    -- world distance so the hit area stays stable across zoom levels/resolutions.
    local world_x, world_z = screen.minimap:MapPosToWorldPos(cursor_x, cursor_y, 0)
    local edge_x, edge_z = screen.minimap:MapPosToWorldPos(
        cursor_x + (2 * HH_FRUITFLY_MAPICON_HIT_RADIUS / screen_width),
        cursor_y,
        0
    )
    if world_x == nil or world_z == nil or edge_x == nil or edge_z == nil then
        return nil
    end

    local dx, dz = edge_x - world_x, edge_z - world_z
    local range = math.sqrt(dx * dx + dz * dz)
    local target = GLOBAL.FindClosestMapIconInRange(
        "hh_fruitfly_shadow",
        world_x,
        0,
        world_z,
        range,
        owner
    )

    if target == nil or not target:IsValid() then
        return nil
    end

    local target_name = target:GetDisplayName()
    local owner_name = target._hh_owner_name ~= nil and
        target._hh_owner_name:value() or nil
    if owner_name == nil or owner_name == "" then
        owner_name = owner ~= nil and owner:IsValid() and owner:GetDisplayName() or nil
    end
    if target_name == nil then
        return nil
    end

    return owner_name ~= nil and
        (target_name .. "\nChủ nhân: " .. owner_name) or
        target_name
end

local function GetMacanhMapIconHoverText(screen, owner)
    if screen.GetCursorPosition == nil or screen.minimap == nil or
        GLOBAL.FindClosestMapIconInRange == nil then
        return nil
    end

    local cursor_x, cursor_y = screen:GetCursorPosition()
    local screen_width = GLOBAL.TheSim:GetScreenSize()
    if screen_width == nil or screen_width <= 0 then
        return nil
    end

    local world_x, world_z = screen.minimap:MapPosToWorldPos(cursor_x, cursor_y, 0)
    local edge_x, edge_z = screen.minimap:MapPosToWorldPos(
        cursor_x + (2 * HH_FRUITFLY_MAPICON_HIT_RADIUS / screen_width),
        cursor_y,
        0
    )
    if world_x == nil or world_z == nil or edge_x == nil or edge_z == nil then
        return nil
    end

    local dx, dz = edge_x - world_x, edge_z - world_z
    local range = math.sqrt(dx * dx + dz * dz)
    local target = GLOBAL.FindClosestMapIconInRange(
        "hh_macanh_shadow", world_x, 0, world_z, range, owner
    )
    if target == nil then
        target = GLOBAL.FindClosestMapIconInRange(
            "hh_hacanh_shadow", world_x, 0, world_z, range, owner
        )
    end
    if target == nil or not target:IsValid() then
        return nil
    end

    local target_name = target:GetDisplayName()
    local owner_name = target._hh_owner_name ~= nil and target._hh_owner_name:value() or nil
    local status = target._hh_status ~= nil and target._hh_status:value() or nil
    if owner_name == nil or owner_name == "" then
        owner_name = owner ~= nil and owner:IsValid() and owner:GetDisplayName() or nil
    end
    if target_name == nil then
        return nil
    end
    status = status ~= nil and status ~= "" and status or "Đang theo chủ"
    return target_name .. "\nChủ nhân: " .. (owner_name or "Không xác định") .. "\n" .. status
end

AddClassPostConstruct("components/playercontroller", function(self)
    local old_GetHoverTextOverride = self.GetHoverTextOverride
    self.GetHoverTextOverride = function(controller, ...)
        local text = old_GetHoverTextOverride(controller, ...)
        if text ~= nil then
            return text
        end

        local screen = GLOBAL.TheFrontEnd ~= nil and GLOBAL.TheFrontEnd:GetActiveScreen() or nil
        if screen == nil or screen.name ~= "MapScreen" then
            return nil
        end

        return GetDungeonGateMapIconHoverText(screen)
            or GetMacanhMapIconHoverText(screen, controller.inst)
            or GetFruitflyMapIconHoverText(screen, controller.inst)
    end
end)

-- Kẻ Thống Trị uses the native AOE controller, so cancellation is observed
-- at the existing playercontroller boundary instead of installing raw mouse
-- handlers. The server receives only one cancel request for a real cancel;
-- native left-click confirmation is explicitly kept separate.
if not GLOBAL.TheNet:IsDedicated() then
    AddClassPostConstruct("components/playercontroller", function(self)
        local old_cancel_aoe = self.CancelAOETargeting
        self.CancelAOETargeting = function(controller, ...)
            local reticule = controller.reticule
            local is_ruler = reticule ~= nil
                and reticule.inst ~= nil
                and reticule.inst:HasTag("hh_ruler_caster")
            local result = old_cancel_aoe(controller, ...)

            if controller._hh_ruler_target_watch ~= nil then
                controller._hh_ruler_target_watch:Cancel()
                controller._hh_ruler_target_watch = nil
            end

            if is_ruler
                and not controller._hh_ruler_left_click
                and not controller._hh_ruler_suppress_cancel then
                GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_ruler_cancel"))
            end
            return result
        end

        local old_cancel_placement = self.CancelPlacement
        self.CancelPlacement = function(controller, ...)
            local reticule = controller.reticule
            local is_ruler = reticule ~= nil
                and reticule.inst ~= nil
                and reticule.inst:HasTag("hh_ruler_caster")
            local result = old_cancel_placement(controller, ...)
            if is_ruler and not controller._hh_ruler_left_click then
                controller:CancelAOETargeting()
            end
            return result
        end

        local old_left_click = self.OnLeftClick
        self.OnLeftClick = function(controller, down, ...)
            local reticule = controller.reticule
            local is_ruler = down
                and reticule ~= nil
                and reticule.inst ~= nil
                and reticule.inst:HasTag("hh_ruler_caster")
            if is_ruler then
                controller._hh_ruler_left_click = true
            end
            local result = old_left_click(controller, down, ...)
            if is_ruler then
                controller._hh_ruler_left_click = nil
            end
            return result
        end
    end)
end

local function IsRulerTargeting(controller)
    return controller ~= nil
        and controller.reticule ~= nil
        and controller.reticule.inst ~= nil
        and controller.reticule.inst:HasTag("hh_ruler_caster")
end

local function StartRulerTargetWatch(controller)
    if controller == nil or not IsRulerTargeting(controller) then
        return
    end
    if controller._hh_ruler_target_watch ~= nil then
        controller._hh_ruler_target_watch:Cancel()
    end

    controller._hh_ruler_target_watch = controller.inst:DoPeriodicTask(0.2, function(player)
        local current_controller = player.components ~= nil and player.components.playercontroller or nil
        if current_controller ~= controller or not IsRulerTargeting(current_controller) then
            if player.hh_ruler_caster ~= nil and player.hh_ruler_caster:value() ~= nil then
                GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_ruler_cancel"))
            end
            if controller._hh_ruler_target_watch ~= nil then
                controller._hh_ruler_target_watch:Cancel()
                controller._hh_ruler_target_watch = nil
            end
            return
        end

        local frontend = GLOBAL.TheFrontEnd
        local screen = frontend ~= nil and frontend:GetActiveScreen() or nil
        local health = player.components ~= nil and player.components.health or nil
        local invalid = not player:IsValid()
            or GLOBAL.TheWorld == nil
            or not GLOBAL.TheWorld:IsValid()
            or player:HasTag("playerghost")
            or (health ~= nil and health:IsDead())
            or screen == nil
            or screen.name ~= "HUD"
            or IsGuideOpen()
            or IsSummaryOpen()
            or (player.HUD ~= nil and player.HUD.HasInputFocus ~= nil and player.HUD:HasInputFocus())
        if invalid and player.components ~= nil and player.components.playercontroller ~= nil then
            player.components.playercontroller:CancelAOETargeting()
        end
    end)
end

AddPlayerPostInit(function(inst)
    if GLOBAL.TheNet:IsDedicated() then
        return
    end

    local function StartRulerWatchFromSignal(player)
        if player ~= GLOBAL.ThePlayer then
            return
        end
        local controller = player.components ~= nil and player.components.playercontroller or nil
        if IsRulerTargeting(controller) then
            StartRulerTargetWatch(controller)
        end
    end

    inst:ListenForEvent("hh_ruler_casterdirty", StartRulerWatchFromSignal)
    inst:ListenForEvent("hh_ruler_targetingstarted", StartRulerWatchFromSignal)
end)

-- Kỹ năng Thánh Vực Hồi Phục (Skill Wheel activation path)
local function TryCastSanctuary()
    if IsGuideOpen() or IsSummaryOpen() then
        return
    end

    local player = GLOBAL.ThePlayer
    local frontend = GLOBAL.TheFrontEnd
    if player == nil or not player:IsValid()
        or frontend == nil
        or GLOBAL.TheWorld == nil
        or not GLOBAL.TheWorld:IsValid()
        or player:HasTag("playerghost") then
        return
    end

    if GLOBAL.TheNet.IsServerPaused ~= nil and GLOBAL.TheNet:IsServerPaused() then
        return
    end

    local health = player.components ~= nil and player.components.health or nil
    if health ~= nil and health:IsDead() then
        return
    end

    local active_screen = frontend:GetActiveScreen()
    if active_screen == nil or active_screen.name ~= "HUD" then
        return
    end

    if player.HUD ~= nil and
        player.HUD.HasInputFocus ~= nil and
        player.HUD:HasInputFocus() then
        return
    end

    local cooldown_netvar = player.hh_sanctuary_cd
    local cooldown = cooldown_netvar ~= nil and cooldown_netvar:value() or 0
    if cooldown > 0 then
        GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_hotkey_feedback"), "sanctuary_cooldown")
        return
    end

    GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_sanctuary_cast"))
end

-- Kỹ năng Diệt Thần (Skill Wheel activation path)
local function TryCastGodslayer()
    if IsGuideOpen() or IsSummaryOpen() then
        return
    end

    local player = GLOBAL.ThePlayer
    local frontend = GLOBAL.TheFrontEnd
    if player == nil or not player:IsValid()
        or frontend == nil
        or GLOBAL.TheWorld == nil
        or not GLOBAL.TheWorld:IsValid()
        or player:HasTag("playerghost") then
        return
    end

    if GLOBAL.TheNet.IsServerPaused ~= nil and GLOBAL.TheNet:IsServerPaused() then
        return
    end

    local health = player.components ~= nil and player.components.health or nil
    if health ~= nil and health:IsDead() then
        return
    end

    local active_screen = frontend:GetActiveScreen()
    if active_screen == nil or active_screen.name ~= "HUD" then
        return
    end

    if player.HUD ~= nil and
        player.HUD.HasInputFocus ~= nil and
        player.HUD:HasInputFocus() then
        return
    end

    local cooldown_netvar = player.hh_godslayer_cd
    local cooldown = cooldown_netvar ~= nil and cooldown_netvar:value() or 0
    if cooldown > 0 then
        GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_hotkey_feedback"), "godslayer_cooldown")
        return
    end

    GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_godslayer_cast"))
end

-- Kỹ năng Nhà Vua (Skill Wheel activation path)
local function TryCastKing()
    if IsGuideOpen() or IsSummaryOpen() then
        return
    end

    local player = GLOBAL.ThePlayer
    local frontend = GLOBAL.TheFrontEnd
    if player == nil or not player:IsValid()
        or frontend == nil
        or GLOBAL.TheWorld == nil
        or not GLOBAL.TheWorld:IsValid()
        or player:HasTag("playerghost") then
        return
    end

    if GLOBAL.TheNet.IsServerPaused ~= nil and GLOBAL.TheNet:IsServerPaused() then
        return
    end

    local health = player.components ~= nil and player.components.health or nil
    if health ~= nil and health:IsDead() then
        return
    end

    local active_screen = frontend:GetActiveScreen()
    if active_screen == nil or active_screen.name ~= "HUD" then
        return
    end

    if player.HUD ~= nil
        and player.HUD.HasInputFocus ~= nil
        and player.HUD:HasInputFocus() then
        return
    end

    local cooldown_netvar = player.hh_king_cd
    local cooldown = cooldown_netvar ~= nil and cooldown_netvar:value() or 0
    if cooldown > 0 then
        GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_hotkey_feedback"), "king_cooldown")
        return
    end

    GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_king_cast"))
end

-- Kỹ năng Kẻ Thống Trị (Skill Wheel activation path)
local function TryBeginRuler()
    if IsGuideOpen() or IsSummaryOpen() then
        return
    end

    local player = GLOBAL.ThePlayer
    local frontend = GLOBAL.TheFrontEnd
    if player == nil or not player:IsValid()
        or frontend == nil
        or GLOBAL.TheWorld == nil
        or not GLOBAL.TheWorld:IsValid()
        or player:HasTag("playerghost") then
        return
    end

    if GLOBAL.TheNet.IsServerPaused ~= nil and GLOBAL.TheNet:IsServerPaused() then
        return
    end

    local health = player.components ~= nil and player.components.health or nil
    if health ~= nil and health:IsDead() then
        return
    end

    local active_screen = frontend:GetActiveScreen()
    if active_screen == nil or active_screen.name ~= "HUD" then
        return
    end

    if player.HUD ~= nil
        and player.HUD.HasInputFocus ~= nil
        and player.HUD:HasInputFocus() then
        return
    end

    local controller = player.components ~= nil and player.components.playercontroller or nil
    if controller == nil or controller:IsAOETargeting() then
        return
    end

    if player.hh_ruler_caster ~= nil and player.hh_ruler_caster:value() ~= nil then
        return
    end

    local cooldown_netvar = player.hh_ruler_cd
    local cooldown = cooldown_netvar ~= nil and cooldown_netvar:value() or 0
    if cooldown > 0 then
        GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_hotkey_feedback"), "ruler_cooldown")
        return
    end

    GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_ruler_begin"))
end

-- Bảng Trạng Thái (Hotkey B)
if not GLOBAL.TheNet:IsDedicated() then
    local UnifiedOpen = GLOBAL.require("ui/ttk_unified_open")
    GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_B, function()
        if IsGuideOpen() then return end
        if GLOBAL.ThePlayer and GLOBAL.TheFrontEnd then
            UnifiedOpen.Toggle(GLOBAL.ThePlayer, "character")
        end
    end)
end

-- Skill Wheel: client-only HUD overlay. It never claims HUD focus, so the
-- PlayerController continues to receive WASD and ordinary gameplay input.
if not GLOBAL.TheNet:IsDedicated() then
    local RankDefs = GLOBAL.require("guild/hh_rank_defs")
    local function HasGuildRank(player, required_rank)
        local rank_netvar = player ~= nil and player.hh_guild_rank or nil
        local rank = rank_netvar ~= nil and rank_netvar:value() or RankDefs.RANK.E
        return rank >= required_rank
    end

    local function TryOpenMonarchStorage()
        GLOBAL.require("ui/ttk_unified_open").Open(GLOBAL.ThePlayer, "storage")
    end

    local SKILL_DEFS = {
        {
            id = "summon",
            label = "Triệu Hồi",
            atlas = "images/skill_wheel/trieu_hoi.xml",
            texture = "trieu_hoi.tex",
            activate = TryOpenShadowSummon,
            cooldown_netvar = "hh_arise_cd",
            cooldown_total_netvar = "hh_arise_cd_total",
        },
        {
            id = "recall",
            label = "Thu Hồi",
            atlas = "images/skill_wheel/thu_hoi.xml",
            texture = "thu_hoi.tex",
            activate = TryOpenShadowRecall,
            cooldown_netvar = "hh_recall_cd",
            cooldown_total_netvar = "hh_recall_cd_total",
        },
        {
            id = "swap",
            label = "Hoán Đổi",
            atlas = "images/skill_wheel/hoan_doi.xml",
            texture = "hoan_doi.tex",
            activate = TryShadowSwap,
            cooldown_netvar = "hh_swap_cd",
            cooldown_total_netvar = "hh_swap_cd_total",
        },
        {
            id = "sanctuary",
            label = "Thánh Vực Hồi Phục",
            atlas = "images/skill_wheel/thanh_vuc_hoi_phuc.xml",
            texture = "thanh_vuc_hoi_phuc.tex",
            activate = TryCastSanctuary,
            cooldown_netvar = "hh_sanctuary_cd",
            cooldown_total_netvar = "hh_sanctuary_cd_total",
            is_unlocked = function(player)
                return HasGuildRank(player, RankDefs.RANK.D)
            end,
        },
        {
            id = "godslayer",
            label = "Diệt Thần",
            atlas = "images/skill_wheel/diet_than.xml",
            texture = "diet_than.tex",
            activate = TryCastGodslayer,
            cooldown_netvar = "hh_godslayer_cd",
            cooldown_total_netvar = "hh_godslayer_cd_total",
            is_unlocked = function(player)
                return HasGuildRank(player, RankDefs.RANK.C)
            end,
        },
        {
            id = "ruler",
            label = "Kẻ Thống Trị",
            atlas = "images/skill_wheel/ke_thong_tri.xml",
            texture = "ke_thong_tri.tex",
            activate = TryBeginRuler,
            cooldown_netvar = "hh_ruler_cd",
            cooldown_total_netvar = "hh_ruler_cd_total",
            is_unlocked = function(player)
                return HasGuildRank(player, RankDefs.RANK.B)
            end,
        },
        {
            id = "king",
            label = "Nhà Vua",
            atlas = "images/skill_wheel/nha_vua_icon.xml",
            texture = "nha_vua_icon.tex",
            activate = TryCastKing,
            cooldown_netvar = "hh_king_cd",
            cooldown_total_netvar = "hh_king_cd_total",
            is_unlocked = function(player)
                return HasGuildRank(player, RankDefs.RANK.S)
            end,
        },
        {
            id = "monarch_storage",
            label = "Kho Quân Vương",
            atlas = "images/skill_wheel/kho_quan_vuong_icon.xml",
            texture = "kho_quan_vuong_icon.tex",
            activate = TryOpenMonarchStorage,
            is_unlocked = function(player)
                return HasGuildRank(player, RankDefs.RANK.A)
            end,
        },
    }

    local SHADOW_WHEEL_DATA = {
        { id = "igris", label = "Igris", prefab = "hh_igris_shadow", icon = "igris_icon" },
        { id = "beru", label = "Beru", prefab = "hh_beru_shadow", icon = "beru_icon" },
        { id = "fruitfly", label = "Fruitfly", prefab = "hh_fruitfly_shadow", icon = "fruitfly_icon" },
        { id = "macanh", label = "Mặc Ảnh", prefab = "hh_macanh_shadow", icon = "mac_anh_icon" },
        { id = "hacanh", label = "Hắc Ảnh", prefab = "hh_hacanh_shadow", icon = "hac_anh_icon" },
    }

    local shadow_state_owner = nil
    local shadow_state_encoded = nil
    local shadow_state_cache = {}

    local function GetShadowStates(owner)
        local netvar = owner ~= nil and owner.hh_shadows_cd or nil
        local encoded = netvar ~= nil and netvar:value() or ""
        if owner == shadow_state_owner and encoded == shadow_state_encoded then
            return shadow_state_cache
        end

        local states = {}
        for chunk in string.gmatch(encoded, "([^|]+)") do
            local separator = string.find(chunk, ":", 1, true)
            if separator ~= nil then
                local prefab = string.sub(chunk, 1, separator - 1)
                local cooldown = tonumber(string.sub(chunk, separator + 1))
                if prefab ~= "" and cooldown ~= nil then
                    states[prefab] = cooldown
                end
            end
        end
        shadow_state_owner = owner
        shadow_state_encoded = encoded
        shadow_state_cache = states
        return states
    end

    local function GetGlobalCooldown(owner, field)
        local netvar = owner ~= nil and owner[field] or nil
        return netvar ~= nil and netvar:value() or 0
    end

    local function BuildShadowWheelDefs(mode)
        local defs = {}
        for _, data in ipairs(SHADOW_WHEEL_DATA) do
            local shadow = data
            defs[#defs + 1] = {
                id = shadow.id,
                label = shadow.label,
                atlas = "images/skill_wheel/" .. shadow.icon .. ".xml",
                texture = shadow.icon .. ".tex",
                checkenabled = function(owner)
                    local state = GetShadowStates(owner)[shadow.prefab]
                    if mode == "summon" then
                        return state == 0 and GetGlobalCooldown(owner, "hh_arise_cd") <= 0
                    end
                    return state == -1 and GetGlobalCooldown(owner, "hh_recall_cd") <= 0
                end,
                activate = function()
                    GLOBAL.SendModRPCToServer(
                        GLOBAL.GetModRPC("hh_rpc", mode == "summon" and "hh_arise" or "hh_recall"),
                        shadow.prefab
                    )
                end,
            }
        end
        return defs
    end

    local SUMMON_WHEEL_DEFS = BuildShadowWheelDefs("summon")
    local RECALL_WHEEL_DEFS = BuildShadowWheelDefs("recall")

    local function CanUseSkillWheel()
        local player = GLOBAL.ThePlayer
        local frontend = GLOBAL.TheFrontEnd
        if player == nil or not player:IsValid() or frontend == nil then
            return false
        end

        local active_screen = frontend:GetActiveScreen()
        if active_screen == nil or active_screen ~= player.HUD or active_screen.name ~= "HUD" then
            return false
        end
        if IsGuideOpen() or IsSummaryOpen() or player.HHMonarchStorageOpen
            or GLOBAL.TheWorld == nil or not GLOBAL.TheWorld:IsValid()
            or player:HasTag("playerghost") then
            return false
        end

        local health = player.components ~= nil and player.components.health or nil
        if health ~= nil and health:IsDead() then
            return false
        end
        if player.HUD ~= nil and player.HUD.HasInputFocus ~= nil and player.HUD:HasInputFocus() then
            return false
        end

        local controller = player.components ~= nil and player.components.playercontroller or nil
        return controller ~= nil and controller:IsEnabled() == true
    end

    local skill_wheel = nil
    local summon_wheel = nil
    local recall_wheel = nil
    local skill_wheel_handlers_applied = false

    local function CloseWheel(wheel)
        if wheel == nil or not wheel.inst:IsValid() or not wheel:IsOpen() then
            return
        end
        wheel:StopVisualUpdates()
        wheel:Close()
    end

    local function ShowWheel(wheel)
        if wheel == nil or not wheel.inst:IsValid()
            or wheel:IsOpen() or not CanUseSkillWheel() then
            return
        end
        if skill_wheel ~= wheel then
            CloseWheel(skill_wheel)
        end
        if summon_wheel ~= wheel then
            CloseWheel(summon_wheel)
        end
        if recall_wheel ~= wheel then
            CloseWheel(recall_wheel)
        end
        -- PlayerHud:OpenSpellWheel applies this scale under the same
        -- proportional commandwheelroot hierarchy.
        wheel:PrepareToOpen()
        wheel:SetScale(GLOBAL.TheFrontEnd:GetProportionalHUDScale())
        wheel:MoveToFront()
        wheel:Open()
        wheel:StartVisualUpdates()
    end

    local function CloseAllSkillWheels()
        CloseWheel(skill_wheel)
        CloseWheel(summon_wheel)
        CloseWheel(recall_wheel)
    end

    local function GetOpenSkillWheel()
        if summon_wheel ~= nil and summon_wheel.inst:IsValid() and summon_wheel:IsOpen() then
            return summon_wheel
        elseif recall_wheel ~= nil and recall_wheel.inst:IsValid() and recall_wheel:IsOpen() then
            return recall_wheel
        elseif skill_wheel ~= nil and skill_wheel.inst:IsValid() and skill_wheel:IsOpen() then
            return skill_wheel
        end
    end

    OpenShadowSummonWheel = function()
        ShowWheel(summon_wheel)
    end

    OpenShadowRecallWheel = function()
        ShowWheel(recall_wheel)
    end

    local function ToggleSkillWheel()
        if skill_wheel == nil or not skill_wheel.inst:IsValid() then
            return
        end
        local open_wheel = GetOpenSkillWheel()
        if open_wheel ~= nil then
            CloseWheel(open_wheel)
        else
            ShowWheel(skill_wheel)
        end
    end

    local function AddSkillWheel(self)
        if self.hh_skill_wheel ~= nil and self.hh_skill_wheel.inst:IsValid() then
            skill_wheel = self.hh_skill_wheel
            summon_wheel = self.hh_summon_wheel
            recall_wheel = self.hh_recall_wheel
            return
        end

        local CreateHHSkillWheel = GLOBAL.require("widgets/hh_skill_wheel")
        skill_wheel = self.commandwheelroot:AddChild(CreateHHSkillWheel({
            name = "HHSkillWheel",
            owner = self.owner,
            skills = SKILL_DEFS,
        }))
        summon_wheel = self.commandwheelroot:AddChild(CreateHHSkillWheel({
            name = "HHSummonWheel",
            owner = self.owner,
            skills = SUMMON_WHEEL_DEFS,
        }))
        recall_wheel = self.commandwheelroot:AddChild(CreateHHSkillWheel({
            name = "HHRecallWheel",
            owner = self.owner,
            skills = RECALL_WHEEL_DEFS,
        }))
        self.hh_skill_wheel = skill_wheel
        self.hh_summon_wheel = summon_wheel
        self.hh_recall_wheel = recall_wheel
        skill_wheel:Close()
        summon_wheel:Close()
        recall_wheel:Close()

        local hud = self.owner ~= nil and self.owner.HUD or nil
        if hud ~= nil and not hud._hh_skill_wheel_onlosefocus_wrapped then
            local OldOnLoseFocus = hud.OnLoseFocus
            hud.OnLoseFocus = function(hud_self, ...)
                CloseAllSkillWheels()
                return OldOnLoseFocus(hud_self, ...)
            end
            hud._hh_skill_wheel_onlosefocus_wrapped = true
        end

        if not skill_wheel_handlers_applied then
            GLOBAL.TheInput:AddKeyDownHandler(GLOBAL.KEY_V, function()
                if skill_wheel == nil or not skill_wheel.inst:IsValid() then
                    return
                end
                -- Match the vanilla character command wheel control: one
                -- action per physical press, while key release only rearms it.
                if skill_wheel._hh_v_latched then
                    return
                end
                skill_wheel._hh_v_latched = true
                ToggleSkillWheel()
            end)
            GLOBAL.TheInput:AddKeyUpHandler(GLOBAL.KEY_V, function()
                if skill_wheel ~= nil and skill_wheel.inst:IsValid() then
                    skill_wheel._hh_v_latched = false
                end
            end)
            skill_wheel_handlers_applied = true
        end
    end

    AddClassPostConstruct("widgets/controls", AddSkillWheel)
end


local function GetOpenMonarchStorage(player)
    local hh_player = player ~= nil and player.components ~= nil and player.components.hh_player or nil
    local storage = hh_player ~= nil and hh_player.monarch_storage or nil
    local container = storage ~= nil and storage.components ~= nil and storage.components.container or nil
    if container ~= nil and container:IsOpenedBy(player) then
        return container
    end
end

local function CountMonarchIngredient(container, prefab)
    local count = 0
    if container ~= nil then
        for slot = 1, container:GetNumSlots() do
            local item = container:GetItemInSlot(slot)
            if item ~= nil and item.prefab == prefab and item.components.inventoryitem ~= nil
                and not item.components.inventoryitem.islockedinslot and not item:HasTag("nocrafting") then
                count = count + (item.components.stackable ~= nil and item.components.stackable:StackSize() or 1)
            end
        end
    end
    return count
end

local function AddMonarchIngredients(container, prefab, amount, ingredients)
    local remaining = amount
    for _, used in pairs(ingredients) do
        remaining = remaining - used
    end
    if remaining <= 0 or container == nil then
        return
    end
    for slot = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(slot)
        if item ~= nil and item.prefab == prefab and item.components.inventoryitem ~= nil
            and not item.components.inventoryitem.islockedinslot and not item:HasTag("nocrafting") then
            local take = math.min(remaining,
                item.components.stackable ~= nil and item.components.stackable:StackSize() or 1)
            ingredients[item] = take
            remaining = remaining - take
            if remaining <= 0 then
                break
            end
        end
    end
end

AddComponentPostInit("builder", function(self)
    local OldHasIngredients = self.HasIngredients
    local OldGetIngredients = self.GetIngredients
    self.HasIngredients = function(builder, recipe)
        if OldHasIngredients(builder, recipe) then
            return true
        end
        recipe = type(recipe) == "string" and GLOBAL.GetValidRecipe(recipe) or recipe
        local storage = GetOpenMonarchStorage(builder.inst)
        if recipe == nil or storage == nil or builder.freebuildmode
            or recipe.getlimitedrecipecount ~= nil and recipe:getlimitedrecipecount(builder.inst) <= 0 then
            return false
        end
        for _, ingredient in ipairs(recipe.ingredients) do
            local amount = math.max(1, GLOBAL.RoundBiasedUp(ingredient.amount * builder.ingredientmod))
            local _, vanilla_count = builder.inst.components.inventory:Has(ingredient.type, amount, true)
            if vanilla_count + CountMonarchIngredient(storage, ingredient.type) < amount then
                return false
            end
        end
        for _, ingredient in ipairs(recipe.character_ingredients) do
            if not builder:HasCharacterIngredient(ingredient) then
                return false
            end
        end
        for _, ingredient in ipairs(recipe.tech_ingredients) do
            if not builder:HasTechIngredient(ingredient) then
                return false
            end
        end
        return true
    end
    self.GetIngredients = function(builder, recipe_name)
        local ingredients, discounted = OldGetIngredients(builder, recipe_name)
        local recipe = GLOBAL.AllRecipes[recipe_name]
        local storage = GetOpenMonarchStorage(builder.inst)
        if recipe ~= nil and storage ~= nil then
            ingredients = ingredients or {}
            for _, ingredient in pairs(recipe.ingredients) do
                if ingredient.amount > 0 then
                    local amount = math.max(1, GLOBAL.RoundBiasedUp(ingredient.amount * builder.ingredientmod))
                    ingredients[ingredient.type] = ingredients[ingredient.type] or {}
                    AddMonarchIngredients(storage, ingredient.type, amount, ingredients[ingredient.type])
                end
            end
        end
        return ingredients, discounted
    end
end)

AddClassPostConstruct("components/builder_replica", function(self)
    local OldHasIngredients = self.HasIngredients
    self.HasIngredients = function(builder, recipe)
        if OldHasIngredients(builder, recipe) then
            return true
        end
        recipe = type(recipe) == "string" and GLOBAL.GetValidRecipe(recipe) or recipe
        local player = builder.inst
        local storage_replica = nil
        if player ~= nil and player.HUD ~= nil and player.HUD.controls ~= nil then
            for container_inst in pairs(player.HUD.controls.containers) do
                if container_inst.prefab == "hh_monarch_storage_container" then
                    storage_replica = container_inst.replica.container
                    break
                end
            end
        end
        if recipe == nil or storage_replica == nil or builder.classified == nil
            or builder.classified.isfreebuildmode:value()
            or recipe.getlimitedrecipecount ~= nil and recipe:getlimitedrecipecount(player) <= 0 then
            return false
        end
        for _, ingredient in ipairs(recipe.ingredients) do
            local amount = math.max(1, GLOBAL.RoundBiasedUp(ingredient.amount * builder:IngredientMod()))
            local _, vanilla_count = player.replica.inventory:Has(ingredient.type, amount, true)
            local storage_count = 0
            for _, item in pairs(storage_replica:GetItems()) do
                if item ~= nil and item.prefab == ingredient.type and item.replica.inventoryitem ~= nil
                    and not item.replica.inventoryitem:IsLockedInSlot() and not item:HasTag("nocrafting") then
                    storage_count = storage_count + (item.replica.stackable ~= nil and item.replica.stackable:StackSize() or 1)
                end
            end
            if vanilla_count + storage_count < amount then
                return false
            end
        end
        for _, ingredient in ipairs(recipe.character_ingredients) do
            if not builder:HasCharacterIngredient(ingredient) then
                return false
            end
        end
        for _, ingredient in ipairs(recipe.tech_ingredients) do
            if not builder:HasTechIngredient(ingredient) then
                return false
            end
        end
        return true
    end
end)

AddClassPostConstruct("widgets/controls", function(self)
    local HHManaUI = require("widgets/hh_mana_ui")
    self.hh_mana_ui = self.inv:AddChild(HHManaUI(self.owner, self.inv))

    local HHShadowCountUI = require("widgets/hh_shadow_count_ui")
    self.hh_shadow_count_ui = self.inv:AddChild(HHShadowCountUI(self.owner, self.inv))

    local HHShadowUI = require("widgets/hh_shadow_ui")
    self.hh_shadow_ui = self:AddChild(HHShadowUI(self.owner))
    -- 380px inset preserves the current 2560px placement (2560 - 380 =
    -- 2180) while making the HUD responsive at 1920px and narrower.
    self.hh_shadow_ui:SetPosition(-380, 110, 0)
    self.hh_shadow_ui:MoveToBack()
    

end)

-- [ĐĂNG KÝ NỀN ĐẤT CHO HẦM NGỤC LAVA]
if not GLOBAL.WORLD_TILES.SOLO_ARENA_LAVA then
    AddTile(
        "SOLO_ARENA_LAVA", 
        "NOISE",            
        { ground_name = "Lava Arena" },  
        {
            name = "rocky", 
            noise_texture = "levels/textures/lavaarena_floor_noise.tex",
            runsound = "dontstarve/movement/run_dirt",
            walksound = "dontstarve/movement/walk_dirt",
            colors = {
                primary_color =         {0,  0,  0,  25},
                secondary_color =       {0,  20, 33, 0},
                secondary_color_dusk =  {0,  20, 33, 80},
                minimap_color =         {80, 20, 20, 255},
            },
            hard = true,
            cannotbedug = true,
        },
        {
            name = "map_edge",
            noise_texture = "levels/textures/lavaarena_floor_noise.tex",
        }
    )
end



modimport("main/hh_dungeon_shop.lua")
