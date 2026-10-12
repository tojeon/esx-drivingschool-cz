ESX = exports['es_extended']:getSharedObject()

local function notify(source, msg)
    TriggerClientEvent('esx:showNotification', source, msg)
end

MySQL.ready(function()
    MySQL.Async.execute([
        [[
            CREATE TABLE IF NOT EXISTS `driving_school_licenses` (
                `identifier` varchar(50) NOT NULL,
                `category` varchar(10) NOT NULL,
                `has_license` tinyint(1) NOT NULL DEFAULT 0,
                `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (`identifier`, `category`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]],
        []
    )

    MySQL.Async.execute([
        [[
            CREATE TABLE IF NOT EXISTS `driving_school_questions` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `category` varchar(10) NOT NULL,
                `question` text NOT NULL,
                `answer_1` text NOT NULL,
                `answer_2` text NOT NULL,
                `answer_3` text NOT NULL,
                `answer_4` text NOT NULL,
                `correct_answer` tinyint(1) NOT NULL,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]],
        []
    )

    local inserted = false
    if not inserted then
        MySQL.Async.fetchScalar('SELECT COUNT(*) FROM driving_school_questions', {}, function(count)
            if tonumber(count) == 0 then
                local questions = {}
                for category, list in pairs(DrivingSchool.questions) do
                    for _, item in ipairs(list) do
                        table.insert(questions, {
                            category = category,
                            question = item.question,
                            answer_1 = item.answers[1],
                            answer_2 = item.answers[2],
                            answer_3 = item.answers[3],
                            answer_4 = item.answers[4],
                            correct_answer = item.correct,
                        })
                    end
                end

                for _, q in ipairs(questions) do
                    MySQL.Async.execute('INSERT INTO driving_school_questions (category, question, answer_1, answer_2, answer_3, answer_4, correct_answer) VALUES (@category, @question, @answer_1, @answer_2, @answer_3, @answer_4, @correct_answer)', {
                        ['@category'] = q.category,
                        ['@question'] = q.question,
                        ['@answer_1'] = q.answer_1,
                        ['@answer_2'] = q.answer_2,
                        ['@answer_3'] = q.answer_3,
                        ['@answer_4'] = q.answer_4,
                        ['@correct_answer'] = q.correct_answer,
                    })
                end
            end
        end)
    end
end)

local function getPlayerLicenses(identifier)
    local licenses = {}
    MySQL.Async.fetchAll('SELECT category, has_license FROM driving_school_licenses WHERE identifier = @identifier', {
        ['@identifier'] = identifier,
    }, function(result)
        for _, row in ipairs(result or {}) do
            licenses[row.category] = row.has_license == 1
        end
    end)
    return licenses
end

RegisterNetEvent('esx_drivingschool:purchaseLicense')
AddEventHandler('esx_drivingschool:purchaseLicense', function(category)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local cfg = DrivingSchool.licenses[category]
    if not cfg then
        notify(source, 'Neplatná kategorie licence.')
        return
    end

    if xPlayer.getMoney() < cfg.price then
        notify(source, 'Nemáš dostatek peněz na licenci ' .. cfg.label .. '.')
        return
    end

    xPlayer.removeMoney(cfg.price)

    MySQL.Async.execute('INSERT INTO driving_school_licenses (identifier, category, has_license) VALUES (@identifier, @category, 1) ON DUPLICATE KEY UPDATE has_license = 1', {
        ['@identifier'] = xPlayer.identifier,
        ['@category'] = category,
    }, function()
        TriggerClientEvent('esx_drivingschool:licenseOwned', source, category, true)
        notify(source, 'Koupil jsi licenci ' .. cfg.label .. ' za ' .. cfg.price .. ' $.')
    end)
end)

ESX.RegisterServerCallback('esx_drivingschool:getLicenseState', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then cb({}) return end

    local licenses = {}
    MySQL.Async.fetchAll('SELECT category, has_license FROM driving_school_licenses WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier,
    }, function(result)
        for _, row in ipairs(result or {}) do
            licenses[row.category] = row.has_license == 1
        end
        cb(licenses)
    end)
end)

ESX.RegisterServerCallback('esx_drivingschool:getQuestions', function(source, cb, category)
    MySQL.Async.fetchAll('SELECT * FROM driving_school_questions WHERE category = @category ORDER BY id', {
        ['@category'] = category,
    }, function(result)
        cb(result or {})
    end)
end)

RegisterNetEvent('esx_drivingschool:submitTheoryExam')
AddEventHandler('esx_drivingschool:submitTheoryExam', function(category, answers)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local result = { correct = 0, total = 0 }
    MySQL.Async.fetchAll('SELECT * FROM driving_school_questions WHERE category = @category ORDER BY id', {
        ['@category'] = category,
    }, function(rows)
        for i, row in ipairs(rows) do
            result.total = result.total + 1
            if tonumber(answers[i]) == tonumber(row.correct_answer) then
                result.correct = result.correct + 1
            end
        end

        local pass = result.correct >= 12
        if pass then
            TriggerClientEvent('esx_drivingschool:theoryResult', source, true, 'Teoretická zkouška úspěšně složena!')
            notify(source, 'Teoretická zkouška byla úspěšně složena!')
        else
            TriggerClientEvent('esx_drivingschool:theoryResult', source, false, 'Teoretická zkouška neprošla. Zkus to znovu.')
            notify(source, 'Teoretická zkouška neprošla. Zkus to znovu.')
        end
    end)
end)

RegisterNetEvent('esx_drivingschool:finishDrivingTest')
AddEventHandler('esx_drivingschool:finishDrivingTest', function(category, success)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if success then
        MySQL.Async.execute('INSERT INTO driving_school_licenses (identifier, category, has_license) VALUES (@identifier, @category, 1) ON DUPLICATE KEY UPDATE has_license = 1', {
            ['@identifier'] = xPlayer.identifier,
            ['@category'] = category,
        }, function()
            TriggerClientEvent('esx_drivingschool:drivingResult', source, true, 'Praktická zkouška splněna!')
            notify(source, 'Praktická zkouška splněna!')
        end)
    else
        TriggerClientEvent('esx_drivingschool:drivingResult', source, false, 'Praktická zkouška neprošla. Instruktor tě opraví.')
        notify(source, 'Praktická zkouška neprošla. Instruktor tě opraví.')
    end
end)
