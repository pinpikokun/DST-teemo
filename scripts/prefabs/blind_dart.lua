local TeemoPoison = require("teemo_poison_util")

-- LoL テーモ ダート発射時セリフ
local DART_QUOTES = {
    "Blind 'em!",
    "That's gotta sting.",
    "Let the poison do its work.",
}

local assets = {
    Asset("ANIM", "anim/blind_dart.zip"),
    Asset("ANIM", "anim/swap_blind_dart.zip"),

    Asset("IMAGE", "images/inventoryimages/blind_dart.tex"),
    Asset("ATLAS", "images/inventoryimages/blind_dart.xml"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_blind_dart", "swap_blind_dart")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner:AddTag("blind_dart_equipped")

    -- 攻撃間隔を1.5秒に設定（遠距離武器のため連射を制限）
    if owner.components.combat then
        owner.components.combat.min_attack_period = 1.5
    end

    -- 敵の攻撃を受けたときに耐久力を減らす（耐久度が無効なら登録しない）
    if inst.components.finiteuses then
        inst._onowner_attacked = function(owner, data)
            if not inst:IsValid() then return end
            if data and data.attacker and data.attacker:IsValid()
                and data.attacker.components.combat
                and inst.components.finiteuses then
                local cur = inst.components.finiteuses:GetUses()
                if cur > 0 then
                    inst.components.finiteuses:SetUses(cur - 1)
                end
            end
        end
        owner:ListenForEvent("attacked", inst._onowner_attacked)
    end
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner:RemoveTag("blind_dart_equipped")

    -- 攻撃間隔を通常に戻す
    if owner.components.combat then
        owner.components.combat.min_attack_period = TUNING.WILSON_ATTACK_PERIOD
    end

    -- リスナー解除
    if inst._onowner_attacked then
        owner:RemoveEventCallback("attacked", inst._onowner_attacked)
        inst._onowner_attacked = nil
    end
end

local function doBlindEffect(target)
    local size = 1
    if target:HasTag("smallcreature") then
        size = 0
    elseif target:HasTag("largecreature") then
        size = 2
    end

    local fx = SpawnPrefab("blind_effect")
    fx.entity:SetParent(target.entity)
    fx.Transform:SetPosition(0, size, 0)
    target.blindEffect = fx
end

local function doBlindEffectEndTask(target)
    if target.blindEffectEndTask ~= nil then
        target.blindEffectEndTask:Cancel()
    end

    local time = 2.0
    if target.components.health then
        if target.components.health.currenthealth <= 0 then
            time = 0.5
        end
    end

    target.blindEffectEndTask = target:DoTaskInTime(time, function(target)
        if target.blindEffect ~= nil then
            if target.blindEffect.kill_fx then
                target.blindEffect:kill_fx()
            else
                target.blindEffect:Remove()
            end
            target.blindEffect = nil
        end
        target.blindEffectEndTask = nil
    end)
end

local function doBlind(target)
    -- 移動可能なクリーチャーのみブラインド（壁等に適用するとBlankOutAttacksのコールバックでクラッシュ）
    if target.components.combat and target.components.locomotor then
        target.components.combat:BlankOutAttacks(2.0)
    end
end

local function toxicEffect(target)
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

local function doToxicShotEndTask(target)
    if target.toxicShotEndTask ~= nil then
        target.toxicShotEndTask:Cancel()
    end

    target.toxicShotEndTask = target:DoTaskInTime(4.0, function(target)
        if target.toxicShotDamageTask ~= nil then
            target.toxicShotDamageTask:Cancel()
            target.toxicShotDamageTask = nil
        end
        target.toxicShotEndTask = nil
        -- 毒マーク解除（他の毒DOTが残っていなければ）
        TeemoPoison.unmarkTeemoPoisoned(target)
    end)
end

local function doToxicShot(target)
    -- 移動可能なクリーチャーのみ毒DOT（壁・構造物には初撃ダメージのみ）
    if not target.components.health or target.components.health.currenthealth <= 0 or not target.components.locomotor then
        return
    end

    -- DOT無効化時はスキップ
    if TEEMO_BLIND_DART_DOT <= 0 then
        return
    end

    -- 毒による食料腐敗マーク（冗長性のため、teemo.luaのonattackotherでもマーク済み）
    TeemoPoison.markTeemoPoisoned(target)

    -- DOT発動中は効果延長のみ
    if target.toxicShotDamageTask ~= nil then
        doToxicShotEndTask(target)
        return
    end

    -- 毒DOT（毎秒ダメージ、4秒間）
    target.toxicShotDamageTask = target:DoPeriodicTask(1.0, function()
        if not target:IsValid() or target.components.health == nil or target.components.health.currenthealth <= 0 then
            if target.toxicShotDamageTask ~= nil then
                target.toxicShotDamageTask:Cancel()
                target.toxicShotDamageTask = nil
            end
            return
        end

        toxicEffect(target)
        local dot = TEEMO_BLIND_DART_DOT
        if target:HasTag("player") then
            dot = dot * 0.3
        end
        target.components.health:DoDelta(-dot, nil, "toxicShot")
        if target.HUD then target.HUD.bloodover:Flash() end
    end)

    doToxicShotEndTask(target)
end

local function onattack(inst, atker, target, skipsanity)

    -- ダート発射時セリフ（30%確率）
    if atker and atker.components.talker and math.random() < 0.3 then
        atker.components.talker:Say(DART_QUOTES[math.random(#DART_QUOTES)])
    end

    -- ブラインド効果・毒DOTは吹き矢攻撃の場合のみ
    if inst:HasTag("blowdart") then

        doBlind(target)
        doToxicShot(target)

        if target.blindEffect ~= nil then
            doBlindEffectEndTask(target)
            return
        end

        doBlindEffect(target)
        doBlindEffectEndTask(target)

    end

end

local function fn(Sim)
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blind_dart")
    inst.AnimState:SetBuild("blind_dart")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("blowdart")
    inst:AddTag("sharp")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TEEMO_BLIND_DART_DAMAGE)
    inst.components.weapon:SetRange(5, 50) -- (攻撃射程, ヒット判定射程) 追尾弾のため必中
    inst.components.weapon:SetOnAttack(onattack)
    inst.components.weapon:SetProjectile("blind_dart_projectile") -- テーモ専用飛翔体（低速・必中）


    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/blind_dart.xml"

    -- 耐久力（敵に攻撃されると減る、設定値で破壊。0 = 壊れない）
    if TEEMO_BLIND_DART_DURABILITY > 0 then
        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(TEEMO_BLIND_DART_DURABILITY)
        inst.components.finiteuses:SetUses(TEEMO_BLIND_DART_DURABILITY)
        inst.components.finiteuses:SetOnFinished(function(inst)
            inst:DoTaskInTime(0, function() inst:Remove() end)
        end)
        -- 攻撃時の自動消費を無効化（被ダメージ時のみ手動で減少させる）
        inst.components.finiteuses:SetIgnoreCombatDurabilityLoss(true)
    end

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    -- teemoのみ装備出来る
    if not inst.components.characterspecific then
        inst:AddComponent("characterspecific")
    end
    inst.components.characterspecific:SetOwner("teemo")
    inst.components.characterspecific:SetStorable(true)
    inst.components.characterspecific:SetComment("Captain Teemo on duty!") 

    return inst
end

return Prefab( "common/inventory/blind_dart", fn, assets)