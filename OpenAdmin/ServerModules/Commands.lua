--------------------------
--		Commands		--
--------------------------

--// Setting some stuff to nil so the script doesn't complain the variables 
--// aren't real (the returned function can see everything in the main script)
Settings = nil
Remote = nil
Admin = nil

return function()
	--[[
		Commands are the things players will actually run via the chat.
		These are arguably the most important part of an admin script as
		without these the script would be useless.
	--]]
	
	Admin:AddCommand({
		Prefix = Settings.Prefix;
		Command = "test";
		Arguments = {"arg1", "arg2", "arg3"};
		Description = "Test Command";
		Level = 1;
		Function = function(plr, args)
			print("THIS IS A TEST");
			print("FIRST ARG: "..tostring(args[1]))
			print("PLAYER RUNNING: "..tostring(plr))
			print("ALL ARGS: "..table.concat(args, ","))
			
			for i,v in next,Admin.Commands do
				print(v.Prefix..v.Command..Settings.SplitKey.. table.concat(v.Arguments, Settings.SplitKey))
			end
			
			print("RUNNING REMOTE EVENT TEST~!:")
			print("RETURN FROM CLIENT: ".. tostring(Remote:Get(plr, "RemoteTest", 1, 2, 3, 4, 5) or "NOTHING RETURNED?"))
			print("FINISHED RUNNING COMMAND");
		end;
	})
	
	Admin:AddCommand({
		Prefix = Settings.Prefix;
		Command = "cmds";
		Arguments = {};
		Description = "Shows a list of commands you can use";
		Level = 1;
		Function = function(plr, args)
			local tab = {}
			local level = Admin:GetLevel(plr)
			
			for i,v in next,Admin.Commands do
				if v.Level <= level then
					table.insert(tab, {
						Text = v.Prefix .. v.Command .. Settings.SplitKey .. table.concat(v.Arguments, Settings.SplitKey);
						Desc = v.Description or "No Description";
					})
				end
			end
			
			Remote:Send(plr, "LaunchUI", "List", {
				Title = "Commands";
				Table = tab;
			})
		end;
	})
	
	Admin:AddCommand({
		Prefix = Settings.Prefix;
		Command = "setlevel";
		Arguments = {"player", "newlevel"};
		Level = 2;
		Description = "Allows you to set the admin level of a player lower than you to a new level that is less than your own";
		Function = function(plr, args)
			assert(args[1] and tonumber(args[2]), "Argument missing or nil")
			
			local plrLevel = Admin:GetLevel(plr)
			local newLevel = tonumber(args[2])
			
			if newLevel >= plrLevel then
				error("Level cannot be higher than player running's level")
			end
			
			for i,v in next,Admin:FilterPlayers(plr, args[1]) do
				local targLevel = Admin:GetLevel(v)
				if plrLevel > targLevel then
					Admin:SetLevel(v, newLevel)
				end
			end
		end
	})
	
	Admin:AddCommand({
		Prefix = Settings.Prefix;
		Command = "respawn";
		Arguments = {"player"};
		Level = 1;
		Description = "Respawns the target player";
		Function = function(plr, args)
			local target = args[1] or plr.Name
			
			for i,v in next,Admin:FilterPlayers(plr, target) do
				v:LoadCharacter()
			end
		end
	})
	
	Admin:AddCommand({
		Prefix = Settings.Prefix;
		Command = "kick";
		Arguments = {"player", "reason"};
		Level = 2;
		Description = "Disconnects the target player from the server";
		Function = function(plr, args)
			assert(args[1], "Argument 1 missing or nil");
			
			local plrLevel = Admin:GetLevel(plr)
			
			for i,v in next,Admin:FilterPlayers(plr, args[1]) do
				local targLevel = Admin:GetLevel(v)
				if targLevel < plrLevel then
					v:Kick(args[2])
				end
			end
		end
	})
	
	Admin:AddCommand({
		Prefix = Settings.Prefix;
		Command = "ban";
		Arguments = {"player", "reason"};
		Level = 2;
		Description = "Bans the target player from the server";
		Function = function(plr, args)
			assert(args[1], "Argument 1 missing or nil");
			
			local plrLevel = Admin:GetLevel(plr)
			
			for i,v in next,Admin:FilterPlayers(plr, args[1]) do
				local targLevel = Admin:GetLevel(v)
				if targLevel < plrLevel then
					table.insert(Admin.BanList, {Name = v.Name, UserId = v.UserId})
					Admin:SetLevel(v, -1)
					v:Kick(args[2])
				end
			end
		end
	})
	
	Admin:AddCommand({
		Prefix = Settings.Prefix;
		Command = "unban";
		Arguments = {"name or userid"};
		Level = 2;
		Description = "Unbans the target player from the server";
		Function = function(plr, args)
			assert(args[1], "Argument 1 missing or nil");
			
			local plrLevel = Admin:GetLevel(plr)
			for i,v in next, Admin.BanList do
				if v.Name:lower():sub(1, #args[1]) == args[1]:lower() or v.UserId == tonumber(args[1]) then
					table.remove(Admin.BanList, i)
					Admin:SetLevel({v.UserId}, 0)
				end
			end
		end
	})
end