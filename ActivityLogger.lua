--Configuration --
local groupId = replace with the groupID you want to log
local staffRankId = replace with the ranks you want logged
local webhookUrl = "your proxied script goes here"

-- Services --
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Main Code --
local SECONDS_PER_HOUR = 3600
local SECONDS_PER_MINUTE = 60

webhookUrl = webhookUrl:gsub("https://discord.com", "https://hooks.hyra.io")
webhookUrl = webhookUrl:gsub("https://discordapp.com", "https://hooks.hyra.io")
webhookUrl - webhookUrl:gsub("https://ptb.discord.com", "https://ptb.hooks.hyra.io")

function convertSeconds(seconds)
	local hours = 0
	local minutes = 0
	while(seconds >= SECONDS_PER_HOUR) do
		hours += 1
		seconds -= SECONDS_PER_HOUR
	end
	while(seconds >= SECONDS_PER_MINUTE) do
		minutes += 1
		seconds -= SECONDS_PER_MINUTE
	end
	local returnedString = hours .. " hours, " .. minutes .. " minutes, and " .. seconds .. " seconds"
	return returnedString
end

function logData(playerName, joinTime, leaveTime, timeSpent)
	local s,e = pcall(function()
		HttpService:RequestAsync({
			Url = webhookUrl,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = HttpService:JSONEncode({
				content = nil,
				embeds = {
					{
						title = "replace this with your custom header",
						description = "I have successfully logged the activity for " .. playerName,
						color = 672940,
						fields = {
							{
								name = "Activity Data",
								value = "Join Time: " .. joinTime .. "\nLeave Time: " .. leaveTime .. "\nTime Spent: " .. timeSpent
							}
						},
						footer = {
							text = "replace this with your custom footer"
						}
					}
				}
			})
		})
	end)
	if(e) then
		warn("There was an error while attempting to log the activity data for " .. playerName)
	end
end

local data = {}

Players.PlayerAdded:Connect(function(plr)
	local plrRank = plr:GetRankInGroup(groupId)
	if(plrRank >= staffRankId) then
		local joinData = {
			playerId = plr.UserId,
			joinTime = os.time()
		}
		table.insert(data, joinData)
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	local userId = plr.UserId
	local leaveTime = os.time()
	local playerJoinData
	local index
	for i,joinData in pairs(data) do
		if(joinData.playerId == userId) then
			playerJoinData = joinData
			index = i
		end
	end
	if(playerJoinData == nil) then return end
	local playerName = Players:GetNameFromUserIdAsync(userId)
	local timeInGame = leaveTime - playerJoinData.joinTime
	local joinString = os.date("%I:%M:%S %p on %A, %B %d, %Y", playerJoinData.joinTime)
	local leaveString = os.date("%I:%M:%S %p on %A, %B %d, %Y", leaveTime)
	local timeString = convertSeconds(timeInGame)
	logData(playerName, joinString, leaveString, timeString)
	table.remove(data, index)
end)
