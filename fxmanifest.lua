fx_version 'cerulean'
game 'gta5'

author 'YourName'
description 'Door lock system with QBCore and Discord webhook integration'
version '1.0.0'

shared_script '@qb-core/shared/locale.lua' -- Include QBCore locale
shared_script 'config.lua' -- Include the config file

client_script 'client.lua'
server_script 'server.lua'
server_script 'json.lua' -- Include JSON library for server-side
