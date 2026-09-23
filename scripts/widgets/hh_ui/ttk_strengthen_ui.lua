local Widget = require('widgets/widget')
local Image = require('widgets/image')
local Text = require('widgets/text')
local ImageButton = require('widgets/imagebutton')
local Theme = require('widgets/hh_ui/ttk_unified_theme')
local FS = 97 / 80
local function Font() return Theme.GetFont() end
local SKIN = 'images/ttk_forge/controls.xml'
local WHITE, BLUE, MUTED = {.92,.96,1,1}, {.48,.80,1,1}, {.66,.73,.82,1}
local WARN = {1,.71,.40,1}

local function Label(parent, text, x, y, size, colour)
    local t = parent:AddChild(Text(Font(), size * FS, text, colour or WHITE))
    t:SetPosition(x,y); t:SetClickable(false)
    return t
end
local function Skin(parent, name, x,y,w,h)
    local i = parent:AddChild(Image(SKIN, name..'.tex'))
    i:SetPosition(x,y); i:SetSize(w,h); i:SetTint(.68,.88,1,1)
    i:SetClickable(false)
    return i
end
local function Line(parent,x,y,w,h)
    local i=parent:AddChild(Image('images/hh_icon/hh_white.xml','hh_white.tex'))
    i:SetSize(w,h); i:SetPosition(x,y); i:SetTint(.36,.51,.65,.8); i:SetClickable(false)
end
local function Button(parent,text,x,y,w,h,fn)
    local b=parent:AddChild(ImageButton(SKIN,'primary.tex'))
    b:SetPosition(x,y); b:ForceImageSize(w,h)
    b:SetNormalScale(1); b:SetFocusScale(1.015)
    b:SetFont(Font()); b:SetDisabledFont(Font()); b:SetTextSize(25*FS); b:SetText(text)
    b:SetTextColour(unpack(WHITE)); b:SetTextFocusColour(1,1,1,1)
    b:SetTextDisabledColour(.48,.56,.65,1)
    b:SetImageNormalColour(.60,.85,1,1); b:SetImageFocusColour(.75,.95,1,1)
    b:SetImageDisabledColour(.40,.49,.60,1)
    b.text:SetPosition(0,4); b:SetOnClick(fn)
    return b
end
local function Number(n) return string.format('%.2f',tonumber(n) or 0):gsub('0+$',''):gsub('%.$','') end

local StrengthenUI=Class(Widget,function(self,owner,container)
    Widget._ctor(self,'Lam Phượng Luyện Khí Đài')
    self.owner,self.container=owner,container
    self.frame=self:AddChild(Image('images/ttk_forge/frame.xml','frame.tex'))
    self.frame:SetSize(900,600); self.frame:SetTint(.72,.90,1,1)
    Label(self,'LAM PHƯỢNG LUYỆN KHÍ ĐÀI',0,239,30)
    Label(self,'CƯỜNG HÓA TRANG BỊ',0,188,22,BLUE)
    Line(self,0,156,780,1); Line(self,-95,-9,1,293)
    Skin(self,'diamond',-95,138,10,10); Skin(self,'diamond',-95,-156,10,10)
    Label(self,'TRANG BỊ',-245,124,20,BLUE)
    Skin(self,'slot',-245,35,120,118)
    self.empty=Label(self,'?',-245,35,40,MUTED)
    self.name=Label(self,'Đặt trang bị vào ô',-245,-51,21)
    Label(self,'Kéo trang bị vào ô phía trên',-245,-87,16,MUTED)
    Label(self,'Giới hạn cường hóa: +13',-245,-117,17,BLUE)
    Label(self,'HIỆN TẠI',65,124,19,MUTED)
    Label(self,'SAU CƯỜNG HÓA',275,124,19,BLUE)
    self.current=Label(self,'—',65,77,32)
    Label(self,'→',166,77,24,BLUE)
    self.next=Label(self,'—',275,77,32,BLUE)
    self.stats=Label(self,'Đặt trang bị để xem chỉ số',170,10,20)
    self.passives=Label(self,'',170,-49,17,MUTED)
    self.probability=Label(self,'Tỷ lệ thành công: —',170,-102,22,BLUE)
    Line(self,0,-157,780,1)
    Skin(self,'slot',-336,-201,60,60)
    self.gem=self:AddChild(Image('images/lucky_gem.xml','lucky_gem.tex'))
    self.gem:SetPosition(-336,-201); self.gem:SetSize(44,44); self.gem:SetClickable(false)
    Label(self,'Đá Cường Hóa',-207,-184,18)
    self.cost=Label(self,'0 / —',-207,-209,19,MUTED)
    self.warning=Label(self,'',142,-193,17,WARN)
    self.status=Label(self,'Đặt trang bị để bắt đầu',0,-235,16,MUTED)
    self.action=Button(self,'CƯỜNG HÓA',0,-273,290,51,function() self:Submit() end)
    self.close=Button(self,'×',388,235,30,30,function() container.replica.container:Close() end)
    self.close:SetTextures(SKIN,'slot.tex')
    self.ready=false; self.action:Disable()
end)

