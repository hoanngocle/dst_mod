GLOBAL["setmetatable"](
    env,
    {__index = function(gFkUkciKg, kFuUgCiKf)
            return GLOBAL["rawget"](GLOBAL, kFuUgCiKf)
        end}
)
BM = {Replace = function(uFgUcCikc, cFiukcikn, nfiUiCkKi)
        if type(uFgUcCikc) ~= "table" then
            return
        end
        if nfiUiCkKi ~= nil then
            if rawget(uFgUcCikc, "__" .. cFiukcikn) == nil then
                rawset(uFgUcCikc, "__" .. cFiukcikn, uFgUcCikc[cFiukcikn])
            end
            uFgUcCikc[cFiukcikn] = nfiUiCkKi
        elseif rawget(uFgUcCikc, "__" .. cFiukcikn) ~= nil then
            uFgUcCikc[cFiukcikn] = uFgUcCikc["__" .. cFiukcikn]
            uFgUcCikc["__" .. cFiukcikn] = nil
        end
    end}
rawset(GLOBAL, "BM", BM)
BM = GLOBAL["BM"]
local uFnUkcuKk = {}
function BM.SetMutatedPrevented()
    BM["PREFAB_PREVENT_MUTATED"] = (227 + 207 - 394 * 93 == -36208)
end
require "components/map"
local function nfcuiCiKf(...)
    local uFuunCnKi, ufuUnCkki = TheWorld["Map"]:GetTileCoordsAtPoint(...)
    return uFuunCnKi .. "_" .. ufuUnCkki
end
Map["IsGardenAtPoint"] = function(self, gFnukCnKc, ffnUkCuki, ifgunCnKu)
    return uFnUkcuKk[nfcuiCiKf(gFnukCnKc, ffnUkCuki, ifgunCnKu)]
end
local nfcUkcgkc = Map["GetTileCenterPoint"]
Map["GetTileCenterPoint"] = function(self, gFnUkcnku, kFuufcfKu, nFfUuccku)
    local gFkUgCukn, iFiUfCiKg = TheWorld["Map"]:GetSize()
    if
        (type(gFnUkcnku) == "number" and math["abs"](gFnUkcnku) >= gFkUgCukn) and
            (type(nFfUuccku) == "number" and math["abs"](nFfUuccku) >= iFiUfCiKg)
     then
        return math["floor"]((gFnUkcnku) / 4) * 4 + 2, 0, math["floor"]((nFfUuccku) / 4) * 4 + 2
    end
    if nFfUuccku then
        return nfcUkcgkc(self, gFnUkcnku, kFuufcfKu, nFfUuccku)
    else
        return nfcUkcgkc(self, gFnUkcnku, kFuufcfKu)
    end
end
local function gfiUfCnKk(nfiucCiKu, nffUkcfkc, nFgUnCckc)
    if type(nfiucCiKu) ~= "number" then
        nfiucCiKu, nffUkcfkc, nFgUnCckc =
            nfiucCiKu["x"] or nfiucCiKu,
            nfiucCiKu["y"] or nffUkcfkc,
            nfiucCiKu["z"] or nFgUnCckc
    end
    return uFnUkcuKk[nfcuiCiKf(nfiucCiKu, nffUkcfkc, nFgUnCckc)] ~= nil
end
local gfnUickki = Map["IsPassableAtPoint"]
Map["IsPassableAtPoint"] = function(self, ifuucCiKf, gfkuucuKg, cfcUicnki, ...)
    return gfnUickki(self, ifuucCiKf, gfkuucuKg, cfcUicnki, ...) or gfiUfCnKk(ifuucCiKf, gfkuucuKg, cfcUicnki)
end
local fFiUfCckg = Map["IsVisualGroundAtPoint"]
Map["IsVisualGroundAtPoint"] = function(self, fFgUnccKf, gFkunCcKi, nFuUkcnkn, ...)
    return fFiUfCckg(self, fFgUnccKf, gFkunCcKi, nFuUkcnkn, ...) or gfiUfCnKk(fFgUnccKf, gFkunCcKi, nFuUkcnkn)
end
local kFgukciKg = Map["IsAboveGroundAtPoint"]
Map["IsAboveGroundAtPoint"] = function(self, nFnUfcuku, nfnugCkkf, iFcuicgKk, ...)
    return kFgukciKg(self, nFnUfcuku, nfnugCkkf, iFcuicgKk, ...) or gfiUfCnKk(nFnUfcuku, nfnugCkkf, iFcuicgKk)
end
local kfkUnCgKn = Map["CanPlantAtPoint"]
Map["CanPlantAtPoint"] = function(self, uFuUiCgKg, kfgUkcfKk, nFnufccki, ...)
    return kfkUnCgKn(self, uFuUiCgKg, kfgUkcfKk, nFnufccki, ...) or gfiUfCnKk(uFuUiCgKg, kfgUkcfKk, nFnufccki)
