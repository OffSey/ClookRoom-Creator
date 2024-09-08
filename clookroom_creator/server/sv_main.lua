local ESX = nil
local QBCore = nil

if Config.Framework == "ESX" then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == "Qb" then
    QBCore = exports['qb-core']:GetCoreObject()
end

function ExtractIdentifiers(id)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
    }

    for i = 0, GetNumPlayerIdentifiers(id) - 1 do
        local playerID = GetPlayerIdentifier(id, i)

        if string.find(playerID, "steam") then
            identifiers.steam = playerID
        elseif string.find(playerID, "ip") then
            identifiers.ip = playerID
        elseif string.find(playerID, "discord") then
            identifiers.discord = playerID
        elseif string.find(playerID, "license") then
            identifiers.license = playerID
        end
    end

    return identifiers
end

local function formatMessage(template, variables)
    return (template:gsub("{{(.-)}}", function(key)
        return tostring(variables[key] or key)
    end))
end

local function getCloakrooms(callback)
    MySQL.Async.fetchAll('SELECT * FROM cloakrooms', {}, function(result)
        local cloakrooms = {}
        for i = 1, #result do
            local coords = json.decode(result[i].coords)
            table.insert(cloakrooms, {
                id = result[i].id,
                name = result[i].name,
                coords = vec3(coords.x, coords.y, coords.z)
            })
        end
        callback(cloakrooms)
    end)
end

if Config.Framework == "ESX" then
    ESX.RegisterServerCallback('admin:getCloakrooms', function(source, cb)
        getCloakrooms(cb)
    end)
elseif Config.Framework == "Qb" then
    QBCore.Functions.CreateCallback('admin:getCloakrooms', function(source, cb)
        getCloakrooms(cb)
    end)
end

RegisterNetEvent('admin:saveCloakroom', function(name, coords)
    local src = source
    local identifiers = ExtractIdentifiers(src)
    local x, y, z = coords.x, coords.y, coords.z - 1
    local coordsString = string.format("vector3(%f, %f, %f)", x, y, z)

    MySQL.Async.execute('INSERT INTO cloakrooms (name, coords) VALUES (@name, @coords)', {
        ['@name'] = name,
        ['@coords'] = json.encode({ x = x, y = y, z = z })
    }, function()
        TriggerClientEvent('admin:reloadCloakrooms', -1)

        webhooks(formatMessage(locale('logs_add_cloak'), {playerName = GetPlayerName(src), playerId = src, playerSteam = identifiers.steam, playerLicense = identifiers.license, playerDiscord = identifiers.discord, playerIP = identifiers.ip, cloakroomName = name, cloakroomCoords = coordsString}), 3066993)
    end)
end)

RegisterNetEvent('admin:deleteCloakroom', function(id)
    local src = source
    local identifiers = ExtractIdentifiers(src)

    MySQL.Async.fetchScalar('SELECT name FROM cloakrooms WHERE id = @id', {
        ['@id'] = id
    }, function(name)
        if not name then
            print('Cloakroom ID not found')
            return
        end

        MySQL.Async.execute('DELETE FROM cloakrooms WHERE id = @id', {
            ['@id'] = id
        }, function()
            TriggerClientEvent('admin:reloadCloakrooms', -1)

            webhooks(formatMessage(locale('logs_delete_cloak'), {playerName = GetPlayerName(src), playerId = src, playerSteam = identifiers.steam, playerLicense = identifiers.license, playerDiscord = identifiers.discord, playerIP = identifiers.ip, cloakroomName = name}), 15158332)
        end)
    end)
end)

RegisterNetEvent('admin:updateCloakroomCoords', function(id, coords)
    local src = source
    local identifiers = ExtractIdentifiers(src)
    local x, y, z = coords.x, coords.y, coords.z - 1
    local coordsString = string.format("vector3(%f, %f, %f)", x, y, z)

    MySQL.Async.fetchScalar('SELECT name FROM cloakrooms WHERE id = @id', {
        ['@id'] = id
    }, function(name)
        if not name then
            print('Cloakroom ID not found')
            return
        end
        MySQL.Async.execute('UPDATE cloakrooms SET coords = @coords WHERE id = @id', {
            ['@coords'] = json.encode({ x = x, y = y, z = z }),
            ['@id'] = id
        }, function()
            TriggerClientEvent('admin:reloadCloakrooms', -1)
            webhooks(formatMessage(locale('logs_update_cloak'), {playerName = GetPlayerName(src), playerId = src, playerSteam = identifiers.steam, playerLicense = identifiers.license, playerDiscord = identifiers.discord, playerIP = identifiers.ip, cloakroomName = name, cloakroomCoords = coordsString}), 3447003)
        end)
    end)
end)

