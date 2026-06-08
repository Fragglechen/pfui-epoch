pfUI:RegisterSkin("Stack Split", "vanilla:tbc:wotlk", function ()
  StripTextures(StackSplitFrame)
  CreateBackdrop(StackSplitFrame, nil, nil, .75)
  CreateBackdropShadow(StackSplitFrame)

  SkinButton(StackSplitOkayButton)
  SkinButton(StackSplitCancelButton)
end)

pfUI:RegisterSkin("Coin Pickup", "vanilla:tbc:wotlk", function ()
  StripTextures(CoinPickupFrame)
  CreateBackdrop(CoinPickupFrame, nil, nil, .75)
  CreateBackdropShadow(CoinPickupFrame)

  SkinButton(CoinPickupOkayButton)
  SkinButton(CoinPickupCancelButton)
end)

pfUI:RegisterSkin("Color Picker", "vanilla:tbc:wotlk", function ()
  CreateBackdrop(ColorPickerFrame)
  CreateBackdropShadow(ColorPickerFrame)

  ColorPickerFrameHeader:SetTexture("")

  SkinButton(ColorPickerOkayButton)
  ColorPickerOkayButton:ClearAllPoints()
  ColorPickerOkayButton:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "BOTTOM", -4, 10)
  SkinButton(ColorPickerCancelButton)
  ColorPickerCancelButton:ClearAllPoints()
  ColorPickerCancelButton:SetPoint("BOTTOMLEFT", ColorPickerFrame, "BOTTOM", 4, 10)

  SkinSlider(OpacitySliderFrame)
end)

pfUI:RegisterSkin("Opacity", "vanilla:tbc:wotlk", function ()
  CreateBackdrop(OpacityFrame, nil, true, .75)
  CreateBackdropShadow(OpacityFrame)

  SkinSlider(OpacityFrameSlider)
  OpacityFrameSlider:ClearAllPoints()
  OpacityFrameSlider:SetPoint("CENTER", 0, 0)
end)

pfUI:RegisterSkin("Tutorial", "vanilla:tbc:wotlk", function ()
  CreateBackdrop(TutorialFrame, nil, true, .75)
  CreateBackdropShadow(TutorialFrame)

  SkinCheckbox(TutorialFrameCheckButton)
  SkinButton(TutorialFrameOkayButton)
end)

pfUI:RegisterSkin("Quest Timer", "vanilla:tbc:wotlk", function ()
  local function SkinQuestTimerFrame()
    if not QuestTimerFrame or QuestTimerFrame.pfSkinned then return end

    CreateBackdrop(QuestTimerFrame, nil, nil, .75)
    CreateBackdropShadow(QuestTimerFrame)
    UpdateMovable(QuestTimerFrame, true)
    if QuestTimerHeader then
      QuestTimerHeader:Hide()
    end

    -- UIParent_ManageFramePositions overwrites positions. Ignore those:
    QuestTimerFrame._SetPoint = QuestTimerFrame._SetPoint or QuestTimerFrame.SetPoint
    QuestTimerFrame.SetPoint = function(self, a, b, c, d, e, f)
      if b ~= "MinimapCluster" then self:_SetPoint(a,b,c,d,e,f) end
    end

    QuestTimerFrame.pfSkinned = true
  end

  if QuestTimerFrame then
    SkinQuestTimerFrame()
    return
  end

  local watcher = CreateFrame("Frame")
  watcher:SetScript("OnUpdate", function()
    if QuestTimerFrame then
      SkinQuestTimerFrame()
      this:SetScript("OnUpdate", nil)
    end
  end)
end)
