
local WorkShops = {}
local Recipes = {}

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        LoadData()
    end
end)

LoadData = function()

    local jobs = Core.GetJobs()
    GlobalState.Jobs = jobs

    if GetResourceState(Shared.FrameworkNames.qb) ~= 'missing' or GetResourceState(Shared.FrameworkNames.qbox) ~= 'missing' then
        local gangs = Core.GetGangs()
        GlobalState.Gangs = gangs
    end

    -- # main data
    local jsondata = LoadResourceFile(GetCurrentResourceName(), "data/tables.json")
    if jsondata then
        WorkShops = json.decode(jsondata)
        GlobalState.WorkShops = WorkShops or {}
    end

    -- # items data
    local jsondata2 = LoadResourceFile(GetCurrentResourceName(), "data/items.json")
    if jsondata2 then
        Recipes = json.decode(jsondata2)
        GlobalState.Recipes = Recipes or {}
    end

end

if GetResourceState(Shared.FrameworkNames.esx) ~= 'missing' then 
    RegisterNetEvent("esx:playerLoaded")
    AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
        local jobs = Core.GetJobs()
        GlobalState.Jobs = jobs
    end)
end

lib.callback.register("qt_crafting-CheckPerm", function(source, perm)
    local hasPerm = IsPlayerAceAllowed(source, perm) 
    return hasPerm
end)

