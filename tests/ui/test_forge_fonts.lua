local callbacks = {}
local load_calls = {}
local fallback_calls = {}

GLOBAL = {
    TheNet = { IsDedicated = function() return false end },
    TheSim = {
        LoadFont = function(_, filename, alias)
            table.insert(load_calls, { filename = filename, alias = alias })
        end,
        SetupFontFallbacks = function(_, alias, fallbacks)
            table.insert(fallback_calls, { alias = alias, fallbacks = fallbacks })
        end,
    },
    DEFAULT_FALLBACK_TABLE = { "fallback_font" },
    FONTS = {},
}
MODROOT = "../mods/PhamNhanTuTien/"
Assets = {}
Asset = function(kind, file) return { type = kind, file = file } end
AddSimPostInit = function(fn) table.insert(callbacks, fn) end

assert(loadfile(__font_loader_path))()

assert(#Assets == 1 and Assets[1].type == "FONT"
    and Assets[1].file == "fonts/ttk_forge_serif.zip",
    "forge serif archive is registered as a mod font asset")
assert(#load_calls == 0, "native font loading waits until registered mod assets are loaded")
assert(#callbacks == 1, "forge serif installs one post-load callback")
assert(GLOBAL.TTK_FORGE_SERIF == nil, "UI cannot select the alias before native loading succeeds")

callbacks[1]()

assert(#load_calls == 1
    and load_calls[1].filename == "../mods/PhamNhanTuTien/fonts/ttk_forge_serif.zip"
    and load_calls[1].alias == "ttk_forge_serif",
    "post-load callback loads the compiled source font under the UI alias")
assert(#fallback_calls == 0, "loading the forge UI registers exactly one font without extra fallback fonts")
assert(GLOBAL.TTK_FORGE_SERIF == "ttk_forge_serif",
    "UI code receives the alias that was loaded")

local failed_callbacks = {}
local failed_fallback_calls = 0
GLOBAL.TTK_FORGE_SERIF = nil
GLOBAL.TheSim = {
    LoadFont = function() error("font archive unavailable") end,
    SetupFontFallbacks = function() failed_fallback_calls = failed_fallback_calls + 1 end,
}
Assets = {}
AddSimPostInit = function(fn) table.insert(failed_callbacks, fn) end

assert(loadfile(__font_loader_path))()
assert(#failed_callbacks == 1, "failed-load scenario still installs its post-load callback")
assert(pcall(failed_callbacks[1]), "font load failure is contained instead of crashing the client")
assert(GLOBAL.TTK_FORGE_SERIF == nil,
    "failed native loading leaves the custom alias disabled for BODYTEXTFONT/UIFONT fallback")
assert(failed_fallback_calls == 0, "fallback chains are not configured for an unloaded alias")

local dedicated_declared = {}
GLOBAL = {
    TheNet = { IsDedicated = function() return true end },
}
setmetatable(GLOBAL, {
    __newindex = function(table_value, key, value)
        dedicated_declared[key] = true
        rawset(table_value, key, value)
    end,
    __index = function(table_value, key)
        if not dedicated_declared[key] then
            error("variable '" .. key .. "' is not declared")
        end
        return rawget(table_value, key)
    end,
})
Assets = {}
callbacks = {}
AddSimPostInit = function(fn) table.insert(callbacks, fn) end

assert(loadfile(__font_loader_path))()
local dedicated_readable, dedicated_font = pcall(function()
    return GLOBAL.TTK_FORGE_SERIF
end)
assert(dedicated_readable and dedicated_font == nil,
    "dedicated servers declare the disabled font alias so strict UI fallback reads are safe")
assert(#Assets == 0, "dedicated servers do not register the client font asset")
assert(#callbacks == 0, "dedicated servers do not install the client font callback")

BODYTEXTFONT = "font_viethoa"
UIFONT = "ui"
TTK_FORGE_SERIF = nil
package.loaded["widgets/hh_ui/ttk_unified_theme"] = nil
local Theme = require("widgets/hh_ui/ttk_unified_theme")
assert(Theme.GetFont() == "font_viethoa", "widgets resolve the Vietnamese font at construction time")
TTK_FORGE_SERIF = "ttk_forge_serif"
assert(Theme.GetFont() == "ttk_forge_serif", "widgets observe the custom alias after SimPostInit")

print("Forge font lifecycle checks PASS")
