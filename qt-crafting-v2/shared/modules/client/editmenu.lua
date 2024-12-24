AddEventHandler("qt_crafting-EditTable", function(data)
    lib.registerContext({
        id = 'editMenu2',
        title = data.name,
        menu = "editMenu",
        options = {
            {
                title = L("modify_items"),
                description = L("modify_items_desc"),
                icon = "fa-solid fa-toolbox",
                arrow = true, 
                event = "qt_crafting-ModifyItems",
                args = { id = data.id, name = data.name }
            },
            {
                title = L("change_position"),
                description = L("change_position_desc"),
                icon = "fa-solid fa-map-location-dot",
                arrow = true, 
                event = "qt_crafting-ModifyApp",
                args = { id = data.id, name = data.name }
            },
            {
                title = L("teleport_table"),
                description = L("teleport_table_desc"),
                icon = "fa-brands fa-google-play",
                arrow = true, 
                event = "qt_crafting-TeleportTable",
                args = { id = data.id, kreirajprop = data.kreirajprop }
            },
            {
                title = L("delete_table"),
                description = L("delete_table_desc"),
                icon = "fa-solid fa-trash-can",
                arrow = true, 
                serverEvent = "qt_crafting-EditActions",
                args = { action = "delete", id = data.id, name = data.name }
            },
        }
    })
    lib.showContext('editMenu2')
end)

AddEventHandler("qt_crafting-TeleportTable", function(data)
    local coords = GlobalState.WorkShops[data.id].coords
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
    SetEntityHeading(PlayerPedId(), coords.w)
    String.SendAlert({type = "info", title = L("main_title"), msg = L("successfully_teleported")})
end)

AddEventHandler("qt_crafting-ModifyApp", function(data)
    local disableGangs = false
    local disableJobs = false 
    local disableBlipDelete = false 
    local disableDeleteJobCheck = false 
    local disableDeleteGangCheck = false 
    local gangs = GlobalState.WorkShops[data.id]['gangs']
    local jobs = GlobalState.WorkShops[data.id]['jobs']
    local blip = GlobalState.WorkShops[data.id]['blip']
    
    if gangs == nil or #gangs == 0 then
        disableGangs = true
        disableDeleteGangCheck = true 
    end

    if jobs == nil or #jobs == 0 then
        disableJobs = true
        disableDeleteJobCheck = true 
    end

    if blip == nil or #blip == 0 then
         disableBlipDelete = true 
    end

    if GetResourceState(Shared.FrameworkNames.esx) ~= 'missing' then 
        disableGangs = true 
    end
    
    lib.registerContext({
        id = 'modifyapp',
        title = data.name,
        menu = "editMenu2",
        options = {
            {
                title = L("change_prop"),
                description = L("change_prop_desc"),
                icon = "fa-solid fa-kaaba",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                args = { id = data.id, action = "ModifyApp", section = "change_prop" }
            },
            {
                title = L("change_blip"),
                description = L("change_blip_desc"),
                icon = "fa-solid fa-location-dot",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                args = { id = data.id, action = "ModifyApp", section = "change_blip" }
            },
            {
                title = L("delete_blip"),
                description = L("delete_blip_desc"),
                icon = "fa-solid fa-ban",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                disabled = disableBlipDelete, 
                args = { id = data.id, action = "ModifyApp", section = "delete_blip" }
            },
            {
                title = L("set_new_pos"),
                description = L("set_new_pos_desc"),
                icon = "fa-solid fa-up-down-left-right",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                args = { id = data.id, action = "ModifyApp", section = "new_pos" }
            },
            {
                title = L("set_new_name"),
                description = L("set_new_name_desc"),
                icon = "fa-solid fa-square-h",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                args = { id = data.id, action = "ModifyApp", section = "new_name" }
            },
            {
                title = L("change_access"),
                description = L("change_access_desc"),
                icon = "fa-solid fa-suitcase",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                disabled = disableJobs,
                args = { id = data.id, action = "ModifyApp", section = "new_jobs" }
            },
            {
                title = L("change_access_gangs"),
                description = L("change_access_gangs_desc"),
                icon = "fa-solid fa-cannabis",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                disabled = disableGangs, 
                args = { id = data.id, action = "ModifyApp", section = "new_gangs" }
            },
            {
                title = L("delete_job_access"),
                description = L("delete_job_qacces_decs"),
                icon = "fa-solid fa-rectangle-xmark",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                disabled = disableDeleteJobCheck,
                args = { id = data.id, action = "ModifyApp", section = "delete_job_access" }
            },
            {
                title = L("delete_gang_access"),
                description = L("delete_gang_qacces_decs"),
                icon = "fa-solid fa-rectangle-xmark",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                disabled = disableDeleteGangCheck,
                args = { id = data.id, action = "ModifyApp", section = "delete_gang_access" }
            },
            {
                title = L("reload_defaults"),
                description = L("reload_defaults_desc"),
                icon = "fa-solid fa-repeat",
                arrow = true, 
                event = "qt_crafting-ModifyApp2",
                args = { id = data.id, action = "ModifyApp", section = "reload_defaults" }
            },
        }
    })
    
    lib.showContext("modifyapp")
    
end)

