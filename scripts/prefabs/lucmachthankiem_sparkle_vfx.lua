local defs = require"prefabs/lucmachthankiem_defs"

local SPARKLE_TEXTURE = "fx/sparkle.tex"
local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local SPARKLE_MAX_LIFETIME = 0.5
local SCALE_ENVELOPE_NAME_SPARKLE = "lucmachthankiem_particle_scaleenvelope_sparkle"

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
        SCALE_ENVELOPE_NAME_SPARKLE,
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

local function EmitSparkleFn(effect, sphere_emitter, adjust_vec)
    local v = 0.05
    local vx, vy, vz = v * UnitRand(), 0, v * UnitRand()
    local lifetime = SPARKLE_MAX_LIFETIME * GetRandomMinMax(0.5, 1)

    local px, py, pz = GetRandomMinMax(-0.25, 0.25), GetRandomMinMax(0.4, 1.2), GetRandomMinMax(-0.25, 0.25)

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
        -- inst.entity:AddNetwork()
    
        inst:AddTag"FX"
        inst:AddTag"NOCLICK"
    
        -- inst.entity:SetPristine()
    
        inst.persists = false
    
        if TheNet:IsDedicated() then
            return inst
        elseif InitEnvelope ~= nil then
            InitEnvelope()
        end
    
        local effect = inst.entity:AddVFXEffect()
        effect:InitEmitters(1)
    
        --SPARKLE
        effect:SetRenderResources(0, SPARKLE_TEXTURE, ADD_SHADER)
        effect:SetUVFrameSize(0, .25, 1)
        
        effect:SetRotationStatus(0, true)
        effect:SetMaxNumParticles(0, 200)
        effect:SetMaxLifetime(0, SPARKLE_MAX_LIFETIME)
        effect:SetColourEnvelope(0, COLOUR_ENVELOPE)
        effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SPARKLE)
        effect:SetBlendMode(0, BLENDMODE.Additive)
        effect:EnableBloomPass(0, true)
        effect:SetLayer(0, LAYER_GROUND)
        effect:SetSortOrder(0, 1)
        effect:SetSortOffset(0, 0)
        effect:SetDragCoefficient(0, .1)
        effect:SetAngularDragCoefficient(0, .1)
        effect:SetAcceleration(0, 0, -0.5, 0)
        effect:EnableDepthTest(0, true)
        -----------------------------------------------------
    
        local step = 0
        local gap = 0
        EmitterManager:AddEmitter(inst, nil, function()

            local velocity = inst.parent and inst.parent.velocity or 0
            if velocity > 20 then
                gap = 3
            elseif velocity > 1 then
                gap = 8
            else
                gap = 15
            end

            step = step + 1
            if step >= gap then
                step = 0
                EmitSparkleFn(effect, nil, nil)
            end
    
        end)
    
        return inst
    end

    return Prefab(name, fn)
end

local prefabs = {}
for i, data in ipairs(defs) do
    table.insert(prefabs, MakeParticleVFX(data.name.."_sparkle_vfx", data.name.."_colourenvelope"))
end

return unpack(prefabs)