--------------------------
--		Interface		--
--------------------------

Core = nil
Remote = nil
Interface = nil

return function()
	Interface = {}
	
	function Interface:LaunchUI(guiName, guiData)
		local gui = script:FindFirstChild(guiName)
		if gui then
			local new = gui:Clone()
			local code = (new:IsA("ModuleScript") and new) or new:FindFirstChild("CodeModule")
			if code then
				return Core:LoadModule(code, nil, guiData)
			end
		end
	end
	
	Remote:AddRemote("LaunchUI", function(args)
		return Interface:LaunchUI(args[1], args[2])
	end)
end