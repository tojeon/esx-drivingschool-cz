local isInsideTest = false
local currentExam = nil
local routeBlip = nil
local routePoints = {}
local routeIndex = 0
local instructorPed = nil
local instructorVehicle = nil
local messageTimer = 0

local function notify(msg)
    ESX.ShowNotification(msg)
end

local function speak(msg)
    if msg then
        SetTimeout(250, function()
            ESX.ShowNotification(msg)
        end)
    end
end

local function clearRouteBlip()
    if routeBlip and DoesBlipExist(routeBlip) then
        RemoveBlip(routeBlip)
    end
    routeBlip = nil
end

local function createInstructorPed(coords, heading)
    if instructorPed and DoesEntityExist(instructorPed) then
        return instructorPed
    end

    local model = GetHashKey('s_m_m_autopsy_01')
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(50)
    end

    instructorPed = CreatePed(4, model, coords.x, coords.y, coords.z, heading, false, false)
    SetEntityAsMissionEntity(instructorPed, true, true)
    SetPedCanRagdoll(instructorPed, false)
    SetBlockingOfNonTemporaryEvents(instructorPed, true)
    SetPedDefaultComponentVariation(instructorPed)
    return instructorPed
end

local function spawnInstructorVehicle(category)
    local model = GetHashKey(DrivingSchool.licenses[category].vehicle)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(50)
    end

    local vehicle = CreateVehicle(model, DrivingSchool.school.coords.x + 3.5, DrivingSchool.school.coords.y, DrivingSchool.school.coords.z, DrivingSchool.school.coords.w or 0.0, true, false)
    SetVehicleNumberPlateText(vehicle, 'DRIVE' .. category)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
    return vehicle
end

local function setInstructorIntoPlayerVehicle(playerVehicle)
    if not instructorPed or not DoesEntityExist(instructorPed) then
        return
    end

    if playerVehicle and DoesEntityExist(playerVehicle) then
        SetPedIntoVehicle(instructorPed, playerVehicle, -1)
        SetEntityInvincible(instructorPed, true)
        SetDriverAbility(instructorPed, 1.0)
        SetPedKeepTask(instructorPed, true)
    end
end

