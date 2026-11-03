{ osConfig, ... }:
let
  heliumApps = osConfig.programs.helium.webApps;

  hotkey = id: binding: { inherit id binding; };

  # settings.toml is validated strictly: every required key must be present and
  # any hotkey left out is unassigned, so only the paneru-equivalent bindings
  # are listed.
  hotkeys = [
    (hotkey "focus.left" "Option+H")
    (hotkey "focus.right" "Option+L")
    (hotkey "focus.up" "Option+K")
    (hotkey "focus.down" "Option+J")
    (hotkey "move.left" "Option+Shift+H")
    (hotkey "move.right" "Option+Shift+L")
    (hotkey "move.up" "Option+Shift+K")
    (hotkey "move.down" "Option+Shift+J")
    (hotkey "cycleSizeForward" "Option+.")
    (hotkey "cycleSizeBackward" "Option+,")
    (hotkey "toggleContainerFullPrimarySpan" "Option+Shift+F")
    (hotkey "toggleFocusedWindowFloating" "Option+F")
    (hotkey "toggleFloatingFocus" "Option+Space")
    (hotkey "consumeWindowIntoColumn" "Option+[")
    (hotkey "expelWindowFromColumn" "Option+]")
    (hotkey "switchWorkspace.previous" "Shift+Command+K")
    (hotkey "switchWorkspace.next" "Shift+Command+J")
    (hotkey "moveWindowToWorkspaceUp" "Option+Command+K")
    (hotkey "moveWindowToWorkspaceDown" "Option+Command+J")
  ]
  ++ builtins.genList (i: hotkey "switchWorkspace.${toString i}" "Option+${toString (i + 1)}") 5
  ++ builtins.genList (i: hotkey "moveToWorkspace.${toString i}" "Option+Shift+${toString (i + 1)}") 5;

  # Paneru's virtual workspaces 1-5.
  workspace = id: name: {
    inherit id name;
    monitorAssignment.type = "main";
    layoutType = "niri";
  };

  workspaces = [
    (workspace "AD36F001-C57E-41A5-AC1D-DF5249D007F0" "1")
    (workspace "454CECD4-5E9D-4ED1-95D7-979D48817F5F" "2")
    (workspace "BEB842B5-E894-4791-9FD1-397C3CDD3538" "3")
    (workspace "248AA883-2261-4D45-943C-79C0E46A232B" "4")
    (workspace "8B8C45D6-CE9E-41D9-BD50-BE4989D5E3DE" "5")
  ];

  # OmniWM's built-in minimum-size rules, minus ghostty which is merged below.
  defaultAppRules = [
    {
      id = "6A31F08A-4051-4354-B439-42F4C71894A3";
      bundleId = "com.openai.codex";
      minWidth = 800.0;
      minHeight = 600.0;
    }
    {
      id = "4BA546DA-2875-4BEF-B13F-1539E833B1A0";
      bundleId = "com.eltima.cmd1.pro.mas";
      minWidth = 950.0;
      minHeight = 550.0;
    }
    {
      id = "486CEFA6-69AA-4A3C-AF27-BCD38F4F138B";
      bundleId = "com.google.Chrome";
      minWidth = 500.0;
      minHeight = 375.0;
    }
    {
      id = "979F05F4-FFA2-4EDD-B23F-08A9944C759F";
      bundleId = "dev.zed.Zed";
      minWidth = 360.0;
      minHeight = 240.0;
    }
    {
      id = "81426D13-C1A5-475E-AFBC-00BBA05042D0";
      bundleId = "com.apple.Safari";
      minWidth = 574.0;
      minHeight = 220.0;
    }
    {
      id = "1CF39647-F30D-4E76-9686-79B551F1B094";
      bundleId = "app.zen-browser.zen";
      minWidth = 500.0;
      minHeight = 495.0;
    }
    {
      id = "005C00D3-F665-47F8-BDAE-D80790E9E46B";
      bundleId = "org.mozilla.firefox";
      minWidth = 500.0;
      minHeight = 120.0;
    }
    {
      id = "C21156B1-0224-4998-97E3-8F4FA65B9F3B";
      bundleId = "company.thebrowser.dia";
      minWidth = 500.0;
      minHeight = 420.0;
    }
    {
      id = "2DE9390B-0DB4-4D0C-9ABA-06F76F1D4EA9";
      bundleId = "com.spotify.client";
      minWidth = 800.0;
      minHeight = 600.0;
    }
    {
      id = "AF752D95-8497-4844-BE20-4C93E73BAEF2";
      bundleId = "com.hnc.Discord";
      minWidth = 800.0;
      minHeight = 500.0;
    }
    {
      id = "8ECAB78B-BCDD-4245-BC25-1609A49B1C86";
      bundleId = "com.microsoft.Outlook";
      minWidth = 930.0;
      minHeight = 650.0;
    }
    {
      id = "552FB77D-BF0E-4737-90A6-B5BC6986C579";
      bundleId = "com.apple.MobileSMS";
      minWidth = 660.0;
      minHeight = 320.0;
    }
  ];

  float = id: bundleId: {
    inherit id bundleId;
    layout = "float";
  };

  # Paneru's `grid` placement has no OmniWM equivalent, so those windows are
  # only floated.
  appRules = defaultAppRules ++ [
    {
      id = "7876C9EF-437E-4D4F-9C27-B1B02F4AABCE";
      bundleId = "com.mitchellh.ghostty";
      layout = "tile";
      initialContainerPrimarySpan = 0.66;
      minWidth = 90.0;
      minHeight = 48.0;
    }
    {
      id = "26940162-C7EF-4D6D-9B1F-8D6EB3154CDD";
      bundleId = "com.superlogical.rex";
      layout = "tile";
      initialContainerPrimarySpan = 0.66;
    }
    {
      id = "416F7E83-3F97-4F15-B07A-816C6820CA3D";
      bundleId = "net.imput.helium";
      layout = "tile";
      initialContainerPrimarySpan = 0.66;
    }
    {
      id = "76585DFB-FE35-4C3B-A67A-A6DAC8FAD394";
      bundleId = "net.imput.helium";
      titleSubstring = "Bitwarden";
      layout = "float";
    }
    (float "AC2F22F8-85DF-4322-A2DD-BF9606F187E0" "com.apple.Music")
    (float "DED1D0A9-4B85-464B-8146-B3A4FF070F92" heliumApps.gmail.expectedBundleId)
    (float "389F6ACD-38D1-4297-988C-B145169D95C1" heliumApps.outlook.expectedBundleId)
    (float "61494793-ED9B-416E-B947-28B019DEFF91" "com.apple.iCal")
    (float "2A61A781-0D20-4E41-A781-DC4F3389A3EC" "com.getharvest.harvestxapp")
    (float "A5328B27-00C3-44A0-A704-B92D594700F0" "com.apple.systempreferences")
    (float "15583C07-D2C9-47B7-A084-49409AF4EAFF" "com.apple.finder")
    (float "A4C1330D-5160-44FB-9E0F-F53822E3DE7A" "com.apple.ActivityMonitor")
    (float "7CD6957E-40A2-4425-A72E-AD6400F2A0F5" "com.apple.ScreenContinuity")
    (float "26D2CAD1-6354-427E-9D88-5A969D4F830A" "com.apple.PhotoBooth")
    (float "9385A1C8-1331-4769-AFDF-67073FDE0071" "com.apple.calculator")
  ];

  color = red: green: blue: alpha: {
    inherit
      red
      green
      blue
      alpha
      ;
  };