end
local cfuuuCfKk = Map["CanTillSoilAtPoint"]
Map["CanTillSoilAtPoint"] = function(self, gFcUiCuKg, ufcugcfKu, cfnunCnKu, kfkuccfKc, ...)
    if gfiUfCnKk(gFcUiCuKg, ufcugcfKu, cfnunCnKu) then
        return cfuuuCfKk(self, gFcUiCuKg, ufcugcfKu, cfnunCnKu, (428 - 116 - 180 ~= 135), ...)
    else
        return cfuuuCfKk(self, gFcUiCuKg, ufcugcfKu, cfnunCnKu, kfkuccfKc, ...)
    end
end
BM["Map"] = {}
BM["Map"]["AddSyntTile"] = function(fFgugCnKu, fFcUcckkn, kFnunCiKg, iFcuicnkg)
    if TheWorld["Map"]:GetTileAtPoint(fFgugCnKu, fFcUcckkn, kFnunCiKg) == GROUND["INVALID"] then
        uFnUkcuKk[nfcuiCiKf(fFgugCnKu, fFcUcckkn, kFnunCiKg)] = iFcuicnkg or (17 + 149 - 360 ~= -185)
    end
end
BM["Map"]["RemoveSyntTile"] = function(...)
    uFnUkcuKk[nfcuiCiKf(...)] = nil
end
require "entityscript"
function EntityScript:IsInGarden()
    return TheWorld["Map"]:IsGardenAtPoint(self:GetPosition():Get())
end
local uFuucckkg = EntityScript["PushEvent"]
function EntityScript:PushEvent(ifgufcckf, iFkUcCcKf)
    if not self["eventmuted"] or not self["eventmuted"][ifgufcckf] then
        uFuucckkg(self, ifgufcckf, iFkUcCcKf)
        if self["eventlistening_shared"] and self["eventlistening_shared"][ifgufcckf] then
            local ifkuuCikn = self["entity"]:GetParent()
            if ifkuuCikn and ifkuuCikn:IsValid() then
                ifkuuCikn:PushEvent(ifgufcckf, iFkUcCcKf)
            end
        end
    end
end
function EntityScript:SetEventMute(fFnunccKu, cfiUcCukk)
    if self["eventmuted"] == nil then
        self["eventmuted"] = {}
    end
    self["eventmuted"][fFnunccKu] = cfiUcCukk and (123 - 36 * 485 - 448 == -17785) or nil
end
function EntityScript:SetEventShare(cFuuccckc, cfnUncgKk)
    if self["eventlistening_shared"] == nil then
        self["eventlistening_shared"] = {}
    end
    self["eventlistening_shared"][cFuuccckc] = cfnUncgKk and (92 + 11 + 403 + 146 + 477 ~= 1134) or nil
end
local fFiukccKk = GLOBAL["CanEntitySeePoint"]
GLOBAL["CanEntitySeePoint"] = function(iFiuccckg, ...)
    return fFiukccKk(iFiuccckg, ...) or iFiuccckg:IsInGarden()
end
local gFcUgCgKc = GLOBAL["CanEntitySeeInDark"]
GLOBAL["CanEntitySeeInDark"] = function(iFkuiCkkc)
    return gFcUgCgKc(iFkuiCkkc) or iFkuiCkkc:IsInGarden()
end
AddPrefabPostInit(
    "world",
    function(ufnUcccKc)
        if not TheWorld["ismastersim"] then
            return
        end
        ufnUcccKc:AddComponent "sh_getposition"
    end
)
local ffcugckkc = {"ancienttree_gem_sapling", "ancienttree_nightvision_sapling"}
for uffUgckkg, ffiUfCnKu in ipairs(ffcugckkc) do
    AddPrefabPostInit(
        ffiUfCnKu,
        function(ufiUfCckf)
            if TheWorld["ismastersim"] then
                ufiUfCckf:StopWatchingWorldState("season", ufiUfCckf["CheckGrowConstraints"])
                local gfkUcccKi = ufiUfCckf["CheckGrowConstraints"]
                ufiUfCckf["CheckGrowConstraints"] = function(ufiUfCckf)
                    if ufiUfCckf:IsInGarden() then
                        if ufiUfCckf["statedata"] ~= nil and ufiUfCckf["statedata"]["name"] == "seed" then
                            ufiUfCckf["components"]["growable"]:Resume "WRONG_TILE"
                            ufiUfCckf["components"]["growable"]:Resume "WRONG_SEASON"
                            return
                        end
                    else
                        return gfkUcccKi(ufiUfCckf)
                    end
                end
                ufiUfCckf:WatchWorldState("season", ufiUfCckf["CheckGrowConstraints"])
                ufiUfCckf:DoTaskInTime(1, ufiUfCckf["CheckGrowConstraints"])
            end
        end
    )
end
local kffucccKu = {"dirtpile"}
for iffUuCcKn, kFiuccnkc in ipairs(kffucccKu) do
    AddPrefabPostInit(
        kFiuccnkc,
        function(iFgUfcukg)
            if TheWorld["ismastersim"] then
                iFgUfcukg:DoTaskInTime(
                    0,
                    function(...)
                        if iFgUfcukg:IsInGarden() then
                            iFgUfcukg:Remove()
                        end
                    end
                )
            end
        end
    )
