local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local DT = E:GetModule('DataTexts')

local lastPanel
local armorString = ARMOR..": "
local chanceString = "%.2f%%";
local format = string.format
local displayString = ''; 
local baseArmor, effectiveArmor, armor, posBuff, negBuff
	
local function OnEvent(self, event, unit)
	if event == "UNIT_RESISTANCES" and unit ~= 'player' then return end
	lastPanel = self
	
	baseArmor, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");

	self.text:SetFormattedText(displayString, armorString, effectiveArmor)
	
	int = 2
end


local function OnEnter(self)
	DT:SetupTooltip(self)
	
	GameTooltip:AddLine(L['Mitigation By Level: '])
	GameTooltip:AddLine(' ')
	
	local playerlvl = UnitLevel('player') + 3
	for i = 1, 4 do
		local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, playerlvl);
		GameTooltip:AddDoubleLine(playerlvl,format(chanceString, armorReduction),1,1,1)
		playerlvl = playerlvl - 1
	end
	local lv = UnitLevel("target")
	if lv and lv > 0 and (lv > playerlvl + 3 or lv < playerlvl) then
		local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, lv);
		GameTooltip:AddDoubleLine(lv, format(chanceString, armorReduction),1,1,1)
	end	
		
	GameTooltip:Show()
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = string.join("", "%s", hex, "%d|r")
	
	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc)
	
	name - name of the datatext (required)
	events - must be a table with string values of event names to register 
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
	onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
]]
DT:RegisterDatatext('Armor', {"UNIT_STATS", "UNIT_RESISTANCES", "FORGE_MASTER_ITEM_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE"}, OnEvent, nil, nil, OnEnter)

