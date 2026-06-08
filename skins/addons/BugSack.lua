pfUI.addonskinner:RegisterSkin("BugSack", function()
  local penv = pfUI:GetEnvironment()
  local StripTextures = penv.StripTextures
  local CreateBackdrop = penv.CreateBackdrop
  local SkinButton = penv.SkinButton
  local SkinCloseButton = penv.SkinCloseButton
  local SkinScrollbar = penv.SkinScrollbar
  local SkinTab = penv.SkinTab

  local skinned = false

  local function ApplySkin()
    if skinned then return true end
    if not BugSackFrame then return false end

    StripTextures(BugSackFrame, true)
    CreateBackdrop(BugSackFrame, nil, nil, .85)

    local buttons = {
      BugSackPrevButton,
      BugSackExportButton,
      BugSackClearButton,
      BugSackSendButton,
      BugSackNextButton,
    }
    for _, button in pairs(buttons) do
      if button then
        StripTextures(button)
        SkinButton(button)
        button:SetHeight(22)
      end
    end

    BugSackPrevButton:ClearAllPoints()
    BugSackPrevButton:SetPoint("BOTTOMLEFT", BugSackFrame, "BOTTOMLEFT", 14, 12)

    BugSackExportButton:ClearAllPoints()
    BugSackExportButton:SetPoint("LEFT", BugSackPrevButton, "RIGHT", 8, 0)

    BugSackClearButton:ClearAllPoints()
    BugSackClearButton:SetPoint("LEFT", BugSackExportButton, "RIGHT", 8, 0)

    if BugSackSendButton then
      BugSackSendButton:ClearAllPoints()
      BugSackSendButton:SetPoint("LEFT", BugSackClearButton, "RIGHT", 8, 0)
      BugSackSendButton:SetPoint("RIGHT", BugSackNextButton, "LEFT", -8, 0)
    end

    BugSackNextButton:ClearAllPoints()
    BugSackNextButton:SetPoint("BOTTOMRIGHT", BugSackFrame, "BOTTOMRIGHT", -14, 12)

    if BugSackFrameScroll then
      StripTextures(BugSackFrameScroll)
      CreateBackdrop(BugSackFrameScroll, nil, true, .35)
    end

    if BugSackFrameScrollScrollBar
      and BugSackFrameScrollScrollBarScrollUpButton
      and BugSackFrameScrollScrollBarScrollDownButton then
      SkinScrollbar(BugSackFrameScrollScrollBar)
    end

    local tabs = {
      BugSackTabAll,
      BugSackTabSession,
      BugSackTabLast,
    }
    for _, tab in pairs(tabs) do
      if tab then
        SkinTab(tab, true)
      end
    end

    BugSackTabAll:ClearAllPoints()
    BugSackTabAll:SetPoint("TOPLEFT", BugSackFrame, "BOTTOMLEFT", 0, -2)

    BugSackTabSession:ClearAllPoints()
    BugSackTabSession:SetPoint("LEFT", BugSackTabAll, "RIGHT", 2, 0)

    BugSackTabLast:ClearAllPoints()
    BugSackTabLast:SetPoint("LEFT", BugSackTabSession, "RIGHT", 2, 0)

    -- BugSack creates its close button without a global name.
    local frameTop = BugSackFrame:GetTop()
    local frameRight = BugSackFrame:GetRight()
    for _, child in pairs({ BugSackFrame:GetChildren() }) do
      if child and child:GetObjectType() == "Button" and not child:GetName() then
        local top = child:GetTop()
        local right = child:GetRight()
        if top and right and frameTop and frameRight
          and math.abs(frameTop - top) < 40
          and math.abs(frameRight - right) < 40 then
          SkinCloseButton(child, BugSackFrame.backdrop, -6, -6)
          break
        end
      end
    end

    skinned = true
    BugSackFrame.pfUISkinned = true
    return true
  end

  local function TryApplySkin()
    local ok, err = pcall(ApplySkin)
    pfUI_cache.addonskinner_errors = pfUI_cache.addonskinner_errors or {}
    pfUI_cache.addonskinner_errors.BugSack = ok and nil or tostring(err)
  end

  TryApplySkin()

  if BugSack and BugSack.OpenSack then
    hooksecurefunc(BugSack, "OpenSack", TryApplySkin)
  end

  pfUI.addonskinner:UnregisterSkin("BugSack")
end)
