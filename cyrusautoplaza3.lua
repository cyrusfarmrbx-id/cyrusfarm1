------------------------------------------------
-- CHECKPOINT TRADE PLAZA
------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserPriority = require(ReplicatedStorage.Shared.UserPriority)

if not UserPriority:IsTradePlaza() then
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    rootPart.CFrame = CFrame.new(-39, 10, 2805)
    task.wait(0.5)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local textCheck = (obj.Name .. " " .. obj.ActionText):lower()
            if textCheck:find("teleporter") or textCheck:find("go to plaza") or textCheck:find("plaza") then
                obj:InputHoldBegin()
                task.wait(0.2)
                obj:InputHoldEnd()
                break
            end
        end
    end
    return
end

------------------------------------------------
-- SERVICES
------------------------------------------------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local myId = LocalPlayer.UserId
local camera = workspace.CurrentCamera

------------------------------------------------
-- BLUR SYSTEM
------------------------------------------------
local locked = false 

local blurEffect = Lighting:FindFirstChild("FarmBlur")
if blurEffect then blurEffect:Destroy() end
blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "FarmBlur"
blurEffect.Size = 56
blurEffect.Enabled = false
blurEffect.Parent = Lighting

task.spawn(function()
    while task.wait() do
        if locked then
            if not blurEffect or not blurEffect.Parent then
                blurEffect = Instance.new("BlurEffect")
                blurEffect.Name = "FarmBlur"
                blurEffect.Size = 56
                blurEffect.Parent = Lighting
            end
            blurEffect.Enabled = true
            blurEffect.Size = 56
        else
            if blurEffect then blurEffect.Enabled = false end
        end
    end
end)

------------------------------------------------
-- CONNECTIONS
------------------------------------------------
local notifConn = nil
local fishConn = nil
local camConn = nil
local dlConn = nil
local playerConn = nil

------------------------------------------------
-- NOTIFIKASI SELLER (CHAT)
------------------------------------------------
local function Notify(title, msg)
    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "["..title.."] "..msg,
            Color = Color3.fromRGB(0, 255, 0),
            Font = Enum.Font.GothamBold,
        })
    end)
    print("["..title.."] "..msg)
end

------------------------------------------------
-- CLEAR TEXT & PETIR (NOL DELAY)
------------------------------------------------
local function clearTextAndLightning(obj)
    if obj.Name == "TextEffectAttachment" then obj:Destroy(); return end
    local name = obj.Name:lower()
    if name == "boltpart" or name == "lightningbolt" or string.find(name, "lightning") or string.find(name, "bolt") then
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj.Enabled = false end
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then obj.Transparency = 1; obj.CastShadow = false end
        task.spawn(function() pcall(function() obj:Destroy() end) end)
    end
end

