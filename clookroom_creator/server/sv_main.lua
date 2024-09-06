local ESX = exports['es_extended']:getSharedObject()

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

ESX.RegisterServerCallback('admin:getCloakrooms', function(source, cb)
    getCloakrooms(cb)
end)

RegisterNetEvent('admin:saveCloakroom', function(name, coords)
    local x, y, z = coords.x, coords.y, coords.z - 1
    local coordsJSON = json.encode({ x = x, y = y, z = z })

    MySQL.Async.execute('INSERT INTO cloakrooms (name, coords) VALUES (@name, @coords)', {
        ['@name'] = name,
        ['@coords'] = coordsJSON
    }, function()
        TriggerClientEvent('admin:reloadCloakrooms', -1)
    end)
end)

RegisterNetEvent('admin:deleteCloakroom', function(id)
    MySQL.Async.execute('DELETE FROM cloakrooms WHERE id = @id', {
        ['@id'] = id
    }, function()
        TriggerClientEvent('admin:reloadCloakrooms', -1)
    end)
end)

RegisterNetEvent('admin:updateCloakroomCoords', function(id, coords)
    local x, y, z = coords.x, coords.y, coords.z - 1
    local coordsJSON = json.encode({ x = x, y = y, z = z })

    MySQL.Async.execute('UPDATE cloakrooms SET coords = @coords WHERE id = @id', {
        ['@coords'] = coordsJSON,
        ['@id'] = id
    }, function()
        TriggerClientEvent('admin:reloadCloakrooms', -1)
    end)
end)

ESX.RegisterCommand(Config.Command, Config.Permissions, function(xPlayer, args, showError)
    if not xPlayer then
        return showError('[^1ERROR^7] The xPlayer value is nil')
    end
    local playerGroup = xPlayer.getGroup()
    local hasPermission = false
    for _, perm in ipairs(Config.Permissions) do
        if playerGroup == perm then
            hasPermission = true
            break
        end
    end

    if not hasPermission then
        return showError('[^1ERROR^7] You do not have permission to use this command')
    end
    TriggerClientEvent('openCloakroomMenu', xPlayer.source)
end, {help = 'Manage cloakrooms', params = {}})