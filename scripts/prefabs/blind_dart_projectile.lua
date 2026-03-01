-- Blind Dart 飛翔体（テーモ専用）
-- LoL原作準拠: 必中（追尾）・低速・短射程
-- ダメージ・ブラインド・毒DOTはblind_dart.luaのonattackで処理

local assets = {
    -- ダミー: ベースゲームの吹き矢アニメを流用（後で専用アニメに差し替え）
    Asset("ANIM", "anim/blow_dart.zip"),
}

local function onhit(inst, attacker, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx ~= nil and target ~= nil and target:IsValid() and target.components.combat then
        local follower = impactfx.entity:AddFollower()
        follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
        if attacker ~= nil and attacker:IsValid() then
            impactfx:FacePoint(attacker.Transform:GetWorldPosition())
        end
    end
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

    -- ダミーアニメ: ベースゲームの吹き矢（セイウチ矢）を流用
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
