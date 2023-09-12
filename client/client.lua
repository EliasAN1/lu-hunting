local QBCore = exports['qb-core']:GetCoreObject()
local RentedVehicles = {}
local vehicleToReturn = {}
local huntingGroup = {}

local function setupClient()
    if not config.blip then return end
    local huntingBlip = AddBlipForCoord(config.blip.location.x, config.blip.location.y, config.blip.location.z)
    SetBlipSprite(huntingBlip, 141)
    SetBlipDisplay(huntingBlip, 2)
    SetBlipScale(huntingBlip, 1.5)
    SetBlipAsShortRange(huntingBlip, true)
    SetBlipColour(huntingBlip, 52)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(config.blip.blipName)
    EndTextCommandSetBlipName(huntingBlip)
end

local function spawnPed()    
    if not config.hunter then return end
    if type(config.hunter.model) ~= 'string' then return end
    local hunterModel = GetHashKey(config.hunter.model)
    RequestModel(hunterModel)
    while not HasModelLoaded(hunterModel) do
        Wait(0)
    end
    local pedCreated = CreatePed(0, hunterModel, config.hunter.coords.x, config.hunter.coords.y, config.hunter.coords.z, config.hunter.coords.w, false, false)
    FreezeEntityPosition(pedCreated, true)
    SetEntityInvincible(pedCreated, true)
    SetBlockingOfNonTemporaryEvents(pedCreated, true)
    exports['qb-target']:AddTargetEntity(pedCreated, {
        options = {{type = "client", event = "lu-hunter:client:talkToTheHunter", label = "Talk to the Hunter", icon = 'fa-brands fa-wolf-pack-battalion', canInteract = function (entity)
            if not IsPedInAnyVehicle(PlayerPedId()) and not IsEntityDead(PlayerPedId()) then
                return true
            end 
        end}},
        distance = 2.0
    })
end

local function setupTarget()
    local distance = 2.0
    exports['qb-target']:AddTargetModel('a_c_deer', {
        options = {{type = "client", event = "lu-hunter:client:SkinAnimal", label = 'Skin animal', animalType = 'Deer', icon = 'fa-brands fa-wolf-pack-battalion', canInteract = function (entity)
            if IsEntityDead(entity) and not IsEntityDead(PlayerPedId()) and not IsPedInAnyVehicle(PlayerPedId()) then
                return true
            end
        end}},
        distance = distance
    })
    exports['qb-target']:AddTargetModel('a_c_mtlion', {
        options = {{type = "client", event = "lu-hunter:client:SkinAnimal", label = 'Skin animal', animalType = 'Mtlion', icon = 'fa-brands fa-wolf-pack-battalion', canInteract = function (entity)
            if IsEntityDead(entity) and not IsEntityDead(PlayerPedId()) and not IsPedInAnyVehicle(PlayerPedId()) then
                return true
            end
        end}},
        distance = distance
    })
    exports['qb-target']:AddTargetModel('a_c_boar', {
        options = {{type = "client", event = "lu-hunter:client:SkinAnimal", label = 'Skin animal', animalType = 'Boar', icon = 'fa-brands fa-wolf-pack-battalion', canInteract = function (entity)
            if IsEntityDead(entity) and not IsEntityDead(PlayerPedId()) and not IsPedInAnyVehicle(PlayerPedId()) then
                return true
            end
        end}},
        distance = distance
    })
    exports['qb-target']:AddTargetModel('a_c_rabbit_01', {
        options = {{type = "client", event = "lu-hunter:client:SkinAnimal", label = 'Skin animal', animalType = 'Rabbit', icon = 'fa-brands fa-wolf-pack-battalion', canInteract = function (entity)
            if IsEntityDead(entity) and not IsEntityDead(PlayerPedId()) and not IsPedInAnyVehicle(PlayerPedId()) then
                return true
            end
        end}},
        distance = distance
    })
    exports['qb-target']:AddTargetModel('a_c_pig', {
        options = {{type = "client", event = "lu-hunter:client:SkinAnimal", label = 'Skin animal', animalType = 'Pig', icon = 'fa-brands fa-wolf-pack-battalion', canInteract = function (entity)
            if IsEntityDead(entity) and not IsEntityDead(PlayerPedId()) and not IsPedInAnyVehicle(PlayerPedId()) then
                return true
            end
        end}},
        distance = distance
    })
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(0)
    end
