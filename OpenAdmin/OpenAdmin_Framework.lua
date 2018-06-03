																																																	--[=[
	
	Project: Open Admin
	
	The goal of this project is to provide a barebones framework that can be used to easilly make an admin script with
	little scripting knowledge. The purpose is to enable users to create their own admins scripts easily. Anyone who
	wants to make a simple admin script for whatever their reasons may be can use this to do it.
	
	This supports:
		Server - Client communication
		Basic Commands
		Admin Levels (With group ranks support)
		Basic Interface (Includes a ported version of Adonis' Window GUI/API)
		
	
	If you use this, I only ask that you leave any existing credits intact. 
	
	Credits:
		Sceleratis 		- Wrote the Framework
		YourNameHere	- WhatYouDidHere
		SomeoneElse		- WhatTheyHelpedWithhere
		
			
	API Information:
		Remote.Functions 				--// Table containins all remote functions
		Remote:GetPlayerData(Player)	--// Returns the data table for a player (Stores information related to their session)
		Remote:Send(Player, ...) 		--// Sends data to the client or server
		Remote:Get(Player, ...)			--// Sends data to the client or server and gets returns
		
		Admin.Commands 								--// Table containins all admin commands
		Admin:AddCommand(Table)						--// Adds a new command to Admin.Commands
		Admin:ExtractArguments(msg, split, num)		--// Extracts command arguments from a message
		Admin:FilterPlayers(Player, msg)			--// Gets a filtered list of players
		Admin:GetLevel(Player)						--// Returns the admin level of the player (non-admins are 0)
		Admin:ProcessMessage(Player, Message)		--// Handles player message processing (finds if the message is a command)
		
		You can easilly add onto the script by adding modules to their appropriate module folder (ServerModules or ClientModules)
		Just remember to update the LoadOrder table (Under the Variables section) to include the new module's name, otherwise
		it won't be loaded by the script. It's also important to note that LoadOrder determines the order in which modules are
		loaded. So if a module needs something from another module (for instance if Commands needs to use stuff from Remote)
		then that module should be placed after the module it needs in LoadOrder, otherwise might not see the functions or 
		variables from the other module it needs. 
		
		Add commands to the Commands module under ServerModules.
			
																																																	--]=]--]]

--------------------------
--		Settings		--
--------------------------
Settings = {
	Prefix = ";";		--// The character at the beginning of a command message (the : in :kick/all)
	SplitKey = " ";		--// The character used to cut up a message into various arguments used by commands (the / in :kick/all)
	Users = {			--// A table containing administrative users and their levels (or banned users if the level is -1 or lower)
		{				
			UserId = -1, --// Test Server "Player1"
			Level = 999
		};
		{
			Name = "Sceleratis", 
			UserId = 1237666,
			Level = 2
		};
		{
			Name = "ExampleGuy", 
			Level = -1 		--// To ban people or groups, just set their admin level to -1
		};
		{
			Group = 123456;	--// Give admin to anyone in rank 123 of group 123456
			Rank = 123; 
			Level = 1;
		};
		{
			Group = 123456;	--// Give admin to anyone in rank 126 or above in group 123456
			Rank = -126;
			Level = 2;
		}
	};
}


----------------------------------
--		Global Variables		--
----------------------------------
Core = {}
Remote = {
	Functions = {}
}
Admin = {
	BanList = {};
	Commands = {};
}

--------------------------
--		Variables		--
--------------------------
local LoadOrder = { --// Order the modules are loaded in
	"Update";
	"Commands";
}

local BypassLevels = {}
local Folder = script.Parent
local Client = Folder.Client
local Modules = Folder.ServerModules
local Players = game:GetService("Players")
local EventParent = game:GetService("JointsService")
local WaiterEvents = {}
local PrefixCache = {}
local PlayerData = {}
local CurrentEvent
local EventCheck
local MakeRemoteEvent
local LoadClient
local NewPlayer
local PlayerLeft


