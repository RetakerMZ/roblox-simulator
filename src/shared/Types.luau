export type Pet = {
	Id: string,
	Name: string,
	Rarity: string,
	Multiplier: number,
}

export type PlayerData = {
	Clicks: number,
	Gems: number,
	Rebirths: number,
	Inventory: { Pet },
	EquippedPets: { string }, -- Pet Ids
	ClickUpgradeLevel: number,
}

return {}
