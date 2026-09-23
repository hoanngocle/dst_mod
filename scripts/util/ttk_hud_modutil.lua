if modinfo.configuration_options ~= nil then
	modconfig = {}
	for i, v in ipairs(modinfo.configuration_options) do
		if #v.options > 1 then
			modconfig[v.name] = GetModConfigData(v.name, v.client)
			env[v.name] = modconfig[v.name]
		end
	end
end

PrefabFiles = {}
Assets = {}

function AddPrefab(file) table.insert(PrefabFiles, file) end
function AddAsset(type, file, param) table.insert(Assets, Asset(type, file, param)) end

function AddPostInitFn(type, key, value)
	if postinitfns[type] == nil then
		postinitfns[type] = {}
	end
	if value ~= nil then
		if postinitfns[type][key] == nil then
			postinitfns[type][key] = {}
		end
		table.insert(postinitfns[type][key], value)
	else
		table.insert(postinitfns[type], key)
	end
end

function AddPostInitData(type, key, value)
	if postinitdata[type] == nil then
		postinitdata[type] = {}
	end
	if value ~= nil then
		postinitdata[type][key] = value
	else
		table.insert(postinitdata[type], key)
	end
end

function GetPostInitFns(type, key)
	if key ~= nil then
		return postinitfns[type] and postinitfns[type][key]
	end
	return postinitfns[type] or TTK_HUDCore.Empty
end

function GetPostInitData(type)
	return postinitdata[type] or TTK_HUDCore.Empty
end

function HasPostInit(type)
	return postinitfns[type] or postinitdata[type]
end

function AddModsPostInit(fn)
	if not HasPostInit("Mods") then
		TTK_HUDCore.After(_G, "TranslateStringTable", function() --this is called right after all mods
			if not modspostinitdone then
				modspostinitdone = true
				for i, fn in ipairs(GetPostInitFns("Mods")) do
					fn()
				end
			end
		end)
	end
	AddPostInitFn("Mods", fn)
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

function AddClassPostInit(name, fn)
	if not HasPostInit("Widget") then
		AddSimPostInit(function()
			for name, fns in pairs(GetPostInitFns("Widget")) do
				TTK_HUDCore.Init(require(name), function(...)
					for i, fn in ipairs(fns) do fn(...) end
				end)
			end
		end)
	end
	AddPostInitFn("Widget", name, fn)
end

if not TheNet:IsDedicated() then
	Text = require "widgets/text"
	Image = require "widgets/image"
	Widget = require "widgets/widget"
	UIAnim = require "widgets/uianim"

	AddComponentPostInit("focalpoint", function(self, inst)
		function self:IsFocusBlocked(source, require_source)
			return self.current_focus ~= nil
				and self.current_focus.source ~= source
				and (require_source ~= true or self.targets[source] ~= nil)
		end

		TTK_HUDCore.Branch(self, "Reset", function(Reset, self, ...)
			if self.current_focus ~= nil and self.current_focus.id == "FIXED" or TUNING.FOCUS_SOFT_STOP and self.inst:GetTimeAlive() > 1 then
				self.current_focus = nil
				TheCamera:SetDefaultOffset()
			else
				return Reset(self, ...)
			end
		end)

		TTK_HUDCore.Branch(self, "StopFocusSource", function(StopFocusSource, self, source, id, ...)
			if id ~= "FIXED" then
				return StopFocusSource(self, source, id, ...)
			end
		end)
	end)
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

if modinfo.SetLocaleMod ~= nil then
	AddModsPostInit(function() --run after language mods
		pcall(modinfo.SetLocaleMod, env)
	end)
end

