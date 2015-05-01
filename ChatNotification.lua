-----------------------------------------------------------------------------------------------
-- Client Lua Script for ChatNotification
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
require "Apollo"
require "GameLib"
require "ChatSystemLib"
require "ChatChannelLib"
require "Sound"
 
-----------------------------------------------------------------------------------------------
-- ChatNotification Module Definition
-----------------------------------------------------------------------------------------------
local ChatNotification = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------

local iLastMessage = 0;
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function ChatNotification:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 
	
    -- initialize variables here

    return o
end

function ChatNotification:Init()
	local bHasConfigureFunction = true
	local strConfigureButtonText = "Chat Notifications"
	local tDependencies = {
		-- "UnitOrPackageName",
	}
	
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- ChatNotification OnLoad
-----------------------------------------------------------------------------------------------
function ChatNotification:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("ChatNotification.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
	Apollo.RegisterEventHandler("ChatMessage", "OnChatMessage", self)
end

-----------------------------------------------------------------------------------------------
-- ChatNotification OnDocLoaded
-----------------------------------------------------------------------------------------------
function ChatNotification:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "ChatNotificationForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("chatnotification", "OnChatNotificationOn", self)

		self.timer = ApolloTimer.Create(1.0, true, "OnTimer", self)

		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- ChatNotification Events
-----------------------------------------------------------------------------------------------

function ChatNotification:OnChatMessage(channelSource, tMessage)
	vType = channelSource:GetType()
	
	if vType == nil then return end
	if tMessage.bSelf then iLastMessage = os.time() return end
	if vType == ChatSystemLib.ChatChannel_Guild and (os.time() - iLastMessage) > 10 then
		Sound.Play(Sound.PlayUIWIndowMetalClose)
		iLastMessage = os.time()
	end
end

-----------------------------------------------------------------------------------------------
-- ChatNotification Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/chatnotification"
function ChatNotification:OnChatNotificationOn()
	-- self.wndMain:Invoke() -- show the window
end

-- on timer
function ChatNotification:OnTimer()
	-- Do your timer-related stuff here.
end


-----------------------------------------------------------------------------------------------
-- ChatNotificationForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function ChatNotification:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function ChatNotification:OnCancel()
	local drPlayer = GameLib.GetPlayerUnit()
	local strName = drPlayer:GetName()
	
	Print("Hello, "..strName)
	
	
	self.wndMain:Close() -- hide the window
end

-----------------------------------------------------------------------------------------------
-- ChatNotification Instance
-----------------------------------------------------------------------------------------------
local ChatNotificationInst = ChatNotification:new()
ChatNotificationInst:Init()