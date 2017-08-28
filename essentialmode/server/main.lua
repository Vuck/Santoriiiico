-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --

_VERSION = '1.4.2'

-- Server
Users = {}
commands = {}
settings = {}
settings.defaultSettings = {
	['pvpEnabled'] = true, -- PLAYER VS PLAYER ?
	['permissionDenied'] = false, -- NO IMPORTANT
	['debugInformation'] = false, -- NO IMPORTANT
	['startingCash'] = 300, -- FIRST JOIN, MONEY ?
	['startingBank'] = 0, -- FIRST JOIN, MONEY IN BANK ?
	['enableRankDecorators'] = false, -- COLORS RANKS ?
	['moneyIcon'] = "$", -- ICON MONEY ? €, $, £ ...
	['nativeMoneySystem'] = false, -- USELESS (LET FALSE)
	['commandDelimeter'] = '/', -- NO IMPORTNT
	['dirtyMoneyShow'] = true, -- SHOW DIRTY MONEY ?
	['showBankBalance'] = true, -- SHOW BANK BALANCE ?
	['tpLastPos'] = false -- TP PLAYER TO POS WHEN DISCONNECTED ?
}
settings.sessionSettings = {}
commandSuggestions = {}

-- Version check
-- PerformHttpRequest("http://poliakov.tk/version.txt", function(err, rText, headers)
-- 	print("\nCurrent version: " .. _VERSION)
-- 	print("Updater version: " .. rText .. "\n")
	
-- 	if rText ~= _VERSION then
-- 		print("\n---------------------------------------------\nVersion mismatch, you are currently not using the newest stable version of essentialmode. Please update: http://poliakov.tk\n---------------------------------------------\n")
-- 	else
-- 		print("Version OK!\n")
-- 	end
-- end, "GET", "", {what = 'this'})

AddEventHandler('playerDropped', function(reason)
	local Source = source

	if(Users[Source])then
		Users[Source].log('playerDropped ' .. reason)
		TriggerEvent("es:playerDropped", Users[Source])
		if(settings.defaultSettings.tpLastPos)then
			MySQL.Async.execute("UPDATE users SET `money`=@valmoney, `bankbalance`=@valbankbalance, `dirtymoney`=@valdirtymoney, `lastPosition`=@vallastposition WHERE identifier = @identifier",
			{['@valmoney'] = Users[Source].getMoney(), ['@valbankbalance'] = Users[Source].getBank(), ['@valdirtymoney'] = Users[Source].getDirtyMoney(), ['vallastposition'] = json.encode(Users[Source].getCoords()), ['@identifier'] = Users[Source].getIdentifier()})
		else
			MySQL.Async.execute("UPDATE users SET `money`=@valmoney, `bankbalance`=@valbankbalance, `dirtymoney`=@valdirtymoney WHERE identifier = @identifier",
			{['@valmoney'] = Users[Source].getMoney(), ['@valbankbalance'] = Users[Source].getBank(), ['@valdirtymoney'] = Users[Source].getDirtyMoney(), ['@identifier'] = Users[Source].getIdentifier()})
		end
		Users[Source] = nil
	end
end)

local justJoined = {}

RegisterServerEvent('es:firstJoinProper')
AddEventHandler('es:firstJoinProper', function()
	registerUser(GetPlayerIdentifiers(source)[1], source)
	justJoined[source] = true

	if(settings.defaultSettings.pvpEnabled)then
		TriggerClientEvent("es:enablePvp", source)
	end
end)

AddEventHandler('es:setSessionSetting', function(k, v)
	settings.sessionSettings[k] = v
end)

AddEventHandler('es:getSessionSetting', function(k, cb)
	cb(settings.sessionSettings[k])
end)

local firstSpawn = {}

RegisterServerEvent('playerSpawn')
AddEventHandler('playerSpawn', function()
	local Source = source
	if(firstSpawn[Source] == nil)then
		TriggerEvent("es:firstSpawn", Source, Users[Source])

		firstSpawn[Source] = true
	end
end)

AddEventHandler("es:setDefaultSettings", function(tbl)
	for k,v in pairs(tbl) do
		if(settings.defaultSettings[k] ~= nil)then
			settings.defaultSettings[k] = v
		end
	end

	debugMsg("Default settings edited.")
end)

