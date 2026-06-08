pfUI:RegisterSkin("Profession", "vanilla:tbc:wotlk", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  local frames = {
    ["TradeSkill"] = { "Blizzard_TradeSkillUI", "TRADE_SKILLS_DISPLAYED", "TradeSkillSkill", "MAX_TRADE_SKILL_REAGENTS" },
    ["Craft"] = { "Blizzard_CraftUI", "CRAFTS_DISPLAYED", "Craft", "MAX_CRAFT_REAGENTS" },
  }

  local function StripLargeArtwork(frame)
    if not frame then return end

    local fname = frame.GetName and frame:GetName() or ""
    if string.find(fname, "Reagent%d+$") then return end

    if frame.GetRegions then
      for _, region in pairs({ frame:GetRegions() }) do
        if region and region.SetTexture then
          local name = region.GetName and region:GetName() or ""
          local parent = region.GetParent and region:GetParent()
          local parentname = parent and parent.GetName and parent:GetName() or ""
          local width = region.GetWidth and region:GetWidth() or 0
          local height = region.GetHeight and region:GetHeight() or 0

          if width > 80 and height > 30
          and not string.find(name, "Highlight", 1, true)
          and not string.find(name, "Icon", 1, true)
          and not string.find(parentname, "Reagent", 1, true) then
            region:SetTexture(nil)
            region:SetAlpha(0)
            region:Hide()
          end
        end
      end
    end

    if frame.GetChildren then
      for _, child in pairs({ frame:GetChildren() }) do
        StripLargeArtwork(child)
      end
    end
  end

  local function CleanUnknownCost(label)
    if not label or not label.GetText then return end

    local text = label:GetText()
    if text and string.find(text, "Total Cost:") and string.find(text, "%-%-") then
      label:SetText(SPELL_REAGENTS)
    end
  end

  local function CreatePaneMask(owner, anchor)
    if not owner or not anchor then return end

    if not owner.pfMask then
      owner.pfMask = CreateFrame("Frame", nil, anchor:GetParent() or owner)
      CreateBackdrop(owner.pfMask, nil, nil, 1)
      owner.pfMask:EnableMouse(false)
    end

    owner.pfMask:ClearAllPoints()
    owner.pfMask:SetPoint("TOPLEFT", anchor, "TOPLEFT", -5, 5)
    owner.pfMask:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 26, -5)
    owner.pfMask:SetFrameLevel((anchor:GetFrameLevel() or 1) + 1)
    if owner.pfMask.backdrop then
      owner.pfMask.backdrop:SetBackdropColor(0, 0, 0, .92)
      owner.pfMask.backdrop:SetBackdropBorderColor(.1, .1, .1, 1)
    end
    owner.pfMask:Show()

    return owner.pfMask
  end

  local function RaiseFrame(frame, level)
    if frame and level and frame.SetFrameLevel then
      frame:SetFrameLevel(level)
    end
  end

  for name, ext in pairs(frames) do
    local name        = name
    local ext         = ext
    local addon       = ext[1]
    local displayed   = ext[2]
    local template    = ext[3]
    local maxreagents = ext[4]
    local frame       = name .. "Frame"

    HookAddonOrVariable(addon, function()
      local SetSelection = frame.."_SetSelection"
      local icon = _G[template.."Icon"] or _G[template.."SkillIcon"]
      local seltitle = _G[template.."Name"] or _G[template.."SkillName"]
      local reagentlabel = _G[name.."ReagentLabel"]
      local collapseall = _G[name.."CollapseAllButton"]
      local detailscroll = _G[name.."DetailScrollFrame"]
      local detailscrollchild = _G[name.."DetailScrollChildFrame"]
      local detailscrollbar = _G[name.."DetailScrollFrameScrollBar"]
      local rankbar = _G[name.."RankFrame"]
      local decrease = _G[name.."DecrementButton"]
      local increase = _G[name.."IncrementButton"]
      local inputbox = _G[name.."InputBox"]
      local cancel = _G[name.."CancelButton"]
      local create = _G[name.."CreateButton"]
      local createall = _G[name.."CreateAllButton"]
      local subclassdropdown = _G[name.."SubClassDropDown"]
      local invslotdropdown = _G[name.."InvSlotDropDown"]
      local scrollbar = _G[name.."ListScrollFrameScrollBar"]
      local scrollframe = _G[name.."ListScrollFrame"]
      local close = _G[frame.."CloseButton"]
      local title = _G[frame.."TitleText"]
      local points = _G[frame.."PointsText"]
      local requiretext = _G[name .. "RequirementText"]
      local search = _G[name .. "FrameEditBox"] or _G[name .. "FrameSearchBox"]

      local frame = _G[frame]

      StripTextures(frame)
      CreateBackdrop(frame, nil, nil, .75)
      CreateBackdropShadow(frame)

      frame:SetWidth(676)
      frame:SetHeight(440)
      frame:DisableDrawLayer("BACKGROUND")
      EnableMovable(frame)

      title:ClearAllPoints()
      title:SetPoint("TOP", 0, -10)
      title:SetTextColor(1,1,1,1)
      SkinCloseButton(close, frame, -6, -6)

      do
        StripTextures(scrollframe)
        StripLargeArtwork(scrollframe)
        SkinScrollbar(scrollbar)

        scrollframe:ClearAllPoints()
        scrollframe:SetPoint("TOPLEFT", 10, -65)
        scrollframe:SetWidth(300)
        scrollframe:SetHeight(365)

        local backdrop = CreateFrame("Frame", scrollframe:GetName().."Backdrop", frame)
        CreateBackdrop(backdrop, nil, nil, .75)
        scrollframe.backdrop = backdrop.backdrop
        scrollframe.backdrop:SetPoint("TOPLEFT", scrollframe, "TOPLEFT", -5, 5)
        scrollframe.backdrop:SetPoint("BOTTOMRIGHT", scrollframe, "BOTTOMRIGHT", 26, -5)

        local leftmask = CreatePaneMask(scrollframe, scrollframe)
        local leftlevel = leftmask and leftmask:GetFrameLevel() + 2
        RaiseFrame(scrollframe, leftlevel)
        RaiseFrame(scrollbar, leftlevel)

        _G[template..1]:ClearAllPoints()
        _G[template..1]:SetPoint("TOPLEFT", scrollframe, "TOPLEFT", 0, 0)

        StripTextures(collapseall)
        SkinCollapseButton(collapseall, true)
        collapseall:ClearAllPoints()
        collapseall:SetPoint("BOTTOMLEFT", scrollframe, "TOPLEFT", -5, 5)
        RaiseFrame(collapseall, leftlevel)

        if invslotdropdown then
          SkinDropDown(invslotdropdown)
          invslotdropdown:ClearAllPoints()
          invslotdropdown:SetPoint("BOTTOMRIGHT", scrollframe.backdrop, "TOPRIGHT", 15, 0)

          SkinDropDown(subclassdropdown)
          subclassdropdown:ClearAllPoints()
          subclassdropdown:SetPoint("RIGHT", invslotdropdown, "LEFT", 27, 0)
        end
      end

      do
        StripTextures(detailscroll)
        StripTextures(detailscrollchild)
        StripLargeArtwork(detailscroll)
        StripLargeArtwork(detailscrollchild)
        SkinScrollbar(detailscrollbar)

        local backdrop = CreateFrame("Frame", nil, frame)
        CreateBackdrop(backdrop, nil, nil, .75)
        detailscroll.backdrop = backdrop.backdrop

        detailscroll.backdrop:SetPoint("TOPLEFT", detailscroll, "TOPLEFT", -5, 5)
        detailscroll.backdrop:SetPoint("BOTTOMRIGHT", detailscroll, "BOTTOMRIGHT", 26, -5)

        local rightmask = CreatePaneMask(detailscroll, detailscroll)
        local rightlevel = rightmask and rightmask:GetFrameLevel() + 2
        RaiseFrame(detailscroll, rightlevel)
        RaiseFrame(detailscrollchild, rightlevel)
        RaiseFrame(detailscrollbar, rightlevel)

        StripTextures(_G[name.."RankFrameBorder"])
        CreateBackdrop(rankbar, nil, true)
        rankbar:SetStatusBarTexture(pfUI.media["img:bar"])
        rankbar:ClearAllPoints()
        rankbar:SetPoint("TOPLEFT", detailscroll.backdrop, "TOPLEFT", 0, 25)
        rankbar:SetPoint("BOTTOMRIGHT", detailscroll.backdrop, "TOPRIGHT", 0, 6)

        if decrease and increase then
          SkinArrowButton(decrease, "left", 18)
          SkinArrowButton(increase, "right", 18)
        end

        if inputbox then
          inputbox:DisableDrawLayer("BACKGROUND")
          CreateBackdrop(inputbox)
          SetAllPointsOffset(inputbox.backdrop, inputbox, .2)
          inputbox:SetJustifyH("CENTER")
          inputbox:SetWidth(36)
        end

        SkinButton(cancel)
        cancel:ClearAllPoints()
        cancel:SetPoint("TOPRIGHT", detailscroll.backdrop, "BOTTOMRIGHT", 0, -5)

        SkinButton(create)
        create:ClearAllPoints()
        create:SetPoint("RIGHT", cancel, "LEFT", -2*bpad, 0)

        SkinButton(createall)
        StripTextures(_G[name.."ExpandButtonFrame"])

        detailscroll:ClearAllPoints()
        detailscroll:SetPoint("TOPLEFT", 346, -65)
        detailscroll:SetWidth(299)
        detailscroll:SetHeight(338)

        for i = 1, _G[maxreagents] do
          local reagent = name.."Reagent" .. i
          local item = _G[reagent]
          local itemicon = _G[reagent.."IconTexture"]
          local count = _G[reagent.."Count"]
          local itemtitle = _G[reagent.."Name"]
          local size = item:GetHeight() - 10

          StripTextures(item)
          CreateBackdrop(item, nil, nil, .75)
          SetAllPointsOffset(item.backdrop, item, 4)
          SetHighlight(item)
          RaiseFrame(item, rightlevel)

          itemicon:SetWidth(size)
          itemicon:SetHeight(size)
          itemicon:ClearAllPoints()
          itemicon:SetPoint("LEFT", 5, 0)
          itemicon:SetTexCoord(.08, .92, .08, .92)
          itemicon:SetParent(item.backdrop)
          itemicon:SetDrawLayer("OVERLAY")

          count:SetParent(item.backdrop)
          count:SetDrawLayer("OVERLAY")
          count:ClearAllPoints()
          count:SetPoint("BOTTOMRIGHT", itemicon, "BOTTOMRIGHT", 0, 0)

          itemtitle:SetParent(item.backdrop)
          itemtitle:SetDrawLayer("OVERLAY")
        end

        if points then
          points:ClearAllPoints()
          points:SetPoint("RIGHT", create, "LEFT", -20, 0)
        end

        StripTextures(icon)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", 5, -5)
        SkinButton(icon, nil, nil, nil, nil, true)
        icon:SetPushedTexture(nil)
        RaiseFrame(icon, rightlevel)

        seltitle:SetJustifyV("TOP")
        seltitle:SetTextColor(.8,.8,.8,1)

        reagentlabel:ClearAllPoints()
        reagentlabel:SetPoint("TOPLEFT", seltitle, "BOTTOMLEFT", -45, -15)
        reagentlabel:SetTextColor(1,1,1,1)

        local scanner = libtipscan:GetScanner(name)
        local function HideExtraDetailText(hide)
          if not detailscrollchild or not detailscrollchild.GetRegions then return end

          for _, region in pairs({ detailscrollchild:GetRegions() }) do
            if region and region.GetText and region.SetPoint
            and region ~= seltitle
            and region ~= reagentlabel then
              if hide then
                region:Hide()
              else
                region:Show()
              end
            end
          end

          if requiretext then
            if hide then
              requiretext:Hide()
            else
              requiretext:Show()
            end
          end
        end

        hooksecurefunc(SetSelection, function(id)
          if id and id ~= 0 then
            detailscroll:Show()
            HandleIcon(icon, icon:GetNormalTexture())

            if name == "TradeSkill" then
              local itemlink = GetTradeSkillItemLink(id)
              if itemlink then
                local _, _, link = string.find(itemlink, "(item:%d+:%d+:%d+:%d+)")
                local off = requiretext and requiretext:GetHeight() or 1
                reagentlabel:SetPoint("TOPLEFT", seltitle, "BOTTOMLEFT", -45, -15-off)

                if link then
                  HideExtraDetailText(true)
                  scanner:SetHyperlink(link)
                  seltitle:SetHeight(0)
                  seltitle:SetText(scanner:FontString())

                  if seltitle:GetHeight() < 30 then
                    seltitle:SetHeight(35)
                  end
                end
              else
                HideExtraDetailText(false)
              end
            end

            CleanUnknownCost(reagentlabel)
            StripLargeArtwork(scrollframe)
            StripLargeArtwork(detailscroll)
            StripLargeArtwork(detailscrollchild)
          end
        end)
      end

      if search then
        _G[displayed] = 21
        scrollframe:SetHeight(338)

        local rank = _G[name.."RankFrameSkillRank"]
        if rank then
          rank:ClearAllPoints()
          rank:SetPoint("CENTER", rankbar, "CENTER", 0, 0)
        end

        local available = _G[frame:GetName().."AvailableFilterCheckButton"]
            or _G[name.."MatsCheckButton"]
            or _G[name.."FrameMatsCheckButton"]
        local available2 = _G[name.."SkillCheckButton"]
            or _G[name.."FrameSkillCheckButton"]
        if available then
          SkinCheckbox(available)
          available:ClearAllPoints()
          available:SetPoint("TOPLEFT", frame, "TOPLEFT", 400, -28)
        end
        if available2 then
          SkinCheckbox(available2)
          available2:ClearAllPoints()
          available2:SetPoint("LEFT", available, "RIGHT", 90, 0)
        end

        search:DisableDrawLayer("BACKGROUND")
        CreateBackdrop(search, nil, nil, 1)
        search.backdrop:SetAllPoints(search)
        search:SetTextInsets(5, 5, 5, 5)
        search:SetHeight(22)
        search:ClearAllPoints()
        search:SetPoint("TOPLEFT",  scrollframe.backdrop, "BOTTOMLEFT",  0, -5)
        search:SetPoint("TOPRIGHT", scrollframe.backdrop, "BOTTOMRIGHT", 0, -5)

        local craft_filter = CraftFrameFilterDropDown
        if craft_filter then
          SkinDropDown(craft_filter)
          craft_filter:ClearAllPoints()
          craft_filter:SetPoint("BOTTOMRIGHT", scrollframe.backdrop, "TOPRIGHT", 15, 0)
        end
      else
        _G[displayed] = 23
      end

      CleanUnknownCost(reagentlabel)
      StripLargeArtwork(scrollframe)
      StripLargeArtwork(detailscroll)
      StripLargeArtwork(detailscrollchild)

      if frame.HookScript then
        frame:HookScript("OnShow", function()
          CleanUnknownCost(reagentlabel)
          StripLargeArtwork(scrollframe)
          StripLargeArtwork(detailscroll)
          StripLargeArtwork(detailscrollchild)
        end)
      end

      if type(_G[name.."Frame_Update"]) == "function" then
        hooksecurefunc(name.."Frame_Update", function()
          CleanUnknownCost(reagentlabel)
          StripLargeArtwork(scrollframe)
          StripLargeArtwork(detailscroll)
          StripLargeArtwork(detailscrollchild)
        end)
      end

      for i = 9, _G[displayed] do
        local button = _G[template..i] or CreateFrame("Button", template..i, frame, template.."ButtonTemplate")
        button:SetPoint("TOPLEFT", _G[template..i - 1], "BOTTOMLEFT")
      end
      for i = 1, _G[displayed] do
        SkinCollapseButton(_G[template..i])
        if scrollframe.pfMask then
          RaiseFrame(_G[template..i], scrollframe.pfMask:GetFrameLevel() + 2)
        end
      end
    end)
  end
end)
