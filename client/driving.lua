local instructorPed = nil
local instructorVehicle = nil
local currentCategory = nil
local currentMessageIndex = 1

local function speakInstruction(text)
    if text then
        ESX.ShowNotification(text)
        PlaySoundFrontend(-1, 'CHECKPOINT_PERFECT', 'HUD_MINI_GAME_SOUNDSET', true)
    end
end

local function createInstructorPed(category)
    if instructorPed and DoesEntityExist(instructorPed) then
        return instructorPed
    end

    local model = GetHashKey('s_m_m_autopsy_01')
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(50)
    end

    instructorPed = CreatePed(4, model, DrivingSchool.school.pedCoords.x + 1.5, DrivingSchool.school.pedCoords.y + 0.8, DrivingSchool.school.pedCoords.z, DrivingSchool.school.pedHeading, false, true)
    SetEntityAsMissionEntity(instructorPed, true, true)
    FreezeEntityPosition(instructorPed, true)
    SetEntityInvincible(instructorPed, true)
    SetPedDefaultComponentVariation(instructorPed)
    return instructorPed
end

local function spawnInstructorVehicle(category)
    local modelHash = GetHashKey(DrivingSchool.licenses[category].vehicle)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(50)
    end

    instructorVehicle = CreateVehicle(modelHash, DrivingSchool.school.coords.x + 6.0, DrivingSchool.school.coords.y + 3.0, DrivingSchool.school.coords.z, 0.0, true, false)
    SetVehicleOnGroundProperly(instructorVehicle)
    SetVehicleEngineOn(instructorVehicle, true, true, false)
    SetVehicleNumberPlateText(instructorVehicle, 'INSTR' .. category)
    return instructorVehicle
end

local function seatInstructor(category)
    if not instructorPed then
        createInstructorPed(category)
    end

    if not instructorVehicle then
        spawnInstructorVehicle(category)
    end

    local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if playerVehicle and playerVehicle ~= 0 then
        SetPedIntoVehicle(instructorPed, playerVehicle, -1)
        SetPedKeepTask(instructorPed, true)
    else
        TaskWarpPedIntoVehicle(instructorPed, instructorVehicle, -1)
    end
end

local function startInstructorDialogue(category)
    currentCategory = category
    currentMessageIndex = 1
    seatInstructor(category)
    speakInstruction('Instruktor: Ahoj, já jsem tvůj instruktor. Já tě budu navigovat v češtině, žádné další řeči.')
    speakInstruction('Instruktor: Teď nastartuj a rozjeď se podle červeného blipu na mapě.')
    speakInstruction('Instruktor: Pokud něco posereš, tak budu tvrdý. Nechci slyšet žádné výmluvy.')
end

RegisterNetEvent('esx_drivingschool:instructorRide')
AddEventHandler('esx_drivingschool:instructorRide', function(category)
    startInstructorDialogue(category)
end)

CreateThread(function()
    while true do
        Wait(1500)
        if currentCategory then
            local messages = DrivingSchool.licenses[currentCategory].instructions
            if currentMessageIndex <= #messages then
                speakInstruction('Instruktor: ' .. messages[currentMessageIndex])
                currentMessageIndex = currentMessageIndex + 1
            else
                speakInstruction('Instruktor: Dobrý, pokračuj. Drž se kurzu, ne přetěžuj.')
                currentMessageIndex = 1
            end
        end
    end
end)

RegisterNetEvent('esx_drivingschool:failRide')
AddEventHandler('esx_drivingschool:failRide', function(type)
    if type == 'speed' then
        speakInstruction('Instruktor: Ty vole, přetáhl jsi rychlost! Tohle je neřízená jízda!')
        speakInstruction('Instruktor: Vrať se na start. Tohle je špatně, a teď nepleť další kraviny!')
    elseif type == 'route' then
        speakInstruction('Instruktor: To je na hovno, sjezd z trasy! Vracíš se zpět a zkusíš to znovu!')
    end
end)
