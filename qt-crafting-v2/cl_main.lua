---@diagnostic disable: missing-parameter
local cache = {}

local DeletrSequence = function()
    for i = 1, #cache do
        DeleteObject(cache[i].obj)
    end
    for i = 1, #cache do 
        RemoveBlip(cache[i].blips)
    end
end

AddEventHandler("onResourceStop", function(res)
    if GetCurrentResourceName() == res then
        DeletrSequence()
    end
end)

RegisterCommand("craft:create", function()
    lib.callback("qt_crafting-CheckPerm", nil, function(access)
        if access then
            SetupCraft()
        else
            String.SendAlert({type = "warning", title = L("main_title"), msg = L("insufficient_permissions"),})
        end
    end, "create")
end)

SetupCraft = function()
    local jobs = {}
    local gangs = {}
    local blip = {}
    local model = nil

    local inputFields = {
        { name = "table_name", label = L("table_name"), type = "input", required = true },
        { name = "obj_hash", label = L("obj_hash"), type = "input", required = false },
        { name = "job", label = L("job"), type = "checkbox" },
        { name = "blip", label = L("blip"), type = "checkbox" },
    }

    if GetResourceState(Shared.FrameworkNames.qb) ~= 'missing' or GetResourceState(Shared.FrameworkNames.qbox) ~= 'missing' then
        inputFields[#inputFields + 1] = { name = "gang", label = L("gang"), type = "checkbox" }
    end

    local formData = lib.inputDialog(L("create_craft_title"), inputFields)

    if formData then
        local jobsSuccess = true
        local blipSuccess = true

        if formData[3] then
            jobsForm(function(jobsData)
                if not jobsData then
                    String.SendAlert({type = "warning", title = L("main_title"), msg = L("canceled_creation")})
                    jobsSuccess = false
                    return
                end
                jobs = jobsData
            end)
        end

        if formData[4] then
            blipForm(function(blipData)
                if not blipData then
                    String.SendAlert({type = "warning", title = L("main_title"), msg = L("canceled_creation")})
                    blipSuccess = false
                    return
                end
                blip = blipData
            end)
        end

        if (GetResourceState(Shared.FrameworkNames.qb) ~= 'missing' or GetResourceState(Shared.FrameworkNames.qbox) ~= 'missing') and formData[5] then
            gangsForm(function(gangsData)
                if not gangsData then
                    String.SendAlert({type = "warning", title = L("main_title"), msg = L("canceled_creation")})
                    return
                end
                gangs = gangsData
            end)
        end

        if not jobsSuccess or not blipSuccess then
            return
        end

        if formData[2] and formData[2]:match("^[%w_%-]+$") then 
            model = formData[2]
        else
            model = Shared.DefaultModel
            String.SendAlert({type = "info", title = L("main_title"), msg = L("using_default_model")})
        end

        local questionForm = lib.alertDialog({
            title = L("title_question_1"),
            content = L("question_1") .. "\n\n" .. L("disclaimer_1"),
            buttons = {
                { label = L("confirm"), value = "confirm", type = "primary" },
                { label = L("cancel"), value = "cancel", type = "secondary" },
            }
        })

        if questionForm == "confirm" then
            SetupPOS(model, function(pos)
                TriggerServerEvent("qt_crafting-SetupCraft", {
                    name = formData[1],
                    model = model,
                    coords = pos,
                    blip = blip,
                    jobs = jobs,
                    gangs = gangs,
                })
            end)
        elseif questionForm == "cancel" then
            String.SendAlert({type = "warning", title = L("main_title"), msg = L("canceled_creation")})
        end
    end
end

jobsForm = function(cb)
    local JobList = GlobalState.Jobs
    local options = {}

    for k, _ in pairs(JobList) do
       options[#options + 1] = { value = k, label = k }
    end

    local jobsInput = lib.inputDialog(L("jobs_config"), {
        { name = "selected_jobs", label = L("select_job"), type = "multi-select", options = options},
    })

    if jobsInput then
        local jobValues = jobsInput[1] 
        cb(jobValues)
    else
        cb(false)
    end
end

gangsForm = function(cb)
    local JobList = GlobalState.Gangs
    local options = {}

    for k, _ in pairs(JobList) do
        options[#options + 1] =  { value = k, label = k }
    end

    local gangsInput = lib.inputDialog(L("gangs_config"), {
        { name = "selected_gangs", label = L("select_gang"), type = "multi-select", options = options },
    })

    if gangsInput then
        local gangValues = gangsInput[1]
        cb(gangValues)
    else
        cb(false)
    end
end

blipForm = function(cb)
    local blipInput = lib.inputDialog(L("blip_config"), {
        { name = "sprite", label = L("sprite_label"), type = "number", required = true },
        { name = "size", label = L("size_label"), type = "number", required = true },
        { name = "color", label = L("color_label"), type = "number", required = true },
        { name = "text", label = L("text_label"), type = "input", required = true },
    })

    if blipInput then
        local tabela = {
            sprite = blipInput[1],
            size = blipInput[2],
            color = blipInput[3],
            text = blipInput[4],
        }
        cb(tabela)
    else
        cb(false)
    end
end

local function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end

SetupPOS = function(model, cb)
    local heading = 0
    local obj
    local created = false

    lib.requestModel(model)
    CreateThread(function()
        while true do
            ---@diagnostic disable-next-line: need-check-nil
            local hit, coords, entity = RayCastGamePlayCamera(100.0)

            if not created then
                created = true
                obj = CreateObject(model, coords.x, coords.y, coords.z + 0.5, false, false, false)
                SetEntityCollision(obj, false, true)
                SetEntityAlpha(obj, 180, false)
                
            end

            SendNUIMessage({
                action = "SetupHelpOn",
                locales = {
                    rotate_right = L('rotate_right'), 
                    rotate_left =  L('rotate_left'), 
                    save = L('save'), 
                    explanation = L('explanation'),
                }
            })

            if IsControlPressed(0, 174) then
                heading = heading + 1.5
            end

            if IsControlPressed(0, 175) then
                heading = heading - 1.5
            end

            if IsDisabledControlPressed(0, 38) then
                local pos = vector4(coords.x, coords.y, coords.z, heading)
                cb(pos)
                DeleteObject(obj)
                SendNUIMessage({
                    action = "SetupHelpOff"
                })

                break
            end

            local pedPos = GetEntityCoords(PlayerPedId())
            local distance = #(coords - pedPos)

            if distance >= 1.5 then
                SetEntityCoords(obj, coords.x, coords.y, coords.z + 0.5)
                SetEntityHeading(obj, heading)
            end
            Wait(0)
        end
    end)
    collectgarbage("collect")
end

AddEventHandler('onClientResourceStart', function (resourceName)
    if(GetCurrentResourceName() ~= resourceName) then return end
     CreateTables()
end)

local function checkJobs(id)
    local jobs = GlobalState.WorkShops[id]["jobs"]
    if jobs == nil or #jobs == 0 then
        return true
    end
    
    for i = 1, #jobs do
        if Core.getjob() == jobs[i] then
            return true
        end
    end
    return false
end

local function checkGangs(id)
    local gangs = GlobalState.WorkShops[id]["gangs"]
    if (GetResourceState(Shared.FrameworkNames.qb) ~= 'missing' and GetResourceState(Shared.FrameworkNames.qbox) ~= 'missing') and (gangs == nil or #gangs == 0) then
        return true
    end
    
    for i = 1, #gangs do
        if Core.getGangs() == gangs[i] then
            return true
        end
    end
    return false
end

local CanAcces = function(id)
    if checkJobs(id) or checkGangs(id) then
        return true
    end
    return false
end

CreateTables = function()
    Wait(500)
    if GlobalState.WorkShops ~= nil then 
        for k, v in pairs (GlobalState.WorkShops) do 
                lib.requestModel(v.model)
                propobj = CreateObject(v.model, vector3(v.coords.x, v.coords.y, v.coords.z), false, true)
                SetEntityHeading(propobj, v.coords.w)
                FreezeEntityPosition(propobj, true) 
                SetEntityInvincible(propobj, true)
                cache[#cache + 1] = {
                    obj = propobj,
                }
                SetModelAsNoLongerNeeded(v.model)
                PlaceObjectOnGroundProperly(propobj)
                if GetResourceState("ox_target") ~= 'missing' then  
                    exports.ox_target:addLocalEntity(propobj, {
                        {
                            name = 'table_'..k,
                            label = L('enter_craft'),
                            icon = "fa-solid fa-hammer",
                            distance = 3,
                            canInteract = function()
                                local access = CanAcces(v.id)
                                if access then
                                    return true
                                else
                                    return false
                                end
                            end,
                            onSelect = function(data)
                                OpenCraftMenu(v.id)
                            end,
                        }
                    })                    
                elseif GetResourceState("qb-target") ~= 'missing' then
                    exports['qb-target']:AddTargetEntity(propobj, {
                        options = {
                            {
                                icon = "fa-solid fa-hammer",
                                label = L('enter_craft'),
                                canInteract = function()
                                    local access = CanAcces(v.id)
                                    if access then
                                        return true
                                    else
                                        return false
                                    end
                                end,
                                action = function()
                                    OpenCraftMenu(v.id)
                                end,
                            }
                        },
                        distance = 3.0
                    })
                end

                if GlobalState.WorkShops[k]['blip'] ~= nil and #GlobalState.WorkShops[k]['blip'] > 0 then 
                    CreateBlip({
                        coords = GlobalState.WorkShops[k].coords, 
                        sprite = tonumber(GlobalState.WorkShops[k].blip.sprite), 
                        color = tonumber(GlobalState.WorkShops[k].blip.color), 
                        size = tonumber(GlobalState.WorkShops[k].blip.size), 
                        text = GlobalState.WorkShops[k].blip.text
                    })
                end
        end
    end
end

RegisterNetEvent("qt-crafting:Re:Sync")
 AddEventHandler("qt-crafting:Re:Sync", function()
    DeletrSequence()
    CreateTables()
end)

OpenCraftMenu = function(id)

        SendNUIMessage({
            action = "CraftMenu", 
            tableIndex = id, 
            TableName = GlobalState.WorkShops[id].name,
            Inventory = Shared.ImagePath, 
            recipes = GlobalState.Recipes
        })
        
        SetNuiFocus(true, true)

end

RegisterCommand("craft:edit", function()
    lib.callback("qt_crafting-CheckPerm", nil, function(access)
        if access then
            EditMenu()
        else
            String.SendAlert({type = "warning", title = L("main_title"), msg = L("insufficient_permissions")})
        end
    end, "edit")
end)

EditMenu = function()
    local opcije = {} 
    for k, v in pairs (GlobalState.WorkShops) do 
        opcije[#opcije + 1] = {
            title = v.name,
            icon = 'fa-solid fa-wrench',
            event = "qt_crafting-EditTable",
            description = L('to_modify'),
            args = { id = v.id, name = v.name, kreirajprop = v.kreirajprop },
            arrow = true,
        }
    end
    lib.registerContext({
        id = 'editMenu',
        title = L('edit_menu_title'),
        options = opcije
    })
    lib.showContext('editMenu')
end

function createRecipe(numRecipe, cb)
    local recipetable = {}
    for i = 1, numRecipe do
        Wait(200)
        local recipeInput = lib.inputDialog(L('reciepe_item') .. ' (' .. i .. '/' .. numRecipe .. ')', {
            { label = L("item_name"), type = 'input', required = true },
            { label = L("item_label"), type = 'input', required = true },
            { label = L("item_amount"), type = 'number', required = true },
            { label = L("removable"), type = 'checkbox' },
        })
        if not recipeInput then return end
        recipetable[#recipetable + 1] = { 
            item = recipeInput[1], 
            label = recipeInput[2], 
            amount = tonumber(recipeInput[3]), 
            removable = recipeInput[4] 
        }
    end
    cb(recipetable)
end

AddEventHandler("qt_crafting-AddItems", function(table_id)
    Wait(200)
    local formData = lib.inputDialog(L("adding_items_title"), {
        { label = L("item_name"), type = 'input', required = true },
        { label = L("item_label"), type = 'input', required = true },
        { label = L("reward_amound"), type = 'number', required = true },
        { label = L("craft_time"), type = 'number', required = true },
        { label = L("required_items_number"), type = 'number', required = true },
    })

    if formData then
        createRecipe(tonumber(formData[5]), function(recipe)
            TriggerServerEvent("qt_crafting-EditActions", {
                action = "add_item",
                item = formData[1],
                label = formData[2],
                amount = tonumber(formData[3]),
                craft_time = tonumber(formData[4]),
                id = table_id,
                recipe = recipe
            })
        end)
    end
end)

CreateBlip = function(data)

    local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    SetBlipSprite(blip, data.sprite)
    SetBlipScale(blip, 0.6) 
    SetBlipColour(blip, data.color)
    SetBlipAsShortRange(blip, true)  

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(tostring(data.text))
    EndTextCommandSetBlipName(blip)

     cache[#cache + 1] = {
         blips = blip,
     }

end



