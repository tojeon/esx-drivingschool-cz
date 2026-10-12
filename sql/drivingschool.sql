local routeActive = false
local routePoints = {}
local currentIndex = 1
local routeBlip = nil
local currentCategory = nil

local function clearRouteBlip()
    if routeBlip and DoesBlipExist(routeBlip) then
        RemoveBlip(routeBlip)
    end
    routeBlip = nil
end

local function createRouteBlip(coords)
    clearRouteBlip()
    routeBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(routeBlip, 1)
    SetBlipScale(routeBlip, 0.8)
    SetBlipColour(routeBlip, 2)
    SetBlipDisplay(routeBlip, 2)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Cílový bod')
    EndTextCommandSetBlipName(routeBlip)
end

local function startRoute(category)
    currentCategory = category
    routePoints = {}
    for _, data in ipairs(DrivingSchool.licenses[category].places) do
        table.insert(routePoints, vector3(data.x, data.y, data.z))
    end
    currentIndex = 1
    routeActive = true
    createRouteBlip(routePoints[currentIndex])
    ESX.ShowNotification('Instruktor: Za chvíli se rozjedeme. Drž se blipu na mapě.')
end

local function failRoute(reason)
    routeActive = false
    clearRouteBlip()
    TriggerEvent('esx_drivingschool:failRide', reason)
    TriggerServerEvent('esx_drivingschool:finishDrivingTest', currentCategory, false)
end

CreateThread(function()
    while true do
        Wait(500)
        if routeActive and currentCategory then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local dist = #(playerCoords - routePoints[currentIndex])

            if dist < 12.0 then
                if currentIndex >= #routePoints then
                    routeActive = false
                    clearRouteBlip()
                    ESX.ShowNotification('Instruktor: Jízda skončila. Vše je v pořádku, zastav a ukonči zkoušku.')
                    TriggerServerEvent('esx_drivingschool:finishDrivingTest', currentCategory, true)
                    currentCategory = nil
                else
                    currentIndex = currentIndex + 1
                    createRouteBlip(routePoints[currentIndex])
                    ESX.ShowNotification('Instruktor: Skvělý. Teď pokračujeme k dalšímu bodu.')
                end
            end

            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if vehicle and vehicle ~= 0 then
                local speed = GetEntitySpeed(vehicle) * 3.6
                if currentCategory == 'B' and speed > 80 then
                    failRoute('speed')
                elseif currentCategory == 'C' and speed > 100 then
                    failRoute('speed')
                elseif currentCategory == 'A' and speed > 70 then
                    failRoute('speed')
                end
            end
        end
    end
end)

RegisterNetEvent('esx_drivingschool:startDrivingExam')
AddEventHandler('esx_drivingschool:startDrivingExam', function(category)
    startRoute(category)
end)
