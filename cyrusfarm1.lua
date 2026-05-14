------------------------------------------------
-- SERVICES
------------------------------------------------
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

------------------------------------------------
-- FARM MODE SYSTEM (BLUR, NOTIF, IKAN, DAILY, UI, FPP)
------------------------------------------------
local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "FarmBlur"
blurEffect.Size = 35 -- 70% Blur
blurEffect.Enabled = false
blurEffect.Parent = game.Lighting

-- 1. NOTIF (TEKS PERFECT)
local fx = workspace:WaitForChild("!!! EFFECTS", 10)
local notifConn = nil
local function clearText(obj)
    if obj.Name == "TextEffectAttachment" then obj:Destroy() end
end

-- 2. HAPUS IKAN DAN PETIR
local cf = workspace:WaitForChild("CosmeticFolder", 10)
local fishConn = nil
local function clearLag(obj)
    if obj:IsA("Model") then
        if obj:FindFirstChild("Handle") or obj.Name == "LightningBolt" then
            for _, v in pairs(obj:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") then v.Transparency = 1 end
            end
            task.delay(1, function() pcall(function() obj:Destroy() end) end)
        end
    elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then
        obj.Transparency = 1
    end
end

-- 3. DAILY LOGIN
local pg = LocalPlayer.PlayerGui
local dl = pg:WaitForChild("!!! Daily Login", 10)
local GuiControl = require(ReplicatedStorage.Modules.GuiControl)
local dlConn = nil
local function autoClose()
    pcall(function() GuiControl:Close(true) end)
    pcall(function() GuiControl:Unlock() end)
    dl.Enabled = false
end

-- 4. HIDE ALL GUI
local locked = false
local savedStates = {}
local guardConns = {}
local blacklist = {
    ["Blackout"] = true,
    ["PurchaseScreenBlackout"] = true,
    ["CutsceneDialogue"] = true,
    ["Freecam"] = true,
    ["CyrusFarmGui"] = true,
    ["LoaderUI"] = true
}

local function kunciUI()
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

-- 5. FPP
local fpLocked = false
local camConn = nil
function toggleFPP(state)
    fpLocked = state
    if state then
        camera.CameraType = Enum.CameraType.Scriptable
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        UIS.MouseIconEnabled = true
        camConn = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local head = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")
                if head then
                    local headCFrame = head.CFrame * CFrame.new(0, 0.5, -1)
                    camera.CFrame = headCFrame
                end
            end
            if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then
                UIS.MouseBehavior = Enum.MouseBehavior.Default
            end
        end)
    else
        if camConn then camConn:Disconnect(); camConn = nil end
        camera.CameraType = Enum.CameraType.Custom
    end
end

-- MASTER CONTROL FARM MODE
local isFarmModeActive = false
local function setFarmMode(state)
    isFarmModeActive = state
    
    -- UI Switch
    webhookGui.Enabled = not state
    farmGui.Enabled = state
    
    -- Blur
    blurEffect.Enabled = state
    
    -- FPP
    toggleFPP(state)
    
    -- UI Lock
    locked = state
    if state then kunciUI() else bukaUI() end
    
    -- Logic Toggles
    if state then
        -- Aktifkan Notif
        for _, v in pairs(fx:GetDescendants()) do clearText(v) end
        notifConn = fx.DescendantAdded:Connect(clearText)
        
        -- Aktifkan Hapus Ikan
        for _, v in pairs(cf:GetDescendants()) do clearLag(v) end
        fishConn = cf.DescendantAdded:Connect(clearLag)
        
        -- Aktifkan Daily
        if dl and dl.Enabled then autoClose() end
        dlConn = dl:GetPropertyChangedSignal("Enabled"):Connect(function()
            if dl.Enabled then autoClose() end
        end)
    else
        -- Nonaktifkan semua connections
        if notifConn then notifConn:Disconnect() end
        if fishConn then fishConn:Disconnect() end
        if dlConn then dlConn:Disconnect() end
    end
end

------------------------------------------------
-- 1. FARM MODE LOADER UI (HIDDEN AWAL)
------------------------------------------------
local farmGui = Instance.new("ScreenGui")
farmGui.Name = "LoaderUI"
farmGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
farmGui.ResetOnSpawn = false
farmGui.Enabled = false

