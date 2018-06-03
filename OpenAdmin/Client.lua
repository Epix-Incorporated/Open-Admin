--[[
	
	Open Admin Framework Client
	
	This script will run the on every player's client and will communicate with the server as needed.
	You can use the client script to do things like make and control ScreenGuis or other UI things.
	Can also be used to get data from the client and give it to the server. 
	
--]]

----------------------------------
--		Global Variables		--
----------------------------------
Core = {}		--// Core stuff
Variables = {} 	--// Shared variables
Remote = {		--// Remote stuff
	Functions = {}
}

--------------------------
--		Variables		--
--------------------------
local LoadOrder = {
	"Update";
	"Interface";
}

local Modules = script:WaitForChild("ClientModules"):Clone() --// Clone the folder to fix a replication lag issue
local EventParent = game:GetService("JointsService")
local WaiterEvents = {}

local CurrentEvent
local EventCheck
local FindRemoteEvent


------------------------------
--		API Functions		--
------------------------------
function Remote:AddRemote(index, func)
	Remote.Functions[index] = func
end

function Remote:Send(...)
	if CurrentEvent then
		CurrentEvent:FireServer("Passive", ...)
	end
end

function Remote:Get(func, ...)
	if CurrentEvent then
		local waiterValue = math.random() .. math.random()
		local newEvent = Instance.new("BindableEvent")
		local returns
		
		newEvent.Event:Connect(function(...) returns = {...} end)
		WaiterEvents[waiterValue] = newEvent
		CurrentEvent:FireServer("GetReturn", func, waiterValue, ...)
		
		if not returns then
			returns = {newEvent.Event:Wait()}
		end
		
		WaiterEvents[waiterValue] = nil
		newEvent:Destroy()
		
		if returns and type(returns) == "table" then
			return unpack(returns)
		end
	end
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

function FindRemoteEvent()
	local newEvent
	
	repeat 
		newEvent = EventParent:FindFirstChild("__OpenAdminFrameworkEvent")
	until newEvent or not wait()
	
	if newEvent then
		if EventCheck then
			EventCheck:Disconnect()
		end
		
		CurrentEvent = newEvent
		
		newEvent.OnClientEvent:Connect(function(mode, func, misc, ...)
			if mode and type(mode) == "string" and func and type(func) == "string" then
				local funcToRun = Remote.Functions[func]
				if funcToRun then
					if mode == "GetReturn" then
						Remote:Send("GiveReturn", misc, funcToRun({...}))
					else
						funcToRun({misc, ...})
					end
				end
			end
		end)
	end
end


----------------------
--		Remote		--
----------------------
Remote:AddRemote("GiveReturn", function(args)
	local waiter = args[1]
	if waiter then
		local event = WaiterEvents[waiter]
		if event then
			event:Fire(select(2, unpack(args)))
		end
	end
end)


----------------------
--		Startup		--
----------------------
wait()
script:Destroy() -- Destroy the client script (hide it)

for i,name in ipairs(LoadOrder) do
	local module = Modules:FindFirstChild(name)
	if module then
		Core:LoadModule(module)
	end
end

FindRemoteEvent()
EventParent.ChildRemoved:Connect(function(child)
	if CurrentEvent and child == CurrentEvent then
		FindRemoteEvent()
	end
end)

Remote:Send("ClientLoaded")
warn("OpenAdmin Client Loaded")



----------------------
--		Done		--
----------------------












