-- // WIND UI - BIG HUB SELLER (PURE DARK + FAST REACTION + UUID CACHE + AUTO SAVE/LOAD + AUTO EQUIP)
-- // Updated Mutation/Shiny Logic + Auto Equip on Sell

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
-- AUTO EQUIP SYSTEM INITIALIZATION
-- ═══════════════════════════════════════════
local EquipRemote = nil

task.spawn(function()
    local success, Module = pcall(function()
        return require(ReplicatedStorage.Controllers.InventoryController.TileInteraction)
    end)
    
    if success and Module then
        -- Cari RemoteEvent di dalam upvalues module EquipRod atau fungsi sejenis
        if Module.EquipRod then
            for _, v in pairs(debug.getupvalues(Module.EquipRod)) do
                if typeof(v) == "Instance" and v:IsA("RemoteEvent") then
                    EquipRemote = v
                    print("[CyrusStore] Auto Equip Remote ditemukan!")
                    break
                end
            end
        end
        
        -- Fallback jika belum ketemu, coba fungsi lain jika ada
        if not EquipRemote then
            warn("[CyrusStore] Gagal menemukan Equip Remote otomatis.")
        end
    else
        warn("[CyrusStore] Gagal memuat Module TileInteraction.")
    end
end)

-- ═══════════════════════════════════════════
-- GLOBAL CACHE SYSTEM (UPDATED LOGIC)
-- ═══════════════════════════════════════════
local CachedLists = { ["Fish"] = {}, ["Enchant Stones"] = {} }
local ItemDatabase = { ["Fish"] = {}, ["Enchant Stones"] = {} }
local SlotUIReferences = {}

local function getDisplayName(item, itemData)
    if not item or not itemData or not itemData.Data then return "Unknown" end
    
    local baseName = itemData.Data.Name or "Unknown"
    local metadata = item.Metadata
    
    if itemData.Data.Type == "Fish" then
        local mutationName = ""
        if metadata and metadata.VariantId then
            local ok, variantData = pcall(function() return ItemUtility:GetVariantData(metadata.VariantId) end)
            if ok and variantData and variantData.Data then
                mutationName = variantData.Data.Name .. " "
            end
        end
        
        return mutationName .. baseName
    end
    
    return baseName
end

local function refreshGlobalCache()
    local inv = Data:Get({ "Inventory" })
    if typeof(inv) ~= "table" then return end
    
    ItemDatabase = { ["Fish"] = {}, ["Enchant Stones"] = {} }
    local count = { ["Fish"] = {}, ["Enchant Stones"] = {} }
    
    for category, items in pairs(inv) do
        if typeof(items) == "table" then
            for _, v in ipairs(items) do
                local ok, data = pcall(function() return ItemUtility.GetItemDataFromItemType(category, v.Id) end)
                if ok and data and data.Data then
                    local t = data.Data.Type
                    if t == "Fish" or t == "Enchant Stones" then
                        local name = getDisplayName(v, data)
                        count[t][name] = (count[t][name] or 0) + (v.Quantity or 1)
                        
                        if not ItemDatabase[t][name] then
                            ItemDatabase[t][name] = {}
                        end
                        table.insert(ItemDatabase[t][name], v.UUID)
                    end
                end
            end
        end
    end
    
    for cat, items in pairs(count) do
        local list = {}
        for name, total in pairs(items) do table.insert(list, name .. " (" .. total .. ")") end
        table.sort(list)
        CachedLists[cat] = list
    end

    for slotNum, ref in pairs(SlotUIReferences) do
        if ref and ref.ItemDropdown and ref.State then
            local cachedList = CachedLists[ref.State.Category] or {}
            ref.ItemDropdown:Refresh(cachedList)
        end
    end
end

WindUI:Notify({ Title = "Loading", Content = "Menyimpan UUID Inventory..." })
repeat task.wait(0.5) until typeof(Data:Get({ "Inventory" })) == "table" and next(Data:Get({ "Inventory" })) ~= nil

refreshGlobalCache()
WindUI:Notify({ Title = "Ready!", Content = "Semua UUID berhasil disimpan!" })

-- ═══════════════════════════════════════════
-- AUTO SAVE / LOAD SYSTEM
-- ═══════════════════════════════════════════
local ConfigFileName = "CyrusStore_Config.json"

local function saveSettings()
    local dataToSave = {}
    for i = 1, 4 do
        if SlotUIReferences[i] and SlotUIReferences[i].State then
            local st = SlotUIReferences[i].State
            dataToSave[tostring(i)] = {
                Category = st.Category,
                DisplayName = st.DisplayName,
                Price = st.Price
            }
        end
    end
    pcall(function()
        writefile(ConfigFileName, HttpService:JSONEncode(dataToSave))
    end)
end

