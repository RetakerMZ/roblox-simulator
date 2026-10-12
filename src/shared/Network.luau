local Network = {}

Network.Names = {
	Click = "ClickRequest",
	Rebirth = "RebirthRequest",
	HatchEgg = "HatchEggRequest",
	UpgradeClick = "UpgradeClickRequest",
	EquipPet = "EquipPetRequest",
	DataSync = "DataSyncEvent",
}

function Network.GetOrCreateRemote(name: string, isFunction: boolean?): Instance
	local folder = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
	if not folder then
		if game:GetService("RunService"):IsServer() then
			folder = Instance.new("Folder")
			folder.Name = "Remotes"
			folder.Parent = game:GetService("ReplicatedStorage")
		else
			folder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 10)
		end
	end

	local remote = folder:FindFirstChild(name)
	if not remote and game:GetService("RunService"):IsServer() then
		remote = Instance.new(if isFunction then "RemoteFunction" else "RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end

	return remote
end

return Network
