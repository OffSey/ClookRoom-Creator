local QBCore = GetResourceState('qb-core'):find('start') and exports['qb-core']:GetCoreObject() or nil
if not QBCore then return end

local commandPermission = type(Config.Permissions) == "string" and Config.Permissions or "user"

QBCore.Commands.Add(Config.Command, 'Manage cloakrooms', {}, false, function(source)
    TriggerClientEvent('openCloakroomMenu', source)
end, commandPermission)