end

function makeEntityFaceEntity(entity1, entity2)
    local p1 = GetEntityCoords(entity1, true)
    local p2 = GetEntityCoords(entity2, true)

    local dx = p2.x - p1.x
    local dy = p2.y - p1.y

    local heading = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading(entity1, heading)
end

function ToggleSlaughterAnimation(toggle, animalEnity)
    local ped = PlayerPedId()
    Wait(250)
    if toggle then
        makeEntityFaceEntity(ped, animalEnity)
        loadAnimDict('amb@medic@standing@kneel@base')
        loadAnimDict('anim@gangops@facility@servers@bodysearch@')
        TaskPlayAnim(GetPlayerPed(-1), "amb@medic@standing@kneel@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
        TaskPlayAnim(GetPlayerPed(-1), "anim@gangops@facility@servers@bodysearch@", "player_search", 8.0, -8.0, -1, 1,
            0, false, false, false)
    elseif not toggle then
        SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
        ClearPedTasks(ped)
    end
end

local function openHunterMenu(header, buttons)
    local header = header
    local close =         {
        header = 'Leave the hunter alone',
        txt = "",
        params = {
            event = "qb-menu:closeMenu"
        }
    }
    menuHunterOptions = {header}
    if #buttons <= 1 then
        menuHunterOptions[#menuHunterOptions+1] = buttons

    else
        
        for i, button in ipairs(buttons) do
            menuHunterOptions[#menuHunterOptions+1] = button
        end
    end
    menuHunterOptions[#menuHunterOptions+1] = close
    exports['qb-menu']:openMenu(menuHunterOptions)
end


-- Inital menu

RegisterNetEvent('lu-hunter:client:talkToTheHunter',function ()
    buttons = {}
    header = {
        header = 'Hunter shop',
        isMenuHeader = true
    }
    buttons[#buttons+1] = {
        header = 'Sell items',
        txt = '',
        params = {
            event = "lu-hunting:client:ValidateHasItem",
        }
    }
    buttons[#buttons+1] = {
        header = 'Rent a hunting vehicle',
        txt = 'deposit $2000 and will return $1500 when returning the car',
        params = {
            event = "lu-hunting:client:RentingVehicle",
        }
    }
    if #RentedVehicles > 0 then 
        for index, vehicle in ipairs(RentedVehicles) do
            local vehicleCoords = GetEntityCoords(vehicle.vehicleEntity)
            local hunterCoords = vector3(config.hunter.coords.x, config.hunter.coords.y, config.hunter.coords.z)
            local dist = #(hunterCoords - vehicleCoords)
            if dist < 20 then  
                buttons[#buttons+1] = {
                    header = 'Return rented vehicle',
                    txt = 'You will recieve $'.. config.carReturnMoney,
                    params = {
                        event = "lu-hunting:client:ReturnVehicle",
                    }
                }
                vehicleToReturn = vehicle
                break
            end
        end
    end
    TriggerEvent('lu-hunting:client:UpdateHuntingGroup')
    if huntingGroup.groupName then
        buttons[#buttons+1] = {
            header = huntingGroup.groupName,
            txt = 'This is the current group you are in. ('.. #huntingGroup.members .. '/4) hunters. Click to leave',
            params = {
                event = "lu-hunting:client:LeaveGroup",
                args = {
                    groupName = huntingGroup.groupName, 
                }
            }
        }
    else
        buttons[#buttons+1] = {
            header = 'Hunting groups',
            txt = 'Start hunting with people and make new friends!',
            params = {
                event = "lu-hunting:client:GetGroups",
            }
        }
    end
    openHunterMenu(header, buttons)
end)


-- Hunting /////

-- Check if he has items, if true then prepare a menu to sell the found items in inventory

RegisterNetEvent('lu-hunting:client:ValidateHasItem', function (recalculation)
    recalculation = recalculation or false
    local sellableItems = {}
    for i, item in ipairs(config.huntingSellables) do
        local hasItem = QBCore.Functions.HasItem(item.itemName, 1)
        if hasItem then 
            sellableItems[#sellableItems+1] = {
                header = 'Sell ' .. item.itemLabel,
                txt = '',
                params = {
                    event = 'lu-hunting:client:SellItem',
                    args = {{item.itemName, item.animalType}}
                }
            }
        end
    end
 
    if #sellableItems == 0 and not recalculation then
        QBCore.Functions.Notify("Go away, Stop wasting my time!", 'error', 5000)
        return
    elseif #sellableItems == 0 and recalculation then
        return
    elseif #sellableItems == 1 then
        sellableItems = sellableItems[1]
    end
    header = {
        header = 'Hunter shop',
        isMenuHeader = true
    }
    openHunterMenu(header, sellableItems)
end)

-- Selling the items to the hunter

RegisterNetEvent('lu-hunting:client:SellItem', function(args)
    local data = {itemData = args[1], playerGroup = huntingGroup, playerNetworkId = NetworkGetNetworkIdFromEntity(GetPlayerPed(-1))}
    TriggerServerEvent('lu-hunting:server:SellItem', data)
end)

-- Skinning animals

RegisterNetEvent('lu-hunter:client:SkinAnimal', function (args)

    if QBCore.Functions.HasItem('weapon_knife') then
        local animalPed = args.entity
        local pedNetworkId = NetworkGetNetworkIdFromEntity(animalPed)
        local shouldContinue = nil
        QBCore.Functions.TriggerCallback("lu-hunting:server:CheckIfAlreadyBeingButchered", function(pedAlreadyBeingButchered)
            for _, pedId in ipairs(pedAlreadyBeingButchered) do
                if pedId == pedNetworkId then
                    QBCore.Functions.Notify('This animals is already being butchered!!', 'error', 5000)
                    shouldContinue = false
                    return
                end            
            end
            shouldContinue = true
            TriggerServerEvent('lu-hunting:server:SaveEntityAsBeingButchered', pedNetworkId)
        end)
        while shouldContinue == nil do
            Wait(0)
        end
        if not shouldContinue then 
            return 
        end
        if GetPedCauseOfDeath(animalPed) == GetHashKey(config.weaponUsedForHunting) then
            if GetCurrentPedWeapon(GetPlayerPed(-1)) then SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey('weapon_unarmed'), true) Wait(2000) end
            ToggleSlaughterAnimation(true, animalPed)
            QBCore.Functions.Progressbar("skining_animal", 'Butchering', 7500, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                DeleteEntity(args.entity)
                TriggerServerEvent('lu-hunting:server:RewardPlayer', args.animalType)
            end, function() -- Cancel
                DeleteEntity(args.entity)
                QBCore.Functions.Notify('You have canceled the skinning process!', "error")
            end)
        else
            QBCore.Functions.Notify('The gun that you used is bad for hunting!', 'error', 5000)
        end
    else
        QBCore.Functions.Notify('I think you are missing an important item used for skinning!', 'error', 5000)
    end
end)


-- Renting a vehicle

RegisterNetEvent('lu-hunting:client:RentingVehicle', function ()
    QBCore.Functions.TriggerCallback('lu-hunting:server:PayVehicleRent', function (payed)
        if payed then
            local hashedCarName = GetHashKey('seminole2')
            RequestModel(hashedCarName)
            while not HasModelLoaded(hashedCarName) do
                Wait(0)
            end
            local createdVehicle = CreateVehicle(hashedCarName, -684.78, 5834.67, 17.33 + 3.0, 132.3, true, false)
            local licensePlate = 'RENT' .. math.random(1000,9999) .. ''
            SetVehicleNumberPlateText(createdVehicle, licensePlate)
            exports['LegacyFuel']:SetFuel(createdVehicle, 100.0)
            SetEntityAsMissionEntity(createdVehicle, true, true)
            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(createdVehicle))
            TriggerServerEvent('lu-hunting:server:GivePlayerRentalPapers', licensePlate)
            RentedVehicles[#RentedVehicles+1] = {vehicleEntity = createdVehicle, vehiclePlateNumber = licensePlate}
            SetModelAsNoLongerNeeded(hashedCarName)
        else
            QBCore.Functions.Notify('You don\'t have enough cash!', 'error', 5000)
        end
    end)  
end)

RegisterNetEvent('lu-hunting:client:ReturnVehicle', function ()
    TriggerServerEvent("lu-hunting:server:RentGiveMoneyBack", vehicleToReturn.vehiclePlateNumber)
    local vehicle = vehicleToReturn.vehicleEntity
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
    vehicleToReturn = {}
    for i = 1, #rentedVehicles, 1 do
        if rentedVehicles[i].licensePlate == licensePlate then  
            table.remove(rentedVehicles, i)
        end
    end

end)

-- Joining or Creating or Leaving hunting group

AddEventHandler('lu-hunting:client:GetGroups', function ()
    QBCore.Functions.TriggerCallback('lu-hunting:server:GetGroups', function (groups)
        header = {
            header = 'Hunter groups',
            isMenuHeader = true
        }
        buttons = {}

        buttons[#buttons+1] = {
            header = 'Create a group',
            txt = 'Create your own group',
            params = {
                event = "lu-hunting:client:CreateGroup",
            }
        }

        for index, group in ipairs(groups) do
            local disabled = false
            if group.totalPlayers == 4 then
                disabled = true
            end
            group["userId"] = NetworkGetNetworkIdFromEntity(GetPlayerPed(-1))
            if group.hasPassword then
                buttons[#buttons+1] = {
                    header = 'Join ' .. group.groupName,
                    txt = 'Hunters ('.. #group.members .. '/4)',
                    params = {
                        event = "lu-hunting:client:JoinGroupWithPassword",
                        args = {
                            group = group, 
                        }
                    },
                    disabled = disabled
                }
            else
                buttons[#buttons+1] = {
                    header = 'Join ' .. group.groupName,
                    txt = 'Hunters ('.. #group.members .. '/4)',
                    params = {
                        event = "lu-hunting:client:JoinGroup",
                        args = {
                            group = group, 
                        }
                    },
                    disabled = disabled
                }
            end
        end 
        if #buttons == 1 then
            buttons = buttons[1]
        end 
        openHunterMenu(header, buttons)
    end)
end)

RegisterNetEvent('lu-hunting:client:CreateGroup', function ()
    local groupInfo = exports['qb-input']:ShowInput({
        header = "Create hunter group",
        submitText = "Create",
        inputs = {
            {
                text = "Group name", 
                name = "groupName",
                type = "text",
                isRequired = true
            },
            {
                text = "Password", -- text you want to be displayed as a place holder
                name = "groupPassword", -- name of the input should be unique otherwise it might override
                type = "text", -- type of the input
                isRequired = false
            }
        },
    })
    if groupInfo == nil then return end
    TriggerServerEvent('lu-hunting:server:CreateGroup', groupInfo.groupName, groupInfo.groupPassword, NetworkGetNetworkIdFromEntity(GetPlayerPed(-1)))
end)

RegisterNetEvent('lu-hunting:client:UpdateHuntingGroup', function ()
    QBCore.Functions.TriggerCallback('lu-hunting:server:GetGroups', function (groups)
        local groupWasFound = false
        local networkId = NetworkGetNetworkIdFromEntity(GetPlayerPed(-1))
        for index, group in ipairs(groups) do
            for index, member in ipairs(group.members) do
                if member == networkId then
                    huntingGroup = group
                    groupWasFound = true
                end
            end
        end
        if not groupWasFound then
            huntingGroup = {}
        end
    end)

end)

RegisterNetEvent('lu-hunting:client:JoinGroupWithPassword', function (data)
    local group = data.group
    local groupInfo = exports['qb-input']:ShowInput({
        header = "Join " .. group.groupName,
        submitText = "Create",
        inputs = {
            {
                text = "Password", -- text you want to be displayed as a place holder
                name = "groupPassword", -- name of the input should be unique otherwise it might override
                type = "text", -- type of the input
                isRequired = false
            }
        },
    })
    group["userInputPassword"] = groupInfo.groupPassword
    TriggerServerEvent('lu-hunting:server:JoinGroup', group)
end)

RegisterNetEvent('lu-hunting:client:JoinGroup', function (data)
    local group = data.group
    TriggerServerEvent('lu-hunting:server:JoinGroup', group)
end)    

RegisterNetEvent('lu-hunting:client:LeaveGroup', function (data)
    TriggerServerEvent('lu-hunting:server:LeaveGroup', data.groupName, NetworkGetNetworkIdFromEntity(GetPlayerPed(-1)))
end)





-- Loading script

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    spawnPed()
    setupClient()
    setupTarget()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    spawnPed()
    setupClient()
    setupTarget()
end)