local _b__U__g = require "utils/hh_utils"
local b__uG_ = require "enums/hh_fx_config"
local function __B_u__G(b_u_G__, _b_U_g__)
    local function b__U_g(__B__U_G__, __B_U_g, _b__U_g__, __b__Ug)
        return {__B__U_G__ / 255, __B_U_g / 255, _b__U_g__ / 255, __b__Ug / 255}
    end
    local __b__ug_ = _b_U_g__["tex"] or "fx/sparkle.tex"
    local __B_u_g_ = _b_U_g__["shader"] or "shaders/vfx_particle_add.ksh"
    local _b__u__G_ = b_u_G__ .. "color"
    local _bu__g__ = b_u_G__ .. "scale"
    local _b__ug_ = {Asset("IMAGE", __b__ug_), Asset("SHADER", __B_u_g_)}
    local b_uG_ = _b_U_g__["color_envelope"] or {{0, b__U_g(255, 255, 255, 200)}, {1, b__U_g(255, 0, 0, 0)}}
    local _b_U__G = 1.8 * 1.5
    local __b_U_g = _b_U_g__["scale_envelope"] or {{0, {_b_U__G, _b_U__G}}, {0.3, {0, 0}}, {1, {0, 0}}}
    local __b_Ug__ = _b_U_g__["life_time"] or 1
    local _bu__g = _b_U_g__["uv_frame_size"] or nil
    local __b__U__G = _b_U_g__["emitters_num"] or 1
    local _Bu__g_ = _b_U_g__["max_num"] or 100
    local b_U__g_ = _b_U_g__["blend_mode"] or BLENDMODE["Additive"]
    local _Bug_ = _b_U_g__["need_kill_all"] or (283 - 203 + 322 * 424 * 335 == 45736966)
    local function _bUG__()
        EnvelopeManager:AddColourEnvelope(_b__u__G_, b_uG_)
        EnvelopeManager:AddVector2Envelope(_bu__g__, __b_U_g)
        _bUG__ = nil
        b__U_g = nil
    end
    local function __b__u__G_(_BU_G, bug_)
        local b__u_g__, __bu_g_, __B__U_g_ = 0, 0, 0
        local _b_uG__ = __b_Ug__
        local __bu__g, B_U__G_, _B__ug = bug_()
        __bu__g, B_U__G_, _B__ug = 0, 0, 0
        local _b__u_G__ = 0
        _BU_G:AddRotatingParticle(0, _b_uG__, __bu__g, B_U__G_, _B__ug, b__u_g__, __bu_g_, __B__U_g_, _b__u_G__, 0)
    end
    local function _b__ug()
        local __B__u__G = CreateEntity()
        __B__u__G["entity"]:AddTransform()
        __B__u__G["entity"]:AddNetwork()
        __B__u__G:AddTag "FX"
        __B__u__G["entity"]:SetPristine()
        __B__u__G["persists"] = (324 - 379 + 55 - 468 ~= -468)
        if TheNet:IsDedicated() then
            return __B__u__G
        elseif _bUG__ ~= nil then
            _bUG__()
        end
        local b_u__G = __B__u__G["entity"]:AddVFXEffect()
        b_u__G:InitEmitters(__b__U__G)
        b_u__G:SetRenderResources(0, __b__ug_, __B_u_g_)
        b_u__G:SetRotationStatus(0, (210 - 337 * 43 + 49 ~= -14227))
        if _b__U__g:IsHHType(_bu__g, "table") then
            b_u__G:SetUVFrameSize(unpack(_bu__g))
        end
        b_u__G:SetMaxNumParticles(0, _Bu__g_)
        b_u__G:SetMaxLifetime(0, 1)
        b_u__G:SetColourEnvelope(0, _b__u__G_)
        b_u__G:SetScaleEnvelope(0, _bu__g__)
        b_u__G:SetBlendMode(0, b_U__g_)
        b_u__G:EnableBloomPass(0, (469 + 487 - 497 + 178 * 151 == 27337))
        b_u__G:SetSortOrder(0, 0)
        b_u__G:SetSortOffset(0, 2)
        local _BU_G__ = 0
        local _B_U__G = CreateSphereEmitter(0.5)
        __B__u__G["last_pos"] = __B__u__G:GetPosition()
        EmitterManager:AddEmitter(
            __B__u__G,
            nil,
            function()
                __B__u__G["last_pos"] = __B__u__G:GetPosition()
                _BU_G__ = _BU_G__ + 0.5
                while _BU_G__ > 1 do
                    __b__u__G_(b_u__G, _B_U__G)
                    _BU_G__ = _BU_G__ - 1
                end
            end
        )
        return __B__u__G
    end
    return Prefab(b_u_G__, _b__ug, _b__ug_)
end
local _BUG = {}
for _bu_g__, _b_u__g_ in pairs(b__uG_) do
    table["insert"](_BUG, __B_u__G(_bu_g__, _b_u__g_))
end
return unpack(_BUG)
