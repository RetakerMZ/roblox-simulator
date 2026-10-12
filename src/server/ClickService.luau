local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Network = require(ReplicatedStorage.Shared.Network)
local DataService = require(script.Parent.DataService)

local ClickService = {}
local LastClick: { [Player]: number } = {}

function ClickService.Init()
	local clickRemote = Network.GetOrCreateRemote(Network.Names.Click)
	clickRemote.OnServerEvent:Connect(ClickService.OnClick)
end

function ClickService.OnClick(player: Player)
	local now = os.clock()
	local last = LastClick[player] or 0
	if now - last < Config.ClickDebounceTime then
		return -- Ignore rate-limited clicks
	end
	LastClick[player] = now

	local data = DataService.Get(player)
	if not data then return end

	-- Calculate Pet Multiplier
	local petMultiplier = 1
	for _, pet in ipairs(data.Inventory) do
		if table.find(data.EquippedPets, pet.Id) then
			petMultiplier = petMultiplier * pet.Multiplier
		end
	end

	-- Rebirth Multiplier
	local rebirthMultiplier = Config.GetRebirthMultiplier(data.Rebirths)

	-- Base power from upgrades
	local basePower = data.ClickUpgradeLevel

	-- Total gained
	local gained = math.floor(basePower * petMultiplier * rebirthMultiplier)
	data.Clicks += math.max(1, gained)

	DataService.Sync(player)
end

return ClickService
