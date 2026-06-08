pfUI:RegisterModule("map", "vanilla:tbc:wotlk", function ()
  table.insert(UISpecialFrames, "WorldMapFrame")

  local function UpdateTooltipScale()
    -- load scale data
    local tooltipscale = tonumber(C.appearance.worldmap.tooltipsize)
    local scale = WorldMapFrame:GetScale()

    -- apply tooltip scale
    if tooltipscale > 0 then
      WorldMapTooltip:SetScale(tooltipscale/scale)
    else
      WorldMapTooltip:SetScale(1)
    end
  end

  local pfOrigSetMapToCurrentZone = _G.SetMapToCurrentZone

  -- register config update handler
  pfUI.map = { UpdateConfig = UpdateTooltipScale }

  C.position["WorldMapFrame"] = C.position["WorldMapFrame"] or { alpha = 1.0, scale = 0.7 }
  C.position["WorldMapFrame"].parent = nil
  C.position["WorldMapFrame"].alpha = 1
  local alpha = 1
  local scale = C.position["WorldMapFrame"].scale

  local function HideFrame(frame)
    if not frame then return end
    frame:Hide()
    if frame.EnableMouse then frame:EnableMouse(false) end
    if frame.IsObjectType and frame:IsObjectType("Frame") then
      frame.Show = function() end
    end
  end

  local function SetDropDownWidth(frame, width)
    if not frame then return end
    frame:SetWidth(width + 40)
    if frame.backdrop then
      frame.backdrop:SetWidth(width + 32)
    end
    if frame.button then
      frame.button:ClearAllPoints()
      frame.button:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    end
  end

  local function EmphasizeCheckButton(button)
    if not button then return end
    button:SetWidth(16)
    button:SetHeight(16)

    if not button.pfFill then
      button.pfFill = button:CreateTexture(nil, "BACKGROUND")
      button.pfFill:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
      button.pfFill:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
      button.pfFill:SetTexture(0, 0, 0, .95)
    end

    if not button.pfOutline then
      button.pfOutline = {}
      for i = 1, 4 do
        button.pfOutline[i] = button:CreateTexture(nil, "OVERLAY")
        button.pfOutline[i]:SetTexture(1, .82, 0, .95)
      end
      button.pfOutline[1]:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
      button.pfOutline[1]:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
      button.pfOutline[1]:SetHeight(1)
      button.pfOutline[2]:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
      button.pfOutline[2]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
      button.pfOutline[2]:SetHeight(1)
      button.pfOutline[3]:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
      button.pfOutline[3]:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
      button.pfOutline[3]:SetWidth(1)
      button.pfOutline[4]:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
      button.pfOutline[4]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
      button.pfOutline[4]:SetWidth(1)
    end

    if not button.backdrop then
      CreateBackdrop(button, nil, true)
    end
    if button.backdrop then
      button.backdrop:SetBackdropColor(0, 0, 0, 1)
      button.backdrop:SetBackdropBorderColor(1, 1, 0, .85)
    end
  end

  local function StripMapChrome(frame)
    if not frame then return end
    if frame == WorldMapFrame.backdrop or frame == WorldMapFrame.shadow then return end

    local name = frame.GetName and frame:GetName() or ""
    if name == "WorldMapButton" or name == "WorldMapDetailFrame" then return end
    if name == "WorldMapFrame" then
      if frame.GetRegions then
        for _, region in pairs({ frame:GetRegions() }) do
          if region and region.SetTexture then
            local width = region.GetWidth and region:GetWidth() or 0
            local height = region.GetHeight and region:GetHeight() or 0
            if width > 40 or height > 20 then
              region:SetTexture(nil)
              region:SetAlpha(0)
              region:Hide()
            end
          end
        end
      end
      return
    end
    if string.find(name, "Quest", 1, true) then return end
    if string.find(name, "POI", 1, true) then return end
    if string.find(name, "DropDown", 1, true) then return end
    if string.find(name, "Button", 1, true) and name ~= "WorldMapFrame" then return end
    if frame.backdrop or frame.shadow then return end

    if frame.GetRegions then
      for _, region in pairs({ frame:GetRegions() }) do
        if region and region.SetTexture then
          local width = region.GetWidth and region:GetWidth() or 0
          local height = region.GetHeight and region:GetHeight() or 0
          if width > 40 or height > 20 then
            region:SetTexture(nil)
            region:SetAlpha(0)
            region:Hide()
          end
        end
        if region and region.GetText and region.SetText then
          local text = region:GetText()
          if text == "Zone Map" or text == "Always Show" or text == "World Map" then
            region:SetText("")
            region:Hide()
          end
        end
      end
    end

    if frame.GetChildren then
      for _, child in pairs({ frame:GetChildren() }) do
        StripMapChrome(child)
      end
    end
  end

  local function PositionMapControls()
    if not WorldMapFrame.pfTopPanel then
      WorldMapFrame.pfTopPanel = CreateFrame("Frame", nil, WorldMapFrame)
      WorldMapFrame.pfTopPanel:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 0, 0)
      WorldMapFrame.pfTopPanel:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", 0, 0)
      WorldMapFrame.pfTopPanel:SetHeight(52)
      CreateBackdrop(WorldMapFrame.pfTopPanel, nil, true, .95)
    end
    if WorldMapFrame.pfTopPanel.backdrop then
      WorldMapFrame.pfTopPanel.backdrop:SetBackdropColor(0, 0, 0, .95)
    end

    HideFrame(WorldMapFrame.pfBottomPanel)

    HideFrame(WorldMapZoneMinimapDropDown)
    HideFrame(WorldMapFrameAreaLabel)
    HideFrame(WorldMapFrameTitle)
    HideFrame(WorldMapFrameTitleText)
    HideFrame(WorldMapFrameSizeDownButton)
    HideFrame(WorldMapFrameSizeUpButton)

    if pfUI.map and pfUI.map.autozoneswitch then
      EmphasizeCheckButton(pfUI.map.autozoneswitch)
      pfUI.map.autozoneswitch:ClearAllPoints()
      pfUI.map.autozoneswitch:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 74, -32)
      pfUI.map.autozoneswitch.text:ClearAllPoints()
      pfUI.map.autozoneswitch.text:SetPoint("LEFT", pfUI.map.autozoneswitch, "RIGHT", 6, 1)
      pfUI.map.autozoneswitch.text:SetJustifyH("LEFT")
    end

    if WorldMapContinentDropDown then
      WorldMapContinentDropDown:ClearAllPoints()
      WorldMapContinentDropDown:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 340, -28)
      SetDropDownWidth(WorldMapContinentDropDown, 150)
    end
    if WorldMapZoneDropDown then
      WorldMapZoneDropDown:ClearAllPoints()
      WorldMapZoneDropDown:SetPoint("LEFT", WorldMapContinentDropDown or WorldMapFrame, WorldMapContinentDropDown and "RIGHT" or "TOPLEFT", 12, WorldMapContinentDropDown and 0 or -28)
      SetDropDownWidth(WorldMapZoneDropDown, 150)
    end
    if WorldMapZoomOutButton then
      WorldMapZoomOutButton:ClearAllPoints()
      WorldMapZoomOutButton:SetPoint("LEFT", WorldMapZoneDropDown or WorldMapFrame, WorldMapZoneDropDown and "RIGHT" or "TOPLEFT", 12, WorldMapZoneDropDown and 2 or -33)
      WorldMapZoomOutButton:SetWidth(110)
    end
    if pfUI.mapreveal and pfUI.mapreveal.onmap then
      EmphasizeCheckButton(pfUI.mapreveal.onmap)
      pfUI.mapreveal.onmap:ClearAllPoints()
      pfUI.mapreveal.onmap:SetPoint("LEFT", WorldMapZoomOutButton or WorldMapFrame, WorldMapZoomOutButton and "RIGHT" or "TOPLEFT", 18, WorldMapZoomOutButton and 0 or -37)
      pfUI.mapreveal.onmap.text:ClearAllPoints()
      pfUI.mapreveal.onmap.text:SetPoint("LEFT", pfUI.mapreveal.onmap, "RIGHT", 6, 0)
    end
    if PFEXQuestHelperMapToggleButton then
      HideFrame(PFEXQuestHelperMapToggleButton)
    end
  end

  local pfMapLoader = CreateFrame("Frame")
  pfMapLoader:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfMapLoader:SetScript("OnEvent", function()
    -- do not load if other map addon is loaded
    if Cartographer then return end
    if METAMAP_TITLE then return end

    WorldMapFrame:SetMovable(true)
    WorldMapFrame:EnableMouse(true)
    WorldMapFrame:RegisterForDrag("LeftButton")

    -- make sure the hooks get only applied once
    if not this.hooked then
      this.hooked = true

      HookScript(WorldMapFrame, "OnShow", function()
        -- The world map is protected in combat. Its layout is already applied
        -- during login, so avoid tainting the combat-safe Blizzard open path.
        if InCombatLockdown and InCombatLockdown() then return end

        -- customize
        this:EnableKeyboard(false)
        this:EnableMouseWheel(1)

        -- set back to default scale
        WorldMapFrame:SetScale(scale or .85)
        WorldMapFrame:SetAlpha(1)

        -- always switch to current zone when opening the map
        pfOrigSetMapToCurrentZone()
        StripMapChrome(WorldMapFrame)
        PositionMapControls()
      end)

      HookScript(WorldMapFrame, "OnMouseWheel", function()
        if IsShiftKeyDown() then
          alpha = clamp(WorldMapFrame:GetAlpha() + arg1/10, 0.1, 1.0)
          WorldMapFrame:SetAlpha(alpha)
        end

        if IsControlKeyDown() then
          local oldscale = WorldMapFrame:GetScale()
          local point, rel, relpoint, offx, offy = WorldMapFrame:GetPoint()
          scale = clamp(oldscale + arg1/10, 0.1, 2.0)

          -- recalculate world frame position based on old and new scale
          if point == "TOPLEFT" and relpoint == "TOPLEFT" then
            offx = offx*oldscale/scale
            offy = offy*oldscale/scale
            WorldMapFrame:SetPoint(point, rel, relpoint, offx, offy)
          end

          WorldMapFrame:SetScale(scale)
          UpdateTooltipScale()
        end

        SaveMovable(this, true)
      end)

      HookScript(WorldMapFrame, "OnDragStart", function()
        WorldMapFrame:StartMoving()
      end)

      HookScript(WorldMapFrame, "OnDragStop",function()
        WorldMapFrame:StopMovingOrSizing()
        SaveMovable(this, true)
      end)
    end

    WorldMapFrame:SetAlpha(1)
    WorldMapFrame:SetScale(scale)
    UpdateTooltipScale()

    WorldMapFrame:ClearAllPoints()
    WorldMapFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    if WorldMapButton then
      WorldMapFrame:SetWidth(WorldMapButton:GetWidth() + 15)
      WorldMapFrame:SetHeight(WorldMapButton:GetHeight() + 55)
    end
    LoadMovable(WorldMapFrame)

    -- skin
    if WorldMapFrameCloseButton then
      WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", 0, 0)
    end
    CreateBackdrop(WorldMapFrame)
    CreateBackdropShadow(WorldMapFrame)

    if WorldMapFrame.backdrop then
      WorldMapFrame.backdrop:SetBackdropColor(0, 0, 0, 1)
    end

    if BlackoutWorld then BlackoutWorld:Hide() end
    StripTextures(WorldMapFrame)
    StripMapChrome(WorldMapFrame)

    if WorldMapZoomOutButton then SkinButton(WorldMapZoomOutButton) end
    if WorldMapFrameCloseButton then SkinCloseButton(WorldMapFrameCloseButton, WorldMapFrame, -3, -3) end

    -- "Switch to current zone" toggle (left side of titlebar)
    if WorldMapContinentDropDown and not pfUI.map.autozoneswitch then
      local btn = CreateFrame("CheckButton", "pfUI_map_autozoneswitch", WorldMapFrame, "UICheckButtonTemplate")
      btn:SetNormalTexture("")
      btn:SetPushedTexture("")
      btn:SetHighlightTexture("")
      btn.text = _G["pfUI_map_autozoneswitchText"]
      CreateBackdrop(btn, nil, true)
      btn:SetWidth(14)
      btn:SetHeight(14)
      btn:SetPoint("RIGHT", WorldMapContinentDropDown, "LEFT", -8, 2)
      btn.text:ClearAllPoints()
      btn.text:SetPoint("RIGHT", btn, "LEFT", -4, 1)
      btn.text:SetJustifyH("RIGHT")
      btn.text:SetText(T["Switch to current zone"])
      btn:SetScript("OnShow", function()
        this:SetChecked(C.appearance.worldmap.autozoneswitch == "1")
      end)
      btn:SetScript("OnClick", function()
        if this:GetChecked() then
          C.appearance.worldmap.autozoneswitch = "1"
          pfOrigSetMapToCurrentZone()
        else
          C.appearance.worldmap.autozoneswitch = "0"
        end
      end)
      pfUI.map.autozoneswitch = btn
    end
    if WorldMapContinentDropDown then SkinDropDown(WorldMapContinentDropDown) end
    if WorldMapZoneDropDown then SkinDropDown(WorldMapZoneDropDown) end
    PositionMapControls()

    -- coordinates
    if WorldMapButton and not WorldMapButton.coords then
      WorldMapButton.coords = CreateFrame("Frame", "pfWorldMapButtonCoords", WorldMapButton)
      WorldMapButton.coords.text = WorldMapButton.coords:CreateFontString(nil, "OVERLAY")
      WorldMapButton.coords.text:SetPoint("BOTTOMRIGHT", WorldMapButton, "BOTTOMRIGHT", -10, 10)
      WorldMapButton.coords.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
      WorldMapButton.coords.text:SetTextColor(1, 1, 1)
      WorldMapButton.coords.text:SetJustifyH("RIGHT")

      WorldMapButton.coords:SetScript("OnUpdate", function()
        local width  = WorldMapButton:GetWidth()
        local height = WorldMapButton:GetHeight()
        local mx, my = WorldMapButton:GetCenter()
        local scale  = WorldMapButton:GetEffectiveScale()
        local x, y   = GetCursorPosition()

        if mx and my then
          mx = (( x / scale ) - ( mx - width / 2)) / width * 100
          my = (( my + height / 2 ) - ( y / scale )) / height * 100
        end

        if mx and my and MouseIsOver(WorldMapButton) then
          WorldMapButton.coords.text:SetText(string.format('%.1f / %.1f', mx, my))
        else
          WorldMapButton.coords.text:SetText("")
        end
      end)
    end
  end)

  pfUI.map.loader = pfMapLoader
end)
