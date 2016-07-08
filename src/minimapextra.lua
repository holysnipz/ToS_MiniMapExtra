
function MINIMAPEXTRA_ON_INIT(addon, frame)
	addon:RegisterMsg("FPS_UPDATE", "MINIMAPEXTRA_UPDATE_EVENT");
end


function MINIMAPEXTRA_UPDATE_EVENT(frame, msg, argStr, argNum)
	-- Map and minimap
	local mapName = session.GetMapName();
	local mapprop = geMapTable.GetMapProp(mapName);
	local minimapFrame = ui.GetFrame("minimap");
	local mapFrame = ui.GetFrame("map");

	-- Get completion percent
	local completionPercent = 100;		--Default; for town / mercenary post / whatsever
	if MAP_USE_FOG(mapName) ~= 0 then
		completionPercent = session.GetMapFogRevealRate(mapName);
		completionPercent = tonumber(string.format("%.1f", completionPercent));
	end

	-- Minimap zoom level
	local curSize = GET_MINIMAPSIZE();
	local mapZoom = math.abs((curSize + 100) / 100);

	-- Character's position relative to the minimap frame (the center)
	local framePositionWidth = minimapFrame:GetWidth() / 2;
	local framePositionHeight = minimapFrame:GetHeight() / 2;
	
	-- Character's position relative to the map
	local pictureUI  = GET_CHILD(mapFrame, "map", "ui::CPicture");	
	local mapWidth = pictureUI:GetImageWidth() * mapZoom;
	local mapHeight = pictureUI:GetImageHeight() * mapZoom;
	local objHandle = session.GetMyHandle();
	local myPosition = info.GetPositionInMap(objHandle, mapWidth, mapHeight);

	-- Loop through list of fog tiles
	HIDE_CHILD_BYNAME(minimapFrame, "_SAMPLE_");
	local tileList = session.GetMapFogList(mapName);
	if tileList ~= nil then
	local tileCount = tileList:Count();
		for i = 0 , tileCount - 1 do
			local tile = tileList:PtrAt(i);
			
			if tile.revealed == 0 then
				-- draw tile on minimap
				tilePosX = (tile.x * mapZoom) - myPosition.x + framePositionWidth;
				tilePosY = (tile.y * mapZoom) - myPosition.y + framePositionHeight;
				tileWidth = math.ceil(tile.w * mapZoom);
				tileHeight = math.ceil(tile.h * mapZoom);

				local tileName = string.format("_SAMPLE_%d", i);
				local pic = minimapFrame:CreateOrGetControl("picture", tileName, tilePosX, tilePosY, tileWidth, tileHeight);
				tolua.cast(pic, "ui::CPicture");
				pic:ShowWindow(1);
				pic:SetImage("fullred");
				pic:SetEnableStretch(1);
				pic:SetAlpha(40.0);
				pic:EnableHitTest(0);
			end
		end
	end

	-- Draw map name and percentage on frame above minimap
	local minimapFrame = ui.GetFrame("minimap");
	local minimapX = minimapFrame:GetX();
	
	local minimapExtraFrame = ui.GetFrame("minimapextra");
	minimapExtraFrame:SetOffset(minimapX,0);
	minimapExtraFrame:SetGravity(ui.RIGHT, ui.TOP);

	local minimapExtraText = minimapExtraFrame:GetChild("minimapExtraText");
	tolua.cast(minimapExtraText, "ui::CRichText");
	
	minimapExtraText:SetOffset(0, 10);
	minimapExtraText:SetGravity(ui.LEFT, ui.TOP);
	minimapExtraText:SetText("{@st42}" .. mapprop:GetName() .. "  " .. completionPercent .. "%{/}");
	minimapExtraText:SetTextAlign("center", "top");
	minimapExtraText:Move(0, 0);
	minimapExtraFrame:ShowWindow(1);
end