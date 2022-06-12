local group = "user"
local states = {}
states.frozen = false
states.frozenPos = nil

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(4)
		
		if (IsControlJustPressed(1, 212) and IsControlJustPressed(1, 213)) then
			if group ~= "user" then
				SetNuiFocus(true, true)
				SendNUIMessage({type = 'open', players = getPlayers()})
			end
		end
	end
end)

RegisterNetEvent('es_admin:setGroup')
AddEventHandler('es_admin:setGroup', function(g)
	group = g
end)

RegisterNUICallback('close', function(data, cb)
	SetNuiFocus(false)
end)

RegisterNUICallback('quick', function(data, cb)
	if data.type == "slay_all" or data.type == "bring_all" or data.type == "slap_all" then
		TriggerServerEvent('es_admin:all', data.type)
	else
		TriggerServerEvent('es_admin:quick', data.id, data.type)
	end
end)

RegisterNUICallback('set', function(data, cb)
	TriggerServerEvent('es_admin:set', data.type, data.user, data.param)
end)

local noclip = false
RegisterNetEvent('es_admin:quick')
AddEventHandler('es_admin:quick', function(t, target)
	if t == "slay" then SetEntityHealth(PlayerPedId(), 0) end
	if t == "goto" then SetEntityCoords(PlayerPedId(), GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(target)))) end
	if t == "bring" then 
		states.frozenPos = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(target)))
		SetEntityCoords(PlayerPedId(), GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(target)))) 
	end
	if t == "crash" then 
		Citizen.Trace("You're being crashed, so you know. This server sucks.\n")
		Citizen.CreateThread(function()
			while true do end
		end) 
	end
	if t == "slap" then ApplyForceToEntity(PlayerPedId(), 1, 9500.0, 3.0, 7100.0, 1.0, 0.0, 0.0, 1, false, true, false, false) end
	if t == "noclip" then
		local msg = "disabled"
		if(noclip == false)then
			noclip_pos = GetEntityCoords(PlayerPedId(), false)
		end

		noclip = not noclip

		if(noclip)then
			msg = "enabled"
		end

		TriggerEvent("chatMessage", "SYSTEM", {255, 0, 0}, "Noclip has been ^2^*" .. msg)
	end
	if t == "freeze" then
		local player = PlayerId()

		local ped = PlayerPedId()

		states.frozen = not states.frozen
		states.frozenPos = GetEntityCoords(ped, false)

		if not state then
			if not IsEntityVisible(ped) then
				SetEntityVisible(ped, true)
			end

			if not IsPedInAnyVehicle(ped) then
				SetEntityCollision(ped, true)
			end

			FreezeEntityPosition(ped, false)
			SetPlayerInvincible(player, false)
		else
			SetEntityCollision(ped, false)
			FreezeEntityPosition(ped, true)
			SetPlayerInvincible(player, true)

			if not IsPedFatallyInjured(ped) then
				ClearPedTasksImmediately(ped)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if(states.frozen)then
			ClearPedTasksImmediately(PlayerPedId())
			SetEntityCoords(PlayerPedId(), states.frozenPos)
		else
			Citizen.Wait(200)
		end
	end
end)

local heading = 0


function GetHanksInput()
	return Citizen.InvokeNative(0xA571D46727E2B718, 2) and "MouseAndKeyboard" or "GamePad"
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(4)

		if(noclip)then
			local currentSpeed = 1
            local noclipEntity =
            IsPedInAnyVehicle(PlayerPedId(-1), false) and GetVehiclePedIsUsing(PlayerPedId(-1)) or
            PlayerPedId(-1)

            local newPos = GetEntityCoords(entity)

            DisableControlAction(0, 32, true)
            DisableControlAction(0, 268, true)

            DisableControlAction(0, 31, true)

            DisableControlAction(0, 269, true)
            DisableControlAction(0, 33, true)

            DisableControlAction(0, 266, true)
            DisableControlAction(0, 34, true)

            DisableControlAction(0, 30, true)

            DisableControlAction(0, 267, true)
            DisableControlAction(0, 35, true)

            DisableControlAction(0, 44, true)
            DisableControlAction(0, 20, true)

            local yoff = 0.0
            local zoff = 0.0

            if GetHanksInput() == "MouseAndKeyboard" then
                if IsDisabledControlPressed(0, 32) then
                    yoff = 0.5
                end
                if IsDisabledControlPressed(0, 33) then
                    yoff = -0.5
                end
                if IsDisabledControlPressed(0, 34) then
                    SetEntityHeading(PlayerPedId(-1), GetEntityHeading(PlayerPedId(-1)) + 3.0)
                end
                if IsDisabledControlPressed(0, 35) then
                    SetEntityHeading(PlayerPedId(-1), GetEntityHeading(PlayerPedId(-1)) - 3.0)
                end
                if IsDisabledControlPressed(0, 22) then
                    zoff = 0.21
                end
                if IsDisabledControlPressed(0, 21) then
                    zoff = -0.21
                end
                if IsDisabledControlPressed(0, 54) then
                    currentSpeed = 10.0
                end
            end

            newPos =
                GetOffsetFromEntityInWorldCoords(
                noclipEntity,
                0.0,
                yoff * (currentSpeed + 0.3),
                zoff * (currentSpeed + 0.3)
            )

            local heading = GetEntityHeading(noclipEntity)
            SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
            SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
            SetEntityHeading(noclipEntity, heading)

            SetEntityCollision(noclipEntity, false, false)
            SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, true, true, true)

			SetEntityCollision(noclipEntity, true, true)
		end
	end