local function GenerateTableID()
    local digits = '0123456789'
    local idLength = 8
    local uniqueId = ''
    for i = 1, idLength do
        local randomIndex = math.random(1, #digits)
        uniqueId = uniqueId .. digits:sub(randomIndex, randomIndex)
    end
    return uniqueId
end

RegisterNetEvent("qt_crafting-SetupCraft", function(data)
    local id

    repeat
        id = GenerateTableID()
    until WorkShops[id] == nil

    local new_craftable = {
        id = id, 
        name = data.name, 
        model = data.model, 
        coords = data.coords, 
        blip = data.blip,
        jobs = data.jobs,
        gangs = data.gangs,
        kreirajprop = data.kreirajprop,
    }

    WorkShops[id] = new_craftable
    Recipes[id] = {}

    UpdateJSON('workshop')
    UpdateJSON("items")
    
    TriggerClientEvent("qt-crafting:SendAlert", source, {
        title = L("main_title"), 
        msg = L("success_create"):format(data.name),
        type = "success"
    })

    LoadData()

    Wait(500)

    TriggerClientEvent("qt-crafting:Re:Sync", -1)
    
    discord_logs(L('server_name'), L("updated_table3"):format(Core.GetajIdentifier(source), id))

end)

RegisterNetEvent("qt_crafting-EditActions", function(data)

    if data.action == "delete" then 

        if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
            WorkShops[data.id] = nil 
            GlobalState.WorkShops = WorkShops 
        end
        if GlobalState.Recipes ~= nil and GlobalState.Recipes[data.id] ~= nil then 
            Recipes[data.id] = nil 
            GlobalState.Recipes = Recipes
        end
        UpdateJSON('workshop')
        UpdateJSON('items')

        discord_logs(L('server_name'), L("updated_table2"):format(Core.GetajIdentifier(source), data.action))

    elseif data.action == "add_item" then 
            
        local new_item = {
                item = data.item, 
                recipe = data.recipe,
                label = data.label,
                amount = tonumber(data.amount), 
                craft_time = data.craft_time
        }

        table.insert(Recipes[data.id], new_item)

        GlobalState.Recipes = Recipes

        UpdateJSON('items')

        discord_logs(L('server_name'), L("updated_table2"):format(Core.GetajIdentifier(source), data.action))

    elseif data.action == "removeItem" then 

        if GlobalState.Recipes ~= nil and GlobalState.Recipes[data.id] ~= nil then 
            local recipes = Recipes[data.id]
            for key, recipe in pairs(recipes) do
                if recipe.item == data.item and recipe.label == data.label then
                    recipes[key] = nil  
                    break
                end
            end
            for i = #recipes, 1, -1 do
                if recipes[i] == nil then
                    table.remove(recipes, i)
                end
            end

            GlobalState.Recipes = Recipes

            UpdateJSON('items')

            discord_logs(L('server_name'), L("updated_table2"):format(Core.GetajIdentifier(source), data.action))

        end

    elseif data.action == "ChangeLabelItem" then 

        if GlobalState.Recipes ~= nil and GlobalState.Recipes[data.id] ~= nil then 
            local recipes = Recipes[data.id]
            for key, recipe in pairs(recipes) do
                if recipe.item == data.item and recipe.label == data.label then
                    recipe.label = data.new_label 
                end
            end
             
            GlobalState.Recipes = Recipes

            UpdateJSON('items')

            discord_logs(L('server_name'), L("updated_table2"):format(Core.GetajIdentifier(source), data.action))
        
        end
    
    elseif data.action == "ChangeCraftTime" then 

        if GlobalState.Recipes ~= nil and GlobalState.Recipes[data.id] ~= nil then 
            local recipes = Recipes[data.id]
            for key, recipe in pairs(recipes) do
                if recipe.item == data.item and recipe.label == data.label then
                    recipe.craft_time = tonumber(data.new_time)  
                end
            end

            GlobalState.Recipes = Recipes

            UpdateJSON('items')

            discord_logs(L('server_name'), L("updated_table2"):format(Core.GetajIdentifier(source), data.action))
--
        end

    elseif data.action == "ChangeRecipeItem" then 

        if GlobalState.Recipes ~= nil and GlobalState.Recipes[data.id] ~= nil then 
            local recipes = Recipes[data.id]
            for key, recipe in pairs(recipes) do
                if recipe.item == data.item and recipe.label == data.label then
                    recipe.recipe = data.recipe  
                end
            end

            GlobalState.Recipes = Recipes

            UpdateJSON('items')

            discord_logs(L('server_name'), L("updated_table2"):format(Core.GetajIdentifier(source), data.action))

        end

    elseif data.action == "ChangeReward" then

        if GlobalState.Recipes ~= nil and GlobalState.Recipes[data.id] ~= nil then 
            local recipes = Recipes[data.id]
            for key, recipe in pairs(recipes) do
                if recipe.item == data.item and recipe.label == data.label then
                    recipe.amount = data.amount  
                end
            end

            GlobalState.Recipes = Recipes

            UpdateJSON('items')


         discord_logs(L('server_name'), L("updated_table2"):format(Core.GetajIdentifier(source), data.action))
         --   
        end

    elseif data.action == "ModifyApp" then 

        if data.section == "change_prop" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].model = data.model
                GlobalState.WorkShops = WorkShops 
                discord_logs(L('server_name'), L("updated_table"):format(Core.GetajIdentifier(source), data.action, data.section))
            end

        elseif data.section == "change_blip" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].blip = data.blipData
                GlobalState.WorkShops = WorkShops 
                discord_logs(L('server_name'), L("updated_table"):format(Core.GetajIdentifier(source), data.action, data.section))
            end

        elseif data.section == "new_pos" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].coords = data.pos
                GlobalState.WorkShops = WorkShops 
                discord_logs(L('server_name'), L("updated_table"):format(Core.GetajIdentifier(source), data.action, data.section))
            end

        elseif data.section == "new_name" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].name = data.name
                GlobalState.WorkShops = WorkShops 
                discord_logs(L('server_name'), L("updated_table"):format(Core.GetajIdentifier(source), data.action, data.section))
            end

        elseif data.section == "new_jobs" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].jobs = data.jobs
                GlobalState.WorkShops = WorkShops 
                discord_logs(L('server_name'), L("updated_table"):format(Core.GetajIdentifier(source), data.action, data.section))
            end

        elseif data.section == "new_gangs" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].gangs = data.gangs
                GlobalState.WorkShops = WorkShops 
                discord_logs(L('server_name'), L("updated_table"):format(Core.GetajIdentifier(source), data.action, data.section))
            end

        elseif data.section == "reload_defaults" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].jobs = {}
                WorkShops[data.id].gangs = {}
                WorkShops[data.id].blip = {}
                GlobalState.WorkShops = WorkShops 
                discord_logs(L('server_name'), L("updated_table"):format(Core.GetajIdentifier(source), data.action, data.section))
            end

        elseif data.section == "delete_blip" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].blip = {}
                GlobalState.WorkShops = WorkShops 
                discord_logs(L('server_name'), L("updated_table"):format(Core.GetajIdentifier(source), data.action, data.section))
            end

        elseif data.section == "delete_job_access" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].jobs = {}
                GlobalState.WorkShops = WorkShops 
                discord_logs(L('server_name'), L("updated_table"):format(Core.GetajIdentifier(source), data.action, data.section))
            end
            
        elseif data.section == "delete_gang_access" then 

            if GlobalState.WorkShops ~= nil and GlobalState.WorkShops[data.id] ~= nil then 
                WorkShops[data.id].gangs = {}
                GlobalState.WorkShops = WorkShops 
                discord_logs(L('server_name'), L("updated_table"):format(Core.GetajIdentifier(source), data.action, data.section))
            end

        end

        UpdateJSON('workshop')
        
    end

    Wait(500)
    TriggerClientEvent("qt-crafting:Re:Sync", -1)

