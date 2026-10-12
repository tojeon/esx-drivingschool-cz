fx_version 'cerulean'
game 'gta5'

author 'tojeon'
description 'ESX Driving School v češtině s instruktorem NPC'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@es_extended/locale.lua',
    'config.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
    'client/npc.lua',
    'client/driving.lua',
}

dependencies {
    'es_extended',
    'ox_target',
    'ox_lib',
}

lua54 'yes'
