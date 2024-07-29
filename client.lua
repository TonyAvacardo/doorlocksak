-- client.lua

local doorCoords = Config.DoorCoords
local doorLocked = true
local dailyCode = nil

-- Function to draw 3D text
local function drawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextColour(255, 255, 255, 215)
    
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

-- Function to prompt the player for the code
local function promptForCode()
    AddTextEntry('FMMC_KEY_TIP1', "Enter the 4-digit code:")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 4)

    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        Citizen.Wait(0)
    end

    if GetOnscreenKeyboardResult() then
        return GetOnscreenKeyboardResult()
    end
    return nil
end

-- Request the daily code from the server
RegisterNetEvent('doorlock:returnCode')
AddEventHandler('doorlock:returnCode', function(code)
    dailyCode = code
end)
TriggerServerEvent('doorlock:getCode')

-- Main thread to handle door interactions
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - doorCoords)

        if distance < 1.5 then
            drawText3D(doorCoords.x, doorCoords.y, doorCoords.z, doorLocked and "[E] Enter Code" or "[E] Lock Door")
            
            if IsControlJustReleased(0, 38) then -- E key
                if doorLocked then
                    local inputCode = promptForCode()
                    if inputCode == dailyCode then
                        doorLocked = false
                        print("Door unlocked!") -- For debugging purposes
                    else
                        print("Incorrect code!") -- For debugging purposes
                    end
                else
                    doorLocked = true
                    print("Door locked!") -- For debugging purposes
                end
            end
        end
    end
end)
