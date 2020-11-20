ESX = nil
isBusy = false
currentZone = nil
PlayerData = {}
Citizen.CreateThread(function()
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end
    PlayerData = ESX.GetPlayerData()
    if Config.UseCoordsFromServer then
        TriggerServerEvent('pixel_drugsystemV2:RequestZones')
    end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

Citizen.CreateThread(function()
    while true do
        if ESX ~= nil and PlayerData ~= nil and not IsPlayersJobBlacklisted() then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local drawingMarker = false
            for k,v in pairs(Config.Zones) do
                local dist = #(playerCoords - vector3(v.Coords.x, v.Coords.y, v.Coords.z))
                if dist <= Config.DrawDistance["Marker"] then
                    drawingMarker = true
                    DrawMarker(Config.Marker.Type, v.Coords.x, v.Coords.y, v.Coords.z, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, Config.Marker.Size.x, Config.Marker.Size.y, Config.Marker.Size.z, Config.Marker.Colors.r, Config.Marker.Colors.g, Config.Marker.Colors.b, Config.Marker.Colors.alpha, false, true, 2, false, false, false, false)
                end
                if dist <= Config.DrawDistance["Text"] and not isBusy and not IsPedInAnyVehicle(PlayerPedId()) then
                    Draw3DText(v.Coords, Config.Text['PressE'])
                    if IsControlJustPressed(0, 51) then
                        currentZone = k
                        TriggerServerEvent('pixel_drugsystemV2:RequestAction', currentZone)
                    end
                end
            end
            if not drawingMarker then
                Citizen.Wait(750)
            end
        else
            Citizen.Wait(500)
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('pixel_drugsystemV2:GetZones')
AddEventHandler('pixel_drugsystemV2:GetZones', function(zns)
    Config.Zones = zns
end)

RegisterNetEvent('pixel_drugsystemV2:StartAction')
AddEventHandler('pixel_drugsystemV2:StartAction', function()
    isBusy = true
    if currentZone ~= nil then
        if Config.Zones[currentZone].Heading ~= nil then
            SetEntityHeading(PlayerPedId(), Config.Zones[currentZone].Heading)
        end
        PlayAnimation(Config.Zones[currentZone].Animation)
        DrawPercent(Config.Zones[currentZone].TaskTime)
        ClearPedTasks(PlayerPedId())
        isBusy = false
        currentZone = nil
    end
end)

function PlayAnimation(anim)
    ClearPedTasks(PlayerPedId())
    while not HasAnimDictLoaded(anim.Dict) do
        RequestAnimDict(anim.Dict)
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), anim.Dict, anim.Name, 8.0, 3.0, -1, 57, 1, false, false, false)
end

function DrawPercent(time)
    FreezeEntityPosition(PlayerPedId(), true)
    TriggerEvent('pixel_drugsystemV2:DrawPercent')
    TimeLeft = 0
    repeat
    TimeLeft = TimeLeft + 1
    Citizen.Wait(time)
    until(TimeLeft == 100)
    showPro = false
    FreezeEntityPosition(PlayerPedId(), false)
  end

RegisterNetEvent('pixel_drugsystemV2:DrawPercent')
AddEventHandler('pixel_drugsystemV2:DrawPercent', function()
  showPro = true
    while showPro do
      Citizen.Wait(0)
      DisableControlAction(0, 73, true)
      Draw3DText(GetEntityCoords(PlayerPedId()), "~b~"..TimeLeft.."~g~%")
    end
end)

function Draw3DText(coords, text)
    local onScreen,_x,_y=World3dToScreen2d(coords.x,coords.y,coords.z)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    SetTextOutline()
    DrawText(_x,_y)
end

function IsPlayersJobBlacklisted()
    if Config.HideFromPolice and #Config.BlacklistedJobs > 0 and PlayerData.job ~= nil then
        for k,v in ipairs(Config.BlacklistedJobs) do
            if PlayerData.job.name == v then
                return true
            end
        end
    end
    return false
end