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

    -- 攻撃間隔を1.0秒に設定（遠距離武器のため連射を制限）
    if owner.components.combat then
        owner.components.combat.min_attack_period = 1.0
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
    inst.components.weapon:SetDamage(0) -- 左クリック近接は0ダメージ（右クリックでprojectile発射）


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