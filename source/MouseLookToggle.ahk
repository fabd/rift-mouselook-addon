;
; "Mouse Look Toggle" for Rift MMO -- version 1.0
;
; See website for documentation & installation:
;
; http://fabd.github.io/rift-mouselook-addon/
;
#NoEnv
#SingleInstance Force

; Mouse Look Toggle key (default: Tab)
Toggle_key             = Tab

; Interract key (use in place of a right click when Mouse Look is active) (default: f)
Interract_Key          = f

; THIS SHOULD NOT CHANGE (see EscapeKey code below for more info) (default: Esc)
Escape_Key             = Esc

; Additional mouse hotkeys available while Mouse Look is active (defaults: Numpad1 - Numpad9)
Shift_Left_Click_Key   = Numpad7
Shift_Right_Click_Key  = Numpad9
Left_Click_Key         = Numpad4
Right_Click_Key        = Numpad6
;Alt_Left_Click_Key     = !Numpad1
;Alt_Right_Click_Key    = !Numpad3
Mouse_Wheel_Up         = Numpad8
Mouse_Wheel_Down       = Numpad5

; Enable/disable debugging
Debugging        := False
DebugLog         := A_Desktop . "\MouseLookToggle_log.txt"

; Misc initialization (don't change these)
MouseLook        := False
GameWindowID     := 0
iTimerBefore     := 0

Menu, Tray, Add, GO TO ADDON WEBSITE, CheckForUpdates

Hotkey, IfWinActive, ahk_class TWNClientFramework
Hotkey, %Toggle_key%, ToggleMouseLook, UseErrorLevel 2
Hotkey, %Interract_Key%, InterractKey, UseErrorLevel 2

; ~ allows the hotkey to fire without blocking the original keypress
Hotkey, ~%Escape_Key%, EscapeKey, UseErrorLevel 2

; This improves Interract Key handling a little bit
SendMode, Input

; Log file helps debugging
if (Debugging && FileExist(DebugLog))
	FileDelete, %DebugLog%

; Poll at regular intervals for a single pixel in a corner of the screen (set by the Addon)
; which cues us that a Rift UI is open that may require mouse/keyboard input, and thus we
; should turn off Mouse Look.
SetTimer, PollForRiftUi, 100

return

#IfWinActive ahk_class TWNClientFramework

ToggleMouseLook:
if (RiftUiIsOpen() || ChatIsOpen())
{
	; whether we use TAB or another key for mouse look toggle, we want it to work in chat
	; as well as in Rift UI which use input fields (such as the Auction house "Search")
	Send, {%Toggle_key%}
	return
}

if MouseLook
	ReleaseMlook()
else
{
	MouseLook := True
	DllCall("SetCursorPos", int, (A_ScreenWidth/2-4) , int, (A_ScreenHeight/2))
	Send, {RButton Down}
	Sleep, 100
}
return

; The Interract hotkey sends a right click in the middle of the view. This allows the user
; to interract with NPCs, harvest nodes, etc without having to toggle off Mouse Look first.
InterractKey:
if MouseLook
{
	ReleaseMlook()
	Sleep, 100 ; wait a bit otherwise camera may turn to a nearby target
}

if (RiftUiIsOpen() || ChatIsOpen())
{
	; if chat or other Rift UI with text input is active, send the key as is
	Send, {%Interract_Key%}
	return
}

Click Right
return

; The Escape also toggles off Mouse Look. This is partly for user-friendliness, and partly
; because it solves not being able to detect the main menu (the Escape menu) in the Addon.
EscapeKey:
ReleaseMlook()
return

; Release the Right Mouse Button when switching focus away from the game window
~!TAB::
~^!DEL::
ReleaseMlook()
return
~LWin::
ReleaseMlook()
Send, {LWin}
return
~RWin::
ReleaseMlook()
Send, {RWin}
return

; Global On/Off toggle for the script
f12::
Suspend
ReleaseMlook()
return

; Control Shift Left Mouse Button to debug the script (this block can safely be removed from the script)
$^+LButton::
if Debugging
{
	Pix1RGB := PixelColorSimple(1, 0)
	Pix2RGB  := PixelColorSimple(2, 0)
	ChatX := ((Pix1RGB & 0xFF00) >> 8) * 100 + (Pix1RGB & 0xFF)
	ChatY := ((Pix2RGB & 0xFF00) >> 8) * 100 + (Pix2RGB & 0xFF)
	; MsgBox Coords received from Rift: %ChatX%, %ChatY%
	ToolTip, % "Coords received from Rift: " ChatX ", " ChatY
	SetTimer, RemoveToolTip, 5000
}
return
RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
return

#If WinActive("ahk_class TWNClientFramework") && MouseLook

; Map the LMB to Action Bar while Mouse Look is active
$LButton::Send, {%Left_Click_Key%}

; Map Shift + LMB to Action Bar while Mouse Look is active
$+LButton::Send, {%Shift_Left_Click_Key%}

; Map RMB to something while Mouse Look is active
$RButton::Send, {%Right_Click_Key%}

; Map Shift + RMB to something while Mouse Look is active
$+RButton::Send, {%Shift_Right_Click_Key%}

; Alt key binds
;$!LButton::Send, {%Alt_Left_Click_Key%}
;$!RButton::Send, {%Alt_Right_Click_Key%}

$WheelUp::Send, {%Mouse_Wheel_Up%}
$WheelDown::Send, {%Mouse_Wheel_Down%}

ReleaseMlook()
{
	global mouselook
	if MouseLook
	{
		;SoundBeep,, 50
		MouseLook := False
		Send, {RButton UP}
	}
}

; Check if a Rift UI Window is open and if so, release Mouse Look.
PollForRiftUi:
if (MouseLook && RiftUiIsOpen())
{
	ReleaseMlook()
}
return

; Check pixel set by Rift Addon that tells us if a Rift UI needs keyboard input.
RiftUiIsOpen()
{
	return PixelColorSimple(0, 0) == 0xff0000
}

; Check whether Rift Chat Window currently has the keyboard focus.
ChatIsOpen()
{
	static SavedChat := False, SavedChatX, SavedChatY
	local  ChatX, ChatY
	
	;TimerStart()
	
	; Check a few pixels of 100% opaque color (ie. no transparency) along a light gray border
	; near the bottom of the chat input area. This background is only active when the user is
	; typing in the chat window. Rift does not allow custom skinning of the native UI so
	; hopefully this pixel check works reliably for all users. It will need updating if
	; the chat window graphics are updated.
	
	if (!SavedChat)
	{
		; In order to make the script adapt to the user's UI, instead of using fixed coordinates
		; we receive them from the in game Addon. The Addon encodes coordinates of the chat window
		; in a few pixels' RGB values. ... o_O
		
		local Pix1RGB := PixelColorSimple(1, 0)
		local Pix2RGB := PixelColorSimple(2, 0)
		ChatX := ((Pix1RGB & 0xFF00) >> 8) * 100 + (Pix1RGB & 0xFF)
		ChatY := ((Pix2RGB & 0xFF00) >> 8) * 100 + (Pix2RGB & 0xFF)
		
		; If chat coordinates can't be received from the Rift Addon for whatever reason,
		; type /mouselooktoggle ingame to get the coordinates and edit them below. As long as the
		; chat window is not moved, it will continue to work. If switching between characters
		; you may want to use /exportui and /importui to make sure the chat window coordinates
		; are identical between characters.
		;
		;ChatX := 57
		;ChatY := 1372
	}
	else
	{
		; Additionally, save the chat coordinates the first time chat input is recognized. This
		; removes the occasional glitches where shaders or weather effects affect the pixels
		; and the chat is not properly detected (ie. snow in Iron Pine Peaks).
		
		ChatX := SavedChatX
		ChatY := SavedChatY
	}
	
	ItsOpen := (PixelColorSimple(ChatX, ChatY) == 0x3b3a3b)
	&& (PixelColorSimple(ChatX+2, ChatY) == 0x3b3a3b)
	&& (PixelColorSimple(ChatX+4, ChatY) == 0x3b3a3b)
	
	if (ItsOpen && !saved_chat)
	{
		SavedChat := True
		SavedChatX := ChatX
		SavedChatY := ChatY
		;SoundBeep,, 50
	}
	
	;TimerEnd("ChatIsOpen()")
	
	return ItsOpen
}

TimerStart()
{
	global Debugging, iTimerBefore
	if !Debugging
		return
	iTimerBefore := A_TickCount
}

TimerEnd(msg)
{
	global Debugging, DebugLog, iTimerBefore
	static iTimerSamples = 0, iTimerTotal = 0
	
	if !Debugging
		return
	
	iTimerElapsed := A_TickCount - iTimerBefore
	iTimerTotal   += iTimerElapsed
	iTimerSamples++
	iTimerAverage := Floor(iTimerTotal / iTimerSamples)
	
	s := msg . " " . iTimerElapsed . "ms (" . iTimerAverage . "ms avg)"
	FileAppend, %s%`n, %DebugLog%
}

; Return unique ID of the game window.
GetGameWindowID()
{
	static GameWindowID := 0
	if !GameWindowID
	{
		GameWindowID := WinExist("ahk_class TWNClientFramework")
		if !GameWindowID
		{
			MsgBox, "GetGameWindowID() could not find game window."
			exit
		}
	}
	return GameWindowID
}

; This is MUCH faster than PixelGetColor() because it works on the game window rather
; than the full desktop. The builtin function in Autohotkey is very slow in Windows 7
; and causes a frame rate drop because it has to go through desktop composition.
;
; Source: http://www.autohotkey.com/board/topic/38414-pixelcolorx-y-window-transp-off-screen-etc-windows/#entry242401
;
PixelColorSimple(x, y)
{
	hWnd := GetGameWindowID()
	
	hDC := DllCall("GetDC", "UInt", hWnd)
	FmtI := A_FormatInteger
	SetFormat, IntegerFast, Hex
	c := DllCall("GetPixel", "UInt", hDC, "Int", x, "Int", y, "UInt")
	c := c >> 16 & 0xff | c & 0xff00 | (c & 0xff) << 16
	c .= ""
	SetFormat, IntegerFast, %FmtI%
	DllCall("ReleaseDC", "UInt", hWnd, "UInt", hDC)
	return c
}

CheckForUpdates:
Run, http://fabd.github.io/rift-mouselook-addon/
return