end)

UpdateJSON = function(action)
    local fileName, fileContent
    if action == "workshop" then
        fileName = "data/tables.json"
        fileContent = json.encode(WorkShops, { indent = true })
    elseif action == 'items' then
        fileName = "data/items.json"
        fileContent = json.encode(Recipes, { indent = true })
    end

    if fileName and fileContent then
        local success, err = pcall(function()
            SaveResourceFile(GetCurrentResourceName(), fileName, fileContent, -1)
        end)
        if not success then
            print("Error saving file: " .. err)
        end
    end
end

lib.callback.register("qt-crafting-CheckItems", function(source, recipe)
    for _, data in ipairs(recipe) do
        local amount = tonumber(data.amount)
        local check = Core.HasItem(source, data.item, amount)  
        if not check then 
            return false  
        end
    end

    return true  
end)

RegisterNetEvent("qt-crafting-GiveItem", function(data)
    local source = source 

    if not source or not GetPlayerName(source) then
        print("Invalid source:", source)
        return
    end

    if type(data) ~= "table" or not data.item or not data.amount or not data.recipe then
        print("Invalid data format:", data)
        return
    end

    if type(data.item) ~= "string" or not tonumber(data.amount) or tonumber(data.amount) <= 0 then
        print("Invalid item or amount:", data.item, data.amount)
        return
    end

    if type(data.recipe) ~= "table" then
        print("Invalid recipe structure:", data.recipe)
        return
    end

    local hasItems = true
    for _, itemData in pairs(data.recipe) do
        if not itemData.item or not tonumber(itemData.amount) or tonumber(itemData.amount) <= 0 then
            print("Invalid recipe item or amount:", itemData.item, itemData.amount)
            hasItems = false
            break
        end

        if not Core.HasItem(source, itemData.item, tonumber(itemData.amount)) then
            hasItems = false
            break
        end
    end

    if not hasItems then
       -- TriggerClientEvent('qt-crafting-Notify', source, "You don't have enough items to craft.")
        return
    end

    Core.AddItem(source, data.item, tonumber(data.amount))

    for _, itemData in pairs(data.recipe) do
        if itemData.removable then 
          Core.RemoveItem(source, itemData.item, tonumber(itemData.amount))
        end
    end

    discord_logs(L('server_name'), L("crafted_item"):format(Core.GetName(source), data.item, data.amount, data.index))
    
end)