if IsInFrontEnd() then
	local Templates = require "widgets/redux/templates"
	local TrueScrollArea = require "widgets/truescrollarea"
	local Menu = require "widgets/menu"
	--package.loaded["widgets/redux/modstab"] = nil

	function AddModsTabData(type, data)
		data.type = type
		data.onupdate = data.onupdate or TTK_HUDCore.Dummy
		if data.widget ~= nil then
			data.package = require(data.widget)
			package.loaded[data.widget] = nil
			if data.script ~= nil then
				modimport(data.script)
				TTK_HUDCore.Load(Assets)
			end
		end
		if data.type == "overlay" then
			AddPostInitData("ModsTab", data.type, data)
		else
			AddPostInitData("ModsTab", data)
		end
	end

	if modinfo.icon_fancy ~= nil then
		AddModsTabData("widget", { widget = modinfo.icon_fancy, parent = "detailimage" })
	end
	if modinfo.extras ~= nil then
		for key, data in pairs(modinfo.extras) do
			if type(data) == "string" then
				AddModsTabData("widget", { widget = data })
			else
				AddModsTabData(data.type, data)
			end
		end
	end

	local function AddChild(self, data, child)
		data.inst = child.inst
		data.inst:ListenForEvent("onremove", function() data.inst = nil end)
		data.inst:ListenForEvent("clearextras", function(inst, mod)
			if mod == modname then
				child:Kill()
			end
		end, self.inst)
	end

	local function ShowExtras(self, extras)
		if extras.overlay ~= nil then
			local screen = TheFrontEnd:GetActiveScreen()
			if screen.mods_tab == self then
				local overlay = screen:AddChild(extras.overlay.package())
				screen[overlay.name:lower()] = overlay
				extras.overlay = nil
			end
		end

		if self.currentmodname ~= modname then
			return self.inst:PushEvent("clearextras", modname)
		end

		if extras.scroll_area == nil or extras.scroll_area.inst == nil then
			local _, oldheight = self.detaildesc:GetRegionSize()
			if oldheight > 370 then
				local detaildesc = Text(self.detaildesc.font, self.detaildesc.size, nil, self.detaildesc.colour)
				detaildesc:SetHAlign(ANCHOR_LEFT)
				detaildesc:SetMultilineTruncatedString(modinfo.description, 999, self.detaildesc._align.width, self.detaildesc._align.maxchars, true)
				local width, height = detaildesc:GetRegionSize()
				local scroll_area = self.detailpanel:AddChild(TrueScrollArea(
					{ widget = detaildesc, offset = { x = 0, y = (oldheight - height) / 2 }, size = { width = width, height = height } },
					{ x = width / -2, y = oldheight / -2, width = width, height = oldheight },
					{ scroll_per_click = 60, h_offset = -15 }
				))
				scroll_area.scissored_root:AddChild(scroll_area.bg)
				scroll_area.bg:SetPosition(0, 0)
				scroll_area:SetPosition(self.detaildesc:GetPosition())
				extras.scroll_area = { onupdate = function() self.detaildesc:SetPosition(10000, 0) end }
				AddChild(self, extras.scroll_area, scroll_area)
			end
		end

		for key, data in pairs(extras) do
			if data.inst ~= nil then
				data.onupdate(data.inst.widget)
			elseif data.type == "button" then
				local button = Templates.IconButton(data.atlas or GetInventoryItemAtlas(data.image), data.image, data.name or modname, false, false, function()
					if data.link ~= nil then
						VisitURL(data.link)
					elseif data.onclick ~= nil then
						data.onclick(data.inst.widget)
					end
					data.onupdate(data.inst.widget, true)
				end, { offset_x = 2, offset_y = 45 })
				if data.scale ~= nil or data.atlas == nil then
					button.icon:SetScale(data.scale or 0.65)
				end
				data.onupdate(button)

				if extras.menu == nil or extras.menu.inst == nil then
					local menu = self.selectedmodmenu.parent:AddChild(Menu(nil, -math.abs(self.selectedmodmenu.offset), true))
					menu:SetPosition(self.selectedmodmenu:GetPosition() - Vector3(self.selectedmodmenu.offset, 0))
					extras.menu = { onupdate = TTK_HUDCore.Dummy }
					AddChild(self, extras.menu, menu)
				end
				extras.menu.inst.widget:AddCustomItem(button)
				AddChild(self, data, button)
			elseif data.type == "widget" then
				local widget = data.package(self, extras)
				local parent = self[data.parent] or widget.parent or self.detailpanel
				parent:AddChild(widget)
				AddChild(self, data, widget)
			end
		end
	end

	local function PatchModsTab()
		local ModsTab = require "widgets/redux/modstab"
		local screen = TheFrontEnd and TheFrontEnd:GetActiveScreen()
		local mods_tab = screen and screen.mods_tab or ModsTab

		local key = "ShowExtras" .. modname
		if mods_tab[key] == nil then
			TTK_HUDCore.After(mods_tab, "ShowModDetails", function(self)
				if self[key] ~= nil then
					self[key](self)
				end
			end)
		end

		mods_tab[key] = function(self)
			local success, message = pcall(ShowExtras, self, GetPostInitData("ModsTab"))
			if not success then
				print(modname, "ShowModDetails", message)
				self[key] = TTK_HUDCore.Dummy
			end
		end

		if mods_tab.inst ~= nil then
			mods_tab.inst:PushEvent("clearextras", modname)
		end
	end

	pcall(PatchModsTab)
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

for pre, pst in pairs({ ModRPC = "Server", ClientModRPC = "Client", ShardModRPC = "Shard" }) do
	local addfn = "Add" .. pre .. "Handler"
	local getfn = "Get" .. pre
	local sendfn = "SendModRPCTo" .. pst

	env[addfn] = function(namespace, name, fn)
		if fn == nil then
			namespace, name, fn = "TTK_HUDCore", namespace, name
		end
		_G[addfn](namespace, name, fn)
	end

	env[sendfn] = function(rpc, ...)
		if type(rpc) == "string" then
			rpc = _G[getfn]("TTK_HUDCore", rpc)
		end
		_G[sendfn](rpc, ...)
	end

	TTK_HUDCore[sendfn] = env[sendfn]
end