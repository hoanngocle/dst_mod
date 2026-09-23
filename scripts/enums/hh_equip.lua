local B_u_g = require("utils/hh_utils")
local HHDaogamDurability = require("utils/hh_daogam_durability")
local bu_G__ = require("enums/hh_prefab_list")
local BU_g = bu_G__["drop_equip"]
local HH_NORMAL_ATTACK_MANA_COST = 5
local HH_NORMAL_ATTACK_NO_MANA_SPEECH = "Bạn không có đủ mana để sử dụng vũ khí này"

local function SpendHHNormalAttackMana(owner, target)
	if owner == nil or not owner:IsValid() or owner:HasTag("playerghost") or target == nil or not target:IsValid() then
		return false
	end

	local components = owner.components
	local health = components ~= nil and components.health or nil
	if health ~= nil and health:IsDead() then
		return false
	end

	local mana = components ~= nil and components.hh_mana or nil
	local current = mana ~= nil and mana.GetCurrent ~= nil and mana:GetCurrent() or nil
	if
		mana == nil
		or mana.GetCurrent == nil
		or mana.DoDelta == nil
		or current == nil
		or current < HH_NORMAL_ATTACK_MANA_COST
	then
		local talker = components ~= nil and components.talker or nil
		if talker ~= nil then
			talker:Say(HH_NORMAL_ATTACK_NO_MANA_SPEECH)
		end
		return false
	end

	mana:DoDelta(-HH_NORMAL_ATTACK_MANA_COST)
	return true
end

local __b__U__g__ = {
	{ ["name"] = "pháp cầu màu tím", ["fx_list"] = { "hh_ball_fx_purple", "hh_sparkle_fx" } },
	{ ["name"] = "pháp cầu màu lục", ["fx_list"] = { "hh_ball_fx_green", "hh_sparkle_fx" } },
	{ ["name"] = "pháp cầu màu đỏ", ["fx_list"] = { "hh_ball_fx_red", "hh_sparkle_fx" } },
	{ ["name"] = "pháp cầu màu lam", ["fx_list"] = { "hh_ball_fx_blue", "hh_sparkle_fx" } },
	{ ["name"] = "pháp cầu màu cam", ["fx_list"] = { "hh_ball_fx_orange", "hh_sparkle_fx" } },
	{ ["name"] = "tinh cầu màu trắng", ["fx_list"] = { "hh_fx_star_white", "hh_sparkle_fx" } },
	{ ["name"] = "tinh cầu màu đỏ", ["fx_list"] = { "hh_fx_star_red", "hh_sparkle_fx" } },
	{ ["name"] = "tinh cầu màu cam", ["fx_list"] = { "hh_fx_star_orange", "hh_sparkle_fx" } },
	{ ["name"] = "tinh cầu màu vàng", ["fx_list"] = { "hh_fx_star_yellow", "hh_sparkle_fx" } },
	{ ["name"] = "tinh cầu màu lục", ["fx_list"] = { "hh_fx_star_green", "hh_sparkle_fx" } },
	{ ["name"] = "tinh cầu màu lam", ["fx_list"] = { "hh_fx_star_blue", "hh_sparkle_fx" } },
	{ ["name"] = "tinh cầu màu tím", ["fx_list"] = { "hh_fx_star_purple", "hh_sparkle_fx" } },
}
local BU__G__ = {
	["gears"] = "ab_decoderStone",
	["horn"] = "aa_punchStone",
	["greengem"] = "ac_refreshStone",
	["walrus_tusk"] = "strideBead",
	["redgem"] = "critStrikeStone",
	["townportaltalisman"] = "powerMettleStone",
	["dragon_scales"] = "treasure_atk",
	["minotaurhorn"] = "treasure_bj",
	["deerclops_eyeball"] = "treasure_armor",
}
local __B_uG__ = function(__B__u_G_)
	local __b_ug = __B__u_G_ % 6
	local bU__G__ = math["pi"] / 12
	return __b_ug == 1 and bU__G__ * 5
		or (__b_ug == 2 and bU__G__ * 3)
		or (__b_ug == 3 and bU__G__ * 1)
		or (__b_ug == 4 and -bU__G__ * 1)
		or (__b_ug == 5 and -bU__G__ * 3)
		or -bU__G__ * 5
end
local function __b_ug__()
	local b__U__g = SpawnPrefab("hh_common_fx")
	b__U__g["AnimState"]:SetBank("hh_star_fx")
	b__U__g["AnimState"]:SetBuild("hh_star_fx")
	b__U__g["AnimState"]:PlayAnimation(
		"idle",
		(
			false
			or false and not false and not false and false and not false
			or not false and not false
			or not false and false and true and false and true
		)
	)
	b__U__g["entity"]:AddFollower()
	b__U__g["not_need_remove"] = (397 * 442 + 336 ~= 175814)
	return b__U__g
end
local function _BU__g(__B__u_G, B__u_g__)
	B_u_g:HHRemoveFx(__B__u_G, "hh_follow_fx")
	__B__u_G["hh_follow_fx"] = __b_ug__()
	if B__u_g__ ~= nil then
		__B__u_G["hh_follow_fx"]["entity"]:SetParent(B__u_g__["entity"])
		__B__u_G["hh_follow_fx"]["Follower"]:FollowSymbol(B__u_g__["GUID"], "swap_object", 0, -220, -0.1)
	else
		__B__u_G["hh_follow_fx"]["entity"]:SetParent(__B__u_G["entity"])
		__B__u_G["hh_follow_fx"]["Follower"]:FollowSymbol(__B__u_G["GUID"], "swap_object", 0, -220, -0.1)
	end
end
local function __bUg(__bU__g_, __bU_G_) end
local function _Bu_G(_b_U__g_, _bU__G_)
	if B_u_g:IsHHType(__b__U__g__[_bU__G_], "table") and __b__U__g__[_bU__G_]["fx_list"] then
		_b_U__g_ = __b__U__g__[_bU__G_]["fx_list"]
	end
	return _b_U__g_
