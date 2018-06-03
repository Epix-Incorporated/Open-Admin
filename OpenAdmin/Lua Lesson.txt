--[==[
	This Module aims to cover some basic information regarding Lua and it's data types or some terminology so
	you have somewhat of a better idea for what certain things are, do, or mean. 
	
	Variables:	
		local SomeTable = {"hi"}		- This is a table. More specifically tables are represented as two curly brackets {}. Tables can contain anything.
		local SomeBool = true 			- This is a boolean. It can be either true or false (1 or 0 for you binary nerds)
		local SomeNumber = 132.42		- Number variable, I don't think I need to explain what a number is. 
		local SomeString = "hi there"	- This is a string. It's plaintext. Anything surrounded by quotes is read by Lua as a string
		
		function SomeFunction() print(1) end	- This is a function. It's a little block of code we can run via it's name when we need to and can pass data to it
		
		game						-- This is the game (or DataModel) object of ROBLOX. It contains everything you would see in the Explorer window of Roblox Studio (along with a bunch of other stuff that you don't normally see
		workspace 					-- Little bit of shortcut to game.Workspace; Workspace holds everything you see rendered in-game (parts, models, etc) (not guis though)
		game:GetService("Players")	-- game:GetService will find or create the service we are looking for (in this case the Players service)
		game.Workspace.ChildAdded	-- This is a RbxScriptSignal; We can connect functions to it that will run when something happens



	Misc Info:		
		Anytime you see the word "nil" it means "nothing"		
		
		-- This is a single line comment
		
		--[[
			This is a multi-line block comment
			Hi
			There
		--]]
		
		Below will run our function everytime a child is added to workspace and will print out the child's name 
		(Child is another word for an object within another object)
		(For example, if we have a Part in Workspace, Workspace would be the Parent, and Part would be the Child)
		
			game.Workspace.ChildAdded:Connect(function(child) 
				print("A child was added! It's name is: ".. child.Name)
			end)
		
		
		Anythimg you see something like "My name is: ".. someString it means we are combining two strings. 
		We can do this with just variables, and we can combine numbers with strings as well
			
			local FirstVar = "Hello"
			local SecondVar = "World"
		
			print(FirstVar .. SecondVar)
			> Prints "HelloWorld"
		
		
	Local vs Global:
		A global variable is a variable that we can access from anywhere in a script, regardless of where it was defined.
		A local variable is a variable that's bound by scope
		A variables scope is basically the area in a script where that variable can be seen
		
		Any local variables declared within a loop or function would be within that loop or function's scope,
		so nothing outside of that loop or function would be able to see that local variable
		A local variable's scope depends on where it was declared, however where it's defined doesn't matter as long
		as the place where it's defined is able to see the variable.
		
		Example:
		
			function someFunc()
				local someVar = 12345
			end
			
			someFunc() 		--// Run someFunc
		print(someVar) 	--// Print someVar 
			
			> Output: nil
			
		We can't print someVar because someVar is local and was declared within the function someFunc, so anything outside
		of someFunc cannot see someVar. Now we can change that by declaring it outside of someFunc and then defining it
		(setting it) inside of someFunc
			
			local someVar 
			
			function someFunc()
				someVar = 1234
			end
			
			someFunc()		--// Run someFunc (someFunc will set someVar to 1234)
			print(someVar)	--// Print someVar
			
			> Output: 1234
			
		Now there is another way to see the value of someVar without declaring it outside of someFunc ahead of time.
		We can return whatever someVar is equal to from someFunc
			
			function someFunc()
				local someVar = 1234
				return someVar
			end
			
			print(someFunc())	--// print whatever someFunc() returns
			
			> Output: 1234
			
		We can also do this in reverse and actually pass data to the function we are calling
			
			function someFunc(someVar)
				print(someVar)
			end
			
			someFunc(1234)
			
			> Output: 1234
			
		Globals aren't bound by any scope, they reside in the environment of the 
		script (a big table that contains all global variables for a script or function)
		
			function someFunc()
					someGlobal = 1234
			end
			
			someFunc()
			print(someGlobal)
			
			> Output: 1234
			
			
			
		
		If you would like to know more about Lua the Roblox Wiki (wiki.roblox.com) has some nice tutorials.
		You can also just search for anything you're unsure about online and get the info you need pretty quickly.
		This small (very brief) lesson just serves to prepare you for some of things you will see within the script
		if you are new to Lua (specifically Roblox Lua).
		
--]==]