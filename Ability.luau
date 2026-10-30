-- Connected DIscord-Github, Discord Username: kuroshanki, Roblox Username: qgegaming
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProjectileEvent = ReplicatedStorage.Ability.ProjectileEvent
local ProjectileArcEvent = ReplicatedStorage.Ability.ProjectileArcEvent
local DashEvent = ReplicatedStorage.Ability.DashEvent
local ShockWaveEvent = ReplicatedStorage.Ability.ShockWaveEvent
local OrbEvent = ReplicatedStorage.Ability.OrbEvent
local OrbRemoteEvent = ReplicatedStorage.Ability.OrbRemoteEvent
local OrbAttackEvent = ReplicatedStorage.Ability.OrbAttackEvent
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
-- template
-- orb config
local ORB_CONFIG = {
	OrbitingOrbRadius = 7, -- set the radius/how far the distance between the orb to the player to 7
	OrbDuration = 2, -- set the duration for how long the orb going to orbit around the player
	OuterOrbRadius = 40, -- set the radius/how far the distance between the orb to the player to40 
	OrbProjectileSpeed = 75, -- set the projectile launch speed to 75
	SPEED = 10, -- set the orbiting orbit for how fast the orb going to orbit the player
}

local orbFolder = workspace:WaitForChild("OrbFolder") -- get the OrbFolder from workspace for filtering the raycast
local orbProjectileTemplate = game:GetService("ServerStorage").CircleProjectile -- get the projectile asset for the orb projectile that going to be shot when something hit the raycast
	
	
local fireballObject = game.ServerStorage:WaitForChild("Projectile") -- get the fireball asset for the fireball projectile that is going to be use in "ProjectileEvent"

ProjectileArcEvent.OnServerEvent:Connect(function(player, mousePos) -- after the server get triggered by the client, it will run a event and receive the player and mousePos arguments
	local char = player.Character -- get the player model
	if not char then return end -- if it didn't found the player model it will return false
	
	local SPEED = 100 -- speed value
	local GRAVITY_MULT = 0.25 -- gravity value
	local MAX_DISTANCE = 250 -- maximum distance the projetile can go

	-- setup
	local origin = char:WaitForChild("HumanoidRootPart").Position  -- player position
	local direction = (mousePos - origin).Unit  -- the direction of where the projectile will go, using Unit so that it only store the direction and not the speed
	local gravity = Vector3.new(0, -workspace.Gravity, 0) * GRAVITY_MULT -- the gravite value of the projectile
	-- projectile
	local projectile = fireballObject:Clone() -- clone the projectile
	projectile.CFrame = CFrame.new(origin, origin + direction) -- make the projectile starting position to be at the player position and rotate the projectile to the finish direction
	projectile.Parent = workspace -- set the parent of the projectile to workspace

	-- velocity
	local velocity = direction * SPEED -- the starting speed of the projectile
	local position = origin -- the current position of the projectile
	local totalDistance = 0 -- the total distance of the projectile
	local elapsed = 0 -- elapsed time of how long has the runservice run
	local connection -- store the curret active connection
	connection = RunService.Heartbeat:Connect(function(deltaTime)-- the projectile will move every frame
		elapsed += deltaTime
		local stepVelocity = velocity + gravity * deltaTime -- the next speed of the projectile after being affect by gravity
		local stepDisplacement = (velocity + stepVelocity) / 2 * deltaTime -- calculate the positional displacemt(distance traveled) involve multiplying the average of the old and new speeds by the time. Resulting in very smooth parabolic motion.
		velocity = stepVelocity -- the new velocity/speed of the projectile in this frame

		local nextPosition = position + stepDisplacement -- calculate the new position of the projectile in this frame
		projectile.CFrame = CFrame.new(nextPosition, nextPosition + velocity.Unit) -- the new position of project and its rotation so that if it going down the model also will look down

		position = nextPosition -- changing the position of the projectile
		totalDistance += stepDisplacement.Magnitude -- calculate the total distance of the projectile in this frame

		-- cleanup
		if totalDistance >= MAX_DISTANCE then -- if the totalDIstance that the projectile has traveled is more than the MAX_DISTANCE it will disconnect the connection and destroy the projectile
			projectile:Destroy() -- destroy the projectile after reaching it maximum distance
			connection:Disconnect() -- disconnect the Event to make sure there no memory leak
		end
	end)
end)

