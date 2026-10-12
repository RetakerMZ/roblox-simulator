local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Network = require(ReplicatedStorage.Shared.Network)
local DataService = require(script.Parent.DataService)

local RebirthService = {}

function RebirthService.Init()
	local rebirthRemote = Network.GetOrCreateRemote(Network.Names.Rebirth)
	rebirthRemote.OnServerEvent:Connect(RebirthService.OnRebirth)
end

function RebirthService.OnRebirth(player: Player)
	local data = DataService.Get(player)
	if not data then return end

	local cost = Config.GetRebirthCost(data.Rebirths)
	if data.Clicks < cost then
		return
	end

	data.Clicks = 0
	data.Rebirths += 1
	data.Gems += (data.Rebirths * 25)

	DataService.Sync(player)
end

return RebirthService
