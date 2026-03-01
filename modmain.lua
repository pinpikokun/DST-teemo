GLOBAL.NOXIOUS_TRAP_MAX_STACKS = 5

-- MOD設定値の読み込み
GLOBAL.TEEMO_HEALTH = GetModConfigData("health") or 100
GLOBAL.TEEMO_HUNGER = GetModConfigData("hunger") or 100
GLOBAL.TEEMO_SANITY = GetModConfigData("sanity") or 250
GLOBAL.TEEMO_DAMAGE_MULT = GetModConfigData("damage_multiplier") or 1.0
GLOBAL.TEEMO_ABSORPTION = GetModConfigData("absorption") or 0
GLOBAL.TEEMO_SPEED_MULT = GetModConfigData("speed_multiplier") or 1.25
GLOBAL.TEEMO_BLIND_DART_DAMAGE = GetModConfigData("blind_dart_damage") or 5
GLOBAL.TEEMO_BLIND_DART_DOT = GetModConfigData("blind_dart_dot") or 5
GLOBAL.TEEMO_NOXIOUS_TRAP_DAMAGE = GetModConfigData("noxious_trap_damage") or 20
GLOBAL.TEEMO_NOXIOUS_TRAP_DOT = GetModConfigData("noxious_trap_dot") or 10
GLOBAL.TEEMO_BLIND_DART_DURABILITY = GetModConfigData("blind_dart_durability")
if GLOBAL.TEEMO_BLIND_DART_DURABILITY == nil then GLOBAL.TEEMO_BLIND_DART_DURABILITY = 2 end
GLOBAL.TEEMO_POISON_SPOIL_PERCENT = GetModConfigData("poison_spoil_percent")
if GLOBAL.TEEMO_POISON_SPOIL_PERCENT == nil then GLOBAL.TEEMO_POISON_SPOIL_PERCENT = 0.7 end
GLOBAL.TEEMO_MUSHROOM_IMMUNITY = GetModConfigData("mushroom_immunity")
if GLOBAL.TEEMO_MUSHROOM_IMMUNITY == nil then GLOBAL.TEEMO_MUSHROOM_IMMUNITY = true end
GLOBAL.TEEMO_SHOW_DAMAGE_NUMBERS = GetModConfigData("show_damage_numbers")
if GLOBAL.TEEMO_SHOW_DAMAGE_NUMBERS == nil then GLOBAL.TEEMO_SHOW_DAMAGE_NUMBERS = true end

-- サモナースペル設定値
GLOBAL.TEEMO_FLASH_COOLDOWN = 300
GLOBAL.TEEMO_FLASH_RANGE = 8
GLOBAL.TEEMO_IGNITE_COOLDOWN = 180
GLOBAL.TEEMO_IGNITE_DAMAGE = GetModConfigData("ignite_damage") or 20
GLOBAL.TEEMO_IGNITE_RANGE = 4

-- 予約スロット数（ノクサストラップ + フラッシュ + イグナイト）
GLOBAL.TEEMO_RESERVED_SLOTS = 3

-- ダメージ数値カラータイプ
local TEEMO_DMG_COLOUR_PHYSICAL = 1
local TEEMO_DMG_COLOUR_MAGIC    = 2
local TEEMO_DMG_COLOUR_TRUE     = 3
GLOBAL.TEEMO_DMG_COLOUR_PHYSICAL = TEEMO_DMG_COLOUR_PHYSICAL
GLOBAL.TEEMO_DMG_COLOUR_MAGIC    = TEEMO_DMG_COLOUR_MAGIC
GLOBAL.TEEMO_DMG_COLOUR_TRUE     = TEEMO_DMG_COLOUR_TRUE

-- サーバー→クライアントRPC送信ヘルパー（ダメージ数字表示）
local function TeemoShowDamageNumber(target, damage, colour_type)
    if not GLOBAL.TEEMO_SHOW_DAMAGE_NUMBERS then return end
    if not GLOBAL.TheWorld.ismastersim then return end
    if target == nil or not target:IsValid() then return end
    local x, y, z = target.Transform:GetWorldPosition()
    local players = GLOBAL.FindPlayersInRange(x, y, z, 40)
    for _, player in pairs(players) do
        GLOBAL.SendModRPCToClient(
            GLOBAL.CLIENT_MOD_RPC["teemo"]["show_damage_number"],
            player.userid, x, y, z, math.abs(damage), colour_type or TEEMO_DMG_COLOUR_TRUE
        )
    end
