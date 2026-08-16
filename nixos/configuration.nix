{ config, pkgs, ... }:

let
  # ------ Parsers :: CSS

  css =
    rules:
    let
      renderDeclaration = property: value: "${property}:${value};";

      renderRule =
        selector: declarations:
        "${selector}{"
        + builtins.concatStringsSep "" (
          builtins.map (property: renderDeclaration property declarations.${property}) (
            builtins.attrNames declarations
          )
        )
        + "}";

    in
    builtins.concatStringsSep "" (
      builtins.map (selector: renderRule selector rules.${selector}) (builtins.attrNames rules)
    );

  # ------ Vars :: Themes

  themes = {
    catppuccinMocha = {
      bg = "#1e1e2e";
      bgDark = "#11111b";
      bgAlt = "#313244";
      fg = "#cdd6f4";
      muted = "#a6adc8";
      blue = "#89b4fa";
      mauve = "#cba6f7";
      red = "#f38ba8";
      green = "#a6e3a1";
      peach = "#fab387";
    };
  };

  bashColors = {
    RESET = "0";
    BOLD = "1";
    BLACK = "30";
    RED = "31";
    GREEN = "32";
    YELLOW = "33";
    BLUE = "34";
    MAGENTA = "35";
    CYAN = "36";
    WHITE = "37";
    GRAY = "90";
    LIGHTRED = "91";
    LIGHTGREEN = "92";
    LIGHTYELLOW = "93";
    LIGHTBLUE = "94";
    LIGHTMAGENTA = "95";
    LIGHTCYAN = "96";
  };

  bashColorInit = builtins.concatStringsSep "\n" (
    builtins.map (name: "${name}=\"\\e[${bashColors.${name}}m\"") (builtins.attrNames bashColors)
  );

  theme = {
    current = themes.catppuccinMocha;

    font = {
      family = "JetBrainsMono Nerd Font";
      size = "11";
    };

    spacing = {
      sm = "4";
      normal = "8";
      lg = "16";
    };
  };

  # ------ Vars :: Packages

  packages = {
    desktop = with pkgs; [
      waybar
      wofi
      alacritty
      mako
      swaybg
      imv
      libnotify
      brightnessctl
      nemo-with-extensions
      udiskie

      wl-clipboard
      grim
      slurp

      dracula-theme
      adwaita-icon-theme
      # catppuccin-gtk
      # arc-theme
    ];

    office = with pkgs; [
      calcurse
      pombo.desktop.calcurse
    ];

    cli = with pkgs; [
      tree
      jq
      wget
      curl
      unzip
      zip
      btop
      fastfetch
      bat
      yazi

      pombo.script.fastfetchLaunch
      pombo.desktop.fastfetch
    ];

    browsers = with pkgs; [
      brave
      firefox
      librewolf
    ];

    networking = with pkgs; [
      bluez
      impala
      bluetui
      wiremix
      resterm

      pombo.desktop.impala
      pombo.desktop.bluetui
      pombo.desktop.wiremix
      pombo.desktop.resterm
    ];

    development = with pkgs; [
      git
      vscodium
      nodejs_26
      github-desktop
      lazygit
      nixfmt
    ];

    developmentRust = with pkgs; [
      rustc
      cargo
      rustfmt
      clippy
      gcc
      file
    ];

    android = with pkgs; [
      android-studio
      androidSdk
      android-tools
    ];

    androidSamsung = with pkgs; [
      heimdall
      usbutils
    ];

    containers = with pkgs; [
      docker
      virtualbox
    ];

    creative = with pkgs; [
      blender
      gimp
      inkscape
      kdePackages.kdenlive

      imagemagick
      darktable

      # oxipng
      # pngquant
      # jpegoptim
      # svgo

      # webp-pixbuf-loader
      # gdk-pixbuf
      # xarchiver
      # pcmanfm
      # lxmenu-data

    ];

    media = with pkgs; [
      obs-studio
      video-downloader
      ffmpeg
      vlc
      #wl-screenrec
    ];

    games = with pkgs; [
      supertux
      wesnoth
      ut1999
      mindustry
    ];

    misc = with pkgs; [
      keepassxc
      pombo.app.jaiba
    ];

    pombo = with pkgs; [
      pombo.script.batteryMonitor
      pombo.script.toggleSignals
      pombo.script.waybarBluetooth
      pombo.script.waybarCamera
      pombo.script.waybarMicrophone
    ];
  };

  # ------ Vars :: Sway

  workspaces = builtins.genList (n: toString (n + 1)) 9;

  workspaceBindings = builtins.concatStringsSep "\n" (
    map (n: ''
      bindsym $mod+${n} workspace number ${n}
      bindsym $mod+Shift+${n} move container to workspace number ${n}
    '') workspaces
  );

  # ------ Custom Scripts

  pombo = {
    script = {
      waybarBluetooth = pkgs.writeShellScriptBin "pombo-waybar-bluetooth" ''
        if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
          printf '{"text":"bt:1","class":"bt-on"}'
        else
          printf '{"text":"bt:0","class":"bt-off"}'
        fi
      '';

      waybarCamera = pkgs.writeShellScriptBin "pombo-waybar-camera" ''
        if ls /dev/video* >/dev/null 2>&1; then
          printf '{"text":"cam:1","class":"active"}'
        else
          printf '{"text":"cam:0","class":"inactive"}'
        fi
      '';

      waybarMicrophone = pkgs.writeShellScriptBin "pombo-waybar-microphone" ''
        mic=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)

        if echo "$mic" | grep -q MUTED; then
          printf '{"text":"mic:0","class":"inactive"}'
        else
          printf '{"text":"mic:1","class":"active"}'
        fi
      '';

      toggleSignals = pkgs.writeShellScriptBin "pombo-toggle-signals" ''
        wifi=$(iwctl device wlan0 show 2>/dev/null | awk '/Powered/ {print $NF}')
          if [ "$wifi" = "on" ]; then
            iwctl device wlan0 set-property Powered off
            bluetoothctl power off
            notify-send "Radio" "Wi-Fi and Bluetooth disabled"
          else
            iwctl device wlan0 set-property Powered on
            notify-send "Radio" "Wi-Fi enabled"
          fi
      '';

      batteryMonitor = pkgs.writeShellScriptBin "pombo-battery-monitor" ''
        BATTERY="/sys/class/power_supply/BAT0"
        THRESHOLD=10
        STATE_FILE="''${XDG_RUNTIME_DIR}/battery-notified"

        while true; do
          if [ -r "$BATTERY/capacity" ] && [ -r "$BATTERY/status" ]; then
            capacity=$(cat "$BATTERY/capacity")
            status=$(cat "$BATTERY/status")

            if [ "$capacity" -le "$THRESHOLD" ] && [ "$status" = "Discharging" ]; then
              if [ ! -f "$STATE_FILE" ]; then
                notify-send \
                  -u critical \
                  -i battery-caution \
                  "Low Battery" \
                  "Battery is at ''${capacity}%"

                touch "$STATE_FILE"
              fi
            else
              # Reset the notification once the battery is charged
              # or goes above the threshold.
              rm -f "$STATE_FILE"
            fi
          fi

          sleep 30
        done
      '';

      fastfetchLaunch = pkgs.writeShellScriptBin "fastfetch-launch" ''
        fastfetch
        exec "$SHELL"
      '';
    };

    desktop = {
      fastfetch = pkgs.makeDesktopItem {
        name = "fastfetch";
        desktopName = "Fastfetch";
        comment = "System information TUI";
        exec = "alacritty -e ${pombo.script.fastfetchLaunch}/bin/fastfetch-launch";
        terminal = false;
        categories = [ "System" ];
      };

      impala = pkgs.makeDesktopItem {
        name = "impala";
        desktopName = "Impala";
        comment = "Wi-Fi TUI";
        exec = "alacritty -e impala";
        terminal = false;
        categories = [ "Network" ];
      };

      bluetui = pkgs.makeDesktopItem {
        name = "bluetui";
        desktopName = "Bluetui";
        comment = "Bluetooth TUI";
        exec = "alacritty -e bluetui";
        terminal = false;
        categories = [ "Network" ];
      };

      resterm = pkgs.makeDesktopItem {
        name = "resterm";
        desktopName = "Resterm";
        comment = "API client for REST, GraphQL, gRPC, WebSocket and SSE";
        exec = "alacritty -e resterm";
        terminal = false;
        categories = [ "Development" ];
      };

      neovim = pkgs.makeDesktopItem {
        name = "neovim";
        desktopName = "Neovim";
        comment = "Text Editor TUI";
        exec = "alacritty -e nvim";
        terminal = false;
        categories = [
          "Development"
        ];
      };

      wiremix = pkgs.makeDesktopItem {
        name = "wiremix";
        desktopName = "Wiremix";
        comment = "PipeWire audio mixer";
        exec = "alacritty -e wiremix";
        terminal = false;
        categories = [
          "AudioVideo"
          "Audio"
        ];
      };

      calcurse = pkgs.makeDesktopItem {
        name = "calcurse";
        desktopName = "Calcurse";
        comment = "Calendar and scheduling TUI";
        exec = "alacritty -e calcurse";
        terminal = false;
        categories = [
          "Office"
          "Calendar"
        ];
      };
    };

    app = {
      jaiba = pkgs.rustPlatform.buildRustPackage rec {
        pname = "jaiba";
        version = "2026.3";

        src = pkgs.fetchFromGitHub {
          owner = "pomboverso";
          repo = "jaiba";
          rev = "2026.3";
          hash = "sha256-2IIoF4StIL8xVYOiuym6UZNpj/N6dMTcfxmnlyn80uc=";
        };

        cargoHash = "sha256-0qZcNp+ZEgT2RYgeDXx3MTDIQeY8FsGGwqpb0NuntzE=";

        postInstall = ''
          install -Dm644 assets/jaiba.desktop \
            $out/share/applications/jaiba.desktop

          install -Dm644 assets/jaiba.svg \
            $out/share/icons/hicolor/scalable/apps/jaiba.svg

          for size in 16 22 24 32 48 64 72 96 128 192 256 512; do
            install -Dm644 \
              assets/icon_''${size}x''${size}.png \
              $out/share/icons/hicolor/''${size}x''${size}/apps/jaiba.png
          done
        '';
      };
    };
  };

  # ------ Android SDK

  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [
      "21"
      "23"
      "28"
      "29"
      "30"
      "31"
      "33"
      "34"
      "35"
      "36"
      "37"
    ];

    abiVersions = [
      "x86_64"
    ];

    includeEmulator = true;
    includeSystemImages = true;

    systemImageTypes = [
      "google_apis"
    ];

    includeNDK = true;
    includeSources = false;
  };

  androidSdk = androidComposition.androidsdk;

