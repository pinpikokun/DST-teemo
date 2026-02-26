
local MakePlayerCharacter = require ("prefabs/player_common")
local TeemoPoison = require("teemo_poison_util")

local assets = {
    Asset( "ANIM", "anim/teemo.zip" ),
    Asset( "ANIM", "anim/ghost_teemo_build.zip" ),
}
local prefabs = {}

local NOXIOUS_TRAP_MAX_STACKS = NOXIOUS_TRAP_MAX_STACKS
local NOXIOUS_TRAP_INITIAL_STACKS = 3
local NOXIOUS_TRAP_RECOVERY_INTERVAL = 30

-- パッシブ「キノコの達人」: キノコのマイナスステータスを無効化
local MUSHROOM_PREFABS = {
    red_cap = true, red_cap_cooked = true,
    green_cap = true, green_cap_cooked = true,
    blue_cap = true, blue_cap_cooked = true,
    moon_cap = true, moon_cap_cooked = true,
}

local function mushroomStatsMod(inst, health_delta, hunger_delta, sanity_delta, food, feeder)
    if food ~= nil and MUSHROOM_PREFABS[food.prefab] then
        if health_delta < 0 then health_delta = 0 end
        if hunger_delta < 0 then hunger_delta = 0 end
        if sanity_delta < 0 then sanity_delta = 0 end
    end
    return health_delta, hunger_delta, sanity_delta
end

local start_inv = {
    "blind_dart",
    -- "sewing_kit",
--    "chester_eyebone",
--    "goldenaxe",
--	  "ruinshat",
	  -- "footballhat",
	  -- "winterhat",
--	  "flowerhat",
}

local function doCamouflage(inst)

    if not inst.isCamouflage then
        inst.isCamouflage = true
        inst.AnimState:SetMultColour(.8,.8,.8,.8)
        inst.DynamicShadow:Enable(false)

        -- ステルス中は敵との当たり判定を無効化（すり抜ける）
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)
        inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)

        -- ステルス中、敵の攻撃を継続的にブロック（ターゲットは維持）
        local function blankNearbyAttacks()
            local x,y,z = inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, 20)
            for k,v in pairs(ents) do
                if v.components.combat and v.components.combat.target == inst then
                    v.components.combat:BlankOutAttacks(1)
                end
            end
        end
        blankNearbyAttacks()
        inst._blankOutTask = inst:DoPeriodicTask(.5, blankNearbyAttacks)
    end
end

local function updCamouflagePrm(inst)
    local x, _, z = inst.Transform:GetWorldPosition()
    inst.camouflage_x = x
    inst.camouflage_z = z
    inst.camouflage_t = GetTime()
    inst.camouflage_h = inst.components.health ~= nil and inst.components.health.currenthealth or 0
end

local function disableCamouflage(inst)

    updCamouflagePrm(inst)

    if not inst.isCamouflage then return end

    inst.isCamouflage = false
    inst.AnimState:SetMultColour(1.0,1.0,1.0,1.0)
    inst.DynamicShadow:Enable(true)

    -- 当たり判定を復元
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)

    -- ステルス中の攻撃ブロックを停止
    if inst._blankOutTask then
        inst._blankOutTask:Cancel()
        inst._blankOutTask = nil
    end

    inst.components.combat.min_attack_period = TUNING.WILSON_ATTACK_PERIOD - (TUNING.WILSON_ATTACK_PERIOD * 0.4)
    if inst.resetAttackSpeedTask ~= nil then
        inst.resetAttackSpeedTask:Cancel()
    end
    inst.resetAttackSpeedTask = inst:DoTaskInTime(5.0, function(inst)
        inst.components.combat.min_attack_period = TUNING.WILSON_ATTACK_PERIOD
        inst.resetAttackSpeedTask = nil
    end, inst)

end

local function checkCamouflage(inst)

    if inst.components.health == nil then
        return
    end

    if inst.components.health.currenthealth < inst.camouflage_h then
        disableCamouflage(inst)
        return
    end

    local x, _, z = inst.Transform:GetWorldPosition()
    local running = inst.components.locomotor:WantsToRun()
    if x == inst.camouflage_x and z == inst.camouflage_z and not running then
        if GetTime() - inst.camouflage_t > 1.5 then doCamouflage(inst) end
    else
        disableCamouflage(inst)
    end
end

local function onAttacked(inst, data)
    disableCamouflage(inst)
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
    if inst.resetMoveQuickTask ~= nil then
        inst.resetMoveQuickTask:Cancel()
    end
    inst.resetMoveQuickTask = inst:DoTaskInTime(5.0, function(inst)
        inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * TEEMO_SPEED_MULT
        inst.resetMoveQuickTask = nil
    end, inst)