end
GLOBAL.TeemoShowDamageNumber = TeemoShowDamageNumber

-- キャラクター選択画面のステータス表示用（TUNINGテーブルに登録）
GLOBAL.TUNING.TEEMO_HEALTH = GLOBAL.TEEMO_HEALTH
GLOBAL.TUNING.TEEMO_HUNGER = GLOBAL.TEEMO_HUNGER
GLOBAL.TUNING.TEEMO_SANITY = GLOBAL.TEEMO_SANITY

-- キャラクター選択画面の初期アイテム表示用
GLOBAL.TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.TEEMO = {"blind_dart", "noxious_trap"}
RegisterInventoryItemAtlas("images/inventoryimages/blind_dart.xml", "blind_dart.tex")
RegisterInventoryItemAtlas("images/inventoryimages/noxious_trap.xml", "noxious_trap.tex")

local STRINGS = GLOBAL.STRINGS

STRINGS.CHARACTER_TITLES.teemo = "Captain Teemo"
STRINGS.CHARACTER_NAMES.teemo = "Captain Teemo"
STRINGS.CHARACTER_DESCRIPTIONS.teemo = "*Goes invisible when standing still\n*Has a poison blowdart\n*Can deploy Noxious Traps\n*Expert at eating mushrooms"
STRINGS.CHARACTER_QUOTES.teemo = "\"on duty !! \""
STRINGS.CHARACTER_ABOUTME.teemo = "Size doesn't mean everything."
STRINGS.CHARACTERS.TEEMO = GLOBAL.require "speech_teemo"
STRINGS.NAMES.TEEMO = "Teemo"
STRINGS.SKIN_NAMES.teemo_none = "Teemo"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TEEMO = 
{
    GENERIC = "It's Teemo!",
    ATTACKER = "That Teemo looks shifty...",
    MURDERER = "Murderer!",
    REVIVER = "Teemo, friend of ghosts.",
    GHOST = "Teemo could use a heart.",
}

PrefabFiles = {
    "teemo",
    "teemo_none",
    "noxious_trap",
    "explode_noxious_trap",
    "toxic_effect_by_teemo",
    "blind_dart",
    "blind_dart_projectile",
    "blind_effect",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/teemo.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/teemo.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/teemo.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/teemo.xml" ),

    Asset( "IMAGE", "bigportraits/teemo.tex" ),
    Asset( "ATLAS", "bigportraits/teemo.xml" ),
    
    Asset( "IMAGE", "images/map_icons/teemo.tex" ),
    Asset( "ATLAS", "images/map_icons/teemo.xml" ),
    
    Asset( "IMAGE", "images/avatars/avatar_teemo.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_teemo.xml" ),
    
    Asset( "IMAGE", "images/avatars/avatar_ghost_teemo.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_teemo.xml" ),

    Asset( "IMAGE", "images/avatars/self_inspect_teemo.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_teemo.xml" ),

    Asset( "IMAGE", "bigportraits/teemo_none.tex" ),
    Asset( "ATLAS", "bigportraits/teemo_none.xml" ),
    
    Asset( "IMAGE", "images/inventoryimages/blind_dart.tex" ),
    Asset( "ATLAS", "images/inventoryimages/blind_dart.xml" ),
    
    Asset( "IMAGE", "images/inventoryimages/noxious_trap.tex" ),
    Asset( "ATLAS", "images/inventoryimages/noxious_trap.xml" ),

    Asset( "IMAGE", "images/hud/teemotab.tex" ),
    Asset( "ATLAS", "images/hud/teemotab.xml" ),

    Asset("SOUNDPACKAGE", "sound/DST-teemo.fev"),
    Asset("SOUND", "sound/DST-teemo_bank00.fsb"),

    Asset( "IMAGE", "images/inventoryimages/summoner_spell_flash.tex" ),
    Asset( "ATLAS", "images/inventoryimages/summoner_spell_flash.xml" ),

    Asset( "IMAGE", "images/inventoryimages/summoner_spell_ignite.tex" ),
    Asset( "ATLAS", "images/inventoryimages/summoner_spell_ignite.xml" ),
}

