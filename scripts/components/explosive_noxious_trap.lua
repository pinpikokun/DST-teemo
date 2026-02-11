local AGGRO_DAMAGE = 1      -- アグロ発生用の初撃ダメージ
local DOT_DAMAGE = 50       -- 1tick あたりのダメージ
local DOT_DAMAGE_PVP = 25   -- PvP時は半分
local DOT_TICKS = 4         -- 合計4tick（50×4=200、PvP: 25×4=100）

local Explosive_Noxious_Trap = Class(function(self,inst)
    self.inst = inst
    self.explosiveRange = 5
    self.deployer = nil
end)

function Explosive_Noxious_Trap:SetDeployer(deployer)
    self.deployer = deployer
end

local function doEndTask(v)

    if v.noxiousTrapEndTask ~= nil then
        v.noxiousTrapEndTask:Cancel()
    end

    v.noxiousTrapEndTask = v:DoTaskInTime(DOT_TICKS + 0.5, function(v)
        if v.components.locomotor ~= nil and v._noxiousTrapSlowAmount ~= nil then
            v.components.locomotor.bonusspeed = (v.components.locomotor.bonusspeed or 0) + v._noxiousTrapSlowAmount
            v._noxiousTrapSlowAmount = nil
        end
        if v.noxiousTrapDamageTask ~= nil then
            v.noxiousTrapDamageTask:Cancel()
            v.noxiousTrapDamageTask = nil
        end
    end, v)
end

local function doSlow(v)
    if v.components.locomotor then
        -- 既存のスローがあれば先に戻す
        if v._noxiousTrapSlowAmount ~= nil then
            v.components.locomotor.bonusspeed = (v.components.locomotor.bonusspeed or 0) + v._noxiousTrapSlowAmount
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
        local counterList = TheSim:FindEntities(x, y, z, self.explosiveRange * 5)
        for k, v in pairs(counterList) do
            if v:HasTag("teemo") then
                counterPlayer = v
                break
            end
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
            if v.components.combat and v ~= self.inst then

                if not v:HasTag(nonTarget) and not v:HasTag("companion") then

                    -- アグロを発生させる（ターゲット帰属用）
                    v.components.combat:GetAttacked(counterPlayer, AGGRO_DAMAGE)

                    -- GetAttackedで死亡した場合はスキップ
                    if v:IsValid() and v.components.health ~= nil
                        and not v.components.health:IsDead() then

                        if v.noxiousTrapDamageTask == nil then
                            local dmg = DOT_DAMAGE
                            if v:HasTag("player") then dmg = DOT_DAMAGE_PVP end

                            -- DOT（毎秒dmgダメージ × DOT_TICKS回）
                            local ticks = 0
                            v.noxiousTrapDamageTask = v:DoPeriodicTask(1.0, function()
                                ticks = ticks + 1

                                if ticks > DOT_TICKS or not v:IsValid()
                                    or v.components.health == nil or v.components.health.currenthealth <= 0 then
                                    if v.noxiousTrapDamageTask ~= nil then
                                        v.noxiousTrapDamageTask:Cancel()
                                        v.noxiousTrapDamageTask = nil
                                    end
                                    return
                                end

                                toxicEffect(v)
                                v.components.health:DoDelta(-dmg, nil, "noxiousTrap")
                                if v.HUD then v.HUD.bloodover:Flash() end

                            end)
                        end

                        doSlow(v)
                        doEndTask(v)
                    end
                end
            end
        end
    end
    self.inst:Remove()
end

return Explosive_Noxious_Trap