end

local function stopPassive(inst)
    if inst.camouflageTask ~= nil then
        inst.camouflageTask:Cancel()
        inst.camouflageTask = nil
    end

    if inst._blankOutTask ~= nil then
        inst._blankOutTask:Cancel()
        inst._blankOutTask = nil
    end

    if inst.resetMoveQuickTask ~= nil then
        inst.resetMoveQuickTask:Cancel()
        inst.resetMoveQuickTask = nil
    end

    if inst.resetAttackSpeedTask ~= nil then
        inst.resetAttackSpeedTask:Cancel()
        inst.resetAttackSpeedTask = nil
    end
end

local function startPassive(inst)
    updCamouflagePrm(inst)
    inst.camouflageTask = inst:DoPeriodicTask(.5, checkCamouflage)
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * TEEMO_SPEED_MULT
end

local function stopNoxiousTrapRecovery(inst)
    if inst._noxiousTrapRecoveryTask ~= nil then
        inst._noxiousTrapRecoveryTask:Cancel()
        inst._noxiousTrapRecoveryTask = nil
    end
end

local function startNoxiousTrapRecovery(inst)
    stopNoxiousTrapRecovery(inst)
    inst._noxiousTrapTimer = inst._noxiousTrapTimer or 0
    inst._noxiousTrapRecoveryTask = inst:DoPeriodicTask(1, function()
        local stacks = inst._noxiousTrapStacks:value()
        if stacks >= NOXIOUS_TRAP_MAX_STACKS then
            inst._noxiousTrapTimer = 0
            return
        end
        inst._noxiousTrapTimer = inst._noxiousTrapTimer + 1
        if inst._noxiousTrapTimer >= NOXIOUS_TRAP_RECOVERY_INTERVAL then
            inst._noxiousTrapTimer = 0
            inst._noxiousTrapStacks:set(stacks + 1)
        end
    end)
end

local function onDeath(inst, data)
    inst.deathcause = data ~= nil and data.cause or "unknown"
    if inst.deathcause == "file_load" then return end
    disableCamouflage(inst)
    stopPassive(inst)
    stopNoxiousTrapRecovery(inst)
end

local common_postinit = function(inst)
	inst.soundsname = "teemo"
	inst.MiniMapEntity:SetIcon( "teemo.tex" )
    inst:AddTag("teemo")

    -- talk_LPを1回再生に変更（ループ・途中停止を防止）
    inst:ListenForEvent("ontalk", function()
        inst:DoTaskInTime(0, function()
            -- ステートグラフが開始したループ再生を停止
            inst.SoundEmitter:KillSound("talk")
            -- 前回のボイスを停止してから1回再生
            inst.SoundEmitter:KillSound("teemo_voice")
            inst.SoundEmitter:PlaySound("dontstarve/characters/teemo/talk_LP", "teemo_voice")
        end)
    end)

    -- ノクサストラップ スタック数ネットワーク変数（クライアント同期用）
    inst._noxiousTrapStacks = net_byte(inst.GUID, "teemo._noxiousTrapStacks", "noxioustrapstacksdirty")

    -- 移動開始時にmoveボイスを再生（クライアント側）
    inst:ListenForEvent("startmoving", function()
        inst.SoundEmitter:PlaySound("dontstarve/characters/teemo/move")
    end)

    -- 上向き攻撃時にblind_dartが体の下にはみ出る対策（クライアント側）
    inst._dartHiding = false
    inst:DoPeriodicTask(0, function()
        if inst:HasTag("blind_dart_equipped") then
            local isUp = inst.AnimState:GetCurrentFacing() == FACING_UP
            local isAttacking = inst.AnimState:IsCurrentAnimation("dart")
                             or inst.AnimState:IsCurrentAnimation("dart_pre")

            if isUp and isAttacking then
                if not inst._dartHiding then
                    inst._dartHiding = true
                    inst.AnimState:SetSymbolMultColour("swap_object", 0, 0, 0, 0)
                end
            elseif inst._dartHiding then
                inst.AnimState:SetSymbolMultColour("swap_object", 1, 1, 1, 1)
                inst._dartHiding = false
            end
        end
    end)
end


-- ACTIONS.GIVE.fn = function(act)
--     if act.target ~= nil and act.target.components.trader ~= nil then
--         act.target.components.trader:AcceptGift(act.doer, act.invobject)
--         return true
--     end
-- end

