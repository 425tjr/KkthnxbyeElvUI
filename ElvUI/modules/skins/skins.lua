local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local S = E:NewModule('Skins', 'AceTimer-3.0', 'AceHook-3.0', 'AceEvent-3.0')

E.Skins = S
S.addonsToLoad = {}
S.nonAddonsToLoad = {}
S.allowBypass = {}
S.EmbeddableAddons = {
	['Recount'] = true,
	['Omen'] = true,
}

local find = string.find

local function SetModifiedBackdrop(self)
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor))	
end

local function SetOriginalBackdrop(self)
	if self.backdrop then self = self.backdrop end
	self:SetBackdropBorderColor(unpack(E["media"].bordercolor))	
end

function S:HandleButton(f, strip)
	if f.Left then f.Left:SetAlpha(0) end
	if f.Middle then f.Middle:SetAlpha(0) end
	if f.Right then f.Right:SetAlpha(0) end
	
	if f.SetNormalTexture then f:SetNormalTexture("") end
	
	if f.SetHighlightTexture then f:SetHighlightTexture("") end
	
	if f.SetPushedTexture then f:SetPushedTexture("") end
	
	if f.SetDisabledTexture then f:SetDisabledTexture("") end
	
	if strip then f:StripTextures() end
	
	f:SetTemplate("Default", true)
	f:HookScript("OnEnter", SetModifiedBackdrop)
	f:HookScript("OnLeave", SetOriginalBackdrop)
end

function S:HandleScrollBar(frame, thumbTrim)
	if _G[frame:GetName().."BG"] then _G[frame:GetName().."BG"]:SetTexture(nil) end
	if _G[frame:GetName().."Track"] then _G[frame:GetName().."Track"]:SetTexture(nil) end
	
	if _G[frame:GetName().."Top"] then
		_G[frame:GetName().."Top"]:SetTexture(nil)
	end
	
	if _G[frame:GetName().."Bottom"] then
		_G[frame:GetName().."Bottom"]:SetTexture(nil)
	end
	
	if _G[frame:GetName().."Middle"] then
		_G[frame:GetName().."Middle"]:SetTexture(nil)
	end

	if _G[frame:GetName().."ScrollUpButton"] and _G[frame:GetName().."ScrollDownButton"] then
		_G[frame:GetName().."ScrollUpButton"]:StripTextures()
		if not _G[frame:GetName().."ScrollUpButton"].icon then
			S:HandleNextPrevButton(_G[frame:GetName().."ScrollUpButton"])
			SquareButton_SetIcon(_G[frame:GetName().."ScrollUpButton"], 'UP')
			_G[frame:GetName().."ScrollUpButton"]:Size(_G[frame:GetName().."ScrollUpButton"]:GetWidth() + 7, _G[frame:GetName().."ScrollUpButton"]:GetHeight() + 7)	
		end
		
		_G[frame:GetName().."ScrollDownButton"]:StripTextures()
		if not _G[frame:GetName().."ScrollDownButton"].icon then
			S:HandleNextPrevButton(_G[frame:GetName().."ScrollDownButton"])
			SquareButton_SetIcon(_G[frame:GetName().."ScrollDownButton"], 'DOWN')
			_G[frame:GetName().."ScrollDownButton"]:Size(_G[frame:GetName().."ScrollDownButton"]:GetWidth() + 7, _G[frame:GetName().."ScrollDownButton"]:GetHeight() + 7)	
		end		
		
		if not frame.trackbg then
			frame.trackbg = CreateFrame("Frame", nil, frame)
			frame.trackbg:Point("TOPLEFT", _G[frame:GetName().."ScrollUpButton"], "BOTTOMLEFT", 0, -1)
			frame.trackbg:Point("BOTTOMRIGHT", _G[frame:GetName().."ScrollDownButton"], "TOPRIGHT", 0, 1)
			frame.trackbg:SetTemplate("Transparent")
		end
		
		if frame:GetThumbTexture() then
			if not thumbTrim then thumbTrim = 3 end
			frame:GetThumbTexture():SetTexture(nil)
			if not frame.thumbbg then
				frame.thumbbg = CreateFrame("Frame", nil, frame)
				frame.thumbbg:Point("TOPLEFT", frame:GetThumbTexture(), "TOPLEFT", 2, -thumbTrim)
				frame.thumbbg:Point("BOTTOMRIGHT", frame:GetThumbTexture(), "BOTTOMRIGHT", -2, thumbTrim)
				frame.thumbbg:SetTemplate("Default", true)
				if frame.trackbg then
					frame.thumbbg:SetFrameLevel(frame.trackbg:GetFrameLevel())
				end
			end
		end	
	end	
