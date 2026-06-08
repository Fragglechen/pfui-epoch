pfUI:RegisterSkin("Battlefield", "vanilla:tbc:wotlk", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  StripTextures(BattlefieldFrame)
  CreateBackdrop(BattlefieldFrame, nil, nil, .75)
  CreateBackdropShadow(BattlefieldFrame)

  BattlefieldFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
  BattlefieldFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 72)
  BattlefieldFrame:SetHitRectInsets(10,32,10,72)
  EnableMovable(BattlefieldFrame)

  SkinCloseButton(BattlefieldFrameCloseButton, BattlefieldFrame.backdrop, -6, -6)

  if BattlefieldFramePortrait then
    BattlefieldFramePortrait:Hide()
  end

  if BattlefieldFrameFrameLabel then
    BattlefieldFrameFrameLabel:ClearAllPoints()
    BattlefieldFrameFrameLabel:SetPoint("TOP", BattlefieldFrame.backdrop, "TOP", 0, -10)
  end

  if BattlefieldFrameNameHeader and BattlefieldZone1 then
    BattlefieldFrameNameHeader:ClearAllPoints()
    BattlefieldFrameNameHeader:SetPoint("BOTTOMLEFT", BattlefieldZone1, "TOPLEFT", 0, 10)
  end

  BattlefieldFrame.tex1 = BattlefieldFrame.backdrop:CreateTexture("BattlefieldFrameWorldMap1", "ARTWORK")
  BattlefieldFrame.tex1:SetTexture("Interface\\BattlefieldFrame\\UI-Battlefield-WorldMap1")
  BattlefieldFrame.tex1:SetPoint("TOPLEFT", 11, -64)
  BattlefieldFrame.tex1:SetHeight(240)
  BattlefieldFrame.tex2 = BattlefieldFrame.backdrop:CreateTexture("BattlefieldFrameWorldMap2", "ARTWORK")
  BattlefieldFrame.tex2:SetTexture("Interface\\BattlefieldFrame\\UI-Battlefield-WorldMap2")
  BattlefieldFrame.tex2:SetPoint("LEFT", BattlefieldFrame.tex1, "RIGHT", 0, 0)
  BattlefieldFrame.tex2:SetHeight(240)

  if BattlefieldListScrollFrame and BattlefieldListScrollFrameScrollBar then
    BattlefieldListScrollFrame.maxsize = CreateFrame("Frame", "BattlefieldListScrollFrameMaxSize", BattlefieldFrame)
    local offset = 2*(border + GetPerfectPixel()) + BattlefieldListScrollFrameScrollBar:GetWidth()
    BattlefieldListScrollFrame.maxsize:SetPoint("TOPLEFT", BattlefieldListScrollFrame, "TOPLEFT", 0, 0)
    BattlefieldListScrollFrame.maxsize:SetPoint("BOTTOMRIGHT", BattlefieldListScrollFrame, "BOTTOMRIGHT", offset, 0)
    CreateBackdrop(BattlefieldListScrollFrame.maxsize, nil, nil, .7)

    CreateBackdrop(BattlefieldListScrollFrame, nil, nil, .7)
    SkinScrollbar(BattlefieldListScrollFrameScrollBar)

    local texWidth1, texWidth2 = BattlefieldFrame.tex1:GetWidth(), BattlefieldFrame.tex2:GetWidth()
    BattlefieldListScrollFrame:SetScript("OnShow", function()
      BattlefieldFrame.tex1:SetWidth(texWidth1 - 12)
      BattlefieldFrame.tex2:SetWidth(texWidth2 - 12)
      if this.maxsize then this.maxsize:Hide() end
    end)
    BattlefieldListScrollFrame:SetScript("OnHide", function()
      BattlefieldFrame.tex1:SetWidth(texWidth1)
      BattlefieldFrame.tex2:SetWidth(texWidth2)
      if this.maxsize then this.maxsize:Show() end
    end)
  end

  BattlefieldFrame.textbox = CreateFrame("Frame", "BattlefieldFrameTextBox", BattlefieldFrame)
  BattlefieldFrame.textbox:SetWidth(320)
  BattlefieldFrame.textbox:SetHeight(110)
  CreateBackdrop(BattlefieldFrame.textbox)
  BattlefieldFrame.textbox:SetPoint("BOTTOM", BattlefieldFrame.backdrop, "BOTTOM", 0, 36)
  if BattlefieldFrameZoneDescription then
    BattlefieldFrameZoneDescription:ClearAllPoints()
    BattlefieldFrameZoneDescription:SetAllPoints(BattlefieldFrame.textbox)
    BattlefieldFrameZoneDescription:SetFontObject(GameFontWhite)
  end

  if BattlefieldFrameCancelButton then
    SkinButton(BattlefieldFrameCancelButton)
  end
  if BattlefieldFrameJoinButton then
    SkinButton(BattlefieldFrameJoinButton)
    BattlefieldFrameJoinButton:ClearAllPoints()
    if BattlefieldFrameCancelButton then
      BattlefieldFrameJoinButton:SetPoint("RIGHT", BattlefieldFrameCancelButton, "LEFT", -2*bpad, 0)
    end
  end
  if BattlefieldFrameGroupJoinButton then
    SkinButton(BattlefieldFrameGroupJoinButton)
    BattlefieldFrameGroupJoinButton:ClearAllPoints()
    if BattlefieldFrameJoinButton then
      BattlefieldFrameGroupJoinButton:SetPoint("RIGHT", BattlefieldFrameJoinButton, "LEFT", -2*bpad, 0)
    end
    BattlefieldFrameGroupJoinButton:SetScript("OnShow", function()
      if BattlefieldFrameCancelButton then
        BattlefieldFrameCancelButton:ClearAllPoints()
        BattlefieldFrameCancelButton:SetPoint("BOTTOMRIGHT", BattlefieldFrame.backdrop, "BOTTOMRIGHT", -bpad - 1, 2*bpad + 2)
      end
    end)
    BattlefieldFrameGroupJoinButton:SetScript("OnHide", function()
      if BattlefieldFrameCancelButton then
        BattlefieldFrameCancelButton:ClearAllPoints()
        BattlefieldFrameCancelButton:SetPoint("CENTER", BattlefieldFrame, "TOPLEFT", 305, -423)
      end
    end)
  end
end)