RemapSoundEvent( "dontstarve/characters/teemo/death_voice", "DST-teemo/dontstarve/characters/DST-teemo/death_voice" )
RemapSoundEvent( "dontstarve/characters/teemo/hurt", "DST-teemo/dontstarve/characters/DST-teemo/hurt" )
RemapSoundEvent( "dontstarve/characters/teemo/talk_LP", "DST-teemo/dontstarve/characters/DST-teemo/talk_LP" )
RemapSoundEvent( "dontstarve/characters/teemo/emote", "DST-teemo/dontstarve/characters/DST-teemo/emote" )
RemapSoundEvent( "dontstarve/characters/teemo/ghost_LP", "DST-teemo/dontstarve/characters/DST-teemo/ghost_LP" )
RemapSoundEvent( "dontstarve/characters/teemo/move", "DST-teemo/dontstarve/characters/DST-teemo/move" )
RemapSoundEvent( "dontstarve/characters/teemo/spwn", "DST-teemo/dontstarve/characters/DST-teemo/spwn" )
RemapSoundEvent( "dontstarve/characters/teemo/attack", "DST-teemo/dontstarve/characters/DST-teemo/attack" )

-- ========== Blind Dart 右クリック発射システム ==========

-- カスタムアクション: 右クリックでBlind Dart発射
AddAction("TEEMO_SHOOT_DART", "Shoot", function(act)
    local weapon = act.invobject
    if weapon == nil or not weapon:IsValid() then return false end

    local doer = act.doer
    if doer == nil or not doer:IsValid() then return false end

    local target = act.target
    local target_pos = act:GetActionPoint()

    local proj = GLOBAL.SpawnPrefab("blind_dart_projectile")
    if proj == nil then return false end

    -- 攻撃者・武器の参照を格納（onhitで使用）
    proj._teemo_weapon = weapon
    proj._teemo_attacker = doer

    -- ターゲット方向を向く
    if target ~= nil and target:IsValid() then
        doer:FacePoint(target.Transform:GetWorldPosition())
    elseif target_pos ~= nil then
        doer:FacePoint(target_pos:Get())
    end

    -- 飛翔体を攻撃者の位置に配置
    local x, y, z = doer.Transform:GetWorldPosition()
    proj.Transform:SetPosition(x, y, z)

    if target ~= nil and target:IsValid() and target.components.combat then
        -- エンティティへの追尾発射
        -- NOTE: DST標準の Throw は (owner, target) の2引数。3つ目の doer は無視される
        proj.components.projectile:Throw(weapon, target, doer)
    else
        -- 地面クリック: クリック地点近くの敵を検索
        if target_pos then
            local px, py, pz = target_pos:Get()
            local ents = GLOBAL.TheSim:FindEntities(px, py, pz, 2, { "_combat" }, { "player", "INLIMBO" })
            local best_target = nil
            local best_dist = math.huge
            for _, ent in pairs(ents) do
                if ent ~= doer and ent.components.combat and ent.components.health
                    and ent.components.health.currenthealth > 0 then
                    local ex, ey, ez = ent.Transform:GetWorldPosition()
                    local d = (ex - px)*(ex - px) + (ez - pz)*(ez - pz)
                    if d < best_dist then
                        best_dist = d
                        best_target = ent
                    end
                end
            end
            if best_target ~= nil then
                proj.components.projectile:Throw(weapon, best_target, doer)
            else
                -- 敵がいない: 視覚演出のみ（まっすぐ飛んで消える）
                proj:RemoveComponent("projectile")
                proj:AddTag("NOCLICK")
                proj.AnimState:PlayAnimation("dart_pipe")
                proj.AnimState:SetOrientation(GLOBAL.ANIM_ORIENTATION.OnGround)
                proj:FacePoint(px, py, pz)
                -- 発射位置をdoerの前方3ユニットにオフセット（LaunchOffset相当）
                local dx, dz = px - x, pz - z
                local dist = math.sqrt(dx * dx + dz * dz)
                if dist > 0 then
                    proj.Transform:SetPosition(x + dx / dist * 3, 0.5, z + dz / dist * 3)
                end
                proj.Physics:SetMotorVel(15, 0, 0)
                proj:DoTaskInTime(0.5, function() if proj:IsValid() then proj:Remove() end end)
            end
        else
            proj:Remove()
            return false
        end
    end

    -- カモフラージュ解除
    if doer.disableCamouflage then
        doer.disableCamouflage()
    end

    return true
end)
GLOBAL.ACTIONS.TEEMO_SHOOT_DART.priority = -1
GLOBAL.ACTIONS.TEEMO_SHOOT_DART.distance = 8
GLOBAL.ACTIONS.TEEMO_SHOOT_DART.rmb = true

