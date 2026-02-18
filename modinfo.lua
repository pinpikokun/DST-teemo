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
}