end)

RegisterNetEvent('es_admin:freezePlayer')
AddEventHandler("es_admin:freezePlayer", function(state)
	local player = PlayerId()

	local ped = PlayerPedId()

	states.frozen = state
	states.frozenPos = GetEntityCoords(ped, false)

	if not state then
		if not IsEntityVisible(ped) then
			SetEntityVisible(ped, true)
		end

		if not IsPedInAnyVehicle(ped) then
			SetEntityCollision(ped, true)
		end

		FreezeEntityPosition(ped, false)
		SetPlayerInvincible(player, false)
	else
		SetEntityCollision(ped, false)
		FreezeEntityPosition(ped, true)
		SetPlayerInvincible(player, true)

		if not IsPedFatallyInjured(ped) then
			ClearPedTasksImmediately(ped)
		end
	end
end)

RegisterNetEvent('es_admin:teleportUser')
AddEventHandler('es_admin:teleportUser', function(x, y, z)
	SetEntityCoords(PlayerPedId(), x, y, z)
	states.frozenPos = {x = x, y = y, z = z}
end)

RegisterNetEvent('es_admin:slap')
AddEventHandler('es_admin:slap', function()
	local ped = PlayerPedId()

	ApplyForceToEntity(ped, 1, 9500.0, 3.0, 7100.0, 1.0, 0.0, 0.0, 1, false, true, false, false)
end)

RegisterNetEvent('es_admin:kill')
AddEventHandler('es_admin:kill', function()
	SetEntityHealth(PlayerPedId(), 0)
end)

RegisterNetEvent('es_admin:heal')
AddEventHandler('es_admin:heal', function()
	SetEntityHealth(PlayerPedId(), 200)
end)

RegisterNetEvent('es_admin:crash')
AddEventHandler('es_admin:crash', function()
	while true do
	end
end)

RegisterNetEvent("es_admin:noclip")
AddEventHandler("es_admin:noclip", function(t)
	local msg = "disabled"
	if(noclip == false)then
		noclip_pos = GetEntityCoords(PlayerPedId(), false)
	end

	noclip = not noclip

	if(noclip)then
		msg = "enabled"
	end

	TriggerEvent("chatMessage", "SYSTEM", {255, 0, 0}, "Noclip has been ^2^*" .. msg)
end)

function getPlayers()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
        table.insert(players, {id = GetPlayerServerId(player), name = GetPlayerName(player)})
    end
    return players
end

local _players = {};

RegisterNetEvent("atg-infinity:setPlayers")
AddEventHandler("atg-infinity:setPlayers", function(cb)
    _players = cb;
end)

RegisterNetEvent("atg-infinity:getPlayers")
AddEventHandler("atg-infinity:getPlayers", function(cb)
    return _players
end)

exports("getPlayers", function()
    return _players
end)

Citizen.CreateThread(function()
    repeat
        Citizen.Wait(1000)
    until _players ~= nil

    local players = 0;

    local kekStr = (
        "[%s] %s"
    ):format(
        GetPlayerServerId(PlayerId()), GetPlayerName(PlayerId())
    )

    while true do
        SetDiscordAppId()
        SetDiscordRichPresenceAsset('large')
        SetDiscordRichPresenceAssetText('Cloud RP | discord.gg/cdev')
        SetDiscordRichPresenceAssetSmall('512')
        SetDiscordRichPresenceAssetSmallText('logo')

        for k, v in pairs(_players) do
            players = players + 1
        end

        SetRichPresence(
            (
                "[%s/100] Cloud RP | discord.gg/cdev"
            ):format(
                players
            )
        )

        players = 0
        Citizen.Wait(15000)
    end
end)