------------------------------------------------
-- CLEAR IKAN (KHUSUS COSMETIC FOLDER)
------------------------------------------------
local function clearFish(obj)
    if obj:IsA("Model") then
        local lowerName = obj.Name:lower()
        local isTarget = obj:FindFirstChild("Handle") or string.find(lowerName, "fish") or string.find(lowerName, "shark")
        if isTarget then
            for _, v in pairs(obj:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") then v.Transparency = 1; v.CanCollide = false end
                if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
            end
            task.delay(1, function() pcall(function() obj:Destroy() end) end)
        end
    end
end

------------------------------------------------
-- UI LOCK SYSTEM
------------------------------------------------
local savedStates = {}
local guardConns = {}
local blacklist = {
    ["Blackout"] = true, ["PurchaseScreenBlackout"] = true, ["CutsceneDialogue"] = true,
    ["Freecam"] = true, ["CyrusFarmGui"] = true, ["LoaderUI"] = true
}

local function kunciUI(pg)
    savedStates = {}
    for _, c in pairs(guardConns) do c:Disconnect() end
    guardConns = {}
    for _, gui in pairs(pg:GetChildren()) do
        if gui:IsA("ScreenGui") and not blacklist[gui.Name] then
            savedStates[gui] = gui.Enabled
            gui.Enabled = false
            local conn = gui:GetPropertyChangedSignal("Enabled"):Connect(function()
                if locked and gui.Enabled then gui.Enabled = false end
            end)
            table.insert(guardConns, conn)
        end
    end
    local childConn = pg.ChildAdded:Connect(function(child)
        task.wait(0.1)
        if child:IsA("ScreenGui") and not blacklist[child.Name] then
            savedStates[child] = child.Enabled
            child.Enabled = false
            local conn = child:GetPropertyChangedSignal("Enabled"):Connect(function()
                if locked and child.Enabled then child.Enabled = false end
            end)
            table.insert(guardConns, conn)
        end
    end)
    table.insert(guardConns, childConn)
end

local function bukaUI()
    for _, c in pairs(guardConns) do c:Disconnect() end
    guardConns = {}
    for gui, state in pairs(savedStates) do
        if gui and gui.Parent then gui.Enabled = state end
    end
    savedStates = {}
end

------------------------------------------------
-- FPP CAMERA
------------------------------------------------
local function toggleFPP(state)
    if state then
        camera.CameraType = Enum.CameraType.Scriptable
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        UIS.MouseIconEnabled = true
        camConn = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                if rootPart and head then
                    local heightOffset = (head.Position - rootPart.Position).Y
                    camera.CFrame = rootPart.CFrame * CFrame.new(0, heightOffset, 0)
                end
            end
            if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
        end)
    else
        if camConn then camConn:Disconnect(); camConn = nil end
        camera.CameraType = Enum.CameraType.Custom
    end
end

------------------------------------------------
-- FARM MODE UI
------------------------------------------------
local farmGui = Instance.new("ScreenGui")
farmGui.Name = "LoaderUI"
farmGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
farmGui.ResetOnSpawn = false
farmGui.Enabled = false

local FM_Main = Instance.new("Frame")
FM_Main.Parent = farmGui
FM_Main.Size = UDim2.new(0.25, 0, 0.22, 0)
FM_Main.Position = UDim2.new(0.5, 0, 0.42, 0)
FM_Main.AnchorPoint = Vector2.new(0.5, 0.5)
FM_Main.BackgroundTransparency = 1
FM_Main.Active = true
FM_Main.Draggable = true
Instance.new("UICorner", FM_Main).CornerRadius = UDim.new(0, 14)

local FM_constraint = Instance.new("UISizeConstraint", FM_Main)
FM_constraint.MinSize = Vector2.new(220, 160)
FM_constraint.MaxSize = Vector2.new(320, 220)

local FM_padding = Instance.new("UIPadding", FM_Main)
FM_padding.PaddingTop = UDim.new(0, 10)
FM_padding.PaddingBottom = UDim.new(0, 10)
FM_padding.PaddingLeft = UDim.new(0, 14)
FM_padding.PaddingRight = UDim.new(0, 14)

local FM_Container = Instance.new("Frame", FM_Main)
FM_Container.Size = UDim2.new(1,0,1,0)
FM_Container.BackgroundTransparency = 1

local FM_Layout = Instance.new("UIListLayout", FM_Container)
FM_Layout.Padding = UDim.new(0,8)
FM_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FM_Layout.VerticalAlignment = Enum.VerticalAlignment.Center

local FM_TopStats = Instance.new("Frame", FM_Container)
FM_TopStats.Size = UDim2.new(1,0,0,42)
FM_TopStats.BackgroundTransparency = 1

local FM_topLayout = Instance.new("UIListLayout", FM_TopStats)
FM_topLayout.FillDirection = Enum.FillDirection.Horizontal
FM_topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FM_topLayout.Padding = UDim.new(0,12)

