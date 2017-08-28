--=============================================================================
-- #Author: Jonathan D @ Gannon
--=============================================================================

--=============================================================================
--  Config
--=============================================================================

Weeds = {}

DecorRegister('illegal_lastBuyWeed', 3)

Weeds.recoltes = {
    { pos = {x = 2215.85, y = 5575.36, z = 53.69}, time = 0},
    { pos = {x = 2216.24, y = 5577.55, z = 53.78}, time = 0},
    { pos = {x = 2218.19, y = 5575.20, z = 53.70}, time = 0},
    { pos = {x = 2221.00, y = 5575.00, z = 53.71}, time = 0},
    { pos = {x = 2222.70, y = 5574.80, z = 53.73}, time = 0},
    { pos = {x = 2227.30, y = 5574.60, z = 53.79}, time = 0},
    { pos = {x = 2230.70, y = 5574.40, z = 53.90}, time = 0},
    { pos = {x = 2232.43, y = 5576.30, z = 53.97}, time = 0},
    { pos = {x = 2230.22, y = 5576.55, z = 53.93}, time = 0},
    { pos = {x = 2227.74, y = 5576.66, z = 53.86}, time = 0},
    { pos = {x = 2225.44, y = 5576.90, z = 53.85}, time = 0},
    { pos = {x = 2223.05, y = 5577.12, z = 53.83}, time = 0},
    { pos = {x = 2220.60, y = 5577.06, z = 53.83}, time = 0},
    { pos = {x = 2218.60, y = 5577.26, z = 53.85}, time = 0},
    { pos = {x = 2219.00, y = 5579.42, z = 53.89}, time = 0},
    { pos = {x = 2223.80, y = 5579.30, z = 53.91}, time = 0},
    { pos = {x = 2225.40, y = 5578.94, z = 53.88}, time = 0},
    { pos = {x = 2230.15, y = 5579.00, z = 53.97}, time = 0},
    { pos = {x = 2233.90, y = 5578.70, z = 54.11}, time = 0}

}
Weeds.tranformCoord = {x = 2329.3796, y = 2569.5812988, z = 46.6780548}
Weeds.tranformRayon = 5.0
Weeds.tranformTime = 4000
Weeds.FullVenteCoord = { x = -97.665946, y = 988.6041, z = 235.756820}
Weeds.VenteUnityCenter = {x = -1325.44, y= -646.0019, z = 25.960}
Weeds.VenteUnityRayon = 270.0
Weeds.passNbTry = 0
Weeds.inRayon = false

Weeds.Text = {
    NoPlant = '~o~Aucune plante',
    RecolteKo = '~o~La pousse n\'est pas encore à maturité',
    RecoltePremature = '~b~Récolte prématurée possible',
    RecolteOk = '~g~Prête à être récoltée',
    ActionRecolte = '~INPUT_PICKUP~ Récolter',
    ActionPanter = '~INPUT_PICKUP~ Planter une graine',
    ActionInteraction = '~INPUT_PICKUP~ Interagir',
    TransformEncours = '~b~Transformation du cannabis en cours',
    TransformOk = '+1 ~o~Joint',
    NoPassword = '...',
    PasswordKo = '~r~Ce n\'est pas le bon mot de passe, Dégage !',
    PasswordOld  = '~b~C\'est l\'ancien mot de passe çà ...',
    PasswordCorrect = '~g~Je t\'achete tout pour un total de ~r~',
    GoodPlaceToSell = '~o~Ca semble être un bon emplacement pour vendre des joints, trouve des clients',
    PasswordSend = "Va voir dans les villas des riches, ils achetent en masse.\n~o~Mot de passe: ~r~",
    Buy2 = '~g~Je te prends deux ~b~joints~w~ pour ~o~',
    Buy1 = '~b~Je te prends un ~b~joint~w~ pour ~o~',
    Buy0 = '~o~Garde ta merde, j\'en veux pas',
    DejaPropo = '~d~Encore ?, Va voir ailleurs, j\'ai deja ce qu\'il me faut~',
    RecolteEncours = '~b~Recolte en cours',
    PlantationEncours = '~b~Plantation en cours',
}


