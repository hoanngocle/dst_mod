local defs = require("ttk_boss_defs")
local terrain = require("ttk_tianjimap")

local Registry = Class(function(self, inst)
    self.inst = inst
    self.entries = {}
    self.busy = {}
    self.ready = false
    for _,key in ipairs(defs.order) do self.entries[key]={status="unspawned"} end
    inst:DoTaskInTime(2, function()
        self:Reconcile()
        self.ready=true
        self:Seed()
    end)
end)

local function Alive(inst)
    return inst ~= nil and inst:IsValid() and inst.components.health ~= nil
        and not inst.components.health:IsDead()
end

function Registry:CanSpawn(key, summoned)
    local def=defs.bosses[key]
    local row=self.entries[key]
    if def == nil or row == nil or self.busy[key] then return false end
    if summoned then return not def.unique and row.status == "dead" end
    return row.status == "unspawned"
end

function Registry:Register(key, inst)
    local row=self.entries[key]
    if row == nil or not Alive(inst) or inst._ttk_boss_auxiliary then return false end
    if row.status == "alive" and row.entity ~= inst then return false end
    if defs.bosses[key].unique and row.status == "dead" then return false end
    inst._ttk_boss_main=true
    inst._ttk_boss_key=key
    inst.persists=true
    row.status="alive"
    row.guid=inst.GUID
    row.entity=inst
    inst:ListenForEvent("onremove",function()
        -- Death is recorded by the death hook before corpse removal. Arbitrary
        -- removal must not unlock a fresh initial spawn or a free summon.
        if row.entity == inst and row.status == "alive" then
            row.status="missing";row.entity=nil;row.guid=nil
            print("[Phàm Nhân] Main boss removed without final death: "..key)
        end
    end)
    return true
end

function Registry:MarkDead(key, inst)
    local row=self.entries[key]
    if not row or row.status ~= "alive" or row.entity ~= inst or inst._ttk_boss_auxiliary then return false end
    row.status="dead";row.guid=nil;row.entity=nil
    return true
end

function Registry:OnSave()
    local saved={entries={}}
    local refs={}
    for _,key in ipairs(defs.order) do
        local row=self.entries[key]
        local guid=row.entity and row.entity:IsValid() and row.entity.GUID or row.guid
        saved.entries[key]={status=row.status,guid=guid}
        if guid and row.status=="alive" then table.insert(refs,guid) end
    end
    return saved,refs
end

function Registry:OnLoad(data)
    self.ready=false
    if not data or type(data.entries)~="table" then return end
    for _,key in ipairs(defs.order) do
        local row=data.entries[key]
        if type(row)=="table" then
            local status=row.status
            if status~="alive" and status~="dead" and status~="missing" and status~="unspawned" then status="missing" end
            self.entries[key]={status=status,guid=row.guid}
        end
    end
end

function Registry:LoadPostPass(newents)
    for _,key in ipairs(defs.order) do
        local row=self.entries[key]
        local record=row.guid and newents[row.guid] or nil
        if row.status=="alive" and record and Alive(record.entity) then
            row.entity=record.entity
            -- Same instance is allowed; do not treat the loading entity as a duplicate.
            self:Register(key,record.entity)
        elseif row.status=="alive" then
            row.status="missing"
            print("[Phàm Nhân] Saved boss entity missing: "..key)
        end
    end
end

function Registry:Reconcile()
    -- Post-load scan only adopts saved MAIN entities, never source minions or
    -- arbitrary c_spawn calls. Missing records remain missing, never unspawned.
    for _,inst in pairs(Ents) do
        local key=inst._ttk_boss_key
        local row=key and self.entries[key]
        if row and inst._ttk_boss_main and not inst._ttk_boss_auxiliary and Alive(inst)
            and row.status~="dead" and (row.entity==inst or not Alive(row.entity)) then
            row.entity=inst;row.guid=inst.GUID;row.status="alive"
            self:Register(key,inst)
        end
    end
    for _,row in pairs(self.entries) do
        if row.status=="alive" and not Alive(row.entity) then row.status="missing" end
    end
end

local function Ground(x,z)
    local map=TheWorld.Map
    if terrain.Contains(x,z) or not map:IsAboveGroundAtPoint(x,0,z)
        or not map:IsPassableAtPoint(x,0,z) or map:IsOceanAtPoint(x,0,z)
        or map:IsPointNearHole(Vector3(x,0,z)) then return false end
    -- A large boss needs a real patch of land, not a single passable shore point.
    for i=0,7 do
        local a=i*math.pi/4
        local px,pz=x+5*math.cos(a),z+5*math.sin(a)
        if not map:IsAboveGroundAtPoint(px,0,pz) or not map:IsPassableAtPoint(px,0,pz)
            or map:IsOceanAtPoint(px,0,pz) or terrain.Contains(px,pz) then return false end
    end
    return true
end

