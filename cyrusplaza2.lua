-- // WIND UI - BIG HUB SELLER (AUTO BOOTH SET ONLY - FIXED VERSION)
-- // Support Delta / Mobile

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local HttpService = game:GetService("HttpService")

local Window = WindUI:CreateWindow({
    Title = "CYRUS STORE",
    Author = "",
    FolderName = "BigHubDarkV99",
    Icon = "solar:bag-check-bold-duotone",
    Size = UDim2.fromOffset(580, 460),
    HideSearchBar = false,
    Theme = "Dark", 
    OpenButton = {
        Title = "Open Seller",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
        Color = ColorSequence.new(Color3.fromHex("#30FF6A"), Color3.fromHex("#e7ff2f")),
    },
    Topbar = { Height = 44, ButtonsType = "Mac" },
})

-- ═══════════════════════════════════════════
-- TAB
-- ═══════════════════════════════════════════
local BoothTab = Window:Tab({
    Title = "TRADE PLAZA",
    Icon = "solar:shop-bold",
    IconColor = Color3.fromHex("#a1a1aa"),
    IconShape = "Square",
    Border = true,
})

local SettingsTab = Window:Tab({
    Title = "SETTINGS",
    Icon = "solar:settings-bold",
    IconColor = Color3.fromHex("#a1a1aa"),
    IconShape = "Square",
    Border = true,
})

-- ═══════════════════════════════════════════
-- FPS BOOST
-- ═══════════════════════════════════════════
SettingsTab:Toggle({
    Title = "🚀 Simple FPS Boost",
    Value = false,
    Callback = function(Value)
        local Lighting = game:GetService("Lighting")
        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        if Value then
            Lighting.GlobalShadows = false Lighting.Brightness = 0 Lighting.FogEnd = 1000000
            for _, v in pairs(Lighting:GetChildren()) do if v:IsA("Atmosphere") or v:IsA("PostEffect") or v:IsA("Sky") then v:Destroy() end end
            if Terrain then Terrain.Decoration = false Terrain.WaterWaveSize = 0 end
            pcall(function() settings().Rendering.QualityLevel = 1 end)
        else
            Lighting.GlobalShadows = true Lighting.Brightness = 2 Lighting.FogEnd = 100000
            if Terrain then Terrain.Decoration = true Terrain.WaterWaveSize = 0.3 end
            pcall(function() workspace.LevelOfDetail = Enum.ModelLevelOfDetail.Automatic end)
        end
    end
})

-- ═══════════════════════════════════════════
-- SERVICES & MODULES
-- ═══════════════════════════════════════════
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TradeData = require(ReplicatedStorage.Shared.Trading.TradeData)
local Replion = require(ReplicatedStorage.Packages.Replion)
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)

local LocalPlayer = Players.LocalPlayer
local Data = Replion.Client:WaitReplion("Data")
local SaleListingsReplion = Replion.Client:WaitReplion("SaleListings")
local SellRemote = TradeData.Remotes.CreateSaleListing
local DeleteRemote = TradeData.Remotes.DeleteSaleListing

local MyBoothPath = {"Players", tostring(LocalPlayer.UserId), "Booth"}

-- ═══════════════════════════════════════════
-- KONFIGURASI AUTO BOOTH SET (ID & HARGA)
-- ═══════════════════════════════════════════
local AutoSetConfig = {
    -- FISH
    [158] = { Name = "King Crab", Price = 3 },
    [187] = { Name = "Queen Crab", Price = 3 },
    [82]  = { Name = "Blob Shark", Price = 3 },
    [83]  = { Name = "Ghost Shark", Price = 3 },
    [359] = { Name = "Gladiator Shark", Price = 3 },
    [339] = { Name = "Skeleton Narwhal", Price = 3 },
    [226] = { Name = "Megalodon", Price = 21 },
    [228] = { Name = "Lochness Monster", Price = 51 },
    [833] = { Name = "Bonemaw Tyrant", Price = 16 },
    [882] = { Name = "Deepsea Monster Axol", Price = 11 },
    -- ENCHANT STONES
    [558] = { Name = "Evolved Enchant Stone", Price = 3 },
    [873] = { Name = "Eggy Enchant Stone", Price = 61 },
    [929] = { Name = "Runic Enchant Stone", Price = 51 },
}

local AutoSetState = {
    IsRunning = false,
    ItemQueue = {}, 
}

-- ═══════════════════════════════════════════
-- FUNGSI HELPER AUTO BOOTH SET (FIXED)
-- ═══════════════════════════════════════════
local function scanAndQueueAutoSet()
    local inv = Data:Get({ "Inventory" })
    if typeof(inv) ~= "table" then return end
    
    AutoSetState.ItemQueue = {}
    local totalScanned = 0
    
    for category, items in pairs(inv) do
        if typeof(items) == "table" then
            for _, v in ipairs(items) do
                if AutoSetConfig[v.Id] then
                    -- FIX: Mengambil data lengkap item untuk mencari tipe yang benar
                    local ok, data = pcall(function() return ItemUtility.GetItemDataFromItemType(category, v.Id) end)
                    
                    if ok and data and data.Data and data.Data.Type then
                        local config = AutoSetConfig[v.Id]
                        local correctType = data.Data.Type -- Ini penting! Menggunakan data.Data.Type
                        
                        if not AutoSetState.ItemQueue[v.Id] then
                            AutoSetState.ItemQueue[v.Id] = {}
                        end
                        table.insert(AutoSetState.ItemQueue[v.Id], {
                            UUID = v.UUID,
                            Category = correctType, -- Menggunakan tipe yang benar dari server
                            Price = config.Price,
                            Name = config.Name,
                            Id = v.Id
                        })
                        totalScanned = totalScanned + 1
                    end
                end
            end
        end
    end
    print("[AUTO SET] Scan selesai. Ditemukan " .. totalScanned .. " item dari list.")
