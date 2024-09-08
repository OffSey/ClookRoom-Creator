lib.locale()
utils = {}

function utils.OffSeyNotify(title, msg, type)
    lib.notify({
        title = title,
        description = msg,
        type = type,
        position = 'top-right',
    })
end

RegisterNetEvent('OffSey:showNotification', utils.OffSeyNotify)


function utils.OffSeyTextUI(title)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(title)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

RegisterNetEvent('OffSey:TextUI')
AddEventHandler('OffSey:TextUI', function(title)
    utils.OffSeyTextUI(title)
end)