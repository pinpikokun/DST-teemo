
local MakePlayerCharacter = require ("prefabs/player_common")

local assets = {
    Asset( "ANIM", "anim/teemo.zip" ),
    Asset( "ANIM", "anim/ghost_teemo_build.zip" ),
}
local prefabs = {}

local NOXIOUS_TRAP_MAX_STACKS = NOXIOUS_TRAP_MAX_STACKS
local NOXIOUS_TRAP_INITIAL_STACKS = 3
local NOXIOUS_TRAP_RECOVERY_INTERVAL = 30

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
        inst:AddTag("notarget")
        inst.AnimState:SetMultColour(.8,.8,.8,.8)
        inst.DynamicShadow:Enable(false)

        -- ステルス突入時のみ、既にターゲットしている敵の攻撃を無効化
        local x,y,z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 20)
        for k,v in pairs(ents) do
            if v.components.combat and v.components.combat.target == inst then
                v.components.combat:BlankOutAttacks(.5)
            end
        end
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
    inst:RemoveTag("notarget")
    inst.AnimState:SetMultColour(1.0,1.0,1.0,1.0)
    inst.DynamicShadow:Enable(true)

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

    if inst.components.sanity == nil or inst.components.health == nil then
        return
    end

    if inst.components.sanity:GetPercent() < .3 then
        disableCamouflage(inst)
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
        inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * 1.26
        inst.resetMoveQuickTask = nil
    end, inst)
end

local function stopPassive(inst)
    if inst.camouflageTask ~= nil then
        inst.camouflageTask:Cancel()
        inst.camouflageTask = nil
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
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * 1.26
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
    stopPassive(inst)
    stopNoxiousTrapRecovery(inst)
end

local common_postinit = function(inst)
	inst.soundsname = "teemo"
	inst.MiniMapEntity:SetIcon( "teemo.tex" )
    inst:AddTag("teemo")

    -- ノクサストラップ スタック数ネットワーク変数（クライアント同期用）
    inst._noxiousTrapStacks = net_byte(inst.GUID, "teemo._noxiousTrapStacks", "noxioustrapstacksdirty")

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

	inst.components.health:SetMaxHealth(100)
	inst.components.hunger:SetMax(100)
	inst.components.sanity:SetMax(100)

    startPassive(inst)

--    inst:ListenForEvent("performaction", function() disableCamouflage(inst) end)
    inst:ListenForEvent("buildsuccess", function() disableCamouflage(inst) end)
    inst:ListenForEvent("equipped", function() disableCamouflage(inst) end)
    inst:ListenForEvent("onpickup", function() disableCamouflage(inst) end)
    inst:ListenForEvent("ondropped", function() disableCamouflage(inst) end)
    inst:ListenForEvent("oneatsomething", function() disableCamouflage(inst) end)
    inst:ListenForEvent("oneaten", function() disableCamouflage(inst) end)
    inst:ListenForEvent("working", function() disableCamouflage(inst) end)
    inst:ListenForEvent("onattackother", function() disableCamouflage(inst) end)
    inst:ListenForEvent("attacked", onAttacked)
    inst:ListenForEvent("death", onDeath)
    inst:ListenForEvent("ms_respawnedfromghost", function()
        startPassive(inst)
        startNoxiousTrapRecovery(inst)
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