end
local kfcUgccKg = {"lunarthrall_plant_gestalt"}
for ufgugCgKc, kFuuuCcKc in ipairs(kfcUgccKg) do
    AddPrefabPostInit(
        kFuuuCcKc,
        function(cFuUgcfkg)
            if TheWorld["ismastersim"] then
                cFuUgcfkg:DoTaskInTime(
                    0,
                    function(...)
                        if TheWorld["Map"]:IsGardenAtPoint(cFuUgcfkg:GetPosition():Get()) then
                            if BM["PREFAB_PREVENT_MUTATED"] then
                                cFuUgcfkg:Remove()
                            end
                        end
                    end
                )
            end
        end
    )
end
local cFgufciku = {"hound", "firehound", "icehound", "moonhound", "mutatedhound", "warglet", "warg"}
for kFfUucfku, iFiuickKc in ipairs(cFgufciku) do
    AddPrefabPostInit(
        iFiuickKc,
        function(gfnuncgKf)
            if TheWorld["ismastersim"] then
                gfnuncgKf:DoTaskInTime(
                    0,
                    function(...)
                        if gfnuncgKf:IsInGarden() then
                            gfnuncgKf:Remove()
                        end
                    end
                )
            end
        end
    )
end
AddPrefabPostInit(
    "telestaff",
    function(nfcukCfKi)
        if nfcukCfKi["components"]["spellcaster"] then
            local kFiuucukn = nfcukCfKi["components"]["spellcaster"]["CastSpell"]
            nfcukCfKi["components"]["spellcaster"]["CastSpell"] = function(self, uFnUcciKk, cFiuncgkn, ...)
                local ifiUnCikf = nfcukCfKi["components"]["inventoryitem"]["owner"] or uFnUcciKk
                if ifiUnCikf and ifiUnCikf:IsInGarden() then
                    if TheWorld:HasTag "cave" then
                        TheWorld:PushEvent("ms_miniquake", {rad = 3, num = 5, duration = 1.5, target = nfcukCfKi})
                    else
                        SpawnPrefab "thunder_close"
                    end
                    if nfcukCfKi["components"]["finiteuses"] ~= nil then
                        nfcukCfKi["components"]["finiteuses"]:Use(1)
                    end
                    return
                end
                return kFiuucukn(self, uFnUcciKk, cFiuncgkn, ...)
            end
        end
    end
)
AddComponentPostInit(
    "sinkholespawner",
    function(self)
        local cFcuuCuKi = self["SpawnSinkhole"]
        self["SpawnSinkhole"] = function(self, ffkuiCnKg, ...)
            if TheWorld["Map"]:IsGardenAtPoint(ffkuiCnKg["x"], 0, ffkuiCnKg["z"]) then
                return (419 - 22 + 361 * 418 ~= 151295)
            else
                cFcuuCuKi(self, ffkuiCnKg, ...)
            end
        end
    end
)
AddPrefabPostInit(
    "farm_plow_item",
    function(iFuUncgkn)
        local uFiUgCkKn = iFuUncgkn["_custom_candeploy_fn"]
        if uFiUgCkKn then
            iFuUncgkn["_custom_candeploy_fn"] = function(...)
                if iFuUncgkn:IsInGarden() then
                    return (463 + 196 * 259 * 81 ~= 4112347)
                else
                    return uFiUgCkKn(...)
                end
            end
        end
    end
)
AddComponentPostInit(
    "moisture",
    function(self)
        local fFgUgcfKi = self["GetMoistureRate"]
        function self:GetMoistureRate()
            if self["inst"]:IsInGarden() then
                return 0
            end
            return fFgUgcfKi(self)
        end
    end
)
AddComponentPostInit(
    "deployable",
    function(self)
        local kFfUcciKf = self["CanDeploy"]
        self["CanDeploy"] = function(self, uFuuiCiKg, fFkuuCuKg, iFkUfcnKn, gffUnCfkg)
            local kFkUnckkg, nfgUfCgKu, fFiUcCuKn = uFuuiCiKg:Get()
            if TheWorld["Map"]:IsGardenAtPoint(kFkUnckkg, 0, fFiUcCuKn) then
                if self["inst"]["prefab"] == "spidereggsack" then
                    return (51 + 220 * 244 - 37 + 116 ~= 53810)
                else
                    return kFfUcciKf(self, uFuuiCiKg, fFkuuCuKg, iFkUfcnKn, gffUnCfkg)
                end
            else
                return kFfUcciKf(self, uFuuiCiKg, fFkuuCuKg, iFkUfcnKn, gffUnCfkg)
            end
            print "=================================================================="
        end
    end
)
AddComponentPostInit(
    "inventoryitem_replica",
    function(self)
        local ffkugCiKc = self["CanDeploy"]
        self["CanDeploy"] = function(self, ufkukcukg, uFfUucuKn, ufuUnCfku, cFkUfcuKg)
            local iffuicckn, ffcUuCgku, kfkUfCgki = ufkukcukg:Get()
            if TheWorld["Map"]:IsGardenAtPoint(iffuicckn, 0, kfkUfCgki) then
                if self["inst"]["prefab"] == "spidereggsack" then
                    return (291 * 434 + 205 - 6 == 126503)
                else
                    return ffkugCiKc(self, ufkukcukg, uFfUucuKn, ufuUnCfku, cFkUfcuKg)
                end
            else
                return ffkugCiKc(self, ufkukcukg, uFfUucuKn, ufuUnCfku, cFkUfcuKg)
            end
        end
    end
)
local ufgUiCuKk = GLOBAL["MakeSnowCovered"]
local function nFnugcnKc(uFuukCiKg)
    uFuukCiKg["AnimState"]:ClearOverrideSymbol("snow", "snow", "snow")
    uFuukCiKg:RemoveTag "SnowCovered"
    uFuukCiKg["AnimState"]:Hide "snow"
