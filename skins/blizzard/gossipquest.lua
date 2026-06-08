pfUI:RegisterSkin("Gossip and Quest", "vanilla:tbc:wotlk", function ()
  local frames = {'Quest', 'Gossip'}
  local panels = {'Greeting', 'Detail', 'Progress', 'Reward'}
  local questTitle = QuestTitleText or QuestInfoTitleHeader
  local questProgressTitle = QuestProgressTitleText or QuestInfoTitleHeader
  local buttons = {
    QuestFrameGreetingGoodbyeButton, GossipFrameGreetingGoodbyeButton,
    QuestFrameDeclineButton, QuestFrameAcceptButton,
    QuestFrameGoodbyeButton, QuestFrameCompleteButton,
    QuestFrameCancelButton, QuestFrameCompleteQuestButton
  }

  for _, button in pairs(buttons) do
    SkinButton(button)
  end

  do -- quest gossip
    if QuestGreetingScrollChildFrame then
      StripTextures(QuestGreetingScrollChildFrame)
    end

    if questTitle then
      questTitle:ClearAllPoints()
      questTitle:SetPoint("TOPLEFT", 10, -10)
    end

    if questProgressTitle then
      questProgressTitle:ClearAllPoints()
      questProgressTitle:SetPoint("TOPLEFT", 10, -10)
    end

    local QuestRewardItemHighlight
    if _G.QuestRewardItemHighlight then
      StripTextures(_G.QuestRewardItemHighlight)
    end

    if QuestRewardScrollChildFrame then
      QuestRewardItemHighlight = CreateFrame("Frame", nil, QuestRewardScrollChildFrame)
      local QuestRewardItemHighlightBG = QuestRewardItemHighlight:CreateTexture(nil, "OVERLAY")
      QuestRewardItemHighlightBG:SetTexture(1,1,1,.2)
      QuestRewardItemHighlightBG:SetAllPoints()
    end

    if type(_G.QuestFrameItems_Update) == "function" then
      hooksecurefunc("QuestFrameItems_Update", function()
        if QuestRewardItemHighlight then
          QuestRewardItemHighlight:Hide()
        end
      end)
    end

    if type(_G.QuestRewardItem_OnClick) == "function" then
      hooksecurefunc("QuestRewardItem_OnClick", function()
        if QuestRewardItemHighlight and this and this.type == "choice" and this.backdrop then
          QuestRewardItemHighlight:SetAllPoints(this.backdrop)
          QuestRewardItemHighlight:Show()
        end
      end)
    end

    for _, name in pairs({ "QuestProgressItem", "QuestDetailItem", "QuestRewardItem" }) do
      for i = 1, 6 do
        local name = name .. i
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
  end

  for _, f in pairs(frames) do
    local frameName = f
    local frame = _G[frameName.."Frame"]
    if not frame then break end
    local NPCName = _G[frame:GetName().."NpcNameText"]
    CreateBackdrop(frame, nil, nil, .75)
    CreateBackdropShadow(frame)

    frame.backdrop:SetPoint("TOPLEFT", 12, -18)
    frame.backdrop:SetPoint("BOTTOMRIGHT", -28, 66)
    frame:SetHitRectInsets(12,28,18,66)
    EnableMovable(frame)

    SkinCloseButton(_G[frame:GetName()..'CloseButton'], frame.backdrop, -6, -6)

    if _G[frame:GetName()..'Portrait'] then
      _G[frame:GetName()..'Portrait']:Hide()
    end

    if NPCName then
      NPCName:ClearAllPoints()
      NPCName:SetPoint("TOP", frame.backdrop, "TOP", 0, -10)
    end

    for _, v in pairs(panels) do
      local panel = v
      if frameName == 'Gossip' and panel ~= 'Greeting' then break end

      local fname = frame:GetName()..panel.."Panel"
      if _G[fname] then
        StripTextures(_G[fname])
      end

      local scroll = _G[frameName..panel.."ScrollFrame"]
      if not scroll then
        break
      end
      scroll:SetHeight(330)
      if _G[scroll:GetName().."ScrollBar"] then
        SkinScrollbar(_G[scroll:GetName().."ScrollBar"])
      end
      CreateBackdrop(scroll, nil, true, .75)

      local bg = scroll:CreateTexture(nil, "LOW")
      bg:SetAllPoints()
      bg:SetTexCoord(.1,1,0,1)
      bg:SetTexture("Interface\\Stationery\\StationeryTest1")

      -- assign material backgrounds to the default one
      if _G[fname.."MaterialTopLeft"] then
        _G[fname.."MaterialTopLeft"].SetTexture = function(self, texture)
          bg:SetTexture(texture)
        end

        _G[fname.."MaterialTopLeft"].Hide = function()
          bg:SetTexture("Interface\\Stationery\\StationeryTest1")
        end

        -- disable material backgrounds
        if _G[fname.."MaterialTopLeft"] then _G[fname.."MaterialTopLeft"].Show = function() return end end
        if _G[fname.."MaterialTopRight"] then _G[fname.."MaterialTopRight"].Show = function() return end end
        if _G[fname.."MaterialBotLeft"] then _G[fname.."MaterialBotLeft"].Show = function() return end end
        if _G[fname.."MaterialBotRight"] then _G[fname.."MaterialBotRight"].Show = function() return end end
        if _G[fname.."MaterialTopLeft"] then _G[fname.."MaterialTopLeft"]:Hide() end
        if _G[fname.."MaterialTopRight"] then _G[fname.."MaterialTopRight"]:Hide() end
        if _G[fname.."MaterialBotLeft"] then _G[fname.."MaterialBotLeft"]:Hide() end
        if _G[fname.."MaterialBotRight"] then _G[fname.."MaterialBotRight"]:Hide() end
      end

      if panel ~= 'Greeting' then
        local num_items, hook_func
        if panel == 'Progress' then
          num_items = MAX_REQUIRED_ITEMS
          hook_func = "QuestFrameProgressItems_Update"
          else
          num_items = MAX_NUM_ITEMS
          hook_func = "QuestFrameItems_Update"
        end
      end
    end
  end
end)