local function addRouteBlip(coords)
    clearRouteBlip()
    routeBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(routeBlip, 1)
    SetBlipColour(routeBlip, 2)
    SetBlipScale(routeBlip, 0.9)
    SetBlipDisplay(routeBlip, 2)
    SetBlipAsShortRange(routeBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Trasa zkoušky')
    EndTextCommandSetBlipName(routeBlip)
end

local function nextRoutePoint()
    if not currentExam then return end
    routeIndex = routeIndex + 1
    if routeIndex > #routePoints then
        routeIndex = 1
    end

    local point = routePoints[routeIndex]
    addRouteBlip(point)
    speak('Instruktor: ' .. point.text)
end

local function startExam(category)
    if isInsideTest then
        notify('Již probíhá zkouška.')
        return
    end

    currentExam = category
    isInsideTest = true
    routeIndex = 0
    routePoints = {}

    for i, point in ipairs(DrivingSchool.licenses[category].places) do
        table.insert(routePoints, {
            x = point.x,
            y = point.y,
            z = point.z,
            text = DrivingSchool.licenses[category].instructions[i] or 'Pokračujte dále.',
        })
    end

    local ped = createInstructorPed(DrivingSchool.school.pedCoords, DrivingSchool.school.pedHeading)
    if not ped then return end

    local vehicle = spawnInstructorVehicle(category)
    if not vehicle then return end

    local playerPed = PlayerPedId()
    local playerVehicle = GetVehiclePedIsIn(playerPed, false)

    if not playerVehicle or playerVehicle == 0 then
        local spawnVehicle = GetHashKey(DrivingSchool.licenses[category].vehicle)
        RequestModel(spawnVehicle)
        while not HasModelLoaded(spawnVehicle) do Wait(50) end

        playerVehicle = CreateVehicle(spawnVehicle, DrivingSchool.school.coords.x + 6.0, DrivingSchool.school.coords.y + 5.0, DrivingSchool.school.coords.z, 0.0, true, false)
        SetVehicleNumberPlateText(playerVehicle, 'TEST' .. category)
        TaskWarpPedIntoVehicle(playerPed, playerVehicle, -1)
    end

    setInstructorIntoPlayerVehicle(playerVehicle)
    nextRoutePoint()

    speak('Instruktor: Ahoj, pojď se mnou. Dneska pojedeš školní zkoušku. Já tě budu navigovat.')
    speak('Instruktor: Drž se trasy, ne přetěžuj rychlost a neznervóznívsek. Všechno bude v pořádku.')
end

local function finishExam(success)
    if not isInsideTest then return end

    isInsideTest = false
    currentExam = nil
    routeIndex = 0
    clearRouteBlip()

    if instructorPed and DoesEntityExist(instructorPed) then
        DeletePed(instructorPed)
        instructorPed = nil
    end

    TriggerServerEvent('esx_drivingschool:finishDrivingTest', success and currentExam or currentExam, success)

    if success then
        speak('Instruktor: Výborně! Jízdu jsi zvládl. Je to dobré a můžeš dostat řidičský průkaz.')
    else
        speak('Instruktor: To byla hrozná jízda, **tohle** jste nedokázal. Zkusíme to znova. A teď se vrať na start.')
    end
end

local function checkRouteProgress()
    if not isInsideTest or not currentExam then return end

    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if not vehicle or vehicle == 0 then return end

    local target = routePoints[routeIndex]
    if not target then return end

    local dist = #(GetEntityCoords(playerPed) - vector3(target.x, target.y, target.z))
    if dist < 10.0 then
        if routeIndex == #routePoints then
            finishExam(true)
        else
            nextRoutePoint()
        end
    end

    local speed = GetEntitySpeed(vehicle) * 3.6
    if speed > 80 and currentExam == 'B' then
        notify('Instruktor: Ty hajzle, přetěžuješ rychlost! To se neodpuští!')
        finishExam(false)
    elseif speed > 100 and currentExam == 'C' then
        notify('Instruktor: To je moc rychle! Tohle je nebezpečné a neprofesionální!')
        finishExam(false)
    end
end

CreateThread(function()
    while true do
        Wait(1000)
        if isInsideTest then
            checkRouteProgress()
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if instructorPed and DoesEntityExist(instructorPed) then
            DeletePed(instructorPed)
        end
        clearRouteBlip()
    end
end)

RegisterCommand('testdrive', function()
    startExam('B')
end, false)

RegisterNetEvent('esx_drivingschool:openMenu')
AddEventHandler('esx_drivingschool:openMenu', function()
    local elements = {}
    for category, cfg in pairs(DrivingSchool.licenses) do
        table.insert(elements, {
            label = cfg.label .. ' – ' .. cfg.price .. '$',
            value = category,
        })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'driving_school_menu', {
        title = 'Autoškola',
        align = 'top-left',
        elements = elements,
    }, function(data, menu)
        TriggerServerEvent('esx_drivingschool:purchaseLicense', data.current.value)
        menu.close()
    end, function(_, menu)
        menu.close()
    end)
end)

RegisterNetEvent('esx_drivingschool:theoryResult')
AddEventHandler('esx_drivingschool:theoryResult', function(success, msg)
    if success then
        notify('Teoretická zkouška: úspěšně složena.')
    else
        notify('Teoretická zkouška: neprošla. ' .. msg)
    end
end)

RegisterNetEvent('esx_drivingschool:drivingResult')
AddEventHandler('esx_drivingschool:drivingResult', function(success, msg)
    if success then
        notify('Praktická zkouška: splněna.')
    else
        notify('Praktická zkouška: neprošla. ' .. msg)
    end
end)

RegisterNetEvent('esx_drivingschool:licenseOwned')
AddEventHandler('esx_drivingschool:licenseOwned', function(category, owned)
    if owned then
        notify('Máš licenci: ' .. DrivingSchool.licenses[category].label)
    end
end)
