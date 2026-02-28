local TeemoPoison = require("teemo_poison_util")

local Explosive_Noxious_Trap = Class(function(self,inst)
    self.inst = inst
    self.explosiveRange = 4
    self.explosiveDamage = TEEMO_NOXIOUS_TRAP_DAMAGE
    self.explosiveDotDamage = TEEMO_NOXIOUS_TRAP_DOT
    self.deployer = nil
end)

function Explosive_Noxious_Trap:SetDeployer(deployer)
    self.deployer = deployer
end

local function doEndTask(v)

    if v.noxiousTrapEndTask ~= nil then
        v.noxiousTrapEndTask:Cancel()
    end

    v.noxiousTrapEndTask = v:DoTaskInTime(4.0, function(v)
        if not v:IsValid() then return end
        if v.components.locomotor ~= nil and v._noxiousTrapSlowAmount ~= nil then
            v.components.locomotor.bonusspeed = (v.components.locomotor.bonusspeed or 0) - v._noxiousTrapSlowAmount
            v._noxiousTrapSlowAmount = nil
        end
        if v.noxiousTrapDamageTask ~= nil then
            v.noxiousTrapDamageTask:Cancel()
            v.noxiousTrapDamageTask = nil
        end
        -- 毒マーク解除（他の毒DOTが残っていなければ）
        TeemoPoison.unmarkTeemoPoisoned(v)
    end, v)
end

local function doSlow(v)
    if v.components.locomotor then
        -- 既にスロー中なら再加算しない（持続時間はdoEndTaskでリセット）
        if v._noxiousTrapSlowAmount ~= nil then
            return
        end
        local slowAmount = v.components.locomotor.runspeed * -0.5
        v._noxiousTrapSlowAmount = slowAmount
        v.components.locomotor.bonusspeed = (v.components.locomotor.bonusspeed or 0) + slowAmount
    end
end

local function toxicEffect(target)
    -- 毒エフェクト
    local size = 1
    if target:HasTag("smallcreature") then
        size = 0
    elseif target:HasTag("largecreature") then
        size = 2
    end

    local fx = SpawnPrefab("toxic_effect_by_teemo")
    fx.entity:SetParent(target.entity)
    fx.Transform:SetPosition(0, size, 0)
end

function Explosive_Noxious_Trap:OnBurnt()

    local x, y, z = self.inst.Transform:GetWorldPosition()

    -- 設置者を攻撃帰属先として使用。nilの場合は近くのteemoプレイヤーを探す
    local counterPlayer = self.deployer
    if counterPlayer == nil or not counterPlayer:IsValid() then
        counterPlayer = nil
        local counterList = TheSim:FindEntities(x, y, z, self.explosiveRange * 5, {"teemo"})
        if #counterList > 0 then
            counterPlayer = counterList[1]
        end
    end

    -- playerは爆発対象外
    local nonTarget = "player"
    if TheNet:GetPVPEnabled() then
        nonTarget = "teemo"
    end

    local ents = TheSim:FindEntities(x, y, z, self.explosiveRange)
    for k, v in pairs(ents) do
        -- アイテムは対象外
        local inpocket = v.components.inventoryitem and v.components.inventoryitem:IsHeld()
        if not inpocket then
            -- 移動可能なクリーチャーのみ対象（壁・構造物には発動しない）
            if v.components.combat and v.components.locomotor and v ~= self.inst then

                if not v:HasTag(nonTarget) and not v:HasTag("companion") then

                    -- 毒による食料腐敗マーク（初撃で倒した場合にも対応するためGetAttackedの前に設定）
                    if self.explosiveDotDamage > 0 then
                        TeemoPoison.markTeemoPoisoned(v)
                    end

                    -- 初撃ダメージ（GetAttackedで実ダメージ適用）
                    v.components.combat:GetAttacked(counterPlayer, self.explosiveDamage, nil)

                    if v.components.health and v.noxiousTrapDamageTask == nil and self.explosiveDotDamage > 0 then

                        -- 毒の効果（1秒毎
                        local dotDamage = self.explosiveDotDamage
                        v.noxiousTrapDamageTask = v:DoPeriodicTask(1.0, function()

                            -- エンティティが無効 or ヘルスが無い場合はタスクをキャンセル
                            if not v:IsValid() or v.components.health == nil or v.components.health.currenthealth <= 0 then
                                if v.noxiousTrapDamageTask ~= nil then
                                    v.noxiousTrapDamageTask:Cancel()
                                    v.noxiousTrapDamageTask = nil
                                end
                                return
                            end

                            -- 毒エフェクト
                            toxicEffect(v)

                            -- ダメージ（プレイヤーのみ軽減）
                            local dmg = dotDamage
                            if v:HasTag("player") then
                                dmg = dotDamage * 0.3
                            end

                            v.components.health:DoDelta(-dmg, nil, "noxiousTrap")
                            -- プレーヤーの場合画面が赤くなるやつ（PVP用)
                            if v.HUD then v.HUD.bloodover:Flash() end

                        end)
                    end

                    doSlow(v)
                    doEndTask(v)
                end
            end
        end
    end
    self.inst:Remove()
end

return Explosive_Noxious_Trap