AddEventHandler('chatMessage', function(source, n, message)
	if(startswith(message, settings.defaultSettings.commandDelimeter))then
		local command_args = stringsplit(message, " ")

		command_args[1] = string.gsub(command_args[1], settings.defaultSettings.commandDelimeter, "")

		local command = commands[command_args[1]]

		if(command)then
			local Source = source
			CancelEvent()
			if(command.perm > 0)then
	
				if(Users[source].getPermissions() >= command.perm or (groups[Users[source].getGroup()] ~= nil and groups[Users[source].getGroup()]:canTarget(command.group)))then
					command.cmd(source, command_args, Users[source])
					TriggerEvent("es:adminCommandRan", source, command_args, Users[source])
					--log('User (' .. GetPlayerName(Source) .. ') run admin command ' .. command_args[1] .. ', with parameters: ' .. table.concat(command_args, ' '))
					Users[source].log('run admin command ' .. command_args[1] .. ', with parameters: ' .. table.concat(command_args, ' '))
				else
					command.callbackfailed(source, command_args, Users[source])
					TriggerEvent("es:adminCommandFailed", source, command_args, Users[source])

					if(type(settings.defaultSettings.permissionDenied) == "string" and not WasEventCanceled())then
						TriggerClientEvent('chatMessage', source, "", {0,0,0}, defaultSettings.permissionDenied)
					end

					--log('User (' .. GetPlayerName(Source) .. ') tried to execute command without having permission: ' .. command_args[1])
					Users[source].log('tried to execute command without having permission ' .. command_args[1] .. ', with parameters: ' .. table.concat(command_args, ' '))
					debugMsg("Non admin (" .. GetPlayerName(Source) .. ") attempted to run admin command: " .. command_args[1])
				end
			else
				command.cmd(source, command_args, Users[source])
				TriggerEvent("es:userCommandRan", source, command_args)
			end
			
			TriggerEvent("es:commandRan", source, command_args, Users[source])
		else
			TriggerEvent('es:invalidCommandHandler', source, command_args, Users[source])

			if WasEventCanceled() then
				CancelEvent()
			end
		end
	else
		TriggerEvent('es:chatMessage', source, message, Users[source])
	end
end)

function addCommand(command, callback, suggestion)
	commands[command] = {}
	commands[command].perm = 0
	commands[command].group = "user"
	commands[command].cmd = callback

	if suggestion then
		if not suggestion.params or not type(suggestion.params) == "table" then suggestion.params = {} end
		if not suggestion.help or not type(suggestion.help) == "string" then suggestion.help = "" end

		commandSuggestions[command] = suggestion
	end

	debugMsg("Command added: " .. command)
end

AddEventHandler('es:addCommand', function(command, callback, suggestion)
	addCommand(command, callback, suggestion)
end)

function addAdminCommand(command, perm, callback, callbackfailed, suggestion)
	commands[command] = {}
	commands[command].perm = perm
	commands[command].group = "superadmin"
	commands[command].cmd = callback
	commands[command].callbackfailed = callbackfailed

	if suggestion then
		if not suggestion.params or not type(suggestion.params) == "table" then suggestion.params = {} end
		if not suggestion.help or not type(suggestion.help) == "string" then suggestion.help = "" end

		commandSuggestions[command] = suggestion
	end

	debugMsg("Admin command added: " .. command .. ", requires permission level: " .. perm)
end

AddEventHandler('es:addAdminCommand', function(command, perm, callback, callbackfailed, suggestion)
	addAdminCommand(command, perm, callback, callbackfailed, suggestion)
end)

function addGroupCommand(command, group, callback, callbackfailed, suggestion)
	commands[command] = {}
	commands[command].perm = math.maxinteger
	commands[command].group = group
	commands[command].cmd = callback
	commands[command].callbackfailed = callbackfailed

	if suggestion then
		if not suggestion.params or not type(suggestion.params) == "table" then suggestion.params = {} end
		if not suggestion.help or not type(suggestion.help) == "string" then suggestion.help = "" end

		commandSuggestions[command] = suggestion
	end

	debugMsg("Group command added: " .. command .. ", requires group: " .. group)
end

AddEventHandler('es:addGroupCommand', function(command, group, callback, callbackfailed, suggestion)
	addGroupCommand(command, group, callback, callbackfailed, suggestion)
end)

function addACECommand(command, group, callback)
	local allowedEveryone = false
	if group == true then allowedEveryone = true end
	RegisterCommand(command, function(source, args)
		if source ~= 0 then
			callback(source, args, Users[source])
		end
	end, allowedEveryone)

	if not allowedEveryone then
		ExecuteCommand('add_ace group.' .. group .. ' command.' .. command .. ' allow')
	end
end

AddEventHandler('es:addACECommand', function(command, group, callback)
	addACECommand(command, group, callback)
end)

RegisterServerEvent('es:updatePositions')
AddEventHandler('es:updatePositions', function(x, y, z)
	if(Users[source])then
		Users[source].setCoords(x, y, z)
	end
end)

-- Info command
commands['info'] = {}
commands['info'].perm = 0
commands['info'].cmd = function(source, args, user)
	local Source = source
	TriggerClientEvent('chatMessage', Source, 'SYSTEM', {255, 0, 0}, "^2[^3EssentialMode^2]^0 Version: ^2 " .. _VERSION)
	TriggerClientEvent('chatMessage', Source, 'SYSTEM', {255, 0, 0}, "^2[^3EssentialMode^2]^0 Commands loaded: ^2 " .. (returnIndexesInTable(commands) - 1))
end