local FM_Main = Instance.new("Frame")
FM_Main.Parent = farmGui
FM_Main.Size = UDim2.new(0.32, 0, 0.42, 0)
FM_Main.Position = UDim2.new(0.5, 0, 0.5, 0)
FM_Main.AnchorPoint = Vector2.new(0.5, 0.5)
FM_Main.BackgroundColor3 = Color3.fromRGB(35,35,35)
FM_Main.Active = false
Instance.new("UICorner", FM_Main).CornerRadius = UDim.new(0, 14)

local FM_Stroke = Instance.new("UIStroke", FM_Main)
FM_Stroke.Thickness = 2
FM_Stroke.Color = Color3.fromRGB(255,0,0)
FM_Stroke.Transparency = 0.1

local FM_constraint = Instance.new("UISizeConstraint", FM_Main)
FM_constraint.MinSize = Vector2.new(240, 340)
FM_constraint.MaxSize = Vector2.new(420, 620)

local FM_padding = Instance.new("UIPadding", FM_Main)
FM_padding.PaddingTop = UDim.new(0, 14)
FM_padding.PaddingBottom = UDim.new(0, 14)
FM_padding.PaddingLeft = UDim.new(0, 14)
FM_padding.PaddingRight = UDim.new(0, 14)

local FM_Container = Instance.new("Frame", FM_Main)
FM_Container.Size = UDim2.new(1,0,1,0)
FM_Container.BackgroundTransparency = 1

local FM_Layout = Instance.new("UIListLayout", FM_Container)
FM_Layout.Padding = UDim.new(0,12)
FM_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

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
local CpuText = FM_createTextStat(FM_TopStats, "CPU")
local FpsText = FM_createTextStat(FM_TopStats, "FPS")

local function FM_createCounter(parent, sizeX, defaultText)
    local box = Instance.new("Frame")
    box.Parent = parent
    box.Size = UDim2.new(sizeX, 0, 1, 0)
    box.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,10)
    local txt = Instance.new("TextLabel", box)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Text = defaultText or "0"
    txt.TextColor3 = Color3.fromRGB(255,255,255)
    txt.TextSize = 18
    txt.Font = Enum.Font.GothamBold
    return txt
end

local FM_Row2 = Instance.new("Frame", FM_Container)
FM_Row2.Size = UDim2.new(0.92, 0, 0, 58)
FM_Row2.BackgroundTransparency = 1

local FM_row2Layout = Instance.new("UIListLayout", FM_Row2)
FM_row2Layout.FillDirection = Enum.FillDirection.Horizontal
FM_row2Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FM_row2Layout.VerticalAlignment = Enum.VerticalAlignment.Center
FM_row2Layout.Padding = UDim.new(0,10)

local SingleBox = Instance.new("Frame", FM_Row2)
SingleBox.Size = UDim2.new(1, 0, 1, 0)
SingleBox.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
Instance.new("UICorner", SingleBox).CornerRadius = UDim.new(0,10)

local SingleText = Instance.new("TextLabel", SingleBox)
SingleText.Size = UDim2.new(1, 0, 1, 0)
SingleText.BackgroundTransparency = 1
SingleText.Text = "🐟 STATUS: FISHING NORMAL"
SingleText.TextColor3 = Color3.fromRGB(255,255,255)
SingleText.TextSize = 18
SingleText.Font = Enum.Font.GothamBold

local LastCatchTime = tick()
task.spawn(function()
    while task.wait(1) do
        local elapsed = tick() - LastCatchTime
        if elapsed > 15 then
            SingleText.Text = "⚠️ STUCK / IDLE (" .. math.floor(elapsed) .. "s)"
            SingleBox.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        else
            SingleText.Text = "🐟 STATUS: FISHING NORMAL"
            SingleBox.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        end
    end
end)

local FM_Row3 = Instance.new("Frame", FM_Container)
FM_Row3.Size = UDim2.new(1,0,0,58)
FM_Row3.BackgroundTransparency = 1

local FM_row3Layout = Instance.new("UIListLayout", FM_Row3)
FM_row3Layout.FillDirection = Enum.FillDirection.Horizontal
FM_row3Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FM_row3Layout.VerticalAlignment = Enum.VerticalAlignment.Center
FM_row3Layout.Padding = UDim.new(0,10)

