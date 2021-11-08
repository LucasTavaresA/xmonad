  -- Base
import XMonad
import System.Exit
import qualified XMonad.StackSet as W

    -- Datas
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.EwmhDesktops  -- para alguns eventos em tela cheia e alguns compositores do obs
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks

   -- Utilidades
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce

-- myTerminal alias
myTerminal = "alacritty"

-- alias para caso o foco siga o mouse ou não
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

-- alias para caso clicar em uma janela para focar também passar o clique ou não
myClickJustFocuses :: Bool
myClickJustFocuses = True

-- tamanho das bordas das janelas em pixels
myBorderWidth   = 1

-- modMasks deixam você especificar qual teclaMod você quer usar.
-- O padrão é mod1Mask ("tecla alt esquerda")
-- mod3Mask ("alt direita"), não entra em conflito com as teclas de atalho do emacs
-- mod4Mask é a ("tecla do windows").
myModMask       = mod4Mask

-- a quantidade padrão de workspaces e seus nome ou números
-- por padrão é usado números mais você pode usar strings com nomes
-- o número de workspaces é determinado pelo tamanho desta lista
--
-- exemplo:
-- myWorkspaces = ["web", "vídeos", "edição", "jogos"]
--
myWorkspaces    = ["1","2","3"]

-- Cor das bordas para janelas com ou sem foco respectivamente
myFocusedBorderColor = "#0000FF" -- com foco
myNormalBorderColor  = "#000000" -- sem foco


------------------------------------------------------------------------
-- Teclas de atalho. Adicione, modifique ou as remova aqui.
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- abre o terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    
    -- abre o rofi
    , ((modm,               xK_p     ), spawn "rofi -show run -show-icons")
    
    -- abre o firefox
    , ((modm,               xK_f     ), spawn "firefox")

    -- abre o deadbeef
    , ((modm, 				xK_a     ), spawn "deadbeef")

    -- abre o geany
    , ((modm, 				xK_g     ), spawn "geany")

    -- pausa/volta a tocar a musica no deadbeef
    , ((modm .|. shiftMask, xK_a     ), spawn "deadbeef --play-pause")
    
    -- Aumenta o volume
    , ((modm              , xK_period),  spawn "amixer -q set Master 10%+")

    -- Diminui o volume
    , ((modm              , xK_comma ), spawn "amixer -q set Master 10%-")

    -- fecha a janela com foco
    , ((modm .|. shiftMask, xK_c     ), kill)

    -- troca entre os algoritmos de layout disponíveis
    , ((modm,               xK_Tab ), sendMessage NextLayout)

    -- move o foco para a próxima janela
    , ((modm,               xK_j     ), windows W.focusDown)

    -- move o foco para a janela anterior
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- troca a janela com foco pela próxima janela
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- troca a janela com foco pela janela anterior
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- diminui a área da janela mestre
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- expande a área da janela mestre
    , ((modm,               xK_l     ), sendMessage Expand)

    -- puxa uma janela flutuante de volta para o layout
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- ativa e desativa o espaçamento da barra de espaço
    -- use esse atalho tendo importado XMonad.Hooks.ManageDocks
    , ((modm              , xK_space   ), sendMessage ToggleStruts)

    -- Saia do xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Reinicia e tenta recompilar o xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")
    ]
    ++

    -- move entre workspaces 1 a 9 usando mod + numero do workspace
    -- mod-[1..9], troca para workspace N
    -- mod-shift-[1..9], move janela com foco para workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

------------------------------------------------------------------------
-- Teclas atalho do mouse
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1 ("botão direito do mouse"), mod + button1 muda janela para modo flutuante e move arrastando o mouse
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button3 ("botão direito"), mod + button3 Muda a janela para modo flutuante e move arrastando o mouse
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))
    ]

------------------------------------------------------------------------
-- Layouts:
-- você pode especificar e modificar  seus layouts modificando esses valores
-- o xmonad mantêm layouts antigos por padrão então apos modificas-los 
-- lembre-se de sair completamente do xmonad fechando tudo e apertando mod + q
--
-- os layouts disponiveis separados por ||| que denota uma seleção de layouts
myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
     -- layout padrão divide a tela em dois
     tiled   = Tall nmaster delta ratio

     -- o número padrão de janelas na parte esquerda (mestre)
     nmaster = 1

     -- proporção padrão da janelas mestre
     ratio   = 1/2

     -- porcentagem da tela incrementada a cada mudança de tamanho da parte mestre
     delta   = 3/100

------------------------------------------------------------------------
-- regras da janela:
-- executa ações arbitrarias e transforma janelas quando se cria uma nova janela de tipo especifico
-- você usa isso por exemplo para sempre flutuar uma janela de um programa ou uma janela especifica de um programa (um aviso de erro)
-- ou fazer um programa especifico iniciar em um workspace diferente
--
-- para achar o nome proprietario associado a um programa, use o comando
-- > xprop | grep WM_CLASS
-- e clique no cliente que você esta interessado
--
-- "NomeDaAplicação" --> modo
-- doFloat inicia essa aplicação como janela flutuante
-- doCenterFloat centraliza e abre como janela flutuante
-- doFullFloat inicia como flutuante e acima de todos os basicamente em tela cheia
-- doShift inicia em outros workspaces
myManageHook = composeAll
    [ className =? "confirm"         --> doFloat
    , className =? "file_progress"   --> doFloat
    , className =? "dialog"          --> doFloat
    , className =? "download"        --> doFloat
    , className =? "error"           --> doFloat
	, className =? "MPlayer"         --> doFloat
    , className =? "Gimp"            --> doFloat
    , className =? "notification"    --> doFloat
    , className =? "pinentry-gtk-2"  --> doFloat
    , className =? "splash"          --> doFloat
    , className =? "deadbeef"       --> doCenterFloat
    , className =? "toolbar"         --> doFloat
    , className =? "Yad"             --> doCenterFloat
    , className =? "sxiv"             --> doCenterFloat
    , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore 
    , isFullscreen -->  doFullFloat
    ]
    
------------------------------------------------------------------------
-- Hook de inicio
-- executa uma ação arbitraria quando o xmonad inicia ou reinicia com mod + q
myStartupHook = do
				spawnOnce "lxsession" -- inicia a sessão
				--spawnOnce "setxkbmap -model abnt2 -layout br &" -- muda o layout de teclado pra br
				--spawnOnce "gnome-keyring-daemon" -- inicia a aplicação de autenticação do gnome
				spawnOnce "picom" -- inicia o compositor para habilitar efeitos visuais no desktop
				--spawnOnce "nm-applet" -- inicia o gerenciador de redes
				spawnOnce "trayer --edge bottom --align right --width 10 --SetDockType true --SetPartialStrut true --expand true --transparent true --alpha 150 --tint 0x000000 --height 20" -- inicia o trayer para mostrar programas em segundo plano
				spawnOnce "nitrogen --restore" -- inicia um novo wallpaper ou restaura o usado na sessão anterior
				--spawnOnce "fluxgui" -- inicia o modo noturno automatico
------------------------------------------------------------------------
-- Roda o xmonad usando os aliases e configurações usados anteriormente

main = do 
	   xmproc <- spawnPipe "xmobar -x 0 /home/lucas/.config/xmobar/xmobarrc"
	   xmonad $ ewmh $ docks $ defaults

defaults = def {
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
        
        keys               = myKeys,
        mouseBindings      = myMouseBindings,
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        startupHook        = myStartupHook
    }

-- uma copia dos comandos usados na configuração padrão do xmonad
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
