local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local DT = E:GetModule('DataTexts')

local TANK_ICON = "|TInterface\\AddOns\\ElvUI\\media\\textures\\tank.tga:14:14|t"
local HEALER_ICON = "|TInterface\\AddOns\\ElvUI\\media\\textures\\healer.tga:14:14|t"
local DPS_ICON = "|TInterface\\AddOns\\ElvUI\\media\\textures\\dps.tga:14:14|t"
local NOBONUSREWARDS = ("%s: N/A"):format(BATTLEGROUND_HOLIDAY)
local lastPanel

local function MakeIconString(tank, healer, damage)
	return ("%s%s%s"):format(tank and TANK_ICON or '', healer and HEALER_ICON or '', damage and DPS_ICON or '')
end

local function OnEvent(self, event, ...)
	local tankReward = false
	local healerReward = false
	local dpsReward = false
	local unavailable = true
	for i=1, GetNumRandomDungeons() do
		local id, name = GetLFGRandomDungeonInfo(i)
		for x = 1,LFG_ROLE_NUM_SHORTAGE_TYPES do
			local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(id, x)
			if eligible and forTank and itemCount > 0 then tankReward = true; unavailable = false; end
			if eligible and forHealer and itemCount > 0 then healerReward = true; unavailable = false; end
			if eligible and forDamage and itemCount > 0 then dpsReward = true; unavailable = false; end
		end
	end	

	if unavailable then
		self.text:SetText(NOBONUSREWARDS)
	else
		self.text:SetFormattedText("%s: %s", BATTLEGROUND_HOLIDAY, MakeIconString(tankReward, healerReward, dpsReward))
	end
	lastPanel = self
end

local function OnClick()
	ToggleFrame(LFDParentFrame)
end

local function ValueColorUpdate(hex, r, g, b)
	NOBONUSREWARDS = ("%s: %sN/A|r"):format(BATTLEGROUND_HOLIDAY, hex)
	
	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

local function OnEnter(self)
	DT:SetupTooltip(self)
	local allUnavailable = true
	local numCTA = 0
	for i=1, GetNumRandomDungeons() do
		local id, name = GetLFGRandomDungeonInfo(i)
		local tankReward = false
		local healerReward = false
		local dpsReward = false
		local unavailable = true
		for x=1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local eligible, forTank, forHealer, forDamage, itemCount = GetLFGRoleShortageRewards(id, x)
			if eligible then unavailable = false end
			if eligible and forTank and itemCount > 0 then tankReward = true end
			if eligible and forHealer and itemCount > 0 then healerReward = true end
			if eligible and forDamage and itemCount > 0 then dpsReward = true end
		end
		
		if not unavailable then
			allUnavailable = false
			local rolesString = MakeIconString(tankReward, healerReward, dpsReward)
			if rolesString ~= ""  then
				DT.tooltip:AddDoubleLine(name..":", rolesString, 1, 1, 1)
			end
			if tankReward or healerReward or dpsReward then numCTA = numCTA + 1 end
		end
	end

	DT.tooltip:Show()
end

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc)

	name - name of the datatext (required)
	events - must be a table with string values of event names to register
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
]]
DT:RegisterDatatext('Call to Arms', {"PLAYER_ENTERING_WORLD", "LFG_UPDATE_RANDOM_INFO"}, OnEvent, nil, OnClick, OnEnter)