-- ComponentAction: 地面右クリック
AddComponentAction("POINT", "weapon", function(inst, doer, pos, actions, right, target)
    if right and inst:HasTag("blowdart") and doer:HasTag("teemo")
        and not (doer.replica.rider and doer.replica.rider:IsRiding()) then
        table.insert(actions, GLOBAL.ACTIONS.TEEMO_SHOOT_DART)
    end
end)

-- ComponentAction: エンティティ右クリック
AddComponentAction("EQUIPPED", "weapon", function(inst, doer, target, actions, right)
    if right and inst:HasTag("blowdart") and doer:HasTag("teemo")
        and not (doer.replica.rider and doer.replica.rider:IsRiding())
        and target and target ~= doer and target:HasTag("_combat") then
        table.insert(actions, GLOBAL.ACTIONS.TEEMO_SHOOT_DART)
    end
end)

-- Stategraph ActionHandler（サーバー）
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.TEEMO_SHOOT_DART, function(inst, action)
    local equip = inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
    if equip ~= nil
        and equip:HasTag("blowdart")
        and not (inst.components.rider and inst.components.rider:IsRiding())
        and not (inst.components.health and inst.components.health:IsDead()) then
        if not inst.sg:HasStateTag("attack") then
            return "teemo_shoot_dart"
        end
    end
end))

-- Stategraph ActionHandler（クライアント）
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.TEEMO_SHOOT_DART, function(inst, action)
    local equip = inst.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
    if equip ~= nil
        and equip:HasTag("blowdart")
        and not (inst.replica.rider and inst.replica.rider:IsRiding())
        and not GLOBAL.IsEntityDead(inst, true) then
        if not inst.sg:HasStateTag("attack") then
            return "teemo_shoot_dart"
        end
    end
end))

-- Stategraph State: teemo_shoot_dart（サーバー）
AddStategraphState("wilson", GLOBAL.State {
    name = "teemo_shoot_dart",
    tags = { "attack", "abouttoattack", "notalking", "autopredict" },

    onenter = function(inst)
        if inst.components.combat:InCooldown() then
            inst.sg:RemoveStateTag("abouttoattack")
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle", true)
            return
        end

        local buffaction = inst:GetBufferedAction()
        local target = buffaction ~= nil and buffaction.target or nil

        inst.components.combat:StartAttack()
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("dart")

        if target ~= nil and target:IsValid() then
            inst:FacePoint(target.Transform:GetWorldPosition())
        elseif buffaction then
            local pos = buffaction:GetActionPoint()
            if pos then inst:FacePoint(pos:Get()) end
        end

        inst.sg.statemem.action = buffaction
        inst.sg:SetTimeout(inst.components.combat.min_attack_period)
    end,

    ontimeout = function(inst)
        inst.sg:RemoveStateTag("attack")
        inst.sg:AddStateTag("idle")
    end,

    timeline = {
        GLOBAL.TimeEvent(6 * GLOBAL.FRAMES, function(inst)
            inst.sg:RemoveStateTag("abouttoattack")
            inst.bufferedaction = inst.sg.statemem.action
            inst:PerformBufferedAction()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_shoot")
        end),
    },

    events = {
        GLOBAL.EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
        GLOBAL.EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        GLOBAL.EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end
        end),
    },

    onexit = function(inst)
        if inst.sg:HasStateTag("abouttoattack") then
            inst.components.combat:CancelAttack()
        end
    end,
})

