local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Network = require(ReplicatedStorage.Shared.Network)
local DataService = require(script.Parent.DataService)

local UpgradeService = {}

function UpgradeService.Init()
	local upgradeRemote = Network.GetOrCreateRemote(Network.Names.UpgradeClick)
	upgradeRemote.OnServerEvent:Connect(UpgradeService.OnUpgrade)
end

function UpgradeService.OnUpgrade(player: Player)
	local data = DataService.Get(player)
	if not data then return end

	local cost = Config.GetUpgradeCost(data.ClickUpgradeLevel)
	if data.Clicks < cost then
		return
	end

	data.Clicks -= cost
	data.ClickUpgradeLevel += 1

	DataService.Sync(player)
end

return UpgradeService
