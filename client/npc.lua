local schoolPed = nil
local schoolBlip = nil
local schoolZone = nil
local inZone = false

local function notify(msg)
    ESX.ShowNotification(msg)
end

local function createSchoolPed()
    if schoolPed and DoesEntityExist(schoolPed) then
        return schoolPed
    end

    local model = GetHashKey(DrivingSchool.school.npcModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(50)
    end

    schoolPed = CreatePed(4, model, DrivingSchool.school.pedCoords.x, DrivingSchool.school.pedCoords.y, DrivingSchool.school.pedCoords.z, DrivingSchool.school.pedHeading, false, true)
    SetEntityAsMissionEntity(schoolPed, true, true)
    SetBlockingOfNonTemporaryEvents(schoolPed, true)
    FreezeEntityPosition(schoolPed, true)
    SetEntityInvincible(schoolPed, true)
    SetPedDefaultComponentVariation(schoolPed)
    return schoolPed
end

local function createSchoolBlip()
    if schoolBlip and DoesBlipExist(schoolBlip) then
        return schoolBlip
    end

    schoolBlip = AddBlipForCoord(DrivingSchool.school.coords.x, DrivingSchool.school.coords.y, DrivingSchool.school.coords.z)
    SetBlipSprite(schoolBlip, 225)
    SetBlipScale(schoolBlip, 0.8)
    SetBlipColour(schoolBlip, 3)
    SetBlipDisplay(schoolBlip, 4)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Autoškola')
    EndTextCommandSetBlipName(schoolBlip)
    return schoolBlip
end

local function setupTargetInteractions()
    exports.ox_target:addBoxZone({
        coords = vec3(DrivingSchool.school.pedCoords.x, DrivingSchool.school.pedCoords.y, DrivingSchool.school.pedCoords.z),
        size = vec3(1.8, 1.8, 2.0),
        rotation = 45.0,
        debug = false,
        options = {
            {
                name = 'drivingschool_interact',
                label = 'Autoškola – otevřít nabídku',
                icon = 'fas fa-car',
                distance = 2.3,
                onSelect = function()
                    TriggerEvent('esx_drivingschool:openMenu')
                end,
            },
        },
    })
end

local function openTheoryExam(category)
    ESX.TriggerServerCallback('esx_drivingschool:getQuestions', function(questions)
        local form = {
            title = 'Teoretická zkouška – ' .. DrivingSchool.licenses[category].label,
            rows = {},
        }

        for i, q in ipairs(questions) do
            table.insert(form.rows, {
                text = q.question,
                type = 'select',
                options = {
                    { label = q.answer_1, value = 1 },
                    { label = q.answer_2, value = 2 },
                    { label = q.answer_3, value = 3 },
                    { label = q.answer_4, value = 4 },
                },
            })
        end

        lib.registerContext({
            id = 'driving_school_exam',
            title = 'Teoretická zkouška',
            options = {
                { label = 'Odeslat odpovědi', onSelect = function()
                    local answers = {}
                    for i, row in ipairs(form.rows) do
                        answers[i] = row.value or 1
                    end
                    TriggerServerEvent('esx_drivingschool:submitTheoryExam', category, answers)
                end },
            }
        })

        lib.showContext('driving_school_exam')
    end, category)
end

AddEventHandler('esx:onPlayerSpawn', function()
    createSchoolPed()
    createSchoolBlip()
    setupTargetInteractions()
end)

CreateThread(function()
    while true do
        Wait(1000)
        if LocalPlayer.state.isLoggedIn then
            createSchoolPed()
            createSchoolBlip()
            break
        end
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    createSchoolPed()
    createSchoolBlip()
    setupTargetInteractions()
end)

RegisterNetEvent('esx_drivingschool:openMenu')
AddEventHandler('esx_drivingschool:openMenu', function()
    local elements = {}
    for category, cfg in pairs(DrivingSchool.licenses) do
        table.insert(elements, {
            label = cfg.label .. ' – ' .. cfg.price .. '$',
            value = category,
        })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'drivingschool_menu', {
        title = 'Autoškola',
        align = 'top-left',
        elements = elements,
    }, function(data, menu)
        local category = data.current.value
        TriggerServerEvent('esx_drivingschool:purchaseLicense', category)
        menu.close()
    end, function(_, menu)
        menu.close()
    end)
end)

RegisterNetEvent('esx_drivingschool:showDrivingMenu')
AddEventHandler('esx_drivingschool:showDrivingMenu', function()
    local elements = {
        { label = 'Teoretická zkouška – A', value = 'A' },
        { label = 'Teoretická zkouška – B', value = 'B' },
        { label = 'Teoretická zkouška – C', value = 'C' },
        { label = 'Praktická zkouška – A', value = 'A_practical' },
        { label = 'Praktická zkouška – B', value = 'B_practical' },
        { label = 'Praktická zkouška – C', value = 'C_practical' },
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'drivingschool_choices', {
        title = 'Výběr zkoušky',
        align = 'top-left',
        elements = elements,
    }, function(data, menu)
        local choice = data.current.value
        if choice == 'A' or choice == 'B' or choice == 'C' then
            openTheoryExam(choice)
        else
            local cat = string.sub(choice, 1, 1)
            TriggerEvent('esx_drivingschool:startDrivingExam', cat)
        end
        menu.close()
    end, function(_, menu)
        menu.close()
    end)
end)

RegisterNetEvent('esx_drivingschool:startDrivingExam')
AddEventHandler('esx_drivingschool:startDrivingExam', function(category)
    local vehicleModel = DrivingSchool.licenses[category].vehicle
    local vehicleHash = GetHashKey(vehicleModel)
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do Wait(50) end

    local vehicle = CreateVehicle(vehicleHash, DrivingSchool.school.coords.x + 8.0, DrivingSchool.school.coords.y + 6.0, DrivingSchool.school.coords.z, 0.0, true, false)
    SetVehicleEngineOn(vehicle, true, true, false)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)

    TriggerEvent('esx_drivingschool:instructorRide', category)
end)
