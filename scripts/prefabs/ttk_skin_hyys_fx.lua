local SPARKLE_TEXTURE = "fx/sparkle.tex"
local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local COLOUR_ENVELOPE = "ttk_skin_hyys_colourenvelope"
local SCALE_ENVELOPE = "ttk_skin_hyys_scaleenvelope"
local assets = { Asset("IMAGE", SPARKLE_TEXTURE), Asset("SHADER", ADD_SHADER) }

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE, {
        { 0, { 174 / 255, 242 / 255, 239 / 255, 1 } },
        { 1, { 174 / 255, 242 / 255, 239 / 255, 0 } },
    })
    EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE, {
        { 0, { .1, .1 } }, { .5, { .7, .7 } }, { 1, { .1, .1 } },
    })
    InitEnvelope = nil
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst:AddTag("FX")
    inst.entity:SetPristine()
    inst.persists = false
    if TheNet:IsDedicated() then return inst end
    if InitEnvelope ~= nil then InitEnvelope() end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)
    effect:SetRenderResources(0, SPARKLE_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, 1.75)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)

    local tick = TheSim:GetTickTime()
    local accumulator = 0
    local emitter = CreateSphereEmitter(1)
    EmitterManager:AddEmitter(inst, nil, function()
        accumulator = accumulator + tick
        while accumulator >= .2 do
            local px, _, pz = emitter()
            effect:AddRotatingParticleUV(0, .7, px, math.random() * 1.2 + .4, pz,
                0, 0, 0, 0, 0, 0, 0)
            accumulator = accumulator - .2
        end
    end)
    return inst
end

return Prefab("ttk_skin_hyys_fx", fn, assets)