local myPed
local myPos

Weeds.recolte = function(id)
    TriggerServerEvent('illegal:recoltWeed', id)
end


Weeds.planteSeed = function(id)
    TriggerServerEvent('illegal:PlanteSeed', id)
    --showMessageInformation(Weeds.Text.PlantationEncours, 10000)
    GcUtils.showProgressBarTimer(10000, Weeds.Text.PlantationEncours)
    PlayEmote('WORLD_HUMAN_GARDENER_PLANT', 4000)
    Citizen.Wait(10000)
end

Weeds.systemGrowth = function (id, seed, pos)
    if seed.time == 0 then
        --showMessageInformation(Weeds.Text.NoPlant)
        --GcUtils.showProgressBar(0, '~o~' .. Weeds.Text.NoPlant, 100)
        GcUtils.DrawTextIn3DWorld(pos.x, pos.y, pos.z, '~o~' .. Weeds.Text.NoPlant)
        showActionInfo(Weeds.Text.ActionPanter)
        if IsControlJustPressed(1, 38) then
            Weeds.planteSeed(id)
        end
    else
        local d = math.floor((getTime()-seed.time) / WeedGrowthTime * 10000) / 100
        if d < 50 then
            --GcUtils.showProgressBar(d/100, Weeds.Text.RecolteKo .. ' ~o~ (' .. d .. '%)', 100)
            GcUtils.DrawTextIn3DWorld(pos.x, pos.y, pos.z, Weeds.Text.RecolteKo .. ' ~o~ (' .. d .. '%)')
        else
            if d >= 100 then
                --GcUtils.showProgressBar(1, Weeds.Text.RecolteOk .. '~o~ (7)', 100)
                GcUtils.DrawTextIn3DWorld(pos.x, pos.y, pos.z,  Weeds.Text.RecolteOk .. '~o~ (7)')
            elseif d >= 90 then
                --GcUtils.showProgressBar(d/100, Weeds.Text.RecoltePremature .. '~o~ (4-5) ~w~ [' .. d .. '%]', 100)
                GcUtils.DrawTextIn3DWorld(pos.x, pos.y, pos.z, Weeds.Text.RecoltePremature .. '~o~ (4-5) ~b~ [' .. d .. '%]')
            elseif d >= 80 then
                --GcUtils.showProgressBar(d/100, Weeds.Text.RecoltePremature .. '~o~ (3-4) ~w~ [' .. d .. '%]', 100)
                GcUtils.DrawTextIn3DWorld(pos.x, pos.y, pos.z, Weeds.Text.RecoltePremature .. '~o~ (3-4) ~b~ [' .. d .. '%]')
            elseif d >= 70 then
                --GcUtils.showProgressBar(d/100, Weeds.Text.RecoltePremature .. '~o~ (2-3) ~w~ [' .. d .. '%]', 100)
                GcUtils.DrawTextIn3DWorld(pos.x, pos.y, pos.z, Weeds.Text.RecoltePremature .. '~o~ (2-3) ~b~ [' .. d .. '%]')
            elseif d >= 60 then
                --GcUtils.showProgressBar(d/100, Weeds.Text.RecoltePremature .. '~o~ (1-3) ~w~ [' .. d .. '%]', 100)
                GcUtils.DrawTextIn3DWorld(pos.x, pos.y, pos.z, Weeds.Text.RecoltePremature .. '~o~ (1-3) ~b~ [' .. d .. '%]')
            elseif d >= 50 then
                --GcUtils.showProgressBar(d/100, Weeds.Text.RecoltePremature .. '~o~ (1-2) ~w~ [' .. d .. '%]', 100)
                GcUtils.DrawTextIn3DWorld(pos.x, pos.y, pos.z, Weeds.Text.RecoltePremature .. '~o~ (1-2) ~b~ [' .. d .. '%]')
            end
            showActionInfo(Weeds.Text.ActionRecolte)
            if IsControlJustPressed(1, 38) then
                Weeds.recolte(id)
            end
        end
    end
end

