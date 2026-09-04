local RunService = game:GetService("RunService")

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))

local WindUI

do
	local ok, result = pcall(function()
		return require("./src/Init")
	end)

	if ok then
		WindUI = result
	else
		if cloneref(game:GetService("RunService")):IsStudio() then
			WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
		else
			WindUI =
				loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
		end
	end
end

-- */  Window  /* --
local Window = WindUI:CreateWindow({
	Title = "TestRbx  |  WindUI Example",
	Author = "by xia0nai",
	Folder = "xia0nai_TestRbx",
	Icon = "solar:folder-2-bold-duotone",
	Theme = "Crimson",
	--IconSize = 22*2,
	NewElements = true,
	--Size = UDim2.fromOffset(700,700),
	HideSearchBar = false,
	OpenButton = {
		Title = "Open TestRbx", -- can be changed
		CornerRadius = UDim.new(1, 0), -- fully rounded
		StrokeThickness = 3, -- removing outline
		Enabled = true, -- enable or disable openbutton
		Draggable = true,
		OnlyMobile = false,
		Scale = 0.5,
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

--Window:SetUIScale(.8)

-- */  Tags  /* --
do
	Window:Tag({
		Title = "v0.0.1-alpha.1",
		Icon = "github",
		Color = Color3.fromHex("#1c1c1c"),
		Border = true,
	})
end