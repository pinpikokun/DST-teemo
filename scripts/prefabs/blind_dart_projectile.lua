-- Blind Dart 飛翔体（テーモ専用）
-- 右クリックで発射 → 追尾必中 → onhitでダメージ・ブラインド・毒DOT・数字表示

local TeemoPoison = require("teemo_poison_util")

-- ダート命中時セリフ
local DART_QUOTES = {
    "Blind 'em!",
    "That's gotta sting.",
    "Let the poison do its work.",
}

local assets = {
    Asset("ANIM", "anim/blow_dart.zip"),
}

-- ========== ブラインド効果 ==========

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

    local time = 3.0
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
    -- 移動可能なクリーチャーのみブラインド（壁・構造物は除外）
    if target.components.combat and target.components.locomotor then
        -- 攻撃力を0にする（攻撃モーションは行うがダメージが通らない = 空振り）
        target.components.combat.externaldamagemultipliers:SetModifier(target, 0, "teemo_blind")

        -- 既存のブラインド解除タスクをキャンセル
        if target._teemoBlindTask ~= nil then
            target._teemoBlindTask:Cancel()
        end

        -- 3秒後に攻撃力を復元
        target._teemoBlindTask = target:DoTaskInTime(3.0, function(target)
            if target:IsValid() and target.components.combat then
                target.components.combat.externaldamagemultipliers:RemoveModifier(target, "teemo_blind")
            end
            target._teemoBlindTask = nil
        end)
    end
end

-- ========== 毒DOT ==========

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

    -- 毒による食料腐敗マーク
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
        TeemoShowDamageNumber(target, dot, TEEMO_DMG_COLOUR_MAGIC)
        if target.HUD then target.HUD.bloodover:Flash() end
    end)

    doToxicShotEndTask(target)
end

-- ========== onhit: 飛翔体命中時の全処理 ==========

local function onhit(inst, owner, target)
    -- owner = weapon (blind_dart) ※projectile:Throw の第1引数
    -- 実際のプレイヤーは inst._teemo_attacker から取得
    local attacker = inst._teemo_attacker
    local weapon = inst._teemo_weapon or owner

    -- 1. インパクトVFX
    local impactfx = SpawnPrefab("impact")
    if impactfx ~= nil and target ~= nil and target:IsValid() and target.components.combat then
        local follower = impactfx.entity:AddFollower()
        follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
        if attacker ~= nil and attacker:IsValid() then
            impactfx:FacePoint(attacker.Transform:GetWorldPosition())
        end
    end

    -- 2. ダメージ計算・適用
    if target ~= nil and target:IsValid() and target.components.combat then
        local damage = TEEMO_BLIND_DART_DAMAGE
        if attacker and attacker:IsValid() and attacker.components.combat then
            damage = damage * (attacker.components.combat.damagemultiplier or 1)
            -- externaldamagemultipliers も適用（SourceModifierListなので:Get()で取得）
            if attacker.components.combat.externaldamagemultipliers then
                damage = damage * attacker.components.combat.externaldamagemultipliers:Get()
            end
        end
        -- 初撃のみ怯み、2撃目以降は怯みなし（LoL準拠: AAにスタンなし）
        if not target._teemo_dart_flinched then
            target._teemo_dart_flinched = true
            local valid_attacker = attacker ~= nil and attacker:IsValid() and attacker or nil
            target.components.combat:GetAttacked(valid_attacker, damage, weapon)
        else
            if target.components.health then
                target.components.health:DoDelta(-damage, nil, "blind_dart")
            end
        end

        -- ダメージ数字表示（初撃: 物理 → オレンジ）
        TeemoShowDamageNumber(target, damage, TEEMO_DMG_COLOUR_PHYSICAL)
    end

    -- 3. ブラインド効果（CD10秒）
    if target ~= nil and target:IsValid() and weapon and weapon:IsValid() and weapon:HasTag("blowdart") then
        local now = GetTime()
        if weapon._lastBlindTime == nil or now - weapon._lastBlindTime >= 10 then
            doBlind(target)
            weapon._lastBlindTime = now
            if target.blindEffect ~= nil then
                doBlindEffectEndTask(target)
            else
                doBlindEffect(target)
                doBlindEffectEndTask(target)
            end
        end

        -- 4. 毒DOT
        doToxicShot(target)
    end

    -- 5. onattackother イベントプッシュ（teemo.lua の既存リスナーを発動）
    if attacker ~= nil and attacker:IsValid() then
        attacker:PushEvent("onattackother", { target = target, weapon = weapon })
    end

    -- 7. ダート命中時セリフ（30%確率）
    if attacker and attacker:IsValid() and attacker.components.talker and math.random() < 0.3 then
        attacker.components.talker:Say(DART_QUOTES[math.random(#DART_QUOTES)])
    end

    -- 8. 飛翔体除去
    inst:Remove()
end

local function onthrown(inst, owner, target, attacker)
    inst:AddTag("NOCLICK")
    inst.AnimState:PlayAnimation("dart_pipe")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeProjectilePhysics(inst)

    inst.AnimState:SetBank("blow_dart")
    inst.AnimState:SetBuild("blow_dart")
    inst.AnimState:PlayAnimation("idle_pipe")

    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(15)           -- 低速（walrus=60, パチンコ=25）
    inst.components.projectile:SetHoming(true)         -- 必中（追尾）
    inst.components.projectile:SetHitDist(1.5)
    inst.components.projectile:SetOnHitFn(onhit)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetOnThrownFn(onthrown)
    inst.components.projectile:SetLaunchOffset(Vector3(3, 0.5, 0))

    return inst
end

return Prefab("common/blind_dart_projectile", fn, assets)
