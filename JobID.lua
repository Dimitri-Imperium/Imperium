--[[ Imperium's Job ID ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)
local HttpService = game:GetService("HttpService")

if not PlayerGui then return end

if PlayerGui:FindFirstChild("JobIDGui") then
    PlayerGui.JobIDGui:Destroy()
end

local JobIDGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Barrier = Instance.new("TextLabel")
local Label = Instance.new("TextLabel")
local PasteJobID = Instance.new("TextBox")
local JoinGame = Instance.new("TextButton")
local CopyJobID = Instance.new("TextButton")
local Close = Instance.new("TextButton")
local MobileToggle = Instance.new("TextButton")
local ToggleHistoryBtn = Instance.new("TextButton")

local HistoryFrame = Instance.new("Frame")
local HistoryLabel = Instance.new("TextLabel")
local HistoryBarrier = Instance.new("TextLabel")
local HistoryScroll = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

local GuiService = game:GetService("StarterGui")
local TeleService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local TOGGLE_KEY = Enum.KeyCode.RightControl
local FILE_NAME = "imperium_history.txt"

local EmeraldInk = Color3.fromRGB(9, 94, 60)
local EmeraldHover = Color3.fromRGB(15, 130, 85)
local Champagne = Color3.fromRGB(247, 237, 219)
local InputBg = Color3.fromRGB(255, 255, 255)
local TextDark = Color3.fromRGB(30, 30, 30)

-- Global Data Loading Configuration (Checks hard drive for history file)
_G.JoinedHistoryData = {}
local success, fileContent = pcall(function() return readfile(FILE_NAME) end)
if success and fileContent then
    pcall(function() _G.JoinedHistoryData = HttpService:JSONDecode(fileContent) end)
end

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function addHoverAnimation(button, normalColor, hoverColor, property)
    property = property or "BackgroundColor3"
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local hoverTween = TweenService:Create(button, tweenInfo, {[property] = hoverColor})
    local normalTween = TweenService:Create(button, tweenInfo, {[property] = normalColor})
    button.MouseEnter:Connect(function() hoverTween:Play() end)
    button.MouseLeave:Connect(function() normalTween:Play() end)
end

local function getRelativeTime(timestamp)
    local diff = os.time() - timestamp
    if diff < 60 then return "Just now" end
    local mins = math.floor(diff / 60)
    if mins < 60 then return mins .. " mins ago" end
    local hours = math.floor(mins / 60)
    if hours < 24 then return hours .. " hours ago" end
    local days = math.floor(hours / 24)
    return days .. " days ago"
end

local function makeDraggable(targetInstance, isMobileButton)
    local dragging, dragInput, dragStart, startPos
    local totalDragDelta = 0
    
    local function update(input)
        local delta = input.Position - dragStart
        totalDragDelta = delta.Magnitude
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(targetInstance, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
    end
    
    targetInstance.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetInstance.Position
            totalDragDelta = 0
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    targetInstance.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    if isMobileButton then
        targetInstance.MouseButton1Down:Connect(function() totalDragDelta = 0 end)
        targetInstance.MouseButton1Click:Connect(function()
            if totalDragDelta > 5 then return end
            MainFrame.Visible = not MainFrame.Visible
        end)
    end
end

JobIDGui.Name = "JobIDGui"
JobIDGui.Parent = PlayerGui
JobIDGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
JobIDGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = JobIDGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Champagne
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 320, 0, 170)
MainFrame.Active = true
makeDraggable(MainFrame, false)

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = EmeraldInk
FrameStroke.Thickness = 2
FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
FrameStroke.Parent = MainFrame
addCorner(MainFrame, 8)

HistoryFrame.Name = "HistoryFrame"
HistoryFrame.Parent = MainFrame
HistoryFrame.BackgroundColor3 = Champagne
HistoryFrame.BorderSizePixel = 0
HistoryFrame.Position = UDim2.new(1, 10, 0, 0)
HistoryFrame.Size = UDim2.new(0, 240, 1, 0)
HistoryFrame.Visible = false

local HistoryStroke = Instance.new("UIStroke")
HistoryStroke.Color = EmeraldInk
HistoryStroke.Thickness = 2
HistoryStroke.Parent = HistoryFrame
addCorner(HistoryFrame, 8)

--[[ Storage ]]
local HttpService = game:GetService("HttpService")
local FILE_NAME = "imperium_history.txt"

HistoryLabel.Name = "HistoryLabel"
HistoryLabel.Parent = HistoryFrame
HistoryLabel.BackgroundTransparency = 1
HistoryLabel.Size = UDim2.new(1, 0, 0, 35)
HistoryLabel.Font = Enum.Font.Arial
HistoryLabel.Text = "Join History"
HistoryLabel.TextColor3 = EmeraldInk
HistoryLabel.TextSize = 18

HistoryBarrier.Name = "HistoryBarrier"
HistoryBarrier.Parent = HistoryFrame
HistoryBarrier.BackgroundColor3 = EmeraldInk
HistoryBarrier.BorderSizePixel = 0
HistoryBarrier.Position = UDim2.new(0, 0, 0.22, 0)
HistoryBarrier.Size = UDim2.new(1, 0, 0, 2)
HistoryBarrier.Text = ""

HistoryScroll.Name = "HistoryScroll"
HistoryScroll.Parent = HistoryFrame
HistoryScroll.BackgroundTransparency = 1
HistoryScroll.BorderSizePixel = 0
HistoryScroll.Position = UDim2.new(0, 5, 0, 42)
HistoryScroll.Size = UDim2.new(1, -10, 1, -47)
HistoryScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
HistoryScroll.ScrollBarThickness = 4
HistoryScroll.ScrollBarImageColor3 = EmeraldInk

UIListLayout.Parent = HistoryScroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)

local function saveHistoryToFile()
    pcall(function()
        writefile(FILE_NAME, HttpService:JSONEncode(_G.JoinedHistoryData))
    end)
end

local function renderHistory()
    for _, item in pairs(HistoryScroll:GetChildren()) do
        if item:IsA("Frame") then item:Destroy() end
    end
    
    for index, data in ipairs(_G.JoinedHistoryData) do
        local Entry = Instance.new("Frame")
        Entry.Name = "Entry"
        Entry.Size = UDim2.new(1, -6, 0, 40)
        Entry.BackgroundColor3 = InputBg
        Entry.BorderSizePixel = 0
        Entry.Parent = HistoryScroll
        addCorner(Entry, 4)
        
        local EntryStroke = Instance.new("UIStroke")
        EntryStroke.Color = Color3.fromRGB(220, 210, 195)
        EntryStroke.Thickness = 1
        EntryStroke.Parent = Entry

        local InfoLabel = Instance.new("TextLabel")
        InfoLabel.Size = UDim2.new(0.65, 0, 1, 0)
        InfoLabel.Position = UDim2.new(0, 6, 0, 0)
        InfoLabel.BackgroundTransparency = 1
        InfoLabel.Font = Enum.Font.Arial
        InfoLabel.Text = string.sub(data.id, 1, 8) .. "...\n" .. getRelativeTime(data.time)
        InfoLabel.TextColor3 = TextDark
        InfoLabel.TextSize = 13
        InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
        InfoLabel.Parent = Entry
        
        local CopyBtn = Instance.new("TextButton")
        CopyBtn.Size = UDim2.new(0, 22, 0, 22)
        CopyBtn.Position = UDim2.new(0.7, 0, 0.22, 0)
        CopyBtn.BackgroundColor3 = EmeraldInk
        CopyBtn.BorderSizePixel = 0
        CopyBtn.Font = Enum.Font.Arial
        CopyBtn.Text = "📋"
        CopyBtn.TextColor3 = Champagne
        CopyBtn.TextSize = 12
        CopyBtn.Parent = Entry
        addCorner(CopyBtn, 4)
        addHoverAnimation(CopyBtn, EmeraldInk, EmeraldHover)
        CopyBtn.MouseButton1Down:Connect(function()
            setclipboard(data.id)
            pcall(function() GuiService:SetCore("SendNotification", {Title = "Imperium", Text = "Job ID Copied!"}) end)
        end)
        
        local DelBtn = Instance.new("TextButton")
        DelBtn.Size = UDim2.new(0, 22, 0, 22)
        DelBtn.Position = UDim2.new(0.85, 0, 0.22, 0)
        DelBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        DelBtn.BorderSizePixel = 0
        DelBtn.Font = Enum.Font.Arial
        DelBtn.Text = "✕"
        DelBtn.TextColor3 = Champagne
        DelBtn.TextSize = 12
        DelBtn.Parent = Entry
        addCorner(DelBtn, 4)
        addHoverAnimation(DelBtn, Color3.fromRGB(180, 50, 50), Color3.fromRGB(220, 60, 60))
        DelBtn.MouseButton1Down:Connect(function()
            table.remove(_G.JoinedHistoryData, index)
            saveHistoryToFile()
            renderHistory()
        end)
    end
    HistoryScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

Barrier.Name = "Barrier"
Barrier.Parent = MainFrame
Barrier.BackgroundColor3 = EmeraldInk
Barrier.BorderSizePixel = 0
Barrier.Position = UDim2.new(0, 0, 0.22, 0)
Barrier.Size = UDim2.new(1, 0, 0, 2)
Barrier.Text = ""

Label.Name = "Label"
Label.Parent = MainFrame
Label.AnchorPoint = Vector2.new(0.5, 0)
Label.BackgroundTransparency = 1
Label.Position = UDim2.new(0.5, 0, 0, 2)
Label.Size = UDim2.new(0, 200, 0, 30)
Label.Font = Enum.Font.Arial
Label.Text = "Imperium - Job ID"
Label.TextColor3 = EmeraldInk
Label.TextSize = 20

PasteJobID.Name = "PasteJobID"
PasteJobID.Parent = MainFrame
PasteJobID.AnchorPoint = Vector2.new(0.5, 0)
PasteJobID.BackgroundColor3 = InputBg
PasteJobID.BorderSizePixel = 0
PasteJobID.Position = UDim2.new(0.5, 0, 0.30, 0)
PasteJobID.Size = UDim2.new(0, 280, 0, 30)
PasteJobID.Font = Enum.Font.Arial
PasteJobID.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
PasteJobID.PlaceholderText = "Paste Job ID here..."
PasteJobID.Text = ""
PasteJobID.TextColor3 = TextDark
PasteJobID.TextSize = 16
addCorner(PasteJobID, 6)

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(210, 200, 185)
InputStroke.Thickness = 1
InputStroke.Parent = PasteJobID

CopyJobID.Name = "CopyJobID"
CopyJobID.Parent = MainFrame
CopyJobID.AnchorPoint = Vector2.new(0.5, 0)
CopyJobID.BackgroundColor3 = EmeraldInk
CopyJobID.BorderSizePixel = 0
CopyJobID.Position = UDim2.new(0.5, -72, 0.53, 0)
CopyJobID.Size = UDim2.new(0, 135, 0, 30)
CopyJobID.Font = Enum.Font.Arial
CopyJobID.Text = "Copy Job ID"
CopyJobID.TextColor3 = Champagne
CopyJobID.TextSize = 16
addCorner(CopyJobID, 6)
addHoverAnimation(CopyJobID, EmeraldInk, EmeraldHover)
CopyJobID.MouseButton1Down:connect(function()
    pcall(function() GuiService:SetCore("SendNotification", {Title = "Imperium", Text = "Copied Job ID to Your Clipboard"}) end)
    setclipboard(game.JobId)
end)

ToggleHistoryBtn.Name = "ToggleHistoryBtn"
ToggleHistoryBtn.Parent = MainFrame
ToggleHistoryBtn.AnchorPoint = Vector2.new(0.5, 0)
ToggleHistoryBtn.BackgroundColor3 = EmeraldInk
ToggleHistoryBtn.BorderSizePixel = 0
ToggleHistoryBtn.Position = UDim2.new(0.5, 72, 0.53, 0)
ToggleHistoryBtn.Size = UDim2.new(0, 135, 0, 30)
ToggleHistoryBtn.Font = Enum.Font.Arial
ToggleHistoryBtn.Text = "History"
ToggleHistoryBtn.TextColor3 = Champagne
ToggleHistoryBtn.TextSize = 16
addCorner(ToggleHistoryBtn, 6)
addHoverAnimation(ToggleHistoryBtn, EmeraldInk, EmeraldHover)
ToggleHistoryBtn.MouseButton1Down:Connect(function()
    HistoryFrame.Visible = not HistoryFrame.Visible
    if HistoryFrame.Visible then renderHistory() end
end)

JoinGame.Name = "JoinGame"
JoinGame.Parent = MainFrame
JoinGame.AnchorPoint = Vector2.new(0.5, 0)
JoinGame.BackgroundColor3 = EmeraldInk
JoinGame.BorderSizePixel = 0
JoinGame.Position = UDim2.new(0.5, 0, 0.76, 0)
JoinGame.Size = UDim2.new(0, 280, 0, 30)
JoinGame.Font = Enum.Font.Arial
JoinGame.Text = "Join Server"
JoinGame.TextColor3 = Champagne
JoinGame.TextSize = 18
addCorner(JoinGame, 6)
addHoverAnimation(JoinGame, EmeraldInk, EmeraldHover)
JoinGame.MouseButton1Down:connect(function()
    if PasteJobID.Text ~= "" then
        table.insert(_G.JoinedHistoryData, 1, {id = PasteJobID.Text, time = os.time()})
        saveHistoryToFile() -- Saves changes securely into executor data files before departure
    end
    TeleService:TeleportToPlaceInstance(game.PlaceId, PasteJobID.Text, Players.LocalPlayer)
end)

Close.Name = "Close"
Close.Parent = MainFrame
Close.AnchorPoint = Vector2.new(1, 0)
Close.BackgroundTransparency = 1
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0.97, 0, 0.03, 0)
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Font = Enum.Font.Arial
Close.Text = "X"
Close.TextColor3 = EmeraldInk
Close.TextSize = 18
addHoverAnimation(Close, EmeraldInk, Color3.fromRGB(200, 50, 50), "TextColor3")
Close.MouseButton1Down:connect(function() JobIDGui:Destroy() end)

MobileToggle.Name = "MobileToggle"
MobileToggle.Parent = JobIDGui
MobileToggle.BackgroundColor3 = Champagne
MobileToggle.BorderSizePixel = 0
MobileToggle.Position = UDim2.new(0.02, 0, 0.15, 0)
MobileToggle.Size = UDim2.new(0, 80, 0, 30)
MobileToggle.Font = Enum.Font.Arial
MobileToggle.Text = "Imperium"
MobileToggle.TextColor3 = EmeraldInk
MobileToggle.TextSize = 14
MobileToggle.Active = true
addCorner(MobileToggle, 6)
makeDraggable(MobileToggle, true)
addHoverAnimation(MobileToggle, Champagne, Color3.fromRGB(235, 225, 205))

if UserInputService.KeyboardEnabled then MobileToggle.Visible = false end

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == TOGGLE_KEY then 
        MainFrame.Visible = not MainFrame.Visible 
    end
end)
