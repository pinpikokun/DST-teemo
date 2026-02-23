-- Teemo Poison Loot Utility
-- 毒状態で死んだ敵のドロップ食料を腐敗させる

local function onLootSpawned(inst, data)
    -- 設定で無効化されている場合はスキップ
    if TEEMO_POISON_SPOIL_PERCENT == nil or TEEMO_POISON_SPOIL_PERCENT <= 0 then
        return
    end

    if data.loot == nil then return end

    -- 食用かつ腐敗可能なアイテムのみ対象
    if data.loot.components.edible == nil then return end
    if data.loot.components.perishable == nil then return end

    -- 中心値 ± 15% のランダムで鮮度を決定（0〜1にクランプ）
    local variance = (math.random() * 2 - 1) * 0.15
    local spoilPercent = math.max(0, math.min(1, TEEMO_POISON_SPOIL_PERCENT + variance))

    -- 現在の鮮度がランダム値より高い場合のみ腐敗させる
    local currentPercent = data.loot.components.perishable:GetPercent()
    if currentPercent > spoilPercent then
        data.loot.components.perishable:SetPercent(spoilPercent)
    end
end

local function markTeemoPoisoned(target)
    if not target:IsValid() then return end
    if target._teemoPoisoned then return end
    target._teemoPoisoned = true
    target:ListenForEvent("loot_prefab_spawned", onLootSpawned)
end

local function unmarkTeemoPoisoned(target)
    if not target:IsValid() then return end
    -- 他の毒DOTが残っている場合はマークを維持
    if target.toxicShotDamageTask ~= nil then return end
    if target.noxiousTrapDamageTask ~= nil then return end
    if not target._teemoPoisoned then return end
    target._teemoPoisoned = nil
    target:RemoveEventCallback("loot_prefab_spawned", onLootSpawned)
end

return {
    markTeemoPoisoned = markTeemoPoisoned,
    unmarkTeemoPoisoned = unmarkTeemoPoisoned,
}
