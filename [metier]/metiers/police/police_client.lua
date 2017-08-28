isCop = false
isCopInService = false
local rank = "inconnu"
local checkpoints = {}
local existingVeh = nil
local handCuffed = false
local isAlreadyDead = false
local allServiceCops = {}
local blipsCops = {}
Citizen.Trace('poloci')

local function sendnotif(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(0,1)	
end

local takingService = {
  --{x=850.156677246094, y=-1283.92004394531, z=28.0047378540039},
  {x=457.956909179688, y=-992.72314453125, z=30.6895866394043},
  {x=1856.91320800781, y=3689.50073242188, z=34.2670783996582},
  {x=-449.594482421875, y=6016.66845703125, z=31.7163963317871},
  {x=142.513473510742, y=-769.184692382813, z=45.7520217895508},
}

local stationGarage = {
	{x=452.115966796875, y=-1018.10681152344, z=28.4786586761475},
	{x=120.482795715332, y=-724.002380371094, z=42.0255546569824},	
}

AddEventHandler("playerSpawned", function()
	TriggerServerEvent("police:checkIsCop")
	GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("GADGET_PARACHUTE"), 150, true, true)
end)

RegisterNetEvent('police:receiveIsCop')
AddEventHandler('police:receiveIsCop', function(result)
	Citizen.Trace('isCopisCopisCopisCopisCopisCopisCop')
	if(result == "inconnu") then
		isCop = false
	else
		isCop = true
		rank = result
	end
end)

RegisterNetEvent('police:nowCop')
AddEventHandler('police:nowCop', function()
	isCop = true
end)

RegisterNetEvent('police:noLongerCop')
AddEventHandler('police:noLongerCop', function()
	isCop = true
	isCopInService = true
	
	local playerPed = GetPlayerPed(-1)
						
	TriggerServerEvent("skin_customization:SpawnPlayer")
	SetPedComponentVariation(GetPlayerPed(-1), 9, 0, 1, 2)
	SetPedComponentVariation(GetPlayerPed(-1), 10, 0, 0, 2)
	RemoveAllPedWeapons(playerPed)
	Citizen.Wait(2000)
	TriggerServerEvent('weaponshop:GiveWeaponsToPlayer')
	
	if(existingVeh ~= nil) then
		SetEntityAsMissionEntity(existingVeh, true, true)
		Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(existingVeh))
		existingVeh = nil
	end
	
	ServiceOff()
end)

RegisterNetEvent('police:getArrested')
AddEventHandler('police:getArrested', function()
	if(isCop == false) then
		handCuffed = not handCuffed
		if(handCuffed) then
			TriggerEvent('chatMessage', 'SYSTEM', {255, 0, 0}, "vous êtes menoté")
		else
			TriggerEvent('chatMessage', 'SYSTEM', {255, 0, 0}, "LIBRE !")
		end
	end
end)

-- RegisterNetEvent('police:payFines')
-- AddEventHandler('police:payFines', function(amount, reason)
	-- --TriggerServerEvent('bank:withdrawAmende', amount)
	-- TriggerEvent('chatMessage', 'SYSTEM', {255, 0, 0}, "You paid a $"..amount.." fine for" .. reason )
-- end)

RegisterNetEvent('police:dropIllegalItem')
AddEventHandler('police:dropIllegalItem', function(id,qty)
	TriggerEvent("player:looseItem", tonumber(id),tonumber(qty))
	TriggerEvent('chatMessage', 'SYSTEM', {255, 0, 0}, "La Police vous a fouillé")
end)

RegisterNetEvent('police:unseatme')
AddEventHandler('police:unseatme', function(t)
	local ped = GetPlayerPed(t)        
	ClearPedTasksImmediately(ped)
	plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
	local xnew = plyPos.x+2
	local ynew = plyPos.y+2
   
	SetEntityCoords(GetPlayerPed(-1), xnew, ynew, plyPos.z)
end)

RegisterNetEvent('police:forcedEnteringVeh')
AddEventHandler('police:forcedEnteringVeh', function(veh)
	if(handCuffed) then
		local pos = GetEntityCoords(GetPlayerPed(-1))
		local entityWorld = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 20.0, 0.0)

		local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, GetPlayerPed(-1), 0)
		local a, b, c, d, vehicleHandle = GetRaycastResult(rayHandle)

		if vehicleHandle ~= nil then
			SetPedIntoVehicle(GetPlayerPed(-1), vehicleHandle, 1)
		end
	end
end)

