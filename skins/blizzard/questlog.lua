pfUI:RegisterSkin("Quest Log", "vanilla:tbc:wotlk", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  _G.QUESTS_DISPLAYED = 23
  _G.MAX_WATCHABLE_QUESTS = 20 -- TODO

  do -- quest log frame
    -- Compatibility
    local QUEST_COUNT
    if QuestLogCount then -- tbc
      QUEST_COUNT = QuestLogCount

      StripTextures(QUEST_COUNT)
      QUEST_COUNT:ClearAllPoints()
      if type(_G.QuestLogUpdateQuestCount) == "function" then
        hooksecurefunc("QuestLogUpdateQuestCount", function(numQuests)
          QUEST_COUNT:ClearAllPoints()
          QUEST_COUNT:SetPoint("BOTTOMRIGHT", QuestLogFrame, "TOPRIGHT", 0, -50)
        end)
      else
        QUEST_COUNT:SetPoint("BOTTOMRIGHT", QuestLogFrame, "TOPRIGHT", 0, -50)
      end
    else -- vanilla
      QUEST_COUNT = QuestLogQuestCount

      QUEST_COUNT:ClearAllPoints()
      QUEST_COUNT:SetPoint("TOPRIGHT", -10, -30)
    end

    if type(_G.QuestLog_OnShow) == "function" then
      hooksecurefunc("QuestLog_OnShow", function()
        QuestLogFrame:ClearAllPoints()
        QuestLogFrame:SetPoint("TOPLEFT", 10, -104)
      end, 1)
    end

    QuestLogFrame:SetWidth(676)
    QuestLogFrame:SetHeight(440)
    QuestLogFrame:DisableDrawLayer("BACKGROUND")

    StripTextures(QuestLogFrame, true)
    CreateBackdrop(QuestLogFrame, nil, nil, .75)
    CreateBackdropShadow(QuestLogFrame)

    EnableMovable(QuestLogFrame)

    QuestLogTitleText:ClearAllPoints()
    QuestLogTitleText:SetPoint("TOP", 0, -10)
    SkinCloseButton(QuestLogFrameCloseButton, QuestLogFrame, -6, -6)

    QuestLogNoQuestsText:ClearAllPoints()
    QuestLogNoQuestsText:SetPoint("TOP", QuestLogFrame, 0, -100)

    local QuestLogFrameLevelsCheckButton = CreateFrame("CheckButton", "QuestLogFrameLevelsCheckButton", QuestLogFrame, "UICheckButtonTemplate")
    QuestLogFrameLevelsCheckButton:SetChecked(C.questlog.showQuestLevels == "1" and true or nil)
    QuestLogFrameLevelsCheckButton:SetPoint("LEFT", QuestLogCollapseAllButton, "RIGHT", 0, 1)
    QuestLogFrameLevelsCheckButton:SetScript("OnClick", function()
      C.questlog.showQuestLevels = C.questlog.showQuestLevels == "1" and "0" or "1"

      -- also update pfQuest's config
      if pfQuest_config and pfQuestConfig and pfQuestConfig.UpdateConfigEntries then
        pfQuest_config["questloglevel"] = C.questlog.showQuestLevels
        pfQuestConfig:UpdateConfigEntries()
      end

      QuestLog_Update()
    end)
    SkinCheckbox(QuestLogFrameLevelsCheckButton, 23)
    QuestLogFrameLevelsCheckButtonText:SetText(T["Quest Levels"])

    if QuestLogTrack then
      CreateBackdrop(QuestLogTrack)
      QuestLogTrack:SetHeight(8)
      QuestLogTrack:SetWidth(8)
      QuestLogTrack:ClearAllPoints()
      QuestLogTrack:SetPoint("RIGHT", QUEST_COUNT, "LEFT", -5, 0)

      StripTextures(QuestLogTrack)
      if QuestLogTrackTracking then
        QuestLogTrackTracking:SetTexture(.8,.8,.8,1)
      end
      if QuestLogTrackTitle then
        QuestLogTrackTitle:Hide()
      end
    end

    local lastButton = nil

    if QuestLogFrameAbandonButton then
      SkinButton(QuestLogFrameAbandonButton)
      QuestLogFrameAbandonButton:ClearAllPoints()
      QuestLogFrameAbandonButton:SetPoint("BOTTOMLEFT", QuestLogFrame, "BOTTOMLEFT", 5, 5)
      QuestLogFrameAbandonButton:SetWidth(98)
      lastButton = QuestLogFrameAbandonButton
    end

    if QuestFramePushQuestButton then
      SkinButton(QuestFramePushQuestButton)
      QuestFramePushQuestButton:ClearAllPoints()
      if lastButton then
        QuestFramePushQuestButton:SetPoint("LEFT", lastButton, "RIGHT", 5, 0)
      else
        QuestFramePushQuestButton:SetPoint("BOTTOMLEFT", QuestLogFrame, "BOTTOMLEFT", 5, 5)
      end
      QuestFramePushQuestButton:SetWidth(98)
      lastButton = QuestFramePushQuestButton
    end

    if QuestFrameExitButton then
      SkinButton(QuestFrameExitButton)
      QuestFrameExitButton:ClearAllPoints()
      if lastButton then
        QuestFrameExitButton:SetPoint("LEFT", lastButton, "RIGHT", 5, 0)
      else
        QuestFrameExitButton:SetPoint("BOTTOMLEFT", QuestLogFrame, "BOTTOMLEFT", 5, 5)
      end
      QuestFrameExitButton:SetWidth(99)
    end

    local QuestLogFrameExpandButton = CreateFrame("Button", "QuestLogFrameExpandButton", QuestLogFrame, "UIPanelButtonTemplate")
    SkinArrowButton(QuestLogFrameExpandButton, "LEFT", 21)
    SetAllPointsOffset(QuestLogFrameExpandButton.icon, QuestLogFrameExpandButton, 6)
    QuestLogFrameExpandButton:SetPoint("LEFT", QuestFrameExitButton, "RIGHT", 5, 0)
    QuestLogFrameExpandButton:SetScript("OnClick", function()
      if QuestLogDetailScrollFrame:IsShown() then
        QuestLogDetailScrollFrame:Hide()
        QuestLogDetailScrollFrame.hidden = true
      else
        QuestLogDetailScrollFrame:Show()
        QuestLogDetailScrollFrame.hidden = nil
      end
    end)

    HookScript(QuestLogDetailScrollFrame, "OnHide", function()
      SkinArrowButton(QuestLogFrameExpandButton, "RIGHT", 21)
      QuestLogDetailScrollFrame:Hide()
      QuestLogFrame:SetWidth(340)
    end)

    HookScript(QuestLogDetailScrollFrame, "OnShow", function()
      SkinArrowButton(QuestLogFrameExpandButton, "LEFT", 21)
      QuestLogDetailScrollFrame:Show()
      QuestLogFrame:SetWidth(676)
      QuestLog_UpdateQuestDetails()
    end)

    StripTextures(EmptyQuestLogFrame)
    EmptyQuestLogFrame:SetScript("OnShow", function()
      -- trigger hide events
      if QuestLogDetailScrollFrame:IsShown() then
        QuestLogDetailScrollFrame:Hide()
      else
        QuestLogDetailScrollFrame:GetScript("OnHide")()
      end
      QuestLogFrameExpandButton:Disable()
    end)

    EmptyQuestLogFrame:SetScript("OnHide", function()
      QuestLogFrameExpandButton:Enable()
    end)
  end

  do -- left pane
    if QuestLogListScrollFrame then
      StripTextures(QuestLogListScrollFrame)
    end
    if QuestLogListScrollFrameScrollBar then
      SkinScrollbar(QuestLogListScrollFrameScrollBar)
    end
    if QuestLogExpandButtonFrame then
      StripTextures(QuestLogExpandButtonFrame) -- ?
    end
    if QuestLogCollapseAllButton then
      StripTextures(QuestLogCollapseAllButton)
      SkinCollapseButton(QuestLogCollapseAllButton, true)
    end

    -- collapse buttons
    if QuestLogCollapseAllButton and QuestLogTitle1 then
      QuestLogCollapseAllButton:ClearAllPoints()
      QuestLogCollapseAllButton:SetPoint("BOTTOMLEFT", QuestLogTitle1, "TOPLEFT", -6, 4)
    end
    for i = 1, QUESTS_DISPLAYED do
      local title = _G["QuestLogTitle"..i]
      if title then
        SkinCollapseButton(title)
      end
    end

    -- quest list backdrop
    local backdrop = CreateFrame("Frame", nil, QuestLogFrame)
    CreateBackdrop(backdrop, nil, nil, .75)
    if QuestLogListScrollFrame then
      backdrop.backdrop:SetPoint("TOPLEFT", QuestLogListScrollFrame, "TOPLEFT", -5, 5)
      backdrop.backdrop:SetPoint("BOTTOMRIGHT", QuestLogListScrollFrame, "BOTTOMRIGHT", 26, -5)
    end

    if QuestLogTitle1 and QuestLogListScrollFrame then
      QuestLogTitle1:ClearAllPoints()
      QuestLogTitle1:SetPoint("TOPLEFT", QuestLogListScrollFrame, "TOPLEFT", 0, 0)
    end

    -- add additional scroll entries
    for i = 7, QUESTS_DISPLAYED do
      local b = _G["QuestLogTitle"..i] or CreateFrame("Button", "QuestLogTitle"..i, QuestLogFrame, "QuestLogTitleButtonTemplate")
      b:SetID(i)
      if _G["QuestLogTitle"..(i-1)] then
        b:SetPoint("TOPLEFT", _G["QuestLogTitle"..(i-1)], "BOTTOMLEFT", 0, 1)
      end
      if _G["QuestLogTitle"..i] then
        SkinCollapseButton(_G["QuestLogTitle"..i])
      end
    end

    if QuestLogListScrollFrame then
      QuestLogListScrollFrame:SetPoint("TOPLEFT", 10, -54)
      QuestLogListScrollFrame:SetHeight(350)
    end

    if type(_G.QuestLog_Update) == "function" then
      hooksecurefunc("QuestLog_Update", function()
        local numEntries = GetNumQuestLogEntries()
        local questIndex, text, level, questTag, isHeader

        if QuestLogDetailScrollFrame and QuestLogDetailScrollFrame.hidden then
          QuestLogDetailScrollFrame:Hide()
        end

        for i=1, QUESTS_DISPLAYED do
          local title = _G["QuestLogTitle"..i]
          local check = _G["QuestLogTitle"..i.."Check"]

          -- update tracked quest marks
          if title and check then
            check:ClearAllPoints()
            check:SetPoint("RIGHT", title, "LEFT", 24, 0)
          end

          -- update quest level
          if C.questlog.showQuestLevels == "1" and title and QuestLogListScrollFrame then
            questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
            if questIndex <= numEntries then
              if pfUI.expansion == 'vanilla' then
                text, level, questTag, isHeader = GetQuestLogTitle(questIndex)
              else
                text, level, questTag, _, isHeader = GetQuestLogTitle(questIndex)
              end
              if not isHeader then
                title:SetText(" ".."["..(questTag and level.."+" or level).."] "..text)
              end
            end
          end
        end
      end)
    end
  end

  do -- right pane
    StripTextures(QuestLogDetailScrollFrame)
    SkinScrollbar(QuestLogDetailScrollFrameScrollBar)



    QuestLogDetailScrollFrame:ClearAllPoints()
    QuestLogDetailScrollFrame:SetPoint("TOPLEFT", QuestLogListScrollFrame, "TOPRIGHT", 35, 0)
    QuestLogDetailScrollFrame:SetHeight(376)
    QuestLogDetailScrollChildFrame:SetHeight(376)

    local bg = QuestLogDetailScrollFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexCoord(.1,1,0,1)
    bg:SetTexture("Interface\\Stationery\\StationeryTest1")

    -- quest log backdrop
    CreateBackdrop(QuestLogDetailScrollFrame, nil, nil, .75)
    QuestLogDetailScrollFrame.backdrop:SetPoint("TOPLEFT", -5, 5)
    QuestLogDetailScrollFrame.backdrop:SetPoint("BOTTOMRIGHT", 26, -5)

    -- skin item buttons
    for i = 1, MAX_NUM_ITEMS do
      local name = "QuestLogItem" .. i
      local item = _G[name]
      local icon = _G[name.."IconTexture"]
      local count = _G[name.."Count"]
      local title = _G[name.."Name"]

      if not item or not icon or not count or not title then
        break
      end

      local xsize = item:GetWidth() -12
      local ysize = item:GetHeight() -12

      item:SetWidth(xsize)
      StripTextures(item)
      CreateBackdrop(item, nil, nil, .75)
      SetAllPointsOffset(item.backdrop, item, 4)
      SetHighlight(item)

      icon:SetWidth(ysize)
      icon:SetHeight(ysize)
      icon:ClearAllPoints()
      icon:SetPoint("LEFT", 6, 0)
      icon:SetTexCoord(.08, .92, .08, .92)
      icon:SetParent(item.backdrop)
      icon:SetDrawLayer("OVERLAY")

      count:SetParent(item.backdrop)
      count:SetDrawLayer("OVERLAY")

      title:SetParent(item.backdrop)
      title:SetDrawLayer("OVERLAY")
    end
  end
end)
