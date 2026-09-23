-- Recipe ownership belongs to the catalog; aliases preserve all existing open
-- recipes and use the already-ported Pham Nhan implementation, never source mods.
local Catalog = require("achievement/ttk_perk_catalog")
local M = {}
local registered = {}
local aliases = {
    xd_luoshen_huazhong = "ttk_luoshen_huazhong",
    xd_yunxiao_fysz = "thanhiquangtruong",
    xd_yunxiao_ymsz = "ttk_yunxiao_ymsz",
    xd_yunxiao_portable_spicer = "ttk_yunxiao_portable_spicer",
    xd_sj_kls = "ttk_sj_kls",
    xd_sudaji_redlantern = "ttk_ngulongdang",
    xd_sudaji_ywfh = "nhatvuphuonghoa",
    xd_qwsk = "ttk_qwsk",
}
local techs = {
    ancient_builder = { ANCIENT=true }, lunar_knight = { CELESTIAL=true },
    pearl_bff = { HERMITCRABSHOP=true }, benevolent_mind = { RABBITKINGSHOP=true },
    festive = { CARNIVAL_PRIZESHOP=true, CARNIVAL_HOSTSHOP=true },
}

function M.GetRecipes(id) return registered[id] or {} end

function M.CanUnlock(perk)
    local recipes = registered[perk.id]
    if perk.builder_tag == nil or recipes == nil or #recipes == 0 then return false end
    for _, name in ipairs(recipes) do
        local recipe = AllRecipes[name]
        if recipe == nil or recipe.builder_tag ~= perk.builder_tag or recipe.builder_skill ~= nil
            or Prefabs[recipe.product] == nil then return false end
    end
    return true
end