local function loadSettings()
    local success, result = pcall(function()
        return readfile(ConfigFileName)
    end)
    
    if success and result then
        local decodeSuccess, decoded = pcall(function() return HttpService:JSONDecode(result) end)
        if not decodeSuccess then return end
        
        for i = 1, 4 do
            local slotData = decoded[tostring(i)]
            if slotData and SlotUIReferences[i] then
                local st = SlotUIReferences[i].State
                local ui = SlotUIReferences[i]

                st.Category = slotData.Category or "Fish"
                pcall(function() 
                    if ui.CategoryDropdown then ui.CategoryDropdown:Set(st.Category) end 
                end)

                local cachedList = CachedLists[st.Category] or {}
                local itemExists = false
                for _, v in ipairs(cachedList) do
                    if v == slotData.DisplayName then
                        itemExists = true
                        break
                    end
                end

                if itemExists then
                    st.DisplayName = slotData.DisplayName
                    st.CleanName = string.match(slotData.DisplayName, "(.+)%s%(") or slotData.DisplayName
                    pcall(function() 
                        if ui.ItemDropdown then ui.ItemDropdown:Set(slotData.DisplayName) end 
                    end)
                else
                    st.DisplayName = ""
                    st.CleanName = ""
                end

                if slotData.Price and slotData.Price ~= 0 then
                    st.Price = slotData.Price
                    pcall(function() 
                        if ui.PriceInput then ui.PriceInput:Set(tostring(slotData.Price)) end 
                    end)
                end
            end
        end
    end
end

BoothTab:Button({
    Title = "🔄 Refresh Data & UUID Inventori",
    Callback = function()
        refreshGlobalCache()
        loadSettings()
        WindUI:Notify({ Title = "Updated", Content = "Data & Settingan diperbarui!" })
    end
})

BoothTab:Space()

-- ═══════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════
local function isItemNameListed(itemName)
    local listings = SaleListingsReplion:Get(MyBoothPath)
    if typeof(listings) ~= "table" then return false end
    
    for _, listing in pairs(listings) do
        if listing and listing.Item then
            local ok, data = pcall(function() return ItemUtility.GetItemDataFromItemType(listing.ItemType, listing.Item.Id) end)
            if ok and data and data.Data then
                local listedName = getDisplayName(listing.Item, data)
                if listedName == itemName then
                    return true
                end
            end
        end
    end
    return false
end

-- ═══════════════════════════════════════════
-- SISTEM PEMBUATAN SLOT
-- ═══════════════════════════════════════════
local function createSlot(slotNumber)
    local slotState = { Category = "Fish", DisplayName = "", CleanName = "", Price = 0, IsSelling = false }

    local SlotSection = BoothTab:Section({
        Title = "🤖  SLOT " .. slotNumber,
        Box = true, BoxBorder = true, Opened = (slotNumber == 1),
    })

    local CategoryDropdown
    local ItemDropdown
    local PriceInput
    local SellToggle

    CategoryDropdown = SlotSection:Dropdown({
        Title = "PILIH KATEGORI",
        Values = {"Fish", "Enchant Stones"}, 
        Value = "Fish", 
        Callback = function(option)
            slotState.Category = option
            local cachedList = CachedLists[option] or {}
            ItemDropdown:Refresh(cachedList)
            
            slotState.DisplayName = ""
            slotState.CleanName = ""
            
            saveSettings()
        end
    })

    SlotSection:Space()

    ItemDropdown = SlotSection:Dropdown({
        Title = "PILIH ITEM",
        Values = CachedLists["Fish"],
        Value = nil,
        Callback = function(option)
            slotState.DisplayName = option
            slotState.CleanName = string.match(option, "(.+)%s%(") or option
            saveSettings()
        end
    })

    SlotSection:Space()

    PriceInput = SlotSection:Input({
        Title = "MASUKAN HARGA",
        Placeholder = "Contoh: 10",
        Callback = function(text)
            local num = tonumber(text)
            if num then slotState.Price = num end
            saveSettings()
        end
    })

    SlotSection:Space()

    SellToggle = SlotSection:Toggle({
        Title = "MULAI JUAL",
        Value = false,
        Callback = function(Value)
            slotState.IsSelling = Value
            if Value then
                if slotState.CleanName == "" then
                    WindUI:Notify({ Title = "Slot " .. slotNumber .. " Error", Content = "Pilih item dulu!" })
                    task.defer(function() SellToggle:Set(false) end)
                    return
                end
                
                task.spawn(function()
                    local failCount = 0
                    local MAX_FAIL = 5
                    
                    while slotState.IsSelling do
                        local isListed = isItemNameListed(slotState.CleanName)
                        
                        if isListed then
                            failCount = 0 
                            task.wait(1) 
                        else
                            local categoryDb = ItemDatabase[slotState.Category]
                            local itemUuids = categoryDb and categoryDb[slotState.CleanName]
                            
                            if itemUuids and #itemUuids > 0 then
                                failCount = 0
                                local targetUUID = itemUuids[1] 
                                
                                local success, resultOrErr = pcall(function()
                                    return SellRemote:InvokeServer("Booth", slotState.Category, targetUUID, slotState.Price)
                                end)

                                if success then
                                    -- ITEM BERHASIL DIPASANG
                                    
                                    -- 1. Equip Item (Request User)
                                    -- Kita equip item yang BARU SAJA dipasang ke booth
                                    if EquipRemote and slotState.Category == "Fish" then
                                        pcall(function()
                                            EquipRemote:FireServer(targetUUID, "Fish")
                                            print("[Slot " .. slotNumber .. "] Equipped: " .. targetUUID)
                                        end)
                                    end

                                    -- 2. Remove UUID dari cache local agar tidak dijual 2x
                                    table.remove(itemUuids, 1)
                                    
                                    -- 3. Tunggu sebentar agar server update
                                    task.wait(1) 
                                else
                                    table.remove(itemUuids, 1) 
                                    task.wait(1.5) 
                                end
                            else
                                task.wait(2)
                                local inv = Data:Get({ "Inventory" })
                                local foundNew = false
                                if typeof(inv) == "table" then
                                    for category, items in pairs(inv) do
                                        if typeof(items) == "table" then
                                            for _, item in ipairs(items) do
                                                local ok, data = pcall(function() return ItemUtility.GetItemDataFromItemType(category, item.Id) end)
                                                if ok and data and data.Data then
                                                    local name = getDisplayName(item, data)
                                                    if name == slotState.CleanName then
                                                        local isCached = false
                                                        for _, cachedUuid in ipairs(itemUuids or {}) do
                                                            if cachedUuid == item.UUID then isCached = true break end
                                                        end
                                                        
                                                        if not isCached then
                                                            if not ItemDatabase[slotState.Category][slotState.CleanName] then
                                                                ItemDatabase[slotState.Category][slotState.CleanName] = {}
                                                            end
                                                            table.insert(ItemDatabase[slotState.Category][slotState.CleanName], item.UUID)
                                                            foundNew = true
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end

                                if not foundNew then
                                    failCount = failCount + 1
                                    if failCount >= MAX_FAIL then
                                        WindUI:Notify({ Title = "Slot " .. slotNumber .. " Habis", Content = slotState.CleanName .. " benar-benar habis di inventory." })
                                        SellToggle:Set(false)
                                        break
                                    end
                                end
                            end
                        end
                        task.wait(0.3) 
                    end
                end)
            else
                print("[SLOT " .. slotNumber .. "] Berhenti jual.")
            end
        end
    })
    
    SlotUIReferences[slotNumber] = { 
        State = slotState, 
        ItemDropdown = ItemDropdown, 
        CategoryDropdown = CategoryDropdown, 
        PriceInput = PriceInput, 
        Toggle = SellToggle 
    }
