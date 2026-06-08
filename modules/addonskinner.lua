local ADDONSKINNER_TITLE = "|cff33ffccpf|cffffffffUI|cffaaaaaa [Addon Skinner]"

pfUI.addonskinner = pfUI.addonskinner or CreateFrame("Frame", "pfAddonSkinner", UIParent)
pfUI.addonskinner.skins = pfUI.addonskinner.skins or {}
pfUI.addonskinner.list = pfUI.addonskinner.list or {}

function pfUI.addonskinner:RegisterSkin(addon_name, skin_function)
  if self.skins[addon_name] then return end

  self.skins[addon_name] = skin_function
  table.insert(self.list, addon_name)
end

function pfUI.addonskinner:UnregisterSkin(addon_name)
  if self.skins[addon_name] then
    self.skins[addon_name] = nil
  end
end

function pfUI.addonskinner:GetConfig()
  pfUI_config.addonskinner = pfUI_config.addonskinner or {}
  local config = self.config or pfUI_config.addonskinner
  config.disabled = config.disabled or {}
  config.notifications = config.notifications or "0"
  self.config = config
  return config
end

function pfUI.addonskinner:Skin(addon)
  local config = self:GetConfig()
  local msg_pref = ADDONSKINNER_TITLE .. "|r: "
  local msg_skinned = msg_pref .. "%q skinned"
  local msg_err = msg_pref .. "error skinning %s --> |cffff0000%s|r"

  local function RunSkin(addon_name)
    if not self.skins[addon_name] or config.disabled[addon_name] == "1" then return end
    local ok, err = pcall(self.skins[addon_name])

    pfUI_cache.addonskinner_errors = pfUI_cache.addonskinner_errors or {}
    pfUI_cache.addonskinner_errors[addon_name] = ok and nil or tostring(err)

    if config.notifications == "1" then
      if not ok then
        DEFAULT_CHAT_FRAME:AddMessage(string.format(msg_err, addon_name, tostring(err)))
      else
        DEFAULT_CHAT_FRAME:AddMessage(string.format(msg_skinned, addon_name))
      end
    end
  end

  if addon then
    RunSkin(addon)
    return
  end

  for _, addon_name in pairs(self.list) do
    if IsAddOnLoaded(addon_name) then
      RunSkin(addon_name)
    end
  end
end

function pfUI.addonskinner:Load(eventName, ...)
  local arg1 = ...

  if eventName == "VARIABLES_LOADED" then
    local config = self:GetConfig()

    for addon_name in pairs(config.disabled) do
      if self.skins[addon_name] == nil then
        config.disabled[addon_name] = nil
      end
    end

    if UnitIsConnected("player") then
      self:Skin()
    else
      self:RegisterEvent("PLAYER_LOGIN")
    end

    self:RegisterEvent("ADDON_LOADED")
  elseif eventName == "PLAYER_LOGIN" then
    self:Skin()
  else
    self:Skin(arg1)
  end
end

function pfUI.addonskinner:Update()
end

pfUI:RegisterModule("addonskinner", function ()
  pfUI.addonskinner:SetScript("OnEvent", function(_, eventName, ...)
    pfUI.addonskinner:Load(eventName, ...)
  end)

  pfUI.addonskinner:Load("VARIABLES_LOADED")

  if pfUI.addonskinner.LoadGui then
    pfUI.addonskinner:LoadGui()
  end
end)
