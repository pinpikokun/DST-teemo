local Widget = require("widgets/widget")
local Image = require("widgets/image")
local Text = require("widgets/text")
local ImageButton = require("widgets/imagebutton")

local NoxiousTrapSlot = Class(Widget, function(self, owner)
    Widget._ctor(self, "NoxiousTrapSlot")

    self.owner = owner

    -- インベントリスロットと同じ背景
    self.bgimage = self:AddChild(Image("images/hud.xml", "inv_slot.tex"))

    -- ノクサストラップアイコン（クリック可能）
    self.icon = self:AddChild(ImageButton(
        "images/inventoryimages/noxious_trap.xml",
        "noxious_trap.tex"
    ))
    self.icon:SetScale(0.65)
    self.icon:SetOnClick(function() self:OnClick() end)
    self.icon.scale_on_focus = false

    -- スタック数テキスト（右下、DST標準のアイテム個数と同じ位置）
    self.stackcount = self:AddChild(Text(NUMBERFONT, 22))
    self.stackcount:SetPosition(16, -16, 0)
    self.stackcount:SetColour(1, 1, 1, 1)

    -- NetVar更新イベントで表示を自動更新
    self.inst:ListenForEvent("noxioustrapstacksdirty", function()
        self:UpdateDisplay()
    end, owner)

    self:UpdateDisplay()
end)

function NoxiousTrapSlot:UpdateDisplay()
    local stacks = self.owner._noxiousTrapStacks:value()
    self.stackcount:SetString(tostring(stacks))

    -- スタック0でグレーアウト
    if stacks > 0 then
        self.icon.image:SetTint(1, 1, 1, 1)
    else
        self.icon.image:SetTint(0.3, 0.3, 0.3, 1)
    end
end

function NoxiousTrapSlot:OnClick()
    local stacks = self.owner._noxiousTrapStacks:value()
    if stacks > 0 then
        SendModRPCToServer(MOD_RPC["teemo"]["use_noxious_trap_stack"])
    end
end

return NoxiousTrapSlot
