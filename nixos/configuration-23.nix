{ config, pkgs, ... }:

let

  # ------ Parsers :: CSS

  parser = {
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
  };

  # ------ Vars :: Themes

  username = "pam";

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

  themes = {
    catppuccinMocha = {
      bg = "#1e1e2e";
      bgDark = "#11111b";
      bgAlt = "#313244";
      fg = "#cdd6f4";
      muted = "#a6adc8";
      accent10 = "#cba6f7";
      accent20 = "#b4befe";
      danger = "#f38ba8";
      warning = "#fab387";
      success = "#a6e3a1";
    };
  };

  theme = {
    current = themes.catppuccinMocha // {
      accent20 = "#89b4fa";
    };

    font = {
      family = "JetBrainsMono Nerd Font";
      size = "11";
    };

    spacing = {
      sm = "4";
      md = "8";
      lg = "16";
    };
  };

  # ------ Vars :: Packages

  packages = {

    desktop = with pkgs; [
      i3
      i3status
      dmenu
      dunst
      libnotify
      nemo
      mc
    ];

    themes = with pkgs; [
      dracula-theme
      adwaita-icon-theme
    ];

    system = with pkgs; [
      alacritty
      st
      rama.appC.fastfetch
      rama.appCpp.btop
      rama.appC.tmux
    ];

    commandUtils = with pkgs; [
      udiskie
      xclip
      scrot
      tree
      jq
      wget
      curl
      unzip
      zip
    ];

    browsers = with pkgs; [
      brave
      firefox
      librewolf
    ];

    networking = with pkgs; [
      bluez
      wiremix
      rama.appGo.resterm
      rama.appRust.impala
      rama.appRust.bluetui
    ];

    development = with pkgs; [
      git
      vscodium
      github-desktop
      nixfmt
    ];

    developmentRuby = with pkgs; [
      ruby
      rubyPackages.standard
    ];

    developmentRust = with pkgs; [
      rustc
      cargo
      rustfmt
      clippy
      gcc
      file
    ];

    developmentAndroid = with pkgs; [
      androidSdk
      android-tools
    ];

    creative = with pkgs; [
      imagemagick
      imv
      cmus
    ];

    media = with pkgs; [
      ffmpeg
      vlc
    ];

    misc = with pkgs; [
      xkeyboard-config
      libxkbcommon
      rama.appPerl.asciiquarium
      rama.appRust.weathr
    ];

    customApps = builtins.attrValues rama.app;
    scripts = builtins.attrValues rama.script;
  };

  # ------ Vars :: i3

  workspaces = builtins.genList (n: toString (n + 1)) 9;

  workspaceBindings = builtins.concatStringsSep "\n" (
    map (n: ''
      bindsym $mod+${n} workspace number ${n}
      bindsym $mod+Shift+${n} move container to workspace number ${n}
    '') workspaces
  );

  # ------ Home Config

  coquiConfig = pkgs.writeText "coqui_config.toml" ''
    theme = "nixos"

    [[command]]
    label = "------ Browsers"

    [[command]]
    label = "Brave"
    cmd = "brave"
    description = ""

    [[command]]
    label = "Firefox"
    cmd = "firefox"
    description = ""

    [[command]]
    label = "LibreWolf"
    cmd = "librewolf"
    description = ""

    [[command]]
    label = "------ Utilities"

    [[command]]
    label = "Jaiba Slim"
    cmd = "st -c floating-terminal -e jaiba --slim"
    description = ""

    [[command]]
    label = "Keepass (TMP)"
    cmd = "keepassxc"
    description = ""

    [[command]]
    label = "Nemo"
    cmd = "nemo"
    description = ""

    [[command]]
    label = "Midnight Commander"
    cmd = "st -e mc"
    description = ""

    [[command]]
    label = "Impala"
    cmd = "st -e impala"
    description = ""

    [[command]]
    label = "Bluetui"
    cmd = "st -e bluetui"
    description = ""

    [[command]]
    label = "Wiremix"
    cmd = "st -e wiremix"
    description = ""

    [[command]]
    label = "Btop"
    cmd = "st -e btop"
    description = ""

    [[command]]
    label = "Caiman"
    cmd = "st -e caiman"
    description = ""

    [[command]]
    label = "Fastfetch"
    cmd = "st -e fastfetch-launch"
    description = ""

    [[command]]
    label = "------ Development"

    [[command]]
    label = "Alacritty"
    cmd = "alacritty"
    description = ""

    [[command]]
    label = "VSCodium"
    cmd = "codium"
    description = ""

    [[command]]
    label = "Github"
    cmd = "github-desktop"
    description = ""

    [[command]]
    label = "ResTerm"
    cmd = "st -e resterm"
    description = ""

    [[command]]
    label = "------ Multimedia"

    [[command]]
    label = "Cmus"
    cmd = "st -e cmus"
    description = ""

    [[command]]
    label = "VLC"
    cmd = "vlc"
    description = ""

    [[command]]
    label = "------ Extras"

    [[command]]
    label = "Weathr"
    cmd = "st -e weathr"
    description = ""

    [[command]]
    label = "Asciiquarium"
    cmd = "st -e asciiquarium"
    description = ""

    [[command]]
    label = "Matrix"
    cmd = "st -e matrix"
    description = ""

    [[command]]
    label = "Polygon"
    cmd = "st -e polygon"
    description = ""

    [[command]]
    label = "------ System"

    [[command]]
    label = "i3 Exit"
    cmd = "i3-msg exit"
    description = ""

    [[command]]
    label = "Reboot"
    cmd = "systemctl reboot"
    description = ""

    [[command]]
    label = "Shutdown"
    cmd = "systemctl poweroff"
    description = ""
  '';

  # ------ Custom Scripts

  rama = {

    script = {

      batteryMonitor = pkgs.writeShellScriptBin "rama-battery-monitor" ''
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

      coquiLaunch = pkgs.writeShellScriptBin "rama-coqui-launch" ''
        if i3-msg '[class="^floating-terminal$"] focus' >/dev/null 2>&1; then
          exit 0
        fi

        exec st -c floating-terminal -e coqui
      '';

      powerMenu = pkgs.writeShellScriptBin "rama-power-menu" ''
        choice=$(
          printf '%s\n' \
            "Shutdown" \
            "Reboot" \
            "Logout" |
          dmenu -i -p "Power:"
        )

        case "$choice" in
          Shutdown)
            systemctl poweroff
            ;;
          Reboot)
            systemctl reboot
            ;;
          Logout)
            i3-msg exit
            ;;
        esac
      '';

    };

    app = {

      jaiba = pkgs.rustPlatform.buildRustPackage rec {
        pname = "jaiba";
        version = "2026.7";

        src = pkgs.fetchFromGitHub {
          owner = "rama-oi";
          repo = "jaiba";
          rev = "cbe20990c31e441b00977de49868671e673c0e68";
          hash = "sha256-oCdk8gB+5Siu3BNSpzhLC+mBtTJG7niomAb6MYTxJK0=";
        };

        cargoHash = "sha256-6rlpLP5q7AtHGMyh2U7cmIt+4f40AGgg0GJiV9ODDso=";

        doCheck = false;
      };

      caiman = pkgs.rustPlatform.buildRustPackage rec {
        pname = "caiman";
        version = "2026.1";

        src = pkgs.fetchFromGitHub {
          owner = "rama-oi";
          repo = "caiman";
          rev = "b64a52c2487187890c93da6707713252abfa32b8";
          hash = "sha256-hYYCITxCqLQyu1u39LUIuO/BxhUzFT/NLGjDiZfHgUw=";
        };

        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

        buildInputs = with pkgs; [
          libxkbcommon
        ];

        cargoHash = "sha256-mnjFMmwAyKFAu7Ll4Xdk8geI7ZlXP+niVqCEu2YOGI=";

        doCheck = false;
      };

      carey = fetchTarball {
        url = "https://github.com/rama-oi/carey/archive/refs/tags/2026.2.tar.gz";
        sha256 = "1k6sip49faaj7vl8jx765410b6afwdkbjdyzbcvq7z09ib20mir9";
      };

      coqui = pkgs.rustPlatform.buildRustPackage rec {
        pname = "coqui";
        version = "2026.4";

        src = pkgs.fetchFromGitHub {
          owner = "rama-oi";
          repo = "coqui";
          rev = "cb4c3353f41d4a1c536cd927ad03338a7498d632";
          hash = "sha256-WSc0bhGpH/qJ2YBIewXEZZvWx6HtT54jEl1Y+40fdMw=";
        };

        cargoHash = "sha256-Bhul97WcC/Pbu0QixOG5XytoW5nrqy9efYOX1xox3AI=";

        doCheck = false;
      };

      matrix = pkgs.stdenv.mkDerivation rec {
        pname = "matrix";
        version = "2026.1";

        src = pkgs.fetchFromGitHub {
          owner = "rama-oi";
          repo = "matrix";
          rev = "master";
          hash = "sha256-qBzyQrxQepN/lLtvuM7JFNTZma/vzQ/oNkB9EEWGqzA=";
        };

        dontBuild = true;

        installPhase = ''
          mkdir -p $out/bin
          cp matrix $out/bin/matrix
          chmod +x $out/bin/matrix
        '';
      };

      polygon = pkgs.stdenv.mkDerivation {
        pname = "polygon";
        version = "2026.1";

        src = pkgs.fetchFromGitHub {
          owner = "rama-oi";
          repo = "polygon";
          rev = "master";
          hash = "sha256-gehgbbMdePQlljMiAuH2v1JaKQv02KbRMhLPtB4RgvU=";
        };

        dontBuild = true;

        installPhase = ''
          mkdir -p $out/bin
          cp polygon.rb $out/bin/polygon
          chmod +x $out/bin/polygon
        '';

        postFixup = ''
          sed -i '1s|^#!.*|#!${pkgs.ruby}/bin/ruby|' $out/bin/polygon
        '';
      };

    };

    appRust = {

      impala = pkgs.rustPlatform.buildRustPackage rec {
        pname = "impala";
        version = "v0.8.0";

        src = pkgs.fetchFromGitHub {
          owner = "pythops";
          repo = "impala";
          rev = "f5f74d5fc25090a4e25e96de1a7ddaae6ce0f9ca";
          hash = "sha256-VjiXrjhmgCqCDEgDLWA2W6ppblMu/Cy6MUAS1uQQJuY=";
        };

        cargoHash = "sha256-9dMl0U/HEr3w6Gc26qHY87ULneD2Jw2OFgxHRwwTol0=";

        doCheck = false;
      };

      bluetui = pkgs.rustPlatform.buildRustPackage rec {
        pname = "bluetui";
        version = "v0.8.1";

        src = pkgs.fetchFromGitHub {
          owner = "pythops";
          repo = "bluetui";
          rev = "c959c09bb17bb8036b56980903fe9e1aaad655df";
          hash = "sha256-K+QAU9/XdGZonsKjBXbPbpJhWIHyaqxP6eb670n81LU=";
        };

        cargoHash = "sha256-i77j7hKtVxDDiHEBz5E7iwGXWYg0f/NfwFnN71QfgPU=";

        doCheck = false;
      };

      weathr = pkgs.rustPlatform.buildRustPackage rec {
        pname = "weathr";
        version = "v1.4.0";

        src = pkgs.fetchFromGitHub {
          owner = "Veirt";
          repo = "weathr";
          rev = "${version}";
          hash = "sha256-BaG8K17RNuswtGx74CEBzMKjFMaNW0RZ5FjM3EfSVTE=";
        };

        cargoHash = "sha256-xIjFleANgzoTS+4Yky+mvtX1IeU6IdaH1YuB8W8bYIo=";

        doCheck = false;
      };

    };

    appGo = {

      resterm = pkgs.buildGoModule rec {
        pname = "resterm";
        version = "v1.2.4";

        src = pkgs.fetchFromGitHub {
          owner = "unkn0wn-root";
          repo = "resterm";
          rev = "v1.2.4";
          hash = "sha256-vp1/yWDqx8fQp4NifjENr/x8e0TVSRlLYv7TshfwC2Y=";
        };

        vendorHash = "sha256-AYe9qB4t1ocL3qQpwXz1Rm91q238rD68ewcwjUxO9nM=";

        doCheck = false;
      };

    };

    appCpp = {

      btop = pkgs.stdenv.mkDerivation rec {
        pname = "btop";
        version = "1.4.7";

        src = pkgs.fetchFromGitHub {
          owner = "aristocratos";
          repo = "btop";
          rev = "v${version}";
          hash = "sha256-3gECGBSWcGTYQkUlD4X2zrxZVvH2x2xfh5zdZ2jJbDQ=";
        };

        nativeBuildInputs = with pkgs; [
          gnumake
        ];

        installPhase = ''
          mkdir -p $out/bin
          cp bin/btop $out/bin/
        '';

        doCheck = false;
      };

    };

    appC = {

      fastfetch = pkgs.stdenv.mkDerivation rec {
        pname = "fastfetch";
        version = "2.67.1";

        src = pkgs.fetchFromGitHub {
          owner = "fastfetch-cli";
          repo = "fastfetch";
          rev = "4dd2f2d";
          hash = "sha256-o4jjRkwrsfnnKiXxJZhTevw5x5zoXAn3XNprxEFWMmU=";
        };

        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
        ];

        doCheck = false;
      };

      tmux = pkgs.stdenv.mkDerivation rec {
        pname = "tmux";
        version = "master";

        src = pkgs.fetchFromGitHub {
          owner = "tmux";
          repo = "tmux";
          rev = "master";
          hash = "sha256-b7Zo3PGMU1Tlbj1yrSSx2gUGTdETCmPj3GkeOa/i9pQ=";
        };

        nativeBuildInputs = with pkgs; [
          autoconf
          automake
          pkg-config
        ];

        buildInputs = with pkgs; [
          libevent
          ncurses
          bison
        ];

        preConfigure = "sh autogen.sh ";

        doCheck = false;
      };

    };

    appPerl = {

      asciiquarium =
        let
          perlWithDeps = pkgs.perl.withPackages (ps: [
            ps.TermAnimation
          ]);
        in
        pkgs.stdenv.mkDerivation rec {
          pname = "asciiquarium";
          version = "1.6";

          src = pkgs.fetchFromGitHub {
            owner = "nothub";
            repo = "asciiquarium";
            rev = "3862efe961358d18649571e7dab4c18f7c2a74b0";
            hash = "sha256-kEA2r13Y9lbxGOqeZZXY8LJARMFXrQAS2Uhi14BE8B0=";
          };

          dontBuild = true;

          nativeBuildInputs = [
            pkgs.makeWrapper
          ];

          installPhase = ''
            install -Dm755 asciiquarium $out/bin/asciiquarium

            wrapProgram $out/bin/asciiquarium \
              --set PERL5LIB "${perlWithDeps}/lib/perl5/site_perl/5.42.0"
          '';
        };

    };

  };

  # ------ Android SDK

  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [
      "10"
      "16"
      "21"
      "36"
      "37"
    ];

    abiVersions = [
      "x86_64"
      "x86"
    ];

    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "default" ];
    includeNDK = true;
    includeSources = false;
  };

  androidSdk = androidComposition.androidsdk;

  # ------ GRUB :: Catppuccin Mocha Theme

  grubTheme = pkgs.runCommand "rama-grub-theme" { } ''
    mkdir -p $out

    cat > $out/theme.txt <<'EOF'
    # rama GRUB Theme
    # Catppuccin Mocha

    title-text: ""

    desktop-color: "${theme.current.bgDark}"

    terminal-font: "Unifont Regular 16"
    terminal-left: "0"
    terminal-top: "0"
    terminal-width: "100%"
    terminal-height: "100%"
    terminal-border: "0"

    # NixOS title

    + label {
      left = 50%-300
      top = 12%
      width = 600
      height = 40

      text = "NIXOS"

      align = "center"

      font = "Unifont Regular 24"

      color = "${theme.current.accent10}"
    }

    # Subtitle

    + label {
      left = 50%-300
      top = 18%
      width = 600
      height = 30

      text = "system generations"

      align = "center"

      font = "Unifont Regular 16"

      color = "${theme.current.muted}"
    }

    # Generation menu

    + boot_menu {
      left = 50%-300
      top = 30%
      width = 600
      height = 45%

      item_font = "Unifont Regular 16"
      selected_item_font = "Unifont Regular 16"

      item_color = "${theme.current.muted}"
      selected_item_color = "${theme.current.accent20}"

      item_height = 42
      item_padding = 8
      item_spacing = 6

      icon_width = 32
      icon_height = 32
      item_icon_space = 16

      scrollbar = false
    }

    # Countdown

    + label {
      left = 50%-300
      top = 82%
      width = 600
      height = 30

      align = "center"

      id = "__timeout__"

      text = "Booting in %d seconds"

      font = "Unifont Regular 16"

      color = "${theme.current.muted}"
    }

    # Countdown progress bar

    + progress_bar {
      left = 50%-300
      top = 88%
      width = 600
      height = 4

      id = "__timeout__"

      fg_color = "${theme.current.accent20}"
      bg_color = "${theme.current.bgAlt}"
      border_color = "${theme.current.bg}"
    }

    EOF
  '';

