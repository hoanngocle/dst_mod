local Theme = {
    design = { width = 1536, height = 1024 },
    safe_margin = 32,
    shell = { width = 1408, height = 900 },
    content = { width = 1280, height = 680, y = -42 },
    colours = {
        backdrop = { .018, .016, .035, .985 },
        panel = { .055, .050, .085, .98 },
        silver = { .76, .79, .88, 1 },
        silver_dim = { .30, .32, .40, 1 },
        purple = { .61, .40, .92, 1 },
        purple_soft = { .78, .66, .98, 1 },
        text = { .91, .92, .98, 1 },
        muted = { .62, .64, .72, 1 },
        locked = { .42, .42, .50, 1 },
        cyan = { .38, .75, .98, 1 },
        orange = { 1, .62, .26, 1 },
        line = { .31, .55, .72, .8 },
    },
}

function Theme.GetFont()
    return TTK_FORGE_SERIF or BODYTEXTFONT or UIFONT
end

function Theme.GetSurfaceScale(kind)
    return kind == "forge" and .7 or 1
end

function Theme.GetFitScale(width, height)
    local safe_width = math.max(1, width - Theme.safe_margin * 2)
    local safe_height = math.max(1, height - Theme.safe_margin * 2)
    return math.min(safe_width / Theme.design.width, safe_height / Theme.design.height, 1)
end

return Theme
