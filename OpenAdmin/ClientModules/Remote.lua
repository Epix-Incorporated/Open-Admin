Remote = nil

return function()
	----------------------
	--		Remote		--
	----------------------
	print("WE ARE IN A MODULE!")
	
	Remote:AddRemote("RemoteTest", function(args)
		print("THIS IS A REMOTE TEST")
		print("ARGS[1]: ".. tostring(args[1]))
		print("ALL ARGS: ".. table.concat(args, ", "))
		return "THIS IS A RETURN FROM THE CLIENT!"
	end)
end