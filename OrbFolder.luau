-- Connected DIscord-Github, Discord Username: kuroshanki, Roblox Username: qgegaming
local PlayersService = game:GetService("Players")

PlayersService.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local orbFolder = Instance.new("Folder")
		orbFolder.Name = "OrbFolder"
		orbFolder.Parent = char
	end)
end)