ProjectileEvent.OnServerEvent:Connect(function(player, mousePos)
	local char = player.Character -- get the player model
	if not char then return end -- if it didn't found the player model it will return false
	
	local SPEED = 100 -- speed value for how fast the projectile going to be shot
	local DURATION = 2 -- duration value for how long the projectile going to last
	
	local origin = char:WaitForChild("HumanoidRootPart").Position  -- player position
	local direction = (mousePos - origin).Unit -- get the direction of where the projectile going to be shot by subtractig the mouse position and the player position, then change the value to unit
	
	local projectile = fireballObject:Clone() --  clone the projectile
	projectile.CFrame = CFrame.new(origin, origin + direction) -- make the projectile starting position to be at the player position and rotate the projectile to the finish direction
	projectile.Parent = workspace -- set the projectile parent to workspace
	
	local velocity = direction * SPEED -- the starting speed of the projectile
	local position = origin -- the current position of the projectile
	local totalDistance = 0 -- the total distance of the projectile
	local Attachment = Instance.new("Attachment") -- make an attachment for the linearvelocity attachment0
	Attachment.Name = "Attachment0" -- set the naem to "Attachment0"
	Attachment.Parent = projectile -- set the parent to projectile
	local linearVelocity = Instance.new("LinearVelocity") -- make a linearVelocity as a way to shot the projectile using physic
	linearVelocity.MaxForce = math.huge -- set the maxforce to math.huge so that it wont get limited
	linearVelocity.Parent = projectile -- set the parent to projectile
	linearVelocity.VectorVelocity = velocity -- the projectil will shot at the with the power the velocity variable from calculating the speed * direction
	linearVelocity.Attachment0 = Attachment -- set the attachment0 to the attachment that is parented on the projectile
	
	local elapsed = 0 -- elapsed time of how long has the runservice run
	local connection -- store the current active runservice
	connection = RunService.Heartbeat:Connect(function(deltaTime)
		elapsed += deltaTime -- calculated how long the runservice has been running
		
		if elapsed >= DURATION then -- if the elapsed time is more than 2 second or how long the duration is set then
			projectile:Destroy() -- destroy the projectile
			connection:Disconnect() -- then disconnect the current runservice 
		end
	end)
end)

DashEvent.OnServerEvent:Connect(function(player, speed)
	local char = player.Character -- get the player model
	if not char then return end -- if it didn't found the player model then it will return false and stop the code
	
	local humanoid = char:WaitForChild("Humanoid") -- get the Humanoid
	if not humanoid then return end -- if it didn't found the humanoid then it will return false and stop the code
	
	local hrp = char:WaitForChild("HumanoidRootPart") -- get the HumanoidRootPart
	if not hrp then return end -- if it didn't found the hrp then it will return false and stop the code

	 -- the direction of where the player move
	local Attachment = Instance.new("Attachment") -- make an attachment for the linearvelocity attachment0
	Attachment.Name = "Attachment0" -- set the name to "Attachment0"
	Attachment.Parent = hrp -- set the parent to hrp
	local connection -- store the current active connection
	connection = RunService.Heartbeat:Connect(function(deltaTime)
		local direction = humanoid.MoveDirection -- the direction of where the player model is currently facing
		local velocity = direction * speed -- the amount of force the dash based on the player direction
		local dashVelocity = Instance.new("LinearVelocity") -- make a linearVelocity as a way to make the player dash using physic
		dashVelocity.MaxForce = math.huge -- set the maxforce to math.huge so that it wont get limited
		dashVelocity.Parent = hrp -- set the pareont to hrp
		dashVelocity.VectorVelocity = velocity -- player will dash at the with the power the velocity variable from calculating the speed * direction
		dashVelocity.Attachment0 = Attachment -- set the attachment0 to the attachment that is parented on the player hrp
		task.wait(0.3) -- after 0.3 second
		if dashVelocity then -- and a dash velocity is true
			dashVelocity:Destroy() -- the DashVelocity,
			Attachment:Destroy() -- Attchment instance and 
			connection:Disconnect() -- connection will be destroy/disconnect and the player will stop moving
		end
	end)
end)

