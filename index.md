---
layout: default
---

### What Does It Do ?

**Mouse Look Toggle** lets you rotate the camera and turn your character without having
to hold down the right mouse button all the time. Besides being more comfortable to play,
it frees the mouse buttons to activate skills on your Action Bars.

### Features

* Adds **Mouse Look Toggle key** to switch the Mouse Look feature on and off.
* Adds **Interract key** to activate things directly in front of your character
  while Mouse Look is active (much like the <kbd>E</kbd> key does in Skyrim)
* Additional **Mouse Button key binds** to activate skills when Mouse Look is active.
* Additional **Mouse Wheel key binds** to activate skills when Mouse Look is active.
* **Seamless integration** (where possible): automatically turns off Mouse Look when opening
  ingame windows like Auction, Mail, etc.

### Controls

The following key binds are set by default in the script. 

| <kbd>TAB</kbd> | <strong>Toggle Mouse Look</strong> |
| <kbd>F</kbd>   | <strong>Interract</strong> <span class="note">You can use this to interract with NPCs, harvest nodes, etc. When Mouse Look is active, it will right click in the center of the view so try to aim the camera towards the object (usually somewhere near the head of your character in 3rd person view).</span> |

<span class="note">NOTE : the script tries to recognize when the user is typing in chat
and allows the controls above to pass through. Thus you should be able to press <kbd>TAB</kbd> in the chat window
to expand slash commands (eg. /lau => /laugh) and also enter the letter F in chat and other input areas.</span>

Additional keys triggered by mouse buttons (set these in game to your Action Bars).

| Shift Left Click    | <kbd>Numpad7</kbd>  |
| Shift Right Click   | <kbd>Numpad9</kbd>  |
| Left Click          | <kbd>Numpad4</kbd>  |
| Right Click         | <kbd>Numpad6</kbd>  |
| Scroll Wheel Up     | <kbd>Numpad8</kbd>  |
| Scroll Wheel Down   | <kbd>Numpad5</kbd>  |

<span class="note">If you already use the Numpad keys, you can change these in the `.ahk` script.</span>

<span class="note">To zoom the camera while Mouse Look is active, use <kbd>Shift</kbd> + Mouse Wheel.</span>



### Installation

1. Download the archive and extract into the Rift Addons folder. There should be a "MouseLookToggle" folder
  alongside your other Addons.

