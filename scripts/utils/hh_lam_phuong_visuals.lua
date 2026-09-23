-- Cosmetic feedback only. Costs, probabilities and equipment are owned by Solo.
local M = {}

local function OnForge(inst)
    inst.AnimState:PlayAnimation("forge")
    inst.AnimState:PushAnimation("idle", true)
    inst.Light:Enable(true)
    if inst._lam_phuong_light_task ~= nil then
        inst._lam_phuong_light_task:Cancel()
    end
    inst._lam_phuong_light_task = inst:DoTaskInTime(1.2, function()
        inst._lam_phuong_light_task = nil
        inst.Light:Enable(false)
    end)
end

function M.Install(inst)
    inst:ListenForEvent("hh_lam_phuong_forge", OnForge)
end

return M
