local QBCore = exports['qb-core']:GetCoreObject()
pedAlreadyBeingButchered = {}
huntingGroups = {}

QBCore.Functions.CreateCallback("lu-hunting:server:CheckIfAlreadyBeingButchered", function (_, cb)
    cb(pedAlreadyBeingButchered)
end)

QBCore.Functions.CreateCallback("lu-hunting:server:PayVehicleRent", function (source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    cb(Player.Functions.RemoveMoney('cash', config.carRentPrice))
end)

RegisterNetEvent('lu-hunting:server:GivePlayerRentalPapers', function (plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    info = {}
    info.citizenid = Player.PlayerData.citizenid
    info.firstname = Player.PlayerData.charinfo.firstname
    info.lastname = Player.PlayerData.charinfo.lastname
    info.birthdate = Player.PlayerData.charinfo.birthdate
    info.plate = plate
    Player.Functions.AddItem('rentpaper', 1, nil, info)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['rentpaper'], "add", 1)
end)


RegisterNetEvent('lu-hunting:server:RentGiveMoneyBack', function (plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local rentalpapers = Player.Functions.GetItemsByName('rentpaper')
    for index, rentalpaper in ipairs(rentalpapers) do
        if rentalpaper.info.plate == plate then 
            Player.Functions.RemoveItem(rentalpaper.name, 1, rentalpaper.slot)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['rentpaper'], "remove", 1)
            break
        end
    end
    Player.Functions.AddMoney('cash', config.carReturnMoney)
end)


-- Hunting groups

QBCore.Functions.CreateCallback("lu-hunting:server:GetGroups", function (source, cb)
    cb(huntingGroups)
end)

RegisterNetEvent('lu-hunting:server:CreateGroup', function (groupName, groupPassword, userId)
    local src = source
    for index, group in ipairs(huntingGroups) do
        if string.lower(group.groupName) == string.lower(groupName) then
            TriggerClientEvent('QBCore:Notify', src, 'This group name already exists!', 'success')
            TriggerClientEvent('lu-hunting:client:CreateGroup', src)
            return
        end
    end
    local hasPassword = false
    if string.len(groupPassword) > 0 then
        hasPassword = true
    end
    huntingGroups[#huntingGroups+1] = {groupName = groupName, hasPassword = hasPassword, groupPassword = groupPassword, members = {userId}}
    TriggerClientEvent('lu-hunting:client:UpdateHuntingGroup', src)
    TriggerClientEvent('QBCore:Notify', src, 'Your group have been created succesfully!' ,'success')
end)

RegisterNetEvent('lu-hunting:server:JoinGroup', function (data)
    local src = source
    local foundTheGroup = false
    local desiredGroup = data
    local userPassword = data.userInputPassword
    for index, group in ipairs(huntingGroups) do
        if group.groupName == desiredGroup.groupName then
            foundTheGroup = true
            if group.hasPassword and group.groupPassword == userPassword then
                if #huntingGroups[index].members < 4 then
                    huntingGroups[index].members[#huntingGroups[index].members+1] = data.userId
                else
                    TriggerClientEvent('QBCore:Notify', src, 'This group is full!' ,'error')
                    return
                end
            elseif not group.hasPassword then
                if #huntingGroups[index].members < 4 then
                    huntingGroups[index].members[#huntingGroups[index].members+1] = data.userId
                else
                    TriggerClientEvent('QBCore:Notify', src, 'This group is full!' ,'error')
                    return
                end
            else
                TriggerClientEvent('QBCore:Notify', src, 'You have entered wrong password' ,'error')
                return
            end
        end
    end
    if foundTheGroup then
        TriggerClientEvent('lu-hunting:client:UpdateHuntingGroup', src)
        TriggerClientEvent('QBCore:Notify', src, 'You have joined '.. desiredGroup.groupName ..'!' ,'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Group was not found, please try again!' ,'error')
    end
end)

RegisterNetEvent('lu-hunting:server:LeaveGroup', function (groupName, userId)
    local src = source
    for index, group in ipairs(huntingGroups) do
        if group.groupName == groupName then
            for index, member in ipairs(group.members) do
                if member == userId then 
                    table.remove(group.members, index)
                end
            end
            if #group.members == 0 then
                table.remove(huntingGroups, index)
            end
        end
    end
    local group = {}
    TriggerClientEvent('lu-hunting:client:UpdateHuntingGroup', src)
    TriggerClientEvent('QBCore:Notify', src, 'You have left the group!','success')
end)


RegisterNetEvent("lu-hunting:server:SaveEntityAsBeingButchered", function (id)
    local atIndexToDelete = #pedAlreadyBeingButchered + 1
    pedAlreadyBeingButchered[#pedAlreadyBeingButchered+1] = id
    SetTimeout(100000, function()
            table.remove(pedAlreadyBeingButchered, atIndexToDelete)
    end)
end)

RegisterNetEvent('lu-hunting:server:RewardPlayer', function (animalType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hideAmount = math.random(config['amounts'][animalType]['minHide'], config['amounts'][animalType]['maxHide'])
    local meatAmount = math.random(config['amounts'][animalType]['minMeat'], config['amounts'][animalType]['maxMeat'])
    if math.random(0, 100) >= config.chanceToGetAntlers and animalType == 'Deer' then 
        if math.random(0, 100) >= config.chanceToGetAntlers then
            if Player.Functions.AddItem('deerantlers', 2) then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['deerantlers'], "add", 2)
            else
                return
            end
        else
            if Player.Functions.AddItem('deerantlers', 1) then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['deerantlers'], "add", 1)
            else
                return
            end
        end 
    end
    if Player.Functions.AddItem(string.lower(animalType)..'hide', hideAmount) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[string.lower(animalType)..'hide'], "add", hideAmount)
    else
        return
    end
    if Player.Functions.AddItem(string.lower(animalType)..'meat', meatAmount) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[string.lower(animalType)..'meat'], "add", meatAmount)
    else
        return
    end
    TriggerClientEvent('QBCore:Notify', src, 'You have skinned the animal perfectly!' ,'success')
end)

RegisterNetEvent('lu-hunting:server:SellItem', function (data)
    local itemData = data.itemData
    local playerGroup = data.playerGroup
    local groupBonus = 1
    local playerNetworkId = data.playerNetworkId
    local next = next
    if next(playerGroup) ~= nil then
        for i, members in ipairs(playerGroup.members) do
            if members == playerNetworkId then
                groupBonus = config.groupBonus[#playerGroup.members]
                break
            end
        end
    end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local itemName = itemData[1]
    local animalType = itemData[2]
    local itemAmount = Player.Functions.GetItemByName(itemName).amount
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local hunterVector3 = vector3(config.hunter.coords.x, config.hunter.coords.y, config.hunter.coords.z)
    if #(playerCoords - hunterVector3) > 5 then
        print("player is cheating!")
    else
        if Player.Functions.RemoveItem(itemName, itemAmount) then
            local totalPrice = 0
            for i = 1, itemAmount, 1 do
                local payoutForAPiece = math.random(config['prices'][animalType][itemName].minPrice, config['prices'][animalType][itemName].maxPrice) * groupBonus
                totalPrice = totalPrice + payoutForAPiece
            end
            Player.Functions.AddMoney('cash', math.floor(totalPrice))
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'remove', itemAmount)
            TriggerClientEvent('QBCore:Notify', src, 'You have sold the hunter '.. itemAmount .. ' pieces of ' .. QBCore.Shared.Items[itemName].label,'success')
            if groupBonus > 1 then
                TriggerClientEvent('QBCore:Notify', src, 'You have received a bonus for being a member of a group!','success')
            end
            TriggerClientEvent('lu-hunting:client:ValidateHasItem', src, true)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Unknown error occured please report it as a bug!' ,'error')
        end
    end
end)