end

-- ═══════════════════════════════════════════
-- EKSEKUSI 4 SLOT & LOAD SETTINGAN
-- ═══════════════════════════════════════════
for i = 1, 4 do createSlot(i) end

task.wait(1)
loadSettings()

-- ═══════════════════════════════════════════════════════════════════════
-- VISUAL TOGGLE SYSTEM
-- ═══════════════════════════════════════════════════════════════════════

local visualState = false
local VisualOnPath = nil 
local VisualOffPath = nil 

task.spawn(function()
    local Controller = ReplicatedStorage:FindFirstChild("Controllers", true):FindFirstChild("BackpackController")
    
    if Controller then
        local success, module = pcall(require, Controller)
        if success and module and module.ToolbarInput then
            local ok1, val1 = pcall(function() return debug.getupvalue(module.ToolbarInput, 1) end)
            local ok2, val2 = pcall(function() return debug.getupvalue(module.ToolbarInput, 2) end)
            
            VisualOffPath = val1 
            VisualOnPath = val2
            
            if VisualOnPath then print("CyrusStore: Visual Loop Ready") end
            if VisualOffPath then print("CyrusStore: Visual Stop Ready") end
        end
    end
end)

local currentVisual = 2

local VisualToggle = BoothTab:Toggle({
    Title = "👁️ VISUAL (LOOP)",
    Value = false,
    Callback = function(Value)
        visualState = Value

        if not Value then
            currentVisual = 2

            if VisualOffPath then
                pcall(function()
                    VisualOffPath:FireServer()
                end)
            end
        else
            print("Visual ON")
        end
    end
})

task.spawn(function()
    while true do
        if visualState then
            if VisualOnPath then
                pcall(function()
                    VisualOnPath:FireServer(currentVisual)
                end)
            end

            currentVisual = currentVisual + 1

            if currentVisual > 5 then
                currentVisual = 2
            end

            for i = 1, 10 do
                task.wait(1)
                if not visualState then
                    break
                end
            end
        else
            task.wait(1)
        end
    end
end)

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
            for slotNum, ref in pairs(SlotUIReferences) do
                if ref and ref.State and ref.State.IsSelling then
                    ref.State.IsSelling = false
                    if ref.Toggle then
                        task.defer(function() ref.Toggle:Set(false) end)
                    end
                end
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
            refreshGlobalCache()
            ClearBoothToggle:Set(false)
        end
    end
})
