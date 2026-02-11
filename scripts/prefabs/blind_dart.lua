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
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
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
            target.blindEffect:Remove()
            target.blindEffect = nil
        end
    end, target)
end

local function doBlind(target)
    if target.components.combat then
        -- -- 標的を見失う
        -- target.components.combat.target = nil
        -- 2.5秒間攻撃できなくする
        target.components.combat:BlankOutAttacks(2.0)
    end
end

local function onattack(inst, atker, target, skipsanity)

    -- ブラインド効果は吹き矢攻撃の場合のみ
    if inst:HasTag("blowdart") then

        if target.blindEffect ~= nil then
            doBlind(target)
            doBlindEffectEndTask(target)
            return
        end

        doBlind(target)
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
    inst.components.weapon:SetDamage(10)
    -- 範囲（攻撃射程、ヒット射程）
    inst.components.weapon:SetRange(4, 8)
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