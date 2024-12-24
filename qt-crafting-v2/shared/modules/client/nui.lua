RegisterNUICallback("close", function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback("animacija", function(data)
    if Shared.CraftAnimation['isScenario'] then
        TaskStartScenarioInPlace(PlayerPedId(), Shared.CraftAnimation['scenario'], 0, true)  
    elseif Shared.CraftAnimation['isAnim'] then
        lib.requestAnimDict(Shared.CraftAnimation['anim'])
        TaskPlayAnim(PlayerPedId(), Shared.CraftAnimation['anim'], Shared.CraftAnimation['dict'], 8.0, -8.0, -1, 2, 0, false, false, false)
    end
end)


RegisterNUICallback("HasItems", function(data, cb)
    lib.callback("qt-crafting-CheckItems", nil, function(canCraft)
        if canCraft then 
            cb(true)
        else
            cb(false)
            String.SendAlert({type = "warning", title = L("main_title"), msg = L("not_enough_to_craft")})
        end
    end, data.recipe)
end)

RegisterNUICallback("GiveItem", function(data)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent("qt-crafting-GiveItem", data)
end)