in
{
  # ------ Imports

  imports = [
    ./hardware-configuration.nix
  ];

  # ------ System

  time.timeZone = "America/Los_Angeles";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ------ Nix :: experimental features

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # ------ Nix :: nixpkgs settings

  nixpkgs.config = {
    android_sdk.accept_license = true;
    allowUnfree = true;
  };

  # ------ Boot

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.luks.devices."luks-26f0579d-79fe-4ff9-96fa-f432718e7385".device =
      "/dev/disk/by-uuid/26f0579d-79fe-4ff9-96fa-f432718e7385";
  };

  # ------ Hardware :: Audio

  services = {
    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  security.rtkit.enable = true;

  # ------ Networking

  networking = {
    hostName = "iqra";
    networkmanager.enable = false;
    wireless.iwd.enable = true;
  };

  hardware.bluetooth.enable = true;

  # ------ Users

  users.users.iqra = {
    isNormalUser = true;
    description = "iqra";

    extraGroups = [
      "wheel"
      "networkmanager"
      "kvm"
      "docker"
    ];

  };

  # ------ Users :: autologin

  services.getty.autologinUser = "iqra";

  # ------ XDG portals

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [
        "Alacritty.desktop"
      ];
    };
  };

  # ------ Storage

  services = {
    udisks2.enable = true;
    gvfs.enable = true;
  };

  environment.pathsToLink = [
    "share/thumbnailers"
  ];

  # ------ Environment variables

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # ------ Program :: Neovim

  programs.neovim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    configure = {
      packages.myPlugins = with pkgs.vimPlugins; {
        start = [
          lualine-nvim
          nvim-web-devicons
        ];
      };

      customRC = ''
        lua << EOF
        vim.g.mapleader = " "

        -- Indentation
        vim.opt.expandtab = true
        vim.opt.tabstop = 2
        vim.opt.shiftwidth = 2
        vim.opt.softtabstop = 2

        -- Visible whitespace
        vim.opt.list = true
        vim.opt.listchars = "space:·,tab:→ ,trail:~"

        -- Line numbers
        vim.opt.number = true

        -- Keep cursor away from screen edges
        vim.opt.scrolloff = 4

        -- Mouse
        vim.opt.mouse = "a"

        -- Search
        vim.opt.ignorecase = true
        vim.opt.smartcase = true

        -- Move lines up/down
        local opts = {
          noremap = true,
          silent = true,
        }

        vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", opts)
        vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", opts)

        vim.keymap.set("i", "<A-Down>", "<Esc>:m .+1<CR>==gi", opts)
        vim.keymap.set("i", "<A-Up>", "<Esc>:m .-2<CR>==gi", opts)

        vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", opts)
        vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", opts)

        -- Select all
        vim.keymap.set("n", "<leader>a", "ggVG", {
          desc = "Select all",
        })

        -- Undo / redo
        vim.keymap.set("n", "<C-z>", "u", opts)
        vim.keymap.set("n", "<C-y>", "<C-r>", opts)

        -- Lualine
        require("lualine").setup({
          options = {
            theme = "dracula",
            globalstatus = true,
            section_separators = "",
            component_separators = "",
          },
        })
        EOF
      '';
    };
  };

  # ------ Program :: Sway

  services.xserver.enable = false;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [ ];
  };

  environment.etc."sway/config".text = ''
    set $mod Mod4

    include /etc/sway/config.d/*

    # Startup
    exec udiskie
    exec waybar --config /etc/waybar/config --style /etc/waybar/style.css
    exec pombo-battery-monitor
    exec bluetoothctl power off
    # exec swaybg -i /path/to/wallpaper.png -m fill

    # GTK theme
    exec gsettings set org.gnome.desktop.interface gtk-theme 'Dracula'

    # Window decorations
    default_border pixel 1
    default_floating_border pixel 1

    # Window colors
    client.focused ${theme.current.mauve} ${theme.current.bgAlt} ${theme.current.fg} ${theme.current.mauve} ${theme.current.bgAlt}
    client.unfocused ${theme.current.bg} ${theme.current.bg} ${theme.current.muted} ${theme.current.bgAlt} ${theme.current.bg}

    # Display
    output eDP-1 scale 2

    # Cursor
    seat seat0 xcursor_theme Adwaita 18

    # Touchpad
    input type:touchpad {
        tap enabled
    }

    # Gaps
    gaps inner ${theme.spacing.sm}
    gaps outer ${theme.spacing.sm}

    # Terminal
    bindsym $mod+z exec alacritty

    # Application launcher
    bindsym $mod+space exec wofi

    # Close window
    bindsym $mod+x kill

    # Reload Sway
    bindsym $mod+r reload

    # Power
    bindsym $mod+Escape exec swaynag -t warning -m 'Shutdown?' -B 'Yes' 'systemctl poweroff'

    ${workspaceBindings}

    # Resizing
    bindsym $mod+comma resize shrink width 1 ppt
    bindsym $mod+period resize grow width 1 ppt

    # Volume
    bindsym --locked XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bindsym --locked XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-
    bindsym --locked XF86AudioRaiseVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+

    # Microphone
    bindsym --locked XF86AudioMicMute exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

    # Brightness
    bindsym --locked XF86MonBrightnessDown exec brightnessctl set 1%-
    bindsym --locked XF86MonBrightnessUp exec brightnessctl set 1%+

    # Touchpad toggle
    bindsym --locked XF86TouchpadToggle exec pombo-toggle-signals

    # Screenshot
    bindsym Print exec grim -g "$(slurp)" - | wl-copy
  '';

  # ------ Program :: Waybar

  environment.etc."waybar/config".text = builtins.toJSON {
    layer = "top";
    position = "top";
    height = 26;
    spacing = theme.spacing.normal;

    "modules-left" = [
      "sway/workspaces"
      "wlr/taskbar"
    ];

    "modules-center" = [ ];

    "modules-right" = [
      "network"
      "custom/bluetooth"
      "custom/camera"
      "custom/microphone"
      "sway/language"
      "backlight"
      "pulseaudio"
      "battery"
      "temperature"
      "clock"
    ];

    "custom/camera" = {
      exec = "${pombo.script.waybarCamera}/bin/pombo-waybar-camera";
      interval = 2;
      "return-type" = "json";
      format = "{}";
      tooltip = false;
    };

    "custom/microphone" = {
      exec = "${pombo.script.waybarMicrophone}/bin/pombo-waybar-microphone";
      interval = 2;
      "return-type" = "json";
      format = "{}";
      tooltip = false;
      "on-click" = "alacritty -e wiremix";
    };

    "sway/workspaces" = {
      "disable-scroll" = true;
      "all-outputs" = true;
      format = "{name}";
    };

    "wlr/taskbar" = {
      format = "{icon}";
      "icon-size" = 16;
      "tooltip-format" = "{title}";
      "on-click" = "activate";
      "on-click-middle" = "close";
    };

    network = {
      interval = 5;
      "format-wifi" = "wf:{essid}:{signalStrength}%";
      "format-ethernet" = "eth:{ifname}";
      "format-disconnected" = "wf:0";
      "on-click" = "alacritty -e impala";
      tooltip = false;
    };

    "custom/bluetooth" = {
      exec = "${pombo.script.waybarBluetooth}/bin/pombo-waybar-bluetooth";
      interval = 5;
      "return-type" = "json";
      format = "{}";
      tooltip = false;
      "on-click" = "alacritty -e bluetui";
    };

    "sway/language" = {
      format = "kbd:{short}";
      tooltip = false;
    };

    backlight = {
      interval = 2;
      format = "bri:{percent}%";
      tooltip = false;
    };

    pulseaudio = {
      format = "snd:{volume}%";
      "format-muted" = "snd:{volume}%";
      tooltip = false;
      "on-click" = "alacritty -e wiremix";
    };

    battery = {
      interval = 10;
      format = "bat:{capacity}%";
      "format-charging" = "bat:{capacity}%";
      "format-full" = "bat:{capacity}%";
      tooltip = false;
      "on-click" = "alacritty -e btop";

      states = {
        warning = 20;
        critical = 10;
      };
    };

    temperature = {
      interval = 5;
      format = "{temperatureF}°F";
      "critical-threshold" = 80;
      tooltip = false;
      "on-click" = "alacritty -e btop";
    };

    clock = {
      interval = 1;
      format = "{:%m/%d | %H:%M}";
      tooltip = false;
      "on-click" = "alacritty -e calcurse";
    };
  };

  environment.etc."waybar/style.css".text = css {
    "*" = {
      "font-family" = "\"${theme.font.family}\"";
      "font-size" = "${theme.font.size}px";
    };

    "window#waybar" = {
      "background" = theme.current.bg;
      "color" = theme.current.fg;
    };

    "button:hover" = {
      "box-shadow" = "inset 0 1px ${theme.current.mauve}";
      "text-shadow" = "none";
    };

    "#workspaces button" = {
      "padding" = "0 ${theme.spacing.sm}px";
      "color" = theme.current.muted;
      "background" = "transparent";
      "border" = "none";
      "border-radius" = "0";
    };

    "#workspaces button:hover" = {
      "color" = theme.current.fg;
    };

    "#workspaces button.focused" = {
      "color" = theme.current.mauve;
    };

    "#workspaces button.urgent" = {
      "color" = theme.current.bg;
      "background" = theme.current.red;
    };

    "#taskbar button" = {
      "padding" = "0 ${theme.spacing.sm}px";
      "color" = theme.current.muted;
      "background" = "transparent";
      "border" = "none";
      "border-radius" = "0";
    };

    "#taskbar button:hover" = {
      "color" = theme.current.fg;
      "background" = theme.current.bgAlt;
    };

    "#taskbar button.active" = {
      "color" = theme.current.mauve;
      "background" = theme.current.bgAlt;
    };

    "#custom-bluetooth, #custom-camera, #custom-microphone, #network, #language, #backlight, #pulseaudio, #battery, #temperature, #clock" =
      {
        "padding" = "0 ${theme.spacing.sm}px";
      };

    "#custom-bluetooth" = {
      "color" = theme.current.fg;
    };

    "#custom-bluetooth.bt-on" = {
      "color" = theme.current.red;
    };

    "#language" = {
      "color" = theme.current.mauve;
    };

    "#backlight" = {
      "color" = theme.current.mauve;
    };

    "#pulseaudio" = {
      "color" = theme.current.mauve;
    };

    "#pulseaudio.muted" = {
      "color" = theme.current.red;
    };

    "#battery" = {
      "color" = theme.current.mauve;
    };

    "#battery.charging" = {
      "color" = theme.current.green;
    };

    "#battery.warning" = {
      "color" = theme.current.bg;
      "background" = theme.current.peach;
    };

    "#battery.critical" = {
      "color" = theme.current.bg;
      "background" = theme.current.red;
    };

    "#temperature" = {
      "color" = theme.current.green;
    };

    "#clock" = {
      "color" = theme.current.fg;
    };

    "#custom-camera, #custom-microphone" = {
      "color" = theme.current.fg;
    };

    "#custom-camera.active, #custom-microphone.active" = {
      "color" = theme.current.red;
    };
  };

  # ------ Program :: Wofi

  environment.etc."wofi/config".text = ''
    show=drun
    term=alacritty
    prompt=Apps
    width=400
    lines=8
    columns=1
    allow_images=false
    hide_scroll=true
    no_actions=true
    style=/etc/wofi/catppuccin-mocha.css
  '';

  environment.etc."wofi/catppuccin-mocha.css".text = css {
    "#window" = {
      "background-color" = theme.current.bg;
      "border" = "0 none";
      "border-radius" = "0";
    };

    "#outer-box" = {
      "padding" = "8px";
      "background-color" = theme.current.bg;
      "border" = "1px solid ${theme.current.blue}";
      "font-size" = "${theme.font.size}px";
      "font-family" = "\"${theme.font.family}\"";
    };

    "#input" = {
      "background-color" = theme.current.bgAlt;
      "color" = theme.current.fg;
      "padding" = "0 ${theme.spacing.normal}px";
      "border" = "none";
      "border-radius" = "0";
      "box-shadow" = "none";
    };

    "#scroll" = {
      "margin-top" = "${theme.spacing.normal}px";
    };

    "#inner-box" = {
      "background-color" = "transparent";
    };

    "#entry" = {
      "padding" = "${theme.spacing.normal}px";
      "margin" = "1px 0";
      "background-color" = "transparent";
      "color" = theme.current.fg;
      "border-radius" = "0";
    };

    "#entry:selected" = {
      "background-color" = theme.current.mauve;
      "outline" = "none";
    };

    "#entry:selected #text" = {
      "color" = theme.current.bg;
    };

    "#text" = {
      "color" = theme.current.fg;
    };
  };

  # ------ Program :: Mako

  environment.etc."mako/config".text = ''
    [mode=default]
    background-color=${theme.current.bg}
    text-color=${theme.current.fg}
    border-color=${theme.current.mauve}

    [urgency=critical]
    background-color=${theme.current.red}
    text-color=${theme.current.bg}
    border-color=${theme.current.red}
  '';

  # ------ Program :: Alacritty

  environment.etc."alacritty/alacritty.toml".text = ''
    [font]
    normal = { family = "${theme.font.family}" }
    size = ${theme.font.size}
  '';

  # ------ Services :: Docker

  virtualisation.docker.enable = true;

  # ------ Services :: Polkit

  security.polkit.enable = true;

  # ------ Packages

  environment.systemPackages = builtins.concatLists (builtins.attrValues packages);

  # ------ Fonts

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # ------ Bash

  programs.bash = {
    enable = true;

    shellAliases = {
      # ls: colors, hidden files, human-readable sizes,
      # directories first
      ls = "ls -lah --color=always --group-directories-first";

      # Prevent deleting root and ask for confirmation
      rm = "rm -I --preserve-root";

      # Ask before overwriting files
      cp = "cp -i";
      mv = "mv -i";

      # Create parent directories automatically
      mkdir = "mkdir -p";

      # Rebuild NixOS
      update = "clear && sudo nixos-rebuild switch";

      # Go up one directory
      ".." = "cd ..";

      cat = "bat";
    };

    promptInit = ''
      ${bashColorInit}

      DIR="\e[''${BOLD};''${LIGHTGREEN}m"
      CMD="\e[''${BOLD};''${LIGHTYELLOW}m"
      PS1="\[$DIR\]\w\[$RESET\]$\[$CMD\]$\[$RESET\] "
    '';
  };

  # ------ State version

  system.stateVersion = "26.05";

  # ------ Samsung Development
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", ATTR{idProduct}=="685d", TAG+="uaccess"
  '';
}
