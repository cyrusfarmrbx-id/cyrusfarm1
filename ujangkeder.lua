------------------------------------------------
-- SERVICES
------------------------------------------------
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

------------------------------------------------
-- PENGATURAN WAKTU WEBHOOK (VPS / LOCAL)
------------------------------------------------
local JAM_TAMBAHAN = 0 

------------------------------------------------
-- FARM MODE SYSTEM
------------------------------------------------
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
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
local dlConn = nil
local camConn = nil
local hideConn = nil

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
                if locked and child.Enabled then gui.Enabled = false end
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
                local head = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")
                if head then camera.CFrame = head.CFrame * CFrame.new(0, 0.5, -1) end
            end
            if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then UIS.MouseBehavior = Enum.MouseBehavior.Default end
        end)
    else
        if camConn then camConn:Disconnect(); camConn = nil end
        camera.CameraType = Enum.CameraType.Custom
    end
end

------------------------------------------------
-- FARM MODE FUNCTIONS
------------------------------------------------
local function EnableFarmMode()
    locked = true
    blurEffect.Enabled = true; blurEffect.Size = 56
    kunciUI(LocalPlayer.PlayerGui)
    toggleFPP(true)
    
    for _, v in pairs(workspace:GetDescendants()) do clearTextAndLightning(v) end
    local cf = workspace:FindFirstChild("CosmeticFolder")
    if cf then for _, v in pairs(cf:GetDescendants()) do clearFish(v) end end

    notifConn = workspace.DescendantAdded:Connect(clearTextAndLightning)
    if cf then fishConn = cf.DescendantAdded:Connect(clearFish) end
    
    -- [HIDE PLAYER] Mulai
    local chars = workspace:FindFirstChild("Characters")
    if chars then
        for _, c in ipairs(chars:GetChildren()) do
            if c:IsA("Model") and c ~= LocalPlayer.Character then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") or p:IsA("MeshPart") then p.Transparency = 1 end
                end
            end
        end
        hideConn = chars.ChildAdded:Connect(function(c)
            if c:IsA("Model") and c ~= LocalPlayer.Character then
                task.wait(0.5)
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") or p:IsA("MeshPart") then p.Transparency = 1 end
                end
            end
        end)
    end
    -- [HIDE PLAYER] Selesai

    print("Farm Mode Enabled")
end

local function DisableFarmMode()
    locked = false
    blurEffect.Enabled = false
    bukaUI()
    toggleFPP(false)
    if notifConn then notifConn:Disconnect(); notifConn = nil end
    if fishConn then fishConn:Disconnect(); fishConn = nil end
    if hideConn then hideConn:Disconnect(); hideConn = nil end -- Tambahkan ini
    print("Farm Mode Disabled")
end

------------------------------------------------
-- UI & WEBHOOK SYSTEM
------------------------------------------------
local farmGui = Instance.new("ScreenGui")
farmGui.Name = "LoaderUI"
farmGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
farmGui.ResetOnSpawn = false
farmGui.Enabled = false

local FM_Main = Instance.new("Frame")
FM_Main.Parent = farmGui
FM_Main.Size = UDim2.new(0.32, 0, 0.42, 0)
FM_Main.Position = UDim2.new(0.5, 0, 0.42, 0)
FM_Main.AnchorPoint = Vector2.new(0.5, 0.5)
FM_Main.BackgroundTransparency = 1
FM_Main.Active = true
FM_Main.Draggable = true
Instance.new("UICorner", FM_Main).CornerRadius = UDim.new(0, 14)

local FM_constraint = Instance.new("UISizeConstraint", FM_Main)
FM_constraint.MinSize = Vector2.new(240, 340)
FM_constraint.MaxSize = Vector2.new(420, 620)

local FM_padding = Instance.new("UIPadding", FM_Main)
FM_padding.PaddingTop = UDim.new(0, 10)
FM_padding.PaddingBottom = UDim.new(0, 10)
FM_padding.PaddingLeft = UDim.new(0, 14)
FM_padding.PaddingRight = UDim.new(0, 14)

local FM_Container = Instance.new("Frame", FM_Main)
FM_Container.Size = UDim2.new(1,0,1,0)
FM_Container.BackgroundTransparency = 1

local FM_Layout = Instance.new("UIListLayout", FM_Container)
FM_Layout.Padding = UDim.new(0,5)
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

local function FM_createCounter(parent, sizeX, defaultText)
    local box = Instance.new("Frame")
    box.Parent = parent
    box.Size = UDim2.new(sizeX, 0, 1, 0)
    box.BackgroundTransparency = 1
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
FM_Row2.Size = UDim2.new(0.92,0,0,28)
FM_Row2.BackgroundTransparency = 1

