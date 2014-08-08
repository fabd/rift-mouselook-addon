-------------------------------------------------------------------------------
-- Mouse Look Toggle Addon for Rift MMO.
--
-- See main site for documentation & installation: 
--
-- http://fabd.github.io/rift-mouselook-addon/
-------------------------------------------------------------------------------

local addon, MT = ...
local UNC = UI.Native.Console1
local isDebug = false

function MT.DebugMsg(...)
  if isDebug then
    print(...)
  end
end

--
-- These are the Native UI's we want to keep track of when they are opened or closed (using the Loaded() event).
--
-- This is not the full list of UI.Native frames! We only want to keep track of the Rift UI which may require
-- mouse or keyboard input. When one of these UI is open, we want to toggle off Mouse Look automatically and
-- we also want the Interract key (by default "F") to work in the input fields (eg. Auction search).
--
-- Note that in some cases, it is more convenient to maintain Mouse Look (for example if using Auto-Loot, it
-- is more convenient for Mouse Look to be maintained whenever the loot window briefly appears during combat).
--

local RIFT_UI_TO_WATCH =
{
  'Ability',
--'Accolade',
  'Achievement',
--'AchievementPopup',
  'Adventure',
--'Ascend',
--'Attunement',
  'Auction',
--'Bag',
--'BagBank1',
--'BagInventory1',     (Disable so we can use "Interract" with NPCs while bags are open)
  'Bank',
  'BankGuild',
--'Breath',
  'Character',
--'Chronicle',
  'Coinlock',
--'Console1',
--'ConsoleSetting',
  'Crafting',
--'Ctf',
--'Guest',
  'Guild',
--'GuildCharter',
  'GuildFinder',
--'Import',
--'Keybind',
--'Layout',
--'Leaderboard',
  'Lfg',
--'Loot',
  'Macro',
--'MacroIcon',
--'MacroSlash',
  'Mail',
--'MailRead',
  'MapMain',
--'MechanicPlayer',
--'MechanicTarget',
  'Mentor',
  'Menu',
--'MessageEvent',
--'MessageText',
--'MessageWarfront',
--'MessageZone',
--'Notification',
--'Notify',
--'PortraitFocus',
  'Quest',
--'QuestStickies',
--'Question',
--'Raid',
--'Reactive',
--'Recall',
--'Respec',
--'Rift',
--'Roll1',
--'Roll2',
--'Roll3',
--'Roll4',
  'Setting',
  'Social',
  'Soul',
  'Split',
--'Streaming',
--'Ticket',
--'Tip',
--'TipAlert',
--'TooltipAnchor',
  'Trade',
--'Tray',
--'TraySocial',
--'Treasure',
--'Trial',
--'Upgrade',
  'Warfront',
  'WarfrontLeaderboard',
--'World',
}

local IsUiOpen = {}

function MT.SetUiStatus(windowId, isLoaded)
  IsUiOpen[windowId] = isLoaded
end

function MT.CheckForOpenUi()
  local b, k, v = false
  for k, v in pairs(IsUiOpen) do
    b = b or v
  end
  return b
end

function MT.CreatePixels()
  local o

  MT.context = UI.CreateContext(addon.identifier)
  
  o = UI.CreateFrame("Frame", "Mouselook Toggle Pixel", MT.context)
  o:SetBackgroundColor(1,0,0)
  o:SetWidth(1)
  o:SetHeight(1)
  o:SetLayer(1)
  o:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
  o:SetVisible(false)
  MT.Pixel = o

  o = UI.CreateFrame("Frame", "Mouselook Pixel 2", MT.context)
  o:SetBackgroundColor(0,1,0)
  o:SetWidth(1)
  o:SetHeight(1)
  o:SetLayer(1)
  o:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 1, 0)
  o:SetVisible(true)
  MT.Pixel2 = o
 
  o = UI.CreateFrame("Frame", "Mouselook Pixel 3", MT.context)
  o:SetBackgroundColor(0,0,1)
  o:SetWidth(1)
  o:SetHeight(1)
  o:SetLayer(1)
  o:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 2, 0)
  o:SetVisible(true)
  MT.Pixel3 = o
end

-- When chat input is on, there is a box that represents the input area where the user types in.
-- In the Autohotkey script we could check for an exact RGB value in the edge of this chat input
-- image. However since each user can have the chat displayed in a different location, we find
-- out the coordinates of the pixel we want to test within the Rift addon (this). We then encode
-- the coordinates in the RGB values of two pixels that are displayed in the top left of the
-- screen. The Autohotkey script reads the pixel's RGB values to retrieve the coordinates. From
-- there on the Autohotkey script is able to tell if the user has chat input currently active.

function MT.GetChatConsole1Coords()
  -- Get coordinates of a pixel in the inner edge. The outer edge's RGB values are not constant
  -- (likely due to the bloom effects in the background scenery).
  local x, y = UNC:GetLeft() + 50, UNC:GetBottom() - 5
  return x, y
end

function MT.SlashCommand()
  local chat_x, chat_y = MT.GetChatConsole1Coords()
  print("Mouse Look Toggle v" .. addon.toc.Version .. " (chat_x = " .. chat_x .. " chat_y = " .. chat_y .. ")")
end

function MT.ChatCoordsToPixelsOhDear()
  local x, y = MT.GetChatConsole1Coords()
  local x_h, x_l, y_h, y_l

  x_h = math.floor( x / 100 )
  x_l = math.fmod( x, 100 )
  y_h = math.floor( y / 100 )
  y_l = math.fmod( y, 100 )

  MT.Pixel2:SetBackgroundColor(0, x_h / 255, x_l / 255)
  MT.Pixel3:SetBackgroundColor(0, y_h / 255, y_l / 255)

  MT.DebugMsg("Mouse Look Pixels: " .. x_h .. ":" .. x_l .. " , " .. y_h .. ":" .. y_l)
end

function UNC.Event:Move()
  MT.ChatCoordsToPixelsOhDear()
end

function UNC.Event:Size()
  MT.ChatCoordsToPixelsOhDear()
end

function MT.Initialize()
  -- local i, v
  -- for i, v in ipairs(RIFT_UI_TO_WATCH) do
  --   IsUiOpen[v] = false
  -- end

  -- Create pixels that are displayed in a corner to communicate with the Autohotkey script
  MT.CreatePixels()

  -- Set up Loaded() events for UIs that should disable Mouse Look mode when they are opened
  for i,windowId in ipairs(RIFT_UI_TO_WATCH) do
    UI.Native[windowId]:EventAttach(Event.UI.Native.Loaded, function(self, h)
      local isLoaded = UI.Native[windowId]:GetLoaded()
      MT.DebugMsg("UI.Native." .. windowId .. ":Loaded() " .. (isLoaded and "1" or "0"))
      MT.SetUiStatus(windowId, isLoaded)
      local isAnyUiLoaded = MT.CheckForOpenUi()
      MT.Pixel:SetVisible(isAnyUiLoaded)
    end, "Event.UI.Native.Loaded")
  end

  Command.Event.Attach(Command.Slash.Register("mouselooktoggle"), MT.SlashCommand, "MT.SlashCommand")
end

MT.Initialize()

print(string.format("v%s loaded.", addon.toc.Version))

