-- Connected DIscord-Github, Discord Username: kuroshanki, Roblox Username: qgegaming
local PlayersService = game:GetService("Players")

PlayersService.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local hrp = char:WaitForChild("HumanoidRootPart")
		local humanoid = char:WaitForChild("Humanoid")
		local hurtbox = Instance.new("Part")
		hurtbox.Parent = char
		hurtbox.Size = Vector3.new(4, 6, 2.5)
		hurtbox.CFrame = hrp.CFrame
		hurtbox.Transparency = 0.5
		hurtbox.CanCollide = false
		hurtbox.Massless = true
		hurtbox.CanQuery = true
		hurtbox.Name = "HurtBox"

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = hrp
		weld.Part1 = hurtbox
		weld.Parent = hurtbox
	end)
end)