RegisterNetEvent('police:resultAllCopsInService')
AddEventHandler('police:resultAllCopsInService', function(array)
	allServiceCops = array
	enableCopBlips()
end)

function POLICE_removeOrPlaceCone()
  local mePed = GetPlayerPed(-1)
  local pos = GetOffsetFromEntityInWorldCoords(mePed, 0.0, 0.2, 0.0)
  local cone = GetClosestObjectOfType( pos.x, pos.y, pos.z, 1.0, GetHashKey("prop_roadcone02a"), false, false, false)
  if cone ~= 0 then
    -- ... /!\
    NetworkRequestControlOfEntity(cone)
    Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(cone))
    Citizen.InvokeNative(0x539E0AE3E6634B9F, Citizen.PointerValueIntInitialized(cone))
    DeleteObject(cone)
    SetEntityCoords(cone, -2000.0, -2000.0, -2000.0)
  else
    local h = GetEntityHeading(mePed)
    local object = CreateObject("prop_roadcone02a", pos.x, pos.y, pos.z, GetEntityHeading(mePed), true, false)
	local id = NetworkGetNetworkIdFromEntity(object) 
	SetNetworkIdCanMigrate(id, true)
    PlaceObjectOnGroundProperly(object)
	SetEntityDynamic(object , true)
	SetEntityInvincible(object , false)
	SetEntityCanBeDamaged(object , true)
	SetEntityHealth(object , 1000)
	SetEntityHasGravity(object , true)
	SetEntityAsMissionEntity(object, true, true)
	SetEntityLoadCollisionFlag(object , true)
	SetEntityRecordsCollisions(object , true)
  end
end

function POLICE_removeOrPlaceBarrier()
  local mePed = GetPlayerPed(-1)
  local pos = GetOffsetFromEntityInWorldCoords(mePed, 0.0, 0.2, 0.0)
  local barriere = GetClosestObjectOfType( pos.x, pos.y, pos.z, 1.0, GetHashKey("prop_barrier_work05"), false, false, false)
  if barriere ~= 0 then
    -- ... /!\
    NetworkRequestControlOfEntity(barriere)
    Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(barriere))
    Citizen.InvokeNative(0x539E0AE3E6634B9F, Citizen.PointerValueIntInitialized(barriere))
    DeleteObject(barriere)
    SetEntityCoords(barriere, -2000.0, -2000.0, -2000.0)
  else
    local h = GetEntityHeading(mePed)
    local object = CreateObject("prop_barrier_work05", pos.x, pos.y, pos.z, GetEntityHeading(mePed), true, false)
	local id = NetworkGetNetworkIdFromEntity(object) 
	SetNetworkIdCanMigrate(id, true)
    PlaceObjectOnGroundProperly(object)
	SetEntityDynamic(object , true)
	SetEntityInvincible(object , false)
	SetEntityCanBeDamaged(object , true)
	SetEntityHealth(object , 1000)
	SetEntityHasGravity(object , true)
	SetEntityAsMissionEntity(object, true, true)
	SetEntityLoadCollisionFlag(object , true)
	SetEntityRecordsCollisions(object , true)
  end
end

function POLICE_removeOrPlaceHerse()
  local mePed = GetPlayerPed(-1)
  local pos = GetOffsetFromEntityInWorldCoords(mePed, 0.0, 0.2, 0.0)
  local herse = GetClosestObjectOfType( pos.x, pos.y, pos.z, 1.0, GetHashKey("p_ld_stinger_s"), false, false, false)
  if herse ~= 0 then
    -- ... /!\
    NetworkRequestControlOfEntity(herse)
    Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(herse))
    Citizen.InvokeNative(0x539E0AE3E6634B9F, Citizen.PointerValueIntInitialized(herse))
    DeleteObject(herse)
    SetEntityCoords(herse, -2000.0, -2000.0, -2000.0)
  else
    local h = GetEntityHeading(mePed)
	local object = CreateObject("p_ld_stinger_s", pos.x, pos.y, pos.z, GetEntityHeading(mePed)   -90.0 , true, false)
	local id = NetworkGetNetworkIdFromEntity(object) 
	SetNetworkIdCanMigrate(id, true)
    PlaceObjectOnGroundProperly(object)
	SetEntityDynamic(object , true)
	SetEntityInvincible(object , false)
	SetEntityCanBeDamaged(object , true)
	SetEntityHealth(object , 1000)
	SetEntityHasGravity(object , true)
	SetEntityAsMissionEntity(object, true, true)
	SetEntityLoadCollisionFlag(object , true)
	SetEntityRecordsCollisions(object , true)
  end
end