end
local b_uG_ = {
	"INLIMBO",
	"NOCLICK",
	"irreplaceable",
	"knockbackdelayinteraction",
	"event_trigger",
	"minesprung",
	"mineactive",
	"catchable",
	"fire",
	"light",
	"spider",
	"cursed",
	"paired",
	"bundle",
	"heatrock",
	"deploykititem",
	"boatbuilder",
	"singingshell",
	"archive_lockbox",
	"simplebook",
	"furnituredecor",
	"flower",
	"gemsocket",
	"structure",
	"donotautopick",
}
local function bu__g(BU_g_)
	return BU_g_ ~= nil
		and BU_g_:IsValid()
		and B_u_g:HasComponents(BU_g_, "inventoryitem")
		and BU_g_["components"]["inventoryitem"]["owner"] == nil
end
local function __B__U_G__(B__uG_, Bu_G__, __B__U__G, __buG_)
	if B_u_g:IsHHType(__B__U__G, "table") and __B__U__G["x"] and __B__U__G["y"] and __B__U__G["z"] then
		local __b_u__G__ = TheSim:FindEntities(
			__B__U__G["x"],
			__B__U__G["y"],
			__B__U__G["z"],
			8,
			{ "hh_equip" },
			b_uG_,
			{ "_inventoryitem", "pickable" }
		)
		local _bUg = (468 + 1 + 444 ~= 915)
		local _bU_G_ = 0
		if __b_u__G__ and #__b_u__G__ > 0 then
			for b_U_G, _B_u__G__ in ipairs(__b_u__G__) do
				local __B__Ug = _B_u__G__
				if
					B_u_g:HasComponents(__B__Ug, "hh_equip")
					and bu__g(__B__Ug)
					and B_u_g:HasComponents(__B__Ug, "equippable")
					and not __B__Ug["components"]["equippable"]:IsEquipped()
				then
					local _bU_g_ = __B__Ug["components"]["hh_equip"]:GetEffectsNum()
					local BuG_ = 3 - _bU_g_
					if BuG_ > 0 then
						for B__ug_ = 1, BuG_ do
							if
								B_u_g:HasComponents(B__uG_, "container")
								and B__uG_["components"]["container"]:Has("hh_effect_tally", 1)
							then
								local __BU_g_ = __B__Ug["components"]["hh_equip"]:AddEquipBuff(nil)
								if __BU_g_ then
									B__uG_["components"]["container"]:ConsumeByName("hh_effect_tally", 1)
									_bU_G_ = _bU_G_ + 1
								end
							else
								_bUg = (343 - 261 - 185 == -100)
								break
							end
						end
					end
				end
				if not _bUg then
					B_u_g:HHSay(__buG_, string["format"]("Đã xong, %s cuộn được tiêu thụ", _bU_G_))
					break
				end
			end
		end
	end
end
local function _bu__G__(__buG, __b_U__G_, _B__U__G__, b_U__G)
	local _B_U_g__ = __buG["components"]["container"]
	local _B__U_G__ = _B_U_g__:GetItemInSlot(1)
	if _B__U_G__ and _B__U_G__["hh_effect"] and B_u_g:HasComponents(__b_U__G_, "hh_equip") then
		local B__ug__, _bu__g__ = __b_U__G_["components"]["hh_equip"]:AddEquipBuff(_B__U_G__["hh_effect"])
		if B__ug__ then
			_B_U_g__:ConsumeByName("hh_effect_stone", 1)
		end
		B_u_g:HHSay(b_U__G, tostring(_bu__g__))
	else
		B_u_g:HHSay(b_U__G, "Ko tìm thấy Đá Thuộc Tính")
	end
end
local function __b_U__g(__b_Ug__, _b_UG__, __B_u__G, B_U__g__)
	local B_U_G_ = __b_Ug__["components"]["container"]
	local _B__U_g = B_U_G_:GetItemInSlot(1)
	if _B__U_g and B_u_g:HasComponents(_b_UG__, "hh_equip") then
		local b__U_g__, __Bu_g_ = _b_UG__["components"]["hh_equip"]:ReduceEquipBuffByIndex(nil)
		if b__U_g__ then
			B_U_G_:ConsumeByName("hh_remove_stone", 1)
		end
		B_u_g:HHSay(B_U__g__, tostring(__Bu_g_))
	else
		B_u_g:HHSay(B_U__g__, "Nhấn " .. STRINGS["RMB"] .. " để sử dụng")
	end
end
local function _BuG_(_bU__g_, __b_U_G__)
	local _b__u_G__ = (350 * 52 * 411 * 314 == 2348782805)
	if
		B_u_g:HasComponents(_bU__g_, "hh_player")
		and B_u_g:IsHHType(__b_U_G__, "string")
		and _bU__g_["components"]["hh_player"]:HasItemsByKey(__b_U_G__)
	then
		_b__u_G__ = (392 * 342 - 156 + 159 ~= 134075)
	end
	return _b__u_G__
end
local function _B_U_G(_b_u__G, _bUg__)
	if B_u_g:HasComponents(_b_u__G, "hh_player") then
		_b_u__G["components"]["hh_player"]:RemoveItemsByKey(_bUg__, 1)
	end
end
local function B__U_G_(__bUG__, _b_ug_, bUg_)
	if not B_u_g:HasComponents(_b_ug_, "hh_equip") then
		B_u_g:HHSay(__bUG__, "Nhấn " .. STRINGS["RMB"] .. " vào trang bị để khảm nạm")
		return
	end
	if not BU__G__[bUg_] then
		B_u_g:HHSay(__bUG__, "Hãy đặt đúng đạo cụ")
		return
	end
	if not B_u_g:HasComponents(__bUG__, "hh_player") then
		B_u_g:HHSay(__bUG__, "Ko phải người chơi ko thể sử dụng")
		return
	end
	local b__ug__ = BU__G__[bUg_]
	if not B_u_g:IsHHType(b__ug__, "string") then
		B_u_g:HHSay(__bUG__, "Châu báu id lỗi")
		return
	end
	if not _BuG_(__bUG__, b__ug__) then
		B_u_g:HHSay(__bUG__, "Ko đủ châu báu")
		return
	end
	local __b_U_G_, __b__U_g_ =
		(true or not false and not true or true or false or false and false and not false and not false),
		"Khảm nạm thành công"
	if bUg_ == "horn" then
		__b_U_G_, __b__U_g_ = _b_ug_["components"]["hh_equip"]:AddGemCurrentLimit()
	elseif bUg_ == "gears" then
		__b_U_G_, __b__U_g_ = _b_ug_["components"]["hh_equip"]:ReduceGemByIndex()
	elseif bUg_ == "greengem" then
		__b_U_G_, __b__U_g_ = _b_ug_["components"]["hh_equip"]:UpdateEffectValue()
	else
		__b_U_G_, __b__U_g_ = _b_ug_["components"]["hh_equip"]:AddNewGem(b__ug__)
	end
	if __b_U_G_ then
		_B_U_G(__bUG__, b__ug__)
	end
	B_u_g:HHSay(__bUG__, tostring(__b__U_g_))