AddEventHandler("qt_crafting-ModifyApp2", function(data)
    Wait(100)

    if data.section == "change_prop" then 

        local formData = lib.inputDialog(L("change_prop_title"), {
            { label = L("enter_new_model"), type = 'input', required = true }
        })
        
        if formData then

            TriggerServerEvent("qt_crafting-EditActions", { 
                action = data.action, 
                section = data.section, 
                id = data.id, 
                model = formData[1] 
            })
        
            String.SendAlert({type = "success", title = L("main_title"), msg = L("change_success")})
        end
        

    elseif data.section == "change_blip" then 

        blipForm(function(blipData)
            if blipData then 
              TriggerServerEvent("qt_crafting-EditActions", { action = data.action, section = data.section, id = data.id, blipData = blipData } )
              String.SendAlert({type = "success", title = L("main_title"),  msg = L("change_success")})
            else
                String.SendAlert({type = "warning", title = L("main_title"), msg = L("canceled_blipsettings")})  
            end
        end)

    elseif data.section == "new_pos" then 

        SetupPOS(GlobalState.WorkShops[data.id].model, function(pos)
            TriggerServerEvent("qt_crafting-EditActions", { action = data.action, section = data.section, id = data.id, pos = pos } )
            String.SendAlert({type = "success", title = L("main_title"), msg = L("change_success")})
        end)

    elseif data.section == "new_name" then 

        local formData = lib.inputDialog(L("new_name_title"), {
            { label = L("enter_new_name"), type = 'input', required = true },
        })
        
        if formData then
            TriggerServerEvent("qt_crafting-EditActions", {
                action = data.action,
                section = data.section,
                id = data.id,
                name = formData[1], 
            })
        
            String.SendAlert({type = "success", title = L("main_title"), msg = L("change_success")})
        end        

    elseif data.section == "new_jobs" then 

        jobsForm(function(jobsData)
            if jobsData then 
                TriggerServerEvent("qt_crafting-EditActions", { action = data.action, section = data.section, id = data.id, jobs = jobsData } )
                String.SendAlert({type = "success", title = L("main_title"),  msg = L("change_success")})
            else
                String.SendAlert({type = "warning", title = L("main_title"),  msg = L("canceled_jobsettings")})  
            end
        end)

    elseif data.section == "new_gangs" then 

        if GetResourceState(Shared.FrameworkNames.qb) ~= 'missing' or GetResourceState(Shared.FrameworkNames.qbox) ~= 'missing' then 
            gangsForm(function(gangsData)
                if gangsData then
                    TriggerServerEvent("qt_crafting-EditActions", { action = data.action, section = data.section, id = data.id, gangs = gangsData } )
                    String.SendAlert({type = "success", title = L("main_title"),  msg = L("change_success")})
                else
                    String.SendAlert({type = "warning", title = L("main_title"), msg = L("canceled_gangsettings")})  
                end
            end)
        else
            String.SendAlert({type = "warning", title = L("main_title"), msg = L("only_for_qb")})  
        end

    elseif data.section == "reload_defaults" then 
        TriggerServerEvent("qt_crafting-EditActions", { action = data.action, section = data.section, id = data.id } )
        String.SendAlert({type = "success", title = L("main_title"), msg = L("change_success")})

    elseif data.section == "delete_blip" then 
        TriggerServerEvent("qt_crafting-EditActions", { action = data.action, section = data.section, id = data.id } )
        String.SendAlert({type = "success", title = L("main_title"), msg = L("change_success")})
    elseif data.section == "delete_job_access" then 
        TriggerServerEvent("qt_crafting-EditActions", { action = data.action, section = data.section, id = data.id } )
        String.SendAlert({type = "success", title = L("main_title"), msg = L("change_success")})
    elseif data.section == "delete_gang_access" then 
        TriggerServerEvent("qt_crafting-EditActions", { action = data.action, section = data.section, id = data.id } )
        String.SendAlert({type = "success", title = L("main_title"), msg = L("change_success")})
    end

end)

AddEventHandler("qt_crafting-ModifyItems", function(data)
    local disableItemList = false 
    local itemList = GlobalState.Recipes[data.id] 
    if itemList == nil or #itemList == 0 then 
        disableItemList = true 
    end
    lib.registerContext({
        id = 'modifyItems',
        title = data.name,
        menu = "editMenu2",
        options = {
            {
                title = L("AddItems"),
                description = L("AddItems_desc"),
                icon = "fa-solid fa-file-circle-plus",
                arrow = true, 
                event = "qt_crafting-AddItems",
                args = data.id
            },
            {
                title = L("items_list"),
                description = L("items_list_desc"),
                icon = "fa-solid fa-sheet-plastic",
                arrow = true, 
                event = "qt_crafting-ItemsListing",
                args = data.id,
                disabled = disableItemList, 
            },
        }
    })
    lib.showContext("modifyItems") 
end)