in
{
  programs.omniwm = {
    enable = true;
    settings = {
      schemaVersion = 5;

      general = {
        hotkeysEnabled = true;
        systemHyperTrigger = "None";
        hyperKeyModifiers = "Control+Option+Shift+Command";
        defaultLayoutType = "niri";
        preventSleepEnabled = false;
        updateChecksEnabled = false;
        ipcEnabled = false;
        animationsEnabled = true;
        # paneru animation_speed = 20.0 (its fastest "comfortable" setting)
        animationSpeed = 2.0;
      };

      # focus_follows_mouse / mouse_follows_focus
      focus = {
        followsMouse = true;
        raiseOnMouseFocus = false;
        lockModifier = "off";
        moveMouseToFocusedWindow = true;
        followsWindowToMonitor = false;
        crossesMonitorAtEdge = false;
        moveCrossesMonitorAtEdge = false;
      };

      mouseWarp = {
        margin = 1;
        enabled = true;
        constrainToArrangement = false;
      };

      routing = {
        mode = "macOS";
        arrangements = [ ];
      };

      # paneru has no padding or gaps configured.
      gaps = {
        size = 0.0;
        fullscreenUsesOuterGaps = false;
        outer = {
          left = 0.0;
          right = 0.0;
          top = 0.0;
          bottom = 0.0;
        };
      };

      niri = {
        visibleContainerCount = 2;
        infiniteLoop = false;
        centerFocusedColumn = "never";
        alwaysCenterSingleColumn = false;
        singleWindowFit = "fill";
        # preset_column_widths
        containerPrimarySpanPresets = [
          0.33
          0.5
          0.66
          1.0
        ];
        defaultContainerPrimarySpan = 0.5;
        resizeStepPercent = 5;
        edgeGaps = true;
      };

      dwindle = {
        smartSplit = false;
        defaultSplitRatio = 1.0;
        splitWidthMultiplier = 1.0;
        singleWindowFit = "fill";
        useGlobalGaps = true;
        moveToRootStable = true;
      };

      # paneru draws no focus border.
      borders = {
        enabled = false;
        width = 5.0;
        color = color 0.084585202284378935 1.0 0.97930003794467602 1.0;
      };

      overview = {
        enabled = true;
        zoom = 1.0;
        backdrop = color 0.05 0.05 0.08 0.0;
        windowBorders = {
          normal = color 0.3 0.3 0.35 0.5;
          hovered = color 0.4 0.6 1.0 1.0;
          selected = color 0.3 0.8 0.4 1.0;
        };
        matchFocusBorder = true;
        invertScrollDirection = false;
        mouseScrollSpeed = 1.0;
      };

      # paneru has no bar.
      workspaceBar = {
        enabled = false;
        hoverPreviewsEnabled = true;
        notificationBadges = "off";
        notificationBadgeRefreshIntervalSeconds = 5.0;
        showLabels = true;
        showFloatingWindows = false;
        windowLevel = "popup";
        position = "overlappingMenuBar";
        notchMode = "moveBelowMenuBar";
        notchActiveZoneWidth = 180.0;
        systemStatsButton = false;
        deduplicateAppIcons = false;
        hideEmptyWorkspaces = false;
        excludedBundleIDs = [ ];
        iconOverrides = { };
        reserveLayoutSpace = false;
        autoHide = false;
        revealModifier = "off";
        revealHoldMilliseconds = 200.0;
        hideInNativeFullscreen = false;
        height = 24.0;
        backgroundOpacity = 0.1;
        transparentBackground = false;
        solidBlackBackground = false;
        showItemBackgrounds = true;
        showAccentHighlights = true;
        xOffset = 0.0;
        yOffset = 0.0;
      };

      # swipe: continuous = false, fingers_count = 3. Paneru also uses the
      # vertical swipe to change virtual workspace.
      gestures = {
        scrollEnabled = true;
        scrollSensitivity = 5.0;
        scrollModifierKey = "optionShift";
        mouseMoveModifierKey = "option";
        mouseResizeModifierKey = "option";
        fingerCount = 3;
        invertDirection = true;
        trackpadScrollStyle = "snap";
        workspaceSwipeEnabled = true;
        workspaceSwipeFingerCount = 3;
        workspaceSwipeAxis = "vertical";
      };

      statusBar = {
        showWorkspaceName = false;
        showAppNames = false;
        useWorkspaceId = false;
        showIcon = true;
      };

      hiddenBar = {
        enabled = false;
        hiddenBundleIDs = [ ];
        rehideIntervalSeconds = 5.0;
      };

      clipboard = {
        historyEnabled = false;
        maxItems = 200;
        maxItemBytes = 8388608;
        maxTotalBytes = 67108864;
        ignoredTypes = [ ];
      };

      quakeTerminal = {
        enabled = false;
        position = "center";
        widthPercent = 50.0;
        heightPercent = 50.0;
        animationDuration = 0.2;
        autoHide = false;
        opacity = 1.0;
        backgroundEffect = "standardBlur";
        backgroundBlurRadius = 0;
        monitorMode = "focusedWindow";
      };

      scratchpads.labels = { };

      appearance = {
        mode = "dark";
        tabRailAppIcons = false;
      };

      inherit hotkeys workspaces appRules;

      monitorBarOverrides = [ ];
      monitorOrientationOverrides = [ ];
      monitorNiriOverrides = [ ];
      monitorDwindleOverrides = [ ];
      monitorGapOverrides = [ ];
    };
  };
}