local CountD = FM_createCounter(FM_Row3, 0.45, "0")
local CountE = FM_createCounter(FM_Row3, 0.45, "0")

local CountBox = Instance.new("Frame", FM_Container)
CountBox.Size = UDim2.new(0.92,0,0,58)
CountBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
Instance.new("UICorner", CountBox).CornerRadius = UDim.new(0,10)

local MainCount = Instance.new("TextLabel", CountBox)
MainCount.Size = UDim2.new(1,0,1,0)
MainCount.BackgroundTransparency = 1
MainCount.Text = "Loading..."
MainCount.TextColor3 = Color3.fromRGB(255,255,255)
MainCount.TextSize = 22
MainCount.Font = Enum.Font.GothamBold

local ExitButton = Instance.new("TextButton", FM_Container)
ExitButton.Size = UDim2.new(0.92,0,0,42)
ExitButton.Text = "EXIT FARM MODE"
ExitButton.TextSize = 16
ExitButton.Font = Enum.Font.GothamBold
ExitButton.TextColor3 = Color3.fromRGB(255,255,255)
ExitButton.BackgroundColor3 = Color3.fromRGB(180,50,50)
Instance.new("UICorner", ExitButton).CornerRadius = UDim.new(0,10)

ExitButton.MouseButton1Click:Connect(function()
    setFarmMode(false) -- NONAKTIFKAN SEMUA
end)

local items = { {"Loch Ness Monster", 2}, {"Ruby", 2} }
local index = 1
local elapsed = 0
local switchDelay = 5
local updateDelay = 0.5
local acc = 0

RunService.RenderStepped:Connect(function(delta)
    acc += delta
    elapsed += delta
    if acc >= updateDelay then
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
    if elapsed >= switchDelay then
        elapsed = 0
        index += 1
        if index > #items then index = 1 end
    end
    local item = items[index]
    MainCount.Text = item[1] .. " ( " .. item[2] .. " )"
end)

-- WEBHOOK UI
local webhookGui = Instance.new("ScreenGui")
webhookGui.Name = "CyrusFarmGui"
webhookGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
webhookGui.ResetOnSpawn = false
webhookGui.Enabled = true

local WH_Main = Instance.new("Frame")
WH_Main.Size = UDim2.new(0.25, 0, 0.4, 0)
WH_Main.BackgroundColor3 = Color3.fromRGB(35,35,35)
WH_Main.Parent = webhookGui
WH_Main.Active = true
WH_Main.Draggable = true
WH_Main.AnchorPoint = Vector2.new(0.5, 0.5)
WH_Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Instance.new("UICorner", WH_Main).CornerRadius = UDim.new(0, 12)

local WH_Stroke = Instance.new("UIStroke", WH_Main)
WH_Stroke.Thickness = 2
WH_Stroke.Color = Color3.fromRGB(255,0,0)
WH_Stroke.Transparency = 0.1

local WH_constraint = Instance.new("UISizeConstraint", WH_Main)
WH_constraint.MinSize = Vector2.new(240, 220)
WH_constraint.MaxSize = Vector2.new(360, 320)

local WH_Top = Instance.new("Frame", WH_Main)
WH_Top.Size = UDim2.new(1,0,0,30)
WH_Top.BackgroundColor3 = Color3.fromRGB(25,25,25)
Instance.new("UICorner", WH_Top).CornerRadius = UDim.new(0, 12)
WH_Top.ClipsDescendants = true

local WH_Title = Instance.new("TextLabel", WH_Top)
WH_Title.Size = UDim2.new(1,-100,1,0)
WH_Title.Position = UDim2.new(0,6,0,0)
WH_Title.Text = "CYRUS FARM"
WH_Title.TextColor3 = Color3.fromRGB(255,255,255)
WH_Title.BackgroundTransparency = 1
WH_Title.TextXAlignment = Enum.TextXAlignment.Left
WH_Title.TextSize = 13

local WH_Close = Instance.new("TextButton", WH_Top)
WH_Close.Size = UDim2.new(0,22,0,22)
WH_Close.Position = UDim2.new(1,-28,0.5,-11)
WH_Close.Text = "X"
WH_Close.BackgroundColor3 = Color3.fromRGB(200,50,50)
Instance.new("UICorner", WH_Close).CornerRadius = UDim.new(1,0)
WH_Close.MouseButton1Click:Connect(function() webhookGui:Destroy() farmGui:Destroy() blurEffect:Destroy() end)