-- Stategraph State: teemo_shoot_dart（クライアント）
AddStategraphState("wilson_client", GLOBAL.State {
    name = "teemo_shoot_dart",
    tags = { "attack", "notalking", "abouttoattack" },

    onenter = function(inst)
        local combat = inst.replica.combat
        if combat:InCooldown() then
            inst.sg:RemoveStateTag("abouttoattack")
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle", true)
            return
        end

        combat:StartAttack()
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("dart")

        local buffaction = inst:GetBufferedAction()
        if buffaction ~= nil then
            inst:PerformPreviewBufferedAction()
            if buffaction.target ~= nil and buffaction.target:IsValid() then
                inst:FacePoint(buffaction.target:GetPosition())
            end
        end

        local cooldown = combat:MinAttackPeriod()
        inst.sg:SetTimeout(math.max(cooldown, 0.5))
    end,

    ontimeout = function(inst)
        inst.sg:RemoveStateTag("attack")
        inst.sg:AddStateTag("idle")
    end,

    timeline = {
        GLOBAL.TimeEvent(6 * GLOBAL.FRAMES, function(inst)
            inst.sg:RemoveStateTag("abouttoattack")
            inst:ClearBufferedAction()
        end),
    },

    events = {
        GLOBAL.EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end
        end),
    },

    onexit = function(inst)
        if inst.sg:HasStateTag("abouttoattack") then
            inst.replica.combat:CancelAttack()
        end
    end,
})

local skin_modes = {
    {
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle",
        scale = 0.75,
        offset = { 0, -25 },
    },
}
AddModCharacter("teemo", "MALE", skin_modes)
AddMinimapAtlas("images/map_icons/teemo.xml")

GLOBAL.PREFAB_SKINS["teemo"] = { "teemo_none" }

-- パッシブ「キノコの達人」: 月キノコの睡眠をテーモのみ無効化
if GLOBAL.TEEMO_MUSHROOM_IMMUNITY then
    AddPrefabPostInit("moon_cap", function(inst)
        if not GLOBAL.TheWorld.ismastersim then return end
        local _oneaten = inst.components.edible.oneaten
        inst.components.edible:SetOnEatenFn(function(inst, eater)
            if eater:HasTag("teemo") then return end
            if _oneaten ~= nil then _oneaten(inst, eater) end
        end)
    end)
end

-- テーモ専用クラフトタブ
local teemoTab = AddRecipeTab(
    "Teemo Items"
    ,998
    ,GLOBAL.resolvefilepath("images/hud/teemotab.xml")
    ,"teemotab.tex"
    ,"teemo"
)

-- ブラインドダート クラフトレシピ（テーモ専用）
AddRecipe2("blind_dart", {
    GLOBAL.Ingredient("boards", 1),
    GLOBAL.Ingredient("green_cap", 1),
    GLOBAL.Ingredient("silk", 1),
    GLOBAL.Ingredient("stinger", 1),
    GLOBAL.Ingredient("rope", 1),
}, GLOBAL.TECH.NONE, {
    atlas = GLOBAL.resolvefilepath("images/inventoryimages/blind_dart.xml"),
    image = "blind_dart.tex",
    builder_tag = "teemo",
    tab = teemoTab,
}, {"CHARACTER"})

-- アイテムの名前・レシピ説明
STRINGS.NAMES.BLIND_DART = "Blind Dart"
STRINGS.RECIPE_DESC.BLIND_DART = "A toxic blowdart that blinds enemies.\nLoses durability when hit while equipped."

-- アイテムの名前 item name
STRINGS.NAMES.NOXIOUS_TRAP = "Noxious Trap"