------------------------------
--		API Functions		--
------------------------------
function Admin:FilterPlayers(plr, filter)
	filter = filter:lower()
	if filter == "me" then
		return {plr}
	elseif filter == "all" then
		return Players:GetPlayers()
	elseif Players:FindFirstChild(filter) then
		return {Players:FindFirstChild(filter)}
	else
		local players = {} 
		
		for name in filter:gmatch('([^,]+)') do
			for i,player in next,Players:GetPlayers() do
				if player.Name:lower():sub(1, #name) == name:lower() then
					table.insert(players, player)
				end
			end
		end
		
		return players
	end
end

function Admin:AddCommand(cmdData)
	cmdData.Prefix = cmdData.Prefix or Settings.Prefix
	cmdData.Arguments = cmdData.Arguments or {}
	cmdData.Level = cmdData.Level or cmdData.AdminLevel or 4
	
	PrefixCache[cmdData.Prefix] = true
	setfenv(cmdData.Function, getfenv())
	table.insert(Admin.Commands, cmdData)
end

function Admin:ExtractArguments(message, key, numArgs)
	local args = {}
	local argLen = 0
	
	for arg in message:gmatch("([^".. key .."]+)") do
		if #args == numArgs-1 then
			table.insert(args, message:sub(argLen + 2, #message))
			break
		else
			argLen = argLen + string.len(arg) + 1
			table.insert(args, arg)
		end
	end
	
	return args
end

function Admin:GetLevel(plr)
	if BypassLevels[plr.UserId] and tonumber(BypassLevels[plr.UserId]) then
		return BypassLevels[plr.UserId]
	else
		local plrData = Remote:GetPlayerData(plr)
		for i,v in next,Settings.Users do
			if v.Group and v.Rank and plrData and plrData.Groups then
				for i,group in next,plrData.Groups do
					if group.Id == v.Group and (group.Rank == v.Rank or (v.Rank < 0 and group.Rank >= math.abs(v.Rank))) then
						return v.Level
					end
				end
			elseif plr.Name == v.Name or plr.UserId == v.UserId then
				return v.Level
			end
		end
		
		return 0
	end
end

function Admin:SetLevel(plr, newLevel)
	BypassLevels[plr.UserId] = newLevel
end

function Admin:ProcessMessage(plr, message)
	if message:sub(1, 2) == "/e" then
		message = message:sub(4)
	end
	
	if PrefixCache[message:sub(1,1)] then
		local playerLevel = Admin:GetLevel(plr)
		local SplitKey = Settings.SplitKey
		
		for i,cmd in next,Admin.Commands do
			local cmdString = string.lower(cmd.Prefix .. cmd.Command)
			if playerLevel >= cmd.Level and message:lower():sub(1,#cmdString) == cmdString:lower() then
				local cmdArgs = Admin:ExtractArguments(message:sub(#cmdString+#SplitKey), SplitKey, #cmd.Arguments)
				local ran,err = pcall(cmd.Function, plr, cmdArgs)
				if not ran then
					Remote:Send(plr, "CommandError", message, err)
				end
			end
		end
	end
end

function Remote:GetPlayerData(p)
	return PlayerData[p.UserId]
end

function Remote:AddFunction(index, func)
	Remote.Functions[index] = func
end

function Remote:Send(p, ...)
	local data = Remote:GetPlayerData(p)
	if data and data.RemoteReady and CurrentEvent then
		CurrentEvent:FireClient(p, "Passive", ...)
	end
end

function Remote:Get(p, func, ...)
	local data = Remote:GetPlayerData(p)
	if data and data.RemoteReady and CurrentEvent then
		local waiterValue = math.random() .. math.random()
		local newEvent = Instance.new("BindableEvent")
		local returns
		
		newEvent.Event:Connect(function(...) returns = {...} end)
		WaiterEvents[waiterValue] = newEvent
		CurrentEvent:FireClient(p, "GetReturn", func, waiterValue, ...)
		
		if not returns then
			delay(120, function() newEvent:Fire() end)
			returns = {newEvent.Event:Wait()}
		end
		
		WaiterEvents[waiterValue] = nil
		newEvent:Destroy()
		
		if returns and type(returns) == "table" then
			return unpack(returns)
		end
	end
end	

------------------------------------------
--		Player Added&Left Handlers		--
------------------------------------------
function PlayerAdded(p)
	local plrLevel = Admin:GetLevel(p)
	if plrLevel < 0 then
		p:Kick("Banned")
	else
		PlayerData[p.UserId] = {
			Groups = game:GetService("GroupService"):GetGroupsAsync(p.UserId)
		}
		
		LoadClient(p)
		p.Chatted:Connect(function(msg)
			Admin:ProcessMessage(p, msg)
		end)
	end
end

function PlayerLeft(p)
	PlayerData[p.UserId] = nil
end


------------------------------
--		Core Functions		--
------------------------------
function Core:LoadModule(module, custEnv, ...)
	return setfenv(require(module), setmetatable(custEnv or {script = module},{
		__index = function(self, ind)
			return getfenv()[ind]
		end;
		
		__newindex = function(self, ind, val)
			getfenv()[ind] = val
		end;
	}))(...)
end


function MakeRemoteEvent()
	local newEvent = Instance.new("RemoteEvent")
	newEvent.Name = "__OpenAdminFrameworkEvent"
	newEvent.Parent = EventParent
	
	if EventCheck then
		EventCheck:Disconnect()
	end
	
	if CurrentEvent then
		CurrentEvent:Destroy()
	end
	
	newEvent.OnServerEvent:Connect(function(p, mode, func, misc, ...)
		if p and mode and type(mode) == "string" and func and type(func) == "string" then
			local funcToRun = Remote.Functions[func]
			if funcToRun then
				if mode == "GetReturn" then
					print("GIVING RETURN?")
					Remote:Send(p, "GiveReturn", misc, funcToRun(p, {...}))
				else
					print("RUNNING REMOTE FUNC")
					funcToRun(p, {misc, ...})
				end
			end
		end
	end)
	
	CurrentEvent = newEvent
	EventCheck = newEvent.Changed:Connect(function(p)
		MakeRemoteEvent()
	end)
end

function LoadClient(p)
	local newClient = Client:Clone()
	local modules = Folder.ClientModules:Clone()
	
	modules.Parent = newClient
	newClient.Parent = p:FindFirstChild("PlayerGui") or p:WaitForChild("Backpack")
	
	if newClient.Parent then
		newClient.Disabled = false
	else
		warn("Failed to load client for ".. p.Name)
	end
end


----------------------
--		Remote		--
----------------------
Remote:AddFunction("ClientLoaded", function(plr, args)
	local data = Remote:GetPlayerData(plr)
	if data then
		data.RemoteReady = true
	end
end)

Remote:AddFunction("GiveReturn", function(plr, args)
	local waiter = args[1]
	if waiter then
		local event = WaiterEvents[waiter]
		if event then
			event:Fire(select(2, unpack(args)))
		end
	end
end)


--------------------------
--		 Startup		--
--------------------------
Folder.Parent = game:GetService("ServerScriptService") 

MakeRemoteEvent()

for i,name in ipairs(LoadOrder) do 
	local module = Modules:FindFirstChild(name) 
	if module then 
		Core:LoadModule(module) 
	end 
end

for i,p in next,Players:GetPlayers() do 
	NewPlayer(p) 
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerLeft)
EventParent.ChildRemoved:Connect(function(child)
	if CurrentEvent and child == CurrentEvent then
		MakeRemoteEvent()
	end
end)

warn("OpenAdmin Framework Loaded")



----------------------
--		Done		--
----------------------