local FM_row2Layout = Instance.new("UIListLayout", FM_Row2)
FM_row2Layout.FillDirection = Enum.FillDirection.Horizontal
FM_row2Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FM_row2Layout.VerticalAlignment = Enum.VerticalAlignment.Center
FM_row2Layout.Padding = UDim.new(0,10)

local SingleBox = Instance.new("Frame", FM_Row2)
SingleBox.Size = UDim2.new(1, 0, 1, 0)
SingleBox.BackgroundTransparency = 1
Instance.new("UICorner", SingleBox).CornerRadius = UDim.new(0,10)

local SingleText = Instance.new("TextLabel", SingleBox)
SingleText.Size = UDim2.new(1, 0, 1, 0)
SingleText.BackgroundTransparency = 1
SingleText.Text = "🐟 STATUS: FISHING NORMAL"
SingleText.TextColor3 = Color3.fromRGB(60, 200, 60)
SingleText.TextSize = 18
SingleText.Font = Enum.Font.GothamBold

local LastCatchTime = tick()
task.spawn(function()
    while task.wait(1) do
        local elapsed = tick() - LastCatchTime
        if elapsed > 15 then
            SingleText.Text = "⚠️ STUCK / IDLE (" .. math.floor(elapsed) .. "s)"
            SingleText.TextColor3 = Color3.fromRGB(200, 50, 50)
        else
            SingleText.Text = "🐟 STATUS: FISHING NORMAL"
            SingleText.TextColor3 = Color3.fromRGB(60, 200, 60)
        end
    end
end)

local FM_Row3 = Instance.new("Frame", FM_Container)
FM_Row3.Size = UDim2.new(1,0,0,28)
FM_Row3.BackgroundTransparency = 1

local FM_row3Layout = Instance.new("UIListLayout", FM_Row3)
FM_row3Layout.FillDirection = Enum.FillDirection.Horizontal
FM_row3Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FM_row3Layout.VerticalAlignment = Enum.VerticalAlignment.Center
FM_row3Layout.Padding = UDim.new(0,10)

local CountD = FM_createCounter(FM_Row3, 0.45, "0")
local CountE = FM_createCounter(FM_Row3, 0.45, "0")

local CountBox = Instance.new("Frame", FM_Container)
CountBox.Size = UDim2.new(0.92,0,0,30)
CountBox.BackgroundTransparency = 1
Instance.new("UICorner", CountBox).CornerRadius = UDim.new(0,10)

local MainCount = Instance.new("TextLabel", CountBox)
MainCount.Size = UDim2.new(1,0,1,0)
MainCount.BackgroundTransparency = 1
MainCount.Text = "Loading..."
MainCount.TextColor3 = Color3.fromRGB(255,255,255)
MainCount.TextSize = 22
MainCount.Font = Enum.Font.GothamBold

local ExitButton = Instance.new("TextButton", FM_Container)
ExitButton.Size = UDim2.new(0.92,0,0,28)
ExitButton.Text = "EXIT FARM MODE"
ExitButton.TextSize = 16
ExitButton.Font = Enum.Font.GothamBold
ExitButton.TextColor3 = Color3.fromRGB(255,255,255)
ExitButton.BackgroundColor3 = Color3.fromRGB(180,50,50)
Instance.new("UICorner", ExitButton).CornerRadius = UDim.new(0,10)

local TargetFish = {}
local displayKeys = {}
local displayIndex = 1
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
    
    local totalTarget = #displayKeys
    
    if totalTarget == 0 then
        MainCount.Text = "Menunggu ikan target..."
    elseif totalTarget == 1 then
        local fishName = displayKeys[1]
        local fishCount = TargetFish[fishName]
        MainCount.Text = fishName .. " ( " .. fishCount .. " )"
    else
        if elapsed >= switchDelay then
            elapsed = 0
            displayIndex += 1
            if displayIndex > totalTarget then displayIndex = 1 end
        end
        local fishName = displayKeys[displayIndex]
        local fishCount = TargetFish[fishName]
        MainCount.Text = fishName .. " ( " .. fishCount .. " )"
    end
end)

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
WH_Title.Text = "CYRUS FARM [FINAL]"
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

local ScanRequested = true

local FarmModeBtn = Instance.new("TextButton", WH_Content)
FarmModeBtn.Size = UDim2.new(0,130,0,36)
FarmModeBtn.Position = UDim2.new(0.5,-65,0,85)
FarmModeBtn.Text = "FARM MODE"
FarmModeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
FarmModeBtn.TextColor3 = Color3.fromRGB(255,255,255)
FarmModeBtn.Font = Enum.Font.SourceSansBold
FarmModeBtn.TextSize = 14
Instance.new("UICorner", FarmModeBtn).CornerRadius = UDim.new(0,8)

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

