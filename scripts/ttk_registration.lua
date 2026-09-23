local defs = require("ttk_defs")

local function SetStrings(G)
    local names = G.STRINGS.NAMES
    local recipe_desc = G.STRINGS.RECIPE_DESC
    local describe = G.STRINGS.CHARACTERS.GENERIC.DESCRIBE

    names.TTK_HHLMZ = "Hoàng Hoa Lê Mộc Trác"
    recipe_desc.TTK_HHLMZ = "Bàn trưng món ăn và hồi độ tươi."
    describe.TTK_HHLMZ = "Một chiếc bàn dành cho linh thực."

    for tier = 1, 4 do
        local key = "TTK_LINGSHI" .. tier
        names[key] = defs.tier_names[tier]
        recipe_desc[key] = tier == 1 and "Linh thạch nhận được khi hạ quái." or "Tinh luyện linh thạch lên phẩm cấp cao hơn."
        describe[key] = "Linh khí cô đọng trong đá."
    end
end

local function RegisterAtlases(env)
    env.RegisterInventoryItemAtlas("images/inventoryimages/ttk_hhlmz.xml", "ttk_hhlmz.tex")
    for tier = 1, 4 do
        local name = "ttk_lingshi" .. tier
        env.RegisterInventoryItemAtlas("images/inventoryimages/" .. name .. ".xml", name .. ".tex")
    end
    env.AddMinimapAtlas("images/map_icons/ttk_hhlmz.xml")
end

local function RegisterContainer(G)
    local containers = require("containers")
    local p = {
        widget = {
            slotpos = {},
            animbank = "ui_backpack_2x4",
            animbuild = "ui_backpack_2x4",
            pos = G.Vector3(275, 0, 0),
            side_align_tip = 100,
        },
        type = "chest",
    }

    for y = 0, 3 do
        table.insert(p.widget.slotpos, G.Vector3(-162, -75 * y + 114, 0))
        table.insert(p.widget.slotpos, G.Vector3(-87, -75 * y + 114, 0))
    end

    p.itemtestfn = function(container, item)
        return item ~= nil
            and item:HasTag("preparedfood")
            and not container.inst:HasTag("burnt")
    end

    containers.params.ttk_hhlmz = p
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS or 0, 8)
end

local function RegisterRecipes(env, G)
    for tier = 2, 4 do
        local name = "ttk_lingshi" .. tier
        env.AddRecipe2(
            name,
            { G.Ingredient("ttk_lingshi" .. (tier - 1), defs.conversion_cost[tier]) },
            G.TECH.SCIENCE_ONE,
            {
                atlas = "images/inventoryimages/" .. name .. ".xml",
                image = name .. ".tex",
                numtogive = 1,
            },
            { "REFINE" }
        )
    end

    env.AddRecipe2(
        "ttk_hhlmz",
        {
            G.Ingredient("livinglog", 3),
            G.Ingredient("boards", 5),
            G.Ingredient("ttk_lingshi1", 10),
        },
        G.TECH.SCIENCE_ONE,
        {
            atlas = "images/inventoryimages/ttk_hhlmz.xml",
            image = "ttk_hhlmz.tex",
            placer = "ttk_hhlmz_placer",
            min_spacing = 4,
        },
        { "STRUCTURES", "DECOR", "COOKING" }
    )
end

return function(env)
    local G = env.GLOBAL
    SetStrings(G)
    RegisterAtlases(env)
    RegisterContainer(G)
    RegisterRecipes(env, G)
end
