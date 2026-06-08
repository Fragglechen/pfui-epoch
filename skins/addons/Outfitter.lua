pfUI.addonskinner:RegisterSkin("Outfitter", function()
  local penv = pfUI:GetEnvironment()
  local StripTextures, CreateBackdrop = penv.StripTextures, penv.CreateBackdrop
  local SetAllPointsOffset = penv.SetAllPointsOffset
  local api = pfUI.api

  local ICON_INSET = -2

  local function safe(call, frame, ...)
    if call and frame then call(frame, ...) end
  end

  local function ensure_backdrop(frame, alpha)
    if not frame then return nil end

    CreateBackdrop(frame, nil, true, alpha or .95)

    if not frame.backdrop then
      frame.backdrop = CreateFrame("Frame", nil, frame)
      frame.backdrop:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
      })
    end

    frame.backdrop:SetFrameLevel(math.max((frame:GetFrameLevel() or 1) - 1, 0))
    frame.backdrop:EnableMouse(false)

    return frame.backdrop
  end

  local function skin_checkbox(cb, size)
    if not cb or cb._pfuiSkinned then return end
    safe(api.SkinCheckbox, cb, size or 22)

    if cb.backdrop then
      cb.backdrop:ClearAllPoints()
      cb.backdrop:SetPoint("TOPLEFT", cb, "TOPLEFT", 3, -3)
      cb.backdrop:SetPoint("BOTTOMRIGHT", cb, "BOTTOMRIGHT", -3, 3)
      cb.backdrop:SetBackdropColor(0, 0, 0, .85)
      cb.backdrop:SetBackdropBorderColor(.6, .6, .6, 1)
    end

    local tex = cb.GetCheckedTexture and cb:GetCheckedTexture()
    if tex and tex.ClearAllPoints then
      tex:ClearAllPoints()
      tex:SetWidth(16)
      tex:SetHeight(16)
      tex:SetPoint("CENTER", cb, "CENTER", 0, 0)
      if tex.SetDrawLayer then tex:SetDrawLayer("OVERLAY", 7) end
      tex:SetVertexColor(1, .82, 0, 1)
    end

    cb._pfuiSkinned = true
  end

  local function skin_button(btn)
    if btn and not btn._pfuiSkinned then
      safe(api.SkinButton, btn)
      btn._pfuiSkinned = true
    end
  end

  local function skin_outfitter_button(btn)
    if not btn or btn._pfuiSkinned then return end

    for _, tex in pairs({ btn.LeftTexture, btn.RightTexture, btn.MiddleTexture, btn.HighlightTexture }) do
      if tex and tex.SetTexture then tex:SetTexture(nil) end
    end
    if btn.SetNormalTexture then btn:SetNormalTexture("") end
    if btn.SetPushedTexture then btn:SetPushedTexture("") end
    if btn.SetHighlightTexture then btn:SetHighlightTexture("") end
    if btn.SetDisabledTexture then btn:SetDisabledTexture("") end

    safe(api.SkinButton, btn)
    btn._pfuiSkinned = true
  end

  local function highlight_button(btn)
    if not btn then return end

    if btn.backdrop then
      btn.backdrop:SetBackdropBorderColor(1, .82, 0, .85)
    end

    local text = btn.GetFontString and btn:GetFontString()
    if text and text.SetTextColor then
      text:SetTextColor(1, .82, 0, 1)
    end
  end

  local function skin_editbox(box)
    if not box or box._pfuiSkinned then return end

    for _, tex in pairs({ box.LeftTexture, box.RightTexture, box.MiddleTexture }) do
      if tex and tex.SetTexture then tex:SetTexture(nil) end
    end

    local backdrop = ensure_backdrop(box, .95)
    backdrop:SetPoint("TOPLEFT", box, "TOPLEFT", -3, 3)
    backdrop:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", 3, -3)
    backdrop:SetBackdropColor(0, 0, 0, .9)
    backdrop:SetBackdropBorderColor(.55, .55, .55, 1)
    if box.SetTextColor then box:SetTextColor(1, 1, 1, 1) end
    if box.SetTextInsets then box:SetTextInsets(6, 6, 0, 0) end
    if box.HookScript then
      box:HookScript("OnEditFocusGained", function()
        if box.backdrop then box.backdrop:SetBackdropBorderColor(1, .82, 0, 1) end
      end)
      box:HookScript("OnEditFocusLost", function()
        if box.backdrop then box.backdrop:SetBackdropBorderColor(.55, .55, .55, 1) end
      end)
    end
    box._pfuiSkinned = true
  end

  local function skin_dropdown(menu)
    if not menu or menu._pfuiSkinned then return end

    for _, tex in pairs({ menu.LeftTexture, menu.RightTexture, menu.MiddleTexture }) do
      if tex and tex.SetTexture then tex:SetTexture(nil) end
    end

    local backdrop = ensure_backdrop(menu, .95)
    backdrop:SetPoint("TOPLEFT", menu, "TOPLEFT", -3, 3)
    backdrop:SetPoint("BOTTOMRIGHT", menu, "BOTTOMRIGHT", 3, -3)
    backdrop:SetBackdropColor(0, 0, 0, .9)
    backdrop:SetBackdropBorderColor(.55, .55, .55, 1)

    if menu.Button then
      menu.Button:ClearAllPoints()
      menu.Button:SetWidth(20)
      menu.Button:SetHeight(20)
      menu.Button:SetPoint("RIGHT", menu, "RIGHT", 1, 0)
      if api.SkinArrowButton then
        api.SkinArrowButton(menu.Button, "down", 16)
      else
        skin_outfitter_button(menu.Button)
      end
    end

    if menu.Text then
      menu.Text:ClearAllPoints()
      menu.Text:SetPoint("LEFT", menu, "LEFT", 6, 1)
      if menu.Button then
        menu.Text:SetPoint("RIGHT", menu.Button, "LEFT", -5, 1)
      else
        menu.Text:SetPoint("RIGHT", menu, "RIGHT", -6, 1)
      end
      menu.Text:SetJustifyH("RIGHT")
      if menu.Text.SetTextColor then menu.Text:SetTextColor(1, .82, 0, 1) end
      if menu.Text.SetDrawLayer then menu.Text:SetDrawLayer("OVERLAY", 7) end
    end

    if menu.Title then
      menu.Title:ClearAllPoints()
      menu.Title:SetPoint("RIGHT", menu, "LEFT", -10, 1)
    end

    menu._pfuiSkinned = true
  end

  local function skin_main_frame()
    if not OutfitterFrame or OutfitterFrame._pfuiSkinned then return end

    StripTextures(OutfitterFrame)
    CreateBackdrop(OutfitterFrame, nil, nil, .75)
    if api.CreateBackdropShadow then api.CreateBackdropShadow(OutfitterFrame) end

    if OutfitterButtonFrame then
      OutfitterFrame:ClearAllPoints()
      OutfitterFrame:SetPoint("TOPLEFT", OutfitterButtonFrame, "TOPRIGHT", -28, -40)
    end

    if OutfitterFrameTitle then
      OutfitterFrameTitle:ClearAllPoints()
      OutfitterFrameTitle:SetPoint("TOP", 0, -6)
    end

    if OutfitterMainFrameButtonBarBackground then
      OutfitterMainFrameButtonBarBackground:SetTexture(nil)
    end

    if OutfitterMainFrameScrollbarTrench then
      StripTextures(OutfitterMainFrameScrollbarTrench)
    end

    safe(api.SkinCloseButton, OutfitterCloseButton, OutfitterFrame.backdrop, -6, -6)
    if OutfitterCloseButton then OutfitterCloseButton:SetPoint("TOPRIGHT", -4, -4) end

    skin_button(OutfitterNewButton)
    if OutfitterNewButton then OutfitterNewButton:SetPoint("BOTTOMRIGHT", -9, 4) end

    skin_button(OutfitterEnableAll)
    if OutfitterEnableAll then OutfitterEnableAll:SetPoint("TOP", -73, -80) end

    skin_button(OutfitterEnableNone)
    if OutfitterEnableNone then OutfitterEnableNone:SetPoint("TOP", 18, -80) end

    safe(api.SkinScrollbar, OutfitterMainFrameScrollFrameScrollBar)

    for i = 0, 13 do
      local menu = _G["OutfitterItem" .. i .. "OutfitMenu"]
      if menu and not menu._pfuiSkinned then
        safe(api.SkinArrowButton, menu, "down")
        menu._pfuiSkinned = true
      end

      local collapse = _G["OutfitterItem" .. i .. "CategoryExpand"]
      if collapse and not collapse._pfuiSkinned then
        safe(api.SkinCollapseButton, collapse)
        if collapse.icon and collapse.icon.backdrop then
          collapse.icon.backdrop:SetPoint("TOPLEFT", -2, 1)
          collapse.icon.backdrop:SetPoint("BOTTOMRIGHT", 1, -2)
        end
        collapse._pfuiSkinned = true
      end
    end

    for _, name in pairs({
      "ShowMinimapButton",
      "RememberVisibility",
      "ShowHotkeyMessages",
      "ShowCurrentOutfit",
      "HideDisabledOutfits",
    }) do
      skin_checkbox(_G["Outfitter" .. name])
    end

    OutfitterFrame._pfuiSkinned = true
  end

  local function skin_dialogs()
    local name_dialog = (Outfitter and Outfitter.NameOutfitDialog and Outfitter.NameOutfitDialog ~= Outfitter) and Outfitter.NameOutfitDialog or nil
    if name_dialog and name_dialog.Open and not name_dialog._pfuiSkinned then
      StripTextures(name_dialog)
      CreateBackdrop(name_dialog, nil, nil, .75)
      if api.CreateBackdropShadow then api.CreateBackdropShadow(name_dialog) end

      name_dialog:SetFrameStrata("DIALOG")
      name_dialog:SetFrameLevel((OutfitterFrame and OutfitterFrame:GetFrameLevel() or 1) + 20)
      name_dialog:SetClampedToScreen(true)
      name_dialog:SetMovable(true)
      name_dialog:RegisterForDrag("LeftButton")
      name_dialog:SetScript("OnDragStart", function() this:StartMoving() end)
      name_dialog:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
      name_dialog:EnableKeyboard(true)
      name_dialog:SetScript("OnKeyDown", function()
        if arg1 == "ESCAPE" then this:Cancel() end
      end)

      if name_dialog.TitleBackground and name_dialog.TitleBackground.SetTexture then
        name_dialog.TitleBackground:SetTexture(nil)
      end

      skin_outfitter_button(name_dialog.DoneButton)
      skin_outfitter_button(name_dialog.CancelButton)
      highlight_button(name_dialog.DoneButton)
      skin_editbox(name_dialog.Name)
      if name_dialog.Name then
        name_dialog.Name:SetScript("OnEscapePressed", function()
          name_dialog:Cancel()
        end)
      end

      skin_checkbox(name_dialog.EmptyOutfitCheckButton, 22)
      skin_checkbox(name_dialog.ExistingOutfitCheckButton, 22)
      skin_checkbox(name_dialog.GenerateOutfitCheckButton, 22)
      skin_dropdown(name_dialog.ScriptMenu)

      for _, section in pairs({ name_dialog.InfoSection, name_dialog.BuildSection, name_dialog.StatsSection }) do
        if section and not section._pfuiSkinned then
          StripTextures(section)
          CreateBackdrop(section, nil, nil, .35)
          section._pfuiSkinned = true
        end
      end

      name_dialog._pfuiSkinned = true
    end

    if OutfitterNameOutfitDialog and not OutfitterNameOutfitDialog._pfuiSkinned then
      StripTextures(OutfitterNameOutfitDialog)
      CreateBackdrop(OutfitterNameOutfitDialog)
      if OutfitterNameOutfitDialogTitle then OutfitterNameOutfitDialogTitle:SetPoint("TOP", 0, -8) end

      if OutfitterNameOutfitDialogName then
        StripTextures(OutfitterNameOutfitDialogName, true, "BACKGROUND")
        CreateBackdrop(OutfitterNameOutfitDialogName)
        OutfitterNameOutfitDialogName:SetWidth(165)
      end

      safe(api.SkinDropDown, OutfitterNameOutfitDialogCreateUsing)
      if OutfitterNameOutfitDialogCreateUsing and OutfitterNameOutfitDialogName then
        OutfitterNameOutfitDialogCreateUsing:SetPoint("TOPLEFT", OutfitterNameOutfitDialogName, "TOPLEFT", -17, -30)
      end
      if OutfitterNameOutfitDialogCreateUsingTitle and OutfitterNameOutfitDialogCreateUsing then
        OutfitterNameOutfitDialogCreateUsingTitle:SetPoint("RIGHT", OutfitterNameOutfitDialogCreateUsing, "LEFT", 5, 0)
      end

      skin_button(OutfitterNameOutfitDialogDoneButton)
      skin_button(OutfitterNameOutfitDialogCancelButton)

      OutfitterNameOutfitDialog._pfuiSkinned = true
    end

    if OutfitterEditScriptDialog and not OutfitterEditScriptDialog._pfuiSkinned then
      StripTextures(OutfitterEditScriptDialog)
      CreateBackdrop(OutfitterEditScriptDialog, nil, nil, .75)
      if api.CreateBackdropShadow then api.CreateBackdropShadow(OutfitterEditScriptDialog) end

      for _, suffix in pairs({ "DoneButton", "CancelButton", "DeleteButton", "TestButton" }) do
        skin_button(_G["OutfitterEditScriptDialog" .. suffix])
      end

      safe(api.SkinScrollbar, OutfitterEditScriptDialogScriptScrollFrameScrollBar)
      OutfitterEditScriptDialog._pfuiSkinned = true
    end
  end

  local function skin_current_outfit_window()
    if OutfitterCurrentOutfit and not OutfitterCurrentOutfit._pfuiSkinned then
      StripTextures(OutfitterCurrentOutfit)
      CreateBackdrop(OutfitterCurrentOutfit)
      OutfitterCurrentOutfit:SetWidth(150)
      OutfitterCurrentOutfit._pfuiSkinned = true
    end
  end

  local function skinSlotName(name)
    local btn = _G[name]
    if not btn or btn._pfuiSkinned then return end
    StripTextures(btn, true)
    CreateBackdrop(btn, ICON_INSET)

    local icon = _G[name .. "Icon"] or _G[name .. "IconTexture"] or (btn.GetNormalTexture and btn:GetNormalTexture())

    if btn.SetNormalTexture then
      btn:SetNormalTexture("")
      btn.SetNormalTexture = function() return end
    end
    if btn.GetNormalTexture then
      local nt = btn:GetNormalTexture()
      if nt and nt.SetTexture then nt:SetTexture("") end
    end
    if btn.SetHighlightTexture then
      btn:SetHighlightTexture("")
      btn.SetHighlightTexture = function() return end
    end
    if btn.SetPushedTexture then
      btn:SetPushedTexture("")
      btn.SetPushedTexture = function() return end
    end
    if btn.GetPushedTexture then
      local pt = btn:GetPushedTexture()
      if pt and pt.SetTexture then pt:SetTexture("") end
      if pt and pt.Hide then pt:Hide() end
    end

    local parentLvl = (OutfitterQuickSlots and OutfitterQuickSlots:GetFrameLevel()) or (btn:GetParent() and btn:GetParent():GetFrameLevel()) or 0
    if btn.backdrop and btn.backdrop.SetFrameLevel then btn.backdrop:SetFrameLevel(parentLvl + 1) end
    if btn.backdrop and btn.backdrop.SetDrawLayer then btn.backdrop:SetDrawLayer("BORDER", 0) end
    if btn.backdrop_border and btn.backdrop_border.SetFrameLevel then btn.backdrop_border:SetFrameLevel(parentLvl + 2) end

    if icon and icon.SetTexCoord then
      icon:SetTexCoord(.07, .93, .07, .93)
      icon:SetParent(btn)
      if btn.backdrop and SetAllPointsOffset then
        SetAllPointsOffset(icon, btn.backdrop, ICON_INSET + 4)
      else
        icon:SetAllPoints(btn)
      end
      if icon.SetDrawLayer then icon:SetDrawLayer("OVERLAY", 300) end

      local base = (btn.backdrop and btn.backdrop.GetFrameLevel and btn.backdrop:GetFrameLevel()) or btn:GetFrameLevel() or 0
      if btn.backdrop_border and btn.backdrop_border.GetFrameLevel then
        local b = btn.backdrop_border:GetFrameLevel()
        if b > base then base = b end
      end
      if icon.SetFrameLevel then icon:SetFrameLevel(base + 3) end

      if hooksecurefunc and icon.SetTexture then
        hooksecurefunc(icon, "SetTexture", function(self)
          self:SetTexCoord(.07, .93, .07, .93)
        end)
      end
    end

    btn._pfuiSkinned = true
  end

  local function skin_quickslots()
    if not OutfitterQuickSlots or OutfitterQuickSlots._pfuiSkinned then return end

    StripTextures(OutfitterQuickSlots, true, "BACKGROUND")
    CreateBackdrop(OutfitterQuickSlots, nil, true, .75)

    local function hideQuickBacks()
      for i = 0, 26 do
        local f = _G["OutfitterQuickSlotsBack" .. i]
        if f and f.Hide then f:Hide() end
      end
      for _, n in pairs({
        "OutfitterQuickSlotsBackStart1",
        "OutfitterQuickSlotsBackStart2",
        "OutfitterQuickSlotsBackEnd1",
        "OutfitterQuickSlotsBackEnd2",
        "OutfitterQuickSlotsBackEnd",
      }) do
        local f = _G[n]
        if f and f.Hide then f:Hide() end
      end
    end

    local function updateSlot(name, parentIndex)
      skinSlotName(name)
      local btn = _G[name]
      if btn then
        if btn.SetNormalTexture then btn:SetNormalTexture("") end
        if btn.GetNormalTexture then
          local nt = btn:GetNormalTexture()
          if nt and nt.SetTexture then nt:SetTexture("") end
        end
        if btn.GetHighlightTexture then
          local ht = btn:GetHighlightTexture()
          if ht and ht.SetTexture then ht:SetTexture("") end
        end
      end

      local parent = _G["OutfitterQuickSlotsItem" .. (parentIndex or 0)]
      if parent and parent.GetID and btn and btn.GetID then
        local bag = parent:GetID()
        local slot = btn:GetID()
        if bag and slot then
          local _, _, _, quality = GetContainerItemInfo(bag, slot)
          if quality then
            local r, g, b = GetItemQualityColor(quality)
            if btn.backdrop and btn.backdrop.SetBackdropBorderColor then btn.backdrop:SetBackdropBorderColor(r, g, b, 1) end
            return
          end
        end
      end

      if btn and btn.backdrop and btn.backdrop.SetBackdropBorderColor then btn.backdrop:SetBackdropBorderColor(0, 0, 0, 1) end
    end

    hideQuickBacks()

    for i = 1, 27 do
      for j = 1, 2 do
        updateSlot("OutfitterQuickSlotsItem" .. i .. "Item" .. j, i)
      end
    end

    if hooksecurefunc then
      if OutfitterQuickSlots_SetNumSlots then
        hooksecurefunc("OutfitterQuickSlots_SetNumSlots", function(pNum)
          hideQuickBacks()
          for i = 1, (pNum or 0) do
            for j = 1, 2 do
              updateSlot("OutfitterQuickSlotsItem" .. i .. "Item" .. j, i)
            end
          end
        end)
      end

      if OutfitterQuickSlots_SetSlotToBag then
        hooksecurefunc("OutfitterQuickSlots_SetSlotToBag", function(index)
          updateSlot("OutfitterQuickSlotsItem" .. index .. "Item1", index)
        end)
      end

      if ContainerFrame_Update then
        hooksecurefunc("ContainerFrame_Update", function(frame)
          if not frame then return end
          local fname
          if type(frame) == "string" then
            fname = frame
          elseif type(frame) == "table" and frame.GetName then
            fname = frame:GetName()
          end
          if not fname then return end
          local _, _, parentIndex = string.find(fname, "^OutfitterQuickSlotsItem(%d+)$")
          if parentIndex then
            parentIndex = tonumber(parentIndex)
            for j = 1, 2 do
              updateSlot(fname .. "Item" .. j, parentIndex)
            end
          end
        end)
      end
    end

    OutfitterQuickSlots._pfuiSkinned = true
  end

  local function Skin()
    skin_main_frame()
    skin_dialogs()
    skin_current_outfit_window()
    skin_quickslots()
  end

  Skin()

  if OutfitterFrame and OutfitterFrame.HookScript then
    OutfitterFrame:HookScript("OnShow", Skin)
  end
  if hooksecurefunc and Outfitter and Outfitter.OpenNameOutfitDialog then
    hooksecurefunc(Outfitter, "OpenNameOutfitDialog", function()
      skin_dialogs()
    end)
  end
  if hooksecurefunc and Outfitter and Outfitter.UpdateCurrentOutfitWindow then
    hooksecurefunc(Outfitter, "UpdateCurrentOutfitWindow", function()
      skin_current_outfit_window()
    end)
  end
  if OutfitterEditScriptDialog and OutfitterEditScriptDialog.HookScript then
    OutfitterEditScriptDialog:HookScript("OnShow", skin_dialogs)
  end

  pfUI.addonskinner:UnregisterSkin("Outfitter")
end)
