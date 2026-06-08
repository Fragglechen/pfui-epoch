pfUI.addonskinner:RegisterSkin("AtlasQuest", function()
  -- upvalue the pfUI methods we use to avoid repeated lookups
  local penv = pfUI:GetEnvironment()
  local StripTextures, CreateBackdrop, SkinCloseButton, SkinButton, SkinArrowButton, 
    SkinCheckbox, SkinCollapseButton, SetAllPointsOffset, SetHighlight, SkinScrollbar, 
    HookScript, hooksecurefunc, SkinDropDown, SkinSlider = 
  penv.StripTextures, penv.CreateBackdrop, penv.SkinCloseButton, penv.SkinButton, penv.SkinArrowButton, 
  penv.SkinCheckbox, penv.SkinCollapseButton, penv.SetAllPointsOffset, penv.SetHighlight, penv.SkinScrollbar, 
  penv.HookScript, penv.hooksecurefunc, penv.SkinDropDown, penv.SkinSlider

  local function reposition()
    if not AtlasQuestFrame or not AtlasFrame then return end

    local side = "Left"
    local playerName = UnitName and UnitName("player")
    if AtlasQuest_Options and playerName and AtlasQuest_Options[playerName]
      and AtlasQuest_Options[playerName]["ShownSide"] then
      side = AtlasQuest_Options[playerName]["ShownSide"]
    end

    AtlasQuestFrame:ClearAllPoints()
    if side == "Right" then
      AtlasQuestFrame:SetPoint("LEFT", AtlasFrame, "RIGHT", -2, 4)
    else
      AtlasQuestFrame:SetPoint("RIGHT", AtlasFrame, "LEFT", 2, 4)
    end

    AtlasQuestFrame:SetFrameStrata(AtlasFrame:GetFrameStrata())
    AtlasQuestFrame:SetFrameLevel(AtlasFrame:GetFrameLevel() + 5)
  end

  local closeButton = _G.AtlasQuestFrameCloseButton or _G.CLOSEbutton
  local insideCloseButton = _G.AtlasQuestInsideFrameCloseButton or _G.CLOSEbutton2
  local atlasQuestButton = _G.AtlasQuestButton or _G.CLOSEbutton3
  local allianceButton = _G.AtlasQuestFrameAllianceButton or _G.AQACB
  local hordeButton = _G.AtlasQuestFrameHordeButton or _G.AQHCB
  local storyButton = _G.AtlasQuestFrameStoryButton or _G.STORYbutton
  local optionsButton = _G.AtlasQuestFrameOptionsButton or _G.OPTIONbutton

  StripTextures(AtlasQuestFrame, nil, "ARTWORK")
  CreateBackdrop(AtlasQuestFrame, nil, nil, .75)
  if closeButton then
    closeButton:SetText("")
    SkinCloseButton(closeButton, AtlasQuestFrame.backdrop)
    closeButton:ClearAllPoints()
    closeButton:SetPoint("TOPLEFT", AtlasQuestFrame.backdrop, "TOPLEFT", 6, -6)
  end
  if AtlasQuestInsideFrame then
    StripTextures(AtlasQuestInsideFrame)
    CreateBackdrop(AtlasQuestInsideFrame, nil, nil, .9)
    if insideCloseButton then
      insideCloseButton:SetText("")
      SkinCloseButton(insideCloseButton, AtlasQuestInsideFrame.backdrop, -6, -6)
    end
  end
  if atlasQuestButton then
    SkinButton(atlasQuestButton)
  end

  if _G.Atlas_OnShow then
    hooksecurefunc("Atlas_OnShow", function()
      reposition()
    end, true)
  end
  if _G.AQ_AtlasOrAlphamap then
    hooksecurefunc("AQ_AtlasOrAlphamap", function()
      reposition()
    end, true)
  end
  if _G.AQRIGHTOption_OnClick then
    hooksecurefunc("AQRIGHTOption_OnClick", function()
      reposition()
    end, true)
  end
  if _G.AQLEFTOption_OnClick then
    hooksecurefunc("AQLEFTOption_OnClick", function()
      reposition()
    end, true)
  end
  AtlasQuestFrame:HookScript("OnShow", function()
    reposition()
  end)

  if allianceButton then SkinCheckbox(allianceButton, 20) end
  if hordeButton then SkinCheckbox(hordeButton, 20) end
  if storyButton then SkinButton(storyButton) end
  if optionsButton then SkinButton(optionsButton) end

-->>-- Options frame
  if AtlasQuestOptionFrame then
    StripTextures(AtlasQuestOptionFrame)
    CreateBackdrop(AtlasQuestOptionFrame, nil, nil, .75)
  end
  if AQAutoshowOption then SkinCheckbox(AQAutoshowOption,20) end
  if AQLEFTOption then SkinCheckbox(AQLEFTOption,20) end
  if AQRIGHTOption then SkinCheckbox(AQRIGHTOption,20) end
  if AQOptionCloseButton then SkinButton(AQOptionCloseButton) end

  reposition()

  pfUI.addonskinner:UnregisterSkin("AtlasQuest")
end)