end

--Tab Regions
local tabs = {
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"Left",
	"Middle",
	"Right",
}

function S:HandleTab(tab)
	if not tab then return end
	for _, object in pairs(tabs) do
		local tex = _G[tab:GetName()..object]
		if tex then
			tex:SetTexture(nil)
		end
	end
	
	if tab.GetHighlightTexture and tab:GetHighlightTexture() then
		tab:GetHighlightTexture():SetTexture(nil)
	else
		tab:StripTextures()
	end
	
	tab.backdrop = CreateFrame("Frame", nil, tab)
	tab.backdrop:SetTemplate("Default")
	tab.backdrop:SetFrameLevel(tab:GetFrameLevel() - 1)
	tab.backdrop:Point("TOPLEFT", 10, E.PixelMode and -1 or -3)
	tab.backdrop:Point("BOTTOMRIGHT", -10, 3)				
end

function S:HandleNextPrevButton(btn, buttonOverride)
	local norm, pushed, disabled
	local inverseDirection = btn:GetName() and (find(btn:GetName(), 'Left') or find(btn:GetName(), 'Prev') or find(btn:GetName(), 'Decrement'))
	
	btn:StripTextures()
	btn:SetNormalTexture(nil)
	btn:SetPushedTexture(nil)
	btn:SetHighlightTexture(nil)
	btn:SetDisabledTexture(nil)

	if not btn.icon then
		btn.icon = btn:CreateTexture(nil, 'ARTWORK')
		btn.icon:Size(13)
		btn.icon:SetPoint('CENTER')
		btn.icon:SetTexture([[Interface\Buttons\SquareButtonTextures]])
		btn.icon:SetTexCoord(0.01562500, 0.20312500, 0.01562500, 0.20312500)
		
		btn:SetScript('OnMouseDown', function(self)
			if self:IsEnabled() then
				self.icon:SetPoint("CENTER", -1, -1);
			end		
		end)
		
		btn:SetScript('OnMouseUp', function(self)
			self.icon:SetPoint("CENTER", 0, 0);
		end)
		
		btn:SetScript('OnDisable', function(self)
			SetDesaturation(self.icon, true);
			self.icon:SetAlpha(0.5);		
		end)
		
		btn:SetScript('OnEnable', function(self)
			SetDesaturation(self.icon, false);
			self.icon:SetAlpha(1.0);		
		end)
		
		if not btn:IsEnabled() then
			btn:GetScript('OnDisable')(btn)
		end
	end

	if buttonOverride then
		if inverseDirection then
			SquareButton_SetIcon(btn, 'UP')
		else
			SquareButton_SetIcon(btn, 'DOWN')
		end
	else
		if inverseDirection then
			SquareButton_SetIcon(btn, 'LEFT')
		else
			SquareButton_SetIcon(btn, 'RIGHT')
		end	
	end
	
	S:HandleButton(btn)
	btn:Size(btn:GetWidth() - 7, btn:GetHeight() - 7)	
end

function S:HandleRotateButton(btn)
	btn:SetTemplate("Default")
	btn:Size(btn:GetWidth() - 14, btn:GetHeight() - 14)	
	
	btn:GetNormalTexture():SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)
	btn:GetPushedTexture():SetTexCoord(0.3, 0.29, 0.3, 0.65, 0.69, 0.29, 0.69, 0.65)	
	
	btn:GetHighlightTexture():SetTexture(1, 1, 1, 0.3)
	
	btn:GetNormalTexture():SetInside()
	btn:GetPushedTexture():SetAllPoints(btn:GetNormalTexture())	
	btn:GetHighlightTexture():SetAllPoints(btn:GetNormalTexture())
