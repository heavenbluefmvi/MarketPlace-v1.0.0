-- client/main.lua
local inMarket = false

RegisterNetEvent('qb-market:openMarket', function(items, prices)
    inMarket = true
    SendNUIMessage({
        type = 'open',
        items = items,
        prices = prices
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback('close', function(_, cb)
    inMarket = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('sellItems', function(data, cb)
    TriggerServerEvent('qb-market:sellItems', data)
    cb('ok')
end)

-- Cập nhật giá real-time
RegisterNetEvent('qb-market:updatePrices', function(prices)
    SendNUIMessage({
        type = 'updatePrices',
        prices = prices
    })
end)
