GLOBAL.NOXIOUS_TRAP_MAX_STACKS = 5

local STRINGS = GLOBAL.STRINGS

STRINGS.CHARACTER_TITLES.teemo = "Captain Teemo"
STRINGS.CHARACTER_NAMES.teemo = "Captain Teemo"
STRINGS.CHARACTER_DESCRIPTIONS.teemo = "Size doesn't mean everything."
STRINGS.CHARACTER_QUOTES.teemo = "\"on duty !! \""
STRINGS.CHARACTERS.TEEMO = GLOBAL.require "speech_teemo"
STRINGS.NAMES.TEEMO = "Teemo"
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
    
	Asset( "IMAGE", "images/inventoryimages/blind_dart.tex" ),
    Asset( "ATLAS", "images/inventoryimages/blind_dart.xml" ),
    
	Asset( "IMAGE", "images/inventoryimages/noxious_trap.tex" ),
    Asset( "ATLAS", "images/inventoryimages/noxious_trap.xml" ),

    Asset( "IMAGE", "images/hud/teemotab.tex" ),
   	Asset( "ATLAS", "images/hud/teemotab.xml" ),

    Asset("SOUNDPACKAGE", "sound/teemo.fev"),
    Asset("SOUND", "sound/teemo.fsb"),
    
}

RemapSoundEvent( "dontstarve/characters/teemo/death_voice", "teemo/characters/teemo/death_voice" )
RemapSoundEvent( "dontstarve/characters/teemo/hurt", "teemo/characters/teemo/hurt" )
RemapSoundEvent( "dontstarve/characters/teemo/talk_LP", "teemo/characters/teemo/talk_LP" )
RemapSoundEvent( "dontstarve/characters/teemo/emote", "teemo/characters/teemo/emote" )
RemapSoundEvent( "dontstarve/characters/teemo/ghost_LP", "teemo/characters/teemo/ghost_LP" )

AddModCharacter("teemo", "MALE")
AddMinimapAtlas("images/map_icons/teemo.xml")

-- アイテムの名前 item name
STRINGS.NAMES.BLIND_DART = "Blind Dart"

-- アイテムの名前 item name
STRINGS.NAMES.NOXIOUS_TRAP = "Noxious Trap"

-- ノクサストラップ スタック消費RPC
AddModRPCHandler("teemo", "use_noxious_trap_stack", function(player)
    if player:HasTag("teemo")
        and player._noxiousTrapStacks
        and player._noxiousTrapStacks:value() > 0 then
        player._noxiousTrapStacks:set(player._noxiousTrapStacks:value() - 1)

        -- 設置アニメーション
        player.sg:GoToState("doshortaction")

        -- アニメーションに合わせてトラップを設置
        player:DoTaskInTime(10 * GLOBAL.FRAMES, function()
            local trap = GLOBAL.SpawnPrefab("noxious_trap")
            local pos = player:GetPosition()
            trap.components.deployable:Deploy(pos, player)
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