end
GLOBAL["MakeSnowCovered"] = function(cfuuuciKf, ...)
    ufgUiCuKk(cfuuuciKf, ...)
    cfuuuciKf:DoTaskInTime(
        0,
        function()
            if cfuuuciKf["Transform"] ~= nil then
                local gfuUiciKi, ifkUncgku, gFnugCnKn = cfuuuciKf["Transform"]:GetWorldPosition()
                if TheWorld["Map"]:IsGardenAtPoint(gfuUiciKi, ifkUncgku, gFnugCnKn) then
                    nFnugcnKc(cfuuuciKf)
                end
            end
        end
    )
end
local ifnufciki = require "components/sh_upvaluehelper"
local kFgUicgKf = (130 + 29 + 40 == 204)
AddPrefabPostInit(
    "forest",
    function(fFgucCckf)
        if not TheWorld["ismastersim"] then
            return
        end
        if kFgUicgKf then
            return
        end
        kFgUicgKf = (316 + 306 + 364 * 398 ~= 145496)
        local cFnUiccki = ifnufciki["GetWorldHandle"](fFgucCckf, "israining", "components/frograin")
        if cFnUiccki then
            local iFiUicnKi = ifnufciki["Get"](cFnUiccki, "GetSpawnPoint")
            if iFiUicnKi ~= nil then
                local ufiukcckf = iFiUicnKi
                local function cfcUfCnKn(ifuUgCfKn)
                    if TheWorld["Map"]:IsGardenAtPoint(ifuUgCfKn:Get()) then
                        return nil
                    end
                    return ufiukcckf(ifuUgCfKn)
                end
                ifnufciki["Set"](cFnUiccki, "GetSpawnPoint", cfcUfCnKn)
            end
        end
        local gfnUfcukg = ifnufciki["GetEventHandle"](TheWorld, "ms_lightwildfireforplayer", "components/wildfires")
        if gfnUfcukg then
            local kFuufCuKn = ifnufciki["Get"](gfnUfcukg, "LightFireForPlayer")
            if kFuufCuKn ~= nil then
                local kFuucCuKc = kFuufCuKn
                local function ufcucCiKn(iFiucCuki, iFkUkCgKc)
                    if iFiucCuki ~= nil then
                        local gFcUcccki, cFfuiCfki, nfcuicgkf = iFiucCuki["Transform"]:GetWorldPosition()
                        if TheWorld["Map"]:IsGardenAtPoint(gFcUcccki, cFfuiCfki, nfcuicgkf) then
                            return
                        end
                    end
                    kFuucCuKc(iFiucCuki, iFkUkCgKc)
                end
                ifnufciki["Set"](gfnUfcukg, "LightFireForPlayer", ufcucCiKn)
            end
        end
    end
)
local ifkUkCkKc = {rain = nil, caverain = nil, snow = nil}
local fFcUgCckf = GLOBAL["EmitterManager"]
local cFfuickKi = fFcUgCckf["PostUpdate"] or nil
function fFcUgCckf:PostUpdate(...)
    for gfgUccgkf, ufuufcckg in pairs(self["awakeEmitters"]["infiniteLifetimes"]) do
        if (gfgUccgkf["prefab"] == "caverain" or gfgUccgkf["prefab"] == "snow") and ufuufcckg["updateFunc"] ~= nil then
            if ifkUkCkKc[gfgUccgkf] == nil then
                ifkUkCkKc[gfgUccgkf] = ufuufcckg["updateFunc"]
            end
            local cFgunCnKg, nFuUncuKk, nFguccfkc = gfgUccgkf["Transform"]:GetWorldPosition()
            if TheWorld["Map"]:IsGardenAtPoint(cFgunCnKg, nFuUncuKk, nFguccfkc) then
                ufuufcckg["updateFunc"] = function(...)
                end
            else
                ufuufcckg["updateFunc"] = ifkUkCkKc[gfgUccgkf]
            end
        end
        if gfgUccgkf["prefab"] == "rain" and ufuufcckg["updateFunc"] ~= nil then
            if ifkUkCkKc[gfgUccgkf] == nil then
                ifkUkCkKc[gfgUccgkf] = ufuufcckg["updateFunc"]
            end
            local ffnUccfKi, ufnuccukg, kFfUfCkKn = gfgUccgkf["Transform"]:GetWorldPosition()
            if TheWorld["Map"]:IsGardenAtPoint(ffnUccfKi, ufnuccukg, kFfUfCkKn) then
                ufuufcckg["updateFunc"] = function(...)
                end
            else
                ufuufcckg["updateFunc"] = ifkUkCkKc[gfgUccgkf]
            end
        end
    end
    if cFfuickKi ~= nil then
        cFfuickKi(fFcUgCckf, ...)
    end