function enableCopBlips()

	for k, existingBlip in pairs(blipsCops) do
        RemoveBlip(existingBlip)
    end
	blipsCops = {}
	
	local localIdCops = {}
	for id = 0, 64 do
		if(NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= GetPlayerPed(-1)) then
			for i,c in pairs(allServiceCops) do
				if(i == GetPlayerServerId(id)) then
					localIdCops[id] = c
					break
				end
			end
		end
	end
	
	for id, c in pairs(localIdCops) do
		local ped = GetPlayerPed(id)
		local blip = GetBlipFromEntity(ped)
		
		if not DoesBlipExist( blip ) then

			blip = AddBlipForEntity( ped )
			SetBlipSprite( blip, 1 )
			Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true )
			HideNumberOnBlip( blip )
			SetBlipNameToPlayerName( blip, id )
			
			SetBlipScale( blip,  0.85 )
			SetBlipAlpha( blip, 255 )
			
			table.insert(blipsCops, blip)
		else
			
			blipSprite = GetBlipSprite( blip )
			
			HideNumberOnBlip( blip )
			if blipSprite ~= 1 then
				SetBlipSprite( blip, 1 )
				Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true )
			end
			
			Citizen.Trace("Name : "..GetPlayerName(id))
			SetBlipNameToPlayerName( blip, id )
			SetBlipScale( blip,  0.85 )
			SetBlipAlpha( blip, 255 )
			
			table.insert(blipsCops, blip)
		end
	end
end

function GetPlayers()
    local players = {}

    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end

function GetClosestPlayer()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = GetPlayerPed(-1)
	local plyCoords = GetEntityCoords(ply, 0)
	
	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = GetDistanceBetweenCoords(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
			if(closestDistance == -1 or closestDistance > distance) then
				closestPlayer = value
				closestDistance = distance
			end
		end
	end
	
	return closestPlayer, closestDistance
end

function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x , y)
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function getIsInService()
	return isCopInService
end

