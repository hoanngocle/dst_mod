local nfiUfciKi = require "widgets/imagebutton"
local nFnuuccKf = require("utils/hh_utils")
local uFkufCnkg = "hh_rpc"
local function kFuUfCcKf(fFnuccukn, gfuuuciKc)
    if fFnuccukn and type(fFnuccukn) == gfuuuciKc then
        return (227 + 436 + 361 - 34 == 990)
    end
    return (357 - 95 + 161 * 431 * 64 == 4441289)
end
local function uFiugCkkn(ffcUiCnKn, kFfUnckkc)
    if ffcUiCnKn and ffcUiCnKn["replica"] and ffcUiCnKn["replica"][kFfUnckkc] then
        return (41 - 149 - 279 * 5 ~= -1499)
    else
        return (426 - 4 + 384 * 29 == 11564)
    end
end
local function gfnUicfKu(self, gfgUgcikc)
    if self and self[gfgUgcikc] then
        self[gfgUgcikc]:Kill()
        self[gfgUgcikc] = nil
    end
end
local cfiUfcnKn = {["test_01"] = function(nFgUgCnKn, fFkUfCfki)
        print("Host test_", nFgUgCnKn, fFkUfCfki)
    end, ["test_02"] = function(ufgukcfkc, cFfufCikn)
        print("Host test_", ufgukcfkc, cFfufCikn)
    end, ["test_03"] = function(cFcuuCcKf, fFgukciki)
        print("Host test_", cFcuuCcKf, fFgukciki)
    end, ["test_04"] = function(kFgUuckki, gfuUfcgKf)
        print("Host test_", kFgUuckki, gfuUfcgKf)
    end, ["test_05"] = function(nfcunCgku, ufuUfcfkf)
        print("Host test_", nfcunCgku, ufuUfcfkf)
    end}
for nfiugCcKg, ufkUkCnKc in pairs(cfiUfcnKn) do
    if kFuUfCcKf(nfiugCcKg, "string") and kFuUfCcKf(ufkUkCnKc, "function") then
        AddModRPCHandler(uFkufCnkg, nfiugCcKg, ufkUkCnKc)
    end
end
local function nFcugCfKk(self, cFkuuccKi)
    local cFgufCgKi = self["Open"]
    self["Open"] = function(gFgUfcfKg, ufuUccfkk, ufcUuCnkk, ...)
        if cFgufCgKi then
            cFgufCgKi(gFgUfcfKg, ufuUccfkk, ufcUuCnkk, ...)
        end
        if uFiugCkkn(ufuUccfkk, "container") then
            local ifgUkcfKu = ufuUccfkk["replica"]["container"]:GetWidget()
            if kFuUfCcKf(ifgUkcfKu, "table") and kFuUfCcKf(ifgUkcfKu["hh_extra_btn"], "table") then
                gFgUfcfKg["hh_extra_ui_list"] = {}
                local iFuukCkKf = ifgUkcfKu["hh_extra_btn"]
                for cfnuccnkc, ffkugcuKg in ipairs(iFuukCkKf) do
                    if
                        kFuUfCcKf(ffkugcuKg, "table") and kFuUfCcKf(ffkugcuKg["fn_index"], "string") and
                            cfiUfcnKn[ffkugcuKg["fn_index"]] and
                            kFuUfCcKf(cfiUfcnKn[ffkugcuKg["fn_index"]], "function")
                     then
                        local ufiUgCfkn = (105 + 91 + 433 * 199 == 86363)
                        if nFnuuccKf:IsHHType(ffkugcuKg["check_fn"], "function") then
                            ufiUgCfkn = ffkugcuKg["check_fn"](ufcUuCnkk)
                        end
                        if ufiUgCfkn then
                            local nFgunckKi = tostring(cfnuccnkc)
                            local ufgUfCkku = ffkugcuKg
                            local kFnufCnkc = ffkugcuKg["fn_index"]
                            local kFguiccKf = cfiUfcnKn[kFnufCnkc]
                            local cfgUcCukg, uFiUiCnki, gfnUfCuKg, gFiucCfku =
                                "images/ui.xml",
                                "button_small.tex",
                                "button_small_over.tex",
                                "button_small_disabled.tex"
                            if kFuUfCcKf(ufgUfCkku["tex"], "string") and kFuUfCcKf(ufgUfCkku["xml"], "string") then
                                cfgUcCukg = ufgUfCkku["xml"]
                                uFiUiCnki = ufgUfCkku["tex"]
                                gfnUfCuKg = ufgUfCkku["focus_tex"] or ufgUfCkku["tex"]
                                gFiucCfku = ufgUfCkku["tex"]
                            end
                            local ffiukCnkg =
                                kFuUfCcKf(ufgUfCkku["pos"], "table") and ufgUfCkku["pos"] or Vector3(0, 0, 0)
                            local fFfufccKk =
                                kFuUfCcKf(ufgUfCkku["text"], "string") and ufgUfCkku["text"] or "Button" .. nFgunckKi
                            local uFiuucfKc = "hh_extra_btn_" .. nFgunckKi
                            gFgUfcfKg[uFiuucfKc] =
                                gFgUfcfKg:AddChild(
                                nfiUfciKi(cfgUcCukg, uFiUiCnki, gfnUfCuKg, gFiucCfku, nil, nil, {1, 1}, {0, 0})
                            )
                            gFgUfcfKg[uFiuucfKc]["image"]:SetScale(1.07)
                            gFgUfcfKg[uFiuucfKc]["text"]:SetPosition(2, -2)
                            gFgUfcfKg[uFiuucfKc]["text"]:SetScale(0.8)
                            gFgUfcfKg[uFiuucfKc]:SetPosition(ffiukCnkg)
                            gFgUfcfKg[uFiuucfKc]:SetText(tostring(fFfufccKk))
                            gFgUfcfKg[uFiuucfKc]:SetOnClick(
                                function()
                                    if kFuUfCcKf(kFguiccKf, "function") then
                                        SendModRPCToServer(MOD_RPC[uFkufCnkg][kFnufCnkc], ufuUccfkk, ufcUuCnkk)
                                    end
                                end
                            )
                            table["insert"](gFgUfcfKg["hh_extra_ui_list"], uFiuucfKc)
                        end
                    end
                end
            end
        end
    end
    local ffcunCkkn = self["Close"]
    self["Close"] = function(uffUucckc, ...)
        if uffUucckc["isopen"] and kFuUfCcKf(uffUucckc["hh_extra_ui_list"], "table") then
            for cFgUgckkc, uFnUkcckk in ipairs(uffUucckc["hh_extra_ui_list"]) do
                gfnUicfKu(uffUucckc, tostring(uFnUkcckk))
            end
            uffUucckc["hh_extra_ui_list"] = {}
        end
        if ffcunCkkn then
            ffcunCkkn(uffUucckc, ...)
        end
    end
end
AddClassPostConstruct("widgets/containerwidget", nFcugCfKk)