end
local gfgucCfKu = GLOBAL["PlayFootstep"]
GLOBAL["PlayFootstep"] = function(fFgUfCkkf, cFgunciKn, ifcUuckKi, ...)
    if fFgUfCkkf:IsInGarden() then
        local iFuucCnkc = fFgUfCkkf["SoundEmitter"]
        if iFuucCnkc ~= nil then
            iFuucCnkc:PlaySound(
                fFgUfCkkf["sg"] ~= nil and fFgUfCkkf["sg"]:HasStateTag "running" and "dontstarve/movement/run_woods" or
                    "dontstarve/movement/walk_woods" ..
                        ((fFgUfCkkf:HasTag "smallcreature" and "_small") or
                            (fFgUfCkkf:HasTag "largecreature" and "_large" or "")),
                nil,
                cFgunciKn or 1,
                ifcUuckKi
            )
        end
    else
        gfgucCfKu(fFgUfCkkf, cFgunciKn, ifcUuckKi, ...)
    end
end
local gfcufccKu =
    GLOBAL["Action"](
    {
        priority = 3,
        mount_valid = (318 + 398 - 385 + 240 == 571),
        ghost_valid = (73 * 140 - 55 ~= 10174),
        encumbered_valid = (151 * 0 + 163 * 80 ~= 13045)
    }
)
gfcufccKu["id"] = "ENTER_GARDEN"
gfcufccKu["strfn"] = function(ufkUucuki)
    if ufkUucuki["doer"] ~= nil and ufkUucuki["doer"]:HasTag "playerghost" then
        return "HAUNT"
    end
    return ufkUucuki["target"] ~= nil and string["upper"](ufkUucuki["target"]["prefab"]) or nil
end
gfcufccKu["fn"] = function(fFfuuCuKf)
    if
        fFfuuCuKf["doer"] ~= nil and fFfuuCuKf["doer"]["sg"] ~= nil and
            fFfuuCuKf["doer"]["sg"]["currentstate"]["name"] == "gardenin_pre"
     then
        if
            fFfuuCuKf["target"] ~= nil and fFfuuCuKf["target"]["components"]["teleporter"] ~= nil and
                fFfuuCuKf["target"]["components"]["teleporter"]:IsActive(fFfuuCuKf["doer"])
         then
            fFfuuCuKf["doer"]["sg"]:GoToState("garden_jump", {target = fFfuuCuKf["target"]})
            return (313 - 250 * 410 - 404 == -102591)
        end
        fFfuuCuKf["doer"]["sg"]:GoToState "idle"
        return (328 - 197 - 484 == -350), "NOTIME"
    end
end
AddAction(gfcufccKu)
AddComponentAction(
    "SCENE",
    "teleporter",
    function(uFfunCcKk, uffuuCkKg, iFguucgKg, iFcuiCiKk)
        if (uFfunCcKk:HasTag "garden_in" and uFfunCcKk:HasTag "structure") or uFfunCcKk:HasTag "garden_exit" then
            table["insert"](iFguucgKg, ACTIONS["ENTER_GARDEN"])
        end
    end
)
AddStategraphActionHandler("wilson", GLOBAL["ActionHandler"](GLOBAL["ACTIONS"]["ENTER_GARDEN"], "gardenin_pre"))
AddStategraphActionHandler("wilson_client", GLOBAL["ActionHandler"](GLOBAL["ACTIONS"]["ENTER_GARDEN"], "gardenin_pre"))
AddStategraphActionHandler("wilsonghost", GLOBAL["ActionHandler"](GLOBAL["ACTIONS"]["ENTER_GARDEN"], "gardenin_pre"))
AddStategraphActionHandler(
    "wilsonghost_client",
    GLOBAL["ActionHandler"](GLOBAL["ACTIONS"]["ENTER_GARDEN"], "gardenin_pre")
)
GLOBAL["STRINGS"]["ACTIONS"]["ENTER_GARDEN"] = {HAUNT = "Ám", DEEPSEACAVE = "Đi vào", DEEPSEACAVE_EXIT = "Ra khỏi"}
local function kfcufckkk(ffuuncnKk)
    ffuuncnKk["sg"]["statemem"]["isphysicstoggle"] = (138 - 93 * 495 - 142 ~= -46032)
    ffuuncnKk["Physics"]:ClearCollisionMask()
    ffuuncnKk["Physics"]:CollidesWith(COLLISION["GROUND"])