FarmModeBtn.MouseButton1Click:Connect(function()
    FarmModeBtn.Text = "LOADING..."
    
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

    webhookGui.Enabled = false
    farmGui.Enabled = true
    FarmModeBtn.Text = "FARM MODE"
    
    ScanRequested = true
end)

ExitButton.MouseButton1Click:Connect(function()
    DisableFarmMode()
    
    if dlConn then dlConn:Disconnect() end

    farmGui.Enabled = false
    webhookGui.Enabled = true
end)

local Test = Instance.new("TextButton", WH_Content)
Test.Size = UDim2.new(0,130,0,30)
Test.Position = UDim2.new(0.5,-65,0,130)
Test.Text = "TEST WEBHOOK"
Test.BackgroundColor3 = Color3.fromRGB(60,60,60)
Test.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", Test).CornerRadius = UDim.new(0,8)

------------------------------------------------
-- WEBHOOK BACKEND LOGIC & SCANNER INVENTORY (FINAL FIX NAME)
------------------------------------------------
task.spawn(function()
    local ok, ItemUtility = pcall(function() return require(ReplicatedStorage.Shared.ItemUtility) end)
    local ok2, TierUtility = pcall(function() return require(ReplicatedStorage.Shared.TierUtility) end)
    local ok3, Replion = pcall(function() return require(ReplicatedStorage.Packages.Replion) end)

    if not (ok and ok2 and ok3) then 
        warn("DEBUG: Gagal load Module Utilities")
        return 
    end

    local Categories = {
        RubyGemstone = {
            Webhook = "https://discord.com/api/webhooks/1504018687735234560/vcDUIkj34d_xnRh_6eNSb8uSGHxDyl2RatpVD0Rvss57rko6nhBvLMsUAhqKwoJzo9Qx",
            IDs = { [243] = true },
            RequireMutation = "Gemstone"
        },
        Forgotten = {
            Webhook = "https://discord.com/api/webhooks/1504018896351662090/Y8oLlclVAwMVP2lS0h-8W4kGu3jK5p3XooMQYD41TlST00veiruwlvfVBwVIbql4qeak",
            IDs = { [773] = true, [822] = true, [870] = true, [210] = true, [907] = true }
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

    local TargetIDs = {
        [243] = "Gemstone", 
        [773] = false, [822] = false, [870] = false, [907] = false, 
        [589] = false, [228] = false, [345] = false, [790] = false, [226] = false, 
        [359] = false, [158] = false, [187] = false, [83]  = false, [145] = false,
        [379] = false, [156] = false, [159] = false, [248] = false, [269] = false, 
        [661] = false, [450] = false, [833] = false, [141] = false, [201] = false, 
        [218] = false, [225] = false, [82]  = false, [339] = false, 
        [558] = false, [929] = false, 
    }

    -- Kita HAPUS bagian IdToName manual karena sudah tidak perlu.

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
        local wibTime = os.time() + (JAM_TAMBAHAN * 3600)
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

    -- --- ULTIMATE FISHING LISTENER (NO FILTER NAME) ---
    print("Mengaktifkan Universal Listener (Semua Remote)...")

    local foundRemotes = {}
    
    -- Ambil SEMUA Remote Event tanpa peduli namanya
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            table.insert(foundRemotes, v)
        end
    end
    
    print("Total Remote Terhubung: " .. #foundRemotes)

    for _, remote in ipairs(foundRemotes) do
        remote.OnClientEvent:Connect(function(...)
            if not TrackerEnabled then return end
            
            local args = {...}
            local id = args[1]
            local metadata = args[2] 
            
            -- 1. FILTER: Harus berupa angka
            if type(id) ~= "number" then return end

            -- 2. VALIDASI ITEM (Anti Spam)
            -- Pastikan ID ini benar-benar item valid di game, bukan random angka
            local isValidItem = false
            pcall(function()
                local checkData = ItemUtility:GetItemData(id)
                if checkData and checkData.Data then
                    isValidItem = true
                end
            end)

            -- Jika bukan item valid, abaikan (makanan, potion, dll)
            if not isValidItem then return end

            -- 3. UPDATE STATUS (ANTI STUCK)
            -- Karena ini item valid (ikan/stone), kita pastikan timer tidak stuck
            LastCatchTime = tick()

            -- 4. CEK TARGET (Webhook)
            local targetCategory = nil
            for catName, catData in pairs(Categories) do
                if catData.IDs[id] then
                    targetCategory = catData
                    break
                end
            end

            -- 5. Jika TARGET LANGKA -> KIRIM WEBHOOK
            if targetCategory then
                if type(metadata) ~= "table" then metadata = {} end
                
                local isShiny = metadata.Shiny == true
                local mutationName = metadata.VariantId
                local weight = metadata.Weight or 0 
                
                local itemName = "Unknown Item"
                local rarity = "Unknown"
                
                pcall(function()
                    local itemData = ItemUtility:GetItemData(id)
                    if itemData and itemData.Data then
                        itemName = itemData.Data.Name 
                        
                        -- Logic Rarity
                        local tierName = nil
                        if itemData.Data.Tier then
                            local success, tierObj = pcall(function() return TierUtility:GetTier(itemData.Data.Tier) end)
                            if success and tierObj then tierName = tierObj.Name end
                        end
                        
                        if tierName then
                            rarity = tierName
                        elseif itemData.Data.Rarity then
                            local success, rarityObj = pcall(function() return TierUtility:GetTier(itemData.Data.Rarity) end)
                            if success and rarityObj then
                                rarity = rarityObj.Name
                            else
                                rarity = tostring(itemData.Data.Rarity) 
                            end
                        end
                    end
                end)
                
                -- Cek Mutation
                if targetCategory.RequireMutation and mutationName ~= targetCategory.RequireMutation then
                    return 
                end
                
                notifyCatch(targetCategory.Webhook, itemName, weight, isShiny, mutationName, rarity)
            end
        end)
    end
    -- --- END UNIVERSAL LISTENER ---
    
    local DataReplion = Replion.Client:WaitReplion("Data", 30)
    if DataReplion then
        local function updateTargetFishUI()
            local newTargetFish = {}
            pcall(function()
                local inventoryItems = DataReplion:Get({ "Inventory", "Items" })
                if typeof(inventoryItems) == "table" then
                    for _, item in ipairs(inventoryItems) do
                        local requireMutation = TargetIDs[item.Id]
                        if requireMutation ~= nil then
                            local itemData = ItemUtility:GetItemData(item.Id)
                            if itemData and itemData.Data and (itemData.Data.Type == "Fish" or itemData.Data.Type == "Enchant Stones") then
                                local mutationName = nil
                                if item.Metadata and item.Metadata.VariantId then
                                    local okV, variantData = pcall(function() return ItemUtility:GetVariantData(item.Metadata.VariantId) end)
                                    if okV and variantData and variantData.Data then mutationName = variantData.Data.Name end
                                end
                                if requireMutation == false or mutationName == requireMutation then
                                    local fishName = itemData.Data.Name
                                    newTargetFish[fishName] = (newTargetFish[fishName] or 0) + 1
                                end
                            end
                        end
                    end
                end
            end)
            TargetFish = newTargetFish
            displayKeys = {}
            for name, _ in pairs(TargetFish) do table.insert(displayKeys, name) end
            if displayIndex > #displayKeys then displayIndex = 1 end
        end
        
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
        
        task.spawn(function()
            while task.wait(0.5) do
                if ScanRequested then
                    ScanRequested = false
                    pcall(function() updateTargetFishUI(); updateFishCount() end)
                end
            end
        end)
        
        DataReplion:OnChange({ "Inventory", "Items" }, function()
            pcall(function() updateTargetFishUI(); updateFishCount() end)
        end)
    end

    Test.MouseButton1Click:Connect(function()
        if not TrackerEnabled then
            WH_Status.Text = "Turn ON first!"; WH_Status.TextColor3 = Color3.fromRGB(255, 255, 0)
            task.wait(1.5); setToggle(false); return
        end
        WH_Status.Text = "Sending Test..."; WH_Status.TextColor3 = Color3.fromRGB(255, 255, 0)
        for catName, catData in pairs(Categories) do notifyCatch(catData.Webhook, "[TEST WEBHOOK]", 0, false, "[TEST MODE]", "[TEST]") end
        task.wait(2)
        if TrackerEnabled then WH_Status.Text = "Webhook: ON"; WH_Status.TextColor3 = Color3.fromRGB(80,255,80) end
    end)
end)

-- OTOMATIS MASUK FARM MODE SETELAH UI SIAP (3 DETIK)
task.spawn(function()
    task.wait(3) -- Tunggu 3 detik sampai semua UI 100% selesai dibuat
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local dl = pg and pg:FindFirstChild("!!! Daily Login")
        local dlGuiControl = nil
        pcall(function() dlGuiControl = require(ReplicatedStorage.Modules.GuiControl) end)
        
        -- Jalankan Farm Mode
        EnableFarmMode()
        
        -- Handle Daily Login
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

        -- Pindahin UI dari Menu ke Farm
        webhookGui.Enabled = false
        farmGui.Enabled = true
        
        ScanRequested = true
    end)
end)
