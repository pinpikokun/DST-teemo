local MAX_TRAPS = 10
local TRAP_LIFETIME = 300 -- 5分

local assets=
{
	Asset("ANIM", "anim/noxious_trap.zip"),
	
	Asset("IMAGE", "images/inventoryimages/noxious_trap.tex"),
	Asset("ATLAS", "images/inventoryimages/noxious_trap.xml"),
}

local DETECT_RADIUS = 3.0
local DETECT_CANTTAGS = {"companion"}
local DETECT_MUSTONETAGS = {"monster", "character", "animal", "shadowcreature", "largecreature", "smallcreature", "insect"}

local function explodeTrap(inst, target)
	-- 爆発エフェクト
	inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
	SpawnPrefab("explode_noxious_trap").Transform:SetPosition(inst.Transform:GetWorldPosition())
	-- ダメージ
	inst.components.explosive_noxious_trap:OnBurnt()
end

local function stopSearchTask(inst)
    if inst.searchTask ~= nil then
        inst.searchTask:Cancel()
        inst.searchTask = nil
    end
end

local function findTarget(inst)
	-- 5分経過したら終了
	inst.elapsed = inst.elapsed + .3
	if inst.elapsed >= TRAP_LIFETIME then
	    stopSearchTask(inst)
	    inst:Remove()
	    return
	end

	-- 爆発の対象
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, DETECT_RADIUS, nil, DETECT_CANTTAGS, DETECT_MUSTONETAGS)

    -- playerは爆発対象外
    local nonTarget = TheNet:GetPVPEnabled() and "teemo" or "player"
    for k, v in pairs(ents) do
    	if not v:HasTag(nonTarget) then
    		stopSearchTask(inst)
    		explodeTrap(inst, v)
    		break
    	end
    end
end

local function startTrap(inst)
	inst.isSetTrap = true
 	inst.elapsed = 0

    inst.Light:SetFalloff(0.9)
    inst.Light:SetIntensity(0.9)
    inst.Light:SetColour(155/255, 225/255, 250/255)
    inst.Light:SetRadius(1.5)

    inst.SoundEmitter:PlaySound("dontstarve/creatures/mandrake/pop")

	-- 1秒後にステルス化
	inst:DoTaskInTime(1.0, function()
		inst.AnimState:SetMultColour(.8, .8, .8, .8)
	end)
	inst:RemoveComponent("inventoryitem")

    stopSearchTask(inst)

	inst.searchTask = inst:DoPeriodicTask(.3, findTarget, 2.0)
end

local function onDeploy(inst, pt, deployer)
	if deployer ~= nil then
		if inst.components.explosive_noxious_trap ~= nil then
			inst.components.explosive_noxious_trap:SetDeployer(deployer)
		end

		-- 設置上限の管理
		if deployer._noxiousTraps == nil then
			deployer._noxiousTraps = {}
		end

		-- 無効になったトラップを除去
		local validTraps = {}
		for _, trap in ipairs(deployer._noxiousTraps) do
			if trap:IsValid() then
				table.insert(validTraps, trap)
			end
		end

		-- 上限超過時は最も古いトラップを削除
		while #validTraps >= MAX_TRAPS do
			local oldest = table.remove(validTraps, 1)
			if oldest:IsValid() then
				stopSearchTask(oldest)
				oldest:Remove()
			end
		end

		table.insert(validTraps, inst)
		deployer._noxiousTraps = validTraps
	end

	startTrap(inst)
	inst.Physics:Teleport(pt:Get())

	-- 設置時にdeployerのmoveボイスを再生
	if deployer ~= nil and deployer.SoundEmitter then
		if math.random() < 0.5 then
			deployer.SoundEmitter:PlaySound("dontstarve/characters/teemo/move")
		end
	end
end

local function onLoad(inst, data)
	if data then
		if data.isSetTrap then
			inst.isSetTrap = data.isSetTrap
			startTrap(inst)
		end
		if data.elapsed then
			inst.elapsed = data.elapsed
		end
	end
end

local function onSave(inst, data)
	data.isSetTrap = inst.isSetTrap
	data.elapsed = inst.elapsed
end

local function fn(Sim)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	inst.entity:AddLight()

	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("noxious_trap")
	inst.AnimState:SetBuild("noxious_trap")
	inst.AnimState:PlayAnimation("idle")

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	-- インベントリアイテム
	inst:AddComponent("inventoryitem")
	-- インベントリ見た目
	inst.components.inventoryitem.atlasname = "images/inventoryimages/noxious_trap.xml"

	-- トラップ設置
    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = onDeploy
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LESS)
    
    -- 爆発ダメージ
	inst:AddComponent("explosive_noxious_trap")

	inst.OnSave = onSave
	inst.OnLoad = onLoad

	return inst
end

return Prefab("common/inventory/noxious_trap", fn, assets),
MakePlacer("common/noxious_trap_placer", "noxious_trap", "noxious_trap", 2, false,true,false)