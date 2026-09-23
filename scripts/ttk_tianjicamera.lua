return function(modenv)
-- Suppress only local precipitation emitters while the room camera is active.
-- Keep other emitters and restore each weather callback when leaving.
if not TheNet:IsDedicated() then
    local emitters=EmitterManager
    local oldupdate=emitters.PostUpdate
    local originals=setmetatable({}, {__mode="k"})
    local function paused() end
    emitters.PostUpdate=function(self,...)
        local inside=ThePlayer and ThePlayer._ttk_tianji_camera and ThePlayer._ttk_tianji_camera:value()~=nil
        for inst,data in pairs(self.awakeEmitters.infiniteLifetimes) do
            if inst.prefab=="rain" or inst.prefab=="caverain" or inst.prefab=="snow" then
                if inside and data.updateFunc then
                    if data.updateFunc~=paused then originals[data]=data.updateFunc end
                    data.updateFunc=paused
                elseif originals[data] then
                    if data.updateFunc==paused then data.updateFunc=originals[data] end
                    originals[data]=nil
                end
            end
        end
        return oldupdate(self,...)
    end
end
modenv.AddClassPostConstruct("cameras/followcamera", function(self)
	local Old_Apply = self.Apply
	function self:Apply()
		if self.ttk_tianji_room and self.ttk_tianji_room:IsValid() then
			self.headingtarget = 0
			local pitch = (self.ttk_tianji_room.pitch or 35)* DEGREES 
			local heading = 0 
			local distance = self.ttk_tianji_room.distance or 23 
			local currentpos
			local x1,y1,z1 = self.ttk_tianji_room.Transform:GetWorldPosition()

			 	currentpos = Vector3(x1+ (self.ttk_tianji_room.current_x or 0) ,1.5,z1)

			local fov = self.ttk_tianji_room.fov or 35
			local currentscreenxoffset = 0
			local cos_pitch = math.cos(pitch)
			local cos_heading = math.cos(heading)
			local sin_heading = math.sin(heading)
			local dx = -cos_pitch * cos_heading
			local dy = -math.sin(pitch)
			local dz = -cos_pitch * sin_heading
			local xoffs, zoffs = 0, 0
			if self.shake ~= nil then		
				local shakeOffset = self.shake:Update(FRAMES)
				if shakeOffset ~= nil then
					local rightOffset = self:GetRightVec() * shakeOffset.x
					currentpos.x = currentpos.x + rightOffset.x
					currentpos.y = currentpos.y + rightOffset.y + shakeOffset.y
					currentpos.z = currentpos.z + rightOffset.z
				else
					self.shake = nil
				end
			end
			if currentscreenxoffset ~= 0 then
				local hoffs = 2 * currentscreenxoffset / RESOLUTION_Y
				local magic_number = 1.03
				local screen_heights = math.tan(fov * .5 * DEGREES) * distance * magic_number
				xoffs = -hoffs * sin_heading * screen_heights
				zoffs = hoffs * cos_heading * screen_heights
			end

			TheSim:SetCameraPos(
				currentpos.x - dx * distance + xoffs,
				currentpos.y - dy * distance,
				currentpos.z - dz * distance + zoffs
			)
			TheSim:SetCameraDir(dx, dy, dz)

			local right = (heading + 90) * DEGREES
			local rx = math.cos(right)
			local ry = 0
			local rz = math.sin(right)

			local ux = dy * rz - dz * ry
			local uy = dz * rx - dx * rz
			local uz = dx * ry - dy * rx

			TheSim:SetCameraUp(ux, uy, uz)
			TheSim:SetCameraFOV(fov)
			local listendist = -.1 * distance
			TheSim:SetListener(
				dx * listendist + currentpos.x,
				dy * listendist + currentpos.y,
				dz * listendist + currentpos.z,
				dx, dy, dz,
				ux, uy, uz
			)			
		else
			Old_Apply(self)
		end
	end
end)

modenv.AddPlayerPostInit(function(inst)
    inst._ttk_tianji_camera=net_entity(inst.GUID,"ttk.tianjicamera","ttk_tianjicameradirty")
    local function update()
        if inst==ThePlayer and TheCamera then
            local room=inst._ttk_tianji_camera:value()
            if room and not TheCamera.ttk_tianji_room then inst._ttk_old_heading=TheCamera.headingtarget end
            TheCamera.ttk_tianji_room=room
            if not room and inst._ttk_old_heading then
                TheCamera.headingtarget=inst._ttk_old_heading;inst._ttk_old_heading=nil
            end
        end
    end
    if not TheNet:IsDedicated() then
        inst:ListenForEvent("ttk_tianjicameradirty",update)
        inst:DoTaskInTime(0,update)
    end
    if TheWorld.ismastersim then
        inst:DoPeriodicTask(.25,function()
            local x,_,z=inst.Transform:GetWorldPosition()
            local room=nil
            for _,v in ipairs(TheSim:FindEntities(x,0,z,22,{"ttk_tianji_room"})) do
                local rx,_,rz=v.Transform:GetWorldPosition()
                if math.abs(x-rx)<=14 and math.abs(z-rz)<=14 then room=v;break end
            end
            if inst._ttk_tianji_camera:value()~=room then inst._ttk_tianji_camera:set(room) end
            if inst._ttk_rain_room~=room then
                if inst._ttk_rain_room and inst.components.rainimmunity then
                    inst.components.rainimmunity:RemoveSource(inst._ttk_rain_room)
                end
                inst._ttk_rain_room=room
                if room then
                    if not inst.components.rainimmunity then inst:AddComponent("rainimmunity") end
                    inst.components.rainimmunity:AddSource(room)
                end
            end
        end)
    end
end)
end
