;
; "Mouse Look Toggle" for Rift MMO -- version 1.0
;
; See website for documentation & installation:
;
; http://fabd.github.io/rift-mouselook-addon/
;
#NoEnv
#SingleInstance force

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
debugging        := False
debug_log        := A_Desktop . "\MouseLookToggle_log.txt"

; Misc initialization (don't change these)
mouselook        := False
gameWindowId     := 0
iTimerBefore     := 0

Menu, Tray, Add, GO TO ADDON WEBSITE, CheckForUpdates

Hotkey,IfWinActive,ahk_class TWNClientFramework
Hotkey,%Toggle_key%,ToggleMouseLook, UseErrorLevel 2
Hotkey,%Interract_Key%,InterractKey, UseErrorLevel 2

; ~ allows the hotkey to fire without blocking the original keypress
Hotkey,~%Escape_Key%,EscapeKey, UseErrorLevel 2

; This improves Interract Key handling a little bit
SendMode Input

; Log file helps debugging
if (Debugging && FileExist(debug_log))
	FileDelete, %debug_log%

; Poll at regular intervals for a single pixel in a corner of the screen (set by the Addon)
; which cues us that a Rift UI is open that may require mouse/keyboard input, and thus we
; should turn off Mouse Look.
SetTimer,PollForRiftUi,100

Return

#IfWinActive ahk_class TWNClientFramework

ToggleMouseLook:
if (RiftUiIsOpen() || ChatIsOpen())
{
	; whether we use TAB or another key for mouse look toggle, we want it to work in chat
	; as well as in Rift UI which use input fields (such as the Auction house "Search")
	Send {%Toggle_key%}
	return
}

if MouseLook
	ReleaseMlook()
else
{
	MouseLook := True
	DllCall("SetCursorPos", int, (A_ScreenWidth/2-4) , int, (A_ScreenHeight/2))
	Send {RButton down}
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

If (RiftUiIsOpen() || ChatIsOpen())
{
	; if chat or other Rift UI with text input is active, send the key as is
	Send {%Interract_Key%}
	Return
}

Click right
Return

; The Escape also toggles off Mouse Look. This is partly for user-friendliness, and partly
; because it solves not being able to detect the main menu (the Escape menu) in the Addon.
EscapeKey:
ReleaseMlook()
Return

; Release the Right Mouse Button when switching focus away from the game window
~!TAB::
~^!DEL::
ReleaseMlook()
Return
~LWin::
ReleaseMlook()
Send, {LWin}
Return
~RWin::
ReleaseMlook()
Send, {RWin}
Return

; Global On/Off toggle for the script
f12::
Suspend
ReleaseMlook()
Return

; Control Shift Left Mouse Button to debug the script (this block can safely be removed from the script)
$^+LButton::
if Debugging
{
	pix1rgb  := PixelColorSimple(1, 0)
	pix2rgb  := PixelColorSimple(2, 0)
	chat_x := ((pix1rgb & 0xFF00) >> 8) * 100 + (pix1rgb & 0xFF)
	chat_y := ((pix2rgb & 0xFF00) >> 8) * 100 + (pix2rgb & 0xFF)
	; MsgBox Coords received from Rift : %chat_x%, %chat_y%
	ToolTip, % "Coords received from Rift: " chat_x ", " chat_y
	SetTimer, RemoveToolTip, 5000
}
Return
RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
Return

#If WinActive("ahk_class TWNClientFramework") && MouseLook

; Map the LMB to Action Bar while Mouse Look is active
$LButton::Send {%Left_Click_Key%}

; Map Shift + LMB to Action Bar while Mouse Look is active
$+LButton::Send {%Shift_Left_Click_Key%}

; Map RMB to something while Mouse Look is active
$RButton::Send {%Right_Click_Key%}

; Map Shift + RMB to something while Mouse Look is active
$+RButton::Send {%Shift_Right_Click_Key%}

; Alt key binds
;$!LButton::Send {%Alt_Left_Click_Key%}
;$!RButton::Send {%Alt_Right_Click_Key%}

$WheelUp::Send, {%Mouse_Wheel_Up%}
$WheelDown::Send, {%Mouse_Wheel_Down%}

ReleaseMlook()
{
	global mouselook
	if MouseLook
	{
		;SoundBeep,,50
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
Return

; Check pixel set by Rift Addon that tells us if a Rift UI needs keyboard input.
RiftUiIsOpen()
{
	return PixelColorSimple(0,0) == 0xff0000
}

; Check whether Rift Chat Window currently has the keyboard focus.
ChatIsOpen()
{
	static saved_chat := False, s_chat_x, s_chat_y
	local  chat_x, chat_y
	
	;TimerStart()
	
	; Check a few pixels of 100% opaque color (ie. no transparency) along a light gray border
	; near the bottom of the chat input area. This background is only active when the user is
	; typing in the chat window. Rift does not allow custom skinning of the native UI so
	; hopefully this pixel check works reliably for all users. It will need updating if
	; the chat window graphics are updated.
	
	if (!saved_chat)
	{
		; In order to make the script adapt to the user's UI, instead of using fixed coordinates
		; we receive them from the in game Addon. The Addon encodes coordinates of the chat window
		; in a few pixels' RGB values. ... o_O
		
		local pix1rgb  := PixelColorSimple(1, 0)
		local pix2rgb  := PixelColorSimple(2, 0)
		chat_x := ((pix1rgb & 0xFF00) >> 8) * 100 + (pix1rgb & 0xFF)
		chat_y := ((pix2rgb & 0xFF00) >> 8) * 100 + (pix2rgb & 0xFF)
		
		; If chat coordinates can't be received from the Rift Addon for whatever reason,
		; type /mouselooktoggle ingame to get the coordinates and edit them below. As long as the
		; chat window is not moved, it will continue to work. If switching between characters
		; you may want to use /exportui and /importui to make sure the chat window coordinates
		; are identical between characters.
		;
		;chat_x := 57
		;chat_y := 1372
	}
	else
	{
		; Additionally, save the chat coordinates the first time chat input is recognized. This
		; removes the occasional glitches where shaders or weather effects affect the pixels
		; and the chat is not properly detected (ie. snow in Iron Pine Peaks).
		
		chat_x := s_chat_x, chat_y := s_chat_y
	}
	
	ItsOpen := (PixelColorSimple(chat_x, chat_y) == 0x3b3a3b)
	&& (PixelColorSimple(chat_x+2, chat_y) == 0x3b3a3b)
	&& (PixelColorSimple(chat_x+4, chat_y) == 0x3b3a3b)
	
	if (ItsOpen && !saved_chat)
	{
		saved_chat := True, s_chat_x := chat_x, s_chat_y := chat_y
		;SoundBeep,,50
	}
	
	;TimerEnd("ChatIsOpen()")
	
	return ItsOpen
}

TimerStart()
{
	global debugging, iTimerBefore
	if !debugging
		Return
	iTimerBefore := A_TickCount
}

TimerEnd(msg)
{
	global debugging, debug_log, iTimerBefore
	static iTimerSamples = 0, iTimerTotal = 0
	
	if !debugging
		Return
	
	iTimerElapsed := A_TickCount - iTimerBefore
	iTimerTotal   += iTimerElapsed
	iTimerSamples++
	iTimerAverage := Floor(iTimerTotal / iTimerSamples)
	
	s := msg . " " . iTimerElapsed . "ms (" . iTimerAverage . "ms avg)"
	FileAppend, %s%`n, %debug_log%
}

; Return unique ID of the game window.
GetGameWindowId()
{
	static gameWindowId = 0
	if !gameWindowId
	{
		gameWindowId := WinExist("ahk_class TWNClientFramework")
		if !gameWindowId
		{
			MsgBox "GetGameWindowId() could not find game window."
			exit
		}
	}
	return gameWindowId
}

; This is MUCH faster than PixelGetColor() because it works on the game window rather
; than the full desktop. The builtin function in Autohotkey is very slow in Windows 7
; and causes a frame rate drop because it has to go through desktop composition.
;
; Source: http://www.autohotkey.com/board/topic/38414-pixelcolorx-y-window-transp-off-screen-etc-windows/#entry242401
;
PixelColorSimple(pc_x, pc_y)
{
	pc_wID := GetGameWindowId()
	
	pc_hDC := DllCall("GetDC", "UInt", pc_wID)
	pc_fmtI := A_FormatInteger
	SetFormat, IntegerFast, Hex
	pc_c := DllCall("GetPixel", "UInt", pc_hDC, "Int", pc_x, "Int", pc_y, "UInt")
	pc_c := pc_c >> 16 & 0xff | pc_c & 0xff00 | (pc_c & 0xff) << 16
	pc_c .= ""
	SetFormat, IntegerFast, %pc_fmtI%
	DllCall("ReleaseDC", "UInt", pc_wID, "UInt", pc_hDC)
	return pc_c
}

CheckForUpdates:
Run, http://fabd.github.io/rift-mouselook-addon/
Return