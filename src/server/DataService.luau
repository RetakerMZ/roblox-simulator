local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Network = require(ReplicatedStorage.Shared.Network)
local Types = require(ReplicatedStorage.Shared.Types)

local DataService = {}
local SessionData: { [Player]: Types.PlayerData } = {}

local DATA_KEY = "SimPlayerData_v1"
local Store = nil
pcall(function()
	Store = DataStoreService:GetDataStore(DATA_KEY)
end)

local function DeepCopy(t)
	local copy = {}
	for k, v in pairs(t) do
		copy[k] = if type(v) == "table" then DeepCopy(v) else v
	end
	return copy
end

function DataService.Init()
	for _, remoteName in pairs(Network.Names) do
		Network.GetOrCreateRemote(remoteName)
	end

	Players.PlayerAdded:Connect(DataService.OnPlayerAdded)
	Players.PlayerRemoving:Connect(DataService.OnPlayerRemoving)
	game:BindToClose(DataService.OnClose)

	task.spawn(function()
		while true do
			task.wait(60)
			for player, _ in pairs(SessionData) do
				DataService.Save(player)
			end
		end
	end)
end

function DataService.OnPlayerAdded(player: Player)
	local data = DeepCopy(Config.DefaultData)

	if Store then
		local success, result = pcall(function()
			return Store:GetAsync(tostring(player.UserId))
		end)
		if success and result then
			for k, v in pairs(result) do
				data[k] = v
			end
		end
	end

	SessionData[player] = data

	-- Create leaderstats for native Roblox UI
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local clicks = Instance.new("IntValue")
	clicks.Name = "Clicks"
	clicks.Value = data.Clicks
	clicks.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = data.Rebirths
	rebirths.Parent = leaderstats

	local gems = Instance.new("IntValue")
	gems.Name = "Gems"
	gems.Value = data.Gems
	gems.Parent = leaderstats

	leaderstats.Parent = player

	DataService.Sync(player)
end

function DataService.Get(player: Player): Types.PlayerData?
	return SessionData[player]
end

function DataService.Sync(player: Player)
	local data = SessionData[player]
	if not data then return end

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		if leaderstats:FindFirstChild("Clicks") then leaderstats.Clicks.Value = data.Clicks end
		if leaderstats:FindFirstChild("Rebirths") then leaderstats.Rebirths.Value = data.Rebirths end
		if leaderstats:FindFirstChild("Gems") then leaderstats.Gems.Value = data.Gems end
	end

	local syncEvent = Network.GetOrCreateRemote(Network.Names.DataSync)
	if syncEvent then
		syncEvent:FireClient(player, data)
	end
end

function DataService.Save(player: Player)
	local data = SessionData[player]
	if not data or not Store then return end

	pcall(function()
		Store:SetAsync(tostring(player.UserId), data)
	end)
end

function DataService.OnPlayerRemoving(player: Player)
	DataService.Save(player)
	SessionData[player] = nil
end

function DataService.OnClose()
	for player, _ in pairs(SessionData) do
		DataService.Save(player)
	end
end

return DataService