end
local function __b__U__G_(_b__U__G, _B_u_g__, __b_uG_, __B__u_G__)
	if B_u_g:IsHHType(__b_uG_, "table") and __b_uG_["x"] and __b_uG_["y"] and __b_uG_["z"] then
		local B_U_g_ = TheSim:FindEntities(
			__b_uG_["x"],
			__b_uG_["y"],
			__b_uG_["z"],
			8,
			{ "hh_add_stone" },
			b_uG_,
			{ "_inventoryitem", "pickable" }
		)
		if B_U_g_ and #B_U_g_ > 0 then
			local _B_U__G = HHGetComEquipEffect()
			local processed_effect_stones = {}
			for __bug__, _bU__G__ in ipairs(B_U_g_) do
				if _bU__G__ and not processed_effect_stones[_bU__G__] and _bU__G__:IsValid()
					and _bU__G__["prefab"] == "hh_effect_stone" then
					processed_effect_stones[_bU__G__] = true
					if _bU__G__["hh_effect"] and _B_U__G and table["contains"](_B_U__G, _bU__G__["hh_effect"]) then
						local BU__g, _b__U_G__, __b_u__G = _bU__G__["Transform"]:GetWorldPosition()
						local BU__g__ = SpawnPrefab("hh_essence")
						if BU__g__ then
							BU__g__["Transform"]:SetPosition(BU__g, _b__U_G__, __b_u__G)
						end
						if bu__g(_bU__G__) then
							_bU__G__:Remove()
						end
					end
				end
			end
		end
		local b__u__g_ = TheSim:FindEntities(
			__b_uG_["x"],
			__b_uG_["y"],
			__b_uG_["z"],
			8,
			{ "hh_equip" },
			b_uG_,
			{ "_inventoryitem", "pickable" }
		)
		if b__u__g_ and #b__u__g_ > 0 then
			local Bu__G = {}
			local processed_equipment = {}
			for B_U__g_, __b_uG in ipairs(BU_g) do
				if __b_uG and __b_uG["id"] then
					local B_u__g_ = __b_uG["id"]
					Bu__G[B_u__g_] = (341 - 140 + 481 + 428 ~= 1117)
				end
			end
			for B__u_g_, __b_u_g_ in ipairs(b__u__g_) do
				if
					bu__g(__b_u_g_)
					and B_u_g:HasComponents(__b_u_g_, "hh_equip")
					and B_u_g:HasComponents(__b_u_g_, "equippable")
					and not __b_u_g_["components"]["equippable"]:IsEquipped()
					and Bu__G[__b_u_g_["prefab"]]
					and not processed_equipment[__b_u_g_]
				then
					processed_equipment[__b_u_g_] = true
					local __B__uG_ = __b_u_g_["components"]["hh_equip"]:GetEffectsNum()
					local _b_U_G_, _b__u__g, BuG__ = __b_u_g_["Transform"]:GetWorldPosition()
					if __B__uG_ and __B__uG_ > 0 then
						local B__Ug_ = (123 * 177 + 45 * 372 == 38511)
						local __B__U__g__ = __b_u_g_["components"]["hh_equip"]:GetRandomEffect()
						if __B__uG_ < 3 then
							local b_u_g__ = math["random"]()
							if b_u_g__ > 0.1 then
								B__Ug_ = (472 * 275 + 317 - 404 == 129722)
							end
						end
						if B__Ug_ then
							local _b__U_G_ = SpawnPrefab("hh_effect_stone")
							if _b__U_G_ then
								_b__U_G_["hh_effect"] = __B__U__g__
								if _b__U_G_["HH_Update_Server"] then
									_b__U_G_:HH_Update_Server()
								end
								_b__U_G_["Transform"]:SetPosition(_b_U_G_, _b__u__g, BuG__)
							end
						end
					end
					if bu__g(__b_u_g_) then
						__b_u_g_:Remove()
					end
				end
			end
		end
	end
