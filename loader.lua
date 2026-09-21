local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))

local WindUI

do
    if cloneref(game:GetService("RunService")):IsStudio() then
        WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
    else
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xia0nai/TestRbx/refs/heads/main/dist/main.lua"))()
    end
end

-- */ Show Notification init /* --
function showNotif(section, msg)
	return WindUI:Notify({
		Title = section,
		Content = msg,
		Duration = 3,
		Icon = "lucide:info",
	})
end

-- */  Window  /* --
local Window = WindUI:CreateWindow({
	Title = "TestRbx",
	Author = "by xia0nai",
	Folder = "xia0nai",
	Icon = "solar:atom-bold-duotone",
	Theme = "Crimson",
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
		Scale = 0.7,
		Color = ColorSequence.new( -- gradient
			Color3.fromHex("#30FF6A"),
			Color3.fromHex("#e7ff2f")
		),
	},
	Topbar = {
		Height = 44,
		ButtonsType = "Mac", -- Default or Mac
	},
})
-- */  Scale window  /* --
-- Window:SetUIScale(.7)
-- */  Tags  /* --
do
	Window:Tag({
		Title = "v0.0.1-alpha.1",
		Icon = "github",
		Color = Color3.fromHex("#1c1c1c"),
		Border = true,
	})
end

local Tabs = {
	MainTab = Window:Tab({
		Title = "Main",
		Icon = "lucide:house",
	}),
	TeleportTab = Window:Tab({
		Title = "Teleport",
		Icon = "lucide:map-pin",
	}),
	SettingsTab = Window:Tab({
		Title = "Settings",
		Icon = "lucide:settings",
	}),
}

-- */ Teleport Tab /* --
do
	local TeleportSection = Tabs.TeleportTab:Section({
		Title = "Teleport",
		Box= true,
		Opened = true,
	})

	local player = Players.LocalPlayer
	local SavedCoords = {}
	local selectedCheckpoint = nil

	local function SaveCoordinate(key)
		local character = player.Character
		if not character then
			showNotif("Error", "Character tidak ditemukan")
			return false
		end

		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then
			showNotif("Error", "HumanoidRootPart tidak ditemukan")
			return false
		end

		SavedCoords[key] = rootPart.CFrame
		showNotif("Saved", "Coordinate '" .. key .. "' telah disimpan")
		return true
	end

	local function GetCoordinate(key)
		return SavedCoords[key]
	end

	local function TeleportTo(key)
		local cframe = SavedCoords[key]
		if not cframe then
			showNotif("Error", "Coordinate '" .. key .. "' tidak ada")
			return
		end

		local character = player.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			rootPart.CFrame = cframe
		end
	end

	local function GetCoordinateKeys()
		local keys = {}
		for key, _ in pairs(SavedCoords) do
			table.insert(keys, key)
		end
		table.sort(keys)  -- opsional, biar urut alfabetis
		return keys
	end

	local CheckPointDropdown = TeleportSection:Dropdown({
		Title = "Select checkpoint",
		Values = GetCoordinateKeys(),
		Callback = function(selected)
			selectedCheckpoint = selected
			showNotif("Checkpoint selected: " .. selected)
		end
	})

	local Input = TeleportSection:Input({
		Title = "Input checkpoint name",
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

	local SaveButton = TeleportSection:Button({
		Title = "Save Coordinate",
		Callback = function()
			if selectedCheckpoint == "" then
				showNotif("Error", "Nama checkpoint kosong!")
				return
			end

			local success = SaveCoordinate(selectedCheckpoint)
			if success then
				showNotif("Success", "Checkpoint '" .. selectedCheckpoint .. "' saved!")
				CheckPointDropdown:Refresh(GetCoordinateKeys())  -- update dropdown biar muncul yang baru
			end
		end
	})
end
-- */ END Teleport Tab /* --

-- */ Settings Tab /* --
do
	local MiscSection = Tabs.SettingsTab:Section({
		Title = "Miscellaneous",
		Box= true,
		Opened = true,
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
		if heartbeatConn then heartbeatConn:Disconnect() heartbeatConn = nil end
		for _, conn in ipairs(inputConns) do
			conn:Disconnect()
		end
		inputConns = {}
		if not state then return end
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