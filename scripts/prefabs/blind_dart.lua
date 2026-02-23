local TeemoPoison = require("teemo_poison_util")

local assets = {
    Asset("ANIM", "anim/blind_dart.zip"),
	Asset("ANIM", "anim/swap_blind_dart.zip"),

	Asset("IMAGE", "images/inventoryimages/blind_dart.tex"),
	Asset("ATLAS", "images/inventoryimages/blind_dart.xml"),
}

local function onequip(inst, owner)
    -- 手に持っている時の見た目？
    owner.AnimState:OverrideSymbol("swap_object", "swap_blind_dart", "swap_blind_dart")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner:AddTag("blind_dart_equipped")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner:RemoveTag("blind_dart_equipped")
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
    if target.components.combat then
        -- 2秒間攻撃できなくする
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
    if not target.components.health or target.components.health.currenthealth <= 0 then
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
    -- RemovePhysicsColliders(inst)

    -- 画像の構成
    inst.AnimState:SetBank("blind_dart")
    -- 実際の画像
    inst.AnimState:SetBuild("blind_dart")
    -- 画像構成の何番目の画像を表示するか
    inst.AnimState:PlayAnimation("idle")

    -- 攻撃の見た目
    inst:AddTag("blowdart")
    -- 攻撃の音に使われてる？
    inst:AddTag("sharp")

    inst.entity:SetPristine()

    -- ホストではない場合はここまで？
    if not TheWorld.ismastersim then
        return inst
    end
	
    -- 武器
    inst:AddComponent("weapon")
    -- ダメージ
    inst.components.weapon:SetDamage(TEEMO_BLIND_DART_DAMAGE)
    -- 範囲（攻撃射程、ヒット射程）
    inst.components.weapon:SetRange(8, 10)
    -- 攻撃効果
    inst.components.weapon:SetOnAttack(onattack)
    -- 吹き矢の矢を飛ばす見た目追加
    inst.components.weapon:SetProjectile("blowdart_walrus")


	inst:AddComponent("inspectable")

    -- インベントリ
    inst:AddComponent("inventoryitem")
    -- インベントリの見た目
	inst.components.inventoryitem.atlasname = "images/inventoryimages/blind_dart.xml"
    inst.components.inventoryitem.keepondeath = true

    -- 幽霊の攻撃（ハウント）時の処理？
    -- MakeHauntableLaunchAndPerish(inst)

    -- 装備
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