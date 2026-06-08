pfUI:RegisterModule("itemclick", "vanilla:tbc:wotlk", function ()
  -- small module that tries to decide if an item should be used or dropped into
  -- the auctionhouse search or trade window

  -- On Wrath-based clients, replacing UseContainerItem() taints normal bag
  -- right-click/use flows. Keep the default Blizzard path there.
  if pfUI.client and pfUI.client >= 30000 then
    return
  end

  local function AuxParseLink(link)
    if not link then return end

    local _, _, item_id, enchant_id, suffix_id, unique_id = string.find(link, "item:([-%d]+):([-%d]*):([-%d]*):([-%d]*)")
    local _, _, name = string.find(link, "%[(.-)%]")

    if item_id then
      return tonumber(item_id), tonumber(suffix_id) or 0, tonumber(unique_id) or 0, tonumber(enchant_id) or 0, name
    end
  end

  local function GetContainerItemLinkCompat(bag, slot)
    if _G.GetContainerItemLink then
      local link = _G.GetContainerItemLink(bag, slot)
      if link then return link end
    end

    if _G.C_Container and _G.C_Container.GetContainerItemLink then
      return _G.C_Container.GetContainerItemLink(bag, slot)
    end
  end

  local function HandleAuxItem(bag, slot)
    if not (AuxFrame and AuxFrame:IsShown() and type(get_active_tab) == "function") then
      return
    end

    local active_tab = get_active_tab()
    if not (active_tab and active_tab.USE_ITEM) then
      return
    end

    local item_id, suffix_id, unique_id, enchant_id, name = AuxParseLink(GetContainerItemLinkCompat(bag, slot))
    if not item_id then
      return
    end

    if not name then
      name = GetItemInfo(item_id)
    end

    active_tab.USE_ITEM(item_id, suffix_id, unique_id, enchant_id, name)
    return true
  end

  local pfHookUseContainerItem = _G.UseContainerItem
  function _G.UseContainerItem(bag,slot)
    if TradeFrame:IsShown() then
      PickupContainerItem(bag,slot)
      local slot = TradeFrame_GetAvailableSlot()
      if slot then ClickTradeButton(slot) end
      if CursorHasItem() then
        ClearCursor()
      end
    elseif HandleAuxItem(bag, slot) then
      return
    elseif AuctionFrame and AuctionFrame:IsShown() and
        AuctionFrameBrowse and AuctionFrameBrowse:IsShown() then
      local link = GetContainerItemLink(bag,slot)
      local name = link and string.sub(link, string.find(link, "%[")+1, string.find(link, "%]")-1) or ""
      BrowseName:SetText(name)
      AuctionFrameBrowse_Search()
    elseif AuctionFrame and AuctionFrame:IsShown() and
        AuctionFrameAuctions and AuctionFrameAuctions:IsShown() then
      PickupContainerItem(bag,slot)
      AuctionsItemButton:Click()
      if CursorHasItem() then
        ClearCursor()
      end
    else
      pfHookUseContainerItem(bag,slot)
    end
  end

end)