function M.Register(env)
    local G = env.GLOBAL
    local function Add(id, name, ingredients, config)
        local perk = Catalog.ById(id)
        config.builder_tag = perk.builder_tag
        config.nounlock = true
        -- Alias recipe metadata only. Native deconstruction looks up the product
        -- prefab's original recipe, so this does not protect the spawned item.
        config.no_deconstruction = true
        local product = string.upper(config.product or name)
        G.STRINGS.NAMES[string.upper(name)] = G.STRINGS.NAMES[product] or config.product or name
        G.STRINGS.RECIPE_DESC[string.upper(name)] = G.STRINGS.RECIPE_DESC[product] or perk.name
        env.AddRecipe2(name, ingredients, G.TECH.NONE, config, {"CHARACTER"})
        registered[id] = registered[id] or {}
        table.insert(registered[id], name)
    end
    local function Clone(id, name, source)
        -- A technology unlock does not grant another character's skill tree.
        -- Includes Walter's slingshotammo_moonglass and slingshot_frame_gems;
        -- inheritance mappings also need explicit adaptation before bypassing it.
        if source.builder_skill ~= nil then return end
        local config = G.deepcopy(source)
        config.product = source.product
        config.builder_tag = nil
        config.no_builder_tag = nil
        config.name = nil
        config.level = nil
        Add(id, name, G.deepcopy(source.ingredients), config)
    end
    -- Snapshot native recipes before adding aliases. Six retained packages are
    -- precisely the source mod's technology families, including New Year offerings.
    local originals = {}
    for name, recipe in pairs(G.AllRecipes) do originals[name] = recipe end
    for _, perk in ipairs(Catalog.All()) do
        if perk.group == "craft" then
            if perk.recipes ~= nil then
                for _, source_id in ipairs(perk.recipes) do
                    local target = aliases[source_id]
                    if target ~= nil and originals[target] ~= nil then Clone(perk.id, source_id, originals[target]) end
                end
            elseif techs[perk.id] ~= nil or perk.id == "celebrate" then
                for name, recipe in pairs(originals) do
                    local matches = false
                    for tech, level in pairs(recipe.level or {}) do
                        if level > 0 and (techs[perk.id] ~= nil and techs[perk.id][tech]
                            or perk.id == "celebrate" and tech:sub(-8) == "OFFERING") then matches = true end
                    end
                    if matches and recipe.builder_tag == nil then
                        Clone(perk.id, "ttk_achievement_" .. name, recipe)
                    end
                end
            end
        end
    end
    -- Exact retained legacy ingredient costs. Products use native prefab assets.
    local Ingredient = G.Ingredient
    local function Recipe(id, product, ingredients, placer)
        Add(id, "ttk_achievement_" .. product, ingredients,
            { product=product, image=product .. ".tex", placer=placer })
    end
    local sanity = G.CHARACTER_INGREDIENT.SANITY
    Recipe("mad_scientist", "halloweenpotion_bravery_large", {Ingredient("froglegs",1), Ingredient("goldnugget",1), Ingredient(sanity,10)})
    Recipe("mad_scientist", "halloweenpotion_health_large", {Ingredient("mosquito",1), Ingredient("red_cap",1), Ingredient(sanity,10)})
    Recipe("mad_scientist", "halloweenpotion_sanity_large", {Ingredient("crow",1), Ingredient("petals_evil",1), Ingredient(sanity,10)})
    for _, product in ipairs({"halloweenpotion_embers", "halloweenpotion_sparks"}) do
        Recipe("mad_scientist", product, {Ingredient("rottenegg",1), Ingredient("charcoal",1), Ingredient(sanity,10)})
    end
    Recipe("mad_scientist", "halloweenpotion_moon", {Ingredient("moonbutterflywings",1), Ingredient("moon_tree_blossom",1), Ingredient(sanity,10)})
    Recipe("mad_scientist", "livingtree_root", {Ingredient("batwing",1), Ingredient("livinglog",1), Ingredient(sanity,20)})
    Recipe("christmas_gift", "klaus_sack", {Ingredient("redmooneye",1),Ingredient("bluemooneye",1),Ingredient("silk",8)}, "ttk_achievement_klaus_sack_placer")
    Recipe("christmas_gift", "deer_antler1", {Ingredient("boneshard",2),Ingredient("twigs",1)})
    local smith = {
        {"spiderhat", {{"silk",12},{"spidergland",6},{"monstermeat",3}}},
        {"hivehat", {{"honeycomb",12},{"honey",9},{"royal_jelly",6},{"bee",12}}},
        {"armorskeleton", {{"fossil_piece",5},{"boneshard",30},{"nightmarefuel",18}}},
        {"skeletonhat", {{"fossil_piece",5},{"boneshard",30},{"nightmarefuel",12}}},
        {"thurible", {{"cutstone",2},{"nightmarefuel",6},{"ash",1}}},
        {"eyemaskhat", {{"milkywhites",9},{"monstermeat",6}}},
        {"shieldofterror", {{"gears",4},{"nightmarefuel",6}}},
        {"alterguardianhat", {{"alterguardianhatshard",15}}},
        {"alterguardianhatshard", {{"moonglass_charged",1},{"moonglass",1},{"purebrilliance",1},{"opalpreciousgem",1}}},
        {"malbatross_beak", {{"malbatross_feather",15},{"houndstooth",7}}},
        {"scrap_monoclehat", {{"wagpunkhat",1},{"wagpunk_bits",6},{"transistor",3},{"trinket_6",3}}},
        {"scraphat", {{"wall_scrap_item",20},{"wagpunk_bits",9}}},
        {"cutless", {{"log",5},{"palmcone_scale",5}}},
        {"oar_monkey", {{"cutless",1},{"log",3},{"palmcone_scale",3}}},
        {"monkey_smallhat", {{"tentaclespots",1}}},
        {"monkey_mediumhat", {{"blackflag",1},{"monkey_smallhat",1}}},
        {"lavae_egg", {{"mitegland",3},{"dragon_scales",2}}},
        {"tentaclespike", {{"tentaclespots",2},{"houndstooth",3}}},
        {"rabbitkingspear", {{"carrot",2},{"beardhair",9},{"manrabbit_tail",3},{"rope",3}}},
    }
    local dens = {
        {"rabbithole", {{"rabbit",1},{"shovel",1}}}, {"molehill", {{"mole",1},{"shovel",1}}},
        {"tallbirdnest", {{"tallbirdegg",1},{"cutgrass",4}}}, {"catcoonden", {{"coontail",1},{"log",4}}},
        {"houndmound", {{"houndstooth",4},{"boneshard",4}}}, {"monkeybarrel", {{"cave_banana",4},{"log",3}}},
        {"slurtlehole", {{"slurtle_shellpieces",4},{"slurtleslime",4}}}, {"walrus_camp", {{"walrus_tusk",4},{"walrushat",4}}},
        {"wasphive", {{"killerbee",4},{"honeycomb",4}}}, {"oceanvine_cocoon", {{"silk",4},{"twigs",4}}},
        {"spiderhole", {{"silk",4},{"fossil_piece",2},{"rocks",4}}}, {"moonspiderden", {{"silk",4},{"moonglass",2},{"moonrocknugget",4}}},
    }
    for id, rows in pairs({legendary_smith=smith, pokeball=dens}) do
        for _, row in ipairs(rows) do
            local ingredients = {}
            for _, item in ipairs(row[2]) do table.insert(ingredients, Ingredient(item[1], item[2])) end
            Recipe(id, row[1], ingredients, id == "pokeball" and "ttk_achievement_" .. row[1] .. "_placer" or nil)
        end
    end
    for index = 1, G.NUM_TRINKETS do
        local gold = G.TUNING.GOLD_VALUES.TRINKETS[index]
        gold = gold ~= nil and math.ceil(gold * .5) or 2
        local extra = gold > 2 and "spiderhat" or gold == 2 and "horn" or "tentaclespike"
        Recipe("antique_shop", "trinket_" .. tostring(index), {Ingredient("goldnugget",gold),Ingredient(extra,1)})
    end
end

-- Auditable dependency boundary: 42/50 source IDs have no safe registered
-- equivalent. In particular, all eight Wang Mazi md forms depend on source-only
-- character/spell state; art files or similarly named weapons are not adapters.
function M.UnavailableInheritance()
    local missing = {}
    for _, perk in ipairs(Catalog.All()) do
        if perk.recipes ~= nil then
            for _, name in ipairs(perk.recipes) do
                if aliases[name] == nil then table.insert(missing, name) end
            end
        end
    end
    return missing
end

return M