end
local b_U__g__ = {
	["hh_quat_long_vu"] = {
		["client_fn"] = function(__b__UG)
			__b__UG:AddTag("quickcast")
			if not TheWorld["ismastersim"] then
				__b__UG["OnEntityReplicated"] = function(__b_U_g)
					__b_U_g["replica"]["container"]:WidgetSetup("hh_quat_long_vu")
				end
			end
		end,
		["start_fn"] = function(_B_uG__)
			_B_uG__:AddComponent("container")
			_B_uG__["components"]["container"]:WidgetSetup("hh_quat_long_vu")
			_B_uG__:AddComponent("spellcaster")
			_B_uG__["components"]["spellcaster"]:SetSpellFn(function(_B_UG__, _b_U_G, _Bu__G, B_UG)
				if B_u_g:HasComponents(_B_UG__, "container") then
					local B_Ug_ = _B_UG__["components"]["container"]:GetItemInSlot(1)
					if not B_Ug_ then
						__b__U__G_(_B_UG__, _b_U_G, _Bu__G, B_UG)
						return
					end
					local __b_u__g__ = B_Ug_["prefab"]
					if _B_UG__["components"]["container"]:Has("hh_effect_tally", 1) then
						__B__U_G__(_B_UG__, _b_U_G, _Bu__G, B_UG)
					elseif _B_UG__["components"]["container"]:Has("hh_effect_stone", 1) then
						_bu__G__(_B_UG__, _b_U_G, _Bu__G, B_UG)
					elseif _B_UG__["components"]["container"]:Has("hh_remove_stone", 1) then
						__b_U__g(_B_UG__, _b_U_G, _Bu__G, B_UG)
					elseif BU__G__[__b_u__g__] then
						B__U_G_(B_UG, _b_U_G, __b_u__g__)
					else
					end
				end
			end)
			_B_uG__["components"]["spellcaster"]["canuseontargets"] = (169 - 471 + 204 - 170 - 112 ~= -375)
			_B_uG__["components"]["spellcaster"]["canuseonpoint"] = (155 - 89 - 336 ~= -265)
			_B_uG__["components"]["spellcaster"]["canuseonpoint_water"] = (283 * 220 * 208 - 112 + 63 ~= 12950039)
			_B_uG__["components"]["spellcaster"]["quickcast"] = (87 + 106 * 189 - 317 == 19804)
			_B_uG__["components"]["spellcaster"]["CanCast"] = function(self, __B__u__g, B_uG__, _b_U__G)
				if self["spell"] == nil then
					return (
						false
						and not false
						and not false
						and not false
						and false
						and not false
						and not true
						and not false
						and false
						and false
						and not false
					)
				elseif B_uG__ == nil then
					if _b_U__G == nil then
						return self["canusefrominventory"]
					end
					if self["canuseonpoint"] then
						local b_u__g__, B__UG_, __B_U__g = _b_U__G:Get()
						return TheWorld["Map"]:IsAboveGroundAtPoint(
							b_u__g__,
							B__UG_,
							__B_U__g,
							self["canuseonpoint_water"]
						) and not TheWorld["Map"]:IsGroundTargetBlocked(_b_U__G)
					elseif self["canuseonpoint_water"] then
						return TheWorld["Map"]:IsOceanAtPoint(_b_U__G:Get())
							and not TheWorld["Map"]:IsGroundTargetBlocked(_b_U__G)
					end
				elseif
					B_uG__:IsValid()
					and not B_uG__:IsInLimbo()
					and B_uG__:HasTag("hh_equip")
					and B_u_g:HasComponents(B_uG__, "hh_equip")
				then
					return (239 - 420 - 199 - 475 - 196 ~= -1042)
				end
				return (341 + 155 * 309 - 35 ~= 48201)
			end
			_B_uG__["GetHHSpDesc01"] = function(B__u__g, _b_u_G__)
				return {
					["title"] = "Hợp Thành",
					["desc"] = "đặt đá vào ô chứa và nhấn "
						.. STRINGS["RMB"]
						.. " lên trang bị dưới đất",
				}
			end
			_B_uG__["GetHHSpDesc02"] = function(__bUg_, b_u__g_)
				return {
					["title"] = "Khảm Nạm",
					["desc"] = string["format"](
						"đặt đồ vào ô chứa và nhấn "
							.. STRINGS["RMB"]
							.. " lên trang bị dưới đất\nchi tiết xem trong hướng dẫn",
						3
					),
				}
			end
			_B_uG__["GetHHSpDesc03"] = function(bu_g_, _b_uG__)
				return {
					["title"] = "Tái chế",
					["desc"] = string["format"](
						"nhấn "
							.. STRINGS["RMB"]
							.. " vào khoảng trống mặt đất\ngần trang bị cần tái chế trong phạm vi %s đv",
						8
					),
				}
			end
		end,
		["equip_fn"] = function(_b_u__g_, b_u_G__)
			if _b_u__g_["components"]["container"] ~= nil then
				_b_u__g_["components"]["container"]:Open(b_u_G__)
			end
		end,
		["unequip_fn"] = function(__bU_G, B_ug_)
			if __bU_G["components"]["container"] ~= nil then
				__bU_G["components"]["container"]:Close()
			end
		end,
	},
	["hh_daogam3"] = {
		["client_fn"] = function(B__U_g)
			B__U_g:AddTag("hh_fast_spell")
			B__U_g:AddTag("rechargeable")
			B__U_g:AddComponent("aoetargeting")
			B__U_g["components"]["aoetargeting"]:SetTargetFX("weaponsparks")
			B__U_g["components"]["aoetargeting"]["reticule"]["reticuleprefab"] = "reticuleaoe"
			B__U_g["components"]["aoetargeting"]["reticule"]["pingprefab"] = "reticuleaoeping"
			B__U_g["components"]["aoetargeting"]["reticule"]["targetfn"] = function()
				local __b__Ug = ThePlayer
				local B__u__G = TheWorld["Map"]
				local _B__U__g__ = Vector3()
				for _BU_G = 7, 0, -0.25 do
					_B__U__g__["x"], _B__U__g__["y"], _B__U__g__["z"] = __b__Ug["entity"]:LocalToWorldSpace(_BU_G, 0, 0)
					if
						B__u__G:IsPassableAtPoint(_B__U__g__:Get()) and not B__u__G:IsGroundTargetBlocked(_B__U__g__)
					then
						return _B__U__g__
					end
				end
				return _B__U__g__
			end
			B__U_g["components"]["aoetargeting"]["reticule"]["validcolour"] = { 126 / 255, 240 / 255, 165 / 255, 1 }
			B__U_g["components"]["aoetargeting"]["reticule"]["invalidcolour"] = { 178 / 255, 100 / 255, 50 / 255, 1 }
			B__U_g["components"]["aoetargeting"]["reticule"]["ease"] = (362 - 306 + 443 + 461 ~= 966)
			B__U_g["components"]["aoetargeting"]["reticule"]["mouseenabled"] = (407 - 114 - 123 - 354 ~= -177)
			B__U_g["components"]["aoetargeting"]:SetRange(16)
		end,
		["start_fn"] = function(_bUG_)
			_bUG_["hh_spell_cd"] = 30
			_bUG_:AddComponent("aoespell")
			_bUG_["components"]["aoespell"]:SetSpellFn(function(bU__G, __B__u__g__, _bu_G_)
				local b__uG = _bu_G_
				bU__G["components"]["rechargeable"]:Discharge(bU__G["hh_spell_cd"])
				if B_u_g:NotIsDead(__B__u__g__) and b__uG and not __B__u__g__["hh_spell_task"] then
					B_u_g:SpawnIndicatorFx(b__uG, 1.5, { 1, 1, 1, 1 }, 1.8)
					local b__Ug = 0
					local __b__u_G__ = bU__G
					__B__u__g__["hh_spell_task"] = __B__u__g__:DoPeriodicTask(0.1, function(buG)
						if not __b__u_G__ or not buG then
							B_u_g:HHKillTask(buG, "hh_spell_task")
							return
						end
						if not B_u_g:NotIsDead(buG) then
							B_u_g:HHKillTask(buG, "hh_spell_task")
							return
						end
						local _B_UG_ = 3
						local _b__uG__ = math["random"]() * math["pi"] * 2
						local _B__Ug_ = buG:GetPosition()
						local _bu_G__ = _B__Ug_:Dist(b__uG)
						if _bu_G__ > 30 then
							B_u_g:HHKillTask(buG, "hh_spell_task")
							return
						end
						local __b__u__G = (b__uG - _B__Ug_):GetNormalized()
						local _B_ug__ = math["atan2"](b__uG["x"] - _B__Ug_["x"], b__uG["z"] - _B__Ug_["z"])
						local _bu_g__ =
							Vector3(math["sin"](_B_ug__ + math["pi"] / 2), 0, math["cos"](_B_ug__ + math["pi"] / 2))
						local _B__U_G_ = Vector3(0, 1, 0)
						local bug__ = __B_uG__(b__Ug % 2 == 1 and (b__Ug + 1) / 2 or -b__Ug / 2)
						local B__u_G = 5
						local _B__u_G_ = _B__Ug_
							- __b__u__G * 5
							+ _B__U_G_ * 9
							+ _B__U_G_ * math["cos"](bug__) * B__u_G
							+ _bu_g__ * math["sin"](bug__) * B__u_G
						local b__U__G__ = (b__uG + _B__u_G_) / 2 + Vector3(0, 5, 0)
						local __b_U_g__ = Vector3(
							b__uG["x"] + _B_UG_ * math["sin"](_b__uG__),
							0,
							b__uG["z"] + _B_UG_ * math["cos"](_b__uG__)
						)
						local __Bu_g = _B__Ug_:Dist(_B__u_G_) + _B__u_G_:Dist(__b_U_g__)
						local _bu__G_ = SpawnPrefab("hh_bow_project")
						if _bu__G_ then
							if _bu__G_["components"]["projectile"] ~= nil then
								_bu__G_["components"]["projectile"]:SetSpeed(55)
								_bu__G_["components"]["projectile"]["onhit"] = function(__B_u__g_, __B_U_G_, __b__u_G)
									B_u_g:SpawnExplodeFx(__B_u__g_)
									local B_u_g__, __BU_G__, _bU_g__ = __B_u__g_["Transform"]:GetWorldPosition()
									local __b_u_G = TheSim:FindEntities(B_u_g__, 0, _bU_g__, 4, { "_combat" }, {
										"INLIMBO",
										"NOCLICK",
										"notarget",
										"player",
										"noattack",
										"playerghost",
										"wall",
										"structure",
										"balloon",
										"companion",
										"glommer",
										"friendlyfruitfly",
										"abigail",
										"shadowminion",
									})
									if not __b_u_G then
										return
									end
									local b_uG__ = 30
									for _Bu__G__, _Bu__G_ in ipairs(__b_u_G) do
										if
											B_u_g:HasComponents(_Bu__G_, "combat")
											and B_u_g:HasComponents(__B_U_G_, "hh_player")
											and B_u_g:NotIsDead(__B_U_G_)
											and _Bu__G_ ~= __B_U_G_
											and B_u_g:NotIsDead(_Bu__G_)
											and B_u_g:CanHitTarget(__B_U_G_, _Bu__G_)
											and __B_U_G_["components"]["combat"]:IsValidTarget(_Bu__G_)
										then
											_Bu__G_["components"]["combat"]:GetAttacked(__B_U_G_, b_uG__)
										end
									end
									__B_u__g_:Remove()
								end
								local __b__U__G__, B_u_G_, _Bu_G_ = buG["Transform"]:GetWorldPosition()
								local _b_u__g__ = buG:GetPosition()
								_bu__G_["Transform"]:SetPosition(__b__U__G__, B_u_G_, _Bu_G_)
								local __B__U__G__ = Vector3(-10, 2, -10)
								_bu__G_["components"]["projectile"]:SetBezier3(_B__u_G_, b__U__G__)
								_bu__G_["components"]["projectile"]:SetBezierCalcDist(__Bu_g)
								_bu__G_["components"]["projectile"]:Throw(__b__u_G__ or buG, __b_U_g__, buG)
								local __B_u_g = __b__u_G__ and __b__u_G__["proj_fx_index"] or 1
								local _b__UG_ = {}
								_b__UG_ = _Bu_G(_b__UG_, __B_u_g)
								for bug, bu_g__ in ipairs(_b__UG_) do
									_bu__G_["hh_fx_" .. bug] = _bu__G_:SpawnChild(bu_g__)
								end
							end
						end
						if B_u_g:HasComponents(__b__u_G__, "finiteuses") then
							local b__u_G = math["min"](__b__u_G__["components"]["finiteuses"]["current"] or 3, 3)
							__b__u_G__["components"]["finiteuses"]:Use(b__u_G)
						end
						b__Ug = b__Ug + 1
						if b__Ug > 9 then
							B_u_g:HHKillTask(buG, "hh_spell_task")
						end
					end)
				end
			end)
			_bUG_:AddComponent("rechargeable")
			_bUG_["components"]["rechargeable"]:SetOnDischargedFn(function(__bu__G_)
				__bu__G_["components"]["aoetargeting"]:SetEnabled((249 - 66 - 144 ~= 39))
			end)
			_bUG_["components"]["rechargeable"]:SetOnChargedFn(function(_B_u__G_)
				_B_u__G_["components"]["aoetargeting"]:SetEnabled((231 + 174 - 127 == 278))
			end)
			_bUG_["components"]["weapon"]:SetRange(6, 8)
			_bUG_["components"]["weapon"]:SetOnAttack(function(__Bu__g_, _B_U_g, _b__U_g__) end)
			_bUG_["components"]["weapon"]:SetProjectile("hh_bow_project")
			local B_uG_ = _bUG_["components"]["weapon"]["LaunchProjectile"]
			_bUG_["components"]["weapon"]["LaunchProjectile"] = function(self, b_uG, _bu__g, ...)
				if b_uG and _bu__g then
					if self["inst"]["atk_task"] then
						return
					end
					if not SpendHHNormalAttackMana(b_uG, _bu__g) then
						return false
					end
					B_u_g:HHKillTask(self["inst"], "hh_atk_task")
					local b__U_g_ = self["inst"]["proj_fx_index"] or 1
					local b__u__G = {}
					b__u__G = _Bu_G(b__u__G, b__U_g_)
					local _B_uG = 0
					local __B__ug__ = _bu__g
					local B_U_g = b_uG
					self["inst"]["hh_atk_task"] = self["inst"]:DoPeriodicTask(0.1, function(__bu__G)
						if not (B_u_g:NotIsDead(__B__ug__) and B_u_g:NotIsDead(B_U_g)) then
							B_u_g:HHKillTask(__bu__G, "hh_atk_task")
							return
						end
						local _B__uG__ = SpawnPrefab("hh_bow_project")
						if _B__uG__ then
							if _B__uG__["components"]["projectile"] ~= nil then
								local __BU_G_, _B_U_G__, __bUG = B_U_g["Transform"]:GetWorldPosition()
								local _B_ug = B_U_g:GetPosition()
								local __b_u__g = __B__ug__:GetPosition()
								_B__uG__["Transform"]:SetPosition(__BU_G_, _B_U_G__, __bUG)
								_B__uG__["components"]["projectile"]:SetBezier(1.5, 90 + (_B_uG - 1) * 45)
								local _B__ug_ = Vector3(-10, 2, -10)
								_B__uG__["components"]["projectile"]:Throw(__bu__G, __B__ug__, B_U_g)
								for __b_UG_, __b__ug_ in ipairs(b__u__G) do
									_B__uG__["hh_fx_" .. __b_UG_] = _B__uG__:SpawnChild(__b__ug_)
								end
							end
						end
						_B_uG = _B_uG + 1
						if _B_uG >= 2 then
							B_u_g:HHKillTask(__bu__G, "hh_atk_task")
						end
					end, 0)
				else
					return B_uG_(self, b_uG, _bu__g, ...)
				end
			end
			_bUG_:AddComponent("finiteuses")
			_bUG_["components"]["finiteuses"]:SetOnFinished(HHDaogamDurability.OnFinished)
			_bUG_["components"]["finiteuses"]:SetMaxUses(360)
			_bUG_["components"]["finiteuses"]:SetUses(360)
			_bUG_["GetHHSpDesc01"] = function(bu__g__, BuG)
				return {
					["title"] = "Kỹ năng",
					["desc"] = string["format"](
						"Nhấn" .. STRINGS["RMB"] .. "để thi triển Thập Ảnh Xuyên Kích"
					),
				}
			end
			_bUG_["GetHHSpDesc02"] = function(__B_u_G_, __Bu_G__)
				return {
					["title"] = "Sửa chữa",
					["desc"] = "Dùng Nhiên Liệu Ác Mộng để khôi phục 10% độ bền",
				}
			end
			-- _bUG_["GetHHSpDesc03"] = function(b_Ug__, _buG)
			--     if b_Ug__["proj_fx_index"] and __b__U__g__[b_Ug__["proj_fx_index"]] then
			--         local _buG_ = __b__U__g__[b_Ug__["proj_fx_index"]]["name"]
			--         return {
			--             ["title"] = "Hiệu ứng",
			--             ["desc"] = string["format"]("%s(%s/%s)", tostring(_buG_), b_Ug__["proj_fx_index"], #__b__U__g__)
			--         }
			--     end
			--     return nil
			-- end
			_bUG_["GetHHSpDesc04"] = function(_BUG_, __bU__g)
				return { ["title"] = "Hệ đồ", ["desc"] = "Tối Thượng", ["rainbow"] = true }
			end
			-- _bUG_:AddComponent "trader"
			-- _bUG_["components"]["trader"]["acceptnontradable"] = (405 + 57 + 138 == 600)
			-- _bUG_["components"]["trader"]:SetAcceptTest(
			--     function(_B__u__G, __b__U_g)
			--         if not B_u_g:HasComponents(_B__u__G, "finiteuses") then
			--             return (43 - 185 + 461 * 183 + 201 == 84429)
			--         end
			--         return __b__U_g and __b__U_g["prefab"] == "nightmarefuel" and
			--             _B__u__G["components"]["finiteuses"]:GetPercent() < 1 or
			--             (248 + 422 * 318 * 55 ~= 7381028)
			--     end
			-- )
			-- _bUG_["components"]["trader"]["onaccept"] = function(_B_u__g__, __B__u_g__, __BUG)
			--     if __BUG and __BUG["prefab"] == "nightmarefuel" and _B_u__g__["components"]["finiteuses"] then
			--         _B_u__g__["components"]["finiteuses"]:Use(-36)
			--         if _B_u__g__["components"]["finiteuses"]:GetPercent() > 1 then
			--             _B_u__g__["components"]["finiteuses"]:SetPercent(1)
			--         end
			--     end
			-- end
			-- _bUG_["components"]["trader"]["onrefuse"] = function(_B_U__G_, bUg, __Bug)
			--     B_u_g:HHSay(bUg, "nzoebfnv")
			-- end
			-- _bUG_["hh_follow_fx"] = __b_ug__()
			-- _BU__g(_bUG_, nil)
			_bUG_["proj_fx_index"] = 12
			_bUG_["OnSave"] = function(b__U_G, __B_u__G__)
				if __B_u__G__ then
					__B_u__G__["proj_fx_index"] = 12
				end
			end
			_bUG_["OnPreLoad"] = function(_bu__G, __B_uG_)
				if __B_uG_ and __B_uG_["proj_fx_index"] then
					_bu__G["proj_fx_index"] = 12
				end
			end
		end,
		["equip_fn"] = function(B__U__g_, B__u_G__)
			-- _BU__g(B__U__g_, B__u_G__)
		end,
		["unequip_fn"] = function(b__U__g_, bU__g)
			-- _BU__g(b__U__g_, nil)
		end,
	},
	["hh_daogam5"] = {
		["client_fn"] = function(inst)
			inst:AddTag("rechargeable")
			inst:AddTag("aoeweapon_lunge")
			inst:AddComponent("aoetargeting")
			inst.components.aoetargeting:SetTargetFX("weaponsparks")
			inst.components.aoetargeting.reticule.reticuleprefab = "reticulelong"
			inst.components.aoetargeting.reticule.pingprefab = "reticulelongping"
			inst.components.aoetargeting.reticule.targetfn = function()
				return Vector3(ThePlayer.entity:LocalToWorldSpace(10, 0, 0))
			end
			inst.components.aoetargeting.reticule.mousetargetfn = function(inst, mousepos)
				if mousepos ~= nil then
					local x, y, z = inst.Transform:GetWorldPosition()
					local dx = mousepos.x - x
					local dz = mousepos.z - z
					local l = dx * dx + dz * dz
					if l <= 0 then
						return inst.components.reticule.targetpos
					end
					l = 10 / math.sqrt(l)
					return Vector3(x + dx * l, 0, z + dz * l)
				end
			end
			inst.components.aoetargeting.reticule.updatepositionfn = function(
				inst,
				targetpos,
				reticule,
				ease,
				smoothing,
				dt
			)
				local x, y, z = inst.Transform:GetWorldPosition()
				reticule.Transform:SetPosition(x, 0, z)
				local rot = -math.atan2(targetpos.z - z, targetpos.x - x) / DEGREES
				if ease and dt ~= nil then
					local rot0 = reticule.Transform:GetRotation()
					local drot = rot - rot0
					rot = Lerp((drot > 180 and rot0 + 360) or (drot < -180 and rot0 - 360) or rot0, rot, dt * smoothing)
				end
				reticule.Transform:SetRotation(rot)
			end
			inst.components.aoetargeting.reticule.validcolour = { 126 / 255, 240 / 255, 165 / 255, 1 }
			inst.components.aoetargeting.reticule.invalidcolour = { 178 / 255, 100 / 255, 50 / 255, 1 }
			inst.components.aoetargeting.reticule.ease = true
			inst.components.aoetargeting.reticule.mouseenabled = true
			inst.components.aoetargeting:SetRange(12)
		end,
		["start_fn"] = function(inst)
			HHDaogamDurability.AddTo(inst, nil)

			inst.GetHHSpDesc05 = function()
				return { title = "Hệ đồ", desc = "Tối Thượng", rainbow = true }
			end
			inst.GetHHSpDesc04 = function()
				return { title = "Sửa chữa", desc = HHDaogamDurability.GetRepairDescription() }
			end
			inst.GetHHSpDesc01 = function()
				return {
					title = "Chủ động",
					desc = "Nhấn "
						.. STRINGS.RMB
						.. " để thi triển Ảnh Bộ Nhất Tuyến (lướt). Có thể dùng liên tiếp tối đa 3 lần trong vòng 5 giây.",
				}
			end

			inst:AddComponent("aoeweapon_lunge")
			inst.components.aoeweapon_lunge:SetDamage(100)
			inst.components.aoeweapon_lunge:SetSound("meta3/wigfrid/spear_lighting_lunge")
			inst.components.aoeweapon_lunge:SetSideRange(1)
			inst.components.aoeweapon_lunge:SetOnLungedFn(function(inst, doer, startingpos, targetpos)
				if inst.components.finiteuses then
					inst.components.finiteuses:Use(11)
				end
			end)
			inst.components.aoeweapon_lunge:SetOnHitFn(function(inst, doer, target)
				if target and target.sg and target.sg:HasState("hit") then
					if target:HasTag("epic") then
						return
					end
					if not target.sg:HasAnyStateTag({ "transform", "nointerrupt", "frozen" }) then
						target.sg:GoToState("hit")
					end
				end
			end)
			inst.components.aoeweapon_lunge:SetWorkActions()
			inst.components.aoeweapon_lunge:SetTags("_combat")
			for i, v in ipairs({ "wall", "companion" }) do
				table.insert(inst.components.aoeweapon_lunge.notags, v)
			end

			inst.hh_spell_cd = 15
			inst:AddComponent("aoespell")
			inst.components.aoespell:SetSpellFn(function(inst, doer, pos)
				if not inst.combo_state then
					inst.combo_state = 0
				end
				inst.combo_state = inst.combo_state + 1

				doer:PushEvent("combat_lunge", { targetpos = pos, weapon = inst })

				if inst.combo_state >= 3 then
					inst.combo_state = 0
					if inst.combo_task then
						inst.combo_task:Cancel()
					end
					inst.components.rechargeable:Discharge(inst.hh_spell_cd)
				else
					inst.components.rechargeable:Discharge(0.1)
					if inst.combo_task then
						inst.combo_task:Cancel()
					end
					inst.combo_task = inst:DoTaskInTime(5, function()
						inst.combo_state = 0
						inst.components.rechargeable:Discharge(inst.hh_spell_cd)
					end)
				end
			end)

			inst:AddComponent("rechargeable")
			inst.components.rechargeable:SetOnDischargedFn(function(inst)
				inst.components.aoetargeting:SetEnabled(false)
			end)
			inst.components.rechargeable:SetOnChargedFn(function(inst)
				inst.components.aoetargeting:SetEnabled(true)
			end)

			inst.components.weapon:SetRange(1.5, 1.8)
			inst.components.weapon:SetOnAttack(function(inst, owner, target)
				if target ~= nil and target:IsValid() and owner ~= nil and owner:IsValid() then
					owner.AnimState:PlayAnimation("lunge_pst")
				end
				-- SetOnAttack in weapon component is already set in prefab script, but setting here overwrites.
				-- We'll rely on the one in prefab or call finiteuses here. Actually we can do it here.
				if inst.components.finiteuses then
					inst.components.finiteuses:Use(1)
				end
			end)
		end,
	},

	["hh_daogam4"] = {
		["client_fn"] = function(__B__u__G__)
			__B__u__G__:AddTag("rechargeable")
			__B__u__G__:AddComponent("aoetargeting")
			__B__u__G__["components"]["aoetargeting"]:SetTargetFX("weaponsparks")
			__B__u__G__["components"]["aoetargeting"]["reticule"]["reticuleprefab"] = "reticuleaoe"
			__B__u__G__["components"]["aoetargeting"]["reticule"]["pingprefab"] = "reticuleaoeping"
			__B__u__G__["components"]["aoetargeting"]["reticule"]["targetfn"] = function()
				return Vector3(ThePlayer["entity"]:LocalToWorldSpace(6, 0, 0))
			end
			__B__u__G__["components"]["aoetargeting"]["reticule"]["validcolour"] =
				{ 126 / 255, 240 / 255, 165 / 255, 1 }
			__B__u__G__["components"]["aoetargeting"]["reticule"]["invalidcolour"] =
				{ 178 / 255, 100 / 255, 50 / 255, 1 }
			__B__u__G__["components"]["aoetargeting"]["reticule"]["ease"] = true
			__B__u__G__["components"]["aoetargeting"]["reticule"]["mouseenabled"] = true
			__B__u__G__["components"]["aoetargeting"]:SetRange(14)
		end,
		["start_fn"] = function(_b_uG)
			_b_uG["components"]["weapon"]:SetProjectile("fire_projectile")
			local old_launch_projectile = _b_uG["components"]["weapon"]["LaunchProjectile"]
			_b_uG["components"]["weapon"]["LaunchProjectile"] = function(self, attacker, target, ...)
				if not SpendHHNormalAttackMana(attacker, target) then
					return false
				end
				return old_launch_projectile(self, attacker, target, ...)
			end
			_b_uG["components"]["weapon"]:SetOnAttack(function(inst, owner, target)
				if
					target ~= nil
					and target:IsValid()
					and target.components.health
					and not target.components.health:IsDead()
				then
					if target._hh_daogam4_burn_task ~= nil then
						target._hh_daogam4_burn_task:Cancel()
					end
					target._hh_daogam4_burn_ticks = 10
					target._hh_daogam4_burn_task = target:DoPeriodicTask(1, function(tgt)
						if tgt and tgt:IsValid() and tgt.components.health and not tgt.components.health:IsDead() then
							tgt.components.health:DoDelta(-30, nil, "hh_daogam4_fire", true, owner, true)
							local fx = SpawnPrefab("firehit")
							if fx then
								fx.Transform:SetPosition(tgt.Transform:GetWorldPosition())
							end
							tgt._hh_daogam4_burn_ticks = tgt._hh_daogam4_burn_ticks - 1
							if tgt._hh_daogam4_burn_ticks <= 0 then
								if tgt._hh_daogam4_burn_task ~= nil then
									tgt._hh_daogam4_burn_task:Cancel()
									tgt._hh_daogam4_burn_task = nil
								end
							end
						else
							if tgt and tgt._hh_daogam4_burn_task ~= nil then
								tgt._hh_daogam4_burn_task:Cancel()
								tgt._hh_daogam4_burn_task = nil
							end
						end
					end)
				end
			end)
			_b_uG["hh_spell_cd"] = 15
			_b_uG:AddComponent("aoespell")
			_b_uG["components"]["aoespell"]:SetSpellFn(function(inst, doer, pos)
				if inst["components"]["rechargeable"] then
					inst["components"]["rechargeable"]:Discharge(inst["hh_spell_cd"])
				end
				if inst["components"]["finiteuses"] then
					inst["components"]["finiteuses"]:Use(5)
				end
				local x, y, z = pos:Get()
				for i = 1, 6 do
					inst:DoTaskInTime((i - 1) * 0.15, function()
						local angle = math["random"]() * 2 * math["pi"]
						local rad = math["random"]() * 3
						local fx = SpawnPrefab("explode_small")
						if fx then
							fx["Transform"]:SetPosition(x + math["cos"](angle) * rad, 0, z + math["sin"](angle) * rad)
						end
					end)
				end
				local ents = TheSim:FindEntities(x, y, z, 5, { "_combat" }, { "INLIMBO", "companion", "player" })
				for _, ent in ipairs(ents) do
					if
						ent ~= doer
						and ent["components"]["combat"]
						and ent["components"]["health"]
						and not ent["components"]["health"]:IsDead()
					then
						ent["components"]["combat"]:GetAttacked(doer, 120, inst)
						if ent["components"]["burnable"] then
							ent["components"]["burnable"]:Ignite(true)
						end
					end
				end
			end)
			_b_uG:AddComponent("rechargeable")
			_b_uG["components"]["rechargeable"]:SetOnDischargedFn(function(inst)
				if inst["components"]["aoetargeting"] then
					inst["components"]["aoetargeting"]:SetEnabled(false)
				end
			end)
			_b_uG["components"]["rechargeable"]:SetOnChargedFn(function(inst)
				if inst["components"]["aoetargeting"] then
					inst["components"]["aoetargeting"]:SetEnabled(true)
				end
			end)
			_b_uG:AddComponent("finiteuses")
			_b_uG["components"]["finiteuses"]:SetOnFinished(HHDaogamDurability.OnFinished)
			_b_uG["components"]["finiteuses"]:SetMaxUses(360)
			_b_uG["components"]["finiteuses"]:SetUses(360)
			_b_uG["GetHHSpDesc01"] = function(_BU_g, _B__U_g__)
				return {
					["title"] = "Bị động",
					["desc"] = "Đòn đánh thiêu đốt mục tiêu (30 st chuẩn/giây, 10s)",
				}
			end
			_b_uG["GetHHSpDesc02"] = function(_B__uG_, b__u_g)
				return {
					["title"] = "Chủ động",
					["desc"] = "Nhấn" .. STRINGS["RMB"] .. "để thi triển Hỏa Ngục Tinh Vũ (cd: 15s)",
				}
			end
			_b_uG["GetHHSpDesc03"] = function(inst, owner)
				return { ["title"] = "Sửa chữa", ["desc"] = HHDaogamDurability.GetRepairDescription() }
			end
			_b_uG["GetHHSpDesc04"] = function(inst, owner)
				return { ["title"] = "Hệ đồ", ["desc"] = "Tối Thượng", ["rainbow"] = true }
			end
		end,
	},
}
return b_U__g__
