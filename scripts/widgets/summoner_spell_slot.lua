local Widget = require("widgets/widget")
local Image = require("widgets/image")
local Text = require("widgets/text")
local ImageButton = require("widgets/imagebutton")

local SummonerSpellSlot = Class(Widget, function(self, owner, config)
    Widget._ctor(self, "SummonerSpellSlot")

    self.owner = owner
    self.spell_name = config.spell_name         -- "flash" or "ignite"
    self.icon_atlas = config.icon_atlas
    self.icon_tex = config.icon_tex
    self.cooldown_event = config.cooldown_event  -- net変数の変更イベント名
    self.on_activate = config.on_activate        -- 発動時コールバック（クライアント側）

    -- インベントリスロットと同じ背景
    self.bgimage = self:AddChild(Image("images/hud.xml", "inv_slot.tex"))

    -- スペルアイコン（クリック可能）
    self.icon = self:AddChild(ImageButton(self.icon_atlas, self.icon_tex))
    self.icon:SetScale(0.65)
    self.icon:SetOnClick(function() self:OnClick() end)
    self.icon.scale_on_focus = false

    -- ホバーアニメーション（ItemSlot準拠）
    self.base_scale = 1
    self.highlight_scale = 1.3

    -- クールダウン表示テキスト（中央）
    self.cooldown_text = self:AddChild(Text(NUMBERFONT, 22))
    self.cooldown_text:SetPosition(0, 0, 0)
    self.cooldown_text:SetColour(1, 1, 1, 1)

    -- NetVar更新イベントで表示を自動更新
    self.inst:ListenForEvent(self.cooldown_event, function()
        self:UpdateDisplay()
    end, owner)

    self:UpdateDisplay()
end)

function SummonerSpellSlot:OnGainFocus()
    SummonerSpellSlot._base.OnGainFocus(self)
    self:ScaleTo(self.base_scale, self.highlight_scale, .125)
end

function SummonerSpellSlot:OnLoseFocus()
    SummonerSpellSlot._base.OnLoseFocus(self)
    self:ScaleTo(self.highlight_scale, self.base_scale, .25)
end

function SummonerSpellSlot:GetCooldownNetVar()
    if self.spell_name == "flash" then
        return self.owner._flashCooldown
    elseif self.spell_name == "ignite" then
        return self.owner._igniteCooldown
    end
    return nil
end

function SummonerSpellSlot:UpdateDisplay()
    local netvar = self:GetCooldownNetVar()
    local cd = netvar ~= nil and netvar:value() or 0

    if cd > 0 then
        self.cooldown_text:SetString(tostring(cd))
        self.cooldown_text:Show()
        self.icon.image:SetTint(0.3, 0.3, 0.3, 1)
    else
        self.cooldown_text:Hide()
        self.icon.image:SetTint(1, 1, 1, 1)
    end
end

function SummonerSpellSlot:OnClick()
    local netvar = self:GetCooldownNetVar()
    local cd = netvar ~= nil and netvar:value() or 0
    if cd > 0 then return end

    if self.on_activate then
        self.on_activate(self)
    end
end

----------------------------------------------------------------
-- フラッシュ ターゲティングモード
-- アイコンクリック → 地面にレティクル表示 → 左クリックでテレポート
----------------------------------------------------------------

function SummonerSpellSlot:StartFlashTargeting()
    if self._flashTargeting then
        self:StopFlashTargeting()
        return
    end
    self._flashTargeting = true

    -- レティクル（地面マーカー）を生成
    local reticule = CreateEntity()
    reticule.entity:AddTransform()
    reticule.entity:AddAnimState()
    reticule:AddTag("FX")
    reticule:AddTag("NOCLICK")
    reticule.persists = false
    -- deploy_marker のアニメーションを流用（半透明の青い円）
    reticule.AnimState:SetBank("deploy_indicator")
    reticule.AnimState:SetBuild("deploy_indicator")
    reticule.AnimState:PlayAnimation("idle", true)
    reticule.AnimState:SetMultColour(0.3, 0.5, 1.0, 0.6)
    self._reticule = reticule

    -- マウス移動でレティクル位置を更新
    self._moveHandler = TheInput:AddMoveHandler(function(x, y)
        if self._reticule and self._reticule:IsValid() then
            local pos = TheInput:GetWorldPosition()
            if pos then
                self._reticule.Transform:SetPosition(pos.x, 0, pos.z)
            end
        end
    end)

    -- 初期位置
    local initPos = TheInput:GetWorldPosition()
    if initPos and self._reticule:IsValid() then
        self._reticule.Transform:SetPosition(initPos.x, 0, initPos.z)
    end

    -- マウスクリックでテレポート or キャンセル
    self._clickHandler = TheInput:AddMouseButtonHandler(function(button, down, x, y)
        if not self._flashTargeting then return false end
        if not down then return false end

        if button == MOUSEBUTTON_LEFT then
            local pos = TheInput:GetWorldPosition()
            if pos then
                SendModRPCToServer(MOD_RPC["teemo"]["use_flash"], pos.x, pos.z)
            end
            self:StopFlashTargeting()
            return true -- イベント消費
        elseif button == MOUSEBUTTON_RIGHT then
            self:StopFlashTargeting()
            return true
        end
        return false
    end)
end

function SummonerSpellSlot:StopFlashTargeting()
    self._flashTargeting = false

    if self._reticule and self._reticule:IsValid() then
        self._reticule:Remove()
    end
    self._reticule = nil

    if self._moveHandler then
        self._moveHandler:Remove()
        self._moveHandler = nil
    end
    if self._clickHandler then
        self._clickHandler:Remove()
        self._clickHandler = nil
    end
end

function SummonerSpellSlot:Kill()
    self:StopFlashTargeting()
    SummonerSpellSlot._base.Kill(self)
end

return SummonerSpellSlot
