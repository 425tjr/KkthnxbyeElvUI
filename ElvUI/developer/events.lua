
SLASH_CPU1 = "/cpu"
SlashCmdList["CPU"] = function(arg)
	if GetCVar("scriptProfile")==0 then
		SetCVar("scriptProfile", 1)
		ReloadUI()
		return
	end

	if arg == nil or arg == "" then arg = 10	end
	
	local frameInfo = {}
	local frame = EnumerateFrames()
	while frame do
		if frame:GetName() then
			local	usage, calls = GetFrameCPUUsage(frame, true)
			frameInfo[#frameInfo + 1] = { frame:GetName(), usage, calls }
		end
    frame = EnumerateFrames(frame)
	end
	
	table.sort(frameInfo, function(a, b) return a[2] > b[2] end)
	
	ChatFrame1:AddMessage("***** Events Top "..arg.."*****")
	for i = 1, tonumber(arg) do
		ChatFrame1:AddMessage(string.format("%s [%d ms] -> %d calls.", frameInfo[i][1], frameInfo[i][2], frameInfo[i][3]))
	end
	ChatFrame1:AddMessage("*****")

end