-- サモナースペル: フラッシュ RPC（クライアントから座標を受け取りテレポート）
AddModRPCHandler("teemo", "use_flash", function(player, x, z)
    if not player:HasTag("teemo") then return end
    if player:HasTag("playerghost") then return end
    if player.components.rider ~= nil and player.components.rider:IsRiding() then return end
    if player._flashCooldown == nil or player._flashCooldown:value() > 0 then return end

    local px, py, pz = player.Transform:GetWorldPosition()
    local tx, tz = x, z

    -- 範囲チェック
    local dx, dz = tx - px, tz - pz
    local dist = math.sqrt(dx * dx + dz * dz)
    local maxRange = GLOBAL.TEEMO_FLASH_RANGE
    if dist > maxRange then
        -- 最大距離にクランプ
        local ratio = maxRange / dist
        tx = px + dx * ratio
        tz = pz + dz * ratio
    end

    -- 目的地が歩行不可の場合の壁抜け判定（LoL準拠）
    if not GLOBAL.TheWorld.Map:IsPassableAtPoint(tx, 0, tz) then
        local dir_x, dir_z = dx, dz
        local len = math.sqrt(dir_x * dir_x + dir_z * dir_z)
        if len > 0 then
            dir_x, dir_z = dir_x / len, dir_z / len
        end

        -- 1. 壁抜け: 目標地点からさらに同じ方向に3ユニット先まで歩行可能地点を探す
        local wallFlashFound = false
        local checkDist = math.min(dist, maxRange)
        for d = checkDist + 0.5, checkDist + 3, 0.5 do
            local cx = px + dir_x * d
            local cz = pz + dir_z * d
            if GLOBAL.TheWorld.Map:IsPassableAtPoint(cx, 0, cz) then
                tx, tz = cx, cz
                wallFlashFound = true
                break
            end
        end

        -- 2. 壁抜けできなければ手前の歩行可能地点にフォールバック
        if not wallFlashFound then
            local found = false
            for d = checkDist, 0.5, -0.5 do
                local cx = px + dir_x * d
                local cz = pz + dir_z * d
                if GLOBAL.TheWorld.Map:IsPassableAtPoint(cx, 0, cz) then
                    tx, tz = cx, cz
                    found = true
                    break
                end
            end
            if not found then return end
        end
    end

    -- クールダウン即時開始（連打防止）
    player._flashCooldown:set(GLOBAL.TEEMO_FLASH_COOLDOWN)

    -- 発動中は移動完全停止（死亡タイミング競合時のクラッシュ防止）
    if player.components.locomotor == nil then return end
    player.components.locomotor:Stop()
    player.components.locomotor:Clear()
    player.Physics:Stop()
    player:AddTag("busy")

    -- 出発エフェクト
    local puff = GLOBAL.SpawnPrefab("shadow_puff")
    if puff ~= nil then
        puff.Transform:SetPosition(px, py, pz)
    end

    -- テレポート実行
    if player.Physics ~= nil then
        player.Physics:Teleport(tx, 0, tz)
    end

    player:RemoveTag("busy")
end)

-- サモナースペル: イグナイト RPC（プレイヤー周囲の敵に炎上DOT）
AddModRPCHandler("teemo", "use_ignite", function(player)
    if not player:HasTag("teemo") then return end
    if player:HasTag("playerghost") then return end
    if player.components.rider ~= nil and player.components.rider:IsRiding() then return end
    if player._igniteCooldown == nil or player._igniteCooldown:value() > 0 then return end

    local x, y, z = player.Transform:GetWorldPosition()
    local range = GLOBAL.TEEMO_IGNITE_RANGE

    -- playerタグ除外（PvP時はteemoのみ除外）
    local nonTarget = GLOBAL.TheNet:GetPVPEnabled() and "teemo" or "player"

    -- 敵意のある対象から最も近い単体を選択
    local target = nil
    local closestDist = math.huge
    local ents = GLOBAL.TheSim:FindEntities(x, y, z, range, {"_combat"})
    for _, v in pairs(ents) do
        if v ~= player
            and v.components.combat
            and not v:HasTag(nonTarget)
            and not v:HasTag("companion")
            and v.components.health
            and v.components.health.currenthealth > 0
            and (v:HasTag("hostile")
                or (v.components.combat.target == player)) then
            local vx, vy, vz = v.Transform:GetWorldPosition()
            local d = (vx - x) * (vx - x) + (vz - z) * (vz - z)
            if d < closestDist then
                closestDist = d
                target = v
            end
        end
    end

    -- 敵意のある対象がいなければ発動しない（CD・エフェクト・音なし）
    if target == nil then return end

    -- クールダウン即時開始（連打防止）
    player._igniteCooldown:set(GLOBAL.TEEMO_IGNITE_COOLDOWN)

    local v = target

    -- 炎上エフェクト（burnable持ちなら着火、延焼は防止）
    if v.components.burnable ~= nil and not v.components.burnable:IsBurning() and not v:HasTag("fireimmune") then
        v.components.burnable:Ignite(nil, player)
        if v.components.propagator ~= nil then
            v.components.propagator:StopSpreading()
        end
    end

    -- 敵に炎の飛沫エフェクト
    local hitfx = GLOBAL.SpawnPrefab("firesplash_fx")
    if hitfx ~= nil then
        local vx, vy, vz = v.Transform:GetWorldPosition()
        hitfx.Transform:SetPosition(vx, vy, vz)
    end

    -- トゥルーダメージDOT（毎秒 × 5秒間、防御無視でヘルス直接減算）
    local dmg = GLOBAL.TEEMO_IGNITE_DAMAGE
    if v:HasTag("player") then
        dmg = dmg * 0.3
    end

    -- 既存のイグナイトDOTがあればキャンセル
    if v._igniteDotTask ~= nil then
        v._igniteDotTask:Cancel()
        v._igniteDotTask = nil
    end
    if v._igniteDotEndTask ~= nil then
        v._igniteDotEndTask:Cancel()
        v._igniteDotEndTask = nil
    end

    v._igniteDotTask = v:DoPeriodicTask(1.0, function()
        if not v:IsValid() or v.components.health == nil or v.components.health.currenthealth <= 0 then
            if v._igniteDotTask ~= nil then
                v._igniteDotTask:Cancel()
                v._igniteDotTask = nil
            end
            return
        end
        -- トゥルーダメージ（DoDelta で直接HP減算、防御無視）
        v.components.health:DoDelta(-dmg, nil, "ignite")
        TeemoShowDamageNumber(v, dmg, TEEMO_DMG_COLOUR_TRUE)
    end)

    -- 5秒後にDOT停止（5回目のティック確定後に停止するため+0.05）
    v._igniteDotEndTask = v:DoTaskInTime(5.05, function()
        if v._igniteDotTask ~= nil then
            v._igniteDotTask:Cancel()
            v._igniteDotTask = nil
        end
        v._igniteDotEndTask = nil
    end)

    -- 発動エフェクト（プレイヤー位置に炎リング + 発動音）
    local ringfx = GLOBAL.SpawnPrefab("firesplash_fx")
    if ringfx ~= nil then
        ringfx.Transform:SetPosition(x, y, z)
    end
    player.SoundEmitter:PlaySound("dontstarve/common/fireBurstLarge")
end)