local master_postinit = function(inst)

	inst.components.health:SetMaxHealth(TEEMO_HEALTH)
	inst.components.hunger:SetMax(TEEMO_HUNGER)
	inst.components.sanity:SetMax(TEEMO_SANITY)
	inst.components.combat.damagemultiplier = TEEMO_DAMAGE_MULT
	inst.components.health:SetAbsorptionAmount(TEEMO_ABSORPTION)

    -- パッシブ「キノコの達人」
    if TEEMO_MUSHROOM_IMMUNITY then
        inst.components.eater.custom_stats_mod_fn = mushroomStatsMod
    end

    startPassive(inst)

    -- スポーン時にspwnボイスを再生
    inst:DoTaskInTime(0.5, function()
        inst.SoundEmitter:PlaySound("dontstarve/characters/teemo/spwn")
    end)

--    inst:ListenForEvent("performaction", function() disableCamouflage(inst) end)
    inst:ListenForEvent("buildsuccess", function() disableCamouflage(inst) end)
    inst:ListenForEvent("equipped", function() disableCamouflage(inst) end)
    inst:ListenForEvent("onpickup", function() disableCamouflage(inst) end)
    inst:ListenForEvent("ondropped", function() disableCamouflage(inst) end)
    inst:ListenForEvent("oneatsomething", function() disableCamouflage(inst) end)
    inst:ListenForEvent("oneaten", function() disableCamouflage(inst) end)
    inst:ListenForEvent("working", function()
        disableCamouflage(inst)
        -- 作業時に一定確率でemoteボイスを再生
        if math.random() < 0.25 then
            inst.SoundEmitter:PlaySound("dontstarve/characters/teemo/emote")
        end
    end)
    -- 採取時に一定確率でemoteボイスを再生
    inst:ListenForEvent("picksomething", function()
        if math.random() < 0.25 then
            inst.SoundEmitter:PlaySound("dontstarve/characters/teemo/emote")
        end
    end)
    -- 収穫時に一定確率でemoteボイスを再生
    inst:ListenForEvent("harvest", function()
        if math.random() < 0.25 then
            inst.SoundEmitter:PlaySound("dontstarve/characters/teemo/emote")
        end
    end)
    inst:ListenForEvent("onattackother", function(inst, data)
        disableCamouflage(inst)
        -- Blind Dart攻撃時、GetAttackedの前に毒マークを設定（初撃即死でも食料腐敗を適用）
        if data and data.weapon and data.weapon:HasTag("blowdart") and data.target then
            TeemoPoison.markTeemoPoisoned(data.target)
        end
        -- 攻撃時に一定確率でattackボイスを再生
        if math.random() < 0.15 then
            inst.SoundEmitter:PlaySound("dontstarve/characters/teemo/attack")
        end
    end)
    inst:ListenForEvent("attacked", onAttacked)
    inst:ListenForEvent("death", onDeath)
    inst:ListenForEvent("ms_respawnedfromghost", function()
        startPassive(inst)
        startNoxiousTrapRecovery(inst)
        -- リスポーン時にspwnボイスを再生
        inst.SoundEmitter:PlaySound("dontstarve/characters/teemo/spwn")
    end)

    -- 最終スロットをノクサストラップ専用にする（アイテム配置を禁止）
    local _CanTakeItemInSlot = inst.components.inventory.CanTakeItemInSlot
    rawset(inst.components.inventory, "CanTakeItemInSlot", function(self, item, slot)
        if slot == self.maxslots then return false end
        return _CanTakeItemInSlot(self, item, slot)
    end)

    -- ノクサストラップ スタック管理
    inst._noxiousTrapStacks:set(NOXIOUS_TRAP_INITIAL_STACKS)
    inst._noxiousTrapTimer = 0
    startNoxiousTrapRecovery(inst)

    -- セーブ/ロード
    local _OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if _OnSave then _OnSave(inst, data) end
        data.noxious_trap_stacks = inst._noxiousTrapStacks:value()
        data.noxious_trap_timer = inst._noxiousTrapTimer
    end

    local _OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if _OnLoad then _OnLoad(inst, data) end
        if data then
            if data.noxious_trap_stacks then
                inst._noxiousTrapStacks:set(data.noxious_trap_stacks)
            end
            if data.noxious_trap_timer then
                inst._noxiousTrapTimer = data.noxious_trap_timer
            end
        end
    end

end

return MakePlayerCharacter("teemo", prefabs, assets, common_postinit, master_postinit, start_inv)