Weeds.checkRecoltes = function ()
    local myPed = GetPlayerPed(-1)
    local myPos = GetEntityCoords(myPed)
    for id, seed in pairs(Weeds.recoltes) do 
        local dist = GetDistanceBetweenCoords(myPos.x, myPos.y, myPos.z, seed.pos.x, seed.pos.y, seed.pos.z, false)
        if dist < 0.7 then
            Weeds.systemGrowth(id,seed, seed.pos)
            break
        end
    end

end

Weeds.checkTranform = function ()
    local dist = GetDistanceBetweenCoords(myPos.x, myPos.y, myPos.z, Weeds.tranformCoord.x, Weeds.tranformCoord.y, Weeds.tranformCoord.z, false)
        
    if dist <= Weeds.tranformRayon then
        --Citizen.Trace('tranform' .. dist)
        if exports.vdk_inventory:getQuantity(WeedItemId) > 0 then
            --showMessageInformation(Weeds.Text.TransformEncours,Weeds.tranformTime)
           --Citizen.Wait(Weeds.tranformTime  - 800)
            --showMessageInformation(Weeds.Text.TransformOk)
            --Citizen.Wait(800)
            GcUtils.showProgressBarTimer(Weeds.tranformTime, Weeds.Text.TransformEncours, Weeds.Text.TransformOk)
            Citizen.Wait(Weeds.tranformTime + 2000)
            TriggerEvent("player:looseItem", WeedItemId, 1)
            TriggerEvent("player:receiveItem", JoinItemId, 1)
        end
    end
end

Weeds.tryFullVente = function ()
    local pw = openTextInput('', 'Mot de passe', 22)
    --Citizen.Trace('pw ' .. pw )
    if pw == nil or pw == '' or pw == 'Mot de passe' then
        showActionInfo(Weeds.Text.NoPassword)
    else
        local qte = exports.vdk_inventory:getQuantity(JoinItemId)
        TriggerServerEvent('illegal:weedTryPassowrd', pw, qte)
    end
end

Weeds.checkVente = function()
    local totalItem = exports.vdk_inventory:getQuantity(JoinItemId)
    if totalItem == 0 then
        return
    end
    local dist = GetDistanceBetweenCoords(myPos.x, myPos.y, myPos.z,Weeds.FullVenteCoord.x, Weeds.FullVenteCoord.y, Weeds.FullVenteCoord.z, true)
    local dist2 = GetDistanceBetweenCoords(myPos.x, myPos.y, myPos.z,Weeds.VenteUnityCenter.x, Weeds.VenteUnityCenter.y, Weeds.VenteUnityCenter.z, false)
    if dist <= 2.0 then
        showActionInfo(Weeds.Text.ActionInteraction)
        if IsControlJustPressed(1, 38) then
            Weeds.tryFullVente()
        end
    elseif dist2 <= Weeds.VenteUnityRayon then
        if Weeds.inRayon == false then
            showMessageInformation(Weeds.Text.GoodPlaceToSell, 8000)
            Weeds.inRayon = true 
        end
        if IsControlJustPressed(1, 38) then 
            --local ped = 0
            --Citizen.InvokeNative(0xC33AB876A77F8164, myPos.x, myPos.y, myPos.z, 5.0, 1,0, Citizen.PointerValueInt(ped),1,0, -1)
            --local ped = GetRandomPedAtCoord(myPos.x, myPos.y, myPos.z, 1.0, 1.0, 1.0, 26, _r)
            local ped = GetRandomPedAtCoord(myPos.x, myPos.y, myPos.z, 3.0, 3.0, 3.0, 26)
           -- local ped = GetRandomPedAtCoord(myPos.x, myPos.y, myPos.z, 3.0, 3.0, 3.0, -1)
            if ped ~= 0 then
                local lastBuy = DecorGetInt(ped, 'illegal_lastBuyWeed')
                if lastBuy == 0 or lastBuy + PNJ_TIME_SELL < getTime() then
                    local r = math.random() 
                    if r > 0.995 then -- 0.995
                       TriggerServerEvent('illegal:needPassword')
                    elseif r > 0.85 and totalItem > 2 then
                        local total = math.random(JoinVenteUnite[1], JoinVenteUnite[2])
                        TriggerEvent("player:sellItemSale", JoinItemId, total)
                        TriggerEvent("player:sellItemSale", JoinItemId, total)
                        showMessageInformation(Weeds.Text.Buy2 .. total*2 .. '$',3000)
                    elseif r > 0.55 then
                        local total = math.random(JoinVenteUnite[1], JoinVenteUnite[2])
                        showMessageInformation(Weeds.Text.Buy1 .. total .. '$', 3000)
                        TriggerEvent("player:sellItemSale", JoinItemId, total)
                    else
                        showMessageInformation(Weeds.Text.Buy0,3000)
                    end
                    DecorSetInt(ped, 'illegal_lastBuyWeed', getTime())
                    SetPedIsDrunk(ped,true)
                else
                    showMessageInformation(Weeds.Text.DejaPropo,3000)
                end
            -- else
            --     showMessageInformation("DEBUG notfound")
            end
        end
    else
        Weeds.inRayon = false
    end