-- ノクサストラップ スタック消費RPC
AddModRPCHandler("teemo", "use_noxious_trap_stack", function(player)
    if player:HasTag("teemo")
        and not player:HasTag("playerghost")
        and not (player.components.rider ~= nil and player.components.rider:IsRiding())
        and player._noxiousTrapStacks
        and player._noxiousTrapStacks:value() > 0 then
        player._noxiousTrapStacks:set(player._noxiousTrapStacks:value() - 1)

        -- トラップ設置時はカモフラージュ解除
        if player.disableCamouflage then
            player.disableCamouflage()
        end

        -- 建設アニメーション（build_pre → build_loop）
        player.sg:GoToState("dolongaction")

        -- アニメーション途中でトラップを設置し、idle に戻す
        -- 移動等で中断された場合はスタックを返還
        player:DoTaskInTime(30 * GLOBAL.FRAMES, function()
            if not player.sg:HasStateTag("doing") then
                player._noxiousTrapStacks:set(player._noxiousTrapStacks:value() + 1)
                return
            end
            local trap = GLOBAL.SpawnPrefab("noxious_trap")
            local pos = player:GetPosition()

            -- まずプレイヤー位置で配置を試みる
            if trap.components.deployable:Deploy(pos, player) then
                player.sg:GoToState("idle")
                return
            end

            -- 失敗した場合、近くの有効な位置を探す
            local offset = GLOBAL.FindWalkableOffset(pos, math.random() * GLOBAL.TWOPI, 2, 8, false, true,
                function(pt)
                    return trap.components.deployable:CanDeploy(pt)
                end)

            if offset ~= nil then
                local deploy_pos = pos + offset
                if trap.components.deployable:Deploy(deploy_pos, player) then
                    player.sg:GoToState("idle")
                    return
                end
            end

            -- どこにも配置できなかった場合：スタック返還 & トラップ削除
            player._noxiousTrapStacks:set(player._noxiousTrapStacks:value() + 1)
            trap:Remove()
            player.sg:GoToState("idle")
        end)
    end
end)

