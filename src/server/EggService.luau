local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Network = require(ReplicatedStorage.Shared.Network)
local DataService = require(script.Parent.DataService)

local EggService = {}

function EggService.Init()
	local hatchRemote = Network.GetOrCreateRemote(Network.Names.HatchEgg)
	local equipRemote = Network.GetOrCreateRemote(Network.Names.EquipPet)

	hatchRemote.OnServerEvent:Connect(EggService.OnHatch)
	equipRemote.OnServerEvent:Connect(EggService.OnEquip)
end

function EggService.OnHatch(player: Player, eggName: string)
	local egg = Config.Eggs[eggName or "BasicEgg"]
	if not egg then return end

	local data = DataService.Get(player)
	if not data then return end

	if egg.Currency == "Clicks" and data.Clicks < egg.Cost then
		return
	elseif egg.Currency == "Gems" and data.Gems < egg.Cost then
		return
	end

	-- Deduct cost
	if egg.Currency == "Clicks" then
		data.Clicks -= egg.Cost
	else
		data.Gems -= egg.Cost
	end

	-- Roll weighted pet
	local totalWeight = 0
	for _, pet in ipairs(egg.Pets) do
		totalWeight += pet.Weight
	end

	local roll = math.random() * totalWeight
	local cumulative = 0
	local chosenPetDef = egg.Pets[1]

	for _, pet in ipairs(egg.Pets) do
		cumulative += pet.Weight
		if roll <= cumulative then
			chosenPetDef = pet
			break
		end
	end

	-- Create new pet item
	local newPet = {
		Id = HttpService:GenerateGUID(false),
		Name = chosenPetDef.Name,
		Rarity = chosenPetDef.Rarity,
		Multiplier = chosenPetDef.Multiplier,
	}

	table.insert(data.Inventory, newPet)

	-- Auto-equip if slot free
	if #data.EquippedPets < Config.MaxEquippedPets then
		table.insert(data.EquippedPets, newPet.Id)
	end

	DataService.Sync(player)
end

function EggService.OnEquip(player: Player, petId: string)
	local data = DataService.Get(player)
	if not data then return end

	local exists = false
	for _, pet in ipairs(data.Inventory) do
		if pet.Id == petId then
			exists = true
			break
		end
	end
	if not exists then return end

	local equippedIndex = table.find(data.EquippedPets, petId)
	if equippedIndex then
		table.remove(data.EquippedPets, equippedIndex)
	else
		if #data.EquippedPets < Config.MaxEquippedPets then
			table.insert(data.EquippedPets, petId)
		end
	end

	DataService.Sync(player)
end

return EggService
