
MacroChanger = {};
--[[MacroChanger.fully_loaded = false;
MacroChanger.default_options = {

	-- main frame position
	frameRef = "CENTER",
	frameX = 0,
	frameY = 0,
	hide = false,

	-- sizing
	frameW = 200,
	frameH = 200,
};
]]--
MacroChanger.skipSpells = {"Turn Evil", "Hammer of Justice", "Rebuke"}
MacroChanger.skipSpellsNumber = 3

--[[function MacroChanger.OnReady()

	-- set up default options
	_G.MacroChangerPrefs = _G.MacroChangerPrefs or {};

	for k,v in pairs(MacroChanger.default_options) do
		if (not _G.MacroChangerPrefs[k]) then
			_G.MacroChangerPrefs[k] = v;
		end
	end

	MacroChanger.CreateUIFrame();
end

function MacroChanger.OnSaving()

	if (MacroChanger.UIFrame) then
		local point, relativeTo, relativePoint, xOfs, yOfs = MacroChanger.UIFrame:GetPoint()
		_G.MacroChangerPrefs.frameRef = relativePoint;
		_G.MacroChangerPrefs.frameX = xOfs;
		_G.MacroChangerPrefs.frameY = yOfs;
	end
end

function MacroChanger.OnUpdate()
	if (not MacroChanger.fully_loaded) then
		return;
	end

	if (MacroChangerPrefs.hide) then 
		return;
	end

	MacroChanger.UpdateFrame();
end
]]--
--[[
function MacroChanger.OnEvent(frame, event, ...)

	if (event == 'ADDON_LOADED') then
		local name = ...;
		if name == 'MacroChanger' then
			MacroChanger.OnReady();
		end
		return;
	end

	if (event == 'PLAYER_LOGIN') then

		MacroChanger.fully_loaded = true;
		return;
	end

	if (event == 'PLAYER_LOGOUT') then
		MacroChanger.OnSaving();
		return;
	end
end
]]--
--[[
function MacroChanger.CreateUIFrame()

	-- create the UI frame
	MacroChanger.UIFrame = CreateFrame("Frame",nil,UIParent);
	MacroChanger.UIFrame:SetFrameStrata("BACKGROUND")
	MacroChanger.UIFrame:SetWidth(_G.MacroChangerPrefs.frameW);
	MacroChanger.UIFrame:SetHeight(_G.MacroChangerPrefs.frameH);

	-- make it black
	MacroChanger.UIFrame.texture = MacroChanger.UIFrame:CreateTexture();
	MacroChanger.UIFrame.texture:SetAllPoints(MacroChanger.UIFrame);
	MacroChanger.UIFrame.texture:SetTexture(0, 0, 0);

	-- position it
	MacroChanger.UIFrame:SetPoint(_G.MacroChangerPrefs.frameRef, _G.MacroChangerPrefs.frameX, _G.MacroChangerPrefs.frameY);

	-- make it draggable
	MacroChanger.UIFrame:SetMovable(true);
	MacroChanger.UIFrame:EnableMouse(true);

	-- create a button that covers the entire addon
	MacroChanger.Cover = CreateFrame("Button", nil, MacroChanger.UIFrame);
	MacroChanger.Cover:SetFrameLevel(128);
	MacroChanger.Cover:SetPoint("TOPLEFT", 0, 0);
	MacroChanger.Cover:SetWidth(_G.MacroChangerPrefs.frameW);
	MacroChanger.Cover:SetHeight(_G.MacroChangerPrefs.frameH);
	MacroChanger.Cover:EnableMouse(true);
	MacroChanger.Cover:RegisterForClicks("AnyUp");
	MacroChanger.Cover:RegisterForDrag("LeftButton");
	MacroChanger.Cover:SetScript("OnDragStart", MacroChanger.OnDragStart);
	MacroChanger.Cover:SetScript("OnDragStop", MacroChanger.OnDragStop);
	MacroChanger.Cover:SetScript("OnClick", MacroChanger.OnClick);

	-- add a main label - just so we can show something
	MacroChanger.Label = MacroChanger.Cover:CreateFontString(nil, "OVERLAY");
	MacroChanger.Label:SetPoint("CENTER", MacroChanger.UIFrame, "CENTER", 2, 0);
	MacroChanger.Label:SetJustifyH("LEFT");
	]]--
	--MacroChanger.Label:SetFont([[Fonts\FRIZQT__.TTF]], 12, "OUTLINE");
	--[[MacroChanger.Label:SetText(" ");
	MacroChanger.Label:SetTextColor(1,1,1,1);
	MacroChanger.SetFontSize(MacroChanger.Label, 20);
end

function MacroChanger.SetFontSize(string, size)

	local Font, Height, Flags = string:GetFont()
	if (not (Height == size)) then
		string:SetFont(Font, size, Flags)
	end
end

function MacroChanger.OnDragStart(frame)
	MacroChanger.UIFrame:StartMoving();
	MacroChanger.UIFrame.isMoving = true;
	GameTooltip:Hide()
end

function MacroChanger.OnDragStop(frame)
	MacroChanger.UIFrame:StopMovingOrSizing();
	MacroChanger.UIFrame.isMoving = false;
end

function MacroChanger.OnClick(self, aButton)
	if (aButton == "RightButton") then
		changeFocusToParty()
	end
	if (aButton == "LeftButton") then
		changePartyToFocus()
	end
end
]]--
function macroChange(msg, editbox)
	if (msg == 'focus') then
		changePartyToFocus()
	elseif (msg == 'party') then
		changeFocusToParty()
	else
		print("Wrong MacroChanger command")
	end
