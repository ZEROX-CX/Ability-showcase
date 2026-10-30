-- Connected DIscord-Github, Discord Username: kuroshanki, Roblox Username: qgegaming
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AbilityModule = require(game:GetService("ReplicatedStorage").AbilityModuleScript)
local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local char = player.Character
local UserInputService = game:GetService("UserInputService")
local mouse = player:GetMouse()
local ProjectileEvent = ReplicatedStorage.Ability.ProjectileEvent
local ProjectileArcEvent = ReplicatedStorage.Ability.ProjectileArcEvent
local DashEvent = ReplicatedStorage.Ability.DashEvent
local ShockWaveEvent = ReplicatedStorage.Ability.ShockWaveEvent
local OrbEvent = ReplicatedStorage.Ability.OrbEvent
local OrbRemoteEvent = ReplicatedStorage.Ability.OrbRemoteEvent
local OrbAttackEvent = ReplicatedStorage.Ability.OrbAttackEvent
local hrp = char:WaitForChild("HumanoidRootPart")
-- orb config

local orbColor -- declaring the orb color, later on will be assign with the value of the color like  "Color3.new(0,1,0.117647)", olor3.new(1, 0.0117647, 0.0627451)
local orbMode -- declaring the orb mode, later on will be assign with the value of the mode like "attack", "buff"
local startTime = 0 -- declaring startTime, later on will be assign with the skill activation time
local isSkillActive = false
local OrbFolder = char:WaitForChild("OrbFolder")
local orbTemplate = game.Workspace:WaitForChild("Circle") -- take the circle asset template from workspace
local speed = 10 -- the speed value for how fast the orb going to orbit
local tweenInfo = TweenInfo.new(.5) -- set the tween duration to .5 second
local DURATION = 2
local goal = { -- end goal for orb tween
	Transparency = 1, -- make the orb go transparent
}

-- dash config
local isDashActive = false -- boolean variable for debounce

local abilityInput = { -- table consisting of all the ability input and function
	[Enum.KeyCode.Q] = function()
		if not isDashActive then -- debounce so player cant spam it
			isDashActive = true -- set the isDashActive to true
			DashEvent:FireServer(100) -- fire the remoteEvent along the speed argument so that player will actually dash
			task.wait(3) -- after 3 second
			isDashActive = false -- set isDashActive to false
		end
	end,
	
	[Enum.KeyCode.E] = function()
		local mousePos = mouse.Hit.Position -- get the current mouse position
		ProjectileArcEvent:FireServer(mousePos) -- fire the remoteEvent along the mouse position argument while pressing the keybind
	end,
	
	[Enum.KeyCode.R] = function()
		local mousePos = mouse.Hit.Position -- get the current mouse position
		ProjectileEvent:FireServer(mousePos) -- fire the remoteEvent along the mouse position argument while pressing the keybind
	end,
	
	[Enum.KeyCode.Z] = function()
		orbMode = "attack" -- set the orbMode to "attack"
		orbColor = Color3.new(1, 0.0117647, 0.0627451) -- set the orb color to neon red
		OrbEvent:FireServer(orbMode, startTime, orbColor) -- fire the remoteFunction sending orbMode, orbAMount, MAX_AMOUNT, startTime, orbColor argument
	end,
	
	[Enum.KeyCode.X] = function()
		orbMode = "buff" -- set the orbMode to "buff"
		orbColor = Color3.new(0,1,0.117647) -- set the orb color to neon green
		OrbEvent:FireServer(orbMode, startTime, orbColor) -- fire the remoteFunction sending orbMode, orbAMount, MAX_AMOUNT, startTime, orbColor argument
	end,
	
}


UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	
	local action = abilityInput[input.KeyCode] -- activating the ability inside of the abilityInput table according to the keybind that is pressed
	if action and not isSkillActive then
		isSkillActive = true -- set the isSkillActive to true
		action() -- run the function for the ability acording to the keybind that is pressed
		task.wait(1) -- after 1 second
		isSkillActive = false -- set isSkillActive to false
	end
end)

local connection
OrbRemoteEvent.OnClientEvent:Connect(function(startTime, orbColor, isHit)
	if connection then -- if there already a running runservice/connection
		connection:Disconnect() -- disconnect the current runservice/connection
		connection = nil -- set the connection to nil
	end
	connection = RunService.Heartbeat:Connect(function(deltaTime) -- set the connection variable to runService.Heartbeat along with the deltaTime argument
		local elapsed = workspace:GetServerTimeNow() - startTime -- counting the elapsed time by getting the currentServerTime - startTime argument to make sure the tween synchronize to the server

		local orbitingOrb = orbTemplate:Clone() -- clone the orb every frame to make a clean rotating visual
		orbitingOrb.Parent = OrbFolder -- change the parent to OrbFolder
		orbitingOrb.Anchored = true -- set the anchored to true to make it be unaffected to physic
		orbitingOrb.Color = orbColor -- change the color to to "orbColor" argument
		local orbTween = TweenService:Create(orbitingOrb, tweenInfo, goal) -- creating tween for orbiting Orb
		local sinX = math.sin(elapsed * speed) * 7 -- calculate the circling movement using sin and cos, the angle is calculated by multiplyinig elapsed * speed, matching the calculation on both side
		local cosZ = math.cos(elapsed * speed) * 7

		orbitingOrb.Position = hrp.Position + Vector3.new(sinX,0,cosZ) -- make the orb orbit around the player
		orbTween:Play() -- play the orbTween
		orbTween.Completed:Connect(function() -- destroy the orb instance after the tween is completed
			game.Debris:addItem(orbitingOrb, 0)
		end)
		if isHit then -- after hitting something
			connection:Disconnect() -- disconnect the runservice/connection
			print("disconnect")
		end

		if elapsed >= DURATION then -- after 2 seconds or how long the duration is set 
			print("timeout")
			connection:Disconnect() -- disconnect the connection
		end
	end)
end)
