ESX = nil
PlayersData = {}
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('pixel_drugsystemV2:RequestAction')
AddEventHandler('pixel_drugsystemV2:RequestAction', function(currentZone)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.UseCoordsFromServer then
        if Zones[currentZone] == nil then
            DropPlayer(source, 'Well, not this time bro ;D')
        end
        ItemLimit = Zones[currentZone].ItemLimit
        ItemToAdd = Zones[currentZone].ItemToAdd
        ItemToRemove = Zones[currentZone].ItemToRemove
    else
        if Config.Zones[currentZone] == nil then
            DropPlayer(source, 'Well, not this time bro ;D')
        end
        ItemLimit = Config.Zones[currentZone].ItemLimit
        ItemToAdd = Config.Zones[currentZone].ItemToAdd
        ItemToRemove = Config.Zones[currentZone].ItemToRemove
    end
    if ItemLimit <= xPlayer.getInventoryItem(ItemToAdd).count then
        xPlayer.showNotification(Config.Text["ErrorItemLimit"])
        return
    end
    if ItemToRemove ~= nil then
        if xPlayer.getInventoryItem(ItemToRemove).count > 0 then
            xPlayer.removeInventoryItem(ItemToRemove, 1)
        else
            xPlayer.showNotification(Config.Text["ErrorNoItem"])
            return
        end
    end
    TriggerClientEvent('pixel_drugsystemV2:StartAction', source)
    xPlayer.addInventoryItem(ItemToAdd, 1)
end)

RegisterServerEvent('pixel_drugsystemV2:EndAction')
AddEventHandler('pixel_drugsystemV2:EndAction', function(currentZone)
   print("dafuq")
end)

Zones = {
    ["weed1"] = {
        ["ItemToAdd"] = "weed",
        ["ItemToRemove"] = nil,
        ["ItemLimit"] = 50,
        ["Coords"] = {x = 31.84, y = -1067.76, z = 38.15},
        ["Heading"] = 162.86,
        ["TaskTime"] = 10,
        ["Animation"] = {
            ["Dict"] = "anim@amb@business@coc@coc_unpack_cut_left@",
            ["Name"] = "coke_cut_v4_coccutter"
        }
    },
    
    ["weed2"] = {
        ["ItemToAdd"] = "weed_pooch",
        ["ItemToRemove"] = "weed",
        ["ItemLimit"] = 50,
        ["Coords"] = {x = 27.61, y = -1079.88, z = 38.15},
        ["Heading"] = 160.29,
        ["TaskTime"] = 10,
        ["Animation"] = {
            ["Dict"] = "anim@amb@business@coc@coc_unpack_cut_left@",
            ["Name"] = "coke_cut_v4_coccutter"
        }
    },

    ["coke1"] = {
        ["ItemToAdd"] = "coke",
        ["ItemToRemove"] = nil,
        ["ItemLimit"] = 50,
        ["Coords"] = {x = 27.61, y = -1064.88, z = 38.15},
        ["Heading"] = 160.0,
        ["TaskTime"] = 10,
        ["Animation"] = {
            ["Dict"] = "anim@amb@business@coc@coc_unpack_cut_left@",
            ["Name"] = "coke_cut_v4_coccutter"
        }
    },

    ["coke2"] = {
        ["ItemToAdd"] = "coke_pooch",
        ["ItemToRemove"] = "coke",
        ["ItemLimit"] = 50,
        ["Coords"] = {x = 25.18, y = -1071.49, z = 38.15},
        ["Heading"] = 158.0,
        ["TaskTime"] = 10,
        ["Animation"] = {
            ["Dict"] = "anim@amb@business@coc@coc_unpack_cut_left@",
            ["Name"] = "coke_cut_v4_coccutter"
        }
    }
}

RegisterServerEvent('pixel_drugsystemV2:RequestZones')
AddEventHandler('pixel_drugsystemV2:RequestZones', function()
    local identifier = GetPlayerIdentifier(source, 0)
    if PlayersData[identifier] == nil then
        if Config.UseCoordsFromServer then
            PlayersData[identifier] = true
            TriggerClientEvent('pixel_drugsystemV2:GetZones', source, Zones)
        end
    else
        DropPlayer(source, "Well, not this time bro ;D")
    end
end)

AddEventHandler('playerDropped', function(reas)
    local identifier = GetPlayerIdentifier(source, 0)
    PlayersData[identifier] = nil
end)