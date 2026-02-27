GLOBAL.NOXIOUS_TRAP_MAX_STACKS = 5

-- MOD設定値の読み込み
GLOBAL.TEEMO_HEALTH = GetModConfigData("health") or 100
GLOBAL.TEEMO_HUNGER = GetModConfigData("hunger") or 100
GLOBAL.TEEMO_SANITY = GetModConfigData("sanity") or 250
GLOBAL.TEEMO_DAMAGE_MULT = GetModConfigData("damage_multiplier") or 1.0
GLOBAL.TEEMO_ABSORPTION = GetModConfigData("absorption") or 0
GLOBAL.TEEMO_SPEED_MULT = GetModConfigData("speed_multiplier") or 1.25
GLOBAL.TEEMO_BLIND_DART_DAMAGE = GetModConfigData("blind_dart_damage") or 10
GLOBAL.TEEMO_BLIND_DART_DOT = GetModConfigData("blind_dart_dot") or 5
GLOBAL.TEEMO_NOXIOUS_TRAP_DAMAGE = GetModConfigData("noxious_trap_damage") or 20
GLOBAL.TEEMO_NOXIOUS_TRAP_DOT = GetModConfigData("noxious_trap_dot") or 20
GLOBAL.TEEMO_BLIND_DART_DURABILITY = GetModConfigData("blind_dart_durability") or 3
GLOBAL.TEEMO_POISON_SPOIL_PERCENT = GetModConfigData("poison_spoil_percent")
if GLOBAL.TEEMO_POISON_SPOIL_PERCENT == nil then GLOBAL.TEEMO_POISON_SPOIL_PERCENT = 0.7 end
GLOBAL.TEEMO_MUSHROOM_IMMUNITY = GetModConfigData("mushroom_immunity")
if GLOBAL.TEEMO_MUSHROOM_IMMUNITY == nil then GLOBAL.TEEMO_MUSHROOM_IMMUNITY = true end

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
    
}

RemapSoundEvent( "dontstarve/characters/teemo/death_voice", "DST-teemo/dontstarve/characters/DST-teemo/death_voice" )
RemapSoundEvent( "dontstarve/characters/teemo/hurt", "DST-teemo/dontstarve/characters/DST-teemo/hurt" )
RemapSoundEvent( "dontstarve/characters/teemo/talk_LP", "DST-teemo/dontstarve/characters/DST-teemo/talk_LP" )
RemapSoundEvent( "dontstarve/characters/teemo/emote", "DST-teemo/dontstarve/characters/DST-teemo/emote" )
RemapSoundEvent( "dontstarve/characters/teemo/ghost_LP", "DST-teemo/dontstarve/characters/DST-teemo/ghost_LP" )
RemapSoundEvent( "dontstarve/characters/teemo/move", "DST-teemo/dontstarve/characters/DST-teemo/move" )
RemapSoundEvent( "dontstarve/characters/teemo/spwn", "DST-teemo/dontstarve/characters/DST-teemo/spwn" )
RemapSoundEvent( "dontstarve/characters/teemo/attack", "DST-teemo/dontstarve/characters/DST-teemo/attack" )

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

-- ノクサストラップ スタック消費RPC
AddModRPCHandler("teemo", "use_noxious_trap_stack", function(player)
    if player:HasTag("teemo")
        and player._noxiousTrapStacks
        and player._noxiousTrapStacks:value() > 0 then
        player._noxiousTrapStacks:set(player._noxiousTrapStacks:value() - 1)

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

-- テーモ用ノクサストラップ専用スロット（インベントリ一番右に固定）
AddClassPostConstruct("widgets/inventorybar", function(self)
    if not self.owner:HasTag("teemo") then return end

    local NoxiousTrapSlot = require("widgets/noxioustrap_slot")

    local _Rebuild = self.Rebuild
    self.Rebuild = function(self, ...)
        if self.noxioustrapslot ~= nil then
            self.noxioustrapslot:Kill()
            self.noxioustrapslot = nil
        end

        _Rebuild(self, ...)

        -- 最後のスロットを非表示＆操作無効にする
        local last = self.inv[#self.inv]
        if last then
            last:Hide()
            last.OnControl = function() return false end

            -- 最後のスロットと同じ位置に NoxiousTrapSlot を配置
            local pos = last:GetPosition()
            self.noxioustrapslot = self.toprow:AddChild(NoxiousTrapSlot(self.owner))
            self.noxioustrapslot:SetPosition(pos.x, pos.y, pos.z)
        end
    end

    self.rebuild_pending = true
end)