local function FM_createTextStat(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = parent
    lbl.Size = UDim2.new(0.3, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.GothamBold
    return lbl
end

local PingText = FM_createTextStat(FM_TopStats, "PING")
local FpsText = FM_createTextStat(FM_TopStats, "FPS")
local CpuText = FM_createTextStat(FM_TopStats, "CPU")

local TokenBox = Instance.new("Frame", FM_Container)
TokenBox.Size = UDim2.new(0.92,0,0,35)
TokenBox.BackgroundTransparency = 1
Instance.new("UICorner", TokenBox).CornerRadius = UDim.new(0,10)

local TokenText = Instance.new("TextLabel", TokenBox)
TokenText.Size = UDim2.new(1,0,1,0)
TokenText.BackgroundTransparency = 1
TokenText.Text = "0"
TokenText.TextColor3 = Color3.fromRGB(255, 255, 255)
TokenText.TextSize = 28
TokenText.Font = Enum.Font.GothamBold
TokenText.TextXAlignment = Enum.TextXAlignment.Center
TokenText.Position = UDim2.new(0, 0, 0, -8)

local ExitButton = Instance.new("TextButton", FM_Container)
ExitButton.Size = UDim2.new(0.92,0,0,28)
ExitButton.Text = "EXIT AUTO BOOTH"
ExitButton.TextSize = 16
ExitButton.Font = Enum.Font.GothamBold
ExitButton.TextColor3 = Color3.fromRGB(255,255,255)
ExitButton.BackgroundColor3 = Color3.fromRGB(180,50,50)
Instance.new("UICorner", ExitButton).CornerRadius = UDim.new(0,10)

local acc = 0
RunService.RenderStepped:Connect(function(delta)
    acc += delta
    if acc >= 0.5 then
        acc = 0
        pcall(function()
            local fps = math.floor(1 / delta)
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            local cpu = math.clamp(math.floor(delta * 1200), 1, 100)
            PingText.Text = ping .. " MS"
            CpuText.Text = cpu .. " MS"
            FpsText.Text = fps .. " FPS"
            if ping <= 50 then PingText.TextColor3 = Color3.fromRGB(80,255,80) elseif ping <= 100 then PingText.TextColor3 = Color3.fromRGB(255,255,0) else PingText.TextColor3 = Color3.fromRGB(255,80,80) end
            if cpu <= 35 then CpuText.TextColor3 = Color3.fromRGB(80,255,80) elseif cpu <= 70 then CpuText.TextColor3 = Color3.fromRGB(255,255,0) else CpuText.TextColor3 = Color3.fromRGB(255,80,80) end
            if fps >= 50 then FpsText.TextColor3 = Color3.fromRGB(80,255,80) elseif fps >= 30 then FpsText.TextColor3 = Color3.fromRGB(255,255,0) else FpsText.TextColor3 = Color3.fromRGB(255,80,80) end
        end)
    end
end)

------------------------------------------------
-- FLOATING BUTTON (KIRI)
------------------------------------------------
local floatingGui = Instance.new("ScreenGui")
floatingGui.Name = "CyrusFarmGui"
floatingGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
floatingGui.ResetOnSpawn = false
floatingGui.Enabled = false

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 44, 0, 44)
FloatBtn.Position = UDim2.new(0, 12, 0.5, -22)
FloatBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
FloatBtn.Text = "🐟"
FloatBtn.TextSize = 22
FloatBtn.Parent = floatingGui
FloatBtn.AutoButtonColor = true

local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Thickness = 2
FloatStroke.Color = Color3.fromRGB(255,0,0)
FloatStroke.Transparency = 0.1

Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

------------------------------------------------
-- TELEPORT TO TARGET SYSTEM
------------------------------------------------
local function teleportToTarget(TargetCF)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not character then
        return false
    end

    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    if not hrp then
        return false
    end

    character:PivotTo(TargetCF)
    return true
end

------------------------------------------------
-- FARM MODE FUNCTIONS
------------------------------------------------
local function EnableFarmMode()
    locked = true
    blurEffect.Enabled = true; blurEffect.Size = 56
    kunciUI(LocalPlayer.PlayerGui)
    toggleFPP(true)
    
    local CharactersFolder = Workspace:FindFirstChild("Characters")
    if CharactersFolder then
        for _, charModel in ipairs(CharactersFolder:GetChildren()) do
            if charModel:IsA("Model") and charModel ~= LocalPlayer.Character then
                charModel:Destroy()
            end
        end
        playerConn = CharactersFolder.ChildAdded:Connect(function(charModel)
            if charModel:IsA("Model") and charModel ~= LocalPlayer.Character then
                charModel:Destroy()
            end
        end)
    end
    
    for _, v in pairs(workspace:GetDescendants()) do clearTextAndLightning(v) end
    local cf = workspace:FindFirstChild("CosmeticFolder")
    if cf then for _, v in pairs(cf:GetDescendants()) do clearFish(v) end end

    notifConn = workspace.DescendantAdded:Connect(clearTextAndLightning)
    if cf then fishConn = cf.DescendantAdded:Connect(clearFish) end
    
    farmGui.Enabled = true
    floatingGui.Enabled = false
end

local function DisableFarmMode()
    locked = false
    blurEffect.Enabled = false
    bukaUI()
    toggleFPP(false)
    
    if playerConn then playerConn:Disconnect(); playerConn = nil end
    if notifConn then notifConn:Disconnect(); notifConn = nil end
    if fishConn then fishConn:Disconnect(); fishConn = nil end
    if dlConn then dlConn:Disconnect(); dlConn = nil end
    
    farmGui.Enabled = false
    floatingGui.Enabled = true
end

ExitButton.MouseButton1Click:Connect(function()
    DisableFarmMode()
end)

FloatBtn.MouseButton1Click:Connect(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local dl = pg and pg:FindFirstChild("!!! Daily Login")
    local dlGuiControl = nil
    pcall(function() dlGuiControl = require(ReplicatedStorage.Modules.GuiControl) end)
    
    EnableFarmMode()
    
    if dl then
        local function autoClose()
            if dlGuiControl then
                pcall(function() dlGuiControl:Close(true) end)
                pcall(function() dlGuiControl:Unlock() end)
            end
            dl.Enabled = false
        end
        if dl.Enabled then autoClose() end
        dlConn = dl:GetPropertyChangedSignal("Enabled"):Connect(function()
            if dl.Enabled then autoClose() end
        end)
    end
end)

------------------------------------------------
-- AUTO SELLER CONFIG & SYSTEM
------------------------------------------------
local BoothCFs = {
    CFrame.new(-1111.115966796875, 18.9910888671875, 2800.157470703125, -0.499873161, 0, 0.866098642, 0, 1, 0, -0.866098642, 0, -0.499873161),
    CFrame.new(-1105.117919921875, 18.9910888671875, 2810.55078125, -0.499873161, 0, 0.866098642, 0, 1, 0, -0.866098642, 0, -0.499873161),
    CFrame.new(-1099.119873046875, 18.9910888671875, 2820.9443359375, -0.499873161, 0, 0.866098642, 0, 1, 0, -0.866098642, 0, -0.499873161),
    CFrame.new(-1093.1217041015625, 18.9910888671875, 2831.337890625, -0.499873161, 0, 0.866098642, 0, 1, 0, -0.866098642, 0, -0.499873161),
    CFrame.new(-1176.853271484375, 18.9910888671875, 2800.1572265625, -0.499873161, 0, 0.866098642, 0, 1, 0, -0.866098642, 0, -0.499873161),
    CFrame.new(-1182.851318359375, 18.9910888671875, 2810.55078125, -0.499873161, 0, 0.866098642, 0, 1, 0, -0.866098642, 0, -0.499873161),
    CFrame.new(-1188.849365234375, 18.9910888671875, 2820.9443359375, -0.499873161, 0, 0.866098642, 0, 1, 0, -0.866098642, 0, -0.499873161),
    CFrame.new(-1194.8472900390625, 18.9910888671875, 2831.337646484375, -0.499873161, 0, 0.866098642, 0, 1, 0, -0.866098642, 0, -0.499873161)
}

local BLACKLIST_IDS = {
    10849334132, 10757298410, 10762189210, 10757278851, 10762153032, 11098889630, 9684028951, 9709193019, 9709047584, 9709050799, 9709105383, 9709099089, 9709062371, 9709069006
}

local AutoSetConfig = {
    [158] = { Name = "King Crab", Price = 2 },
    [187] = { Name = "Queen Crab", Price = 2 },
    [82]  = { Name = "Blob Shark", Price = 2 },
    [83]  = { Name = "Ghost Shark", Price = 2 },
    [359] = { Name = "Gladiator Shark", Price = 2 },
    [339] = { Name = "Skeleton Narwhal", Price = 2 },
    [269] = { Name = "Elshark Gran Maja", Price = 6 },
    [145] = { Name = "Worm Fish", Price = 4 },
    [661] = { Name = "Elpirate Gran Maja", Price = 16 },
    [243] = { Name = "Ruby", Price = 91 },
    [226] = { Name = "Megalodon", Price = 223 },
    [228] = { Name = "Lochness Monster", Price = 711 },
    [833] = { Name = "Bonemaw Tyrant", Price = 6 },
    [882] = { Name = "Deepsea Monster Axol", Price = 11 },
    [864] = { Name = "Strawberry Orca", Price = 52 },
    [927] = { Name = "Aurelion", Price = 31 },
    [589] = { Name = "Cursed Kraken", Price = 51 },
    [5] = { Name = "Winged Halo", Price = 51 },
    [558] = { Name = "Evolved Enchant Stone", Price = 2 },
    [873] = { Name = "Eggy Enchant Stone", Price = 61 },
    [929] = { Name = "Runic Enchant Stone", Price = 51 },
}

-- ================= LOAD LIBRARY & SYSTEM =================
task.spawn(function()
    Notify("SYSTEM", "Loading Library...")
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    local Net = require(Packages:WaitForChild("Net"))
    local Replion = require(Packages:WaitForChild("Replion"))
    local TradeData = require(ReplicatedStorage.Shared.Trading.TradeData)
    local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)

    Notify("SYSTEM", "Loading Data...")
    local Data = nil
    local startTime = tick()
    repeat
        task.wait(0.5)
        local ok = pcall(function() Data = Replion.Client:GetReplion("Data") end)
        if ok and Data then break end
    until (tick() - startTime) > 15 

    if not Data then
        Notify("ERROR", "Gagal Load Data!")
        return
    end

    local ServerBrowserData = Replion.Client:GetReplion("ServerBrowser")
    local RemoteConfigs = Replion.Client:GetReplion("RemoteConfigs")
    local SaleListingsReplion = Replion.Client:GetReplion("SaleListings")
    local SellRemote = TradeData.Remotes.CreateSaleListing
    local DeleteRemote = TradeData.Remotes.DeleteSaleListing
    local MyBoothPath = {"Players", tostring(myId), "Booth"}

    local initialTokens = Data:Get("Tokens")
    if typeof(initialTokens) == "number" then
        TokenText.Text = tostring(initialTokens)
    end
    Data:OnChange("Tokens", function(TokenBaru)
        if typeof(TokenBaru) == "number" then
            TokenText.Text = tostring(TokenBaru)
        end
    end)

    Notify("SYSTEM", "Data Siap. Memulai Seller...")
    
    local function doServerHop()
        Notify("HOP", "Mencari server sepi (Max 10 pemain)...")
        local startTick = tick()
        repeat task.wait(0.5) until (ServerBrowserData.Data.Servers and next(ServerBrowserData.Data.Servers) ~= nil) or (tick() - startTick > 10)
        
        if not ServerBrowserData.Data.Servers then 
            Notify("HOP", "Gagal load daftar server, coba fallback...")
            pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId) end)
            return false 
        end
        
        local servers = ServerBrowserData.Data.Servers
        local EligibleServers = {}
        
        for jobId, data in pairs(servers) do
            if jobId == game.JobId then continue end
            
            local count = 0
            if typeof(data) == "table" then
                count = tonumber(data.Players) or 0
            end
            
            if count <= 10 then
                table.insert(EligibleServers, jobId)
            end
        end
        
        if #EligibleServers > 0 then
            local targetJobId = EligibleServers[math.random(1, #EligibleServers)]
            Notify("HOP", "Pindah ke server random sepi.")
            task.wait(2)
            pcall(function()
                local isServerHopEnabled = false
                pcall(function() isServerHopEnabled = RemoteConfigs:Get("ServerBrowser") end)
                
                if isServerHopEnabled == true then
                    Net:RemoteEvent("ServerHop"):FireServer(targetJobId)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId)
                end
            end)
            return true
        else
            Notify("HOP", "Tidak ada server dengan <= 5 pemain.")
        end
        
        return false
    end

    local ItemDatabase = {} 
    local AutoSetState = { IsRunning = false }

    local function refreshGlobalCache()
        local inv = Data:Get({ "Inventory" })
        if typeof(inv) ~= "table" then return end
        ItemDatabase = {}
        for category, items in pairs(inv) do
            if typeof(items) == "table" then
                for _, v in ipairs(items) do
                    if AutoSetConfig[v.Id] then
                        local ok, data = pcall(function() return ItemUtility.GetItemDataFromItemType(category, v.Id) end)
                        if ok and data and data.Data and data.Data.Type then
                            local t = data.Data.Type
                            local configName = AutoSetConfig[v.Id].Name
                            if not ItemDatabase[t] then ItemDatabase[t] = {} end
                            if not ItemDatabase[t][configName] then ItemDatabase[t][configName] = {} end
                            table.insert(ItemDatabase[t][configName], {
                                UUID = v.UUID,
                                Category = t,
                                Price = AutoSetConfig[v.Id].Price
                            })
                        end
                    end
                end
            end
        end
    end

    local function isItemNameListed(itemName)
        local listings = SaleListingsReplion:Get(MyBoothPath)
        if typeof(listings) ~= "table" then return false end
        for _, listing in pairs(listings) do
            if listing and listing.Item then
                local ok, data = pcall(function() return ItemUtility.GetItemDataFromItemType(listing.ItemType, listing.Item.Id) end)
                if ok and data and data.Data and data.Data.Name == itemName then
                    return true
                end
            end
        end
        return false
    end

    local function clearAllBoothItems()
        local listings = SaleListingsReplion:Get(MyBoothPath)
        if typeof(listings) ~= "table" or next(listings) == nil then return end
        for listingId, _ in pairs(listings) do
            pcall(function() DeleteRemote:InvokeServer("Booth", listingId) end)
            task.wait(0.3)
        end
    end

    local function startAutoSelling()
        if AutoSetState.IsRunning then return end
        AutoSetState.IsRunning = true
        Notify("SELL", "Scan & Simpan UUID...")
        refreshGlobalCache() 
        Notify("SELL", "Auto Selling DIMULAI (Parallel)!")
        
        for configId, configData in pairs(AutoSetConfig) do
            task.spawn(function()
                local itemFailCount = 0
                local MAX_FAIL = 3
                while AutoSetState.IsRunning do
                    local isListed = isItemNameListed(configData.Name)
                    if isListed then
                        itemFailCount = 0
                        task.wait(0.5)
                    else
                        local targetUUIDData = nil
                        for catType, items in pairs(ItemDatabase) do
                            if items[configData.Name] and #items[configData.Name] > 0 then
                                targetUUIDData = table.remove(items[configData.Name], 1)
                                break
                            end
                        end
                        if targetUUIDData then
                            itemFailCount = 0
                            pcall(function() SellRemote:InvokeServer("Booth", targetUUIDData.Category, targetUUIDData.UUID, targetUUIDData.Price) end)
                            local confirmWait = 0
                            while AutoSetState.IsRunning and not isItemNameListed(configData.Name) and confirmWait < 0.3 do
                                task.wait(0.1)
                                confirmWait += 0.1
                            end
                        else
                            task.wait(0.5)
                            local inv = Data:Get({ "Inventory" })
                            local foundNew = false
                            if typeof(inv) == "table" then
                                for category, items in pairs(inv) do
                                    if typeof(items) == "table" then
                                        for _, item in ipairs(items) do
                                            if item.Id == configId then
                                                local ok, data = pcall(function() return ItemUtility.GetItemDataFromItemType(category, item.Id) end)
                                                if ok and data and data.Data and data.Data.Name == configData.Name then
                                                    local t = data.Data.Type
                                                    if not ItemDatabase[t] then ItemDatabase[t] = {} end
                                                    if not ItemDatabase[t][configData.Name] then ItemDatabase[t][configData.Name] = {} end
                                                    table.insert(ItemDatabase[t][configData.Name], {
                                                        UUID = item.UUID,
                                                        Category = t,
                                                        Price = configData.Price
                                                    })
                                                    foundNew = true
                                                    break
                                                end
                                            end
                                        end
                                        if foundNew then break end
                                    end
                                end
                            end
                            if not foundNew then
                                itemFailCount = itemFailCount + 1
                                if itemFailCount >= MAX_FAIL then
                                    Notify("SELL", configData.Name .. " habis.")
                                    break
                                end
                            else
                                itemFailCount = 0
                            end
                        end
                    end
                end
            end)
        end
    end

    -- ================= MAIN LOOP =================
    pcall(function()
        repeat task.wait(0.5) until typeof(Data:Get({ "Inventory" })) == "table"
        Notify("SYSTEM", "Cek Blacklist...")
        task.wait(2)
        
        local foundTarget = false
        for _, player in ipairs(Players:GetPlayers()) do
            if player.UserId ~= myId then
                for _, id in ipairs(BLACKLIST_IDS) do
                    if player.UserId == id then
                        foundTarget = true
                        break
                    end
                end
            end
            if foundTarget then break end
        end
        
        if foundTarget then
            Notify("BLOCK", "Ada akun lain! HOP!")
            task.wait(3)
            doServerHop()
        else
            Notify("SAFE", "Deteksi Booth Sekali Jalan...")
            
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            
            local boothKosong = {}
            local sudahPunyaBooth = false

            for i, boothCF in ipairs(BoothCFs) do
                local closestBoothModel = nil
                local shortestDist = math.huge
                
                for _, booth in ipairs(Workspace:GetDescendants()) do
                    if booth:IsA("Model") and booth.Name == "Booth" then
                        local dist = (booth:GetPivot().Position - boothCF.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closestBoothModel = booth
                        end
                    end
                end
                
                if closestBoothModel then
                    local owner = closestBoothModel:GetAttribute("Owner")
                    if owner == myId then
                        sudahPunyaBooth = true
                        break
                    elseif owner == 0 or owner == nil then
                        table.insert(boothKosong, {Index = i, CF = boothCF, Model = closestBoothModel})
                    end
                end
            end

            if sudahPunyaBooth then
                Notify("SUCCESS", "Kamu Sudah Punya Booth! Setup...")
                clearAllBoothItems()
                startAutoSelling()
            elseif #boothKosong > 0 then
                Notify("BOOTH", "Menemukan Booth Kosong, Teleport...")
                local targetBooth = boothKosong[1]
                local posisiMendarat = targetBooth.CF * CFrame.new(0, 0, 4)
                
                -- TELEPORT KE BOOTH
                teleportToTarget(posisiMendarat)
                task.wait(1)
                
                local prompt = targetBooth.Model:FindFirstChild("ProximityPrompt", true)
                if prompt and prompt.ActionText == "Claim Booth" then
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    else
                        keypress(0x45) task.wait(0.1) keyrelease(0x45)
                    end
                    
                    task.wait(1)
                    Notify("SUCCESS", "Booth Diambil! Setup...")
                    clearAllBoothItems()
                    startAutoSelling()
                else
                    Notify("FULL", "Booth tidak bisa diambil, HOP...")
                    doServerHop()
                end
            else
                Notify("FULL", "Semua booth penuh, HOP...")
                doServerHop()
            end
        end
    end)
end)

------------------------------------------------
-- AUTO START FARM MODE
------------------------------------------------
task.spawn(function()
    task.wait(0.5)
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local dl = pg and pg:FindFirstChild("!!! Daily Login")
    local dlGuiControl = nil
    pcall(function() dlGuiControl = require(ReplicatedStorage.Modules.GuiControl) end)
    
    EnableFarmMode()
    
    if dl then
        local function autoClose()
            if dlGuiControl then
                pcall(function() dlGuiControl:Close(true) end)
                pcall(function() dlGuiControl:Unlock() end)
            end
            dl.Enabled = false
        end
        if dl.Enabled then autoClose() end
        dlConn = dl:GetPropertyChangedSignal("Enabled"):Connect(function()
            if dl.Enabled then autoClose() end
        end)
    end
end)
