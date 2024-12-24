Core = {

    getjob = function()
        if ESX ~= nil then
            return ESX.GetPlayerData().job.name
        elseif QBCore ~= nil then
            return QBCore.Functions.GetPlayerData().job.name
        elseif QBOX ~= nil then 
            return QBOX.Functions.GetPlayerData().job.name
        end
    end,

    getGangs = function()
        if QBCore ~= nil then 
           return QBCore.Functions.GetPlayerData().gang.name
        elseif QBOX ~= nil then 
           return QBOX.Functions.GetPlayerData().gang.name
        end
    end
    
}