-- テーモ用専用スロット（インベントリ右端3枠: ノクサストラップ, フラッシュ, イグナイト）
AddClassPostConstruct("widgets/inventorybar", function(self)
    if not self.owner:HasTag("teemo") then return end

    local NoxiousTrapSlot = require("widgets/noxioustrap_slot")
    local SummonerSpellSlot = require("widgets/summoner_spell_slot")

    local _Rebuild = self.Rebuild
    self.Rebuild = function(self, ...)
        -- 既存のカスタムスロットを破棄
        if self.noxioustrapslot ~= nil then
            self.noxioustrapslot:Kill()
            self.noxioustrapslot = nil
        end
        if self.flashslot ~= nil then
            self.flashslot:Kill()
            self.flashslot = nil
        end
        if self.igniteslot ~= nil then
            self.igniteslot:Kill()
            self.igniteslot = nil
        end

        _Rebuild(self, ...)

        local numSlots = #self.inv
        if numSlots < GLOBAL.TEEMO_RESERVED_SLOTS then return end

        -- 最後の3スロットを非表示＆操作無効にする
        for i = numSlots - GLOBAL.TEEMO_RESERVED_SLOTS + 1, numSlots do
            local slot = self.inv[i]
            if slot then
                slot:Hide()
                slot.OnControl = function() return false end
            end
        end

        -- スロット配置: [ノクサストラップ] [フラッシュ] [イグナイト]
        -- 右から3番目 = ノクサストラップ
        local trapSlot = self.inv[numSlots - 2]
        if trapSlot then
            local pos = trapSlot:GetPosition()
            self.noxioustrapslot = self.toprow:AddChild(NoxiousTrapSlot(self.owner))
            self.noxioustrapslot:SetPosition(pos.x, pos.y, pos.z)
        end

        -- 右から2番目 = フラッシュ
        local flashInvSlot = self.inv[numSlots - 1]
        if flashInvSlot then
            local pos = flashInvSlot:GetPosition()
            self.flashslot = self.toprow:AddChild(SummonerSpellSlot(self.owner, {
                spell_name = "flash",
                icon_atlas = "images/inventoryimages/summoner_spell_flash.xml",
                icon_tex = "summoner_spell_flash.tex",
                cooldown_event = "flashcooldowndirty",
                on_activate = function(slot)
                    slot:StartFlashTargeting()
                end,
            }))
            self.flashslot:SetPosition(pos.x, pos.y, pos.z)
        end

        -- 右から1番目 = イグナイト
        local igniteInvSlot = self.inv[numSlots]
        if igniteInvSlot then
            local pos = igniteInvSlot:GetPosition()
            self.igniteslot = self.toprow:AddChild(SummonerSpellSlot(self.owner, {
                spell_name = "ignite",
                icon_atlas = "images/inventoryimages/summoner_spell_ignite.xml",
                icon_tex = "summoner_spell_ignite.tex",
                cooldown_event = "ignitecooldowndirty",
                on_activate = function(slot)
                    SendModRPCToServer(MOD_RPC["teemo"]["use_ignite"])
                end,
            }))
            self.igniteslot:SetPosition(pos.x, pos.y, pos.z)
        end
    end

    self.rebuild_pending = true
end)

-- ========== フローティングダメージ数字 クライアントRPC ==========

local TEEMO_DMG_COLOURS = {
    [1] = {1, 0.51, 0.16, 1},  -- PHYSICAL: オレンジ
    [2] = {0.31, 0.78, 1, 1},  -- MAGIC: 水色
    [3] = {1, 1, 1, 1},        -- TRUE: 白
}

AddClientModRPCHandler("teemo", "show_damage_number", function(x, y, z, damage, colour_type)
    if not GLOBAL.TEEMO_SHOW_DAMAGE_NUMBERS then return end
    local TeemoPopupNumber = require("widgets/teemo_popupnumber")
    local player = GLOBAL.ThePlayer
    if not (player and player.HUD and player.HUD.popupstats_root) then return end

    local val = math.floor(damage + 0.5)
    local height = math.random(30, 50)
    local angle = (math.random() < 0.5 and 180 or 0) + GLOBAL.GetRandomMinMax(-30, 30)
    angle = angle * GLOBAL.DEGREES

    local colour = TEEMO_DMG_COLOURS[colour_type] or TEEMO_DMG_COLOURS[3]

    player.HUD.popupstats_root:AddChild(
        TeemoPopupNumber(player, tostring(val), 32,
            GLOBAL.Vector3(x, y, z),
            GLOBAL.Vector3(math.cos(angle), math.sin(angle), 0),
            height, colour)
    )
end)
