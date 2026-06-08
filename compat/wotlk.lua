-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())
if pfUI.expansion ~= "wotlk" then return end

-- [[ Constants ]]--
MAX_LEVEL = 80
CASTBAR_EVENT_CAST_DELAY = "UNIT_SPELLCAST_DELAYED"
CASTBAR_EVENT_CHANNEL_DELAY = "UNIT_SPELLCAST_CHANNEL_UPDATE"
CASTBAR_EVENT_CAST_START = "UNIT_SPELLCAST_START"
CASTBAR_EVENT_CHANNEL_START = "UNIT_SPELLCAST_CHANNEL_START"

EVENTS_MINIMAP_ZONE_UPDATE = { "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED" }

MICRO_BUTTONS = {
  "CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton",
  "AchievementMicroButton", "QuestLogMicroButton", "SocialsMicroButton",
  "WorldMapMicroButton", "PVPMicroButton", "LFGMicroButton",
  "HelpMicroButton",
}

NAMEPLATE_OBJECTORDER = { "border", "castborder", "casticon", "glow", "name", "level", "levelicon", "raidicon" }
NAMEPLATE_FRAMETYPE = "Frame"

MINIMAP_TRACKING_FRAME = _G.MiniMapTracking or _G.MiniMapTrackingFrame or _G.MiniMapTrackingButton
FRIENDS_NAME_LOCATION = "ButtonTextLocation"

COOLDOWN_FRAME_TYPE = "Cooldown"
LOOT_BUTTON_FRAME_TYPE = "Button"

PLAYER_BUFF_START_ID = 0

ACTIONBAR_SECURE_TEMPLATE_BAR = "SecureHandlerStateTemplate"
ACTIONBAR_SECURE_TEMPLATE_BUTTON = "SecureActionButtonTemplate"
UNITFRAME_SECURE_TEMPLATE = "SecureUnitButtonTemplate"

-- [[ WotLK API Downgrade ]]--
FCF_SetChatWindowFontSize = function(frame, size)
  return _G.FCF_SetChatWindowFontSize(nil, frame, size)
end

UIDropDownMenu_SetText = function(text, frame)
  return _G.UIDropDownMenu_SetText(frame, text)
end

UIDropDownMenu_SetWidth = function(num, frame)
  return _G.UIDropDownMenu_SetWidth(frame, num)
end

UIDropDownMenu_SetButtonWidth = function(num, frame)
  return _G.UIDropDownMenu_SetButtonWidth(frame, num)
end

UIDropDownMenu_JustifyText = function(align, frame)
  return _G.UIDropDownMenu_JustifyText(frame, align)
end

local raw_UnitBuff = _G.UnitBuff
local raw_UnitDebuff = _G.UnitDebuff

local function normalizeBuffIndex(id)
  local index = tonumber(id) or 0
  if PLAYER_BUFF_START_ID and PLAYER_BUFF_START_ID > 0 then
    index = index - PLAYER_BUFF_START_ID
  end
  if index < 1 then
    index = 1
  end
  return index
end

function GetPlayerBuff(id, mode)
  local index = normalizeBuffIndex(id)
  local filter = mode and string.find(mode, "HARMFUL", 1, true) and "HARMFUL" or nil
  local name = filter and raw_UnitDebuff("player", index) or raw_UnitBuff("player", index)
  if not name then return -1 end
  return id
end

function GetPlayerBuffApplications(id, mode)
  local index = normalizeBuffIndex(id)
  local filter = mode and string.find(mode, "HARMFUL", 1, true) and "HARMFUL" or nil
  local _, _, _, count = filter and raw_UnitDebuff("player", index) or raw_UnitBuff("player", index)
  return count or 0
end

function GetPlayerBuffTexture(id, mode)
  local index = normalizeBuffIndex(id)
  local filter = mode and string.find(mode, "HARMFUL", 1, true) and "HARMFUL" or nil
  local _, _, icon = filter and raw_UnitDebuff("player", index) or raw_UnitBuff("player", index)
  return icon
end

function GetPlayerBuffDispelType(id, mode)
  local _, _, _, _, debuffType = raw_UnitDebuff("player", normalizeBuffIndex(id))
  return debuffType
end

function GetPlayerBuffTimeLeft(id, mode)
  local index = normalizeBuffIndex(id)
  local filter = mode and string.find(mode, "HARMFUL", 1, true) and "HARMFUL" or nil
  local _, _, _, _, _, duration, expirationTime = filter and raw_UnitDebuff("player", index) or raw_UnitBuff("player", index)
  if expirationTime and duration and duration > 0 then
    return expirationTime - GetTime()
  end
  return 0
end

GetDifficultyColor = GetQuestDifficultyColor or GetDifficultyColor

function UnitBuff(unitstr, i)
  local _, _, icon, count, _, duration, expirationTime, _, _, _, spellId = raw_UnitBuff(unitstr, i)
  return icon, count, nil, spellId, duration, expirationTime
end

function UnitDebuff(unitstr, i)
  local _, _, texture, stacks, dtype, _, duration, expirationTime, _, _, spellId = raw_UnitDebuff(unitstr, i)
  return texture, stacks, dtype, spellId, duration, expirationTime
end

function GetContainerNumSlots(bag)
  if bag == -2 and pfUI.bag and not pfUI.bag.showKeyring then
    return 0
  else
    return _G.GetContainerNumSlots(bag)
  end
end

libdebuff = {
  ["UnitDebuff"] = function(self, a1, a2, a3)
    return _G.UnitDebuff(a1, a2, a3)
  end
}

if not _G.GetUnitGUID and _G.UnitGUID then
  function GetUnitGUID(unit)
    return _G.UnitGUID(unit)
  end
end

if not _G.ManaBarColor then
  local fallbackPowerColors = _G.PowerBarColor or {}
  ManaBarColor = {
    [0] = fallbackPowerColors["MANA"] or { r = 0.00, g = 0.00, b = 1.00 },
    [1] = fallbackPowerColors["RAGE"] or { r = 1.00, g = 0.00, b = 0.00 },
    [2] = fallbackPowerColors["FOCUS"] or { r = 1.00, g = 0.50, b = 0.25 },
    [3] = fallbackPowerColors["ENERGY"] or { r = 1.00, g = 1.00, b = 0.00 },
    [4] = fallbackPowerColors["HAPPINESS"] or { r = 0.00, g = 1.00, b = 1.00 },
    [5] = fallbackPowerColors["RUNIC_POWER"] or { r = 0.00, g = 0.82, b = 1.00 },
  }
end

UnitReactionColor = {
  { r = 1.0, g = 0.0, b = 0.0 },
  { r = 1.0, g = 0.0, b = 0.0 },
  { r = 1.0, g = 0.5, b = 0.0 },
  { r = 1.0, g = 1.0, b = 0.0 },
  { r = 0.0, g = 1.0, b = 0.0 },
  { r = 0.0, g = 1.0, b = 0.0 },
  { r = 0.0, g = 1.0, b = 0.0 },
}

if SetCVar then
  SetCVar("showQuestTrackingTooltips", 0)
end
