local M = {}
M.entries = {
    { id = "eva_original", atlas = "bigportraits/eva.xml", texture = "eva.tex", ratio = 2 / 3 },
    { id = "eva_art_1", atlas = "images/eva_portraits/eva_art_1.xml", texture = "eva_art_1.tex", ratio = 2 / 3 },
    { id = "eva_art_2", atlas = "images/eva_portraits/eva_art_2.xml", texture = "eva_art_2.tex", ratio = 9 / 16 },
    { id = "eva_art_3", atlas = "images/eva_portraits/eva_art_3.xml", texture = "eva_art_3.tex", ratio = 2 / 3 },
    { id = "eva_art_4", atlas = "images/eva_portraits/eva_art_4.xml", texture = "eva_art_4.tex", ratio = 2 / 3 },
}
local KEY = "pham_nhan_eva_portrait_v1"
local State = {}
State.__index = State
function M.New(sim, changed)
    return setmetatable({ sim = sim, changed = changed, index = 1, default = "eva_original", revision = 0, saves = 0 }, State)
end
function State:Notify()
    if self.changed then self.changed() end
end
function State:Get() return M.entries[self.index] end
function State:IsDefault() return self:Get().id == self.default end
function State:Load()
    local revision = self.revision
    local saves = self.saves
    self.sim:GetPersistentString(KEY, function(ok, id)
        if ok and self.saves == saves then
            for i, entry in ipairs(M.entries) do
                if entry.id == id then
                    self.default = id
                    if self.revision == revision then self.index = i end
                    break
                end
            end
        end
        self:Notify()
    end)
end
function State:Step(direction)
    self.index = ((self.index - 1 + direction) % #M.entries) + 1
    self.revision = self.revision + 1
    self.error = nil
    self:Notify()
end
function State:Save()
    if self.saving then return end
    local id = self:Get().id
    self.saves = self.saves + 1
    self.revision = self.revision + 1
    self.saving, self.error = true, nil
    self:Notify()
    self.sim:SetPersistentString(KEY, id, false, function(ok)
        self.saving = false
        if ok then self.default = id else self.error = true end
        self:Notify()
    end)
end
return M
