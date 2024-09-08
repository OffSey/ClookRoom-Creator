lib.locale()

local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil

if not ESX then return end

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