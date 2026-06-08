pfUI:RegisterSkin("Character", "vanilla:tbc:wotlk", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()
  -- Compatibility
  if PlayerTitleDropDown then -- tbc, wotlk
    -- Character Tab
    SkinDropDown(PlayerTitleDropDown)
    PlayerTitleDropDown:SetPoint("TOP", CharacterLevelText, "BOTTOM", 0, -2)
    PlayerTitleDropDownText:SetPoint("LEFT", PlayerTitleDropDown.backdrop, "LEFT", 6, 2)
    SkinDropDown(PlayerStatFrameLeftDropDown)
    SkinDropDown(PlayerStatFrameRightDropDown)

    -- Honor Tab
  else -- vanilla
    -- Honor Tab
    StripTextures(HonorFrame)

    HonorFrameProgressBar:SetStatusBarTexture(pfUI.media["img:bar"])
    CreateBackdrop(HonorFrameProgressBar)
    HonorFrameProgressBar:SetHeight(24)
  end

  local magicResTextureCords = {
    {0.21875, 0.78125, 0.25, 0.3203125},
    {0.21875, 0.78125, 0.0234375, 0.09375},
    {0.21875, 0.78125, 0.13671875, 0.20703125},
    {0.21875, 0.78125, 0.36328125, 0.43359375},
    {0.21875, 0.78125, 0.4765625, 0.546875}
  }

  CreateBackdrop(CharacterFrame, nil, nil, .75)
  CreateBackdropShadow(CharacterFrame)

  CharacterFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
  CharacterFrame.backdrop:SetPoint("BOTTOMRIGHT", -30, 72)
  CharacterFrame:SetHitRectInsets(10,30,10,72)
  EnableMovable("CharacterFrame", nil, CHARACTERFRAME_SUBFRAMES)

  SkinCloseButton(CharacterFrameCloseButton, CharacterFrame.backdrop, -6, -6)

  CharacterFrame:DisableDrawLayer("ARTWORK")

  if CharacterNameText then
    CharacterNameText:ClearAllPoints()
    CharacterNameText:SetPoint("TOP", CharacterFrame.backdrop, "TOP", 0, -10)
  end

  if CharacterFrameTab1 then
    CharacterFrameTab1:ClearAllPoints()
    CharacterFrameTab1:SetPoint("TOPLEFT", CharacterFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
  end
  for i = 1, 8 do
    local tab = _G["CharacterFrameTab"..i]
    local lastTab = _G["CharacterFrameTab"..(i-1)]
    if tab and lastTab and lastTab:IsShown() then
      tab:ClearAllPoints()
      tab:SetPoint("LEFT", lastTab, "RIGHT", border*2 + 1, 0)
    end
    if tab then
      SkinTab(tab)
    end
  end

  do -- Character tab routing and BetterCharacterStats refresh
    local NormalizeFrameLevel

    local function NormalizeFrameRegions(frame)
      if not frame then return end

      for _, region in ipairs({ frame:GetRegions() }) do
        if region and region.SetDrawLayer then
          if region.GetObjectType and region:GetObjectType() == "FontString" then
            region:SetDrawLayer("OVERLAY")
            if region.SetAlpha then region:SetAlpha(1) end
          else
            region:SetDrawLayer("BORDER")
            if frame ~= BCSFrame and region.SetAlpha then region:SetAlpha(1) end
          end
        end
      end
    end

    local function NormalizeBCSText(frame)
      if not frame then return end

      local label = _G[frame:GetName() .. "Label"]
      local text = _G[frame:GetName() .. "StatText"]

      if label then
        label:SetDrawLayer("OVERLAY")
        label:SetAlpha(1)
        label:SetTextColor(1, .82, 0, 1)
      end

      if text then
        text:SetDrawLayer("OVERLAY")
        text:SetAlpha(1)
      end
    end

    local function RaiseBCSDropDownList()
      if DropDownList1 then
        DropDownList1:SetFrameStrata("TOOLTIP")
        DropDownList1:SetFrameLevel(250)
      end

      for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
        local button = _G["DropDownList1Button" .. i]
        if button then
          button:SetFrameStrata("TOOLTIP")
          button:SetFrameLevel(251)
          if button:GetFontString() then
            button:GetFontString():SetDrawLayer("OVERLAY")
            button:GetFontString():SetAlpha(1)
          end
        end
      end
    end

    local function NormalizeBCSDropDownChecks()
      local openMenu = UIDROPDOWNMENU_OPEN_MENU
      if not openMenu or not openMenu.GetName then return end

      local menuName = openMenu:GetName()
      local expectedValue

      if menuName == "PlayerStatFrameLeftDropDown" then
        expectedValue = openMenu.selectedValue or (BCSConfigEpoch and BCSConfigEpoch["DropdownLeft"])
      elseif menuName == "PlayerStatFrameRightDropDown" then
        expectedValue = openMenu.selectedValue or (BCSConfigEpoch and BCSConfigEpoch["DropdownRight"])
      else
        return
      end

      if not expectedValue then return end

      for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
        local button = _G["DropDownList1Button" .. i]
        if button and button:IsShown() then
          local isSelected = button.value == expectedValue
          local check = button.Check or _G[button:GetName() .. "Check"]

          button.checked = isSelected

          if check then
            if isSelected then
              check:Show()
            else
              check:Hide()
            end
          end
        end
      end
    end

    local function QueueRaiseBCSDropDownList()
      RaiseBCSDropDownList()
      NormalizeBCSDropDownChecks()

      if DropDownList1 and not DropDownList1.pfBCSOnShowHooked then
        local oldShow = DropDownList1:GetScript("OnShow")
        DropDownList1:SetScript("OnShow", function(self, ...)
          if oldShow then oldShow(self, ...) end
          RaiseBCSDropDownList()
          NormalizeBCSDropDownChecks()
        end)
        DropDownList1.pfBCSOnShowHooked = true
      end

      if not pfBCSDropDownRaiser then
        CreateFrame("Frame", "pfBCSDropDownRaiser", UIParent)
      end

      pfBCSDropDownRaiser.ticks = 2
      pfBCSDropDownRaiser:SetScript("OnUpdate", function()
          if this.ticks and this.ticks > 0 then
            RaiseBCSDropDownList()
            NormalizeBCSDropDownChecks()
            this.ticks = this.ticks - 1
          else
            this:SetScript("OnUpdate", nil)
          end
      end)
    end

    local function NormalizeBCSDropDown(frame, level)
      if not frame then return end

      NormalizeFrameLevel(frame, level)

      if frame.backdrop then
        frame.backdrop:SetFrameStrata(CharacterFrame:GetFrameStrata())
        frame.backdrop:SetFrameLevel(level - 1)
        frame.backdrop:Show()
      end

      if frame.button then
        frame.button:SetFrameStrata(CharacterFrame:GetFrameStrata())
        frame.button:SetFrameLevel(level + 1)
      end

      local text = _G[frame:GetName() .. "Text"]
      if text then
        text:Show()
        text:SetAlpha(1)
        text:SetDrawLayer("OVERLAY")
        text:SetTextColor(1, 1, 1, 1)
        text:ClearAllPoints()
        text:SetPoint("LEFT", frame.backdrop or frame, "LEFT", 8, 3)
        text:SetPoint("RIGHT", frame.backdrop or frame, "RIGHT", -24, 3)
        text:SetJustifyH("LEFT")
        text:SetWidth(76)
      end

      local button = frame.button or _G[frame:GetName() .. "Button"]
      if button and not frame.pfBCSDropDownListHooked then
        local oldClick = button:GetScript("OnClick")
        button:SetScript("OnClick", function(self, ...)
          if oldClick then oldClick(self or this, ...) end
          QueueRaiseBCSDropDownList()
        end)
        frame.pfBCSDropDownListHooked = true
      end
    end

    local function SkinBCSBackground()
      if not BCSFrame then return end

      if BCSFrame.SetBackdrop then BCSFrame:SetBackdrop(nil) end

      for _, region in ipairs({ BCSFrame:GetRegions() }) do
        if region and region.SetTexture then
          region:SetTexture(nil)
          region:SetAlpha(0)
          region:SetDrawLayer("BACKGROUND")
          region:Hide()
        end
      end

      for _, texture in ipairs({
        PlayerStatLeftTop, PlayerStatLeftMiddle, PlayerStatLeftBottom,
        PlayerStatRightTop, PlayerStatRightMiddle, PlayerStatRightBottom,
      }) do
        if texture then
          texture:SetTexture(nil)
          texture:SetAlpha(0)
          texture:SetDrawLayer("BACKGROUND")
          texture:Hide()
        end
      end

      if BCSFrame.backdrop then
        BCSFrame.backdrop:SetBackdrop(nil)
        BCSFrame.backdrop:Hide()
      end

      for _, child in ipairs({ BCSFrame:GetChildren() }) do
        if child and child.SetBackdrop and child ~= PlayerStatFrameLeftDropDown and child ~= PlayerStatFrameRightDropDown then
          child:SetBackdrop(nil)
        end

        if child and child.backdrop and child ~= PlayerStatFrameLeftDropDown and child ~= PlayerStatFrameRightDropDown then
          child.backdrop:SetBackdrop(nil)
          child.backdrop:Hide()
        end

        if child then
          for _, region in ipairs({ child:GetRegions() }) do
            if region and region.GetObjectType and region:GetObjectType() ~= "FontString" and region.SetAlpha then
              region:SetAlpha(0)
              if region.SetTexture then region:SetTexture(nil) end
              region:Hide()
            end
          end
        end
      end
    end

    NormalizeFrameLevel = function(frame, level)
      if not frame then return end
      frame:SetFrameStrata(CharacterFrame:GetFrameStrata())
      frame:SetFrameLevel(level)
      frame:SetAlpha(1)
      NormalizeFrameRegions(frame)

      for _, child in ipairs({ frame:GetChildren() }) do
        child:SetFrameStrata(CharacterFrame:GetFrameStrata())
        child:SetFrameLevel(level + 1)
        child:SetAlpha(1)
        NormalizeFrameRegions(child)
      end
    end

    local function NormalizeBCSLevels()
      if not CharacterFrame then return end

      local frameLevel = CharacterFrame:GetFrameLevel()
      local modelLevel = CharacterModelFrame and CharacterModelFrame:GetFrameLevel() or frameLevel
      local backdropLevel = CharacterFrame.backdrop and CharacterFrame.backdrop:GetFrameLevel() or frameLevel
      local base = math.max(frameLevel + 12, modelLevel + 12, backdropLevel + 4)

      if BCSFrame then
        BCSFrame:SetParent(PaperDollFrame or CharacterFrame)
        BCSFrame:SetFrameStrata(CharacterFrame:GetFrameStrata())
        BCSFrame:SetFrameLevel(base)
        BCSFrame:SetAlpha(1)
        NormalizeFrameRegions(BCSFrame)
        SkinBCSBackground()
      end

      NormalizeFrameLevel(PlayerStatFrameLeft, base + 6)
      NormalizeFrameLevel(PlayerStatFrameRight, base + 6)
      NormalizeBCSDropDown(PlayerStatFrameLeftDropDown, base + 8)
      NormalizeBCSDropDown(PlayerStatFrameRightDropDown, base + 8)

      for i = 1, 6 do
        NormalizeFrameLevel(_G["PlayerStatFrameLeft"..i], base + 6)
        NormalizeFrameLevel(_G["PlayerStatFrameRight"..i], base + 6)
        NormalizeBCSText(_G["PlayerStatFrameLeft"..i])
        NormalizeBCSText(_G["PlayerStatFrameRight"..i])
      end
    end

    local function LayoutBCSRows()
      if not BCSFrame then return end

      local function LayoutSide(prefix, xOffset)
        for i = 1, 6 do
          local frame = _G[prefix .. i]
          local statFrame = _G[prefix .. i .. "Stat"]
          local label = _G[prefix .. i .. "Label"]
          local text = _G[prefix .. i .. "StatText"]

          if frame then
            frame:SetParent(BCSFrame)
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", BCSFrame, "TOPLEFT", xOffset, -3 - ((i - 1) * 13))
            frame:SetWidth(104)
            frame:SetHeight(13)
            frame:Show()
          end

          if statFrame then
            statFrame:SetParent(frame or BCSFrame)
            statFrame:ClearAllPoints()
            statFrame:SetPoint("RIGHT", frame or BCSFrame, "RIGHT", 0, 0)
            statFrame:SetWidth(34)
            statFrame:SetHeight(13)
            statFrame:Show()
          end

          if label then
            label:SetParent(frame or BCSFrame)
            label:ClearAllPoints()
            label:SetPoint("LEFT", frame or BCSFrame, "LEFT", 0, 0)
            label:SetWidth(68)
            label:SetJustifyH("LEFT")
            label:SetDrawLayer("OVERLAY", 7)
            label:SetAlpha(1)
            label:Show()
          end

          if text then
            text:SetParent(statFrame or frame or BCSFrame)
            text:ClearAllPoints()
            text:SetPoint("RIGHT", statFrame or frame or BCSFrame, "RIGHT", 0, 0)
            text:SetWidth(34)
            text:SetJustifyH("RIGHT")
            text:SetDrawLayer("OVERLAY", 7)
            text:SetAlpha(1)
            text:Show()
          end
        end
      end

      LayoutSide("PlayerStatFrameLeft", 6)
      LayoutSide("PlayerStatFrameRight", 121)
    end

    local function RefreshBCS()
      if BCSFrame then
        BCSFrame:Show()
        NormalizeBCSLevels()
        LayoutBCSRows()

      end
      if CharacterAttributesFrame then
        CharacterAttributesFrame:Hide()
      end
      if BCS and BCS.UpdateStats then
        BCS.needScanGear = true
        BCS.needScanTalents = true
        BCS.needScanAuras = true
        BCS.needScanSkills = true
        local ok, err = pcall(BCS.UpdateStats, BCS)
        if ok then
          NormalizeBCSLevels()
        elseif DEFAULT_CHAT_FRAME and err then
          DEFAULT_CHAT_FRAME:AddMessage("|cffff5555pfUI BCS error:|r " .. tostring(err))
        end
      end
    end

    local function SafeCall(func, ...)
      if type(func) ~= "function" then return nil end
      local ok, a, b, c, d, e = pcall(func, ...)
      if ok then return a, b, c, d, e end
      return nil
    end

    local function GetPvPStatValues()
      local todayKills, _, todayHonor = SafeCall(GetPVPSessionStats)
      local yesterdayKills, yesterdayHonor = SafeCall(GetPVPYesterdayStats)
      local lifetimeKills = SafeCall(GetPVPLifetimeStats)
      local honor = SafeCall(GetHonorCurrency) or UnitHonor and UnitHonor("player") or 0
      local conquest = SafeCall(GetConquestCurrency) or SafeCall(GetArenaCurrency) or 0

      return {
        honor = honor or 0,
        conquest = conquest or 0,
        todayKills = todayKills or 0,
        todayHonor = todayHonor or 0,
        yesterdayKills = yesterdayKills or 0,
        yesterdayHonor = yesterdayHonor or 0,
        lifetimeKills = lifetimeKills or 0,
      }
    end

    local function SetText(fontString, text, r, g, b)
      if not fontString then return end
      fontString:SetText(text)
      if r then fontString:SetTextColor(r, g, b) end
    end

    local function CreatePvPPanel()
      if pfCharacterPvPFrame then return pfCharacterPvPFrame end

      local frame = CreateFrame("Frame", "pfCharacterPvPFrame", CharacterFrame)
      frame:SetPoint("TOPLEFT", CharacterFrame.backdrop, "TOPLEFT", 18, -42)
      frame:SetPoint("BOTTOMRIGHT", CharacterFrame.backdrop, "BOTTOMRIGHT", -18, 18)
      CreateBackdrop(frame, nil, nil, .45)
      frame:Hide()

      frame.top = CreateFrame("Frame", nil, frame)
      frame.top:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, -12)
      frame.top:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -22, -12)
      frame.top:SetHeight(166)
      CreateBackdrop(frame.top, nil, nil, .25)

      frame.portrait = frame:CreateTexture(nil, "ARTWORK")
      frame.portrait:SetWidth(54)
      frame.portrait:SetHeight(54)
      frame.portrait:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -12)

      frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.title:SetPoint("TOP", frame.top, "TOP", 0, -14)
      frame.title:SetText("Player vs. Player")
      frame.title:SetTextColor(1, .82, 0)

      frame.honorLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.honorLabel:SetPoint("TOP", frame.top, "TOP", -48, -48)
      frame.honorLabel:SetText((HONOR or "Honor") .. ":")
      frame.honorValue = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.honorValue:SetPoint("LEFT", frame.honorLabel, "RIGHT", 8, 0)
      frame.honorIcon = frame:CreateTexture(nil, "OVERLAY")
      frame.honorIcon:SetWidth(18)
      frame.honorIcon:SetHeight(18)
      frame.honorIcon:SetPoint("LEFT", frame.honorValue, "RIGHT", 10, 0)
      frame.honorIcon:SetTexture("Interface\\PVPFrame\\PVP-HonorPoints-Icon")

      frame.conquestLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.conquestLabel:SetPoint("TOP", frame.top, "TOP", 76, -48)
      frame.conquestLabel:SetText((CONQUEST or "Conquest") .. ":")
      frame.conquestValue = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.conquestValue:SetPoint("LEFT", frame.conquestLabel, "RIGHT", 8, 0)
      frame.conquestIcon = frame:CreateTexture(nil, "OVERLAY")
      frame.conquestIcon:SetWidth(18)
      frame.conquestIcon:SetHeight(18)
      frame.conquestIcon:SetPoint("LEFT", frame.conquestValue, "RIGHT", 8, 0)
      frame.conquestIcon:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon")

      frame.today = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.today:SetPoint("TOP", frame.top, "TOP", -94, -82)
      frame.today:SetText(TODAY or "Today")
      frame.yesterday = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.yesterday:SetPoint("TOP", frame.top, "TOP", 34, -82)
      frame.yesterday:SetText(YESTERDAY or "Yesterday")
      frame.lifetime = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.lifetime:SetPoint("TOP", frame.top, "TOP", 130, -82)
      frame.lifetime:SetText(LIFETIME or "Lifetime")

      frame.killsLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.killsLabel:SetPoint("TOP", frame.top, "TOP", -124, -109)
      frame.killsLabel:SetText(KILLS or "Kills")
      frame.honorRowLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.honorRowLabel:SetPoint("TOP", frame.top, "TOP", -124, -131)
      frame.honorRowLabel:SetText(HONOR or "Honor")

      frame.todayKills = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.todayKills:SetPoint("TOP", frame.today, "BOTTOM", 0, -16)
      frame.yesterdayKills = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.yesterdayKills:SetPoint("TOP", frame.yesterday, "BOTTOM", 0, -16)
      frame.lifetimeKills = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.lifetimeKills:SetPoint("TOP", frame.lifetime, "BOTTOM", 0, -16)

      frame.todayHonor = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.todayHonor:SetPoint("TOP", frame.todayKills, "BOTTOM", 0, -12)
      frame.yesterdayHonor = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.yesterdayHonor:SetPoint("TOP", frame.yesterdayKills, "BOTTOM", 0, -12)
      frame.lifetimeHonor = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.lifetimeHonor:SetPoint("TOP", frame.lifetimeKills, "BOTTOM", 0, -12)

      frame.conquestSeason = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.conquestSeason:SetPoint("TOP", frame.top, "TOP", -34, -150)
      frame.conquestSeason:SetText((CONQUEST or "Conquest") .. " this season:")
      frame.conquestSeasonValue = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.conquestSeasonValue:SetPoint("LEFT", frame.conquestSeason, "RIGHT", 12, 0)
      frame.conquestSeasonIcon = frame:CreateTexture(nil, "OVERLAY")
      frame.conquestSeasonIcon:SetWidth(18)
      frame.conquestSeasonIcon:SetHeight(18)
      frame.conquestSeasonIcon:SetPoint("LEFT", frame.conquestSeasonValue, "RIGHT", 8, 0)
      frame.conquestSeasonIcon:SetTexture("Interface\\PVPFrame\\PVP-ArenaPoints-Icon")

      frame.teams = {}
      for i, label in pairs({ "2v2", "3v3", "5v5" }) do
        local flag = frame:CreateTexture(nil, "ARTWORK")
        flag:SetWidth(28)
        flag:SetHeight(28)
        flag:SetPoint("LEFT", frame, "TOPLEFT", 74, -222 - (i - 1) * 58)
        flag:SetTexture("Interface\\AddOns\\pfUI\\img\\pvp")
        flag:SetVertexColor(.85, .85, .85, .55)

        local team = CreateFrame("Frame", nil, frame)
        team:SetHeight(44)
        team:SetPoint("TOPLEFT", frame, "TOPLEFT", 104, -202 - (i - 1) * 58)
        team:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
        CreateBackdrop(team, nil, nil, .35)

        team.text = team:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        team.text:SetPoint("CENTER", team, "CENTER", 0, 0)
        team.text:SetText("(" .. label .. ")")
        team.text:SetTextColor(.45, .45, .45)
        team.flag = flag
        frame.teams[i] = team
      end

      return frame
    end

    local function RefreshPvPPanel()
      local frame = CreatePvPPanel()
      local stats = GetPvPStatValues()

      if frame.portrait then
        SetPortraitTexture(frame.portrait, "player")
      end

      SetText(frame.honorValue, stats.honor, 1, .82, 0)
      SetText(frame.conquestValue, stats.conquest, 1, .82, 0)
      SetText(frame.todayKills, stats.todayKills, 1, 1, 1)
      SetText(frame.yesterdayKills, stats.yesterdayKills, 1, 1, 1)
      SetText(frame.lifetimeKills, stats.lifetimeKills, 1, 1, 1)
      SetText(frame.todayHonor, stats.todayHonor, 1, 1, 1)
      SetText(frame.yesterdayHonor, stats.yesterdayHonor, 1, 1, 1)
      SetText(frame.lifetimeHonor, "-", .7, .7, .7)
      SetText(frame.conquestSeasonValue, stats.conquest .. " / 750", 1, .82, 0)

      frame:Show()
      return frame
    end

    local function GetMoneyValues()
      local money = GetMoney and GetMoney() or 0
      local gold = math.floor(money / 10000)
      local silver = math.floor((money % 10000) / 100)
      local copper = money % 100
      return gold, silver, copper
    end

    local function GetCurrencyListValue(pattern)
      if type(_G.GetCurrencyListSize) ~= "function" or type(_G.GetCurrencyListInfo) ~= "function" then
        return nil, nil, nil
      end

      for i = 1, GetCurrencyListSize() do
        local name, isHeader, _, _, _, count, icon = GetCurrencyListInfo(i)
        if name and not isHeader and string.find(string.lower(name), pattern, 1, true) then
          return count or 0, icon, name
        end
      end
    end

    local function GetWarsongMarkValue()
      local count, icon, name = GetCurrencyListValue("warsong")
      if count then return count, icon, name end

      local itemID = 20558
      local fallbackCount = GetItemCount and GetItemCount(itemID) or 0
      local fallbackIcon = GetItemIcon and GetItemIcon(itemID) or "Interface\\Icons\\INV_Misc_Rune_07"
      return fallbackCount or 0, fallbackIcon, "Warsong Gulch Mark of Honor"
    end

    local function CreatePfCurrencyRow(parent)
      local row = CreateFrame("Frame", nil, parent)
      CreateBackdrop(row, nil, nil, .24)

      row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      row.label:SetPoint("LEFT", row, "LEFT", 12, 0)
      row.label:SetWidth(300)
      row.label:SetJustifyH("LEFT")
      row.label:SetTextColor(1, 1, 1)

      row.icon = row:CreateTexture(nil, "OVERLAY")
      row.icon:SetWidth(22)
      row.icon:SetHeight(22)
      row.icon:SetPoint("RIGHT", row, "RIGHT", -12, 0)

      row.value = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      row.value:SetPoint("RIGHT", row.icon, "LEFT", -10, 0)
      row.value:SetWidth(70)
      row.value:SetJustifyH("RIGHT")
      row.value:SetTextColor(1, 1, 1)

      return row
    end

    local function LayoutCurrencyPanel(frame)
      frame:ClearAllPoints()
      frame:SetPoint("TOPLEFT", CharacterFrame.backdrop or CharacterFrame, "TOPLEFT", 0, 0)
      frame:SetPoint("BOTTOMRIGHT", CharacterFrame.backdrop or CharacterFrame, "BOTTOMRIGHT", 0, 0)
      if frame.backdrop then frame.backdrop:Hide() end

      local width = CharacterFrame.backdrop and CharacterFrame.backdrop.GetWidth and CharacterFrame.backdrop:GetWidth() or 650
      local height = CharacterFrame.backdrop and CharacterFrame.backdrop.GetHeight and CharacterFrame.backdrop:GetHeight() or 730
      local inner = width - 32

      frame.portraitHolder:ClearAllPoints()
      frame.portraitHolder:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, -24)
      frame.portraitHolder:SetWidth(82)
      frame.portraitHolder:SetHeight(82)

      frame.portrait:ClearAllPoints()
      frame.portrait:SetPoint("TOPLEFT", frame.portraitHolder, "TOPLEFT", 6, -6)
      frame.portrait:SetPoint("BOTTOMRIGHT", frame.portraitHolder, "BOTTOMRIGHT", -6, 6)

      frame.playerName:Hide()

      frame.playerInfo:ClearAllPoints()
      frame.playerInfo:SetPoint("TOPLEFT", frame.portraitHolder, "TOPRIGHT", 18, -22)

      frame.title:ClearAllPoints()
      frame.title:SetPoint("TOP", frame, "TOP", 0, -104)

      frame.section:ClearAllPoints()
      frame.section:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -150)
      frame.section:SetWidth(inner)
      frame.section:SetHeight(158)

      frame.sectionTitle:ClearAllPoints()
      frame.sectionTitle:SetPoint("TOP", frame.section, "TOP", 0, -20)

      frame.honorRow:ClearAllPoints()
      frame.honorRow:SetPoint("TOPLEFT", frame.section, "TOPLEFT", 12, -58)
      frame.honorRow:SetWidth(inner - 24)
      frame.honorRow:SetHeight(34)

      frame.warsongRow:ClearAllPoints()
      frame.warsongRow:SetPoint("TOPLEFT", frame.section, "TOPLEFT", 12, -98)
      frame.warsongRow:SetWidth(inner - 24)
      frame.warsongRow:SetHeight(34)

      frame.honorRow.label:SetWidth(inner - 170)
      frame.warsongRow.label:SetWidth(inner - 170)

      frame.money:ClearAllPoints()
      frame.money:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 18)
      frame.money:SetWidth(width - 204)
      frame.money:SetHeight(34)

      frame.close:ClearAllPoints()
      frame.close:SetPoint("LEFT", frame.money, "RIGHT", 12, 0)
      frame.close:SetWidth(160)
      frame.close:SetHeight(34)
    end

    local function CreateCurrencyPanel()
      if pfCharacterCurrencyFrame then pfCharacterCurrencyFrame:Hide() end
      if pfCharacterCurrencyMockFrame then pfCharacterCurrencyMockFrame:Hide() end
      if TokenFrame then TokenFrame:Hide() end

      local frame = pfCharacterCurrencyPanel
      if not frame then
        frame = CreateFrame("Frame", "pfCharacterCurrencyPanel", CharacterFrame)
        frame:Hide()

        frame.portraitHolder = CreateFrame("Frame", nil, frame)
        CreateBackdrop(frame.portraitHolder, nil, nil, .45)

        frame.portrait = frame:CreateTexture(nil, "ARTWORK")

        frame.playerName = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.playerName:SetTextColor(1, 1, 1)

        frame.playerInfo = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.playerInfo:SetTextColor(1, .82, 0)

        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.title:SetText(CURRENCY or TOKEN or "Currency")
        frame.title:SetTextColor(1, .82, 0)

        frame.section = CreateFrame("Frame", nil, frame)
        CreateBackdrop(frame.section, nil, nil, .26)

        frame.sectionTitle = frame.section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.sectionTitle:SetText("Player vs. Player")
        frame.sectionTitle:SetTextColor(1, .82, 0)

        frame.honorRow = CreatePfCurrencyRow(frame.section)
        frame.honorRow.label:SetText(HONOR_POINTS or "Honor Points")

        frame.warsongRow = CreatePfCurrencyRow(frame.section)

        frame.money = CreateFrame("Frame", nil, frame)
        CreateBackdrop(frame.money, nil, nil, .34)

        frame.moneyText = frame.money:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.moneyText:SetPoint("CENTER", frame.money, "CENTER", 0, 0)
        frame.moneyText:SetTextColor(1, 1, 1)

        frame.close = CreateFrame("Button", nil, frame)
        CreateBackdrop(frame.close, nil, nil, .65)
        frame.close.text = frame.close:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.close.text:SetPoint("CENTER", frame.close, "CENTER", 0, 0)
        frame.close.text:SetText(CLOSE or "Close")
        frame.close.text:SetTextColor(1, .82, 0)
        frame.close:SetScript("OnClick", function()
          HideUIPanel(CharacterFrame)
        end)
      end

      LayoutCurrencyPanel(frame)
      return frame
    end

    local function RefreshCurrencyPanel()
      local frame = CreateCurrencyPanel()
      local honor = SafeCall(GetHonorCurrency) or (UnitHonor and UnitHonor("player")) or 0
      local warsong, warsongIcon, warsongName = GetWarsongMarkValue()
      local gold, silver, copper = GetMoneyValues()
      local className = UnitClass("player") or ""
      local race = UnitRace("player") or ""

      SetPortraitTexture(frame.portrait, "player")
      frame.playerName:Hide()
      SetText(frame.playerInfo, (LEVEL or "Level") .. " " .. (UnitLevel("player") or "") .. " " .. race .. " " .. className, 1, .82, 0)
      SetText(frame.honorRow.value, honor, 1, 1, 1)
      frame.honorRow.icon:SetTexture("Interface\\PVPFrame\\PVP-HonorPoints-Icon")
      frame.warsongRow.label:SetText(warsongName or "Warsong Gulch Mark of Honor")
      SetText(frame.warsongRow.value, warsong, 1, 1, 1)
      frame.warsongRow.icon:SetTexture((warsongIcon and warsongIcon ~= 0) and warsongIcon or "Interface\\Icons\\INV_Misc_Rune_07")
      SetText(frame.moneyText, gold .. " |cffffd700g|r  " .. silver .. " |cffc7c7cfs|r  " .. copper .. " |cffeda55fc|r", 1, 1, 1)

      frame:Show()
      return frame
    end

    local function GetPvPContentFrame()
      if PVPFrame then
        return PVPFrame
      end

      return HonorFrame
    end

    local function GetPvPContentFrameName()
      local frame = GetPvPContentFrame()
      return frame and frame.GetName and frame:GetName()
    end

    local function HidePvPRootWindow()
      if PVPParentFrame then
        PVPParentFrame:Hide()
      end
    end

    local function SetupEmbeddedPvPFrame(frame)
      frame = frame or GetPvPContentFrame()
      if not frame then return nil end

      if not frame.pfOriginalParent then
        frame.pfOriginalParent = frame:GetParent() or UIParent
      end

      frame:SetParent(CharacterFrame)
      frame:ClearAllPoints()
      frame:SetScale(.82)
      frame:SetPoint("TOPLEFT", CharacterFrame.backdrop, "TOPLEFT", 18, -34)
      frame:SetFrameStrata(CharacterFrame:GetFrameStrata())
      frame:SetFrameLevel(CharacterFrame:GetFrameLevel() + 5)
      if not frame.backdrop then
        CreateBackdrop(frame, nil, nil, .55)
        frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
      end
      HidePvPRootWindow()

      return frame
    end

    local function EnsurePvPSubFrameLoaded()
      local click = PVPMicroButton and PVPMicroButton.GetScript and PVPMicroButton:GetScript("OnClick")
      if click then
        pcall(click, PVPMicroButton, "LeftButton")
      elseif PVPFrame then
        ShowUIPanel(PVPFrame)
      elseif HonorFrame then
        ShowUIPanel(HonorFrame)
      end

      return SetupEmbeddedPvPFrame(GetPvPContentFrame())
    end

    local function SetupEmbeddedCharacterSubFrame(frame)
      if not frame or not CharacterFrame or not CharacterFrame.backdrop then return nil end
      frame:ClearAllPoints()
      frame:SetParent(CharacterFrame)
      frame:SetPoint("TOPLEFT", CharacterFrame.backdrop, "TOPLEFT", 18, -34)
      frame:SetPoint("BOTTOMRIGHT", CharacterFrame.backdrop, "BOTTOMRIGHT", -18, 18)
      frame:SetFrameStrata(CharacterFrame:GetFrameStrata())
      frame:SetFrameLevel(CharacterFrame:GetFrameLevel() + 5)
      return frame
    end

    local function FindEpochCompanionFrame()
      if CompanionFrame then return CompanionFrame end
      if not CharacterFrame then return nil end

      local function IsCandidateFrame(frame)
        if not frame or frame == CharacterFrame then return nil end
        if frame.GetObjectType and frame:GetObjectType() == "Button" then return nil end

        local name = frame.GetName and frame:GetName()
        if name and string.find(name, "CharacterFrameTab", 1, true) then return nil end
        if frame.GetParent and frame:GetParent() ~= CharacterFrame then return nil end
        if frame.GetWidth and frame:GetWidth() < 250 then return nil end
        if frame.GetHeight and frame:GetHeight() < 250 then return nil end

        return true
      end

      local function HasCompanionText(frame)
        if not frame then return nil end
        local name = frame.GetName and frame:GetName()
        if name then
          local lname = string.lower(name)
          if string.find(lname, "companion", 1, true) or string.find(lname, "pet", 1, true) then
            return true
          end
        end

        for _, region in pairs({ frame:GetRegions() }) do
          if region and region.GetObjectType and region:GetObjectType() == "FontString" and region.GetText then
            local text = region:GetText()
            if text then
              local ltext = string.lower(text)
              if string.find(ltext, "companion", 1, true) or string.find(ltext, "pet", 1, true) then
                return true
              end
            end
          end
        end
      end

      for _, child in pairs({ CharacterFrame:GetChildren() }) do
        if child and child.IsShown and child:IsShown() and IsCandidateFrame(child) then
          if HasCompanionText(child) then return child end
          for _, subchild in pairs({ child:GetChildren() }) do
            if subchild and subchild.IsShown and subchild:IsShown() and HasCompanionText(subchild) then
              return child
            end
          end
        end
      end
    end

    local function ApplyCompanionFrameSkin(frame)
      local companion = frame or FindEpochCompanionFrame()
      if not companion then return end
      if companion.pfSkinningCompanion then return end
      companion.pfSkinningCompanion = true
      companion.pfEpochCompanionSkinApplied = true
      CharacterFrame.pfEpochCompanionSkinApplied = companion.pfEpochCompanionSkinApplied
      CharacterFrame.pfEpochCompanionFrameName = companion.GetName and companion:GetName() or "anonymous"

      local function StripChildTextures(frame)
        if not frame then return end
        StripTextures(frame)
        if frame.DisableDrawLayer then
          frame:DisableDrawLayer("BACKGROUND")
          frame:DisableDrawLayer("BORDER")
        end

        for _, child in pairs({ frame:GetChildren() }) do
          local objectType = child and child.GetObjectType and child:GetObjectType()
          local name = child and child.GetName and child:GetName() or ""
          if child and child ~= CompanionFrameCloseButton and objectType ~= "Button" and objectType ~= "CheckButton" and objectType ~= "PlayerModel" and objectType ~= "Model" and not string.find(name, "Model", 1, true) then
            StripTextures(child)
            if child.DisableDrawLayer then
              child:DisableDrawLayer("BACKGROUND")
              child:DisableDrawLayer("BORDER")
            end
          end
        end
      end

      local function EnsureCompanionSectionBackdrop(frame, alpha)
        if not frame then return end
        if not frame.backdrop then
          CreateBackdrop(frame, nil, nil, alpha or .55)
        end
        if frame.backdrop then
          frame.backdrop:ClearAllPoints()
          frame.backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
          frame.backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
          if frame.backdrop.SetFrameLevel and frame.GetFrameLevel then
            local level = frame:GetFrameLevel()
            frame.backdrop:SetFrameLevel(level > 0 and level - 1 or 0)
          end
        end
      end

      local function EnsureCompanionGoldFrame(frame)
        if not frame then return end
        if not frame.pfGoldBorder then
          frame.pfGoldBorder = CreateFrame("Frame", nil, frame)
          frame.pfGoldBorder:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
          })
          frame.pfGoldBorder:SetBackdropColor(0, 0, 0, .20)
          frame.pfGoldBorder:SetBackdropBorderColor(1, 1, 1, 1)
          if frame.pfGoldBorder.EnableMouse then frame.pfGoldBorder:EnableMouse(false) end
        end

        frame.pfGoldBorder:ClearAllPoints()
        frame.pfGoldBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -10, 10)
        frame.pfGoldBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 10, -10)
        if frame.pfGoldBorder.SetFrameLevel and frame.GetFrameLevel then
          frame.pfGoldBorder:SetFrameLevel(frame:GetFrameLevel() + 2)
        end
      end

      local function CenterCompanionModelText(frame)
        if not frame then return end
        for _, region in pairs({ frame:GetRegions() }) do
          if region and region.GetObjectType and region:GetObjectType() == "FontString" and region.GetText then
            local text = region:GetText()
            local ltext = text and string.lower(text)
            if text and text ~= "" and ltext ~= "summon" and ltext ~= "dismiss" and not string.find(ltext, "page", 1, true) then
              region:ClearAllPoints()
              region:SetPoint("CENTER", frame, "CENTER", 0, -54)
              if region.SetJustifyH then region:SetJustifyH("CENTER") end
              if region.SetWidth then region:SetWidth(360) end
            end
          end
        end
      end

      local function SkinCompanionActionButton(button, modelFrame)
        if not button then return end
        SkinButton(button)
        button:SetWidth(260)
        button:SetHeight(28)
        button:ClearAllPoints()
        button:SetPoint("CENTER", modelFrame or button:GetParent(), "CENTER", 0, -90)
        if button.SetFrameLevel and modelFrame and modelFrame.GetFrameLevel then
          button:SetFrameLevel(modelFrame:GetFrameLevel() + 8)
        end
        if button.EnableMouse then button:EnableMouse(true) end
        if button.RegisterForClicks then button:RegisterForClicks("LeftButtonUp") end
        button:Show()
        button.pfCompanionButtonSkinned = true
      end

      local function PositionCompanionModelControls(frame)
        if not frame then return end
        local rotateIndex = 0
        local placed = {}

        if frame.SetPosition then
          pcall(frame.SetPosition, frame, 0, 0, .28)
        end

        for _, child in pairs({ frame:GetChildren() }) do
          local name = child and child.GetName and child:GetName() or ""
          if child and child.ClearAllPoints and string.find(name, "Rotate", 1, true) then
            child:ClearAllPoints()
            child:SetPoint("TOPLEFT", frame, "TOPLEFT", 22 + rotateIndex * 42, -30)
            placed[child] = true
            rotateIndex = rotateIndex + 1
          end
        end

        for _, button in pairs({
          CompanionFrameCompanionModelFrameRotateLeftButton,
          CompanionFrameCompanionModelFrameRotateRightButton,
          CompanionFrameMountModelFrameRotateLeftButton,
          CompanionFrameMountModelFrameRotateRightButton,
          CompanionModelFrameRotateLeftButton,
          CompanionModelFrameRotateRightButton,
          MountModelFrameRotateLeftButton,
          MountModelFrameRotateRightButton,
        }) do
          if button and button.ClearAllPoints and not placed[button] then
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", frame, "TOPLEFT", 22 + rotateIndex * 42, -30)
            placed[button] = true
            rotateIndex = rotateIndex + 1
          end
        end
      end

      local function SkinCompanionChild(frame)
        if not frame then return end
        local name = frame.GetName and frame:GetName() or ""
        local objectType = frame.GetObjectType and frame:GetObjectType() or ""

        if string.find(name, "Model", 1, true) or objectType == "PlayerModel" or objectType == "Model" then
          EnableClickRotate(frame)
          frame:ClearAllPoints()
          frame:SetPoint("TOPLEFT", companion, "TOPLEFT", 18, -42)
          frame:SetPoint("TOPRIGHT", companion, "TOPRIGHT", -18, -42)
          frame:SetHeight(210)
          EnsureCompanionSectionBackdrop(frame, .25)
          EnsureCompanionGoldFrame(frame)
          PositionCompanionModelControls(frame)
          CenterCompanionModelText(frame)
        elseif string.find(name, "List", 1, true) or string.find(name, "ScrollFrame", 1, true) or objectType == "ScrollFrame" then
          StripChildTextures(frame)
          frame:ClearAllPoints()
          frame:SetPoint("TOPLEFT", companion, "TOPLEFT", 18, -268)
          frame:SetPoint("BOTTOMRIGHT", companion, "BOTTOMRIGHT", -18, 46)
          EnsureCompanionSectionBackdrop(frame, .55)
        end
      end

      local function SkinCompanionButtons(frame)
        if not frame then return end
        for _, child in pairs({ frame:GetChildren() }) do
          if child and child.GetObjectType and child:GetObjectType() == "Button" then
            local text = child.GetText and child:GetText()
            local ltext = text and string.lower(text)
            local name = child.GetName and child:GetName() or ""
            if (ltext and (ltext == "summon" or ltext == "dismiss")) or string.find(name, "SummonButton", 1, true) then
              SkinCompanionActionButton(child, child:GetParent())
            end
          end
          if child and child.GetChildren then
            SkinCompanionButtons(child)
          end
        end
      end

      local function AlignCompanionSlots(frame)
        if not frame then return end

        local function IsCompanionSlot(button)
          if not button then return nil end
          local objectType = button.GetObjectType and button:GetObjectType()
          if objectType ~= "Button" and objectType ~= "CheckButton" then return nil end

          local name = button.GetName and button:GetName() or ""
          local text = button.GetText and button:GetText()
          local width = button.GetWidth and button:GetWidth() or 0
          local height = button.GetHeight and button:GetHeight() or 0

          if text then return nil end
          if string.find(name, "Tab", 1, true) then return nil end
          if string.find(name, "Close", 1, true) then return nil end
          if string.find(name, "Next", 1, true) then return nil end
          if string.find(name, "Prev", 1, true) then return nil end
          if string.find(name, "Rotate", 1, true) then return nil end
          if width < 36 or width > 82 then return nil end
          if height < 36 or height > 82 then return nil end

          return true
        end

        for _, child in pairs({ frame:GetChildren() }) do
          if IsCompanionSlot(child) then
            local point, relativeTo, relativePoint, xOfs, yOfs = child:GetPoint(1)
            if point and not IsCompanionSlot(relativeTo) then
              if not child.pfCompanionSlotOriginalPoint then
                child.pfCompanionSlotOriginalPoint = { point, relativeTo, relativePoint, xOfs or 0, yOfs or 0 }
              end

              local original = child.pfCompanionSlotOriginalPoint
              child:ClearAllPoints()
              child:SetPoint(original[1], original[2], original[3], original[4] - 32, original[5])
            end
          end

          if child and child.GetChildren then
            AlignCompanionSlots(child)
          end
        end
      end

      StripTextures(companion)
      companion:DisableDrawLayer("BACKGROUND")
      companion:DisableDrawLayer("BORDER")
      companion:DisableDrawLayer("ARTWORK")
      StripChildTextures(companion)
      if CompanionFrameCloseButton then CompanionFrameCloseButton:Hide() end

      if CompanionFrameTitleText then
        CompanionFrameTitleText:ClearAllPoints()
        CompanionFrameTitleText:SetPoint("TOP", CharacterFrame.backdrop, "TOP", 0, -10)
        CompanionFrameTitleText:SetText(UnitName("player") or "")
        CompanionFrameTitleText:Show()
      end

      if CharacterNameText then
        CharacterNameText:SetText(UnitName("player") or "")
        CharacterNameText:Show()
      end

      for _, child in pairs({ companion:GetChildren() }) do
        SkinCompanionChild(child)
      end

      for _, name in pairs({
        "CompanionFrameCompanionModelFrame",
        "CompanionFrameMountModelFrame",
        "CompanionModelFrame",
        "MountModelFrame",
      }) do
        local model = _G[name]
        if model then
          SkinCompanionChild(model)
        end
      end

      local actionModel = CompanionFrameCompanionModelFrame or CompanionModelFrame or CompanionFrameMountModelFrame or MountModelFrame
      for _, name in pairs({
        "CompanionListFrame",
        "CompanionFrameCompanionList",
        "CompanionFrameCompanionListScrollFrame",
        "CompanionFrameMountList",
        "CompanionFrameMountListScrollFrame",
      }) do
        local list = _G[name]
        if list then
          SkinCompanionChild(list)
        end
      end

      for _, scrollbar in pairs({
        CompanionListScrollFrameScrollBar,
        CompanionFrameCompanionListScrollFrameScrollBar,
        CompanionFrameMountListScrollFrameScrollBar,
      }) do
        if scrollbar then SkinScrollbar(scrollbar) end
      end

      if CompanionFrameTab1 then SkinTab(CompanionFrameTab1) end
      if CompanionFrameTab2 then SkinTab(CompanionFrameTab2) end
      if CompanionFrameSummonButton then SkinCompanionActionButton(CompanionFrameSummonButton, actionModel) end
      if MountSummonButton then SkinCompanionActionButton(MountSummonButton, actionModel) end
      SkinCompanionButtons(companion)
      AlignCompanionSlots(companion)
      if CompanionPrevPageButton then SkinArrowButton(CompanionPrevPageButton, "left", 12) end
      if CompanionNextPageButton then SkinArrowButton(CompanionNextPageButton, "right", 12) end

      if not companion.pfCompanionShowHooked then
        HookScript(companion, "OnShow", function()
          this:SetScript("OnUpdate", function()
            this:SetScript("OnUpdate", nil)
            this.pfSkinningCompanion = nil
            if CharacterFrame and CharacterFrame.pfApplyCompanionFrameSkin then
              CharacterFrame.pfApplyCompanionFrameSkin()
            end
          end)
        end)
        companion.pfCompanionShowHooked = true
      end

      companion.pfSkinningCompanion = nil
      return companion
    end
    CharacterFrame.pfApplyCompanionFrameSkin = ApplyCompanionFrameSkin

    local companionSkinTicker = CreateFrame("Frame", nil, CharacterFrame)
    companionSkinTicker:Hide()
    companionSkinTicker:SetScript("OnUpdate", function()
      this:Hide()
      local companion = FindEpochCompanionFrame()
      if companion and companion:IsShown() then
        companion = ApplyCompanionFrameSkin(companion) or companion
        SetupEmbeddedCharacterSubFrame(companion)
      end
    end)

    local function QueueCompanionFrameSkin()
      companionSkinTicker:Show()
    end

    local function EnsureCompanionSubFrameLoaded()
      if CompanionFrame then
        if CompanionFrameTab1 and CompanionFrameTab1.GetScript and CompanionFrameTab1:GetScript("OnClick") then
          pcall(CompanionFrameTab1:GetScript("OnClick"), CompanionFrameTab1)
        end
        ApplyCompanionFrameSkin()
        return SetupEmbeddedCharacterSubFrame(CompanionFrame)
      end

      local click = CharacterMicroButton and CharacterMicroButton.GetScript and CharacterMicroButton:GetScript("OnClick")
      if click then pcall(click, CharacterMicroButton, "LeftButton") end
      if ToggleCompanionFrame then pcall(ToggleCompanionFrame, "CRITTER") end

      if CompanionFrame then
        if CompanionFrameTab1 and CompanionFrameTab1.GetScript and CompanionFrameTab1:GetScript("OnClick") then
          pcall(CompanionFrameTab1:GetScript("OnClick"), CompanionFrameTab1)
        end
        ApplyCompanionFrameSkin()
        return SetupEmbeddedCharacterSubFrame(CompanionFrame)
      end

      if PetPaperDollFrame then
        return SetupEmbeddedCharacterSubFrame(PetPaperDollFrame)
      end
    end

    local function EnsureTokenSubFrameLoaded()
      if TokenFrame then TokenFrame:Hide() end
      return RefreshCurrencyPanel()
    end

    local function EnforceSubFrame(frame, tab)
      if not CharacterFrame then return end
      CharacterFrame.pfChangingSubFrame = true
      if frame == "CompanionFrame" and not CompanionFrame then
        local companion = EnsureCompanionSubFrameLoaded()
        if companion and companion.GetName then
          frame = companion:GetName()
        elseif PetPaperDollFrame then
          frame = "PetPaperDollFrame"
        else
          CharacterFrame.pfChangingSubFrame = nil
          return
        end
      end

      if PaperDollFrame then PaperDollFrame:Hide() end
      if ReputationFrame then ReputationFrame:Hide() end
      if SkillFrame then SkillFrame:Hide() end
      if CompanionFrame then CompanionFrame:Hide() end
      if PVPParentFrame then PVPParentFrame:Hide() end
      if PVPFrame then PVPFrame:Hide() end
      if HonorFrame then HonorFrame:Hide() end
      if pfCharacterPvPFrame then pfCharacterPvPFrame:Hide() end
      if pfCharacterCurrencyFrame then pfCharacterCurrencyFrame:Hide() end
      if pfCharacterCurrencyMockFrame then pfCharacterCurrencyMockFrame:Hide() end
      if pfCharacterCurrencyPanel then pfCharacterCurrencyPanel:Hide() end
      if PetPaperDollFrame then PetPaperDollFrame:Hide() end
      if TokenFrame then TokenFrame:Hide() end
      if BCSFrame then BCSFrame:Hide() end

      if frame and _G[frame] then
        _G[frame]:Show()
      end
      if frame == "pfCharacterCurrencyPanel" then
        RefreshCurrencyPanel()
      end

      CharacterFrame.selectedTab = tab
      CharacterFrame.currentSubFrame = frame

      if PanelTemplates_SetTab then
        PanelTemplates_SetTab(CharacterFrame, tab)
      end

      CharacterFrame.pfChangingSubFrame = nil
    end

    local function QueueSubFrame(frame, tab)
      if not CharacterFrame then return end
      CharacterFrame.pfPendingSubFrame = frame
      CharacterFrame.pfPendingTab = tab
      CharacterFrame:SetScript("OnUpdate", function()
        this:SetScript("OnUpdate", nil)
        EnforceSubFrame(this.pfPendingSubFrame, this.pfPendingTab)

        if this.pfPendingSubFrame == "PaperDollFrame" then
          RefreshBCS()
        elseif this.pfPendingSubFrame == "ReputationFrame" and type(_G.ReputationFrame_Update) == "function" then
          ReputationFrame_Update()
        elseif this.pfPendingSubFrame == "SkillFrame" and type(_G.SkillFrame_Update) == "function" then
          SkillFrame_Update()
        elseif this.pfPendingSubFrame == "CompanionFrame" or this.pfPendingSubFrame == "PetPaperDollFrame" then
          local companion = EnsureCompanionSubFrameLoaded()
          if companion then
            companion:Show()
            if companion.GetName then
              CharacterFrame.currentSubFrame = companion:GetName()
            end
          end
        elseif this.pfPendingSubFrame == "TokenFrame" then
          local token = EnsureTokenSubFrameLoaded()
          if token then token:Show() end
        elseif this.pfPendingSubFrame == "pfCharacterCurrencyPanel" then
          RefreshCurrencyPanel()
        elseif this.pfPendingSubFrame == "pfCharacterPvPFrame" then
          RefreshPvPPanel()
        elseif (this.pfPendingSubFrame == "PVPParentFrame" or this.pfPendingSubFrame == "PVPFrame" or this.pfPendingSubFrame == "HonorFrame") and type(_G.HonorFrame_Update) == "function" then
          local activePvPFrame = EnsurePvPSubFrameLoaded()
          if activePvPFrame and activePvPFrame.GetName and activePvPFrame:GetName() ~= this.pfPendingSubFrame then
            EnforceSubFrame(activePvPFrame:GetName(), this.pfPendingTab)
          end
          HonorFrame_Update()
          this:SetScript("OnUpdate", function()
            this:SetScript("OnUpdate", nil)
            local finalPvPFrame = GetPvPContentFrame()
            if finalPvPFrame then
              SetupEmbeddedPvPFrame(finalPvPFrame)
              finalPvPFrame:Show()
            end
          end)
        end
      end)
    end

    local function HideCharacterSubFrames()
      if PaperDollFrame then PaperDollFrame:Hide() end
      if ReputationFrame then ReputationFrame:Hide() end
      if SkillFrame then SkillFrame:Hide() end
      if CompanionFrame then CompanionFrame:Hide() end
      if PVPParentFrame then PVPParentFrame:Hide() end
      if PVPFrame then PVPFrame:Hide() end
      if HonorFrame then HonorFrame:Hide() end
      if pfCharacterPvPFrame then pfCharacterPvPFrame:Hide() end
      if pfCharacterCurrencyFrame then pfCharacterCurrencyFrame:Hide() end
      if pfCharacterCurrencyMockFrame then pfCharacterCurrencyMockFrame:Hide() end
      if pfCharacterCurrencyPanel then pfCharacterCurrencyPanel:Hide() end
      if PetPaperDollFrame then PetPaperDollFrame:Hide() end
      if TokenFrame then TokenFrame:Hide() end
      if BCSFrame then BCSFrame:Hide() end
    end

    local function ShowCharacterSubFrame(tab, frame)
      return function(self)
        QueueSubFrame(frame, tab)
      end
    end

    local function GetTabLabel(tab)
      if not tab then return nil end
      if tab.GetText then
        local text = tab:GetText()
        if text and text ~= "" then return text end
      end
      local fontString = _G[tab:GetName() .. "Text"]
      if fontString and fontString.GetText then
        local text = fontString:GetText()
        if text and text ~= "" then return text end
      end
    end

    local function NormalizeTabLabel(label)
      if not label then return nil end
      return string.lower(tostring(label))
    end

    local function MatchLabel(label, globalName, fallback)
      local expected = _G[globalName]
      if type(expected) == "string" and label == string.lower(expected) then
        return true
      end
      if fallback and (label == fallback or string.find(label, fallback, 1, true)) then
        return true
      end
      return false
    end

    local function GetLastCharacterTabIndex()
      local last = 1
      for i = 1, 12 do
        if _G["CharacterFrameTab" .. i] then
          last = i
        else
          break
        end
      end
      return last
    end

    local function GetStableTabWidth(tab)
      local width = 80
      local text = tab and tab.GetName and _G[tab:GetName() .. "Text"]
      if text and text.GetStringWidth then
        width = math.floor(text:GetStringWidth() + 32)
      end
      if width < 48 then width = 48 end
      if width > 78 then width = 78 end
      return width
    end

    local function LayoutVisibleTabs()
      local lastShown
      local shown = 0
      for i = 1, GetLastCharacterTabIndex() do
        local tab = _G["CharacterFrameTab" .. i]
        if tab and tab:IsShown() then shown = shown + 1 end
      end

      local maxTabWidth
      if shown > 0 and CharacterFrame.backdrop and CharacterFrame.backdrop.GetWidth then
        local spacing = border*2 + 1
        maxTabWidth = math.floor((CharacterFrame.backdrop:GetWidth() - bpad*2 - spacing*(shown - 1) - 2) / shown)
        if maxTabWidth > 78 then maxTabWidth = 78 end
        if maxTabWidth < 42 then maxTabWidth = 42 end
      end

      for i = 1, GetLastCharacterTabIndex() do
        local tab = _G["CharacterFrameTab" .. i]
        if tab and tab:IsShown() then
          local tabWidth = maxTabWidth or GetStableTabWidth(tab)
          if tab.SetWidth then tab:SetWidth(tabWidth) end
          if _G[tab:GetName() .. "Middle"] then _G[tab:GetName() .. "Middle"]:SetWidth(tabWidth - 20) end
          tab:ClearAllPoints()
          if not lastShown then
            tab:SetPoint("TOPLEFT", CharacterFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
          else
            tab:SetPoint("LEFT", lastShown, "RIGHT", border*2 + 1, 0)
          end
          lastShown = tab
        end
      end
    end
    CharacterFrame.pfLayoutVisibleTabs = LayoutVisibleTabs

    local function EnsureCurrencyCharacterTab()
      local frame = "pfCharacterCurrencyPanel"
      local currencyText = CURRENCY or TOKEN or "Currency"
      local tabIndex = nil

      for i = 1, GetLastCharacterTabIndex() do
        local existing = _G["CharacterFrameTab" .. i]
        local label = NormalizeTabLabel(GetTabLabel(existing))
        if label and (MatchLabel(label, "TOKEN", "currency") or MatchLabel(label, "CURRENCY", "currencies")) then
          tabIndex = i
          break
        end
      end

      if not tabIndex then
        local pvpIndex
        for i = 1, GetLastCharacterTabIndex() do
          local existing = _G["CharacterFrameTab" .. i]
          local label = NormalizeTabLabel(GetTabLabel(existing))
          if label and (MatchLabel(label, "PVP", "pvp") or MatchLabel(label, "HONOR", "honor")) then
            pvpIndex = i
            break
          end
        end

        tabIndex = pvpIndex or (GetLastCharacterTabIndex() + 1)
        if pvpIndex then
          local last = GetLastCharacterTabIndex()
          for i = last, pvpIndex, -1 do
            local oldTab = _G["CharacterFrameTab" .. i]
            local newTab = _G["CharacterFrameTab" .. (i + 1)]
            if oldTab and not newTab then
              newTab = CreateFrame("Button", "CharacterFrameTab" .. (i + 1), CharacterFrame, "CharacterFrameTabButtonTemplate")
              newTab:SetID(i + 1)
              SkinTab(newTab)
            end
            if oldTab and newTab then
              newTab:SetText(GetTabLabel(oldTab) or "")
              newTab:SetID(i + 1)
              newTab.pfRouteHooked = nil
              newTab:Show()
            end
          end
        end
      end

      local tab = _G["CharacterFrameTab" .. tabIndex]
      if not tab and _G["CharacterFrameTab" .. (tabIndex - 1)] then
        tab = CreateFrame("Button", "CharacterFrameTab" .. tabIndex, CharacterFrame, "CharacterFrameTabButtonTemplate")
        tab:SetID(tabIndex)
        SkinTab(tab)
      end

      if not tab then return end

      if PanelTemplates_SetNumTabs then
        PanelTemplates_SetNumTabs(CharacterFrame, GetLastCharacterTabIndex())
      end

      PanelTemplates_DeselectTab(tab)
      tab:SetText(currencyText)
      if not tab.pfCurrencyTab then
        tab.pfRouteHooked = nil
      end
      tab.pfCurrencyTab = true
      tab:Show()

      if not tab.pfRouteHooked then
        tab:SetScript("OnClick", function()
          ShowCharacterSubFrame(tab:GetID(), frame)()
        end)
        tab:SetScript("OnMouseUp", function()
          ShowCharacterSubFrame(tab:GetID(), frame)()
        end)
        tab.pfRouteHooked = true
      end
    end

    local function EnsurePvPCharacterTab()
      local frame = "pfCharacterPvPFrame"
      if not frame then return end

      local tabIndex = nil
      for i = 1, GetLastCharacterTabIndex() do
        local existing = _G["CharacterFrameTab" .. i]
        local label = NormalizeTabLabel(GetTabLabel(existing))
        if label and (MatchLabel(label, "PVP", "pvp") or MatchLabel(label, "HONOR", "honor")) then
          tabIndex = i
          break
        end
      end

      if not tabIndex then
        tabIndex = GetLastCharacterTabIndex() + 1
      end

      local tab = _G["CharacterFrameTab" .. tabIndex]
      if not tab and _G["CharacterFrameTab" .. (tabIndex - 1)] then
        tab = CreateFrame("Button", "CharacterFrameTab" .. tabIndex, CharacterFrame, "CharacterFrameTabButtonTemplate")
        tab:SetID(tabIndex)
        SkinTab(tab)
      end

      if not tab then return end

      if PanelTemplates_SetNumTabs then
        PanelTemplates_SetNumTabs(CharacterFrame, tabIndex)
      end

      PanelTemplates_DeselectTab(tab)
      tab:SetText(PVP)
      tab:Show()

      if not tab.pfRouteHooked then
        HookScript(tab, "OnClick", function()
          ShowCharacterSubFrame(tab:GetID(), frame)()
        end)
        HookScript(tab, "OnMouseUp", function()
          ShowCharacterSubFrame(tab:GetID(), frame)()
        end)
        tab.pfRouteHooked = true
      end
    end

    local function ApplyCharacterTabRouting()
      CharacterFrame.pfExtendedTabsActive = true
      EnsureCurrencyCharacterTab()
      EnsurePvPCharacterTab()

      for i = 1, GetLastCharacterTabIndex() do
        local tab = _G["CharacterFrameTab" .. i]
        local label = NormalizeTabLabel(GetTabLabel(tab))

        if tab and label then
          if not tab.pfCompanionSkinHooked then
            HookScript(tab, "OnClick", QueueCompanionFrameSkin)
            HookScript(tab, "OnMouseUp", QueueCompanionFrameSkin)
            tab.pfCompanionSkinHooked = true
          end

          local frame
          if MatchLabel(label, "CHARACTER_BUTTON", "character") then
            frame = "PaperDollFrame"
          elseif MatchLabel(label, "COMPANIONS", "pets") then
            frame = "CompanionFrame"
          elseif MatchLabel(label, "REPUTATION", "reputation") then
            frame = "ReputationFrame"
          elseif MatchLabel(label, "SKILLS", "skills") then
            frame = "SkillFrame"
          elseif MatchLabel(label, "TOKEN", "currency") or MatchLabel(label, "CURRENCY", "currencies") then
            frame = "pfCharacterCurrencyPanel"
          elseif MatchLabel(label, "PVP", "pvp") then
            frame = "pfCharacterPvPFrame"
          elseif MatchLabel(label, "HONOR", "honor") then
            frame = "pfCharacterPvPFrame"
          end

          if frame and not tab.pfRouteHooked then
            HookScript(tab, "OnClick", function()
              ShowCharacterSubFrame(i, frame)()
            end)
            HookScript(tab, "OnMouseUp", function()
              ShowCharacterSubFrame(i, frame)()
            end)
            tab.pfRouteHooked = true
          end

        end
      end

      LayoutVisibleTabs()
    end

    local function ShowCharacterPvPTab()
      if not CharacterFrame then return end

      ApplyCharacterTabRouting()

      local tabIndex = nil
      for i = 1, GetLastCharacterTabIndex() do
        local tab = _G["CharacterFrameTab" .. i]
        local label = NormalizeTabLabel(GetTabLabel(tab))
        if label and (MatchLabel(label, "PVP", "pvp") or MatchLabel(label, "HONOR", "honor")) then
          tabIndex = i
          break
        end
      end

      tabIndex = tabIndex or GetLastCharacterTabIndex()

      if not CharacterFrame:IsShown() then
        ShowUIPanel(CharacterFrame)
      end

      QueueSubFrame("pfCharacterPvPFrame", tabIndex)
      RefreshPvPPanel()

      if PVPParentFrame then PVPParentFrame:Hide() end
      if PVPFrame then PVPFrame:Hide() end
      if HonorFrame then HonorFrame:Hide() end
    end

    local function InstallPvPKeybindingOverride()
      _G.pfUI_ShowCharacterPvPTab = ShowCharacterPvPTab
      _G.TogglePVPFrame = ShowCharacterPvPTab
      _G.TogglePVP = ShowCharacterPvPTab
      _G.ToggleHonorFrame = ShowCharacterPvPTab
      _G.PVPFrame_Toggle = ShowCharacterPvPTab
      _G.HonorFrame_Toggle = ShowCharacterPvPTab
    end

    InstallPvPKeybindingOverride()
    HookAddonOrVariable("Blizzard_PVPUI", InstallPvPKeybindingOverride)

    HookScript(CharacterFrame, "OnShow", function()
      ApplyCharacterTabRouting()
      QueueCompanionFrameSkin()

      if PaperDollFrame and PaperDollFrame:IsShown() then
        RefreshBCS()
      elseif CharacterFrame.selectedTab == 1 or CharacterFrame.currentSubFrame == "PaperDollFrame" then
        QueueSubFrame("PaperDollFrame", 1)
      end
    end)

    HookScript(CharacterFrame, "OnHide", function()
      if TokenFrame then TokenFrame:Hide() end
      for _, frame in pairs({ PVPParentFrame, PVPFrame, HonorFrame }) do
        if frame and frame.pfOriginalParent then
          frame:Hide()
          frame:ClearAllPoints()
          frame:SetParent(frame.pfOriginalParent)
          frame:SetScale(1)
          if PVPTeam1 then PVPTeam1:SetScale(1) end
          if PVPTeam2 then PVPTeam2:SetScale(1) end
          if PVPTeam3 then PVPTeam3:SetScale(1) end
        end
      end
    end)
  end

  do -- Character Tab
    local slots = {
      "HeadSlot",
      "NeckSlot",
      "ShoulderSlot",
      "BackSlot",
      "ChestSlot",
      "ShirtSlot",
      "TabardSlot",
      "WristSlot",
      "HandsSlot",
      "WaistSlot",
      "LegsSlot",
      "FeetSlot",
      "Finger0Slot",
      "Finger1Slot",
      "Trinket0Slot",
      "Trinket1Slot",
      "MainHandSlot",
      "SecondaryHandSlot",
      "RangedSlot",
      "AmmoSlot"
    }

    local function RefreshPetPosition()
      if CharacterFrame and CharacterFrame.pfExtendedTabsActive then
        if CharacterFrame.pfLayoutVisibleTabs then
          CharacterFrame.pfLayoutVisibleTabs()
        end
        return
      end
      if not CharacterFrameTab3 then return end
      CharacterFrameTab3:ClearAllPoints()
      CharacterFrameTab3:SetPoint("LEFT", HasPetUI() and CharacterFrameTab2 or CharacterFrameTab1, "RIGHT", border*2 + 1, 0)
    end

    local function RefreshCharacterSlots()
      for i, slot in pairs(slots) do
        local slotId, _, _ = GetInventorySlotInfo(slot)
        local quality = GetInventoryItemQuality("player", slotId)
        slot = _G["Character"..slot]

        if slot and slot.backdrop then
          if quality and quality > 0 then
            slot.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
            else
            slot.backdrop:SetBackdropBorderColor(pfUI.cache.er, pfUI.cache.eg, pfUI.cache.eb, pfUI.cache.ea)
          end

          if ShaguScore and GetInventoryItemLink("player", slotId) and slot.scoreText then
            local _, _, itemID = string.find(GetInventoryItemLink("player", slotId), "item:(%d+):%d+:%d+:%d+")
            local itemLevel = ShaguScore.Database[tonumber(itemID)] or 0
            local _, _, itemRarity, _, _, _, _, _, itemSlot, _ = GetItemInfo(itemID)
            local r,g,b = GetItemQualityColor((itemRarity or 1))
            local score = ShaguScore:Calculate(itemSlot, itemRarity, itemLevel)
            if score and score > 0  then
              if quality and quality > 0 then
                slot.scoreText:SetText(score)
                slot.scoreText:SetTextColor(r, g, b, 1)
                else
                slot.scoreText:SetText("")
              end
              else
              if slot.scoreText then slot.scoreText:SetText("") end
            end
            else
            if slot.scoreText then slot.scoreText:SetText("") end
          end
        end
      end
    end

    HookScript(CharacterFrame, "OnShow", function()
      RefreshCharacterSlots()
      RefreshPetPosition()

      if not this.hooked then
        if type(_G.PaperDollItemSlotButton_Update) == "function" then
          hooksecurefunc("PaperDollItemSlotButton_Update", RefreshCharacterSlots)
        end
        if type(_G.PetTab_Update) == "function" then
          hooksecurefunc("PetTab_Update", RefreshPetPosition)
        elseif _G.PetPaperDollFrame then
          HookScript(PetPaperDollFrame, "OnShow", RefreshPetPosition)
        end
        this.hooked = true
      end
    end)

    if PaperDollFrame then StripTextures(PaperDollFrame) end
    if CharacterAttributesFrame then StripTextures(CharacterAttributesFrame) end
    if CharacterResistanceFrame then StripTextures(CharacterResistanceFrame) end
    if CharacterModelFrame then
      StripTextures(CharacterModelFrame)
      EnableClickRotate(CharacterModelFrame)
    end
    if CharacterModelFrameRotateLeftButton then CharacterModelFrameRotateLeftButton:Hide() end
    if CharacterModelFrameRotateRightButton then CharacterModelFrameRotateRightButton:Hide() end

    for i,c in pairs(magicResTextureCords) do
      local magicResFrame = _G["MagicResFrame"..i]
      if magicResFrame then
        magicResFrame:SetWidth(26)
        magicResFrame:SetHeight(26)
        CreateBackdrop(magicResFrame)
        SetAllPointsOffset(magicResFrame.backdrop, magicResFrame, 2)
        local icon = GetNoNameObject(magicResFrame, "Texture", "BACKGROUND", "ResistanceIcons")
        if icon then
          SetAllPointsOffset(icon, magicResFrame, 3)
          icon:SetTexCoord(c[1], c[2], c[3], c[4])
        end
      end
    end

    for i, slot in pairs(slots) do
      local frame = _G["Character"..slot]
      if frame then
        StripTextures(frame)
        CreateBackdrop(frame)
        SetAllPointsOffset(frame.backdrop, frame, 0)

        HandleIcon(frame.backdrop, _G["Character"..slot.."IconTexture"])

        if not frame.scoreText then
          frame.scoreText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
          frame.scoreText:SetFont(pfUI.font_default, 12, "OUTLINE")
          frame.scoreText:SetPoint("TOPRIGHT", 0, 0)
        end
      end
    end
  end

  do -- Pet Tab
    if PetPaperDollFrame then
      StripTextures(PetPaperDollFrame)

      if PetNameText then
        PetNameText:ClearAllPoints()
        PetNameText:SetPoint("TOP", CharacterFrame.backdrop, "TOP", 0, -10)
      end

      if PetModelFrame then
        EnableClickRotate(PetModelFrame)
      end
      if PetModelFrameRotateLeftButton then PetModelFrameRotateLeftButton:Hide() end
      if PetModelFrameRotateRightButton then PetModelFrameRotateRightButton:Hide() end

      if PetPaperDollCloseButton then PetPaperDollCloseButton:Hide() end

      if PetAttributesFrame then StripTextures(PetAttributesFrame) end
      if PetPaperDollFrameExpBar then
        StripTextures(PetPaperDollFrameExpBar)
        CreateBackdrop(PetPaperDollFrameExpBar, nil, true)
        PetPaperDollFrameExpBar:SetStatusBarTexture(pfUI.media["img:bar"])
        PetPaperDollFrameExpBar:ClearAllPoints()
        if PetModelFrame then
          PetPaperDollFrameExpBar:SetPoint("BOTTOM", PetModelFrame, "BOTTOM", 0, -120)
        end
      end

      if PetTrainingPointLabel and PetArmorFrame then
        PetTrainingPointLabel:ClearAllPoints()
        PetTrainingPointLabel:SetPoint("TOPLEFT", PetArmorFrame, "BOTTOMLEFT", 0, -16)
      end

      if PetTrainingPointText and PetArmorFrame then
        PetTrainingPointText:ClearAllPoints()
        PetTrainingPointText:SetPoint("TOPRIGHT", PetArmorFrame, "BOTTOMRIGHT", 0, -16)
      end

      if PetPaperDollPetInfo and PetModelFrame then
        PetPaperDollPetInfo:ClearAllPoints()
        PetPaperDollPetInfo:SetPoint("TOPLEFT", PetModelFrame, "TOPLEFT")
        PetPaperDollPetInfo:SetFrameLevel(255)
      end

      if PetResistanceFrame and PetModelFrame then
        PetResistanceFrame:ClearAllPoints()
        PetResistanceFrame:SetPoint("TOPRIGHT", PetModelFrame, "TOPRIGHT")
      end

      for i,c in pairs(magicResTextureCords) do
        local magicResFrame = _G["PetMagicResFrame"..i]
        if magicResFrame then
          magicResFrame:SetWidth(26)
          magicResFrame:SetHeight(26)
          CreateBackdrop(magicResFrame)
          SetAllPointsOffset(magicResFrame.backdrop, magicResFrame, 2)
          local icon = GetNoNameObject(magicResFrame, "Texture", "BACKGROUND", "ResistanceIcons")
          if icon then
            SetAllPointsOffset(icon, magicResFrame, 3)
            icon:SetTexCoord(c[1], c[2], c[3], c[4])
          end
        end
      end
    end
  end

  do -- Companion/Pets Tab
    if CharacterFrame.pfApplyCompanionFrameSkin then
      CharacterFrame.pfApplyCompanionFrameSkin()
    end
  end

  do -- Currency/Token Tab
    if TokenFrame then TokenFrame:Hide() end
  end

  do -- Reputation Tab
    if ReputationFrame then
      StripTextures(ReputationFrame)
    end

    for i = 1, NUM_FACTIONS_DISPLAYED do
      local row = _G["ReputationBar" .. i]
      local bar = _G["ReputationBar" .. i .. "ReputationBar"] or row

      if row then
        StripTextures(row)
        row:SetHeight(22)
        if not row.backdrop then
          CreateBackdrop(row)
        end
      end

      if bar and bar.SetStatusBarTexture then
        StripTextures(bar)
        bar:SetHeight(11)
        bar:SetStatusBarTexture(pfUI.media["img:bar"])
        if row and row.backdrop then
          bar:ClearAllPoints()
          bar:SetPoint("LEFT", row.backdrop, "LEFT", 2, 0)
          bar:SetPoint("RIGHT", row.backdrop, "RIGHT", -2, 0)
          bar:SetHeight(11)
        elseif bar.backdrop then
          bar.backdrop:SetFrameLevel(bar:GetFrameLevel() - 1)
        elseif not bar.backdrop then
          CreateBackdrop(bar)
        end
      end

      local name = _G["ReputationBar"..i.."FactionName"]
      local standing = _G["ReputationBar"..i.."FactionStanding"]
      if name then name:SetDrawLayer("OVERLAY") end
      if standing then standing:SetDrawLayer("OVERLAY") end

      local war = _G["ReputationBar"..i.."AtWarCheck"]
      if war then
        StripTextures(war)
        war:SetWidth(13)
        war:SetHeight(13)
        war:ClearAllPoints()
        if row and row.backdrop then
          war:SetPoint("LEFT", row.backdrop, "RIGHT", 6, 0)
        elseif bar and bar.backdrop then
          war:SetPoint("LEFT", bar.backdrop, "RIGHT", 6, 0)
        end
        if not war.icon then
          war.icon = war:CreateTexture(nil, "OVERLAY")
          war.icon:SetPoint("LEFT", -3, -8)
          war.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-SwordCheck")
        end
      end

      local header = _G["ReputationHeader"..i]
      if header then
        StripTextures(header)
        SkinCollapseButton(header)
      end
    end

    if ReputationListScrollFrame then
      StripTextures(ReputationListScrollFrame)
    end
    if ReputationListScrollFrameScrollBar then
      SkinScrollbar(ReputationListScrollFrameScrollBar)
    end

    if ReputationDetailFrame then
      StripTextures(ReputationDetailFrame)
      CreateBackdrop(ReputationDetailFrame, nil, nil, .75)
      if ReputationDetailCloseButton then
        SkinCloseButton(ReputationDetailCloseButton, ReputationDetailFrame.backdrop, -6, -6)
      end

      ReputationDetailFrame:ClearAllPoints()
      ReputationDetailFrame:SetPoint("TOPLEFT", CharacterFrame.backdrop, "TOPRIGHT", 2*border, 0)
    end

    if ReputationDetailAtWarCheckBox then SkinCheckbox(ReputationDetailAtWarCheckBox) end
    if ReputationDetailInactiveCheckBox then SkinCheckbox(ReputationDetailInactiveCheckBox) end
    if ReputationDetailMainScreenCheckBox then SkinCheckbox(ReputationDetailMainScreenCheckBox) end
  end

  do -- Skills Tab
    StripTextures(SkillFrame)

    SkillFrameExpandButtonFrame:DisableDrawLayer("BACKGROUND")

    SkillFrameCancelButton:Hide()

    StripTextures(SkillFrameCollapseAllButton)
    SkinCollapseButton(SkillFrameCollapseAllButton, true)
    SkillFrameCollapseAllButton:ClearAllPoints()
    SkillFrameCollapseAllButton:SetPoint("BOTTOMLEFT", SkillTypeLabel1, "TOPLEFT", 2, 2)

    for i = 1, SKILLS_TO_DISPLAY do
      local header = _G["SkillTypeLabel"..i]
      StripTextures(header)
      SkinCollapseButton(header)

      StripTextures(_G["SkillRankFrame"..i.."Border"])

      local frame = _G["SkillRankFrame" .. i]
      local lastframe = _G["SkillRankFrame" .. i-1]
      StripTextures(frame)
      CreateBackdrop(frame)

      if lastframe then
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", lastframe, "BOTTOMLEFT", 0, -6)
      end
      frame:SetStatusBarTexture(pfUI.media["img:bar"])
      frame:SetHeight(12)
    end

    StripTextures(SkillListScrollFrame)
    SkinScrollbar(SkillListScrollFrameScrollBar)

    StripTextures(SkillDetailScrollFrame)
    SkillDetailScrollFrameScrollBar:Hide()
    SkillDetailScrollChildFrame:Hide()

    SkillDetailCostText:SetParent(SkillDetailScrollFrame)
    SkillDetailDescriptionText:SetParent(SkillDetailScrollFrame)

    StripTextures(SkillDetailStatusBar)
    CreateBackdrop(SkillDetailStatusBar)
    SkillDetailStatusBar:SetStatusBarTexture(pfUI.media["img:bar"])
    SkillDetailStatusBar:SetParent(SkillDetailScrollFrame)

    StripTextures(SkillDetailStatusBarUnlearnButton)
    SkillDetailStatusBarUnlearnButton:SetWidth(20)
    SkillDetailStatusBarUnlearnButton:SetHeight(20)
    SkillDetailStatusBarUnlearnButton:SetHitRectInsets(0,0,0,0)
    SkillDetailStatusBarUnlearnButton:ClearAllPoints()
    SkillDetailStatusBarUnlearnButton:SetPoint("LEFT", SkillDetailStatusBar, "RIGHT", 6, 0)
    SkillDetailStatusBarUnlearnButton:SetPushedTexture(nil)
    SkillDetailStatusBarUnlearnButton:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
  end

  do -- PvP Tab
    local pvpFrame = PVPFrame or HonorFrame
    if pvpFrame then
      for _, closeName in pairs({
        "PVPFrameCloseButton",
        "HonorFrameCloseButton",
        "PVPParentFrameCloseButton"
      }) do
        local closeButton = _G[closeName]
        if closeButton then
          closeButton:Hide()
        end
      end

      if pvpFrame.pfQueueButton then pvpFrame.pfQueueButton:Hide() end
      if pvpFrame.pfArenaButton then pvpFrame.pfArenaButton:Hide() end
    end
  end
end)