end

function S:HandleEditBox(frame)
	frame:CreateBackdrop("Default")

	if frame.TopLeftTex then frame.TopLeftTex:Kill() end
	if frame.TopRightTex then frame.TopRightTex:Kill() end
	if frame.TopTex then frame.TopTex:Kill() end
	if frame.BottomLeftTex then frame.BottomLeftTex:Kill() end
	if frame.BottomRightTex then frame.BottomRightTex:Kill() end
	if frame.BottomTex then frame.BottomTex:Kill() end
	if frame.LeftTex then frame.LeftTex:Kill() end
	if frame.RightTex then frame.RightTex:Kill() end
	if frame.MiddleTex then frame.MiddleTex:Kill() end
	
	if frame:GetName() then
		if _G[frame:GetName().."Left"] then _G[frame:GetName().."Left"]:Kill() end
		if _G[frame:GetName().."Middle"] then _G[frame:GetName().."Middle"]:Kill() end
		if _G[frame:GetName().."Right"] then _G[frame:GetName().."Right"]:Kill() end
		if _G[frame:GetName().."Mid"] then _G[frame:GetName().."Mid"]:Kill() end
		
		if frame:GetName():find("Silver") or frame:GetName():find("Copper") then
			frame.backdrop:Point("BOTTOMRIGHT", -12, -2)
		end		
	end
end

function S:HandleDropDownBox(frame, width)
	local button = _G[frame:GetName().."Button"]
	if not width then width = 155 end
	
	frame:StripTextures()
	frame:Width(width)
	
	_G[frame:GetName().."Text"]:ClearAllPoints()
	_G[frame:GetName().."Text"]:Point("RIGHT", button, "LEFT", -2, 0)

	
	button:ClearAllPoints()
	button:Point("RIGHT", frame, "RIGHT", -10, 3)
	hooksecurefunc(button, "SetPoint", function(self, point, attachTo, anchorPoint, xOffset, yOffset)
		if point ~= "RIGHT" or attachTo ~= frame or anchorPoint ~= "RIGHT" or xOffset ~= -10 or yOffset ~= 3 then
			button:ClearAllPoints()
			button:Point("RIGHT", frame, "RIGHT", -10, 3)		
		end
	end)
	
	self:HandleNextPrevButton(button, true)
	
	frame:CreateBackdrop("Default")
	frame.backdrop:Point("TOPLEFT", 20, -2)
	frame.backdrop:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
end

function S:HandleCheckBox(frame)
	frame:StripTextures()
	frame:CreateBackdrop("Default")
	frame.backdrop:SetInside(nil, 4, 4)
	
	if frame.SetCheckedTexture then
		frame:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	end
	
	if frame.SetDisabledTexture then
		frame:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	end
	
	frame:HookScript('OnDisable', function(self)
		if not self.SetDisabledTexture then return; end
		if self:GetChecked() then
			self:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
		else
			self:SetDisabledTexture("")
		end
	end)
	
	hooksecurefunc(frame, "SetNormalTexture", function(self, texPath)
		if texPath ~= "" then
			self:SetNormalTexture("");
		end
	end)
	
	hooksecurefunc(frame, "SetPushedTexture", function(self, texPath)
		if texPath ~= "" then
			self:SetPushedTexture("");
		end
	end)	
	
	hooksecurefunc(frame, "SetHighlightTexture", function(self, texPath)
		if texPath ~= "" then
			self:SetHighlightTexture("");
		end
	end)		
end

