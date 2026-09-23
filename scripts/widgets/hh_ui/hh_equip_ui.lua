local Widget = require('widgets/widget')
local Image = require('widgets/image')
local Text = require('widgets/text')
local ImageButton = require('widgets/imagebutton')
local Items = require('enums/hh_items')
local Lock = require('utils/hh_summary_lock')
local Utils = require('utils/hh_utils')
local Theme = require('widgets/hh_ui/ttk_unified_theme')
local FS = 97/80
local function Font() return Theme.GetFont() end
local SKIN = 'images/ttk_forge/controls.xml'
local WHITE,MUTED,PURPLE,GOLD={.94,.91,.96,1},{.72,.68,.79,1},{.78,.64,.95,1},{1,.75,.43,1}
local function Label(parent,text,x,y,size,colour,width)
    local t=parent:AddChild(Text(Font(),size*FS,text,colour or WHITE))
    t:SetPosition(x,y);t:SetClickable(false)
    if width then t:SetTruncatedString(text,width,nil,true) end
    return t
end
local function Rect(parent,x,y,w,h,colour)
    local i=parent:AddChild(Image('images/hh_icon/hh_white.xml','hh_white.tex'))
    i:SetPosition(x,y);i:SetSize(w,h);i:SetTint(unpack(colour));i:SetClickable(false)
    return i
end
local function Button(parent,text,x,y,w,h,fn,size)
    local b=parent:AddChild(ImageButton(SKIN,'tab_idle.tex'))
    b:SetPosition(x,y);b:ForceImageSize(w,h);b:SetNormalScale(1);b:SetFocusScale(1.015)
    b:SetFont(Font());b:SetDisabledFont(Font());b:SetTextSize((size or 18)*FS);b:SetText(text)
    b:SetTextColour(unpack(WHITE));b:SetTextFocusColour(1,1,1,1);b:SetTextDisabledColour(.43,.40,.49,1)
    b:SetOnClick(fn);return b
