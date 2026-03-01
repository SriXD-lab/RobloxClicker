local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local clickStore = DataStoreService:GetDataStore("PlayerClickData_v1")

local CLICK_EVENT_NAME = "ClickEvent"
local REBIRTH_COST = 100
local DEFAULT_MULTIPLIER = 1

local clickEvent = ReplicatedStorage:FindFirstChild(CLICK_EVENT_NAME)
if not clickEvent then
	clickEvent = Instance.new("RemoteEvent")
	clickEvent.Name = CLICK_EVENT_NAME
	clickEvent.Parent = ReplicatedStorage
end

local sessionData = {}

local function createLeaderstats(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local clicks = Instance.new("IntValue")
	clicks.Name = "Clicks"
	clicks.Value = 0
	clicks.Parent = leaderstats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = leaderstats

	local multiplier = Instance.new("IntValue")
	multiplier.Name = "ClickMultiplier"
	multiplier.Value = DEFAULT_MULTIPLIER
	multiplier.Parent = player

	return clicks, rebirths, multiplier
end

local function getPlayerData(player)
	local key = "Player_" .. player.UserId
	local success, data = pcall(function()
		return clickStore:GetAsync(key)
	end)

	if success and typeof(data) == "table" then
		return {
			Clicks = tonumber(data.Clicks) or 0,
			Rebirths = tonumber(data.Rebirths) or 0,
			Multiplier = tonumber(data.Multiplier) or DEFAULT_MULTIPLIER,
		}
	end

	return {
		Clicks = 0,
		Rebirths = 0,
		Multiplier = DEFAULT_MULTIPLIER,
	}
end

local function savePlayerData(player)
	local cached = sessionData[player]
	if not cached then
		return
	end

	local key = "Player_" .. player.UserId
	local payload = {
		Clicks = cached.Clicks.Value,
		Rebirths = cached.Rebirths.Value,
		Multiplier = cached.Multiplier.Value,
	}

	pcall(function()
		clickStore:SetAsync(key, payload)
	end)
end

Players.PlayerAdded:Connect(function(player)
	local clicks, rebirths, multiplier = createLeaderstats(player)
	local data = getPlayerData(player)

	clicks.Value = data.Clicks
	rebirths.Value = data.Rebirths
	multiplier.Value = math.max(DEFAULT_MULTIPLIER, data.Multiplier)

	sessionData[player] = {
		Clicks = clicks,
		Rebirths = rebirths,
		Multiplier = multiplier,
	}
end)

Players.PlayerRemoving:Connect(function(player)
	savePlayerData(player)
	sessionData[player] = nil
end)

clickEvent.OnServerEvent:Connect(function(player, action)
	local data = sessionData[player]
	if not data then
		return
	end

	if action == "Rebirth" then
		if data.Clicks.Value >= REBIRTH_COST then
			data.Clicks.Value -= REBIRTH_COST
			data.Rebirths.Value += 1
			data.Multiplier.Value += 2
		end
		return
	end

	data.Clicks.Value += data.Multiplier.Value
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		savePlayerData(player)
	end
end)
