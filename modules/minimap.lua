pfUI:RegisterModule("minimap", "vanilla:tbc:wotlk", function ()
  local rawborder, border = GetBorderSize()
  local size = tonumber(C.appearance.minimap.size) or 140

  if MiniMapWorldMapButton then MiniMapWorldMapButton:Hide() end
  if MinimapToggleButton then MinimapToggleButton:Hide() end
  MinimapBorderTop:Hide()
  MinimapZoneTextButton:Hide()
  MinimapZoomIn:Hide()
  MinimapZoomOut:Hide()
  GameTimeFrame:Hide()

  MinimapBorder:SetTexture(nil)

  pfUI.minimap = CreateFrame("Frame","pfMinimap",UIParent)
  CreateBackdrop(pfUI.minimap)
  CreateBackdropShadow(pfUI.minimap)
  pfUI.minimap:SetPoint("TOPRIGHT", UIParent, -border*2, -border*2)
  UpdateMovable(pfUI.minimap)
  pfUI.minimap:SetScript("OnShow", function()
    QueueFunction(ShowUIPanel, Minimap)
  end)

  Minimap:SetParent(pfUI.minimap)
  Minimap:SetPoint("CENTER", pfUI.minimap, "CENTER", 0.5, -.5)
  Minimap:SetFrameLevel(1)
  Minimap:SetMaskTexture(pfUI.media["img:minimap"])
  Minimap:EnableMouseWheel(true)
  Minimap:SetScript("OnMouseWheel", function()
    if(arg1 > 0) then Minimap_ZoomIn() else Minimap_ZoomOut() end
  end)

  pfUI.minimap.UpdateConfig = function(self)
    size = tonumber(C.appearance.minimap.size) or 140

    pfUI.minimap:SetWidth(size)
    pfUI.minimap:SetHeight(size)

    Minimap:SetWidth(size)
    Minimap:SetHeight(size)

    -- vanilla+tbc: do the best to detect the minimap arrow
    local arrowscale = tonumber(C.appearance.minimap.arrowscale) or 1
    local minimaparrow
    for k, v in pairs({Minimap:GetChildren()}) do
      if v:IsObjectType("Model") and not v:GetName() then
        local model = v:GetModel()
        if model and string.find(strlower(model), "interface\\minimap\\minimaparrow") then
          minimaparrow = v
          break
        end
      end
    end

    if minimaparrow then
      minimaparrow:SetScale(arrowscale)
    end
  end

  pfUI.minimap:UpdateConfig()

  hooksecurefunc("ToggleMinimap", function()
    if pfUI.farmmap and pfUI.farmmap:IsShown() then
      Minimap:Hide()
      return
    end

    if Minimap:IsVisible() then
      pfUI.minimap:SetHeight(size)
      pfUI.minimap:SetAlpha(1)
    else
      pfUI.minimap:SetHeight(-border-5)
      pfUI.minimap:SetAlpha(0)
      Minimap:Hide()
    end
  end)

  -- battleground icon
  MiniMapBattlefieldFrame:ClearAllPoints()
  MiniMapBattlefieldFrame:SetPoint("BOTTOMRIGHT", Minimap, 4, -4)
  MiniMapBattlefieldBorder:Hide()
  MiniMapBattlefieldFrame:SetScript("OnClick", function()
    GameTooltip:Hide()
    if MiniMapBattlefieldFrame.status == "active" then
      if arg1 == "RightButton" then
        ToggleDropDownMenu(1, nil, MiniMapBattlefieldDropDown, "MiniMapBattlefieldFrame", -95, -5)
      elseif IsShiftKeyDown() then
        ToggleBattlefieldMinimap()
      else
        ToggleWorldStateScoreFrame()
      end
    elseif arg1 == "RightButton" then
      ToggleDropDownMenu(1, nil, MiniMapBattlefieldDropDown, "MiniMapBattlefieldFrame", -95, -5)
    end
  end)

  local function SelectBattlefieldQueue(index)
    if not index or index <= 0 then return end
    if index and index > 0 then
      if BattlefieldFrame then BattlefieldFrame.selected = index end
      if type(_G.SetSelectedBattlefield) == "function" then
        pcall(_G.SetSelectedBattlefield, index)
      end
      if type(_G.RequestBattlegroundInstanceInfo) == "function" then
        pcall(_G.RequestBattlegroundInstanceInfo, index)
      end
    end
  end

  local function OpenBattlefieldQueue(index)
    if not BattlefieldFrame then return end
    ShowUIPanel(BattlefieldFrame)

    if index and index > 0 then
      SelectBattlefieldQueue(index)
    else
      BattlefieldFrame.selected = nil
      if type(_G.SetSelectedBattlefield) == "function" then
        pcall(_G.SetSelectedBattlefield, 0)
      end
    end

    if type(_G.BattlefieldFrame_Update) == "function" then
      pcall(_G.BattlefieldFrame_Update)
    end
  end

  local function QueueBattleground(index)
    SelectBattlefieldQueue(index)
    if type(_G.JoinBattlefield) == "function" then
      -- Instance 0 is Blizzard's "First Available" queue for the selected battleground type.
      local ok = pcall(_G.JoinBattlefield, 0)
      if not ok then
        pcall(_G.JoinBattlefield, index)
      end
    end
  end

  local function QueueArena(mode)
    if ArenaFrame then
      ShowUIPanel(ArenaFrame)
    end

    if mode == "skirmish" and type(_G.JoinSkirmish) == "function" then
      if not pcall(_G.JoinSkirmish) then
        pcall(_G.JoinSkirmish, 0)
      end
      return
    end

    if type(_G.JoinArena) == "function" then
      local bracket = tonumber(mode)
      if not pcall(_G.JoinArena, bracket) then
        if not pcall(_G.JoinArena, bracket, true) then
          pcall(_G.JoinArena, tostring(mode))
        end
      end
    end
  end

  local function GetQueuedBattlefieldName(name)
    if type(_G.GetBattlefieldStatus) ~= "function" or not name then return nil end

    local maxQueues = MAX_BATTLEFIELD_QUEUES or 3
    for i = 1, maxQueues do
      local status, mapName = _G.GetBattlefieldStatus(i)
      if status and status ~= "none" and mapName == name then
        return status
      end
    end
  end

  local function GetQueuedArenaStatus()
    if type(_G.GetBattlefieldStatus) ~= "function" then return nil end

    local maxQueues = MAX_BATTLEFIELD_QUEUES or 3
    for i = 1, maxQueues do
      local status, mapName, _, _, _, teamSize = _G.GetBattlefieldStatus(i)
      if status and status ~= "none" and (teamSize or (mapName and string.find(mapName, ARENA or "Arena", 1, true))) then
        return status
      end
    end
  end

  local function GetAvailableBattlegroundLabel(index)
    if type(_G.GetBattlegroundInfo) ~= "function" then return nil end
    local name, canEnter = _G.GetBattlegroundInfo(index)
    if type(name) == "string" and name ~= "" then
      if canEnter ~= false then
        return name
      end
    end
  end

  local function GetTextFromFrame(frame)
    if not frame then return nil end
    local frameName = frame:GetName()

    if frameName then
      for _, suffix in pairs({ "Name", "Text", "Title" }) do
        local text = _G[frameName .. suffix]
        if text and type(text.GetText) == "function" then
          local value = text:GetText()
          if type(value) == "string" and value ~= "" then
            return value
          end
        end
      end
    end

    if type(frame.GetRegions) == "function" then
      local regions = { frame:GetRegions() }
      for _, region in pairs(regions) do
        if region and type(region.GetText) == "function" then
          local value = region:GetText()
          if type(value) == "string" and value ~= "" then
            return value
          end
        end
      end
    end
  end

  local function FindBattlegroundIndexByName(name)
    if not name or type(_G.GetNumBattlegroundTypes) ~= "function" or type(_G.GetBattlegroundInfo) ~= "function" then
      return nil
    end

    for i = 1, _G.GetNumBattlegroundTypes() do
      local bgName = _G.GetBattlegroundInfo(i)
      if bgName == name then
        return i
      end
    end
  end

  local function GetAvailableBattlegrounds()
    local battlegrounds = {}

    if BattlefieldFrame and type(_G.BattlefieldFrame_Update) == "function" then
      local wasShown = BattlefieldFrame:IsShown()
      local previousSelected = BattlefieldFrame.selected

      BattlefieldFrame.selected = nil
      if type(_G.SetSelectedBattlefield) == "function" then
        pcall(_G.SetSelectedBattlefield, 0)
      end
      pcall(_G.BattlefieldFrame_Update)

      for i = 1, 20 do
        local button = _G["BattlefieldZone" .. i]
        if button and button:IsShown() then
          local name = GetTextFromFrame(button)
          local index = button:GetID()
          if not index or index <= 0 then
            index = FindBattlegroundIndexByName(name)
          end

          if name and index and index > 0 then
            table.insert(battlegrounds, { name = name, index = index })
          end
        end
      end

      BattlefieldFrame.selected = previousSelected
      if previousSelected and type(_G.SetSelectedBattlefield) == "function" then
        pcall(_G.SetSelectedBattlefield, previousSelected)
      end
      if not wasShown then
        BattlefieldFrame:Hide()
      elseif type(_G.BattlefieldFrame_Update) == "function" then
        pcall(_G.BattlefieldFrame_Update)
      end
    end

    if getn(battlegrounds) == 0 and type(_G.GetNumBattlegroundTypes) == "function" then
      for i = 1, _G.GetNumBattlegroundTypes() do
        local name = GetAvailableBattlegroundLabel(i)
        if name then
          table.insert(battlegrounds, { name = name, index = i })
        end
      end
    end

    return battlegrounds
  end

  local function InitializePvPDropDown(dropdown, level, menuList)
    if level == 1 then
      local info = UIDropDownMenu_CreateInfo()
      info.isTitle = 1
      info.notCheckable = 1
      info.text = BATTLEFIELDS or "Battlegrounds"
      UIDropDownMenu_AddButton(info, level)

      info = UIDropDownMenu_CreateInfo()
      info.notCheckable = 1
      info.text = ARENA or "Arena"
      info.hasArrow = 1
      info.value = "arena"
      UIDropDownMenu_AddButton(info, level)

      do
        local hasBattleground
        local battlegrounds = GetAvailableBattlegrounds()
        for _, battleground in pairs(battlegrounds) do
          if battleground.name and battleground.index then
            hasBattleground = true
            local bgIndex = battleground.index
            local queued = GetQueuedBattlefieldName(battleground.name)
            info = UIDropDownMenu_CreateInfo()
            info.notCheckable = nil
            info.checked = queued and 1 or nil
            info.disabled = queued and 1 or nil
            info.text = battleground.name
            info.func = function()
              QueueBattleground(bgIndex)
              CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info, level)
          end
        end

        if not hasBattleground then
          info = UIDropDownMenu_CreateInfo()
          info.notCheckable = 1
          info.disabled = 1
          info.text = NONE or "None"
          UIDropDownMenu_AddButton(info, level)
        end
      end
    elseif menuList == "arena" then
      local function AddArenaItem(text, value)
        local queueValue = value
        local queued = GetQueuedArenaStatus()
        local info = UIDropDownMenu_CreateInfo()
        info.notCheckable = nil
        info.checked = queued and 1 or nil
        info.disabled = queued and 1 or nil
        info.text = text
        info.func = function()
          QueueArena(queueValue)
          CloseDropDownMenus()
        end
        UIDropDownMenu_AddButton(info, level)
      end

      AddArenaItem("Rated (2v2)", 2)
      AddArenaItem("Rated (3v3)", 3)
      AddArenaItem("Rated (5v5)", 5)

      local info = UIDropDownMenu_CreateInfo()
      info.disabled = 1
      info.notCheckable = 1
      info.text = " "
      UIDropDownMenu_AddButton(info, level)

      AddArenaItem("Skirmish", "skirmish")
    end
  end

  pfUI.minimap.pvpqueue = CreateFrame("Button", "pfMinimapPvPQueue", Minimap)
  pfUI.minimap.pvpqueue:SetWidth(20)
  pfUI.minimap.pvpqueue:SetHeight(20)
  pfUI.minimap.pvpqueue:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 4, -4)
  pfUI.minimap.pvpqueue:SetFrameStrata("HIGH")
  pfUI.minimap.pvpqueue:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  CreateBackdrop(pfUI.minimap.pvpqueue, nil, true)

  pfUI.minimap.pvpqueue.icon = pfUI.minimap.pvpqueue:CreateTexture(nil, "ARTWORK")
  pfUI.minimap.pvpqueue.icon:SetTexture(pfUI.media["img:pvp"])
  pfUI.minimap.pvpqueue.icon:SetPoint("TOPLEFT", pfUI.minimap.pvpqueue, "TOPLEFT", 2, -2)
  pfUI.minimap.pvpqueue.icon:SetPoint("BOTTOMRIGHT", pfUI.minimap.pvpqueue, "BOTTOMRIGHT", -2, 2)

  pfUI.minimap.pvpqueue.dropdown = CreateFrame("Frame", "pfMinimapPvPQueueDropDown", pfUI.minimap.pvpqueue, "UIDropDownMenuTemplate")
  UIDropDownMenu_Initialize(pfUI.minimap.pvpqueue.dropdown, InitializePvPDropDown, "MENU")

  pfUI.minimap.pvpqueue:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine(PVP or "PvP")
    GameTooltip:AddLine((LEFT_BUTTON or "Left Click") .. ": Queue Menu", 1, 1, 1)
    GameTooltip:AddLine((RIGHT_BUTTON or "Right Click") .. ": " .. (BATTLEFIELDS or "Battlegrounds"), .8, .8, .8)
    GameTooltip:Show()
  end)
  pfUI.minimap.pvpqueue:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  local function PvPQueueButton_OnClick(self, button)
    local frame = self or this or pfUI.minimap.pvpqueue
    local click = button or arg1

    if click == "LeftButton" then
      ToggleDropDownMenu(1, nil, frame.dropdown, frame, 0, 0)
    else
      OpenBattlefieldQueue()
    end
  end

  pfUI.minimap.pvpqueue:SetScript("OnClick", nil)
  pfUI.minimap.pvpqueue:SetScript("OnMouseDown", PvPQueueButton_OnClick)

  local function RegisterPvPQueueAddonButton()
    if not pfUI.minimap or not pfUI.minimap.pvpqueue then return end

    pfUI_cache["abuttons"] = pfUI_cache["abuttons"] or {}
    pfUI_cache["abuttons"]["add"] = pfUI_cache["abuttons"]["add"] or {}
    pfUI_cache["abuttons"]["del"] = pfUI_cache["abuttons"]["del"] or {}

    for i, name in ipairs(pfUI_cache["abuttons"]["del"]) do
      if name == "pfMinimapPvPQueue" then
        table.remove(pfUI_cache["abuttons"]["del"], i)
        break
      end
    end

    local exists
    for _, name in ipairs(pfUI_cache["abuttons"]["add"]) do
      if name == "pfMinimapPvPQueue" then
        exists = true
        break
      end
    end

    if not exists then
      table.insert(pfUI_cache["abuttons"]["add"], "pfMinimapPvPQueue")
    end

    if pfUI.addonbuttons and pfUI.addonbuttons.ProcessButtons then
      pfUI.addonbuttons:ProcessButtons()
    end
  end

  RegisterPvPQueueAddonButton()

  -- mail icon
  MiniMapMailFrame:ClearAllPoints()
  MiniMapMailFrame:SetPoint("TOPRIGHT", pfUI.minimap, "TOPRIGHT", 0, 0)
  MiniMapMailBorder:Hide()
  MiniMapMailIcon:SetTexture(pfUI.media["img:mail"])

  MiniMapMailFrame:SetScript("OnShow", function()
    if not this.highlight then
      this.highlight = CreateFrame("Frame", nil, this)
      this.highlight:SetAllPoints(this)
      this.highlight:SetFrameLevel(this:GetFrameLevel() + 1)

      this.highlight.tex = this.highlight:CreateTexture("OVERLAY")
      this.highlight.tex:SetTexture(pfUI.media["img:mail"])
      this.highlight.tex:SetPoint("TOPLEFT", MiniMapMailIcon, "TOPLEFT", -2, 2)
      this.highlight.tex:SetPoint("BOTTOMRIGHT", MiniMapMailIcon, "BOTTOMRIGHT", 2, -2)
      this.highlight.tex:SetVertexColor(1,.5,.5)

      this.highlight:SetScript("OnUpdate", function()
        if not this.count then this.count = 0 end
        if not this.modifier then this.modifier = 1 end
        if this.count >= 10 then this:Hide() end

        this:SetAlpha(this:GetAlpha() + this.modifier)

        if this:GetAlpha() <= 0.1 then
          this.modifier = 0.05
          this.count = this.count + 1
        elseif this:GetAlpha() >= 0.9 then
          this.modifier = -0.05
        end
      end)
    end

    this.highlight.count = 0
    this.highlight:Show()
  end)

  -- Create coordinates text frame with location configurable
  pfUI.minimapCoordinates = CreateFrame("Frame", "pfMinimapCoord", pfUI.minimap)
  pfUI.minimapCoordinates:SetScript("OnUpdate", function()
    -- Throttle to update coords every 0.1 seconds
    if ( this.tick or 0) > GetTime() then return end
    this.tick = GetTime() + .1
    
    if C.appearance.minimap.coordstext == "off" then return end

    this.posX, this.posY = GetPlayerMapPosition("player")
    if this.posX ~= 0 and this.posY ~= 0 then
      this.text:SetText(string.format("%.1f, %.1f", round(this.posX * 100, 1), round(this.posY * 100, 1)))
    else
      this.text:SetText("|cffffaaaaN/A")
    end
  end)

  if C.appearance.minimap.coordsloc == "topleft" then
    pfUI.minimapCoordinates:SetPoint("TOPLEFT", 3, -3)
  elseif C.appearance.minimap.coordsloc == "topright" then
    pfUI.minimapCoordinates:SetPoint("TOPRIGHT", -3, -3)
  elseif C.appearance.minimap.coordsloc == "bottomright" then
    pfUI.minimapCoordinates:SetPoint("BOTTOMRIGHT", -3, 3)
  else
    pfUI.minimapCoordinates:SetPoint("BOTTOMLEFT", 3, 3)
  end

  pfUI.minimapCoordinates:SetHeight(C.global.font_size)
  pfUI.minimapCoordinates:SetWidth(Minimap:GetWidth())
  pfUI.minimapCoordinates.text = pfUI.minimapCoordinates:CreateFontString("MinimapCoordinatesText", "LOW", "GameFontNormal")
  pfUI.minimapCoordinates.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
  pfUI.minimapCoordinates.text:SetTextColor(1,1,1,1)
  pfUI.minimapCoordinates.text:SetAllPoints(pfUI.minimapCoordinates)

  if C.appearance.minimap.coordsloc == "topright" or C.appearance.minimap.coordsloc == "bottomright" then
    pfUI.minimapCoordinates.text:SetJustifyH("RIGHT")
  else
    pfUI.minimapCoordinates.text:SetJustifyH("LEFT")
  end

  if C.appearance.minimap.coordstext ~= "on" then
    pfUI.minimapCoordinates:Hide()
  else
    pfUI.minimapCoordinates:Show()
  end

  -- Create zone text frame in top center of minimap
  pfUI.minimapZone = CreateFrame("Frame", "pfMinimapZone", pfUI.minimap)
  pfUI.minimapZone:RegisterEvent("MINIMAP_ZONE_CHANGED")
  pfUI.minimapZone:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.minimapZone:SetPoint("TOP", 0, -3)
  pfUI.minimapZone:SetHeight(C.global.font_size + 2)
  pfUI.minimapZone:SetWidth(Minimap:GetWidth())
  pfUI.minimapZone.text = pfUI.minimapZone:CreateFontString("minimapZoneText", "LOW", "GameFontNormal")
  pfUI.minimapZone.text:SetFont(pfUI.font_default, C.global.font_size + 2, "OUTLINE")
  pfUI.minimapZone.text:SetAllPoints(pfUI.minimapZone)
  pfUI.minimapZone.text:SetJustifyH("CENTER")

  pfUI.minimapZone:SetScript("OnEvent", function()
    if not WorldMapFrame:IsShown() then
      SetMapToCurrentZone()
    end

    if C.appearance.minimap.zonetext ~= "off" then
      local pvp, _, arena = GetZonePVPInfo()
      if arena then
        pfUI.minimapZone.text:SetTextColor(1.0, 0.1, 0.1)
      elseif pvp == "friendly" then
        pfUI.minimapZone.text:SetTextColor(0.1, 1.0, 0.1)
      elseif pvp == "hostile" then
        pfUI.minimapZone.text:SetTextColor(1.0, 0.1, 0.1)
      elseif pvp == "contested" then
        pfUI.minimapZone.text:SetTextColor(1.0, 0.7, 0)
      else
        pfUI.minimapZone.text:SetTextColor(1, 1, 1, 1)
      end
      pfUI.minimapZone.text:SetText(GetMinimapZoneText())
    end
  end)

  if C.appearance.minimap.zonetext ~= "on" then
    pfUI.minimapZone:Hide()
  else
    pfUI.minimapZone:Show()
  end

  -- Minimap hover event
  -- Update and toggle showing of coordinates and zone text on mouse enter/leave
  Minimap:SetScript("OnEnter", function()
    if C.appearance.minimap.coordstext ~= "off" then
      pfUI.minimapCoordinates:Show()
    end
    if C.appearance.minimap.zonetext ~= "off" then
      pfUI.minimapZone:Show()
    end
  end)
  Minimap:SetScript("OnLeave", function()
    if C.appearance.minimap.coordstext ~= "on" then
      pfUI.minimapCoordinates:Hide()
    end
    if C.appearance.minimap.zonetext ~= "on" then
      pfUI.minimapZone:Hide()
    end
  end)

  pfUI.minimap.pvpicon = CreateFrame("Frame", nil, pfUI.minimap)
  pfUI.minimap.pvpicon:Hide()
  pfUI.minimap.pvpicon:RegisterEvent("UPDATE_FACTION")
  pfUI.minimap.pvpicon:RegisterEvent("UNIT_FACTION")
  pfUI.minimap.pvpicon:SetFrameStrata("HIGH")
  pfUI.minimap.pvpicon:SetWidth(16)
  pfUI.minimap.pvpicon:SetHeight(16)
  pfUI.minimap.pvpicon:SetAlpha(.5)
  pfUI.minimap.pvpicon:SetParent(pfUI.minimap)
  pfUI.minimap.pvpicon:SetPoint("BOTTOMRIGHT", pfUI.minimap, "BOTTOMRIGHT", -5, 5)
  pfUI.minimap.pvpicon.texture = pfUI.minimap.pvpicon:CreateTexture(nil,"DIALOG")
  pfUI.minimap.pvpicon.texture:SetTexture(pfUI.media["img:pvp"])
  pfUI.minimap.pvpicon.texture:SetAllPoints(pfUI.minimap.pvpicon)

  pfUI.minimap.pvpicon:SetScript("OnEvent", function()
    if C.unitframes.player.showPVPMinimap == "1" and UnitIsPVP("player") then
      pfUI.minimap.pvpicon:Show()
    else
      pfUI.minimap.pvpicon:Hide()
    end
  end)

end)