end

local function isItemIdInBooth(itemId)
    local listings = SaleListingsReplion:Get(MyBoothPath)
    if typeof(listings) ~= "table" then return false end
    
    for _, listing in pairs(listings) do
        if listing and listing.Item then
            -- Cek berdasarkan ID Item
            if listing.Item.Id == itemId then
                return true
            end
        end
    end
    return false
end

-- ═══════════════════════════════════════════
-- INISIALISASI AWAL
-- ═══════════════════════════════════════════
WindUI:Notify({ Title = "Loading", Content = "Menyiapkan sistem..." })
repeat task.wait(0.5) until typeof(Data:Get({ "Inventory" })) == "table" and next(Data:Get({ "Inventory" })) ~= nil

scanAndQueueAutoSet()
WindUI:Notify({ Title = "Ready!", Content = "Sistem siap digunakan!" })

BoothTab:Button({
    Title = "🔄 Refresh Inventory",
    Callback = function()
        scanAndQueueAutoSet()
        WindUI:Notify({ Title = "Updated", Content = "Inventory di-scan ulang!" })
    end
})

BoothTab:Space()

-- ═══════════════════════════════════════════
-- TOGGLE AUTO BOOTH SET (FIXED LOGIC)
-- ═══════════════════════════════════════════
AutoBoothTogle = BoothTab:Toggle({
    Title = "🤖 AUTO BOOTH SET",
    Value = false,
    Callback = function(Value)
        if Value then
            scanAndQueueAutoSet()
            WindUI:Notify({ Title = "Auto Booth Set", Content = "Inventory di-scan. Memulai auto jual..." })
            
            task.spawn(function()
                AutoSetState.IsRunning = true
                
                while AutoSetState.IsRunning do
                    local listedAnyThisCycle = false
                    
                    for itemId, configData in pairs(AutoSetConfig) do
                        if not AutoSetState.IsRunning then break end
                        
                        -- Cek apakah item sudah ada di booth
                        if isItemIdInBooth(itemId) then
                            continue
                        end
                        
                        local queueList = AutoSetState.ItemQueue[itemId]
                        
                        if queueList and #queueList > 0 then
                            local itemToSell = queueList[1]
                            
                            local success, result = pcall(function()
                                -- FIX: Menggunakan 'itemToSell.Category' yang sudah diambil dari data.Data.Type
                                return SellRemote:InvokeServer("Booth", itemToSell.Category, itemToSell.UUID, itemToSell.Price)
                            end)
                            
                            if success then
                                if result == true then
                                    print("[AUTO SET] Sukses menjual: " .. itemToSell.Name)
                                    table.remove(queueList, 1)
                                    listedAnyThisCycle = true
                                else
                                    print("[AUTO SET] Gagal jual " .. itemToSell.Name .. ": " .. tostring(result))
                                end
                            else
                                print("[AUTO SET] Error Remote: " .. tostring(result))
                            end
                            
                            task.wait(0.5)
                        end
                    end
                    
                    if not listedAnyThisCycle then
                        task.wait(2)
                        scanAndQueueAutoSet()
                    else
                        task.wait(1)
                    end
                end
            end)
            
        else
            AutoSetState.IsRunning = false
            WindUI:Notify({ Title = "Auto Booth Set", Content = "Berhenti." })
        end
    end
})

-- ═══════════════════════════════════════════
-- TOGGLE HAPUS SEMUA BOOTH
-- ═══════════════════════════════════════════
BoothTab:Space()

local ClearBoothToggle

ClearBoothToggle = BoothTab:Toggle({
    Title = "🗑️ HAPUS SEMUA ITEM BOOTH",
    Value = false,
    Callback = function(Value)
        if Value then
            if AutoSetState.IsRunning then
                AutoSetState.IsRunning = false
                AutoBoothTogle:Set(false)
            end
            
            task.wait(0.5)
            
            local listings = SaleListingsReplion:Get(MyBoothPath)
            if typeof(listings) ~= "table" or next(listings) == nil then
                WindUI:Notify({ Title = "Booth Kosong", Content = "Tidak ada item yang perlu dihapus." })
                ClearBoothToggle:Set(false)
                return
            end
            
            WindUI:Notify({ Title = "Clearing Booth", Content = "Menghapus semua item dari booth..." })
            
            local deleteCount = 0
            for listingId, _ in pairs(listings) do
                local success, err = pcall(function()
                    return DeleteRemote:InvokeServer("Booth", listingId)
                end)
                
                if success then
                    deleteCount += 1
                else
                    warn("Gagal hapus listing: " .. tostring(err))
                end
                task.wait(0.5)
            end
            
            WindUI:Notify({ Title = "Booth Dibersihkan!", Content = deleteCount .. " item berhasil dihapus dari booth." })
            
            task.wait(1)
            scanAndQueueAutoSet()
            ClearBoothToggle:Set(false)
        end
    end
})
