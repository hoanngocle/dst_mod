function TTK_HUDCore.Tint(tint, alpha, raw)
	if raw then
		return tint[1], tint[2], tint[3], alpha or 1
	end
	return { r = tint[1] or 1, g = tint[2] or 1, b = tint[3] or 1, a = alpha or tint[4] or 1 }
end

function TTK_HUDCore.Alpha(alpha)
	return TTK_HUDCore.Tint(WHITE, alpha)
end

function TTK_HUDCore.FormatTimer(time)
	local bits = {}
	if time_units == nil then
		time_units = { { 86400, "d"}, { 3600, "h" }, { 60, "m" }, { 1, "s" }  }
	end
	for index, data in pairs(time_units) do
		local range, suffix = unpack(data)
		if time > range then
			table.insert(bits, math.floor(time / range) .. suffix)
			time = time % range
			if #bits == 2 then
				break
			end
		end
	end
	return table.concat(bits, " ")
end

function TTK_HUDCore.Load(assets)
	local prefab = Prefab("MOD_" .. modname .. math.random(), nil, assets, {}, true)
	prefab.search_asset_first_path = MODROOT
	RegisterSinglePrefab(prefab)
	TheSim:LoadPrefabs({ prefab.name })
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
if IsInFrontEnd() then return end --\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

function TTK_HUDCore.Replica(inst, fn)
	if TheWorld.ismastersim or inst.Network == nil then
		inst:DoTaskInTime(0, fn)
	else
		TTK_HUDCore.After(inst, "OnEntityReplicated", fn)
	end
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local TAGS =
{
	Limbo = "INLIMBO",
	Blocker = "blocker",
	Item = "_inventoryitem",
	Follower = "_follower",
	Combat = "_combat",
	FX = "FX",
}

for name, tag in pairs(TAGS) do
	TTK_HUDCore[name] = { tag }
end