OrbEvent.OnServerEvent:Connect(function(player, orbMode, startTime, orbColor)
		
		local startTime = workspace:GetServerTimeNow() -- get the current server time when the client invoke/call the server
		local isHit = false -- boolean variable to send to the client
		local isTouched = false -- variable for -- debounce so that the projectile only hit the target once
		OrbRemoteEvent:FireClient(player, startTime, orbColor, isHit) -- sending the startTIme, orbColor, and isHurtBox arguments to the client
		-- Character Clause
		local character = player.Character -- get the player model from the player argument
		if not character then return end -- if it didn't found the player model it will return a false
		
		local humanoid = character:WaitForChild("Humanoid") -- get the player humanoid instance
		if not humanoid then return end -- if it didn't found the Humanoid from char it will return a false

		local hrp = character:WaitForChild("HumanoidRootPart")
		if not hrp then return end -- if it didn't found the HumanoidRootPart it will return a false
		
		local connection
		connection = RunService.Heartbeat:Connect(function(deltaTime)
		local elapsed = workspace:GetServerTimeNow() - startTime  -- counting the elapsed time by getting the currentServerTime - startTime, so that the client is synchronized to the server
				local sinX = math.sin(elapsed * ORB_CONFIG["SPEED"]) * ORB_CONFIG["OrbitingOrbRadius"] -- calculate the circling movement using sin and cos, the angle is calculated by multiplyinig elapsed * speed * ORBITING_ORB_RADIUS, matching the calculation on both side
				local cosZ = math.cos(elapsed * ORB_CONFIG["SPEED"]) * ORB_CONFIG["OrbDuration"]
				local outerOrbPosition = hrp.Position + Vector3.new(math.sin(elapsed * ORB_CONFIG["SPEED"]) * ORB_CONFIG["OuterOrbRadius"],0,math.cos(elapsed * ORB_CONFIG["SPEED"]) * ORB_CONFIG["OuterOrbRadius"])
				local orbitingOrbPosition = hrp.Position + Vector3.new(sinX,0,cosZ)
				if orbMode == "buff" then -- if the orbMode argument is "buff" the player will get an increase in speed
					humanoid.WalkSpeed = 25
					humanoid.JumpHeight = 10
					humanoid.MaxHealth = 130
				elseif orbMode == "attack" then
					local rayCastParams = RaycastParams.new()
					rayCastParams.FilterDescendantsInstances = {hrp.Parent, orbFolder:GetChildren()}
					rayCastParams.FilterType = Enum.RaycastFilterType.Exclude
					
					local rayDirection = outerOrbPosition - orbitingOrbPosition
					local rayResult = workspace:Raycast(orbitingOrbPosition, rayDirection, rayCastParams)
					
					if rayResult then -- run the code if something hit the ray cast
						--print(rayResult.Instance)
						if rayResult.Instance.Name == "HurtBox" then -- run the code if the ray cast result is an instance with the name "HurtBox"
							isHit = true
							OrbRemoteEvent:FireClient(player, startTime, orbColor, isHit) -- fire the client again to disconnected the client orbiting connection
							-- make the player humanoid root part collision group to the player id so that it 
							local Projectile = orbProjectileTemplate:Clone() -- clone the projetile template once
							Projectile.Parent = workspace -- set the parent to workspace
							Projectile.Position = orbitingOrbPosition -- make the starting position the same as the orb position
							Projectile.Color = orbColor -- change the color to the current orb mode color
							Projectile.CanCollide = false -- make the projectile cannot collide

							local direction = (rayResult.Position - Projectile.Position).Unit
							local projectileAttachment = Instance.new("Attachment") -- make an attachment for the linear velocity
							projectileAttachment.Parent = Projectile

							local projectileVelocity = Instance.new("LinearVelocity")
							projectileVelocity.Parent = Projectile -- set the parent to the projectile
							projectileVelocity.Attachment0 = projectileAttachment -- set the attacment to the projectile attachment
							projectileVelocity.VectorVelocity = direction * ORB_CONFIG["OrbProjectileSpeed"] -- set the velocity value to the where the direction is time by launchspeed
							projectileVelocity.MaxForce = math.huge -- set the maximum force to math.huge so that it wont get limit
							local touchedEvent
							touchedEvent = Projectile.Touched:Connect(function(touchedPart)
								if isTouched then return end
								
								local char = touchedPart.Parent
								local humanoid = char and char:FindFirstChild("Humanoid")
								local isPlayer = humanoid.Parent
								if isPlayer ~= character and humanoid and humanoid.Health > 0 then -- get all of the instance that the projectile hit
									isTouched = true -- set the isTouched variable to true for debouncing
									touchedEvent:Disconnect() -- disconnect the touhedEvent
									Projectile:Destroy() -- destroy the projectile
									humanoid.Health -= 10 -- damage the humanoid that got hit by 10
									print(character)
									return
								end
								
								local foundPart = workspace:GetPartsInPart(Projectile) -- if the first check doesn't work it will go to this block of code
								for _, part in ipairs(foundPart) do -- loop through the foundPart table
									
									local c = part.Parent -- get the character from the parent of part that the projectile hit
									local h = c:FindFirstChild("Humanoid") -- get the humanoid from the player model

 										if h and h.Health > 0 then -- only trigger the code if the ray cast hit a humanoid and it health value is more than 0
										isTouched = true
										touchedEvent:Disconnect()
										Projectile:Destroy() 
										h.Health -= 10
										print(humanoid)
										return
									end
								end

								task.wait(.1) -- wait for 0.1 second so that the target can only
								isTouched = false -- set it back to false
							end)
							connection:Disconnect() -- disconnect the connection after the ray hit something
						end

					else
						print("nothing has hit the ray")
					end
				end
			if elapsed >= ORB_CONFIG["OrbDuration"] then -- after 2 seconds
				connection:Disconnect() -- disconnect the current connection
			end
		end)
end)