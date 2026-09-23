local Screen = require "widgets/screen"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"

local HHShadowPopup = Class(Screen, function(self, target, options)
    Screen._ctor(self, "HHShadowPopup")
    options = options or {}

    -- Nền đen mờ che game ở phía sau
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0,0,0,.5)

    -- Widget gốc để giữ toàn bộ các thành phần ở giữa màn hình
    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    -- Hình nền Custom của bạn
    self.bg = self.proot:AddChild(Image("images/hh_icon/trich_xuat_background.xml", "trich_xuat_background.tex"))
    self.bg:SetScale(0.4, 0.4, 1)

    -- Dòng chữ Tiêu đề
    self.title = self.proot:AddChild(Text(BODYTEXTFONT, 50, options.title or "Trích Xuất Bóng Ma"))
    self.title:SetColour(0, 0, 0, 1) -- Màu đen (Có thể đổi tùy nền)
    self.title:SetPosition(0, 80, 0)

    -- Dòng chữ Câu hỏi
    self.text = self.proot:AddChild(Text(BODYTEXTFONT, options.text_size or 35,
        options.text or "Bạn có muốn trích xuất bóng ma từ cái xác này không?"))
    self.text:SetColour(0, 0, 0, 1)
    self.text:SetPosition(0, 10, 0)

    -- 2 Nút bấm (Sử dụng Menu chuẩn của Klei để có tiếng click và hover)
    local buttons = {
        {text = "Có", cb = function()
            if options.on_yes ~= nil then
                options.on_yes(target)
            else
                SendModRPCToServer(GetModRPC("hh_rpc", "hh_extract_shadow"), target)
            end
            TheFrontEnd:PopScreen() 
        end},
        {text = "Không", cb = function() TheFrontEnd:PopScreen() end}
    }
    
    -- Tham số 150 là khoảng cách giữa 2 nút
    self.menu = self.proot:AddChild(Menu(buttons, 150, true))
    
    -- TÙY CHỈNH VỊ TRÍ 2 NÚT BẤM
    -- Ở đây bạn có thể chỉnh tọa độ (x, y, z) cho toàn bộ cụm nút
    self.menu:SetPosition(0, -80, 0)

    -- Nếu muốn chỉnh TỪNG NÚT riêng biệt, mở comment đoạn dưới:
    self.menu.items[1]:SetPosition(-160, 0, 0) -- Nút Có
    self.menu.items[2]:SetPosition(160, 0, 0)  -- Nút Không

    -- Đặt focus mặc định cho tay cầm (Controller)
    self.default_focus = self.menu
end)

-- Hàm xử lý bắt phím tắt (Ví dụ: bấm phím ESC hoặc nút B trên tay cầm để thoát)
function HHShadowPopup:OnControl(control, down)
    if HHShadowPopup._base.OnControl(self, control, down) then return true end

    if control == CONTROL_CANCEL and not down then
        TheFrontEnd:PopScreen()
        return true
    end
end

-- Hiển thị hướng dẫn phím tắt dưới góc màn hình cho người chơi tay cầm
function HHShadowPopup:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    return table.concat(t, "  ")
end

return HHShadowPopup
