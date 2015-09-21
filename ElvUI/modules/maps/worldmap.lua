local E, L, V, P, G = unpack(select(2, ...));
local M = E:NewModule("WorldMap", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0");
E.WorldMap = M;

function M:SetLargeWorldMap()
	if(InCombatLockdown()) then return; end
	
	WorldMapFrame:SetParent(E.UIParent);
	WorldMapFrame:EnableKeyboard(false);
	WorldMapFrame:SetScale(1);
	WorldMapFrame:EnableMouse(false);
	
	if(not WorldMapFrame:GetAttribute("UIPanelLayout-defined")) then
		UIPanelWindows["WorldMapFrame"].area = "center";
		UIPanelWindows["WorldMapFrame"].allowOtherPanels = true;
	else
		WorldMapFrame:SetAttribute("UIPanelLayout-area", "center");
		WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true);
	end
	
	WorldMapFrameSizeUpButton:Hide();
	WorldMapFrameSizeDownButton:Show();
end

function M:SetSmallWorldMap()
	if(InCombatLockdown()) then return; end
	
	WorldMapFrameSizeUpButton:Show();
	WorldMapFrameSizeDownButton:Hide();
end

function M:PLAYER_REGEN_ENABLED()
	WorldMapFrameSizeDownButton:Enable();
	WorldMapFrameSizeUpButton:Enable();
end

function M:PLAYER_REGEN_DISABLED()
	WorldMapFrameSizeDownButton:Disable();
	WorldMapFrameSizeUpButton:Disable();
end

function M:UpdateCoords()
	if(not WorldMapFrame:IsShown()) then return; end
	local inInstance, _ = IsInInstance();
	local x, y = GetPlayerMapPosition("player");
	x = E:Round(100 * x, 2);
	y = E:Round(100 * y, 2);
	
	if(x ~= 0 and y ~= 0) then
		CoordsHolder.playerCoords:SetText(PLAYER..":   "..x..", "..y);
	else
		CoordsHolder.playerCoords:SetText("");
	end
	
	local scale = WorldMapDetailFrame:GetEffectiveScale();
	local width = WorldMapDetailFrame:GetWidth();
	local height = WorldMapDetailFrame:GetHeight();
	local centerX, centerY = WorldMapDetailFrame:GetCenter();
	local x, y = GetCursorPosition();
	local adjustedX = (x / scale - (centerX - (width/2))) / width;
	local adjustedY = (centerY + (height/2) - y / scale) / height;
	
	if(adjustedX >= 0  and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
		adjustedX = E:Round(100 * adjustedX, 2);
		adjustedY = E:Round(100 * adjustedY, 2);
		CoordsHolder.mouseCoords:SetText(MOUSE_LABEL..":   "..adjustedX..", "..adjustedY);
	else
		CoordsHolder.mouseCoords:SetText("");
	end
end

function M:Initialize()
	local coordsHolder = CreateFrame("Frame", "CoordsHolder", WorldMapFrame);
	coordsHolder:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() + 1);
	coordsHolder:SetFrameStrata(WorldMapDetailFrame:GetFrameStrata());
	coordsHolder.playerCoords = coordsHolder:CreateFontString(nil, "OVERLAY");
	coordsHolder.mouseCoords = coordsHolder:CreateFontString(nil, "OVERLAY");
	coordsHolder.playerCoords:SetTextColor(1, 1 ,0);
	coordsHolder.mouseCoords:SetTextColor(1, 1 ,0);
	coordsHolder.playerCoords:SetFontObject(NumberFontNormal);
	coordsHolder.mouseCoords:SetFontObject(NumberFontNormal);
	coordsHolder.playerCoords:SetPoint("BOTTOMLEFT", WorldMapDetailFrame, "BOTTOMLEFT", 5, 5);
	coordsHolder.playerCoords:SetText(PLAYER..":   0, 0");
	coordsHolder.mouseCoords:SetPoint("BOTTOMLEFT", coordsHolder.playerCoords, "TOPLEFT", 0, 5);
	coordsHolder.mouseCoords:SetText(MOUSE_LABEL..":   0, 0");
	
	self:ScheduleRepeatingTimer("UpdateCoords", 0.05);
	
	if(E.private.general.smallerWorldMap) then
		BlackoutWorld:SetTexture(nil);
		self:SecureHook("WorldMap_ToggleSizeDown", "SetSmallWorldMap");
		self:SecureHook("WorldMap_ToggleSizeUp", "SetLargeWorldMap");
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		self:RegisterEvent("PLAYER_REGEN_DISABLED");
		
		if(WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE) then
			self:SetLargeWorldMap();
		elseif(WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE) then
			self:SetSmallWorldMap();
		elseif(WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE) then
			self:SetLargeWorldMap();
		end
		
		DropDownList1:HookScript("OnShow", function(self)
			if(DropDownList1:GetScale() ~= UIParent:GetScale()) then
				DropDownList1:SetScale(UIParent:GetScale());
			end		
		end)
	end
end

E:RegisterInitialModule(M:GetName());