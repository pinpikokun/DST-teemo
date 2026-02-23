-- This information tells other players more about the mod
name = "Captain Teemo"
description = "League of Legends."
author = "pinpikokun"
version = "0.2.2.3"

-- This is the URL name of the mod's thread on the forum; the part after the ? and before the first & in the url
forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

-- 互換性無し
dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true

-- MODアイコン
icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- クライアントに必要か
all_clients_require_mod = true
clients_only_mod = false

server_filter_tags = {"teemo"}

configuration_options = {
    {
        name = "health",
        label = "Health",
        hover = "Teemo's max health",
        options = {
            {description = "75",  data = 75},
            {description = "100", data = 100},
            {description = "150", data = 150},
            {description = "200", data = 200},
            {description = "250", data = 250},
        },
        default = 100,
    },
    {
        name = "hunger",
        label = "Hunger",
        hover = "Teemo's max hunger",
        options = {
            {description = "75",  data = 75},
            {description = "100", data = 100},
            {description = "150", data = 150},
            {description = "200", data = 200},
        },
        default = 100,
    },
    {
        name = "sanity",
        label = "Sanity",
        hover = "Teemo's max sanity",
        options = {
            {description = "100", data = 100},
            {description = "150", data = 150},
            {description = "200", data = 200},
            {description = "250", data = 250},
            {description = "300", data = 300},
        },
        default = 250,
    },
    {
        name = "damage_multiplier",
        label = "Damage Multiplier",
        hover = "Teemo's damage multiplier",
        options = {
            {description = "0.75x", data = 0.75},
            {description = "1.0x",  data = 1.0},
            {description = "1.25x", data = 1.25},
            {description = "1.5x",  data = 1.5},
            {description = "2.0x",  data = 2.0},
        },
        default = 1.0,
    },
    {
        name = "absorption",
        label = "Defense (Absorption)",
        hover = "Teemo's damage absorption rate",
        options = {
            {description = "0%",  data = 0},
            {description = "10%", data = 0.1},
            {description = "25%", data = 0.25},
            {description = "50%", data = 0.5},
        },
        default = 0,
    },
    {
        name = "speed_multiplier",
        label = "Move Speed",
        hover = "Teemo's movement speed multiplier",
        options = {
            {description = "1.0x",  data = 1.0},
            {description = "1.1x",  data = 1.1},
            {description = "1.25x", data = 1.25},
            {description = "1.5x",  data = 1.5},
        },
        default = 1.25,
    },
    {
        name = "blind_dart_damage",
        label = "Blind Dart Damage",
        hover = "Base damage of the Blind Dart / ブラインドダートの初撃ダメージ",
        options = {
            {description = "1",   data = 1},
            {description = "5",   data = 5},
            {description = "10",  data = 10},
            {description = "15",  data = 15},
            {description = "20",  data = 20},
            {description = "25",  data = 25},
            {description = "30",  data = 30},
            {description = "35",  data = 35},
            {description = "40",  data = 40},
            {description = "45",  data = 45},
            {description = "50",  data = 50},
            {description = "55",  data = 55},
            {description = "60",  data = 60},
            {description = "65",  data = 65},
            {description = "70",  data = 70},
            {description = "75",  data = 75},
            {description = "80",  data = 80},
            {description = "85",  data = 85},
            {description = "90",  data = 90},
            {description = "95",  data = 95},
            {description = "100", data = 100},
            {description = "105", data = 105},
            {description = "110", data = 110},
            {description = "115", data = 115},
            {description = "120", data = 120},
            {description = "125", data = 125},
            {description = "130", data = 130},
            {description = "135", data = 135},
            {description = "140", data = 140},
            {description = "145", data = 145},
            {description = "150", data = 150},
        },
        default = 10,
    },
    {
        name = "blind_dart_dot",
        label = "Blind Dart DOT",
        hover = "Toxic Shot poison damage per second (4s) / 毒DOTダメージ（毎秒、4秒間）",
        options = {
            {description = "0",   data = 0},
            {description = "5",   data = 5},
            {description = "10",  data = 10},
            {description = "15",  data = 15},
            {description = "20",  data = 20},
            {description = "25",  data = 25},
            {description = "30",  data = 30},
            {description = "35",  data = 35},
            {description = "40",  data = 40},
            {description = "45",  data = 45},
            {description = "50",  data = 50},
            {description = "55",  data = 55},
            {description = "60",  data = 60},
            {description = "65",  data = 65},
            {description = "70",  data = 70},
            {description = "75",  data = 75},
            {description = "80",  data = 80},
            {description = "85",  data = 85},
            {description = "90",  data = 90},
            {description = "95",  data = 95},
            {description = "100", data = 100},
        },
        default = 5,
    },
    {
        name = "noxious_trap_damage",
        label = "Noxious Trap Damage",
        hover = "Initial hit damage of Noxious Trap / ノクサストラップの初撃ダメージ",
        options = {
            {description = "1",   data = 1},
            {description = "5",   data = 5},
            {description = "10",  data = 10},
            {description = "15",  data = 15},
            {description = "20",  data = 20},
            {description = "25",  data = 25},
            {description = "30",  data = 30},
            {description = "35",  data = 35},
            {description = "40",  data = 40},
            {description = "45",  data = 45},
            {description = "50",  data = 50},
            {description = "55",  data = 55},
            {description = "60",  data = 60},
            {description = "65",  data = 65},
            {description = "70",  data = 70},
            {description = "75",  data = 75},
            {description = "80",  data = 80},
            {description = "85",  data = 85},
            {description = "90",  data = 90},
            {description = "95",  data = 95},
            {description = "100", data = 100},
            {description = "105", data = 105},
            {description = "110", data = 110},
            {description = "115", data = 115},
            {description = "120", data = 120},
            {description = "125", data = 125},
            {description = "130", data = 130},
            {description = "135", data = 135},
            {description = "140", data = 140},
            {description = "145", data = 145},
            {description = "150", data = 150},
        },
        default = 20,
    },
    {
        name = "noxious_trap_dot",
        label = "Noxious Trap DOT",
        hover = "Noxious Trap poison damage per second (4s, scaled by creature) / 毒DOTダメージ（毎秒、4秒間、クリーチャー倍率あり）",
        options = {
            {description = "0",   data = 0},
            {description = "5",   data = 5},
            {description = "10",  data = 10},
            {description = "15",  data = 15},
            {description = "20",  data = 20},
            {description = "25",  data = 25},
            {description = "30",  data = 30},
            {description = "35",  data = 35},
            {description = "40",  data = 40},
            {description = "45",  data = 45},
            {description = "50",  data = 50},
            {description = "55",  data = 55},
            {description = "60",  data = 60},
            {description = "65",  data = 65},
            {description = "70",  data = 70},
            {description = "75",  data = 75},
            {description = "80",  data = 80},
            {description = "85",  data = 85},
            {description = "90",  data = 90},
            {description = "95",  data = 95},
            {description = "100", data = 100},
        },
        default = 20,
    },
}