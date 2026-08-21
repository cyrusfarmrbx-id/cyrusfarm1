local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Replion = require(ReplicatedStorage.Packages.Replion)
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)

-- Membuat UI ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "LockDetailUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Frame Utama
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 320)
mainFrame.Position = UDim2.new(0, 15, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(80, 80, 80)
mainStroke.Thickness = 1.5

-- Header / Judul
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
header.BorderSizePixel = 0
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Loading Data..."
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

-- Scrolling Frame (Untuk list item yang bisa di-scroll)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -16, 1, -50)
scrollFrame.Position = UDim2.new(0, 8, 0, 45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Fungsi untuk membuat baris item baru
local function createItemRow(text, order)
    local row = Instance.new("TextLabel")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    row.BorderSizePixel = 0
    row.Text = "  • " .. text
    row.TextColor3 = Color3.fromRGB(200, 200, 200)
    row.Font = Enum.Font.Gotham
    row.TextSize = 13
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.LayoutOrder = order
    row.Parent = scrollFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
    return row
end

-- Tombol Close (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Proses Menghitung dan Mencari Nama Item di Background
task.spawn(function()
    local Data = Replion.Client:WaitReplion("Data")
    local Inventory = Data:Get("Inventory")
    
    local lockedCount = 0
    local lockedItemsData = {}

    for category, items in pairs(Inventory or {}) do
        if typeof(items) == "table" then
            for _, item in ipairs(items) do
                if item.TradeLock or (item.Metadata and item.Metadata.TradeLock) or item.TradeLocked then
                    lockedCount = lockedCount + 1
                    
                    -- Cari nama item berdasarkan kategori dan ID
                    local itemName = "Unknown Item"
                    local success, err = pcall(function()
                        local itemInfo = ItemUtility.GetItemDataFromItemType(category, item.Id)
                        if itemInfo and itemInfo.Data then
                            itemName = itemInfo.Data.Name
                        end
                    end)

                    -- Hitung jumlah jika nama itemnya sama (misal: 3x Blob Shark)
                    if lockedItemsData[itemName] then
                        lockedItemsData[itemName] = lockedItemsData[itemName] + 1
                    else
                        lockedItemsData[itemName] = 1
                    end
                end
            end
        end
    end

    -- Update Judul
    titleLabel.Text = "Locked Items: " .. lockedCount

    -- Masukkan hasilnya ke UI
    if lockedCount == 0 then
        createItemRow("Tidak ada item ter-lock!", 1)
    else
        local order = 1
        for name, count in pairs(lockedItemsData) do
            local displayText = name .. " : " .. count
            createItemRow(displayText, order)
            order = order + 1
        end
    end
end)