end
local positions={}
for row=0,5 do for col=0,3 do positions[#positions+1]={-356+col*46,115-row*46} end end
positions[25]={-80,80};positions[26]={100,80};positions[27]={280,80};positions[28]={110,95}
local allslots={};for i=1,24 do allslots[i]=i end
local function Enabled(b,on) if on then b:Enable() else b:Disable() end end

local Summary=Class(Widget,function(self,owner,container)
    Widget._ctor(self,'Bảng Tổng Hợp')
    self.owner,self.container,self.page=owner,container,1
    self.frame=self:AddChild(Image('images/ttk_forge/frame.xml','frame.tex'));self.frame:SetSize(900,600)
    Label(self,'BẢNG TỔNG HỢP',0,239,34)
    Label(self,'TÁI CHẾ',-287,180,23,PURPLE)
    self.tab='combine'
    self.tabs={
        combine=Button(self,'Hợp Thành',-25,184,250,39,function()self:SetTab('combine')end,22),
        socket=Button(self,'Khảm',245,184,250,39,function()self:SetTab('socket')end,22),
    }
    self.combine=self:AddChild(Widget('combine_panel'))
    self.socket=self:AddChild(Widget('socket_panel'))
    Rect(self,-176,-18,1,420,{.5,.43,.60,1});Rect(self,0,163,780,1,{.5,.43,.60,1})
    Label(self,'Đặt đồ cần tái chế vào 24 ô',-287,145,15,MUTED)
    self.move=Button(self,'Đưa từ túi',-287,-166,206,37,function()
        self:Ask('MoveEquips','Đưa trang bị trong túi vào vùng tái chế?\nThao tác này chưa phá hủy trang bị.',nil,{})
    end)
    self.recycle=Button(self,'Tái chế',-287,-210,206,37,function()
        self:Ask('RemoveEquips','Phá hủy trang bị trong 24 ô bên trái?\nCó cơ hội nhận lại Đá Thuộc Tính.\nKhông thể hoàn tác.',nil,allslots)
    end)
    Label(self,'Kiểm tra đồ trước khi tái chế.',-287,-248,15,GOLD)
    for i,caption in ipairs({'Trang bị','Đá / Giấy thuộc tính','Lục Bảo Thạch'}) do
        Label(self.combine,caption,positions[24+i][1],133,17,WHITE)
    end
    Label(self.combine,'Làm mới trị số',-80,19,17,MUTED)
    Label(self.combine,'Thêm một dòng',100,19,17,MUTED)
    Label(self.combine,'Xóa ngẫu nhiên',280,19,17,MUTED)
    self.reroll=Button(self.combine,'Đổi trị số',-80,-31,158,42,function()
        self:Ask('UpdateEffectValue','Đổi trị số thuộc tính của trang bị?\nTiêu hao 1 Bùa May từ số dư.',nil,{25})
    end,19)
    self.add=Button(self.combine,'Ép thuộc tính',100,-31,158,42,function()
        self:Ask('AddEquipEffect','Thêm một dòng thuộc tính vào trang bị?\nTiêu hao Đá hoặc Giấy trong ô giữa.',nil,{25,26})
    end,19)
    self.remove=Button(self.combine,'Tẩy một dòng',280,-31,158,42,function()
        self:Ask('RemoveEquipEffect','Xóa ngẫu nhiên một dòng thuộc tính?\nTiêu hao 1 Lục Bảo Thạch.',nil,{25,27})
    end,19)
    self.charm=Label(self.combine,'Bùa May: 0',110,-106,21,PURPLE)
    Label(self.combine,'Đổi trị số tiêu hao 1 Bùa May từ số dư.',110,-140,17,MUTED)
    Label(self.combine,'Muốn chọn dòng để xóa:\ndùng Thanh Tẩy tại Thần Binh Phổ.',110,-215,18,MUTED)
    Label(self.socket,'Trang bị khảm',110,145,19)
    Label(self.socket,'Đặt trang bị vào ô, rồi chọn châu báu bên dưới.',110,43,17,MUTED)
    self.gem_buttons={}
    for i=1,8 do
        local b=Button(self.socket,'',-30+((i-1)%2)*270,-21-math.floor((i-1)/2)*52,250,42,function() self:ChooseGem(i) end,18)
        self.gem_buttons[i]=b
    end
    self.empty=Label(self.socket,'Chưa có châu báu hoặc đạo cụ.\nThu thập thêm khi chiến đấu.',110,-85,20,MUTED)
    self.previous=Button(self.socket,'‹',-20,-247,40,30,function()self:ChangePage(-1)end)
    self.next=Button(self.socket,'›',240,-247,40,30,function()self:ChangePage(1)end)
    self.pagenum=Label(self.socket,'1 / 1',110,-247,18,MUTED)
    self.close=Button(self,'×',388,234,30,30,function()Lock.Close(owner)end,23)
    self.close:SetTextures(SKIN,'slot.tex')
    self.inst:ListenForEvent('hh_items',function()self:UpdateTemplates()end,owner)
    self:UpdateTemplates();self:SetTab('combine');self:StartUpdating()
end)

function Summary:GetItem(index)
    return self.container and self.container.replica.container:GetItemInSlot(index) or nil
end
function Summary:AttachContainerWidget(native)
    self.native=native
    for i,slot in ipairs(native.inv) do
        slot:SetPosition(unpack(positions[i]));slot.bgimage:SetTexture(SKIN,'slot.tex')
        slot.bgimage:SetSize(64,64)
        slot:SetHoverText(i<=24 and 'Trang bị cần tái chế' or i==25 and 'Trang bị cần đổi thuộc tính' or i==26 and 'Chỉ nhận Đá hoặc Giấy Thuộc Tính' or i==27 and 'Chỉ nhận Lục Bảo Thạch' or 'Trang bị cần khảm',{font=Font(),font_size=18*FS})
        slot:SetOnTileChangedFn(function()self:Refresh()end)
    end
    self:RefreshSlots()
end
function Summary:GetSlotLayout(index)
    local point=positions[index]
    return point and { x=point[1], y=point[2] } or nil
end
function Summary:GetVisibleSlots(tab)
    local visible={}
    for i=1,24 do visible[#visible+1]=i end
    if tab=='combine' then
        visible[#visible+1],visible[#visible+2],visible[#visible+3]=25,26,27
    elseif tab=='socket' then
        visible[#visible+1]=28
    end
    return visible
end
function Summary:GetActionRPC(action)
    return ({reroll='UpdateEffectValue',add='AddEquipEffect',remove='RemoveEquipEffect',socket='EquipGems'})[action]
end
function Summary:RefreshSlots()
    if not self.native then return end
    for i,slot in ipairs(self.native.inv) do
        local visible=not self.dialog and (i<=24 or (self.tab=='combine' and i>=25 and i<=27) or (self.tab=='socket' and i==28))
        if visible then slot:Show() else slot:Hide() end
    end
end
function Summary:SetTab(tab)
    if self.dialog or (tab~='combine' and tab~='socket') then return end
    self.tab=tab
    if tab=='combine' then self.combine:Show();self.socket:Hide() else self.combine:Hide();self.socket:Show() end
    for id,button in pairs(self.tabs) do
        local active=id==tab
        button:SetTextures(SKIN,active and 'tab_active.tex' or 'tab_idle.tex')
        button:SetTextColour(unpack(active and {.12,.10,.16,1} or WHITE))
    end
    self:RefreshSlots()
end
function Summary:GetSlotScale(index)
    return index<=24 and .68 or 1.08
end
function Summary:UpdateTemplates()
    self.balance,self.entries=0,{}
    for _,entry in ipairs(Utils:GetClientValue(self.owner,'hh_items') or {}) do
        if entry.id=='ac_refreshStone' then self.balance=tonumber(entry.num) or 0 end
        if Items[entry.id] and entry.id~='ac_refreshStone' and entry.id~='ad_cleanStone' and (tonumber(entry.num) or 0)>0 then
            table.insert(self.entries,entry)
        end
    end
    self.page=math.max(1,math.min(self.page,math.ceil(#self.entries/8)))
    self:Refresh()
end
function Summary:ChangePage(delta)
    self.page=math.max(1,math.min(math.max(1,math.ceil(#self.entries/8)),self.page+delta));self:Refresh()
end
function Summary:Refresh()
    local gear=self:GetItem(25)
    Enabled(self.reroll,gear and self.balance>0);Enabled(self.add,gear and self:GetItem(26));Enabled(self.remove,gear and self:GetItem(27))
    local has=false;for i=1,24 do if self:GetItem(i) then has=true;break end end
    Enabled(self.recycle,has)
    self.charm:SetString('Bùa May: '..self.balance)
    local pages=math.max(1,math.ceil(#self.entries/8))
    self.pagenum:SetString(self.page..' / '..pages)
    Enabled(self.previous,self.page>1);Enabled(self.next,self.page<pages)
    if #self.entries==0 then self.empty:Show() else self.empty:Hide() end
    for i,b in ipairs(self.gem_buttons) do
        local entry=self.entries[(self.page-1)*8+i];b.entry=entry
        if entry then
            local def=Items[entry.id];b:Show()
            local name=def.name:gsub('★',' ')
            b:SetText(name..' · '..entry.num);b.text:SetTruncatedString(name..' · '..entry.num,230,nil,true)
            b:SetHoverText(def.name..' · '..entry.num,{font=Font(),font_size=18*FS})
            b:SetTextColour(unpack(def.name:find('★',1,true) and GOLD or WHITE))
            Enabled(b,def.is_item or self:GetItem(28))
        else b:Hide() end
    end
end
function Summary:ChooseGem(index)
    local entry=self.gem_buttons[index].entry
    if not entry then return end
    local def=Items[entry.id]
    local action=entry.id=='aa_punchStone' and 'Đục thêm lỗ khảm?' or entry.id=='ab_decoderStone' and 'Tháo ngẫu nhiên một châu báu?' or def.is_item and 'Sử dụng đạo cụ này?' or 'Khảm châu báu vào trang bị?'
    self:Ask('EquipGems',action..'\n'..def.name:gsub('★',' ')..' · Tiêu hao 1',entry.id,def.is_item and {} or {28})
end
function Summary:Dismiss()
    if self.dialog then self.dialog:Kill();self.dialog=nil end
    self:RefreshSlots()
end
function Summary:Ask(action,message,arg,indices)
    if self.sent_at and GetTime()-self.sent_at<.3 then return end
    self:Dismiss()
    local captured={};for _,i in ipairs(indices) do captured[i]=self:GetItem(i) or false end
    if self.native then for _,slot in ipairs(self.native.inv) do slot:Hide() end end
    self.dialog=self:AddChild(Widget('confirmation'))
    local shade=Rect(self.dialog,0,0,900,600,{.025,.018,.04,.95});shade:SetClickable(true)
    Label(self.dialog,'XÁC NHẬN THAO TÁC',0,103,27,PURPLE)
    Label(self.dialog,message,0,25,21)
    self.cancel=Button(self.dialog,'Hủy bỏ',-110,-95,185,44,function()self:Dismiss()end,20)
    local sent=false
    self.confirm=Button(self.dialog,'Xác nhận',110,-95,185,44,function()
        if sent or not self.dialog then return end
        for i,item in pairs(captured) do
            if (self:GetItem(i) or false)~=item then self:Dismiss();return end
        end
        sent=true;self.sent_at=GetTime();self:Dismiss()
        SendModRPCToServer(MOD_RPC.hh_rpc.hh_handle_equip,action,arg)
    end,20)
end
function Summary:OnUpdate(dt)
    self.elapsed=(self.elapsed or 0)+dt
    if self.elapsed>=.2 then self.elapsed=0;self:Refresh() end
end
return Summary