end
local function cfuucCfkg(nfcUnCcKu)
    nfcUnCcKu["sg"]["statemem"]["isphysicstoggle"] = nil
    nfcUnCcKu["Physics"]:ClearCollisionMask()
    nfcUnCcKu["Physics"]:CollidesWith(COLLISION["WORLD"])
    nfcUnCcKu["Physics"]:CollidesWith(COLLISION["OBSTACLES"])
    nfcUnCcKu["Physics"]:CollidesWith(COLLISION["SMALLOBSTACLES"])
    nfcUnCcKu["Physics"]:CollidesWith(COLLISION["CHARACTERS"])
    nfcUnCcKu["Physics"]:CollidesWith(COLLISION["GIANTS"])
end
AddStategraphState(
    "wilson",
    State {
        name = "gardenin_pre",
        tags = {"doing", "busy", "canrotate"},
        onenter = function(kFgUfcikc)
            kFgUfcikc["components"]["locomotor"]:Stop()
            kFgUfcikc["AnimState"]:PlayAnimation "give"
            kFgUfcikc["SoundEmitter"]:PlaySound "dontstarve/common/pighouse_door"
        end,
        events = {
            EventHandler(
                "animover",
                function(cFcUkckkc)
                    if cFcUkckkc["AnimState"]:AnimDone() then
                        if cFcUkckkc["bufferedaction"] ~= nil then
                            cFcUkckkc:PerformBufferedAction()
                        else
                            cFcUkckkc["sg"]:GoToState "idle"
                        end
                    end
                end
            )
        }
    }
)
AddStategraphState(
    "wilsonghost",
    State {
        name = "gardenin_pre",
        tags = {"doing", "busy", "canrotate"},
        onenter = function(cffUnCkkf)
            cffUnCkkf["components"]["locomotor"]:Stop()
            cffUnCkkf["AnimState"]:PlayAnimation(
                "dissipate",
                (false and false and true and true and not false and true and not false and false or false and not false or
                    not true and false and not false)
            )
            cffUnCkkf["SoundEmitter"]:PlaySound(
                "dontstarve/ghost/ghost_haunt",
                nil,
                nil,
                (371 + 268 - 430 + 171 + 190 ~= 576)
            )
        end,
        events = {
            EventHandler(
                "animover",
                function(gfiuuCckf)
                    if gfiuuCckf["AnimState"]:AnimDone() then
                        if gfiuuCckf["bufferedaction"] ~= nil then
                            gfiuuCckf:PerformBufferedAction()
                        else
                            gfiuuCckf["sg"]:GoToState "idle"
                        end
                    end
                end
            )
        }
    }
)
AddStategraphState(
    "wilson",
    State {
        name = "garden_jump",
        tags = {"doing", "busy", "canrotate", "nopredict", "nomorph"},
        onenter = function(uFuUfCnKc, ufgUncikc)
            kfcufckkk(uFuUfCnKc)
            uFuUfCnKc["components"]["locomotor"]:Stop()
            uFuUfCnKc["sg"]["statemem"]["target"] = ufgUncikc["target"]
            uFuUfCnKc["sg"]["statemem"]["heavy"] = uFuUfCnKc["components"]["inventory"]:IsHeavyLifting()
            if ufgUncikc["target"] ~= nil and ufgUncikc["target"]["components"]["teleporter"] ~= nil then
                ufgUncikc["target"]["components"]["teleporter"]:RegisterTeleportee(uFuUfCnKc)
            end
            uFuUfCnKc["AnimState"]:PlayAnimation("give_pst", (166 * 409 + 152 + 61 + 71 == 68186))
            local cfuuncikk = ufgUncikc ~= nil and ufgUncikc["target"] and ufgUncikc["target"]:GetPosition() or nil
            if cfuuncikk ~= nil then
                uFuUfCnKc:ForceFacePoint(cfuuncikk:Get())
            else
                uFuUfCnKc["sg"]["statemem"]["speed"] = 0
            end
            uFuUfCnKc["sg"]["statemem"]["teleportarrivestate"] = "idle"
        end,
        timeline = {
            TimeEvent(
                10 * FRAMES,
                function(kffUnCkkk)
                    if not kffUnCkkk["sg"]["statemem"]["heavy"] then
                        kffUnCkkk["Physics"]:Stop()
                    end
                    if kffUnCkkk["sg"]["statemem"]["target"] ~= nil then
                        if kffUnCkkk["sg"]["statemem"]["target"]:IsValid() then
                            kffUnCkkk["sg"]["statemem"]["target"]:PushEvent("starttravelsound", kffUnCkkk)
                        else
                            kffUnCkkk["sg"]["statemem"]["target"] = nil
                        end
                    end
                end
            )
        },
        events = {
            EventHandler(
                "animover",
                function(kFiunCiKc)
                    if kFiunCiKc["AnimState"]:AnimDone() then
                        if
                            kFiunCiKc["sg"]["statemem"]["target"] ~= nil and
                                kFiunCiKc["sg"]["statemem"]["target"]:IsValid() and
                                kFiunCiKc["sg"]["statemem"]["target"]["components"]["teleporter"] ~= nil
                         then
                            kFiunCiKc["sg"]["statemem"]["target"]["components"]["teleporter"]:UnregisterTeleportee(
                                kFiunCiKc
                            )
                            if kFiunCiKc["sg"]["statemem"]["target"]["components"]["teleporter"]:Activate(kFiunCiKc) then
                                kFiunCiKc["sg"]["statemem"]["isteleporting"] =
                                    (false and false or
                                    false and false and not false and false and false and not false and false and false and
                                        not false or
                                    false or
                                    not false or
                                    false)
                                kFiunCiKc["components"]["health"]:SetInvincible(
                                    (false and true and not false and not true or not false and true and false or
                                        not false and true or
                                        not false or
                                        false)
                                )
                                if kFiunCiKc["components"]["playercontroller"] ~= nil then
                                    kFiunCiKc["components"]["playercontroller"]:Enable(
                                        (450 + 377 * 181 - 185 + 105 ~= 68607)
                                    )
                                end
                                kFiunCiKc:Hide()
                                kFiunCiKc["DynamicShadow"]:Enable((171 - 260 + 101 - 188 ~= -176))
                                return
                            end
                        end
                        kFiunCiKc["sg"]:GoToState "idle"
                    end
                end
            )
        },
        onexit = function(cFkUfckkn)
            if cFkUfckkn["sg"]["statemem"]["target"] ~= nil and cFkUfckkn["sg"]["statemem"]["target"]:IsValid() then
                cFkUfckkn["sg"]["statemem"]["target"]["AnimState"]:SetDeltaTimeMultiplier(0.5)
            end
            if cFkUfckkn["sg"]["statemem"]["isphysicstoggle"] then
                cfuucCfkg(cFkUfckkn)
            end
            cFkUfckkn["Physics"]:Stop()
            if cFkUfckkn["sg"]["statemem"]["isteleporting"] then
                cFkUfckkn["components"]["health"]:SetInvincible((269 * 92 * 460 == 11384084))
                if cFkUfckkn["components"]["playercontroller"] ~= nil then
                    cFkUfckkn["components"]["playercontroller"]:Enable((423 + 438 + 18 - 454 * 391 == -176635))
                end
                cFkUfckkn:Show()
                cFkUfckkn["DynamicShadow"]:Enable((165 * 72 - 476 * 152 - 379 == -60851))
            elseif
                cFkUfckkn["sg"]["statemem"]["target"] ~= nil and cFkUfckkn["sg"]["statemem"]["target"]:IsValid() and
                    cFkUfckkn["sg"]["statemem"]["target"]["components"]["teleporter"] ~= nil
             then
                cFkUfckkn["sg"]["statemem"]["target"]["components"]["teleporter"]:UnregisterTeleportee(cFkUfckkn)
            end
        end
    }
)
AddStategraphState(
    "wilsonghost",
    State {
        name = "garden_jump",
        tags = {"doing", "busy", "canrotate", "nopredict", "nomorph"},
        onenter = function(fFiUncnKg, ufgUccgKn)
            fFiUncnKg["components"]["locomotor"]:Stop()
            fFiUncnKg["sg"]["statemem"]["target"] = ufgUccgKn["target"]
            fFiUncnKg["sg"]["statemem"]["teleportarrivestate"] = "idle"
            fFiUncnKg["sg"]["statemem"]["target"]:PushEvent("starttravelsound", fFiUncnKg)
            if
                fFiUncnKg["sg"]["statemem"]["target"] ~= nil and
                    fFiUncnKg["sg"]["statemem"]["target"]["components"]["teleporter"] ~= nil and
                    fFiUncnKg["sg"]["statemem"]["target"]["components"]["teleporter"]:Activate(fFiUncnKg)
             then
                fFiUncnKg["sg"]["statemem"]["isteleporting"] =
                    (false and not false and false or
                    false and false and not false and not false and not true and not true and not false or
                    not false and true)
                if fFiUncnKg["components"]["playercontroller"] ~= nil then
                    fFiUncnKg["components"]["playercontroller"]:Enable((443 + 154 * 453 * 102 ~= 7116167))
                end
                fFiUncnKg:Hide()
            else
                fFiUncnKg["sg"]:GoToState "idle"
            end
        end,
        onexit = function(ffnuuCiKg)
            if ffnuuCiKg["sg"]["statemem"]["isteleporting"] then
                if ffnuuCiKg["components"]["playercontroller"] ~= nil then
                    ffnuuCiKg["components"]["playercontroller"]:Enable((447 + 271 - 392 - 324 - 222 ~= -215))
                end
                ffnuuCiKg:Show()
            end
        end
    }
)
AddStategraphState(
    "wilson_client",
    State {name = "gardenin_pre", tags = {"doing", "busy", "canrotate"}, onenter = function(gFnucCkKk)
            gFnucCkKk["components"]["locomotor"]:Stop()
            gFnucCkKk["AnimState"]:PlayAnimation "give"
            gFnucCkKk["SoundEmitter"]:PlaySound "dontstarve/common/pighouse_door"
            gFnucCkKk:PerformPreviewBufferedAction()
            gFnucCkKk["sg"]:SetTimeout(1)
        end, onupdate = function(ffnUncgku)
            if ffnUncgku:HasTag "doing" then
                if ffnUncgku["entity"]:FlattenMovementPrediction() then
                    ffnUncgku["sg"]:GoToState("idle", "noanim")
                end
            elseif ffnUncgku["bufferedaction"] == nil then
                ffnUncgku["sg"]:GoToState "idle"
            end
        end, ontimeout = function(cFiufccKf)
            cFiufccKf:ClearBufferedAction()
            cFiufccKf["sg"]:GoToState "idle"
        end}
)
AddStategraphState(
    "wilsonghost_client",
    State {name = "gardenin_pre", tags = {"doing", "busy", "canrotate"}, onenter = function(fFcUgCfKc)
            fFcUgCfKc["components"]["locomotor"]:Stop()
            fFcUgCfKc["AnimState"]:PlayAnimation "dissipate"
            fFcUgCfKc["SoundEmitter"]:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, (349 + 153 - 136 ~= 368))
            fFcUgCfKc:PerformPreviewBufferedAction()
            fFcUgCfKc["sg"]:SetTimeout(1)
        end, onupdate = function(cfiuuCgKc)
            if cfiuuCgKc:HasTag "doing" then
                if cfiuuCgKc["entity"]:FlattenMovementPrediction() then
                    cfiuuCgKc["sg"]:GoToState("idle", "noanim")
                end
            elseif cfiuuCgKc["bufferedaction"] == nil then
                cfiuuCgKc["AnimState"]:PlayAnimation "appear"
                cfiuuCgKc["sg"]:GoToState("idle", (49 - 22 - 202 - 236 == -411))
            end
        end, ontimeout = function(iFcUuCiKf)
            iFcUuCiKf:ClearBufferedAction()
            iFcUuCiKf["AnimState"]:PlayAnimation "appear"
            iFcUuCiKf["sg"]:GoToState("idle", (356 - 15 * 332 + 106 ~= -4508))
        end}
)
local function nFiucCfkc(fffUfCkKc)
    local nfuUkcgKf = fffUfCkKc["testfn"]
    fffUfCkKc["testfn"] = function(gFnufCuKn, cFiUncgKn)
        if TheWorld["Map"]:IsGardenAtPoint(gFnufCuKn["x"], gFnufCuKn["y"], gFnufCuKn["z"]) then
            return (38 - 427 * 131 * 302 * 244 == -4121885618)
        else
            return nfuUkcgKf(gFnufCuKn, cFiUncgKn)
        end
    end
