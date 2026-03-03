local assets = 
{
    Asset("ANIM", "anim/blind_effect.zip")
}
local function kill_fx(inst)
    inst.AnimState:PlayAnimation("close")
    inst:DoTaskInTime(0.1, inst.Remove)
end

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("forcefield")
    inst.AnimState:SetBuild("blind_effect")
    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("idle_loop", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst.kill_fx = kill_fx

    return inst
end

return Prefab("common/blind_effect", fn, assets)