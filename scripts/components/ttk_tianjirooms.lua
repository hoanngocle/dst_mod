local terrain = require("ttk_tianjimap")
local Rooms = Class(function(self,inst) self.inst=inst;self.rooms={} end)

local function build(x,z)
    local spawned={}
    local function add(name,dx,dz,mirror)
        local ent=SpawnPrefab(name)
        if not ent then return false end
        table.insert(spawned,ent)
        ent.Transform:SetPosition(x+dx,0,z+dz)
        if mirror then ent._ttk_mirror=true;ent.Transform:SetScale(-1,1,1) end
        return true
    end
    local ok=add("ttk_tianji_room",0,0)
        and add("ttk_tianji_exit",13.3,0.3)
        and add("ttk_tianji_floor",-14.7,0)
        and add("ttk_tianji_wallpaper",-1,0)
        and add("ttk_tianji_doorart",14.6,0)
        and add("ttk_tianji_decals",14,-14.5)
        and add("ttk_tianji_decals",14,14.5,true)
    for n=-15,15 do
        if ok then
            ok=add("ttk_tianji_wall",-14.8,n+0.5) and add("ttk_tianji_wall",14.8,n+0.5)
                and add("ttk_tianji_wall",n+0.5,-14.8) and add("ttk_tianji_wall",n+0.5,14.8)
        end
    end
    if not ok then
        for _,ent in ipairs(spawned) do ent:Remove() end
        terrain.Remove(x,z)
        return false
    end
    return true
end

local function footprintFree(x, z)
    -- Solo can reserve synthetic ground without leaving an entity at its centre.
    for dx = -16, 16, 4 do
        for dz = -16, 16, 4 do
            local px, pz = x + dx, z + dz
            if terrain.Contains(px, pz)
                or TheWorld.Map:IsAboveGroundAtPoint(px, 0, pz)
                or TheWorld.Map:IsPassableAtPoint(px, 0, pz) then
                return false
            end
        end
    end
    return #TheSim:FindEntities(x, 0, z, 50, nil, {"INLIMBO"}) == 0
end

function Rooms:GetRoom(owner)
    if not owner then return nil end
    if self.rooms[owner] then return self.rooms[owner] end
    for side=1,2 do
        for k=1,78 do
            local row=math.ceil(k/3)-1
            local x=-1852+150*row
            local z=(side==1 and 1500 or -1850)+150*((k-3*row)-1)
            if footprintFree(x,z) then
                terrain.Register(x,z)
                if not build(x,z) then return nil end
                self.rooms[owner]={x=x,z=z}
                return self.rooms[owner]
            end
        end
    end
end
function Rooms:OnSave() return {rooms=self.rooms} end
function Rooms:OnLoad(data)
    self.rooms=data and data.rooms or {}
    terrain.Preload(data)
end

local function safe(x,z)
    return not terrain.Contains(x,z) and TheWorld.Map:IsPassableAtPoint(x,0,z)
        and not TheWorld.Map:IsPointNearHole(Vector3(x,0,z))
        and not TheWorld.Map:IsOceanAtPoint(x,0,z)
end
local function safeNear(x,z)
    if safe(x,z) then return Vector3(x,0,z) end
    for radius=1,16 do
        for i=0,15 do
            local a=i*2*math.pi/16
            local px,pz=x+radius*math.cos(a),z+radius*math.sin(a)
            if safe(px,pz) then return Vector3(px,0,pz) end
        end
    end
end
local function move(ent,pt)
    if ent.Physics then ent.Physics:Teleport(pt.x,0,pt.z)
    else ent.Transform:SetPosition(pt.x,0,pt.z) end
    if ent.components.locomotor then ent.components.locomotor:Stop() end
    if ent.SnapCamera then ent:SnapCamera() end
end
local function transport(player,pt)
    move(player,pt)
    local seen={}
    local function followers(entity)
        local leader=entity.components and entity.components.leader
        if leader then
            for follower in pairs(leader.followers) do
                if follower:IsValid() and not seen[follower] then seen[follower]=true;move(follower,pt) end
            end
        end
    end
    followers(player)
    local inv=player.components.inventory
    if inv then
        if inv.activeitem then followers(inv.activeitem) end
        for _,item in pairs(inv.itemslots) do followers(item) end
        for _,item in pairs(inv.equipslots) do
            followers(item)
            if item.components.container then for _,v in pairs(item.components.container.slots) do followers(v) end end
        end
    end
end
function Rooms:Enter(house,player)
    if not player or not player.userid or not player.components.ttk_tianjireturn then return false end
    local room=self:GetRoom(house._ttk_owner)
    if not room then return false end
    local x,_,z=player.Transform:GetWorldPosition()
    if terrain.Contains(x,z) then return false end
    player.components.ttk_tianjireturn:Mark(x,z)
    transport(player,Vector3(room.x+11.5,0,room.z))
    return true
end
function Rooms:Exit(player)
    if not player or not player.components.ttk_tianjireturn then return false end
    local saved=player.components.ttk_tianjireturn.pos
    local pt=saved and saved.shard==tostring(TheShard:GetShardId()) and safeNear(saved.x,saved.z) or nil
    if not pt then
        for _,ent in pairs(Ents) do
            if ent:IsValid() and ent:HasTag("multiplayer_portal") then
                local x,_,z=ent.Transform:GetWorldPosition();pt=safeNear(x,z)
                if pt then break end
            end
        end
    end
    if not pt then return false end
    transport(player,pt)
    player.components.ttk_tianjireturn.pos=nil
    return true
end
return Rooms
