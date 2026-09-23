local defs = require"prefabs/lucmachthankiem_defs"

local EMBER_TEXTURE = resolvefilepath"fx/lucmachthankiem_light_particle.tex"
local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local EMBER_MAX_LIFETIME = 0.6
local SCALE_ENVELOPE_NAME_EMBER = "lucmachthankiem_particle_scaleenvelope_ember"

local assets = {
    Asset("IMAGE", EMBER_TEXTURE),
}

local function IntColour(r, g, b, a)
    return {r / 255, g / 255, b / 255, a / 255}
end

local function InitEnvelope()

    for i, data in ipairs(defs) do
        local NAME = data.name.."_colourenvelope"
        local color = data.color
        EnvelopeManager:AddColourEnvelope(
            NAME,
            {
                { 0,    {color[1], color[2], color[3], 25} },
                { .2,   {color[1], color[2], color[3], 255} },
                { .6,   {color[1]/2, color[2]/2, color[3]/2, 200} },
                { 1,    IntColour(0, 0, 0, 0) },
            }
        )
    end

    local max_scale = 0.75
    local end_scale = 0.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_EMBER,
        {
            { 0,    { max_scale, max_scale } },
            { 0.5,  { max_scale, max_scale } },
            { 1,    { end_scale * max_scale, end_scale * max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

local function GetRandomMinMax(min, max)
    return min + math.random() * (max - min)
end

local function EmitEmberFn(effect, sphere_emitter, adjust_vec)
    local v = 0.2
    local vx, vy, vz = v * UnitRand(), 0, v * UnitRand()
    local lifetime = EMBER_MAX_LIFETIME * GetRandomMinMax(0.5, 1)

    local px, py, pz = sphere_emitter()
    py = py + 2

    effect:AddRotatingParticle(
        0,
        lifetime,                           -- lifetime
        px, py, pz,                         -- position
        vx, vy, vz,                         -- velocity
        GetRandomItem({0, 90, 180, 270}),   -- angle
        0                                   -- angle velocity
    )
end

local function MakeParticleVFX(name, COLOUR_ENVELOPE)

    local function fn()
        local inst = CreateEntity()
    
        inst.entity:AddTransform()
        inst.entity:AddNetwork()
    
        inst:AddTag"FX"
        inst:AddTag"NOCLICK"
    
        inst.entity:SetPristine()
    
        inst.persists = false

        if TheWorld.ismastersim then
            inst:DoTaskInTime(0.2, inst.Remove)
        end
    
        if TheNet:IsDedicated() then
            return inst
        elseif InitEnvelope ~= nil then
            InitEnvelope()
        end
    
        local effect = inst.entity:AddVFXEffect()
        effect:InitEmitters(1)
    
        --EMBER
        effect:SetRenderResources(0, EMBER_TEXTURE, ADD_SHADER)
        effect:SetRotationStatus(0, true)
        effect:SetMaxNumParticles(0, 200)
        effect:SetMaxLifetime(0, EMBER_MAX_LIFETIME)
        effect:SetColourEnvelope(0, COLOUR_ENVELOPE)
        effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_EMBER)
        effect:SetBlendMode(0, BLENDMODE.Additive)
        effect:EnableBloomPass(0, true)
        effect:SetLayer(0, LAYER_WORLD)
        effect:SetSortOrder(0, 2)
        effect:SetSortOffset(0, 0)
        effect:SetDragCoefficient(0, .1)
        effect:SetAngularDragCoefficient(0, .1)
        effect:EnableDepthTest(0, true)
        
        -----------------------------------------------------
    
        local ember_sphere_emitter = CreateSphereEmitter(1.25)
        local step = 0

        EmitterManager:AddEmitter(inst, nil, function()

            step = step + 1
            if step >= 2 then
                step = 0
                EmitEmberFn(effect, ember_sphere_emitter, nil)
            end
    
        end)
    
        return inst
    end

    return Prefab(name, fn, assets)
end

local prefabs = {}
for i, data in ipairs(defs) do
    table.insert(prefabs, MakeParticleVFX(data.name.."_ember_vfx", data.name.."_colourenvelope"))
end

return unpack(prefabs)