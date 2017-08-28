-- ... eueu ok
fuel = 0.5
-- ...

function round(num, numDecimalPlaces)
  local mult = 5^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

RegisterServerEvent('frfuel:fuelAdded')
AddEventHandler('frfuel:fuelAdded', function(amount)

local cost = round(fuel * amount)

TriggerEvent('es:getPlayerFromId', source, function(user)
local curplayer = user.identifier
local wallet = user.money
local new_wallet = wallet - cost
--TriggerClientEvent('chatMessage', source, "SYSTEM", {255,0,0}, "DEBUG: " .. wallet .. " - " .. cost .. " = " .. new_wallet .. " :DEBUG")

    TriggerEvent("es:setPlayerDataId", curplayer, "money", new_wallet, function(response, success)
        user:removeMoney(cost)
        TriggerClientEvent('es:activateMoney', source, new_wallet)
            if(success)then
				TriggerClientEvent("es_freeroam:notify", source, "CHAR_JOSEF", 0.5, "Station essence", false, "Le prix de l'essence est de ~y~" .. fuel.."~s~$\nVotre plein est de ~y~" .. round(amount) .. "~s~ litres d'essence\nLe plein vous a couté ~r~" .. round(cost).."~s~$")
                --if (new_wallet <= 0)then
                --    TriggerClientEvent('chatMessage', -1, "911", {255, 0, 0}, GetPlayerName(source) .." n'a pas payé sont plein d'essence , il est recherché par la police")
                --    SetPlayerWantedLevel(source,  1,  false)
                --end
            end
        end)
    end)
end)