function StrengthenUI:AttachContainerWidget(native)
    local slot=native.inv[1]
    slot:SetPosition(-245,35); slot:SetScale(1.3)
    slot.base_scale,slot.highlight_scale=1.3,1.3
    slot.bgimage:SetTexture(SKIN,'slot.tex'); slot.bgimage:SetSize(90,88)
    slot.bgimage:SetTint(.68,.88,1,1)
    slot:SetHoverText('Trang bị cần cường hóa',{font=Font(),font_size=18*FS})
    slot:SetOnTileChangedFn(function() self:Refresh(self.data) end)
    slot:MoveToFront()
end

function StrengthenUI:ViewState(data,item)
    data=data or {}
    if not item or not item.Network or data.item_id~=tostring(item.Network:GetNetworkID()) then
        return 'empty'
    end
    local level=tonumber(data.c_level) or 0
    if level>=13 then return 'maxed' end
    if level+1>=10 and data.has_protection then return 'protected' end
    return 'ready'
end

function StrengthenUI:Refresh(data)
    data=data or {}; self.data=data
    if self.pending and data.revision and self.pending~=data.revision then self.pending=nil end
    local item=self.container.replica.container:GetItemInSlot(1)
    local synced=item and item.Network and data.item_id==tostring(item.Network:GetNetworkID())
    local level=tonumber(data.c_level) or 0
    local target=level+1
    local gems=tonumber(data.redgem_count) or 0
    local maxed=synced and level>=13
    self.ready=synced and not maxed and data.revision~=nil and gems>=target and not self.pending or false
    if item then self.empty:Hide() else self.empty:Show() end
    self.name:SetTruncatedString(synced and data.name or (item and 'Đang kiểm tra trang bị…' or 'Đặt trang bị vào ô'),260,nil,true)
    self.current:SetString(synced and '+'..level or '—')
    self.next:SetString(synced and (maxed and 'TỐI ĐA' or '+'..target) or '—')
    local stat='Đặt trang bị để xem chỉ số'
    if synced then
        if data.isweapon then
            stat='Sát thương\n'..Number(data.c_damage)..'   →   '..Number(maxed and data.c_damage or data.n_damage)
        elseif data.isarmor then
            stat='Hấp thụ sát thương\n'..Number((data.c_absorb_percent or 0)*100)..'%   →   '..Number((maxed and data.c_absorb_percent or data.n_absorb_percent or 0)*100)..'%'
        else stat='Cấp cường hóa trang bị' end
    end
    self.stats:SetString(stat)
    self.passives:SetString(synced and ('Nội tại: '..(data.c_prizebuff_count or 0)..' → '..(maxed and (data.c_prizebuff_count or 0) or (data.n_prizebuff_count or 0))) or '')
    self.probability:SetString(maxed and 'Đã đạt cấp cao nhất' or ('Tỷ lệ thành công: '..(synced and data.probability and Number(math.min(1,math.max(0,data.probability))*100)..'%' or '—')))
    self.cost:SetString(synced and (maxed and 'Không cần thêm đá' or gems..' / '..target..'  ·  Trong túi') or '— / —')
    self.cost:SetColour(unpack(self.ready and BLUE or MUTED))
    self.gem:SetTint(1,1,1,synced and gems>=target and 1 or .30)
    local risk='Thất bại: giữ nguyên cấp trang bị.\nĐá đã dùng không được hoàn lại.'
    if target>=10 then
        risk=data.has_protection and (data.has_magic and 'Thất bại: giữ trang bị và cấp.\nTiêu hao 1 Bùa Bảo Vệ + 1 Bùa Ma Thuật.' or 'Thất bại: giữ trang bị, tụt 1 cấp.\nTiêu hao 1 Bùa Bảo Vệ.') or 'Thất bại: mất trang bị.\nCần Bùa Bảo Vệ để giữ trang bị.'
    elseif target>=6 then
        risk=data.has_magic and 'Thất bại: giữ nguyên cấp trang bị.\nTiêu hao 1 Bùa Ma Thuật.' or 'Thất bại: tụt 1 cấp cường hóa.\nCần Bùa Ma Thuật để giữ cấp.'
    end
    self.warning:SetString(not synced and 'Đá được lấy trực tiếp từ túi đồ.' or maxed and 'Trang bị đã hoàn tất cường hóa.' or risk)
    self.status:SetString(self.pending and 'Đang chờ kết quả từ máy chủ…' or not synced and 'Đặt trang bị hợp lệ vào ô bên trái' or maxed and 'Cường hóa tối đa +13' or gems<target and 'Chưa đủ Đá Cường Hóa trong túi' or 'Sẵn sàng cường hóa lên +'..target)
    if self.ready then self.action:Enable() else self.action:Disable() end
end

function StrengthenUI:Submit()
    self:Refresh(self.data)
    if not self.ready then return end
    local item=self.container.replica.container:GetItemInSlot(1)
    self.pending=self.data.revision
    SendModRPCToServer(MOD_RPC.hh_lo_ren.strengthen,self.container,item,nil,self.data.revision)
    self:Refresh(self.data)
end

return StrengthenUI