AddEventHandler("qt_crafting-ItemUpdateMenu", function(data)
    lib.registerContext({
        id = 'manipulate_iteme',
        title = data.label,
        menu = "items_list_tableee",
        options = {
            {
                title = L("RemoveItem"),
                description = L("RemoveItem_desc"),
                icon = "fa-solid fa-trash-can",
                arrow = true, 
                serverEvent = "qt_crafting-EditActions",
                args = { action = "removeItem", id = data.table_id, item = data.item, label = data.label }
            },
            {
                title = L("Change_Label_Item"),
                description = L("Change_Label_Item_desc"),
                icon = "fa-solid fa-tv",
                arrow = true, 
                event = "qt_crafting-ItemUpdateMenu2",
                args = { action = "ChangeLabelItem", id = data.table_id, item = data.item, label = data.label }
            },
            {
                title = L("change_recipe_item"),
                description = L("change_recipe_item_desc"),
                icon = "fa-solid fa-newspaper",
                arrow = true, 
                event = "qt_crafting-ItemUpdateMenu2",
                args = { action = "ChangeRecipeItem", id = data.table_id, item = data.item, label = data.label }
            },
            {
                title = L("craft_time_change_item"),
                description = L("craft_time_change_item_desc"),
                icon = "fa-regular fa-clock",
                arrow = true, 
                event = "qt_crafting-ItemUpdateMenu2",
                args = { action = "ChangeCraftTime", id = data.table_id, item = data.item, label = data.label }
            },
            {
                title = L("change_item_amount_reward"),
                description = L("change_item_amount_reward_desc"),
                icon = "fa-solid fa-mountain-sun",
                arrow = true, 
                event = "qt_crafting-ItemUpdateMenu2",
                args = { action = "ChangeReward", id = data.table_id, item = data.item, label = data.label }
            },
        }
    })
    lib.showContext("manipulate_iteme") 
end)

AddEventHandler("qt_crafting-ItemUpdateMenu2", function(data)
    Wait(200)
    if data.action == "ChangeLabelItem" then
        local formData = lib.inputDialog(L("items_display_change"), {
            { label = L("item_name_new"), type = 'input', required = true },
        })
        if formData then
            TriggerServerEvent("qt_crafting-EditActions", {
                action = data.action,
                new_label = formData[1], 
                id = data.id,
                item = data.item,
                label = data.label
            })
        end

    elseif data.action == "ChangeCraftTime" then
        local formData = lib.inputDialog(L("items_craftime_change"), {
            { label = L("item_craftime_new"), type = 'number', required = true },
        })
        if formData then
            TriggerServerEvent("qt_crafting-EditActions", {
                action = data.action,
                new_time = tonumber(formData[1]), 
                id = data.id,
                item = data.item,
                label = data.label
            })
        end

    elseif data.action == "ChangeRecipeItem" then
        local formData = lib.inputDialog(L("adding_items_title"), {
            { label = L("required_items_number"), type = 'number', required = true },
        })
        if formData then
            createRecipe(tonumber(formData[1]), function(recipe)
                TriggerServerEvent("qt_crafting-EditActions", {
                    action = data.action,
                    item = data.item,
                    id = data.id,
                    recipe = recipe,
                    label = data.label
                })
            end)
        end

    elseif data.action == "ChangeReward" then
        local formData = lib.inputDialog(L("change_reward_am_title"), {
            { label = L("new_reward_amount"), type = 'number', required = true },
        })
        if formData then
            TriggerServerEvent("qt_crafting-EditActions", {
                action = data.action,
                amount = tonumber(formData[1]), 
                id = data.id,
                item = data.item,
                label = data.label
            })
        end
    end

    lib.notify({
        type = "success",
        title = L("main_title"),
        description = L("change_success"),
        position = 'top' 
    })
end)

AddEventHandler("qt_crafting-ItemsListing", function(table_id)
    local options = {}
    
    local recipe_data = GlobalState.Recipes[table_id]
    
    if recipe_data then
        for _, recipe in ipairs(recipe_data) do
            table.insert(options, {
                title = recipe.label,
                icon = 'fa-solid fa-gear',
                event = "qt_crafting-ItemUpdateMenu",
                args = { item = recipe.item, table_id = table_id, label = recipe.label },
            })
        end
    end

    lib.registerContext({
        id = 'items_list_tableee',
        title = L('items_list'),
        menu = "editMenu2",
        options = options
    })
    lib.showContext('items_list_tableee')
end)