in
{

  # ------ Home Config

  system.activationScripts.coquiConfig = ''
    install -d -m 0755 /home/${username}/.config/rama/

    install -m 0644 \
      ${coquiConfig} \
      /home/${username}/.config/rama/coqui_config.toml

    chown ${username}:users \
      /home/${username}/.config/rama/coqui_config.toml
  '';

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

  # ------ Boot :: GRUB

  boot = {
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";

        gfxmodeEfi = "1024x600";
        gfxpayloadEfi = "keep";

        timeoutStyle = "menu";
        configurationLimit = 10;

        theme = grubTheme;
      };
    };
  };

  # ------ Hardware :: Audio

  security.rtkit.enable = true;

  # ------ Networking

  networking = {
    hostName = username;

    networkmanager.enable = false;

    wireless.iwd.enable = true;
  };

  hardware.bluetooth.enable = true;

  # ------ Users

  users.users.${username} = {
    isNormalUser = true;

    description = username;

    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  # ------ Security

  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=-1
  '';

  # ------ Services

  services = {

    xserver = {
      enable = true;

      # X11 keyboard layout
      xkb.layout = "carey";

      xkb.extraLayouts.carey = {
        description = "carey";

        languages = [
          "spa"
          "fra"
          "por"
          "ita"
          "ron"
          "cat"
          "glg"
          "oci"
          "srd"
          "lld"
          "roh"
          "ast"
          "arg"
          "cos"
          "wln"
          "mwl"
          "rup"
        ];

        symbolsFile = "${rama.app.carey}/xkb/symbols/carey";
      };

      # X11 input handling
      libinput = {
        enable = true;

        touchpad = {
          tapping = true;
        };
      };

      # i3
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3;
      };

      # Lightweight login manager
      displayManager.lightdm.enable = true;

      displayManager.autoLogin.enable = true;
      displayManager.autoLogin.user = username;
    };

    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    udisks2.enable = true;
    gvfs.enable = true;

    getty.autologinUser = username;
  };

  # ------ XDG portals

  xdg.portal = {
    enable = true;

    # No wlroots/Sway portal.
    wlr.enable = false;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # ------ Storage

  environment.pathsToLink = [
    "share/thumbnailers"
  ];

  # ------ Environment variables

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "i3";
    XDG_SESSION_DESKTOP = "i3";

    ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
  };

  # ------ Program :: i3

  environment.etc."i3/config".text = ''
    set $mod Mod4

    # Startup

    exec --no-startup-id dbus-update-activation-environment --systemd DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP=i3

    exec --no-startup-id systemctl --user import-environment DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP

    exec --no-startup-id udiskie

    exec --no-startup-id dunst

    exec --no-startup-id rama-battery-monitor

    exec --no-startup-id bluetoothctl power off

    # GTK theme
    exec --no-startup-id gsettings set org.gnome.desktop.interface gtk-theme 'Dracula'

    # Window decorations

    default_border pixel 1
    default_floating_border pixel 1

    # Window colors

    client.focused ${theme.current.accent10} ${theme.current.bgAlt} ${theme.current.fg} ${theme.current.accent10} ${theme.current.bgAlt}

    client.unfocused ${theme.current.bg} ${theme.current.bg} ${theme.current.muted} ${theme.current.bgAlt} ${theme.current.bg}

    # Gaps

    gaps inner ${theme.spacing.md}
    gaps outer ${theme.spacing.sm}

    # Terminal

    bindsym $mod+z exec --no-startup-id st

    # Application launcher

    bindsym $mod+space exec --no-startup-id rama-coqui-launch

    # Close window

    bindsym $mod+x kill

    # Reload i3

    bindsym $mod+r reload

    # Floating terminals

    for_window [class="floating-terminal"] \
      floating enable, \
      resize set 350 400, \
      move position center

    # Power

    bindsym $mod+Escape exec --no-startup-id rama-power-menu

    # Workspaces

    ${workspaceBindings}

    # Resizing

    bindsym $mod+comma resize shrink width 1 px
    bindsym $mod+period resize grow width 1 px

    # Volume

    bindsym XF86AudioMute exec --no-startup-id \
      wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

    bindsym XF86AudioLowerVolume exec --no-startup-id \
      wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-

    bindsym XF86AudioRaiseVolume exec --no-startup-id \
      wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+

    # Microphone

    bindsym XF86AudioMicMute exec --no-startup-id \
      wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

    # Brightness

    bindsym XF86MonBrightnessDown exec --no-startup-id \
      brightnessctl set 1%-

    bindsym XF86MonBrightnessUp exec --no-startup-id \
      brightnessctl set 1%+

    # Screenshot

    bindsym Print exec --no-startup-id \
      sh -c 'scrot - | xclip -selection clipboard -t image/png'

    # i3status bar

    bar {
      status_command i3status -c /etc/i3status.conf

      position top

      colors {
        background ${theme.current.bg}
        statusline ${theme.current.fg}
        separator ${theme.current.muted}

        focused_workspace ${theme.current.accent20} ${theme.current.accent20} ${theme.current.bg}
        active_workspace ${theme.current.bgAlt} ${theme.current.bgAlt} ${theme.current.fg}
        inactive_workspace ${theme.current.bg} ${theme.current.bg} ${theme.current.muted}
        urgent_workspace ${theme.current.danger} ${theme.current.danger} ${theme.current.bg}
      }
    }
  '';

  # ------ Program :: i3status

  environment.etc."i3status.conf".text = ''
    general {
      colors = true
      interval = 5

      color_good = "${theme.current.success}"
      color_bad = "${theme.current.danger}"
      color_degraded = "${theme.current.warning}"
    }

    order += "wireless _first_"
    order += "battery all"
    order += "volume master"
    order += "cpu_temperature 0"
    order += "disk /"
    order += "tztime local"

    wireless _first_ {
      format_up = "wifi:%quality %essid"
      format_down = "wifi:down"
    }

    battery all {
      format = "bat:%status %percentage"
      format_down = "bat:down"
      last_full_capacity = true
    }

    volume master {
      format = "snd:%volume"
      format_muted = "snd:muted"
    }

    cpu_temperature 0 {
      format = "temp:%degrees°C"
    }

    disk "/" {
      format = "disk:%avail"
    }

    tztime local {
      format = "%m/%d | %H:%M"
    }
  '';

  # ------ Program :: Dunst

  environment.etc."dunst/dunstrc".text = ''
    [global]
      monitor = 0
      follow = mouse

      width = 300
      height = 100

      origin = top-right
      offset = 10x10

      padding = 8
      horizontal_padding = 8

      frame_width = 2
      frame_color = "${theme.current.accent10}"

      background = "${theme.current.bg}"
      foreground = "${theme.current.fg}"

      font = "${theme.font.family} ${theme.font.size}"

      timeout = 5

    [urgency_low]
      background = "${theme.current.bg}"
      foreground = "${theme.current.muted}"

    [urgency_normal]
      background = "${theme.current.bg}"
      foreground = "${theme.current.fg}"

    [urgency_critical]
      background = "${theme.current.danger}"
      foreground = "${theme.current.bg}"
      frame_color = "${theme.current.danger}"
  '';

  # ------ Program :: Alacritty

  environment.etc."alacritty/alacritty.toml".text = ''
    [font]
    normal = { family = "${theme.font.family}" }
    size = ${theme.font.size}
  '';

  # ------ Services :: Polkit

  security.polkit.enable = true;

  # ------ Packages

  environment.systemPackages = builtins.concatLists (builtins.attrValues packages) ++ [
    rama.script.powerMenu
  ];

  # ------ Fonts

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # ------ Bash

  programs.bash = {
    enable = true;

    shellAliases = {
      ls = "ls --color=always --group-directories-first";
      rm = "rm -I --preserve-root";
      cp = "cp -i";
      mv = "mv -i";
      mkdir = "mkdir -p";
      ".." = "cd ..";
      weathr = "weathr --simulate thunderstorm --hide-hud";
      lotus = "lotus-test";
    };

    promptInit = ''
      ${bashColorInit}

      update() {
        clear

        current_generation=$(readlink /nix/var/nix/profiles/system | sed -E 's/[^-]*-([0-9]+)-link/\1/')

        printf '%b' "''${YELLOW}Updating NixOS generation ''${LIGHTCYAN}''${current_generation}''${RESET}\n\n"

        if ! sudo nixos-rebuild switch; then
          printf '%b\n' "''${LIGHTRED}Update failed.''${RESET}"
          return 1
        fi

        new_generation=$(readlink /nix/var/nix/profiles/system | sed -E 's/[^-]*-([0-9]+)-link/\1/')

        printf '%b' "\n''${YELLOW}Switched to NixOS generation ''${LIGHTCYAN}''${new_generation}''${RESET}\n"

        # Reload i3.
        i3-msg reload

        # Restart dunst.
        pkill dunst 2>/dev/null || true
        dunst >/dev/null 2>&1 &

        printf '%b\n' "''${LIGHTBLUE}Desktop reloaded.''${RESET}"
      }

      DIR="''${BOLD}''${LIGHTGREEN}"
      CMD="''${BOLD}''${LIGHTYELLOW}"

      PS1="\[$DIR\]\w\[$RESET\]\[$CMD\]\$\[$RESET\] "
    '';
  };

  # ------ State version

  system.stateVersion = "23.11";

}