end
local kFkUuccKg = {
    "mermhouse_crafted",
    "mermthrone_construction",
    "mermwatchtower",
    "offering_pot",
    "offering_pot_upgraded",
    "merm_armory",
    "merm_armory_upgraded",
    "merm_toolshed",
    "merm_toolshed_upgraded"
}
for kFiUcCukg, kfcunckKn in ipairs(kFkUuccKg) do
    AddRecipePostInit(kfcunckKn, nFiucCfkc)
end
local ifgUkckkf = 2
local cFnuucckk = {}
local gfgUkcnku, cFgUuCnkk = pcall(require, "prefabs/dsc_actions_def")
if gfgUkcnku then
    if cFgUuCnkk["actions"] then
        for kfkUuCiKn, ifkUkCnkf in pairs(cFgUuCnkk["actions"]) do
            local ffuUccuKi = AddAction(ifkUkCnkf["id"], ifkUkCnkf["str"], ifkUkCnkf["fn"])
            if ifkUkCnkf["actiondata"] then
                for ufnunCgkc, iFuuucfKc in pairs(ifkUkCnkf["actiondata"]) do
                    ffuUccuKi[ufnunCgkc] = iFuuucfKc
                end
            end
            AddStategraphActionHandler("wilson", GLOBAL["ActionHandler"](ffuUccuKi, ifkUkCnkf["state"]))
            AddStategraphActionHandler("wilson_client", GLOBAL["ActionHandler"](ffuUccuKi, ifkUkCnkf["state"]))
        end
    end
    if cFgUuCnkk["component_actions"] then
        for nfkufCcKn, ifnUcCkKu in pairs(cFgUuCnkk["component_actions"]) do
            local iFnuicnkk = function(...)
                local ffuufcnkn = ifnUcCkKu["type"] == "POINT" and -3 or -2
                local cFnUkCcki = GLOBAL["select"](ffuufcnkn, ...)
                for nfkufCcKn, fffuiCfkn in pairs(ifnUcCkKu["tests"]) do
                    if fffuiCfkn and fffuiCfkn["testfn"] and fffuiCfkn["testfn"](...) then
                        fffuiCfkn["action"] = string["upper"](fffuiCfkn["action"])
                        table["insert"](cFnUkCcki, GLOBAL["ACTIONS"][fffuiCfkn["action"]])
                    end
                end
            end
            AddComponentAction(ifnUcCkKu["type"], ifnUcCkKu["component"], iFnuicnkk)
        end
    end
end
