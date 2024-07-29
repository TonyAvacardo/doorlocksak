local QBCore = exports['qb-core']:GetCoreObject() -- Get QBCore object
local currentCode = nil

-- Use values from config.lua
local webhookURL = Config.WebhookURL
local doorCoords = Config.DoorCoords
local adminJob = Config.AdminJob

-- Function to generate a 4-digit code based on the current date
local function generateDailyCode()
    local date = os.date("*t")
    math.randomseed(date.year * 1000 + date.yday) -- Seed random with year and day of the year
    currentCode = string.format("%04d", math.random(0, 9999))
    print("Today's code is: " .. currentCode) -- For debugging purposes

    -- Send the code to the Discord webhook
    sendCodeToDiscord(currentCode)
end

-- Function to generate a new 4-digit code manually
local function generateNewCode()
    math.randomseed(os.time()) -- Seed random with current time
    currentCode = string.format("%04d", math.random(0, 9999))
    print("New manual code is: " .. currentCode) -- For debugging purposes

    -- Send the code to the Discord webhook
    sendCodeToDiscord(currentCode)
end

-- Function to send the code to a Discord webhook
local function sendCodeToDiscord(code)
    local message = {
        username = "FiveM Door Lock System",
        embeds = {{
            title = "Daily Door Code",
            description = "Today's code is: **" .. code .. "**",
            color = 3447003 -- Blue color
        }}
    }
    
    PerformHttpRequest(webhookURL, function(err, text, headers) 
        if err ~= 200 then
            print("Failed to send code to Discord: " .. err)
        end
    end, 'POST', json.encode(message), { ['Content-Type'] = 'application/json' })
end

-- Generate the code when the server starts
generateDailyCode()

-- Regenerate the code every day at midnight
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000 * 60 * 60 * 24) -- Wait 24 hours
        generateDailyCode()
    end
end)

-- Event to get the current code
RegisterNetEvent('doorlock:getCode')
AddEventHandler('doorlock:getCode', function()
    local src = source
    TriggerClientEvent('doorlock:returnCode', src, currentCode)
end)

-- Command to manually generate a new code
QBCore.Commands.Add('gennewcode', 'Generate a new door code', {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if src == 0 or Player.PlayerData.job.name == adminJob then
        -- Allow console and players with specified job to run this command
        generateNewCode()
        if src ~= 0 then
            TriggerClientEvent('chat:addMessage', src, { args = { '^1SYSTEM', 'A new code has been generated and sent to Discord.' } })
        end
    else
        TriggerClientEvent('chat:addMessage', src, { args = { '^1SYSTEM', 'You do not have permission to use this command.' } })
    end
end)
