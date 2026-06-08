pfUI:RegisterSkin("Options - Video", "vanilla:tbc:wotlk", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()
  if not OptionsFrame then return end

  -- Compatibility
  local MAX_SLIDERS, MAX_CHECKBOXES
  if OptionsFrameSlider10 then -- tbc
    MAX_SLIDERS = 11
    MAX_CHECKBOXES = 19

    for i=1, MAX_SLIDERS do
      local slider = _G["OptionsFrameSlider"..i]
      if slider then
        local shift = 0
        if i == 4 or i == 5 or i == 7 or i == 8 or i == 10 or i == 11 then shift = 10 end
        local point, anchor, anchorPoint, x, y = slider:GetPoint()
        slider:ClearAllPoints()
        slider:SetPoint(point, anchor, anchorPoint, x, y - shift)
      end
    end

    if type(_G.OptionsFrame_Load) == "function" then
      hooksecurefunc("OptionsFrame_Load", function()
        if OptionsFramePixelShaders then
          OptionsFramePixelShaders:SetWidth(230)
        end
        if OptionsFrameMiscellaneous and OptionsFramePixelShaders then
          OptionsFrameMiscellaneous:ClearAllPoints()
          OptionsFrameMiscellaneous:SetPoint("LEFT", OptionsFramePixelShaders, "RIGHT", 6, 0)
        end
      end)
    end
    if OptionsFrameDefaults and OptionsFramePixelShaders then
      OptionsFrameDefaults:ClearAllPoints()
      OptionsFrameDefaults:SetPoint("TOPLEFT", OptionsFramePixelShaders, "BOTTOMLEFT", 0, -10)
    end
    if OptionsFrameCancel and OptionsFrameMiscellaneous then
      OptionsFrameCancel:ClearAllPoints()
      OptionsFrameCancel:SetPoint("TOPRIGHT", OptionsFrameMiscellaneous, "BOTTOMRIGHT", 0, -10)
    end
  else -- vanilla
    MAX_SLIDERS = 9
    MAX_CHECKBOXES = 18

    for i=1, MAX_SLIDERS do
      local slider = _G["OptionsFrameSlider"..i]
      if slider then
        local shift = 0
        if i == 1 or i == 6 then shift = 4
        elseif i == 4 or i == 8 then shift = 10
        end
        local point, anchor, anchorPoint, x, y = slider:GetPoint()
        slider:ClearAllPoints()
        slider:SetPoint(point, anchor, anchorPoint, x, y - shift)
      end
    end
  end

  CreateBackdrop(OptionsFrame, nil, nil, .75)
  CreateBackdropShadow(OptionsFrame)

  EnableMovable(OptionsFrame)

  HookScript(OptionsFrame, "OnShow", function()
    this:ClearAllPoints()
    this:SetPoint("CENTER", 0, 0)
  end)

  if OptionsFrameHeader then
    OptionsFrameHeader:SetTexture("")
  end
  local OptionsFrameHeaderText = GetNoNameObject(OptionsFrame, "FontString", "ARTWORK", VIDEOOPTIONS_MENU)
  if OptionsFrameHeaderText then
    OptionsFrameHeaderText:ClearAllPoints()
    OptionsFrameHeaderText:SetPoint("TOP", OptionsFrame.backdrop, "TOP", 0, -10)
  end

  if OptionsFrameDisplay then CreateBackdrop(OptionsFrameDisplay, nil, true, .75) end
  if OptionsFrameWorldAppearance then CreateBackdrop(OptionsFrameWorldAppearance, nil, true, .75) end
  if OptionsFrameBrightness then CreateBackdrop(OptionsFrameBrightness, nil, true, .75) end
  if OptionsFramePixelShaders then CreateBackdrop(OptionsFramePixelShaders, nil, true, .75) end
  if OptionsFrameMiscellaneous then CreateBackdrop(OptionsFrameMiscellaneous, nil, true, .75) end

  if OptionsFrameDefaults then SkinButton(OptionsFrameDefaults) end
  if OptionsFrameCancel then SkinButton(OptionsFrameCancel) end
  if OptionsFrameOkay then SkinButton(OptionsFrameOkay) end
  if OptionsFrameOkay and OptionsFrameCancel then
    OptionsFrameOkay:ClearAllPoints()
    OptionsFrameOkay:SetPoint("RIGHT", OptionsFrameCancel, "LEFT", -2*bpad, 0)
  end

  if OptionsFrameResolutionDropDown then SkinDropDown(OptionsFrameResolutionDropDown) end
  if OptionsFrameRefreshDropDown then SkinDropDown(OptionsFrameRefreshDropDown) end
  if OptionsFrameMultiSampleDropDown then SkinDropDown(OptionsFrameMultiSampleDropDown) end

  for i=1, MAX_SLIDERS do
    local slider = _G["OptionsFrameSlider"..i]
    if slider then
      SkinSlider(slider)
    end
  end

  for i=1, MAX_CHECKBOXES do
    local btn = _G["OptionsFrameCheckButton"..i]
    if btn then
      SkinCheckbox(btn, 28)
    end
  end
end)
