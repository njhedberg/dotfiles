-- Xmonad config

import XMonad
import System.Exit
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO
import Control.Monad
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Actions.WindowBringer
import XMonad.Actions.GridSelect
import XMonad.Util.Dmenu

import qualified XMonad.StackSet as W
import qualified Data.Map as M

-- -- The default number of workspaces (virtual screens) and their names.
-- -- By default we use numeric strings, but any string may be used as a
-- -- workspace name. The number of workspaces is determined by the length
-- -- of this list.
-- --
-- -- A tagging example:
-- --
-- -- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
-- --
myWorkspaces =
    ["1:term", "2:web", "3:mail", "4:dev"] ++ map show [5..8] ++ ["9:vm"]

------------------------------------------------------------------------
-- Custom key bindings
--
myKeys =
    --
    -- New key bindings
    --
    -- Go to the window
    [ ((mod4Mask .|. shiftMask, xK_g), gotoMenu)
    -- Bring the window
    , ((mod4Mask .|. shiftMask, xK_b), bringMenu)
    -- Display opened windows in a grid
    , ((mod4Mask, xK_g), goToSelected defaultGSConfig)
    -- Lock the screen
    , ((mod4Mask .|. shiftMask, xK_l), spawn "xscreensaver-command -lock")
    -- Close focused window with one hand in Dvorak
    , ((mod4Mask .|. shiftMask, xK_o), kill)
    -- Print screen
    , ((0, xK_Print), spawn "scrot")
    -- XF86AudioMute
    , ((0, 0x1008ff12), spawn "amixer -c 0 set Master toggle")
    -- XF86AudioLowerVolume
    , ((0, 0x1008ff11), spawn "amixer -c 0 set Master 2dB-")
    -- XF86AudioRaiseVolume
    , ((0, 0x1008ff13), spawn "amixer -c 0 set Master 2dB+")
    --
    -- TypeMatrix special keys
    --
    -- Web browser
    , ((0, 0x1008ff18), spawn "firefox")
    -- Email
    , ((0, 0x1008ff19), spawn "thunderbird")
    -- Calculator
    , ((0, 0x1008ff1d), spawn "gcalctool")
    --
    -- Override default behavior
    --
    -- Launch dmenu with custom appearance
    , ((mod4Mask, xK_p), spawn "dmenu_run.sh")
    -- Quit xmonad
    , ((mod4Mask .|. shiftMask, xK_q), confirm "Exit?" $ io (exitWith ExitSuccess))
    -- Restart xmonad
    , ((mod4Mask, xK_q), confirm "Restart?" $ spawn "xmonad --recompile; xmonad --restart")
    ]

confirm :: String -> X () -> X ()
confirm msg f = do
    result <- menuArgs "dmenu" ["-p", msg] ["no", "yes"]
    when (result == "yes") f

------------------------------------------------------------------------
---- Layouts:
-- 
-- -- You can specify and transform your layouts by modifying these values.
-- -- If you change layout bindings be sure to use 'mod-shift-space' after
-- -- restarting (with 'mod-q') to reset your layout state to the new
-- -- defaults, as xmonad preserves your old layout settings by default.
-- --
-- -- * NOTE: XMonad.Hooks.EwmhDesktops users must remove the obsolete
-- -- ewmhDesktopsLayout modifier from layoutHook. It no longer exists.
-- -- Instead use the 'ewmh' function from that module to modify your
-- -- defaultConfig as a whole. (See also logHook, handleEventHook, and
-- -- startupHook ewmh notes.)
-- --
-- -- The available layouts.  Note that each layout is separated by |||,
-- -- which denotes layout choice.
-- --
myLayout = avoidStruts (
    tiled |||
    Mirror tiled |||
    tabbed shrinkText tabConfig |||
    Full |||
    spiral (6/7)) |||
    noBorders (fullscreenFull Full)
         where tiled = Tall 1 (3/100) (1/2)

tabConfig = defaultTheme {
    activeBorderColor = "grey",
    activeTextColor = "green",
    activeColor = "black",
    inactiveBorderColor = "grey",
    inactiveTextColor = "grey",
    inactiveColor = "black"
}

------------------------------------------------------------------------
---- Window rules:
-- 
-- -- Execute arbitrary actions and WindowSet manipulations when managing
-- -- a new window. You can use this to, for example, always float a
-- -- particular program, or have a client always appear on a particular
-- -- workspace.
-- --
-- -- To find the property name associated with a program, use
-- -- > xprop | grep WM_CLASS
-- -- and click on the client you're interested in.
-- --
-- -- To match on the WM_NAME, you can use 'title' in the same way that
-- -- 'className' and 'resource' are used below.
-- --
myManageHook = composeAll
    [ className =? "Gimp"          --> doFloat
    , className =? "Vncviewer"     --> doFloat
    , className =? "Firefox"       --> doShift "2:web"
    , className =? "Thunderbird"   --> doShift "3:mail"
    , className =? "Pidgin"        --> doShift "3:mail"
    , className =? "VirtualBox"    --> doShift "9:vm"
    , className =? "Xfce4-notifyd" --> doIgnore -- Prevent to steal the focus.
    ]

main = do
    xmproc <- spawnPipe "xmobar ~/.xmonad/xmobarrc"
    xmonad $ defaultConfig
        { manageHook = manageDocks <+> myManageHook
                        <+> manageHook defaultConfig
        , logHook = dynamicLogWithPP $ xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        , modMask = mod4Mask -- Use Super instead of Alt
        , terminal = "urxvt"
        , workspaces = myWorkspaces
        , layoutHook = smartBorders $ myLayout
        } `additionalKeys` myKeys
