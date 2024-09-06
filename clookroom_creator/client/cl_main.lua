lib.locale()

local selectedCloakroom = nil
local currentPosition = nil
local cloakroomMarkers = {}
local ESX = exports['es_extended']:getSharedObject()

function openCloakroomMenu()
    local options = {
        {
            title = locale('create_new_cloakroom'),
            icon = "fa-solid fa-plus",
            onSelect = function()
                createNewCloakroom()
            end
        },
        {
            title = locale('manage_existing_cloakrooms'),
            icon = "fa-solid fa-wand-magic",
            onSelect = function()
                showExistingCloakrooms()
            end
        }
    }

    lib.registerContext({
        id = 'admin_cloakroom',
        title = locale('cloakroom_management'),
        options = options
    })

    lib.showContext('admin_cloakroom')
end

function showExistingCloakrooms()
    ESX.TriggerServerCallback('admin:getCloakrooms', function(cloakrooms)
        local options = {}

        for _, cloakroom in ipairs(cloakrooms) do
            table.insert(options, {
                title = cloakroom.name,
                description = string.format("Pos: %s", cloakroom.coords),
                onSelect = function()
                    manageCloakroom(cloakroom)
                end
            })
        end

        lib.registerContext({
            id = 'existing_cloakrooms',
            title = locale('existing_cloakrooms'),
            menu = 'admin_cloakroom',
            options = options
        })

        lib.showContext('existing_cloakrooms')
    end)
end

function manageCloakroom(cloakroom)
    lib.registerContext({
        id = 'manage_cloakroom',
        menu = 'existing_cloakrooms',
        title = cloakroom.name,
        options = {
            {
                title = locale('move_cloakroom'),
                icon = "fa-solid fa-up-down-left-right",
                onSelect = function()
                    lib.showTextUI(locale('confirm_position'))
                    currentPosition = nil
                    CreateThread(function()
                        while not currentPosition do
                            if IsControlJustPressed(0, 38) then -- E
                                currentPosition = GetEntityCoords(PlayerPedId())
                                lib.hideTextUI()
                                TriggerServerEvent('admin:updateCloakroomCoords', cloakroom.id, currentPosition)
                                TriggerEvent('OffSey:showNotification', locale('cloakroom_moved_title'), locale('cloakroom_moved_message'), 'success')
                                lib.showContext('admin_cloakroom')
                            end
                            Wait(0)
                        end
                    end)
                end
            },
            {
                title = locale('teleport'),
                icon = "fa-solid fa-arrow-up-from-bracket",
                description = string.format("Pos: %s", cloakroom.coords),
                onSelect = function()
                    local lejoueur = PlayerPedId()
                    SetEntityCoords(lejoueur, cloakroom.coords)
                end
            },
            {
                title = locale('delete_cloakroom'),
                icon = "fa-solid fa-trash",
                onSelect = function()
                    TriggerServerEvent('admin:deleteCloakroom', cloakroom.id)
                    TriggerEvent('OffSey:showNotification', locale('cloakroom_deleted_title'), locale('cloakroom_deleted_message'), 'success')
                    lib.hideContext()
                end
            },
        }
    })

    lib.showContext('manage_cloakroom')
end

function createNewCloakroom()
    local input = lib.inputDialog(locale('create_cloakroom_title'), {
        {type = 'input', label = locale('cloakroom_name_label'), description = locale('cloakroom_name_description'), required = true, min = 4, max = 16}
    })

    if input then
        local name = input[1]
        lib.showTextUI(locale('confirm_position'))
        currentPosition = nil

        CreateThread(function()
            while not currentPosition do
                if IsControlJustPressed(0, 38) then -- E
                    currentPosition = GetEntityCoords(PlayerPedId())
                    lib.hideTextUI()
                    lib.registerContext({
                        id = 'confirm_cloakroom_creation',
                        title = locale('confirm_creation_title'),
                        options = {
                            {
                                title = locale('confirm'),
                                description = string.format(locale('confirm_description_format'), name, currentPosition),
                                onSelect = function()
                                    TriggerServerEvent('admin:saveCloakroom', name, currentPosition)
                                    TriggerEvent('OffSey:showNotification', locale('cloakroom_created_title'), locale('cloakroom_created_message'), 'success')
                                    lib.hideContext()
                                    lib.showContext('admin_cloakroom')
                                end
                            },
                            {
                                title = locale('cancel'),
                                onSelect = function()
                                    lib.hideContext()
                                    lib.showContext('admin_cloakroom')
                                end
                            }
                        }
                    })
                    lib.showContext('confirm_cloakroom_creation')
                end
                Wait(0)
            end
        end)
    end
end

function loadCloakrooms()
    ESX.TriggerServerCallback('admin:getCloakrooms', function(cloakrooms)
        cloakroomMarkers = cloakrooms
    end)
end

function drawCloakroomMarkers()
    CreateThread(function()
        while true do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            local sleep = 500

            for _, cloakroom in ipairs(cloakroomMarkers) do
                local markerCoords = vector3(cloakroom.coords.x, cloakroom.coords.y, cloakroom.coords.z)

                local distance = #(playerCoords - markerCoords)

                if distance < 20.0 then
                    sleep = 0 
                    DrawMarker(Config.Marker.Checkpoint.type, markerCoords.x, markerCoords.y, markerCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.Checkpoint.scale.x, Config.Marker.Checkpoint.scale.y, Config.Marker.Checkpoint.scale.z, Config.Marker.Checkpoint.color[1], Config.Marker.Checkpoint.color[2], Config.Marker.Checkpoint.color[3], Config.Marker.Checkpoint.color[4], false, true, 2, false, nil, nil, false)

                    if distance < 1.5 then
                        TriggerEvent('OffSey:TextUI', locale('openlockrooms'))

                        if IsControlJustPressed(0, 38) then -- E
                            if Config.Skin == "rcore_clothing" then
                                TriggerEvent('rcore_clothing:openChangingRoom')
                            elseif Config.Skin == "illenium-appearance" then
                                TriggerEvent('illenium-appearance:client:openOutfitMenu')
                            end
                        end
                    end
                end
            end

            Wait(sleep)
        end
    end)
end

CreateThread(function()
    loadCloakrooms()
    drawCloakroomMarkers()
end)

RegisterNetEvent('admin:reloadCloakrooms', function()
    loadCloakrooms()
end)

RegisterNetEvent('openCloakroomMenu')
AddEventHandler('openCloakroomMenu', function()
    openCloakroomMenu()
end)
