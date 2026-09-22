local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))

local player = Players.LocalPlayer
local WindUI
local Const = {
    Config = {
        Author = "xia0nai",
        Folder = "xia0nai",
        WebhookUrl = "https://discord.com/api/webhooks/1524106748238233872/WD-qBs3YacK5BgRcsqGI6uLzC5G5tKY-udWgO2YWxCHpd-Y64ooORwqGgiwq4kuMQkdy"
    },
    WindUI = {
        Theme = "Crimson"
    }
}

do
    if cloneref(game:GetService("RunService")):IsStudio() then
        WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
    else
        WindUI = loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/xia0nai/TestRbx/refs/heads/main/dist/main.lua"))()
    end
end

-- */ Show Notification init /* --
function showNotif(section, msg)
    return WindUI:Notify({
        Title = section,
        Content = msg,
        Duration = 3,
        Icon = "lucide:info"
    })
end

-- */  Window  /* --
local Window = WindUI:CreateWindow({
    Title = "TestRbx",
    Author = "by " .. Const.Config.Author,
    Folder = Const.Config.Folder,
    Icon = "solar:atom-bold-duotone",
    Theme = Const.WindUI.Theme,
    NewElements = true,
    HideSearchBar = false,
    OpenButton = {
        Title = "TestRbx",
        Icon = "solar:atom-bold-duotone",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.8,
        Color = ColorSequence.new( -- gradient
        Color3.fromHex("#30FF6A"), Color3.fromHex("#e7ff2f"))
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Default" -- Default or Mac
    },
    User = {
        Enabled = true
    }
})
-- */  Scale window  /* --
-- Window:SetUIScale(.7)
-- */  Tags  /* --
do
    Window:Tag({
        Title = "v0.0.1-alpha.1",
        Icon = "github",
        Color = Color3.fromHex("#1c1c1c"),
        Border = true
    })
end

local Tabs = {
    MainTab = Window:Tab({
        Title = "Main",
        Icon = "lucide:house"
    }),
    TeleportTab = Window:Tab({
        Title = "Teleport",
        Icon = "lucide:map-pin"
    }),
    SettingsTab = Window:Tab({
        Title = "Settings",
        Icon = "lucide:settings"
    })
}

-- */ Teleport Tab /* --
do
    local TeleportSection = Tabs.TeleportTab:Section({
        Title = "Teleport",
        Box = true,
        Opened = true
    })

    local SavedCoords = {}
    local selectedCheckpoint = nil

    local function CFrameToString(key, cf)
        local x, y, z = cf.Position.X, cf.Position.Y, cf.Position.Z
        local rx, ry, rz = cf:ToEulerAnglesXYZ()

        return string.format("%s;%.4f;%.4f;%.4f;%.4f;%.4f;%.4f", key, x, y, z, rx, ry, rz)
    end

    local function StringToCFrame(str)
        local parts = {}
        for value in str:gmatch("[^;]+") do
            table.insert(parts, value)
        end

        local key = parts[1]
        local x, y, z, rx, ry, rz = tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]), tonumber(parts[5]),
            tonumber(parts[6]), tonumber(parts[7])

        local cframe = CFrame.new(x, y, z) * CFrame.Angles(rx, ry, rz)
        return key, cframe
    end

    local function SaveCoordinate(key)
        local character = player.Character
        if not character then
            return false
        end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            return false
        end

        SavedCoords[key] = rootPart.CFrame
        return true
    end

    local function GetCoordinate(key)
        return SavedCoords[key]
    end

    local function sendWebhookMessage(strCoord)
		showNotif("Webhook", "Sending webhook message for checkpoint: " .. strCoord)
        local embed = {
            embeds = {{
                title = "ℹ️ New checkpoint reached!",
                description = string.format("%s reached **Checkpoint 20**!\n\`\`\`%s\`\`\`", player.Name, strCoord),
                color = 16019256,
                footer = {
                    text = "Keep unlock next checkpoints!"
                },
                thumbnail = {
                    url = "https://cdn.discordapp.com/embed/avatars/2.png"
                }
            }}
        }

        local payload = {
            username = player.Name,
            content = HttpService:JSONEncode(embed)
        }
        local jsonPayload = HttpService:JSONEncode(payload)

        local success, response = pcall(function()
            return HttpService:PostAsync(Const.Config.WebhookUrl, jsonPayload)
        end)
    end

    local function TeleportTo(key)
        local cframe = SavedCoords[key]
        if not cframe then
            return
        end

        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = cframe
            shwNotif("Teleported", "Teleported to '" .. key .. "'")
        end
    end

    local function GetCoordinateKeys()
        local keys = {}
        for key, _ in pairs(SavedCoords) do
            table.insert(keys, key)
        end
        table.sort(keys) -- opsional, biar urut alfabetis
        return keys
    end

    local CheckPointDropdown = TeleportSection:Dropdown({
        Title = "Checkpoint",
        Values = GetCoordinateKeys(),
        Callback = function(selected)
            selectedCheckpoint = selected
        end
    })

    local NewCPInput = TeleportSection:Input({
        Title = "New checkpoint name",
        Callback = function(text)
            selectedCheckpoint = text
        end
    })

    local TPButton = TeleportSection:Button({
        Title = "Teleport",
        Callback = function()
            if selectedCheckpoint then
                TeleportTo(selectedCheckpoint)
            end
        end
    })

    local HStack = TeleportSection:HStack()

    local DeleteButton = HStack:Button({
        Title = "Delete",
        Icon = "lucide:trash",
        Callback = function()
            if not selectedCheckpoint then
                showNotif("Error", "Tidak ada checkpoint yang dipilih!")
                return
            end
            if not SavedCoords[selectedCheckpoint] then
                showNotif("Error", "Checkpoint tidak ditemukan!")
                return
            end
            local deletedName = selectedCheckpoint
            SavedCoords[selectedCheckpoint] = nil
            selectedCheckpoint = nil

            if not SavedCoords[deletedName] then
                CheckPointDropdown:Refresh(GetCoordinateKeys())
                CheckPointDropdown:Select(nil)
                showNotif("Deleted", "Checkpoint '" .. deletedName .. "' deleted!")
            end
        end
    })

    local SaveButton = HStack:Button({
        Title = "Save",
        Icon = "lucide:save",
        Callback = function()
            if selectedCheckpoint == "" then
                showNotif("Error", "Nama checkpoint kosong!")
                return
            end
            local success = SaveCoordinate(selectedCheckpoint)
            if success then
                CheckPointDropdown:Refresh(GetCoordinateKeys()) -- update dropdown biar muncul yang baru
                NewCPInput:Set("")
                sendWebhookMessage(CFrameToString(selectedCheckpoint, SavedCoords[selectedCheckpoint]))
                showNotif("Saved", "Checkpoint '" .. selectedCheckpoint .. "' saved!")
            end
        end
    })
end
-- */ END Teleport Tab /* --

-- */ Settings Tab /* --
do
    local MiscSection = Tabs.SettingsTab:Section({
        Title = "Miscellaneous",
        Box = true,
        Opened = true
    })

    -- */ Anti-AFK init /* --
    local AntiAFK = {}
    AntiAFK.Enabled = false
    AntiAFK.IdleThreshold = 15 * 60
    local lastInput = tick()
    local heartbeatConn = nil
    local inputConns = {}

    local function resetTimer()
        lastInput = tick()
    end

    function AntiAFK.Toggle(state)
        AntiAFK.Enabled = state
        if heartbeatConn then
            heartbeatConn:Disconnect()
            heartbeatConn = nil
        end
        for _, conn in ipairs(inputConns) do
            conn:Disconnect()
        end
        inputConns = {}
        if not state then
            return
        end
        lastInput = tick()
        table.insert(inputConns, UserInputService.InputBegan:Connect(resetTimer))
        table.insert(inputConns, UserInputService.InputChanged:Connect(resetTimer))

        task.spawn(function()
            while AntiAFK.Enabled do
                task.wait(50)
                if AntiAFK.Enabled and tick() - lastInput >= AntiAFK.IdleThreshold then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                    lastInput = tick()
                end
            end
        end)
    end

    local AFKToggle = MiscSection:Toggle({
        Title = "Anti-AFK",
        Type = "Checkbox",
        Value = true, -- default value
        Flag = "Settings_Misc_AntiAFK",
        Callback = function(state)
            AntiAFK.Toggle(state)
            if state then
                showNotif("Settings changes", "Anti-AFK enabled")
            else
                showNotif("Settings changes", "Anti-AFK disabled")
            end
        end
    })
    -- */ END Anti-AFK init /* --
end
-- */ END Settings Tab /* --
