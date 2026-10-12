local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local Network = require(ReplicatedStorage.Shared.Network)
local Types = require(ReplicatedStorage.Shared.Types)

local UIController = {}
local Player = Players.LocalPlayer

local ScreenGui: ScreenGui
local StatsLabel: TextLabel
local RebirthButton: TextButton
local UpgradeButton: TextButton
local HatchButton: TextButton
local ClickButton: TextButton
local PetListFrame: ScrollingFrame

function UIController.Init()
	UIController.BuildHUD()

	local syncRemote = Network.GetOrCreateRemote(Network.Names.DataSync)
	syncRemote.OnClientEvent:Connect(UIController.UpdateData)
end

function UIController.BuildHUD()
	local playerGui = Player:WaitForChild("PlayerGui")

	ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "SimulatorHUD"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = playerGui

	-- Top Bar: Stats
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(0, 420, 0, 50)
	topBar.Position = UDim2.new(0.5, -210, 0, 15)
	topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	topBar.BorderSizePixel = 0
	topBar.Parent = ScreenGui

	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 10)
	topCorner.Parent = topBar

	StatsLabel = Instance.new("TextLabel")
	StatsLabel.Size = UDim2.new(1, -20, 1, 0)
	StatsLabel.Position = UDim2.new(0, 10, 0, 0)
	StatsLabel.BackgroundTransparency = 1
	StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	StatsLabel.Font = Enum.Font.FredokaOne
	StatsLabel.TextSize = 18
	StatsLabel.Text = "Clicks: 0  |  Gems: 100  |  Rebirths: 0"
	StatsLabel.Parent = topBar

	-- Center Right: Action Buttons container
	local buttonContainer = Instance.new("Frame")
	buttonContainer.Name = "ButtonContainer"
	buttonContainer.Size = UDim2.new(0, 200, 0, 220)
	buttonContainer.Position = UDim2.new(1, -220, 0.5, -110)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Parent = ScreenGui

	local uiList = Instance.new("UIListLayout")
	uiList.Padding = UDim.new(0, 10)
	uiList.Parent = buttonContainer

	-- Hatch Button
	HatchButton = UIController.CreateButton("Hatch Basic Egg (250 Clicks)", Color3.fromRGB(85, 170, 85), buttonContainer)
	HatchButton.MouseButton1Click:Connect(function()
		local remote = Network.GetOrCreateRemote(Network.Names.HatchEgg)
		remote:FireServer("BasicEgg")
	end)

	-- Upgrade Click Button
	UpgradeButton = UIController.CreateButton("Upgrade Click (50 Clicks)", Color3.fromRGB(50, 130, 220), buttonContainer)
	UpgradeButton.MouseButton1Click:Connect(function()
		local remote = Network.GetOrCreateRemote(Network.Names.UpgradeClick)
		remote:FireServer()
	end)

	-- Rebirth Button
	RebirthButton = UIController.CreateButton("Rebirth (1,000 Clicks)", Color3.fromRGB(220, 70, 70), buttonContainer)
	RebirthButton.MouseButton1Click:Connect(function()
		local remote = Network.GetOrCreateRemote(Network.Names.Rebirth)
		remote:FireServer()
	end)

	-- Giant Center Click Button
	ClickButton = Instance.new("TextButton")
	ClickButton.Name = "ClickButton"
	ClickButton.Size = UDim2.new(0, 160, 0, 160)
	ClickButton.Position = UDim2.new(0.5, -80, 0.8, -80)
	ClickButton.BackgroundColor3 = Color3.fromRGB(240, 165, 0)
	ClickButton.Font = Enum.Font.FredokaOne
	ClickButton.TextSize = 28
	ClickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	ClickButton.Text = "TAP!\n👆"
	ClickButton.Parent = ScreenGui

	local clickCorner = Instance.new("UICorner")
	clickCorner.CornerRadius = UDim.new(1, 0) -- Circular button
	clickCorner.Parent = ClickButton

	-- Punchy button press animation
	ClickButton.MouseButton1Down:Connect(function()
		TweenService:Create(ClickButton, TweenInfo.new(0.05), { Size = UDim2.new(0, 140, 0, 140), Position = UDim2.new(0.5, -70, 0.8, -70) }):Play()
	end)
	ClickButton.MouseButton1Up:Connect(function()
		TweenService:Create(ClickButton, TweenInfo.new(0.1, Enum.EasingStyle.Back), { Size = UDim2.new(0, 160, 0, 160), Position = UDim2.new(0.5, -80, 0.8, -80) }):Play()
		local remote = Network.GetOrCreateRemote(Network.Names.Click)
		remote:FireServer()
	end)

	-- Left Side: Pet Inventory Frame
	local invFrame = Instance.new("Frame")
	invFrame.Name = "InventoryFrame"
	invFrame.Size = UDim2.new(0, 200, 0, 260)
	invFrame.Position = UDim2.new(0, 20, 0.5, -130)
	invFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	invFrame.Parent = ScreenGui

	local invCorner = Instance.new("UICorner")
	invCorner.CornerRadius = UDim.new(0, 8)
	invCorner.Parent = invFrame

	local invTitle = Instance.new("TextLabel")
	invTitle.Size = UDim2.new(1, 0, 0, 30)
	invTitle.BackgroundTransparency = 1
	invTitle.Font = Enum.Font.FredokaOne
	invTitle.TextSize = 16
	invTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	invTitle.Text = "Pets Inventory"
	invTitle.Parent = invFrame

	PetListFrame = Instance.new("ScrollingFrame")
	PetListFrame.Size = UDim2.new(1, -10, 1, -40)
	PetListFrame.Position = UDim2.new(0, 5, 0, 35)
	PetListFrame.BackgroundTransparency = 1
	PetListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	PetListFrame.ScrollBarThickness = 4
	PetListFrame.Parent = invFrame

	local petListLayout = Instance.new("UIListLayout")
	petListLayout.Padding = UDim.new(0, 5)
	petListLayout.Parent = PetListFrame
