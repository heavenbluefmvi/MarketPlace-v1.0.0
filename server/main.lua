-- server/main.lua
local QBCore = exports['qb-core']:GetCoreObject()

local marketItems = {}
local currentPrices = {}
local adminGroups = { -- Thêm các group admin vào đây
    'admin',
    'superadmin'
}

-- Khởi tạo chợ
Citizen.CreateThread(function()
    -- Load dữ liệu từ database (nếu có)
    -- marketItems = MySQL.query.await('SELECT * FROM market_items')
    
    -- Dữ liệu mẫu
    marketItems = {
        {
            item = "wood",
            name = "Gỗ Thông",
            image = "https://cdn-icons-png.flaticon.com/512/2346/2346780.png",
            basePrice = 150,
            currentPrice = 150,
            enabled = true
        },
        -- Thêm các item khác tương tự
    }
    
    UpdateAllPrices()
end)

-- Hàm cập nhật giá
function UpdateAllPrices()
    currentPrices = {}
    for _, item in pairs(marketItems) do
        if item.enabled then
            local fluctuation = math.random(-200, 200)/1000 -- ±20%
            currentPrices[item.item] = math.floor(item.basePrice * (1 + fluctuation))
        end
    end
    TriggerClientEvent('qb-market:updatePrices', -1, currentPrices)
end

-- Sự kiện mở chợ
RegisterNetEvent('qb-market:openMarket', function()
    local src = source
    TriggerClientEvent('qb-market:openMarket', src, marketItems, currentPrices)
end)

-- Sự kiện bán vật phẩm
RegisterNetEvent('qb-market:sellItems', function(itemsToSell)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local total = 0

    for itemName, quantity in pairs(itemsToSell) do
        if quantity > 0 then
            local item = Player.Functions.GetItemByName(itemName)
            if not item or item.amount < quantity then
                TriggerClientEvent('QBCore:Notify', src, "Không đủ "..itemName, "error")
                return
            end
            
            Player.Functions.RemoveItem(itemName, quantity)
            total = total + (currentPrices[itemName] or 0) * quantity
        end
    end

    if total > 0 then
        Player.Functions.AddMoney('cash', total)
        TriggerClientEvent('QBCore:Notify', src, "Bán thành công được $"..total, "success")
    end
end)

-- Admin commands
QBCore.Commands.Add("addmarketitem", "Thêm vật phẩm vào chợ (Admin)", {{name = "item", help = "Tên vật phẩm"}, {name = "price", help = "Giá cơ bản"}}, true, function(source, args)
    local src = source
    if CheckAdmin(src) then
        local item = args[1]
        local price = tonumber(args[2])
        
        table.insert(marketItems, {
            item = item,
            name = item,
            basePrice = price,
            currentPrice = price,
            enabled = true
        })
        
        UpdateAllPrices()
        TriggerClientEvent('QBCore:Notify', src, "Đã thêm vật phẩm "..item, "success")
    end
end)

QBCore.Commands.Add("delmarketitem", "Xóa vật phẩm khỏi chợ (Admin)", {{name = "item", help = "Tên vật phẩm"}}, true, function(source, args)
    local src = source
    if CheckAdmin(src) then
        for k,v in pairs(marketItems) do
            if v.item == args[1] then
                table.remove(marketItems, k)
                break
            end
        end
        UpdateAllPrices()
        TriggerClientEvent('QBCore:Notify', src, "Đã xóa vật phẩm "..args[1], "success")
    end
end)

QBCore.Commands.Add("editmarketprice", "Chỉnh giá vật phẩm (Admin)", {{name = "item", help = "Tên vật phẩm"}, {name = "price", help = "Giá mới"}}, true, function(source, args)
    local src = source
    if CheckAdmin(src) then
        for _,v in pairs(marketItems) do
            if v.item == args[1] then
                v.basePrice = tonumber(args[2])
                UpdateAllPrices()
                TriggerClientEvent('QBCore:Notify', src, "Đã cập nhật giá "..args[1], "success")
                return
            end
        end
        TriggerClientEvent('QBCore:Notify', src, "Không tìm thấy vật phẩm", "error")
    end
end)

-- Hàm kiểm tra admin
function CheckAdmin(source)
    local Player = QBCore.Functions.GetPlayer(source)
    for _, group in pairs(adminGroups) do
        if Player.PlayerData.group == group then
            return true
        end
    end
    TriggerClientEvent('QBCore:Notify', source, "Bạn không có quyền!", "error")
    return false
end
