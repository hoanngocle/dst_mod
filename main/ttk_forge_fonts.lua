-- Noto Serif Medium (OFL), compiled by tools/build_forge_font.py.
-- The alias is deliberately published only after TheSim accepts the archive;
-- widgets then fall back to BODYTEXTFONT instead of rendering white blocks.
local G = GLOBAL
G.TTK_FORGE_SERIF = nil
if G.TheNet:IsDedicated() then return end
local alias = "ttk_forge_serif"
local filename = MODROOT .. "fonts/ttk_forge_serif.zip"
Assets = Assets or {}
table.insert(Assets, Asset("FONT", "fonts/ttk_forge_serif.zip"))

AddSimPostInit(function()
    local sim = G.TheSim
    if sim == nil or type(sim.LoadFont) ~= "function" then return false end
    local loaded = pcall(function()
        sim:LoadFont(filename, alias)
    end)
    G.TTK_FORGE_SERIF = loaded and alias or nil
    return loaded
end)
