local Intervals = {}

Core = {
    
    GetFromId = function(src)
        if ESX ~= nil then
            return ESX.GetPlayerFromId(src)
        elseif QBCore ~= nil then
            return QBCore.Functions.GetPlayer(src)
        elseif QBOX ~= nil then
           return exports.qbx_core:GetPlayer(src)
        end
    end,

    GetJobs = function()
        if ESX ~= nil then
            return ESX.GetJobs()
        elseif QBCore ~= nil then
            return QBCore.Shared.Jobs
        elseif QBOX ~= nil then 
            return exports.qbx_core:GetJobs()
        end
    end,

    GetGangs = function()
        if QBCore ~= nil then
            return QBCore.Shared.Gangs
        elseif QBOX ~= nil then 
            return exports.qbx_core:GetGangs()
        end
    end,

    GetInventory = function(src)
        local xPlayer = Core.GetFromId(tonumber(src))
        local items, inv = {}, {}
    
        if ESX ~= nil then
            items = xPlayer.getInventory()
        elseif QBCore ~= nil then
            items = xPlayer.PlayerData.items
        end
    
        for k,v in pairs(items) do
            if (v.amount and v.amount > 0) or (v.count and v.count > 0) then
                table.insert(inv, {
                    name  = v.name, 
                    label = v.label,
                    count = (v.amount or v.count),
                    info  = (v.info or v.metadata or false),
                })
            end
        end
    
        return inv
    end,

    AddItem = function(src, item, amount)
        local src = Core.GetSource(src)
        local xPlayer = Core.GetFromId(src)
        if ESX ~= nil then
            xPlayer.addInventoryItem(item, amount)
        elseif QBCore ~= nil then
            xPlayer.Functions.AddItem(item, amount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[tostring(item)], "add")
        elseif QBOX ~= nil then
            exports.ox_inventory:AddItem(src, item, amount)
        end
    end,

    RemoveItem = function(src, item, amount)
        local src = Core.GetSource(src)
        local xPlayer = Core.GetFromId(src)
        if ESX ~= nil then
            xPlayer.removeInventoryItem(item, amount)
        elseif QBCore ~= nil then
            xPlayer.Functions.RemoveItem(item, amount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[tostring(item)], "remove")
        elseif QBOX ~= nil then
            exports.ox_inventory:RemoveItem(src, item, amount)
        end
    end,

    HasItem = function(src, item, amount)
        if ESX ~= nil or QBCore ~= nil then 
            local inv = Core.GetInventory(src)
            for k,v in pairs(inv) do
                if v.name == item then
                    if v.count >= amount then
                        return true, v.count
                    else
                        return false, v.count
                    end
                end
            end
            return false, 0
        elseif QBOX ~= nil then
            if exports.ox_inventory:GetItem(src, item, nil, true) >= amount then
                return true 
            else
                return false, 0
            end
        end
    end,

    GetItem = function(src, item)
        local xPlayer = Core.GetFromId(tonumber(src))
        if ESX ~= nil then
            local invItem = xPlayer.getInventoryItem(item)
            if invItem == nil then
                return nil
            else
                return {name = invItem.name, label = invItem.label, count = invItem.count}
            end
        elseif QBCore ~= nil then
                local invItem = xPlayer.Functions.GetItemByName(item)
                if invItem ~= nil then
                    return {name = invItem.name, label = invItem.label, count = invItem.amount}
                else
                    return nil
                end
         elseif QBOX ~= nil then
            local invItem = xPlayer.Functions.GetItemByName(item)
            if invItem ~= nil then
                return {name = invItem.name, label = invItem.label, count = invItem.amount}
            else
                return nil
            end
        end
    end,

    GetSource = function(src)
        local xPlayer = Core.GetFromId(tonumber(src))
        while xPlayer == nil do
            Wait(500)
            xPlayer = Core.GetFromId(tonumber(src))
        end
        if ESX ~= nil then
            return xPlayer.source
        elseif QBCore ~= nil then
            return xPlayer.PlayerData.source
        elseif QBOX ~= nil then
            return xPlayer.PlayerData.source
        end
    end,

     GetajIdentifier = function(source)
        if not source then
            return nil
        end
    
        local identifiers = GetPlayerIdentifiers(source)
    
        if identifiers and #identifiers > 0 then
            for _, id in ipairs(identifiers) do
                if string.sub(id, 1, 6) == "license" then
                    return id 
                end
            end
        end
    
        return nil
    end,
    
    GetName = function(src)
        local xPlayer = Core.GetFromId(tonumber(src))
        if ESX ~= nil then
            return xPlayer.getName()
        elseif QBCore ~= nil then
            return xPlayer.PlayerData.name
        elseif QBOX ~= nil then
            return xPlayer.PlayerData.name
        end
    end,

    SetInterval = function(id, msec, callback, onclear)
        if not Intervals[id] and msec then
            Intervals[id] = msec
            CreateThread(function()
                repeat
                    local interval = Intervals[id]
                    Wait(interval)
                    callback(interval)
                until interval == -1 and (onclear and onclear() or true)
                Intervals[id] = nil
            end)
        elseif msec then Intervals[id] = msec end
    end,

    ClearInterval = function(id)
        if Intervals[id] then Intervals[id] = -1 end
    end,

}