function S:HandleItemButton(b, shrinkIcon)
	if b.isSkinned then return; end

	b:StripTextures()
	b:CreateBackdrop('Default', true)
	b:StyleButton()
	
	local icon = b.icon or b.IconTexture
	if b:GetName() and _G[b:GetName()..'IconTexture'] then
		icon = _G[b:GetName()..'IconTexture']
	elseif b:GetName() and _G[b:GetName()..'Icon'] then
		icon = _G[b:GetName()..'Icon']
	end
	
	if icon then
		icon:SetTexCoord(unpack(E.TexCoords))

		-- create a backdrop around the icon
		
		if shrinkIcon then
			b.backdrop:SetAllPoints()
			icon:SetInside(b)
		else
			b.backdrop:SetOutside(icon)
		end
		icon:SetParent(b.backdrop)
	end
	b.isSkinned = true
end

function S:HandleCloseButton(f, point, text)
	f:StripTextures()
	
	if not f.backdrop then
		f:CreateBackdrop('Default', true)
		f.backdrop:Point('TOPLEFT', 7, -8)
		f.backdrop:Point('BOTTOMRIGHT', -8, 8)
		f:HookScript('OnEnter', SetModifiedBackdrop)
		f:HookScript('OnLeave', SetOriginalBackdrop)	
	end
	if not text then text = 'x' end
	if not f.text then
		f.text = f:CreateFontString(nil, 'OVERLAY')
		f.text:SetFont([[Interface\AddOns\ElvUI\media\fonts\PT_Sans_Narrow.ttf]], 16, 'OUTLINE')
		f.text:SetText(text)
		f.text:SetJustifyH('CENTER')
		f.text:SetPoint('CENTER', f, 'CENTER')
	end
	
	if point then
		f:Point("TOPRIGHT", point, "TOPRIGHT", 2, 2)
	end
end

function S:HandleSliderFrame(frame)
	local orientation = frame:GetOrientation()
	local SIZE = 12
	frame:StripTextures()
	frame:CreateBackdrop('Default')
	frame.backdrop:SetAllPoints()
	hooksecurefunc(frame, "SetBackdrop", function(self, backdrop)
		if backdrop ~= nil then
			frame:SetBackdrop(nil)
		end
	end)
	frame:SetThumbTexture(E["media"].blankTex)
	frame:GetThumbTexture():SetVertexColor(0.3, 0.3, 0.3)
	frame:GetThumbTexture():Size(SIZE-2,SIZE-2)
	if orientation == 'VERTICAL' then
		frame:Width(SIZE)
	else
		frame:Height(SIZE)
		
		for i=1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region and region:GetObjectType() == 'FontString' then
				local point, anchor, anchorPoint, x, y = region:GetPoint()
				if anchorPoint:find('BOTTOM') then
					region:Point(point, anchor, anchorPoint, x, y - 4)
				end
			end
		end		
	end
end

function S:ADDON_LOADED(event, addon)
	if self.allowBypass[addon] then
		S.addonsToLoad[addon]()
		S.addonsToLoad[addon] = nil
		return
	end
	
	if not E.initialized or not S.addonsToLoad[addon] then return end
	S.addonsToLoad[addon]()
	S.addonsToLoad[addon] = nil	
end

function S:RegisterSkin(name, loadFunc, forceLoad, bypass)
	if bypass then
		self.allowBypass[name] = true;
	end
	
	if forceLoad then
		loadFunc()
		self.addonsToLoad[name] = nil;		
	elseif name == 'ElvUI' then
		self.nonAddonsToLoad[#self.nonAddonsToLoad + 1] = loadFunc
	else
		self.addonsToLoad[name] = loadFunc;
	end
end

function S:Initialize()
	self.db = E.private.skins
	for addon, loadFunc in pairs(self.addonsToLoad) do
		if IsAddOnLoaded(addon) then
			loadFunc();
			self.addonsToLoad[addon] = nil;
		end
	end
	
	for _, loadFunc in pairs(self.nonAddonsToLoad) do
		loadFunc();
	end
	wipe(self.nonAddonsToLoad)
end

S:RegisterEvent('ADDON_LOADED')

E:RegisterModule(S:GetName())