end



Weeds.drawDebug = function ()
    for _, k in pairs(Weeds.recoltes) do 
        ShowVerticalLineAtPos(k.pos) 
    end
end

Weeds.start = function ()
    TriggerServerEvent('illegal:requestFullPlantData')
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            myPed = GetPlayerPed(-1)
            myPos = GetEntityCoords(myPed)
            Weeds.checkRecoltes()
            Weeds.checkTranform()
            Weeds.checkVente()
        end
    end)
end




--=============================================================================
--  Event
--=============================================================================
RegisterNetEvent('illegal:setFullPlantData')
AddEventHandler('illegal:setFullPlantData',function(data)
    for i, t in pairs(data) do
        Weeds.recoltes[i].time = t
    end
end)

RegisterNetEvent('illegal:seedChange')
AddEventHandler('illegal:seedChange',function(id, time)
    Weeds.recoltes[id].time = time
end)

RegisterNetEvent('illegal:recoltWeed')
AddEventHandler('illegal:recoltWeed',function(qte)
    TriggerEvent('player:receiveItem',WeedItemId, qte) 
   
    GcUtils.showProgressBarTimer(24000, Weeds.Text.RecolteEncours, '+ ' .. qte .. ' ~o~Cannabis')
    --showMessageInformation(Weeds.Text.RecolteEncours, 20000)
    PlayEmote('WORLD_HUMAN_GARDENER_PLANT', 20000)
    Citizen.Wait(20000 + 6000)

end)

RegisterNetEvent('illegal:fullVente')
AddEventHandler('illegal:fullVente', function( sta, qte)
    if sta == 0 then
        showMessageInformation(Weeds.Text.PasswordOld,8000)
    elseif sta == 1 then
        local total = qte * JoinVenteFull
        showMessageInformation(Weeds.Text.PasswordCorrect .. total .. '$', 8000)
        TriggerEvent("player:looseItem", JoinItemId, qte)
    else
        showMessageInformation(Weeds.Text.PasswordKo, 8000)
        Weeds.passNbTry = Weeds.passNbTry + 1 
    end
end)


RegisterNetEvent('illegal:password')
AddEventHandler('illegal:password', function(password, exptime)
	if tonumber(exptime) < 60 then
		timeresult = tostring(exptime) 
		unite = " sec"
	elseif exptime < 120 then
		timeresult = exptime / 60
		unite = " minute"
	else
		timeresult = exptime / 60
		unite = " minutes"
	end
    showMessageInformation(Weeds.Text.PasswordSend .. password .. "~w~ Expiration dans ~r~" .. math.floor(timeresult) .. unite, 30000)
    Citizen.Wait(15000)
end)


--=============================================================================
--  Initialisation
--=============================================================================



--=============================================================================
--  DEBUG
--=============================================================================
-- TriggerEvent("player:receiveItem", JoinItemId, 9)
-- TriggerEvent("player:receiveItem", WeedItemId, 2)
-- -- Citizen.Trace('Time: ' .. GcUtils.getTime())
-- SetEntityCoords(GetPlayerPed(-1),-1136.65,  -1466.16, 7.69071)