local WH_Min = Instance.new("TextButton", WH_Top)
WH_Min.Size = UDim2.new(0,22,0,22)
WH_Min.Position = UDim2.new(1,-56,0.5,-11)
WH_Min.Text = "-"
WH_Min.BackgroundColor3 = Color3.fromRGB(120,120,120)
Instance.new("UICorner", WH_Min).CornerRadius = UDim.new(1,0)

local WH_Content = Instance.new("Frame", WH_Main)
WH_Content.Size = UDim2.new(1,0,1,-30)
WH_Content.Position = UDim2.new(0,0,0,30)
WH_Content.BackgroundTransparency = 1

local WH_Status = Instance.new("TextLabel", WH_Content)
WH_Status.Size = UDim2.new(1,0,0,22)
WH_Status.Position = UDim2.new(0,0,0,8)
WH_Status.Text = "Webhook: ON"
WH_Status.TextColor3 = Color3.fromRGB(80,255,80)
WH_Status.BackgroundTransparency = 1
WH_Status.TextSize = 12

local ToggleBG = Instance.new("Frame", WH_Content)
ToggleBG.Size = UDim2.new(0,130,0,36)
ToggleBG.Position = UDim2.new(0.5,-65,0,40)
ToggleBG.BackgroundColor3 = Color3.fromRGB(60,200,60)
Instance.new("UICorner", ToggleBG).CornerRadius = UDim.new(1,0)

local Circle = Instance.new("Frame", ToggleBG)
Circle.Size = UDim2.new(0,28,0,28)
Circle.Position = UDim2.new(1,-32,0.5,-14)
Circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", Circle).CornerRadius = UDim.new(1,0)

local TrackerEnabled = true
local function setToggle(state)
    TrackerEnabled = state
    if state then
        ToggleBG.BackgroundColor3 = Color3.fromRGB(60,200,60)
        Circle:TweenPosition(UDim2.new(1,-32,0.5,-14), "Out", "Quad", 0.2, true)
        WH_Status.Text = "Webhook: ON"
        WH_Status.TextColor3 = Color3.fromRGB(80,255,80)
    else
        ToggleBG.BackgroundColor3 = Color3.fromRGB(170,170,170)
        Circle:TweenPosition(UDim2.new(0,4,0.5,-14), "Out", "Quad", 0.2, true)
        WH_Status.Text = "Webhook: OFF"
        WH_Status.TextColor3 = Color3.fromRGB(255,80,80)
    end
end

ToggleBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        setToggle(not TrackerEnabled)
    end
end)

local FarmModeBtn = Instance.new("TextButton", WH_Content)
FarmModeBtn.Size = UDim2.new(0,130,0,36)
FarmModeBtn.Position = UDim2.new(0.5,-65,0,85)
FarmModeBtn.Text = "FARM MODE"
FarmModeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
FarmModeBtn.TextColor3 = Color3.fromRGB(255,255,255)
FarmModeBtn.Font = Enum.Font.SourceSansBold
FarmModeBtn.TextSize = 14
Instance.new("UICorner", FarmModeBtn).CornerRadius = UDim.new(0,8)

FarmModeBtn.MouseButton1Click:Connect(function()
    setFarmMode(true) -- AKTIFKAN SEMUA
end)

local Test = Instance.new("TextButton", WH_Content)
Test.Size = UDim2.new(0,130,0,30)
Test.Position = UDim2.new(0.5,-65,0,130)
Test.Text = "TEST WEBHOOK"
Test.BackgroundColor3 = Color3.fromRGB(60,60,60)
Test.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", Test).CornerRadius = UDim.new(0,8)

local Icon = Instance.new("ImageButton")
Icon.Size = UDim2.new(0,38,0,38)
Icon.Position = UDim2.new(0,10,0.5,0)
Icon.BackgroundColor3 = Color3.fromRGB(35,35,35)
Icon.Visible = false
Icon.Parent = webhookGui
Icon.Active = true
Icon.Draggable = true
Instance.new("UICorner", Icon).CornerRadius = UDim.new(0,8)