end

function UIController.CreateButton(text: string, color: Color3, parent: Instance): TextButton
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 50)
	btn.BackgroundColor3 = color
	btn.Font = Enum.Font.FredokaOne
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	return btn
end

function UIController.UpdateData(data: Types.PlayerData)
	StatsLabel.Text = string.format("Clicks: %d  |  Gems: %d  |  Rebirths: %d", data.Clicks, data.Gems, data.Rebirths)

	local rebirthCost = Config.GetRebirthCost(data.Rebirths)
	RebirthButton.Text = string.format("Rebirth\n(%d Clicks)", rebirthCost)

	local upgradeCost = Config.GetUpgradeCost(data.ClickUpgradeLevel)
	UpgradeButton.Text = string.format("Upgrade Click (Lvl %d)\n(%d Clicks)", data.ClickUpgradeLevel, upgradeCost)

	-- Update Pet List
	for _, child in ipairs(PetListFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _, pet in ipairs(data.Inventory) do
		local isEquipped = table.find(data.EquippedPets, pet.Id) ~= nil
		local petBtn = Instance.new("TextButton")
		petBtn.Size = UDim2.new(1, -6, 0, 35)
		petBtn.BackgroundColor3 = if isEquipped then Color3.fromRGB(40, 140, 60) else Color3.fromRGB(50, 50, 60)
		petBtn.Font = Enum.Font.GothamMedium
		petBtn.TextSize = 12
		petBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		petBtn.Text = string.format("%s (x%.1f) %s", pet.Name, pet.Multiplier, if isEquipped then "[ON]" else "[OFF]")
		petBtn.Parent = PetListFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = petBtn

		petBtn.MouseButton1Click:Connect(function()
			local equipRemote = Network.GetOrCreateRemote(Network.Names.EquipPet)
			equipRemote:FireServer(pet.Id)
		end)
	end

	PetListFrame.CanvasSize = UDim2.new(0, 0, 0, #data.Inventory * 40)
end

return UIController