function Registry:FreePoint(x,z,natural)
    if not Ground(x,z) then return false end
    local radius=60 -- Portal clearance applies to summons as well as initial placement.
    for _,ent in ipairs(TheSim:FindEntities(x,0,z,radius,nil,{"INLIMBO","FX","DECOR","NOCLICK"})) do
        if ent:HasTag("structure") or ent:HasTag("multiplayer_portal") then
            local ex,_,ez=ent.Transform:GetWorldPosition()
            local distance=(ex-x)^2+(ez-z)^2
            if distance < (ent:HasTag("multiplayer_portal") and 60^2 or (natural and 40^2 or 6^2)) then return false end
        elseif natural and ent:HasTag("player") then return false end
    end
    for _,row in pairs(self.entries) do
        if Alive(row.entity) then
            local bx,_,bz=row.entity.Transform:GetWorldPosition()
            if (bx-x)^2+(bz-z)^2 < (natural and 100^2 or 20^2) then return false end
        end
    end
    return true
end

function Registry:SpawnAt(key,x,z)
    local inst=SpawnPrefab(defs.bosses[key].prefab)
    if not inst then return nil end
    local ok,err=pcall(function()
        inst.Transform:SetPosition(x,0,z)
        inst._ttk_boss_home={x=x,z=z}
        if inst.components.knownlocations then inst.components.knownlocations:RememberLocation("home",Vector3(x,0,z)) end
    end)
    if not ok then
        inst:Remove()
        print("[Phàm Nhân] Boss setup failed: "..tostring(err))
        return nil
    end
    if not self:Register(key,inst) then inst:Remove();return nil end
    return inst
end

function Registry:Seed()
    if not self.ready or not self.inst.ismastersim or self.inst:HasTag("cave") then return end
    local topology=self.inst.topology or {}
    local remaining=false
    for _,key in ipairs(defs.order) do
        if self:CanSpawn(key,false) then
            local placed=false
            for attempt=1,120 do
                local nodes=topology.nodes or {}
                if #nodes==0 then break end
                local index=math.random(#nodes)
                local node=nodes[index]
                local name=string.lower((topology.ids or {})[index] or "")
                if node.x and node.y and not string.find(name,"ocean",1,true)
                    and not string.find(name,"island",1,true) and not string.find(name,"moon",1,true) then
                    local angle=math.random()*2*math.pi
                    local radius=24*math.sqrt(math.random())
                    local x,z=node.x+radius*math.cos(angle),node.y+radius*math.sin(angle)
                    if self:FreePoint(x,z,true) then
                        placed=self:SpawnAt(key,x,z)~=nil
                        if placed then break end
                    end
                end
            end
            if not placed then remaining=true end
        end
    end
    -- Retry only genuinely unspawned entries. The saved state is authoritative.
    if remaining and not self.retry then
        self.retry=self.inst:DoTaskInTime(120,function() self.retry=nil;self:Seed() end)
    end
end

function Registry:TrySummon(key, player, item)
    local def=defs.bosses[key]
    if not self.ready then return false,"Thế giới đang tải dữ liệu boss." end
    if not def or def.unique then return false,"Boss này chỉ xuất hiện một lần." end
    if not player or not player:IsValid() or not player:HasTag("player")
        or player:HasTag("playerghost") or not Alive(player) then return false,"Chỉ người đang sống mới dùng được phù." end
    if not item or not item:IsValid() or item.prefab~=def.summon or not item.components.inventoryitem
        or item.components.inventoryitem:GetGrandOwner()~=player then return false,"Phù phải nằm trong túi của bạn." end
    if self.inst:HasTag("cave") then return false,"Hãy triệu hồi trên mặt đất của thế giới chính." end
    local x,_,z=player.Transform:GetWorldPosition()
    if not Ground(x,z) or (player.GetCurrentPlatform and player:GetCurrentPlatform()) then return false,"Cần đứng trên đất liền, ngoài Thiên Cơ Ốc." end
    if not self:CanSpawn(key,true) then return false,"Boss còn tồn tại hoặc chưa được hạ lần đầu." end
    local sx,sz
    for radius=8,12,2 do
        for i=0,15 do
            local a=i*math.pi/8
            local px,pz=x+radius*math.cos(a),z+radius*math.sin(a)
            if self:FreePoint(px,pz,false) then sx=px;sz=pz;break end
        end
        if sx then break end
    end
    if not sx then return false,"Không có khoảng đất trống đủ rộng để triệu hồi." end
    self.busy[key]=true
    local ok,boss=pcall(self.SpawnAt,self,key,sx,sz)
    self.busy[key]=nil
    if not ok then
        print("[Phàm Nhân] Summon failed: "..tostring(boss))
        return false,"Triệu hồi thất bại; phù được giữ lại."
    end
    if not boss then return false,"Không tạo được boss; phù được giữ lại." end
    if item.components.stackable then item.components.stackable:Get(1):Remove() else item:Remove() end
    return true
end

return Registry
