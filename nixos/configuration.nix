{
  config,
  pkgs,
  ...
}:

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
    # svg = { };
    # toml = { };
  };

  # ------ Vars :: Themes

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
      accent10 = "#cba6f7"; # mauve
      accent20 = "#b4befe"; # lavender
      danger = "#f38ba8"; # red
      warning = "#fab387"; # peach
      success = "#a6e3a1"; # green
    };

    melangeDark = {
      bg = "#161413";
      bgDark = "#221C18";
      bgAlt = "#322B24";
      fg = "#ECE1D7";
      muted = "#9C9187";
      accent10 = "#EBC06E";
      accent20 = "#D49A3A";
      danger = "#B65C60";
      warning = "#E49B5D";
      success = "#8CBBA1";
    };

    pomboverso = {
      bg = "#2E2C42";
      bgDark = "#2C2336";
      bgAlt = "#342A44";
      fg = "#ECE3F6";
      muted = "#B7AFD1";
      accent10 = "#B78ED7";
      accent20 = "#E081D8";
      danger = "#E081D8";
      warning = "#EC7CA7";
      success = "#B7AFD1";
    };

    tokyoNight = {
      bg = "#1A1B26";
      bgDark = "#3A524A";
      bgAlt = "#567468";
      fg = "#C0CAF5";
      muted = "#789488";
      accent10 = "#7AA2F7";
      accent20 = "#64A0D2";
      danger = "#F7768E";
      warning = "#FF9E64";
      success = "#9ECE6A";
    };

    dracula = {
      bg = "#282A36";
      bgDark = "#363849";
      bgAlt = "#424450";
      fg = "#F8F8F2";
      muted = "#4F5163";
      accent10 = "#BD93F8";
      accent20 = "#8BE9FB";
      danger = "#FF79C6";
      warning = "#FFB86C";
      success = "#50FA7B";
    };
  };

  theme = {
    # current = themes.tokyoNight;
    current = themes.catppuccinMocha // {
      # accent20 = "#f5c2e7"; # pink
      # accent20 = "#89b4fa"; # blue
      # accent20 = "#f38ba8"; # red
      # accent20 = "#a6e3a1"; # green
      accent20 = "#fab387"; # peach
      # accent20 = "#89dceb"; # sky
      # accent20 = "#b4befe"; # lavender
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
      waybar
      alacritty
      mako
      swaybg
      libnotify
      nemo-with-extensions
      mc
    ];

    themes = with pkgs; [
      dracula-theme
      adwaita-icon-theme
    ];

    system = with pkgs; [
      rama.appC.fastfetch
      rama.appCpp.btop
    ];

    office = with pkgs; [
      calcurse
      xournalpp
      # yazi
    ];

    commandUtils = with pkgs; [
      brightnessctl
      udiskie
      wl-clipboard
      grim
      slurp
      wf-recorder

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
      nodejs_26
      github-desktop
      nixfmt

      rama.appGo.lazygit
    ];

    developmentSql = with pkgs; [
      postgresql
    ];

    developmentRust = with pkgs; [
      rustc
      cargo
      rustfmt
      clippy
      gcc
      file
    ];

    # developmentGo = with pkgs; [
    #   go
    # ];

    developmentAndroid = with pkgs; [
      android-studio
      androidSdk
      android-tools
      universal-android-debloater
    ];

    developmentAndroidSamsung = with pkgs; [
      heimdall
      usbutils
    ];

    containers = with pkgs; [
      docker

      rama.appRust.oxker
    ];

    containersKudu = with pkgs; [
      qemu_kvm
      passt
      xorriso
      tigervnc
      rama.appRust.kudu
    ];

    creative = with pkgs; [
      blender
      gimp
      inkscape
      kdePackages.kdenlive

      imagemagick
      darktable
      imv
      cmus

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
      video-downloader
      ffmpeg
      vlc
    ];

    games = with pkgs; [
      supertux
      wesnoth
      ut1999
      mindustry
      veloren
      supertuxkart
    ];

    misc = with pkgs; [
      keepassxc
      xkeyboard-config
      libxkbcommon
      rama.appPerl.asciiquarium
      rama.appRust.weathr
      rama.appGo.tuios
    ];

    customApps = builtins.attrValues rama.app;
    scripts = builtins.attrValues rama.script;
  };

  # ------ Vars :: Sway

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
    cmd = "alacritty --class floating-terminal -e jaiba --slim"
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
    cmd = "alacritty -e mc"
    description = ""

    [[command]]
    label = "Impala"
    cmd = "alacritty -e impala"
    description = ""

    [[command]]
    label = "Bluetui"
    cmd = "alacritty -e bluetui"
    description = ""

    [[command]]
    label = "Wiremix"
    cmd = "alacritty -e wiremix"
    description = ""

    [[command]]
    label = "Btop"
    cmd = "alacritty -e btop"
    description = ""

    [[command]]
    label = "Caiman"
    cmd = "alacritty -e caiman"
    description = ""

    [[command]]
    label = "TUIOS"
    cmd = "alacritty -e tuios"
    description = ""

    [[command]]
    label = "Fastfetch"
    cmd = "alacritty -e fastfetch-launch"
    description = ""

    [[command]]
    label = "Calcurse"
    cmd = "alacritty -e calcurse"
    description = ""

    [[command]]
    label = "------ Development"

    [[command]]
    label = "VSCodium"
    cmd = "codium"
    description = ""

    [[command]]
    label = "Android Studio"
    cmd = "android-studio"
    description = ""

    [[command]]
    label = "Universal Android Debloater"
    cmd = "uad-ng"
    description = ""

    [[command]]
    label = "Github"
    cmd = "github-desktop"
    description = ""

    [[command]]
    label = "Kudu"
    cmd = "alacritty -e kudu"
    description = ""

    [[command]]
    label = "ResTerm"
    cmd = "alacritty -e resterm"
    description = ""

    [[command]]
    label = "Oxker"
    cmd = "alacritty -e oxker"
    description = ""

    [[command]]
    label = "------ Multimedia"

    [[command]]
    label = "Cmus"
    cmd = "alacritty -e cmus"
    description = ""

    [[command]]
    label = "VLC"
    cmd = "vlc"
    description = ""

    [[command]]
    label = "Video Downloader"
    cmd = "video-downloader"
    description = ""

    [[command]]
    label = "Inkscape"
    cmd = "inkscape"
    description = ""

    [[command]]
    label = "Blender"
    cmd = "blender"
    description = ""

    [[command]]
    label = "Gimp"
    cmd = "gimp"
    description = ""

    [[command]]
    label = "Kdenlive"
    cmd = "kdenlive"
    description = ""

    [[command]]
    label = "Darktable"
    cmd = "darktable"
    description = ""

    [[command]]
    label = "------ Games"

    [[command]]
    label = "Supertux 2"
    cmd = "supertux2"
    description = ""

    [[command]]
    label = "SuperTuxKart"
    cmd = "supertuxkart"
    description = ""

    [[command]]
    label = "Battle for Wesnoth"
    cmd = "wesnoth"
    description = ""

    [[command]]
    label = "Mindustry"
    cmd = "mindustry"
    description = ""

    [[command]]
    label = "Unreal Torunament 1999"
    cmd = "ut1999"
    description = ""

    [[command]]
    label = "Veloren"
    cmd = "veloren-voxygen"
    description = ""

    [[command]]
    label = "------ Extras"

    [[command]]
    label = "Weathr"
    cmd = "alacritty -e weathr"
    description = ""

    [[command]]
    label = "Asciiquarium"
    cmd = "alacritty -e asciiquarium"
    description = ""

    [[command]]
    label = "------ System"

    [[command]]
    label = "Sway Exit"
    cmd = "swaymsg exit"
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

  nixTheme = pkgs.writeText "nixos.toml" ''
    theme = "nixos"

    name = "NixOS"
    author = "Pombo"
    version = 1

    [colors]
    background = "${theme.current.bg}"
    text = "${theme.current.fg}"

    border = "${theme.current.muted}"
    header = "${theme.current.accent20}"
    accent = "${theme.current.accent20}"

    warning = "${theme.current.warning}"
    error = "${theme.current.danger}"
    success = "${theme.current.success}"

    selection_fg = "${theme.current.bg}"
    selection_bg = "${theme.current.accent10}"

    claws = "#89B4FA"
    claws_light = "#B4BEFE"
    claws_shadow = "#585B70"

    shell = "#45475A"
    shell_light = "#585B70"
    shell_shadow = "#313244"
  '';

  # ------ Custom Scripts

  rama = {
    script = {
      # waybarQuote = pkgs.writeShellScriptBin "rama-waybar-quote" ''
      #   quotes=(
      #     "be the problem you want to see in the world"
      #     "the horrors persist, but so do i"
      #     "wake up. commit nonsense."
      #     "have you tried turning yourself off and on again?"
      #     "god gives his hardest battles to his silliest soldiers"
      #     "another day, another poor decision"
      #   )

      #   printf '%s\n' "''${quotes[@]}" | ${pkgs.coreutils}/bin/shuf -n 1
      # '';

      waybarBluetooth = pkgs.writeShellScriptBin "rama-waybar-bluetooth" ''
        if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
          printf '{"text":"bt:1","class":"bt-on"}'
        else
          printf '{"text":"bt:0","class":"bt-off"}'
        fi
      '';

      waybarCamera = pkgs.writeShellScriptBin "rama-waybar-camera" ''
        if ls /dev/video* >/dev/null 2>&1; then
          printf '{"text":"cam:1","class":"active"}'
        else
          printf '{"text":"cam:0","class":"inactive"}'
        fi
      '';

      waybarMicrophone = pkgs.writeShellScriptBin "rama-waybar-microphone" ''
        mic=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)

        if echo "$mic" | grep -q MUTED; then
          printf '{"text":"mic:0","class":"inactive"}'
        else
          printf '{"text":"mic:1","class":"active"}'
        fi
      '';

      toggleSignals = pkgs.writeShellScriptBin "rama-toggle-signals" ''
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

      coquiLaunch = pkgs.writeShellScriptBin "rama-coqui-launch" ''
        if swaymsg '[app_id="^floating-terminal$"] focus' >/dev/null 2>&1; then
          exit 0
        fi

        exec alacritty --class floating-terminal -e coqui
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

        cargoHash = "sha256-mnjFMmwAyKkFA7uLl4Xdk8geI7ZlXP+niVqCEu2YOGI=";
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

      lotus-test = pkgs.rustPlatform.buildRustPackage rec {
        pname = "lotus-test";
        version = "2026.1";

        src = pkgs.fetchFromGitHub {
          owner = "lotus-io";
          repo = "lotus-test";
          rev = "47d74c161471224110469a5dfb988dc924930ac4";
          hash = "sha256-qzVKY2uxGvTp4waxtnilkjBngt+lTjdO5zfnAZq7PiQ=";
        };

        cargoHash = "sha256-6IfASHXXlD19BsyDwNyFTiOFCUBWmsbWfQFyyz/6sOQ=";
        doCheck = false;
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

      kudu = pkgs.rustPlatform.buildRustPackage rec {
        pname = "kudu";
        version = "v0.3.0";

        src = pkgs.fetchFromGitHub {
          owner = "pythops";
          repo = "kudu";
          rev = "${version}";
          hash = "sha256-6XPl51t7g0l7lMdC12fUyUsi/DSaX9D9mIO4X7EXYlc=";
        };

        cargoHash = "sha256-xILrjqBjWmBtzamXQ/fJuyPYn/Hq2thP3P9a+X6lYJU=";
        doCheck = false;
      };

      oxker = pkgs.rustPlatform.buildRustPackage rec {
        pname = "oxker";
        version = "v0.13.4";

        src = pkgs.fetchFromGitHub {
          owner = "mrjackwills";
          repo = "oxker";
          rev = "v0.13.4";
          hash = "sha256-5tbH4bLP6xFG+mf7YRjQryV7kwi9CwCzTp0KXkD858E=";
        };

        cargoHash = "sha256-pJAnR0P5/vA9HbljbC3XhQbpiSeq3oBDCCaMuwfzLZ4=";
        doCheck = false;
      };

      weathr = pkgs.rustPlatform.buildRustPackage rec {
        pname = "weathr";
        version = "v1.4.0";

        src = pkgs.fetchFromGitHub {
          owner = "Veirt";
          repo = "weathr";
          rev = "v1.4.0";
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

      lazygit = pkgs.buildGoModule rec {
        pname = "lazygit";
        version = "v0.64.1";

        src = pkgs.fetchFromGitHub {
          owner = "jesseduffield";
          repo = "lazygit";
          rev = "v0.64.1";
          hash = "sha256-UYyIrSHk+efKvHvxQs7FsOGA7e0uM9mg+1O1WRJIeEU=";
        };

        vendorHash = null;

        nativeCheckInputs = [
          pkgs.gitMinimal
        ];

        doCheck = false;
      };

      tuios = pkgs.buildGoModule rec {
        pname = "tuios";
        version = "v0.7.0";

        src = pkgs.fetchFromGitHub {
          owner = "Gaurav-Gosain";
          repo = "tuios";
          rev = "v0.7.0";
          hash = "sha256-XPcgUDlIbwp278Kc9B0aXxxIX2XnsJpFzxHDaop9cLs=";
        };

        vendorHash = "sha256-98XZe60gcRWyP0ApUV+qCJ0UoAExx7X0FPtFL0Tr0a4=";

        # nativeCheckInputs = [
        #   pkgs.gitMinimal
        # ];

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
  system.activationScripts.nixTheme = ''
    install -d -m 0755 /home/iqra/.config/rama/themes
    install -m 0644 ${nixTheme} /home/iqra/.config/rama/themes/nixos.toml
    chown iqra\:users /home/iqra/.config/rama/themes/nixos.toml
  '';

  system.activationScripts.coquiConfig = ''
    install -d -m 0755 /home/iqra/.config/rama/
    install -m 0644 ${coquiConfig} /home/iqra/.config/rama/coqui_config.toml
    chown iqra\:users /home/iqra/.config/rama/coqui_config.toml
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

  services.xserver.xkb.extraLayouts.carey = {
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

  # ------ Services :: PostgreSQL

  services.postgresql = {
    enable = true;

    ensureDatabases = [
      "iqra"
    ];

    ensureUsers = [
      {
        name = "iqra";
        ensureDBOwnership = true;
      }
    ];
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
    loader.systemd-boot.enable = false;

    loader.efi.canTouchEfiVariables = true;

    loader.grub = {
      enable = true;

      efiSupport = true;
      device = "nodev";

      gfxmodeEfi = "1920x1080";
      gfxpayloadEfi = "keep";

      timeoutStyle = "menu";

      configurationLimit = 10;
      theme = grubTheme;
    };

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

  # ------ Security
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=-1
  '';
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
    XDG_CURRENT_DESKTOP = "sway";
  };

  # ------ Virtualization
  # virtualisation.libvirtd.enable = true;
  # programs.virt-manager.enable = true;

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
    exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP=sway
    exec systemctl --user import-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP

    exec udiskie
    exec waybar --config /etc/waybar/config --style /etc/waybar/style.css
    exec rama-battery-monitor
    exec bluetoothctl power off
    exec swaybg -c '${theme.current.accent20}'

    # GTK theme
    exec gsettings set org.gnome.desktop.interface gtk-theme 'Dracula'

    # Window decorations
    default_border pixel 1
    default_floating_border pixel 1

    # Window colors
    client.focused ${theme.current.accent10} ${theme.current.bgAlt} ${theme.current.fg} ${theme.current.accent10} ${theme.current.bgAlt}
    client.unfocused ${theme.current.bg} ${theme.current.bg} ${theme.current.muted} ${theme.current.bgAlt} ${theme.current.bg}

    # Display
    output eDP-1 scale 2

    # Cursor
    seat seat0 xcursor_theme Adwaita 18

    # Keyboard
    input type:keyboard {
        xkb_layout carey
    }

    # Touchpad
    input type:touchpad {
        tap enabled
    }

    # Gaps
    gaps inner ${theme.spacing.md}
    gaps outer ${theme.spacing.sm}

    # Terminal
    bindsym $mod+z exec alacritty

    # Application launcher
    bindsym $mod+space exec rama-coqui-launch

    # Close window
    bindsym $mod+x kill

    # Reload Sway
    bindsym $mod+r reload

    # Floating Terminals
    for_window [app_id="floating-terminal"] floating enable, resize set width 350px height 400px, move position center

    # Power
    bindsym $mod+Escape exec swaynag \
      -t custom \
      -m 'Are you sure you want to shut down the computer?' \
      -Z 'Yes' 'systemctl poweroff' \
      -s 'No'

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
    bindsym --locked XF86TouchpadToggle exec rama-toggle-signals

    # Screenshot
    bindsym Print exec grim -g "$(slurp)" - | wl-copy
  '';

  environment.etc."swaynag/config".text = ''
    [custom]
    background=${theme.current.bgAlt}
    text=${theme.current.fg}
    button-background=${theme.current.accent10}
    button-text=${theme.current.bg}
    border=${theme.current.bgAlt}
    button-border-size=4
    button-padding=4
    button-gap=0
    button-dismiss-gap=4
  '';

  # ------ Program :: Waybar

  environment.etc."waybar/config".text = builtins.toJSON {
    layer = "top";
    position = "top";
    height = 26;
    spacing = theme.spacing.md;

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
      "custom/msg"
    ];

    # "custom/msg" = {
    #   exec = "${rama.script.waybarQuote}/bin/rama-waybar-quote";
    #   format = ":: {} ::";
    #   tooltip = false;
    # };

    "custom/camera" = {
      exec = "${rama.script.waybarCamera}/bin/rama-waybar-camera";
      interval = 2;
      "return-type" = "json";
      format = "{}";
      tooltip = false;
    };

    "custom/microphone" = {
      exec = "${rama.script.waybarMicrophone}/bin/rama-waybar-microphone";
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
      tooltip = false;
      "icon-size" = 16;
      "tooltip-format" = "{title}";
      "on-click" = "activate";
      "on-click-middle" = "close";
      "all-outputs" = true;
      "sort-by" = "name";
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
      exec = "${rama.script.waybarBluetooth}/bin/rama-waybar-bluetooth";
      interval = 5;
      "return-type" = "json";
      format = "{}";
      tooltip = false;
      "on-click" = "alacritty -e bluetui";
    };

    "sway/language" = {
      format = "kbd:{short}";
      tooltip = false;
      "on-click" = "alacritty -e caiman";
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

  environment.etc."waybar/style.css".text = parser.css {
    "*" = {
      "font-family" = "\"${theme.font.family}\"";
      "font-size" = "${theme.font.size}px";
    };

    "window#waybar" = {
      "background" = theme.current.bg;
      "color" = theme.current.fg;
    };

    "button, button:hover" = {
      "padding" = "0";
      "margin" = "0";
      "background" = "transparent";
      "border" = "0";
      "box-shadow" = "none";
      "text-shadow" = "unset";
      "outline" = "unset";
    };

    "#taskbar" = {
      "background-color" = theme.current.bgAlt;
      "border-radius" = "25px";
      "padding" = "0px ${theme.spacing.md}px";
      "margin" = "0 ${theme.spacing.sm}px";
    };

    "button label, #taskbar button, label" = {
      "color" = theme.current.muted;
      "border" = "none";
      "padding" = "0px ${theme.spacing.md}px";
      "margin" = "${theme.spacing.sm}px";
      "border-radius" = "25px";
      "font-weight" = "bold";
      "min-width" = "${theme.spacing.lg}px";
      "min-height" = "22px";
      "transition" = "0";
    };

    "button:hover label, #taskbar button:hover" = {
      "color" = theme.current.bg;
      "background" = theme.current.accent10;
    };

    "button.focused label" = {
      "color" = theme.current.bg;
      "background" = theme.current.accent20;
    };

    "#taskbar button.active" = {
      "background" = theme.current.accent20;
    };

    "button.urgent label" = {
      "color" = theme.current.bg;
      "background-color" = theme.current.warning;
    };

    "#custom-msg" = {
      color = theme.current.accent10;
      font-weight = "bold";
    };

    "#language" = {
      "min-width" = "70px";
    };

    "#custom-bluetooth.bt-on, #pulseaudio.muted, #battery.critical, #custom-camera.active, #custom-microphone.active" =
      {
        "color" = theme.current.bg;
        "background-color" = theme.current.danger;
      };

    "#battery.warning" = {
      "color" = theme.current.bg;
      "background-color" = theme.current.warning;
    };

    "#battery.charging, #temperature" = {
      "color" = theme.current.bg;
      "background-color" = theme.current.success;
    };

    "#network:hover, #custom-bluetooth:hover, #custom-microphone:hover, #language:hover, #pulseaudio:hover, #battery:hover, #temperature:hover, #clock:hover" =
      {
        "color" = theme.current.bg;
        "background-color" = theme.current.accent20;
      };
  };

  # ------ Program :: Mako

  environment.etc."mako/config".text = ''
    [mode=default]
    background-color=${theme.current.bg}
    text-color=${theme.current.fg}
    border-color=${theme.current.accent10}

    [urgency=critical]
    background-color=${theme.current.danger}
    text-color=${theme.current.bg}
    border-color=${theme.current.danger}
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

      record() {
        clear
        
        timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
        wf-recorder -o eDP-1 -f "$HOME/Videos/screen-$timestamp.mp4"
      }

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

        # Restart Sway components that don't automatically reload.
        swaymsg reload

        # Restart Waybar.
        pkill waybar 2>/dev/null || true
        nohup waybar --config /etc/waybar/config --style /etc/waybar/style.css >/dev/null 2>&1 &

        printf '%b\n' "''${LIGHTBLUE}Desktop reloaded.''${RESET}"
      }

      DIR="''${BOLD}''${LIGHTGREEN}"
      CMD="''${BOLD}''${LIGHTYELLOW}"

      PS1="\[$DIR\]\w\[$RESET\]\[$CMD\]\$\[$RESET\] "
    '';
  };

  # ------ Samsung Development

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", ATTR{idProduct}=="685d", TAG+="uaccess"
  '';

  # ------ State version

  system.stateVersion = "26.05";
}
