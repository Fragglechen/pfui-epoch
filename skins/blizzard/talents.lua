pfUI:RegisterSkin("Talents", "vanilla:tbc:wotlk", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  HookAddonOrVariable("Blizzard_TalentUI", function()
    -- Compatibility
    local TALENT_FRAME, TALENT_FRAME_NAME
    if PlayerTalentFrame then -- tbc
      TALENT_FRAME = _G.PlayerTalentFrame
    else -- vanilla
      TALENT_FRAME = _G.TalentFrame
    end
    if not TALENT_FRAME or not TALENT_FRAME.GetName then return end
    TALENT_FRAME_NAME = TALENT_FRAME:GetName()

    local function StripTalentFooterArtwork(frame)
      if not frame then return end

      local scrollframe = _G[TALENT_FRAME_NAME.."ScrollFrame"]
      local name = frame.GetName and frame:GetName() or ""
      local isFooterButton =
        name == TALENT_FRAME_NAME.."LearnButton" or
        name == TALENT_FRAME_NAME.."ResetButton" or
        name == TALENT_FRAME_NAME.."CancelButton"

      if string.find(name, "Talent%d+$") then return end
      if string.find(name, "Tab%d+$") then return end
      if string.find(name, "Button", 1, true) and not isFooterButton then return end
      if string.find(name, "ScrollBar", 1, true) then return end

      if frame.GetRegions then
        for _, region in pairs({ frame:GetRegions() }) do
          if region and region.SetTexture then
            local width = region.GetWidth and region:GetWidth() or 0
            local height = region.GetHeight and region:GetHeight() or 0
            local bottom = region.GetBottom and region:GetBottom()
            local top = region.GetTop and region:GetTop()
            local footerBottom = TALENT_FRAME.backdrop and TALENT_FRAME.backdrop.GetBottom and TALENT_FRAME.backdrop:GetBottom()

            if footerBottom and bottom and top and width > 40 and height > 8 and top < footerBottom + 105 and bottom > footerBottom + 28 then
              region:SetTexture(nil)
              region:SetAlpha(0)
              region:Hide()
            end
          end
        end
      end

      if frame.GetChildren then
        for _, child in pairs({ frame:GetChildren() }) do
          if child and child ~= scrollframe then
            StripTalentFooterArtwork(child)
          end
        end
      end
    end

    local function StripTalentFooterButton(button)
      if not button then return end

      StripTextures(button)

      if button.GetRegions then
        for _, region in pairs({ button:GetRegions() }) do
          if region and region.SetTexture then
            region:SetTexture(nil)
            region:SetAlpha(0)
            region:Hide()
          end
        end
      end
    end

    local function HideTalentFooterBlizzardArt()
      local textures = {
        "Bottom",
        "BottomLeft",
        "BottomMiddle",
        "BottomRight",
        "BottomBorder",
        "ButtonBottomBorder",
        "PointsBar",
        "PointsBarLeft",
        "PointsBarMiddle",
        "PointsBarRight",
        "TalentPointsBar",
        "TalentPointsBarLeft",
        "TalentPointsBarMiddle",
        "TalentPointsBarRight",
        "UnspentPointsBar",
        "UnspentPointsBarLeft",
        "UnspentPointsBarMiddle",
        "UnspentPointsBarRight",
      }

      for _, texture in pairs(textures) do
        local region = _G[TALENT_FRAME_NAME..texture]
        if region then
          if region.SetTexture then region:SetTexture(nil) end
          if region.SetAlpha then region:SetAlpha(0) end
          if region.Hide then region:Hide() end
        end
      end

      local frames = {
        "PreviewBar",
        "PreviewBarFiller",
      }

      for _, frame in pairs(frames) do
        frame = _G[TALENT_FRAME_NAME..frame]
        if frame then
          if frame.GetRegions then
            for _, region in pairs({ frame:GetRegions() }) do
              if region and region.SetTexture then
                region:SetTexture(nil)
                region:SetAlpha(0)
                region:Hide()
              end
            end
          end
        end
      end
    end

    local function SkinTalentFooter()
      local points = _G[TALENT_FRAME_NAME.."TalentPointsText"]
      local learn = _G[TALENT_FRAME_NAME.."LearnButton"]
      local reset = _G[TALENT_FRAME_NAME.."ResetButton"]
      local cancel = _G[TALENT_FRAME_NAME.."CancelButton"]
      local inner = _G[TALENT_FRAME_NAME.."ScrollFrame"]

      HideTalentFooterBlizzardArt()

      if points then
        points:ClearAllPoints()
        points:SetPoint("BOTTOMRIGHT", TALENT_FRAME.backdrop, "BOTTOMRIGHT", -14, 14)
        points:SetJustifyH("RIGHT")
      end

      if cancel then
        StripTalentFooterButton(cancel)
        cancel:Hide()
      end

      if reset then
        StripTalentFooterButton(reset)
        SkinButton(reset)
        reset:SetWidth(150)
        reset:SetHeight(24)
        reset:Show()
        reset:ClearAllPoints()
        if inner then
          reset:SetPoint("RIGHT", inner, "RIGHT", 0, 0)
          reset:SetPoint("BOTTOM", TALENT_FRAME.backdrop, "BOTTOM", 0, 7)
        else
          reset:SetPoint("BOTTOMRIGHT", TALENT_FRAME.backdrop, "BOTTOMRIGHT", -8, 7)
        end
      end

      if learn then
        StripTalentFooterButton(learn)
        SkinButton(learn)
        learn:SetWidth(150)
        learn:SetHeight(24)
        learn:Show()
        learn:ClearAllPoints()
        if inner then
          learn:SetPoint("LEFT", inner, "LEFT", 0, 0)
          learn:SetPoint("BOTTOM", TALENT_FRAME.backdrop, "BOTTOM", 0, 7)
        elseif reset then
          learn:SetPoint("RIGHT", reset, "LEFT", -2*bpad, 0)
        else
          learn:SetPoint("BOTTOMRIGHT", TALENT_FRAME.backdrop, "BOTTOMRIGHT", -8, 7)
        end
      end
    end

    local function DebugTalentFooterRegions(frame, depth)
      if not frame or depth > 4 then return end

      local frameName = frame.GetName and frame:GetName() or tostring(frame)
      local footerBottom = TALENT_FRAME.backdrop and TALENT_FRAME.backdrop.GetBottom and TALENT_FRAME.backdrop:GetBottom()
      if not footerBottom then return end

      if frame.GetRegions then
        for index, region in pairs({ frame:GetRegions() }) do
          if region and region.IsShown and region:IsShown() and region.SetTexture then
            local width = region.GetWidth and region:GetWidth() or 0
            local height = region.GetHeight and region:GetHeight() or 0
            local left = region.GetLeft and region:GetLeft()
            local bottom = region.GetBottom and region:GetBottom()
            local top = region.GetTop and region:GetTop()
            local texture = region.GetTexture and region:GetTexture() or "nil"

            if bottom and top and top < footerBottom + 160 and bottom > footerBottom then
              table.insert(pfUI_cache.talentdebug, {
                frame = frameName,
                region = index,
                texture = tostring(texture),
                width = floor(width + .5),
                height = floor(height + .5),
                left = floor((left or 0) + .5),
                bottom = floor(bottom + .5),
                top = floor(top + .5),
              })
            end
          end
        end
      end

      if frame.GetChildren then
        for _, child in pairs({ frame:GetChildren() }) do
          DebugTalentFooterRegions(child, depth + 1)
        end
      end
    end

    _G.SLASH_PFUITALENTDEBUG1 = "/pftalentdebug"
    _G.SlashCmdList["PFUITALENTDEBUG"] = function()
      pfUI_cache = pfUI_cache or {}
      pfUI_cache.talentdebug = {}
      DebugTalentFooterRegions(TALENT_FRAME, 0)
      DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccpfTalent|r saved " .. table.getn(pfUI_cache.talentdebug) .. " footer texture entries to pfUI_cache.talentdebug")
    end

    StripTextures(TALENT_FRAME)
    CreateBackdrop(TALENT_FRAME, nil, nil, .75)
    CreateBackdropShadow(TALENT_FRAME)

    TALENT_FRAME.backdrop:SetPoint("TOPLEFT", 10, -10)
    TALENT_FRAME.backdrop:SetPoint("BOTTOMRIGHT", -32, 72)
    TALENT_FRAME:SetHitRectInsets(10,32,10,72)
    EnableMovable(TALENT_FRAME)

    TALENT_FRAME:DisableDrawLayer("BACKGROUND")
    if _G[TALENT_FRAME_NAME.."CancelButton"] then
      _G[TALENT_FRAME_NAME.."CancelButton"]:Hide()
    end

    if _G[TALENT_FRAME_NAME.."TitleText"] then
      _G[TALENT_FRAME_NAME.."TitleText"]:ClearAllPoints()
      _G[TALENT_FRAME_NAME.."TitleText"]:SetPoint("TOP", TALENT_FRAME.backdrop, "TOP", 0, -10)
    end
    if _G[TALENT_FRAME_NAME.."SpentPoints"] then
      _G[TALENT_FRAME_NAME.."SpentPoints"]:ClearAllPoints()
      _G[TALENT_FRAME_NAME.."SpentPoints"]:SetPoint("TOP", TALENT_FRAME.backdrop, "TOP", 0, -48)
    end

    if _G[TALENT_FRAME_NAME.."CloseButton"] then
      SkinCloseButton(_G[TALENT_FRAME_NAME.."CloseButton"], TALENT_FRAME.backdrop, -6, -6)
    end

    if _G[TALENT_FRAME_NAME.."ScrollFrame"] then
      StripTextures(_G[TALENT_FRAME_NAME.."ScrollFrame"])
    end
    if _G[TALENT_FRAME_NAME.."ScrollFrameScrollBar"] then
      SkinScrollbar(_G[TALENT_FRAME_NAME.."ScrollFrameScrollBar"])
    end

    SkinTalentFooter()

    for i = 1, MAX_NUM_TALENTS do
      local talent = _G[TALENT_FRAME_NAME.."Talent"..i]
      if talent then
        StripTextures(talent)
        SkinButton(talent, nil, nil, nil, _G[TALENT_FRAME_NAME.."Talent"..i.."IconTexture"])

        _G[TALENT_FRAME_NAME.."Talent"..i.."Rank"]:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
      end
    end

    if _G[TALENT_FRAME_NAME.."Tab1"] then
      _G[TALENT_FRAME_NAME.."Tab1"]:ClearAllPoints()
      _G[TALENT_FRAME_NAME.."Tab1"]:SetPoint("TOPLEFT", TALENT_FRAME.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
    end
    for i = 1, 5 do
      local tab = _G[TALENT_FRAME_NAME.."Tab"..i]
      local lastTab = _G[TALENT_FRAME_NAME.."Tab"..(i-1)]
      if tab then
      if lastTab then
        tab:ClearAllPoints()
        tab:SetPoint("LEFT", lastTab, "RIGHT", border*2 + 1, 0)
      end
      SkinTab(tab)
      end
    end

    StripTalentFooterArtwork(TALENT_FRAME)
    SkinTalentFooter()

    local delay = CreateFrame("Frame")
    delay.ticks = 0
    delay:Hide()
    delay:SetScript("OnUpdate", function()
      this.ticks = this.ticks + 1
      StripTalentFooterArtwork(TALENT_FRAME)
      SkinTalentFooter()
      if this.ticks >= 5 then
        this:Hide()
      end
    end)
    delay.Start = function(self)
      self.ticks = 0
      self:Show()
    end

    if TALENT_FRAME.HookScript then
      TALENT_FRAME:HookScript("OnShow", function()
        StripTalentFooterArtwork(TALENT_FRAME)
        SkinTalentFooter()
        delay:Start()
      end)
    end

    if type(_G.PlayerTalentFrame_Update) == "function" then
      hooksecurefunc("PlayerTalentFrame_Update", function()
        StripTalentFooterArtwork(TALENT_FRAME)
        SkinTalentFooter()
        delay:Start()
      end)
    end
  end)
end)
