pfUI:RegisterSkin("Options - Sound", "vanilla:tbc:wotlk", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()
  local frame = SoundOptionsFrame or AudioOptionsFrame
  if not frame then return end

  -- Compatibility
  local SoundOptionsFrameHeaderText, NUM_CHECKBOXES, NUM_SLIDERS
  if SOUND_OPTIONS then -- tbc
    SoundOptionsFrameHeaderText = GetNoNameObject(frame, "FontString", "BACKGROUND", SOUND_OPTIONS)
    NUM_CHECKBOXES = 11
    NUM_SLIDERS = 6

    if AudioOptionsFrame then
      StripTextures(AudioOptionsFrame)
    else
      StripTextures(frame)
    end
    if SoundOptionsFramePlayback then CreateBackdrop(SoundOptionsFramePlayback, nil, true, .75) end
    if SoundOptionsFrameHardware then CreateBackdrop(SoundOptionsFrameHardware, nil, true, .75) end
    if SoundOptionsFrameVolume then CreateBackdrop(SoundOptionsFrameVolume, nil, true, .75) end

    if SoundOptionsOutputDropDown then
      SkinDropDown(SoundOptionsOutputDropDown)
    end

    if SoundOptionsFrameDefaults then
      SoundOptionsFrameDefaults:ClearAllPoints()
      if SoundOptionsFramePlayback then
        SoundOptionsFrameDefaults:SetPoint("TOPLEFT", SoundOptionsFramePlayback, "BOTTOMLEFT", 0, -10)
      end
    end
    if SoundOptionsFrameCancel then
      SoundOptionsFrameCancel:ClearAllPoints()
      if SoundOptionsFrameVolume then
        SoundOptionsFrameCancel:SetPoint("TOPRIGHT", SoundOptionsFrameVolume, "BOTTOMRIGHT", 0, -10)
      end
    end
    if SoundOptionsFrameOkay and SoundOptionsFrameCancel then
      SoundOptionsFrameOkay:ClearAllPoints()
      SoundOptionsFrameOkay:SetPoint("RIGHT", SoundOptionsFrameCancel, "LEFT", -2*bpad, 0)
    end
  else -- vanilla
    SoundOptionsFrameHeaderText = GetNoNameObject(frame, "FontString", "ARTWORK", SOUNDOPTIONS_MENU)
    NUM_CHECKBOXES = 8
    NUM_SLIDERS = 4

    if SoundOptionsFrameOkay and SoundOptionsFrameCancel then
      SoundOptionsFrameOkay:ClearAllPoints()
      SoundOptionsFrameOkay:SetPoint("RIGHT", SoundOptionsFrameCancel, "LEFT", -2*bpad, 0)
    end
    if SoundOptionsFrameSlider1 then
      SoundOptionsFrameSlider1:ClearAllPoints()
      SoundOptionsFrameSlider1:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -18, -43)
    end
    for i=2, NUM_SLIDERS do
      local slider = _G["SoundOptionsFrameSlider"..i]
      local prev = _G["SoundOptionsFrameSlider"..i-1]
      if slider and prev then
        slider:ClearAllPoints()
        slider:SetPoint("TOP", prev, "BOTTOM", 0, -30)
      end
    end
  end

  StripTextures(frame)
  CreateBackdrop(frame, nil, true, .75)
  CreateBackdropShadow(frame)

  EnableMovable(frame)

  HookScript(frame, "OnShow", function()
    this:ClearAllPoints()
    this:SetPoint("CENTER", 0, 0)
  end)

  if SoundOptionsFrameHeaderText then
    SoundOptionsFrameHeaderText:ClearAllPoints()
    SoundOptionsFrameHeaderText:SetPoint("TOP", 0, -10)
  end

  if SoundOptionsFrameDefaults then SkinButton(SoundOptionsFrameDefaults) end
  if SoundOptionsFrameCancel then SkinButton(SoundOptionsFrameCancel) end
  if SoundOptionsFrameOkay then SkinButton(SoundOptionsFrameOkay) end

  for i=1, NUM_CHECKBOXES do
    local btn = _G["SoundOptionsFrameCheckButton"..i]
    if btn then
      SkinCheckbox(btn, 28)
    end
  end

  for i=1, NUM_SLIDERS do
    local slider = _G["SoundOptionsFrameSlider"..i]
    if slider then
      SkinSlider(slider)
    end
  end
end)
