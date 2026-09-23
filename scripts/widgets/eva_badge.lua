local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

local soulbadge = Class(Badge, function(self, owner)
    Badge._ctor(self, "soul", owner)

	if TUNING.EVA_HUD then
		self.backing = self.underNumber:AddChild(UIAnim())
		self.backing:GetAnimState():SetBank("status_meter")
		self.backing:GetAnimState():SetBuild("status_meter_soul")
		self.backing:GetAnimState():PlayAnimation("bg")
	else
		self.backing = self.underNumber:AddChild(UIAnim())
		self.backing:GetAnimState():SetBank("status_meter")
		self.backing:GetAnimState():SetBuild("status_meter")
		self.backing:GetAnimState():PlayAnimation("bg")
	end
	self.anim = self.underNumber:AddChild(UIAnim())
	self.anim:GetAnimState():SetBank("status_meter_soul")
	self.anim:GetAnimState():SetBuild("status_meter_soul")
	self.anim:GetAnimState():PlayAnimation("anim")
	
	self.darksoul = self.underNumber:AddChild(Image("images/souls/darksoul_0.xml", "darksoul_0.tex"))

	if TUNING.EVA_HUD then
		self.circleframe = self.underNumber:AddChild(UIAnim())
		self.circleframe:GetAnimState():SetBank("status_meter")
		self.circleframe:GetAnimState():SetBuild("status_meter_soul")
		self.circleframe:GetAnimState():PlayAnimation("frame")
	else
		self.circleframe = self.underNumber:AddChild(UIAnim())
		self.circleframe:GetAnimState():SetBank("status_meter")
		self.circleframe:GetAnimState():SetBuild("status_meter")
		self.circleframe:GetAnimState():PlayAnimation("frame")
	end

	local darksoul = 0
	self.darksoul:SetScale(darksoul, darksoul, darksoul)
	self.darksoul:SetPosition(0, 0, 0)

	self.num = self:AddChild(Text(BODYTEXTFONT, 33))
    self.num:SetHAlign(ANCHOR_MIDDLE)
    self.num:SetPosition(3, 0, 0)
    self.num:Hide()
    self:StartUpdating()
end)
function soulbadge:SetPercent(val, max)
	max = max or 100
	val = val or 0
	self.anim:GetAnimState():SetPercent("anim", 1 - val)

	local darksoul = 0.85 * val
	if val > 0.75 then
		self.darksoul:SetTexture("images/souls/darksoul_0.xml", "darksoul_0.tex")	
	elseif val>0.5 then
		self.darksoul:SetTexture("images/souls/darksoul_1.xml", "darksoul_1.tex")	
	elseif val>0.25 then
		self.darksoul:SetTexture("images/souls/darksoul_2.xml", "darksoul_2.tex")	
		darksoul = darksoul  * 1.3
	else
		self.darksoul:SetTexture("images/souls/darksoul_3.xml", "darksoul_3.tex")	
		darksoul = darksoul  * 2
	end
	self.darksoul:SetScale(darksoul, darksoul, darksoul)

	self.num:SetString(tostring(math.ceil(val * max)))
	
	if KnownModIndex:IsModEnabled("workshop-376333686") then
		self.num:Show()
		self.num:SetPosition(1, -40, 0)
		self.num:SetScale(.75, .75, .75)
		if self.show_progress then
			if self.show_remaining then
				self.maxnum:SetString(tostring(math.floor(val * max)))
			end
		else
			self.maxnum:SetString(tostring(max))
		end
	else
		self.num:SetPosition(3, 0, 0)
	end
end
function soulbadge:OnUpdate(dt)

end

return soulbadge