end

function changeFocusToParty()
	for i = 121, 139 do
		name, _, body, _ = GetMacroInfo(i)
		if(name ~= nil) then
			if(string.find(body, "@focus")) then
				local isExcluded = false
				for j = 1, MacroChanger.skipSpellsNumber do
					if(string.find(body, MacroChanger.skipSpells[j])) then
						isExcluded = true
					end
				end
				if not isExcluded then
					local newBody = body:gsub("@focus", "@party1")
					EditMacro(i, nil, nil, newBody, 1, nil)
				end
			end
		end
	end
	print("Changed @focus to @party1 !")
end

function changePartyToFocus()
	for i = 121, 139 do
		name, _, body, _ = GetMacroInfo(i)
		if(name ~= nil) then
			if(string.find(body, "@party1")) then
				local isExcluded = false
				for j = 1, MacroChanger.skipSpellsNumber do
					if(string.find(body, MacroChanger.skipSpells[j])) then
						isExcluded = true
					end
				end
				if not isExcluded then
					local newBody = body:gsub("@party1", "@focus")
					EditMacro(i, nil, nil, newBody, 1, nil)
				end
			end
		end
	end
	print("Changed @party1 to @focus !")
end

--[[
function MacroChanger.UpdateFrame()

	-- update the main frame state here
	MacroChanger.Label:SetText(string.format("%d", GetTime()));
end


MacroChanger.EventFrame = CreateFrame("Frame");
MacroChanger.EventFrame:Show();
MacroChanger.EventFrame:SetScript("OnEvent", MacroChanger.OnEvent);
MacroChanger.EventFrame:SetScript("OnUpdate", MacroChanger.OnUpdate);
MacroChanger.EventFrame:RegisterEvent("ADDON_LOADED");
MacroChanger.EventFrame:RegisterEvent("PLAYER_LOGIN");
MacroChanger.EventFrame:RegisterEvent("PLAYER_LOGOUT");
]]--

SLASH_MACROCHANGER1, SLASH_MACROCHANGER2 = "/mc", "/macrochanger"
SlashCmdList["MACROCHANGER"] = macroChange