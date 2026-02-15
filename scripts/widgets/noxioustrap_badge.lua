local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"

local NoxiousTrapBadge = Class(Widget, function(self, owner)
    Widget._ctor(self, "NoxiousTrapBadge")
    self.owner = owner
    self.maxStacks = NOXIOUS_TRAP_MAX_STACKS

    -- キノコアイコン（クリック可能）
    self.button = self:AddChild(ImageButton(
        "images/inventoryimages/noxious_trap.xml",
        "noxious_trap.tex"
    ))
    self.button:SetScale(0.6)
    self.button:SetOnClick(function() self:OnClick() end)
    self.button.image:SetTint(1, 1, 1, 1)

    -- スタック数テキスト
    self.text = self:AddChild(Text(NUMBERFONT, 28))
    self.text:SetPosition(0, -30)
    self.text:SetColour(1, 1, 1, 1)

    -- NetVar更新イベントで表示を自動更新
    self.inst:ListenForEvent("noxioustrapstacksdirty", function()
        self:UpdateDisplay()
    end, owner)

    self:UpdateDisplay()
end)

function NoxiousTrapBadge:UpdateDisplay()
    local stacks = self.owner._noxiousTrapStacks:value()
    self.text:SetString(stacks .. "/" .. self.maxStacks)

    -- スタック0でグレーアウト
    if stacks > 0 then
        self.button.image:SetTint(1, 1, 1, 1)
    else
        self.button.image:SetTint(0.3, 0.3, 0.3, 1)
    end
end

function NoxiousTrapBadge:OnClick()
    local stacks = self.owner._noxiousTrapStacks:value()
    if stacks > 0 then
        SendModRPCToServer(MOD_RPC["teemo"]["use_noxious_trap_stack"])
    end
end

return NoxiousTrapBadge
