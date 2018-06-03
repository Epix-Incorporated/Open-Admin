----------------------
--		Remote		--
----------------------

--// Setting some stuff to nil so the script doesn't complain the variables 
--// aren't real (the returned function can see everything in the main script)
Settings = nil
Remote = nil
Admin = nil

return function()
	
	--[[
		These functions are used for communication between the server and client.
		The client can run these using Send(funcName, data) or Get(funcName, data).
		I refer to these as remote commands as they are commands being ran by the client
		via the remote event instead of the chat. We can use the script's RemoteEvent to
		send data between the server and a player's client, these remote command functions just
		make it a little easier or cleaner to deal with the RemoteEvent, instead of just putting
		a bunch of if and elseif statements in the OnServerEvent event. 
		
		It is important to always check if the player is allowed to do something BEFORE
		doing anything. For instance, if you have a function named AddAdmin that adds a name
		to the admin list, you should check that the player sending the data and running the function
		is allowed to add admins. You can do this by checking their level via GetLevel(plr).
		
		While I used AddAdmin as an example, this would be incredibly bad practice as there should
		never be a reason to add new admins via remote commands. 
		
		Send & Get data from the other end via the Send() or Get() functions.
		Send and Get run the same remote functions and do the same thing mostly, however Get() will get whatever
		is returned by the function being ran on the other end, while Send() will just fire and forget. 
	--]]
	
	Remote:AddFunction("GetCommands", function(plr, args)
		return Admin.Commands
	end)
end