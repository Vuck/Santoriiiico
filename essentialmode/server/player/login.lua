-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --
-- NO TOUCHY, IF SOMETHING IS WRONG CONTACT KANERSPS! --

-- VERSION MYSQL ASYNC BY POLIAKOV (aka PERVS)--

function LoadUser(identifier, source, new)
	MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @name", {['@name'] = identifier}, function (result)
		Users[source] = CreatePlayer(source, result[1].permission_level, result[1].money, result[1].bankbalance, result[1].identifier, result[1].group, result[1].dirtymoney)
		Users[source].log('Connecting')
		TriggerEvent('es:playerLoaded', source, Users[source])

		TriggerClientEvent('es:setPlayerDecorator', source, 'rank', Users[source]:getPermissions())
		TriggerClientEvent('es:setMoneyIcon', source,settings.defaultSettings.moneyIcon)

		Users[source].setMoney(result[1].money)
		if(settings.defaultSettings.showBankBalance)then
			Users[source].setBankBalance(result[1].bankbalance)
		end
		if(settings.defaultSettings.dirtyMoneyShow)then
			Users[source].setDirtyMoney(result[1].dirtymoney)
		end
		if(new)then
			TriggerEvent('es:newPlayerLoaded', source, Users[source])
		end
		if(settings.defaultSettings.tpLastPos)then
			local coordsForSpawn = json.decode(result[1].lastPosition)
			TriggerClientEvent('es:setSpawnCoords_c', source, coordsForSpawn)
		end
	end)
end

function getPlayerFromId(id)
	print("Test: " .. type(id) .. " | " .. id)
	return Users[id]
end

AddEventHandler('es:getPlayers', function(cb)
	cb(Users)
end)

function hasAccount(identifier, callback)
	local result = MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @name", {['@name'] = identifier}, function (result)
		if(result[1] ~= nil) then
			callback(true)
		else
			callback(false)
		end
	end)
end

function registerUser(identifier, source)
	hasAccount(identifier, function (result)
		if result then
			LoadUser(identifier, source, false)
		else
			--Mais prenez garde ! Le premier nombre aléatoire que vous obtenez 'n'est pas vraiment randomisé '(au moins dans Windows 2K et OS X). Pour obtenir à un meilleur nombre pseudo-aléatoire il faut générer quelques nombres aléatoires avant d'en obtenir un vrai
			local phoneNumber = '0' .. math.random(600000000,699999999)
			phoneNumber = '0' .. math.random(600000000,699999999)
			phoneNumber = '0' .. math.random(600000000,699999999)
			phoneNumber = '0' .. math.random(600000000,699999999)
			phoneNumber = '0' .. math.random(600000000,699999999)
			phoneNumber = '0' .. math.random(600000000,699999999)
			phoneNumber = '0' .. math.random(600000000,699999999)
			phoneNumber = '0' .. math.random(600000000,699999999)
			phoneNumber = '0' .. math.random(600000000,699999999)
			phoneNumber = '0' .. math.random(600000000,699999999)
			phoneNumber = '0' .. math.random(600000000,699999999)
			
			-- local phoneNumberIsExisting = MySQL.Sync.fetchAll("SELECT identifier FROM users WHERE phone_number = @phoneNumber", {
				-- ['@phoneNumber'] = '0'
			-- })
			-- print("YOYOYOYOYOYOYOY")
			-- print(phoneNumber)
			-- print(phoneNumberIsExisting[1].identifier)
			-- while phoneNumberIsExisting[1].count ~= 0 do
				-- phoneNumber = '0' .. math.random(600000000,699999999)
				-- phoneNumberIsExisting = MySQL.Sync.fetchAll("SELECT COUNT(*) FROM users WHERE phone_number = @phoneNumber", {
					-- ['@phoneNumber'] = tonumber(phoneNumber)
				-- })
				-- print(phoneNumber)
				-- print(phoneNumberIsExisting[1].count)
			-- end	
			print("YOYOYOYOYOYOYOYO")
			MySQL.Async.execute("INSERT INTO users (`identifier`, `money`, `bankbalance`, `phone_number`) VALUES (@identifier,@money,@bankbalance,@phoneNumber)", {['@identifier'] = identifier, ['@money'] = settings.defaultSettings.startingCash, ['@bankbalance'] = settings.defaultSettings.startingBank, ['@phoneNumber'] = phoneNumber})

			LoadUser(identifier, source, true)
		end
	end)
end

AddEventHandler("es:setPlayerData", function(user, k, v, cb)
	if(Users[user])then
		if(Users[user].get(k))then
			if(k ~= "money") then
				Users[user].set(k, v)

				MySQL.Async.execute("UPDATE users SET @key=@value WHERE identifier = @identifier",
				{['@key'] = k, ['@value'] = v, ['@identifier'] = Users[user]['identifier']})
			end

			if(k == "group")then
				Users[user].set(k, v)
			end
		else
			cb("Column does not exist!", false)
		end
	else
		cb("User could not be found!", false)
	end
end)

AddEventHandler("es:setPlayerDataId", function(user, k, v, cb)
	MySQL.Async.execute("UPDATE users SET @key=@value WHERE identifier = @identifier",
	{['@key'] = k, ['@value'] = v, ['@identifier'] = user})

	cb("Player data edited.", true)
end)

AddEventHandler("es:getPlayerFromId", function(user, cb)
	if cb == nil then
		print('===============================================================================================================')
		print('===============================================================================================================')
		print('===============================================================================================================')
		print('es:getPlayerFromId cb is NIL !!! ERROR :D')
		print('===============================================================================================================')
		print('===============================================================================================================')
		print('===============================================================================================================')
		return 
	end
	if(Users)then
		if(Users[user])then
			cb(Users[user])
		else
			cb(nil)
		end
	else
		cb(nil)
	end
end)

AddEventHandler("es:getPlayerFromIdentifier", function(identifier, cb)
	MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @name", {['@name'] = identifier}, function (result)
		if(result[1])then
			cb(result[1])
		else
			cb(nil)
		end
	end)
end)

-- Function to update player money every 60 seconds.
local function savePlayerMoney()
	SetTimeout(60000, function()
		for k,v in pairs(Users)do
			if Users[k] ~= nil then
				MySQL.Async.execute("UPDATE users SET `money`=@valMoney, `bankbalance`=@valBankBalance, `dirtymoney`=@valDirtyMoney WHERE identifier = @identifier",
				{['@valMoney'] = v.getMoney(), ['@valBankBalance'] = v.getBank(), ['@valDirtyMoney'] = v.getDirtyMoney(), ['@identifier'] = v.getIdentifier()})
			end
		end

		savePlayerMoney()
	end)
end

savePlayerMoney()