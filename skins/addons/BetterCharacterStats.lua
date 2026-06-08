local function RegisterBetterCharacterStatsSkin()
  if pfUI and pfUI.api and pfUI_config then
    local penv = pfUI:GetEnvironment()
    local GetStringColor, GetBorderSize = penv.GetStringColor, penv.GetBorderSize
    local SkinDropDown, HookScript = penv.SkinDropDown, penv.HookScript

    local bcsframe = _G["BCSFrame"]
    if not bcsframe then
      pfUI.addonskinner:UnregisterSkin("BetterCharacterStats")
      pfUI.addonskinner:UnregisterSkin("BetterCharacterStats-epoch")
      return
    end

    local function ApplyBCSSkin()
      for _, region in ipairs({bcsframe:GetRegions()}) do
        if region and region.Hide then region:Hide() end
      end

      for _, name in ipairs({
        "PlayerStatLeftTop", "PlayerStatLeftMiddle", "PlayerStatLeftBottom",
        "PlayerStatRightTop", "PlayerStatRightMiddle", "PlayerStatRightBottom",
      }) do
        local tex = _G[name]
        if tex and tex.Hide then
          tex:Hide()
        end
      end

      if not bcsframe.pfborder then
        local rawborder, border = GetBorderSize()
        local er, eg, eb, ea = GetStringColor(pfUI_config.appearance.border.color)

        local b = CreateFrame("Frame", nil, bcsframe:GetParent())
        b:SetFrameLevel(math.max((bcsframe:GetFrameLevel() or 0) - 2, 0))
        b:SetPoint("TOPLEFT", bcsframe, "TOPLEFT", -border, border)
        b:SetPoint("BOTTOMRIGHT", bcsframe, "BOTTOMRIGHT", border, -border)
        b:SetBackdrop(pfUI.backdrop)
        b:SetBackdropColor(0, 0, 0, .8)
        b:SetBackdropBorderColor(er, eg, eb, ea)
        bcsframe.pfborder = b

        local shadow = CreateFrame("Frame", nil, bcsframe:GetParent())
        shadow:SetFrameLevel(math.max((bcsframe:GetFrameLevel() or 0) - 3, 0))
        shadow:SetPoint("TOPLEFT", b, "TOPLEFT", -3, 3)
        shadow:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 3, -3)
        shadow:SetBackdrop({ bgFile = pfUI.media["img:blank"], tile = true, tileSize = 1 })
        shadow:SetBackdropColor(0, 0, 0, .5)
        bcsframe.pfborder_shadow = shadow
      end

      if not bcsframe.pfleftpanel then
        local left = CreateFrame("Frame", nil, bcsframe)
        left:SetFrameStrata("DIALOG")
        left:SetFrameLevel(bcsframe:GetFrameLevel() + 4)
        left:SetPoint("TOPLEFT", bcsframe, "TOPLEFT", 0, 0)
        left:SetSize(115, 78)
        left:SetBackdrop(pfUI.backdrop)
        left:SetBackdropColor(0, 0, 0, .8)
        left:SetBackdropBorderColor(0, 0, 0, 0)
        bcsframe.pfleftpanel = left
      end

      if not bcsframe.pfrightpanel then
        local right = CreateFrame("Frame", nil, bcsframe)
        right:SetFrameStrata("DIALOG")
        right:SetFrameLevel(bcsframe:GetFrameLevel() + 4)
        right:SetPoint("TOPRIGHT", bcsframe, "TOPRIGHT", 0, 0)
        right:SetSize(115, 78)
        right:SetBackdrop(pfUI.backdrop)
        right:SetBackdropColor(0, 0, 0, .8)
        right:SetBackdropBorderColor(0, 0, 0, 0)
        bcsframe.pfrightpanel = right
      end

      for side = 1, 2 do
        local prefix = side == 1 and "PlayerStatFrameLeft" or "PlayerStatFrameRight"
        for i = 1, 6 do
          local statframe = _G[prefix .. i]
          local label = _G[prefix .. i .. "Label"]
          local value = _G[prefix .. i .. "StatText"]

          if statframe then
            statframe:SetParent(bcsframe)
            statframe:SetFrameStrata("DIALOG")
            statframe:SetFrameLevel(bcsframe:GetFrameLevel() + 8)
            statframe:Show()
          end

          if label then
            label:SetFont(pfUI.font_default, 11, "")
            label:SetTextColor(1, .82, 0, 1)
            label:SetDrawLayer("OVERLAY", 7)
            label:SetAlpha(1)
            label:Show()
          end

          if value then
            value:SetFont(pfUI.font_default, 11, "")
            value:SetDrawLayer("OVERLAY", 7)
            value:SetAlpha(1)
            value:Show()
          end
        end
      end
    end

    local function ApplyDropDownSkin()
      local left = _G["PlayerStatFrameLeftDropDown"]
      local right = _G["PlayerStatFrameRightDropDown"]

      local function ResolveDropDownText(value)
        if not value or not BCS or not BCS.L then return nil end
        return BCS.L[value] or value
      end

      local function RefreshDropDownOverlay(dropdown, configKey, fallbackText)
        if not dropdown then return end

        local textValue = ResolveDropDownText(BCSConfigEpoch and BCSConfigEpoch[configKey]) or fallbackText
        local anchor = dropdown.backdrop or dropdown

        if not dropdown.pfLabel then
          dropdown.pfLabel = dropdown:CreateFontString(nil, "OVERLAY")
          dropdown.pfLabel:SetFontObject(GameFontWhite)
          dropdown.pfLabel:SetFont(pfUI.font_default, 11, "")
          dropdown.pfLabel:SetJustifyH("LEFT")
          dropdown.pfLabel:SetDrawLayer("OVERLAY", 7)
          dropdown.pfLabel:SetTextColor(1, 1, 1, 1)
        end

        dropdown.pfLabel:ClearAllPoints()
        dropdown.pfLabel:SetPoint("LEFT", anchor, "LEFT", 8, 3)
        dropdown.pfLabel:SetPoint("RIGHT", anchor, "RIGHT", -24, 3)
        dropdown.pfLabel:SetText(textValue)
        dropdown.pfLabel:Show()
      end

      local function PrepareDropDown(dropdown)
        if not dropdown or dropdown:GetObjectType() ~= "Frame" then return end

        for _, region in ipairs({dropdown:GetRegions()}) do
          if region and region.GetObjectType and region:GetObjectType() == "Texture" then
            region:Hide()
          end
        end

        local button = _G[dropdown:GetName() .. "Button"]
        if button then
          for _, region in ipairs({button:GetRegions()}) do
            if region and region.GetObjectType and region:GetObjectType() == "Texture" then
              region:Hide()
            end
          end
        end

        dropdown:SetParent(bcsframe)
        dropdown:SetFrameStrata("DIALOG")
        dropdown:SetFrameLevel(bcsframe:GetFrameLevel() + 10)
      end

      if left and left:GetObjectType() == "Frame" then
        PrepareDropDown(left)
        SkinDropDown(left, nil, nil, nil, true)
        if left.backdrop then
          left.backdrop:SetPoint("TOPLEFT", 19, -2)
          left.backdrop:SetPoint("BOTTOMRIGHT", -19, 7)
        end

        local leftButton = _G[left:GetName() .. "Button"]
        if leftButton then
          leftButton:SetFrameStrata("DIALOG")
          leftButton:SetFrameLevel(left:GetFrameLevel() + 2)
          if leftButton.backdrop then
            leftButton.backdrop:Show()
          end
          if leftButton.icon then
            leftButton.icon:Show()
            leftButton.icon:SetDrawLayer("OVERLAY", 7)
            leftButton.icon:SetVertexColor(1, .82, 0, 1)
          end
          if not leftButton.pfBCSListHook then
            HookScript(leftButton, "OnClick", function()
              for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
                local btn = _G["DropDownList1Button" .. i]
                if btn then
                  btn:SetFrameStrata("DIALOG")
                  btn:SetFrameLevel(leftButton:GetFrameLevel() + 4)
                  local normal = _G[btn:GetName() .. "NormalText"]
                  local highlight = _G[btn:GetName() .. "Highlight"]
                  if normal then
                    normal:SetFont(pfUI.font_default, 12, "")
                    normal:SetTextColor(1, 1, 1, 1)
                    normal:SetAlpha(1)
                    normal:Show()
                  end
                  if highlight then
                    highlight:SetVertexColor(1, .82, 0, .15)
                  end
                end
              end
            end)
            leftButton.pfBCSListHook = true
          end
        end

        local leftText = _G[left:GetName() .. "Text"]
        if leftText then
          leftText:ClearAllPoints()
          leftText:SetPoint("LEFT", left.backdrop, "LEFT", 8, 3)
          leftText:SetPoint("RIGHT", left.backdrop, "RIGHT", -24, 3)
          leftText:SetJustifyH("LEFT")
          leftText:SetFont(pfUI.font_default, 11, "")
          leftText:SetTextColor(1, 1, 1, 1)
          leftText:SetDrawLayer("OVERLAY", 7)
          leftText:SetAlpha(1)
          leftText:SetWidth(76)
          leftText:SetText("")
          leftText:Hide()
        end
        RefreshDropDownOverlay(left, "DropdownLeft", "Base Stats")
      end

      if right and right:GetObjectType() == "Frame" then
        PrepareDropDown(right)
        SkinDropDown(right, nil, nil, nil, true)
        if right.backdrop then
          right.backdrop:SetPoint("TOPLEFT", 19, -2)
          right.backdrop:SetPoint("BOTTOMRIGHT", -19, 7)
        end

        local rightButton = _G[right:GetName() .. "Button"]
        if rightButton then
          rightButton:SetFrameStrata("DIALOG")
          rightButton:SetFrameLevel(right:GetFrameLevel() + 2)
          if rightButton.backdrop then
            rightButton.backdrop:Show()
          end
          if rightButton.icon then
            rightButton.icon:Show()
            rightButton.icon:SetDrawLayer("OVERLAY", 7)
            rightButton.icon:SetVertexColor(1, .82, 0, 1)
          end
          if not rightButton.pfBCSListHook then
            HookScript(rightButton, "OnClick", function()
              for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
                local btn = _G["DropDownList1Button" .. i]
                if btn then
                  btn:SetFrameStrata("DIALOG")
                  btn:SetFrameLevel(rightButton:GetFrameLevel() + 4)
                  local normal = _G[btn:GetName() .. "NormalText"]
                  local highlight = _G[btn:GetName() .. "Highlight"]
                  if normal then
                    normal:SetFont(pfUI.font_default, 12, "")
                    normal:SetTextColor(1, 1, 1, 1)
                    normal:SetAlpha(1)
                    normal:Show()
                  end
                  if highlight then
                    highlight:SetVertexColor(1, .82, 0, .15)
                  end
                end
              end
            end)
            rightButton.pfBCSListHook = true
          end
        end

        local rightText = _G[right:GetName() .. "Text"]
        if rightText then
          rightText:ClearAllPoints()
          rightText:SetPoint("LEFT", right.backdrop, "LEFT", 8, 3)
          rightText:SetPoint("RIGHT", right.backdrop, "RIGHT", -24, 3)
          rightText:SetJustifyH("LEFT")
          rightText:SetFont(pfUI.font_default, 11, "")
          rightText:SetTextColor(1, 1, 1, 1)
          rightText:SetDrawLayer("OVERLAY", 7)
          rightText:SetAlpha(1)
          rightText:SetWidth(76)
          rightText:SetText("")
          rightText:Hide()
        end
        RefreshDropDownOverlay(right, "DropdownRight", "Melee")
      end
    end

    local function ApplyAll()
      ApplyBCSSkin()
      ApplyDropDownSkin()
    end

    local dropper = CreateFrame("Frame", nil, UIParent)
    dropper:RegisterEvent("PLAYER_ENTERING_WORLD")
    dropper:SetScript("OnEvent", function()
      this:UnregisterAllEvents()
      ApplyAll()
    end)

    HookScript(bcsframe, "OnShow", ApplyAll)
    ApplyAll()
  end
  pfUI.addonskinner:UnregisterSkin("BetterCharacterStats")
  pfUI.addonskinner:UnregisterSkin("BetterCharacterStats-epoch")
end

pfUI.addonskinner:RegisterSkin("BetterCharacterStats", RegisterBetterCharacterStatsSkin)
pfUI.addonskinner:RegisterSkin("BetterCharacterStats-epoch", RegisterBetterCharacterStatsSkin)
