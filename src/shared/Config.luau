local Config = {}

Config.DefaultData = {
	Clicks = 0,
	Gems = 100,
	Rebirths = 0,
	Inventory = {},
	EquippedPets = {},
	ClickUpgradeLevel = 1,
}

Config.MaxEquippedPets = 3
Config.ClickDebounceTime = 0.1 -- 100ms anti-macro limit

Config.GetRebirthCost = function(rebirths: number): number
	return math.floor(1000 * (2.5 ^ rebirths))
end

Config.GetRebirthMultiplier = function(rebirths: number): number
	return 1 + (rebirths * 0.5)
end

Config.GetUpgradeCost = function(level: number): number
	return math.floor(50 * (1.8 ^ (level - 1)))
end

Config.Eggs = {
	BasicEgg = {
		Cost = 250,
		Currency = "Clicks",
		Pets = {
			{ Name = "Dog", Rarity = "Common", Weight = 50, Multiplier = 1.2 },
			{ Name = "Cat", Rarity = "Common", Weight = 35, Multiplier = 1.5 },
			{ Name = "Bunny", Rarity = "Rare", Weight = 12, Multiplier = 2.5 },
			{ Name = "Golden Dragon", Rarity = "Legendary", Weight = 3, Multiplier = 6.0 },
		},
	},
}

return Config
