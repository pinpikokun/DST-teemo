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
    if self.owner:HasTag("playerghost") then return end
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

    -- レティクル（地面マーカー）を生成 — DST標準のAoEターゲティング円を使用
    local reticule = SpawnPrefab("reticuleaoe")
    reticule.AnimState:SetScale(0.5, 0.5, 0.5)
    reticule.AnimState:SetMultColour(0.3, 0.7, 1.0, 1)
    reticule.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    self._reticule = reticule

    -- マウス移動でレティクル位置を更新 + 範囲外なら赤色に変更
    local maxRange = TEEMO_FLASH_RANGE or 8
    self._moveHandler = TheInput:AddMoveHandler(function(x, y)
        if self._reticule and self._reticule:IsValid() and self.owner:IsValid() then
            local pos = TheInput:GetWorldPosition()
            if pos then
                self._reticule.Transform:SetPosition(pos.x, 0, pos.z)
                local px, py, pz = self.owner.Transform:GetWorldPosition()
                local dx, dz = pos.x - px, pos.z - pz
                local dist = math.sqrt(dx * dx + dz * dz)
                if dist <= maxRange then
                    -- 範囲内: 青
                    self._reticule.AnimState:SetMultColour(0.3, 0.7, 1.0, 1)
                else
                    -- 範囲外: 赤
                    self._reticule.AnimState:SetMultColour(1.0, 0.2, 0.2, 1)
                end
            end
        end
    end)

    -- 初期位置
    local initPos = TheInput:GetWorldPosition()
    if initPos and self._reticule:IsValid() then
        self._reticule.Transform:SetPosition(initPos.x, 0, initPos.z)
    end

    -- ESCキーでキャンセル
    self._keyHandler = TheInput:AddKeyUpHandler(KEY_ESCAPE, function()
        if self._flashTargeting then
            self:StopFlashTargeting()
        end
    end)

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
    if self._keyHandler then
        self._keyHandler:Remove()
        self._keyHandler = nil
    end
end

function SummonerSpellSlot:Kill()
    self:StopFlashTargeting()
    SummonerSpellSlot._base.Kill(self)
end

return SummonerSpellSlot
