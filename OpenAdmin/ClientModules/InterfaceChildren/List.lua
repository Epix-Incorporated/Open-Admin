Remote = nil
Interface = nil

return function(data)
	local Title = data.Title or data.Name or "List"
	local Table = data.Table or {}
	local window = Interface:LaunchUI("Window", {
		Name = "ListWindow";
		Title = Title;
		Size  = data.Size or {225, 200};
		MinSize = {150, 100};
	})
	
	local scroller = window:Add("ScrollingFrame", {
		BackgroundTransparency = 1;
	})
	
	scroller:GenerateList(Table)
	
	window:Ready()
end