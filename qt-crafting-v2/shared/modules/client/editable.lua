String = {}

function String.SendAlert(data)
        -- exports["okokNotify"]:Alert(data.title, data.msg, 5000, data.type)
        -- ESX.ShowNotification(data.msg)
        -- QBCore.Functions.Notify(data.msg)
         exports.qbx_core:Notify(data.msg)
end

RegisterNetEvent("qt-crafting:SendAlert", function(data)
    String.SendAlert(data)
end)
