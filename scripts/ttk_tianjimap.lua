local M = {}
local rooms = {}
function M.Reset() rooms = {} end
function M.Register(x, z) rooms[x .. ":" .. z] = {x=x, z=z} end
function M.Remove(x, z) rooms[x .. ":" .. z] = nil end
function M.Contains(x, z)
    if x == nil or z == nil then return nil end
    for _, room in pairs(rooms) do
        if math.abs(x-room.x) <= 14 and math.abs(z-room.z) <= 14 then return room end
    end
end
function M.Preload(data)
    for _, room in pairs(data and data.rooms or {}) do M.Register(room.x, room.z) end
end
function M.Install(map)
    local mt = getmetatable(map)
    local methods = mt and mt.__index or map
    if methods._ttk_tianji_installed then return end
    methods._ttk_tianji_installed = true
    local function wrap(name, value)
        local old = methods[name]
        if old then
            methods[name] = function(self, x, y, z, ...)
                if M.Contains(x,z) then return value end
                return old(self,x,y,z,...)
            end
        end
    end
    for _, name in ipairs({"IsPassableAtPoint", "IsPassableAtPointWithPlatformRadiusBias", "IsAboveGroundAtPoint", "IsVisualGroundAtPoint"}) do wrap(name,true) end
    for _, name in ipairs({"IsOceanAtPoint", "IsOceanTileAtPoint"}) do wrap(name,false) end
    wrap("GetTileAtPoint", (WORLD_TILES or GROUND).WOODFLOOR)
    local old = methods.GetTileCenterPoint
    methods.GetTileCenterPoint = function(self,x,y,z,...)
        if z ~= nil and M.Contains(x,z) then return math.floor(x/4)*4+2,0,math.floor(z/4)*4+2 end
        if z == nil then return old(self,x,y,...) end
        return old(self,x,y,z,...)
    end
end
return M