2. [Download and install Autohotkey](http://www.autohotkey.com/).

3. Double click the `MouseLookToggle.ahk` file to run the Autohotkey script. <span class="note">A little "H" icon should show
  up in the tray bar. The Autohotkey script will only work within the active Rift game window. If you exit
  and restart the game, right click the Autohotkey icon in the tray and select "Reload This Script" to make
  sure it works properly.</span>
  
4. Enable the "Mouse Look Toggle" Addon within Rift (this needs to be done only once).

Set up the following options in game:

* Bind **Target Next Enemy** or **Target Nearest Enemy** (recommended) to another key than <kbd>TAB</kbd>.
  <span class="note">The TAB key is used to toggle Mouse Look (unless you edit the script). Suggestion: unbind <kbd>X</kbd>
  ("dive") or <kbd>V</kbd> ("look behind") and bind it to *Target Nearest Enemy*.</span>

* Bind **Select Target of Target** to another key than <kbd>F</kbd>.
  <span class="note">Alternatively, edit `Interract_Key` in the
  script to <kbd>e</kbd> and unbind **Strafe Right** in the key bindings, for a setup similar to Skyrim.
  (Strafe Left/Right keys are not necessary with Mouse Look mode).</span>

**Hint** Type <code>/exportkeybindings</code> in the chat window to save your key configuration,
log into another character and then type <code>/importkeybindings</code> (assuming you want
to use the same hotkeys across all your characters).


### Recommended In Game Settings

* **Interface > Misc > Auto-Loot By Default**<br/>
  <span class="note">Essential, lets you loot creatures with the *Interract* key without having to toggle Mouse Look!</span>

* **Interface > Combat > Target Nearest in Front of Player**<br/>
  <span class="note">Along with *Target Nearest Enemy* key bind, this is the easiest mode to switch target in Mouse Look mode.</span>

* **Interface > Combat > Smart Target**<br/>
  <span class="note">Automatically pick a near target when using a skill.</span>


### Testing that the Addon works properly

1. Double check that both the Autohotkey script and the ingame Addon are active.
2. Place the mouse cursor over a Mail box or NPC and press the *Interract* key : the Mail or NPC should activate.
3. Again place the mouse cursor over a Mail box or NPC. Now, **without moving the mouse cursor** type Enter to start
   typing in chat and try both the *Interract* and *Mouse Look Toggle* keys. Both keys should function as expected
   in chat (eg. TAB should auto-complete slash commands). The *Interract* key should NOT activate whatever the mouse
   is pointing to while typing in chat.


### Known Limitations

* **Moving the Chat Window** (or changing the resolution in Video settings): the Chat window
  UI is no longer recognized by the script and the Mouse Look / Interract keys won't work
  properly in chat. To fix this, restart the Autohotkey script (right click in the tray and
  select "Reload this script").<br/>
  <br/>
  When frequently switching between characters to make it less of hassle you may want to use
  `/exportui` and `/importui` to make sure each of your characters has the Chat Window UI at
  the exact same location (the horizontal size can change, but not vertical).

* Not all ingame UI are recognized yet. It may not be possible for the Addon to recognize the Rift
  Store. If you are unable to use the `Interract` and `Mouse Look Toggle` keys in some of the
  unrecognized windows, open one that is recognized such as "Abilities". When one of the recognized
  windows is active, the Interract key and Mouse Look Toggle key should work as expected in the
  input fields.

* The script does not work properly in Fullscreen mode. Use Windowed Fullscreen mode instead, or Windowed.

* Shaders / Filters (like SweetFX): if the shader changes the colours (for example Vignette or
  Vibrance options) it will prevent the script from working correctly. Anti-aliasing filters like
  SMAA should work fine.

* The Addon communicates with the Autohotkey script by setting a few pixels in a corner of the game
  window. These pixels do not appear in screenshots if you hide the UI.


### Thanks

Mouse Look Toggle for Rift is inspired by [pvpproject's Combat Mode 1.1](http://www.reddit.com/r/Guildwars2/comments/10s4s6/combat_mode_11/) script which
provides similar functionality for Guild Wars 2.


### F.A.Q

**Is it safe to use Autohotkey?**

While Autohotkey has [many legitimate uses](http://lifehacker.com/5598693/the-best-time-saving-autohotkey-tricks-you-should-be-using) it is also being used to create "bots" in various games, including Rift. A "fishing bot" script apparently made the rounds a couple years ago and it appears that Trion World implemented rather crude detection of the Autohotkey as a result.

[Quoting January 9th 2013 Patch Notes:](http://forums.riftgame.com/general-discussions/patch-notes/347356-rift-2-1-hotfix-2-8-00am-pst-1-9-13-na-2-00am-gmt-10-1-13-eu.html) "That said, some folks do innocently use keyboard-assistance software while they’re at their computer." (...) "for the next week or two, until the bot situation gets back under control, use of this software may intentionally be randomly unreliable, up to causing random disconnects."

**This was in January 2013**. A Google search of Autohotkey on the Rift forums doesn't show up any recent posts relating to bans for legitimate uses of Autohotkey. Obviously if pressed, the developers and customer service are going to say something along the lines that "use of unauthorized third-party software is not allowed".

If you are still worried about using Autohotkey you can compile the script. Simply look for the `ahk2exe`program in your Autohotkey installation folder, it is very easy to use. This will create a new, completely standalone executable that can be run without Autohotkey.

