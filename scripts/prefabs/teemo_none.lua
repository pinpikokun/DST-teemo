local assets = {
    Asset("ANIM", "anim/teemo.zip"),
    Asset("ANIM", "anim/ghost_teemo_build.zip"),
}

local skins = {
    normal_skin = "teemo",
    ghost_skin = "ghost_teemo_build",
}

return CreatePrefabSkin("teemo_none", {
    base_prefab = "teemo",
    type = "base",
    assets = assets,
    skins = skins,
    skin_tags = {"TEEMO", "CHARACTER", "BASE"},
    build_name_override = "teemo",
    rarity = "Character",
})
