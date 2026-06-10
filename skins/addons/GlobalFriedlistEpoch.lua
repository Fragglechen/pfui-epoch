pfUI.addonskinner:RegisterSkin("GlobalFriedlist-epoch", function()
  local penv = pfUI:GetEnvironment()
  local StripTextures = penv.StripTextures
  local CreateBackdrop = penv.CreateBackdrop
  local SkinButton = penv.SkinButton
  local SkinCheckbox = penv.SkinCheckbox
  local SkinCloseButton = penv.SkinCloseButton
  local SkinTab = penv.SkinTab
  local ApplySkin

  local function SkinActionButton(button)
    if not button or button.pfGlobalFriedlistSkinned then return end
    StripTextures(button)
    SkinButton(button)
    button:HookScript("OnClick", function()
      ApplySkin()
    end)
    button.pfGlobalFriedlistSkinned = true
  end

  local function SkinEditBox(editbox)
    if not editbox or editbox.pfGlobalFriedlistSkinned then return end
    StripTextures(editbox)
    editbox:SetBackdrop(nil)
    CreateBackdrop(editbox, nil, true)
    editbox:SetTextInsets(5, 5, 0, 0)
    editbox.pfGlobalFriedlistSkinned = true
  end

  local function SkinCheckButton(button)
    if not button or button.pfGlobalFriedlistSkinned then return end
    SkinCheckbox(button)
    button:HookScript("OnClick", function()
      ApplySkin()
    end)
    button.pfGlobalFriedlistSkinned = true
  end

  local function SkinSubTab(tab)
    if not tab or tab.pfGlobalFriedlistSkinned then return end
    SkinTab(tab, true)
    tab.pfGlobalFriedlistSkinned = true
  end

  local function SkinDialog(frame)
    if not frame then return end

    if not frame.pfGlobalFriedlistFrameSkinned then
      frame:SetBackdrop(nil)
      if frame.bg then
        frame.bg:Hide()
      end
      CreateBackdrop(frame, nil, nil, .85)
      frame.pfGlobalFriedlistFrameSkinned = true
    end

    if frame.close and not frame.close.pfGlobalFriedlistSkinned then
      SkinCloseButton(frame.close, frame.backdrop, -6, -6)
      frame.close.pfGlobalFriedlistSkinned = true
    end

    SkinEditBox(frame.nameEdit)
    SkinEditBox(frame.noteEdit)
    SkinActionButton(frame.save)
    SkinActionButton(frame.cancel)
    SkinActionButton(frame.accept)
    SkinActionButton(frame.decline)
  end

  local function SkinFooter(footer)
    if not footer then return end
    SkinActionButton(footer.add)
    SkinActionButton(footer.send)
    SkinActionButton(footer.remove)
    SkinActionButton(footer.invite)
  end

  ApplySkin = function()
    SkinFooter(GlobalFriedlistEpochFooter)
    SkinFooter(GlobalFriedlistEpochIgnoreFooter)
    SkinFooter(GlobalFriedlistEpochDungeonIgnoreFooter)

    SkinSubTab(GlobalFriedlistEpochSubTab1)
    SkinSubTab(GlobalFriedlistEpochSubTab2)
    SkinSubTab(GlobalFriedlistEpochSubTab3)

    SkinDialog(GlobalFriedlistEpochDialog)
    SkinDialog(GlobalFriedlistEpochDungeonIgnoreDialog)
    SkinDialog(GlobalFriedlistEpochWhoOptInDialog)

    local options = GlobalFriedlistEpochOptionsPanel
    if options then
      for _, child in pairs({ options:GetChildren() }) do
        if child and child:GetObjectType() == "Button" then
          SkinActionButton(child)
        end
      end
    end

    SkinCheckButton(GlobalFriedlistEpochUseGflWhoCheck)
    SkinCheckButton(GlobalFriedlistEpochUseAddonCheck)

    SkinEditBox(GlobalFriedlistEpochPresenceHeartbeatEdit)
    SkinEditBox(GlobalFriedlistEpochPresenceMissedEdit)
  end

  ApplySkin()

  if FriendsFrame and not FriendsFrame.pfGlobalFriedlistSkinHooked then
    FriendsFrame:HookScript("OnShow", ApplySkin)
    FriendsFrame.pfGlobalFriedlistSkinHooked = true
  end

  if InterfaceOptionsFrame and not InterfaceOptionsFrame.pfGlobalFriedlistSkinHooked then
    InterfaceOptionsFrame:HookScript("OnShow", ApplySkin)
    InterfaceOptionsFrame.pfGlobalFriedlistSkinHooked = true
  end

  local watcher = CreateFrame("Frame")
  local elapsed = 0
  watcher:SetScript("OnUpdate", function(_, update)
    elapsed = elapsed + update
    if elapsed < .2 then return end
    elapsed = 0

    if (FriendsFrame and FriendsFrame:IsShown())
      or (InterfaceOptionsFrame and InterfaceOptionsFrame:IsShown())
      or (GlobalFriedlistEpochDialog and GlobalFriedlistEpochDialog:IsShown())
      or (GlobalFriedlistEpochDungeonIgnoreDialog and GlobalFriedlistEpochDungeonIgnoreDialog:IsShown())
      or (GlobalFriedlistEpochWhoOptInDialog and GlobalFriedlistEpochWhoOptInDialog:IsShown()) then
      ApplySkin()
    end
  end)
end)
