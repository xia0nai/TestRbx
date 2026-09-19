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
	SettingsTab = Window:Tab({
		Title = "Settings",
		Icon = "lucide:settings",
	}),
}

-- */ Settings Tab /* --
do
	local AboutSection = Tabs.SettingsTab:Section({
		Title = "Miscellaneous",
	})

	local AFKToggle = AboutSection:Toggle({
    Title = "Anti-AFK",
    Type = "Checkbox",
    Value = false, -- default value
    Callback = function(state) 
        showNotif("Settings changes", "Anti-AFK was applied")
    end
})
end