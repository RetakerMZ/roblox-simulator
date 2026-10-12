local DataService = require(script.DataService)
local ClickService = require(script.ClickService)
local RebirthService = require(script.RebirthService)
local EggService = require(script.EggService)
local UpgradeService = require(script.UpgradeService)

-- Bootstrap services
DataService.Init()
ClickService.Init()
RebirthService.Init()
EggService.Init()
UpgradeService.Init()

print("[Server] Roblox Simulator core services initialized successfully.")