function isNearTakeService()
	for i = 1, #takingService do
		local ply = GetPlayerPed(-1)
		local plyCoords = GetEntityCoords(ply, 0)
		local distance = GetDistanceBetweenCoords(takingService[i].x, takingService[i].y, takingService[i].z, plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
		if(distance < 30) then
			DrawMarker(1, takingService[i].x, takingService[i].y, takingService[i].z-1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 155, 255, 200, 0, 0, 2, 0, 0, 0, 0)
		end
		if(distance < 2) then
			return true
		end
	end
end

function isNearStationGarage()
	for i = 1, #stationGarage do
		local ply = GetPlayerPed(-1)
		local plyCoords = GetEntityCoords(ply, 0)
		local distance = GetDistanceBetweenCoords(stationGarage[i].x, stationGarage[i].y, stationGarage[i].z, plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
		if(distance < 30) then
			DrawMarker(1, stationGarage[i].x, stationGarage[i].y, stationGarage[i].z-1, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 1.0, 0, 155, 255, 200, 0, 0, 2, 0, 0, 0, 0)
		end
		if(distance < 2) then
			return true
		end
	end
end

function ServiceOn()
	isCopInService = true
	--TriggerServerEvent("jobssystem:jobs", 2)
	TriggerServerEvent("police:takeService")
end

function ServiceOff()
	isCopInService = false
	--TriggerServerEvent("jobssystem:jobs", 7)
	TriggerServerEvent("police:breakService")
	allServiceCops = {}
	
	for k, existingBlip in pairs(blipsCops) do
        RemoveBlip(existingBlip)
    end
	blipsCops = {}
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if(isCop) then
			if(isNearTakeService()) then
			
				DisplayHelpText('Appuyer sur ~INPUT_CONTEXT~ pour ouvrir le vestiaire',0,1,0.5,0.8,0.6,255,255,255,255) -- ~g~E~s~
				if IsControlJustPressed(1,51) then
					--OpenMenuVest()
					MenuChoixPoliceService()
				end
			end
			-- if(isCopInService) then
				-- if IsControlJustPressed(1,166) then 
					-- OpenPoliceMenu()
				-- end
			-- end
			
			if(isCopInService) then
				if(isNearStationGarage()) then
					if(policevehicle ~= nil) then --existingVeh
						DisplayHelpText('Appuyer sur ~INPUT_CONTEXT~ pour ranger votre vehicule',0,1,0.5,0.8,0.6,255,255,255,255)
					else
						DisplayHelpText('Appuyer sur ~INPUT_CONTEXT~ pour ouvrir le garage de police',0,1,0.5,0.8,0.6,255,255,255,255)
					end
					
					if IsControlJustPressed(1,51) then
						if(policevehicle ~= nil) then
							SetEntityAsMissionEntity(policevehicle, true, true)
							Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(policevehicle))
							policevehicle = nil
						else
							--OpenVeh()
							MenuChoixPoliceVehicleCar()
							local ply = GetPlayerPed(-1)
							local plyCoords = GetEntityCoords(ply, 0)
							local distance = GetDistanceBetweenCoords(stationGarage[2].x, stationGarage[2].y, stationGarage[2].z, plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
							if(distance < 30) then
								DrawMarker(1, stationGarage[2].x, stationGarage[2].y, stationGarage[2].z-1, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 1.0, 0, 155, 255, 200, 0, 0, 2, 0, 0, 0, 0)
							end
							if(distance < 2) then
								MenuChoixSecretVehicleCar()
							end
							
						end
					end
				end
				
				
			end
		else
			if (handCuffed == true) then
			  RequestAnimDict('mp_arresting')

			  while not HasAnimDictLoaded('mp_arresting') do
				Citizen.Wait(0)
			  end

			  local myPed = PlayerPedId()
			  local animation = 'idle'
			  local flags = 16

			  TaskPlayAnim(myPed, 'mp_arresting', animation, 8.0, -8, -1, flags, 0, 0, 0, 0)
			end
		end
    end
end)
---------------------------------------------------------------------------------------
-------------------------------SPAWN HELI AND CHECK DEATH------------------------------
---------------------------------------------------------------------------------------
local alreadyDead = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if(isCop) then
			if(isCopInService) then
			
				-- if(IsPlayerDead(PlayerId())) then
					-- if(alreadyDead == false) then
						-- ServiceOff()
						-- alreadyDead = true
					-- end
				-- else
					-- alreadyDead = false
				-- end
			
				DrawMarker(1,449.113,-981.084,42.691,0,0,0,0,0,0,2.0,2.0,2.0,0,155,255,200,0,0,0,0)
			
				if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), 449.113,-981.084,43.691, true ) < 5 then
					if(existingVeh ~= nil) then
						DisplayHelpText('Appuyer sur ~INPUT_CONTEXT~ pour ranger votre helicopter',0,1,0.5,0.8,0.6,255,255,255,255)
					else
						DisplayHelpText('Appuyer sur ~INPUT_CONTEXT~ pour prendre vote helicopter',0,1,0.5,0.8,0.6,255,255,255,255)
					end
					
					if IsControlJustPressed(1,51)  then
						if(existingVeh ~= nil) then
							SetEntityAsMissionEntity(existingVeh, true, true)
							Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(existingVeh))
							existingVeh = nil
						else
							local car = GetHashKey("polmav")
							local ply = GetPlayerPed(-1)
							local plyCoords = GetEntityCoords(ply, 0)
							
							RequestModel(car)
							while not HasModelLoaded(car) do
									Citizen.Wait(0)
							end
							
							existingVeh = CreateVehicle(car, plyCoords["x"], plyCoords["y"], plyCoords["z"], 180.0, true, false)
							SetVehicleLivery(existingVeh, 0)
							local id = NetworkGetNetworkIdFromEntity(existingVeh)
							SetNetworkIdCanMigrate(id, true)
							TaskWarpPedIntoVehicle(ply, existingVeh, -1)
						end
					end
				end
			end
		end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
			if not(isCopInService) then
				local ply = GetPlayerPed(-1)
				RemoveWeaponFromPed(ply, GetHashKey("WEAPON_PUMPSHOTGUN"))
				RemoveWeaponFromPed(ply, GetHashKey("WEAPON_SNIPERRIFLE"))
				RemoveWeaponFromPed(ply, GetHashKey("WEAPON_PISTOL50"))
				RemoveWeaponFromPed(ply, GetHashKey("WEAPON_PISTOL"))
				RemoveWeaponFromPed(ply, GetHashKey("WEAPON_SMG"))
				RemoveWeaponFromPed(ply, GetHashKey("WEAPON_MICROSMG"))
				RemoveWeaponFromPed(ply, GetHashKey("WEAPON_CARBINERIFLE"))
				RemoveWeaponFromPed(ply, GetHashKey("WEAPON_SPECIALCARBINE"))
				RemoveWeaponFromPed(ply, GetHashKey("WEAPON_COMBATPISTOL"))
			end
	end
end)

Citizen.CreateThread(function()
	for i = 1, 12 do
		Citizen.InvokeNative(0xDC0F817884CDD856, i, false)
	end
end)