local IconStroke = Instance.new("UIStroke", Icon)
IconStroke.Thickness = 2
IconStroke.Color = Color3.fromRGB(255,0,0)
IconStroke.Transparency = 0.1
Icon.Image = "rbxassetid://6031280882"
Icon.ScaleType = Enum.ScaleType.Fit
Icon.ImageColor3 = Color3.fromRGB(255,255,255)

WH_Min.MouseButton1Click:Connect(function()
    WH_Main.Visible = false
    Icon.Visible = true
end)

Icon.MouseButton1Click:Connect(function()
    WH_Main.Visible = true
    Icon.Visible = false
end)

------------------------------------------------
-- WEBHOOK BACKEND LOGIC
------------------------------------------------
task.spawn(function()
    local ok, ItemUtility = pcall(function() return require(ReplicatedStorage.Shared.ItemUtility) end)
    local ok2, TierUtility = pcall(function() return require(ReplicatedStorage.Shared.TierUtility) end)
    local ok3, Replion = pcall(function() return require(ReplicatedStorage.Packages.Replion) end)

    if not (ok and ok2 and ok3) then return end

    local Categories = {
        RubyGemstone = {
            Webhook = "https://discord.com/api/webhooks/1504018687735234560/vcDUIkj34d_xnRh_6eNSb8uSGHxDyl2RatpVD0Rvss57rko6nhBvLMsUAhqKwoJzo9Qx",
            IDs = { [243] = true },
            RequireMutation = "Gemstone"
        },
        Forgotten = {
            Webhook = "https://discord.com/api/webhooks/1504018896351662090/Y8oLlclVAwMVP2lS0h-8W4kGu3jK5p3XooMQYD41TlST00veiruwlvfVBwVIbql4qeak",
            IDs = { [773] = true, [822] = true, [870] = true, [907] = true }
        },
        Secret = {
            Webhook = "https://discord.com/api/webhooks/1504019053193461841/TvwIWf8F9HC93r0t96EyXHOS5bf5kBGtDFOwMk-Hrc6fsNCsLUkHNj-tFNUviC6vPShQ",
            IDs = { [589] = true, [228] = true, [345] = true, [790] = true, [226] = true }
        },
        SecretTumbal = {
            Webhook = "https://discord.com/api/webhooks/1504019269627674675/5LnchM57p4B1n6AYhI28coZ-e1qZJimg_ISO42ZPTFy2SpyAcTRBay4a3pSKJT_dBoMH",
            IDs = { 
                [359] = true, [158] = true, [187] = true, [83] = true, [145] = true,
                [379] = true, [156] = true, [159] = true, [248] = true, [269] = true, [661] = true, 
                [450] = true, [833] = true, [141] = true, [201] = true, [218] = true, [225] = true, 
                [82] = true, [339] = true 
            }
        },
        EnchantStone = {
            Webhook = "https://discord.com/api/webhooks/1504019386904739840/OW5ZzDqjImAAX7yTsxSK-Ya9U5Ue3nNkAnX11hufPRTg8ZhSBjPENgXHfl5QMIHes4lK",
            IDs = { [558] = true, [929] = true }
        }
    }

    local NameToId = {}
    local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
    if itemsFolder then
        for _, itemScript in ipairs(itemsFolder:GetChildren()) do
            if itemScript:IsA("ModuleScript") then
                local okI, data = pcall(function() return require(itemScript) end)
                if okI and data and data.Data and data.Data.Name and data.Data.Id then
                    NameToId[data.Data.Name] = data.Data.Id
                end
            end
        end
    end

    local function sendWebRequest(url, method, headers, body)
        local requestFunc = http_request or syn.request or fluxus.request or http.request or request
        if requestFunc then
            pcall(function()
                requestFunc({ Url = url, Method = method, Headers = headers, Body = body })
            end)
        end
    end

    local function notifyCatch(webhookUrl, itemName, itemWeight, isShiny, mutationName, rarity)
        if webhookUrl == "" then return end
        local wibTime = os.time() + (7 * 3600)
        local dateStr = os.date("%m/%d/%Y", wibTime)
        local timeStr = os.date("%H:%M:%S", wibTime)
        local wibString = dateStr .. " " .. timeStr .. " WIB"
        
        local payload = {
            username = "CYRUS BOT",
            embeds = {{
                color = 16711680,
                fields = {
                    { name = "Player", value = "```" .. LocalPlayer.Name .. "```", inline = true },
                    { name = "Name Fish", value = "```" .. itemName .. "```", inline = true },
                    { name = "Rarity", value = "```" .. rarity .. "```", inline = true },
                    { name = "Mutation", value = "```" .. (mutationName or "None") .. "```", inline = true }
                },
                footer = { text = "Cyrus Webhook • " .. wibString }
            }}
        }
        task.spawn(sendWebRequest, webhookUrl .. "?wait=true", "POST", {["Content-Type"] = "application/json"}, HttpService:JSONEncode(payload))
    end

    local HookedRemotes = {}
    local function processRemoteEvent(remote)
        if not remote:IsA("RemoteEvent") then return end
        if HookedRemotes[remote] then return end
        HookedRemotes[remote] = true

        remote.OnClientEvent:Connect(function(...)
            local args = {...}
            if TrackerEnabled and #args >= 2 then
                local fishName = args[1]
                local metadata = args[2]
                local isValidCatch = typeof(fishName) == "string" and typeof(metadata) == "table" and metadata.Weight ~= nil and typeof(metadata.Weight) == "number"
                
                if isValidCatch then
                    LastCatchTime = tick() -- Update status normal
                    local isShiny = metadata.Shiny == true
                    local mutationName = nil
                    if metadata.VariantId then
                        local okV, variantData = pcall(function() return ItemUtility:GetVariantData(metadata.VariantId) end)
                        if okV and variantData and variantData.Data then mutationName = variantData.Data.Name end
                    end
                    local caughtId = NameToId[fishName]
                    for catName, catData in pairs(Categories) do
                        if catData.IDs[caughtId] then
                            if catData.RequireMutation and mutationName ~= catData.RequireMutation then break end
                            local rarity = "Unknown"
                            pcall(function()
                                local itemData = ItemUtility:GetItemData(fishName)
                                if itemData and itemData.Data then
                                    if itemData.Data.Tier then rarity = TierUtility:GetTier(itemData.Data.Tier).Name
                                    elseif itemData.Probability then rarity = TierUtility:GetTierFromRarity(itemData.Probability.Chance).Name end
                                end
                            end)
                            notifyCatch(catData.Webhook, fishName, metadata.Weight, isShiny, mutationName, rarity)
                            break
                        end
                    end
                end
            end
        end)
    end
    for _, desc in ipairs(game:GetDescendants()) do pcall(processRemoteEvent, desc) end
    game.DescendantAdded:Connect(function(desc) pcall(processRemoteEvent, desc) end)

    local DataReplion = Replion.Client:WaitReplion("Data", 30)
    if DataReplion then
        local function updateFishCount()
            local count = 0
            pcall(function()
                local inventoryItems = DataReplion:Get({ "Inventory", "Items" })
                if typeof(inventoryItems) == "table" then
                    for _, item in ipairs(inventoryItems) do
                        local itemData = ItemUtility:GetItemData(item.Id)
                        if itemData and itemData.Data and itemData.Data.Type == "Fish" then count += 1 end
                    end
                end
            end)
            CountD.Text = tostring(count)
        end
        updateFishCount()
        DataReplion:OnChange({ "Inventory", "Items" }, updateFishCount)
    end

    Test.MouseButton1Click:Connect(function()
        if not TrackerEnabled then
            WH_Status.Text = "Turn ON first!"
            WH_Status.TextColor3 = Color3.fromRGB(255, 255, 0)
            task.wait(1.5)
            setToggle(false)
            return
        end
        WH_Status.Text = "Sending Test..."
        WH_Status.TextColor3 = Color3.fromRGB(255, 255, 0)
        for catName, catData in pairs(Categories) do
            notifyCatch(catData.Webhook, "[TEST WEBHOOK]", 0, false, "[TEST MODE]", "[TEST]")
        end
        task.wait(2)
        if TrackerEnabled then
            WH_Status.Text = "Webhook: ON"
            WH_Status.TextColor3 = Color3.fromRGB(80,255,80)
        end
    end)
end)