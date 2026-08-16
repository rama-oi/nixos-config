# NixOS Configurations

Just a bunch of nice things that I feel that make sense to share abotu how I keep my configuration organized. most of these things probably would look better in a different file but for now I'm enjoying having only one file that edit everything.

## Details

### CSS Parser

I had a situation where there were a lot of CSS escaped so having a JSON to CSS to make things looks more evenly sounded like a good idea. Also, let's keep in mind that the CSS I'm exporting is minified which is nice since I don't actually need to see the output anymore just the config o I can save some space.

```nix
environment.etc."wofi/catppuccin-mocha.css".text = css {
    "#window" = {
        "background-color" = theme.current.bg;
        "border: = "0 none";
        "border-radius" = "0";
    };

    "#outer-box" = {
        "padding" = "8px";
        "background-color" = theme.current.bg;
        "border" = "1px solid ${theme.current.blue}";
        "font-size" = "${theme.font.size}px";
        "font-family" = "\"${theme.font.family}\"";
    };
};
```

### Themes

Because there were a lot of styles from different modules (like Waybar and Wofi) having a global theme would save me some time and I didn't have to define variables in CSS anymore (which is less lines of the final code).

```nix
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
```

### Packages Organization

I used to have a long list now I can create small groups and always remember why I installed this things in the first place (avoiding million comments explaining this) so If I installed some modules for something like **pcmanfm** and then I remove the package I know exactly that I can remove this group entirely.

```nix
packages = {
    development = with pkgs; [
      ...
    ];

    developmentRust = with pkgs; [
      ...
    ];

    developmentAndroid = with pkgs; [
      ...
    ];

    developmentAndroidSamsung = with pkgs; [
      ...
    ];
};
```

### Desktop Entries

The idea behind this is that I want to be able to open TUI's with a single click so I'm wrapping everything into **alacritty** (my default terminal) and now I can run these apps from **wofi** or by clicking some icons in **waybar**.

```nix
desktop = {
    impala = pkgs.makeDesktopItem {
    name = "impala";
    desktopName = "Impala";
    comment = "Wi-Fi TUI";
    exec = "alacritty -e impala";
    terminal = false;
    categories = [ "Network" ];
    };
};
```

## Install

### Backup Default Configuration
Copy the original NixOS configuration before replacing it:
```sh
sudo cp -a /etc/nixos ~/git/81_cnf__nixos/backup/nixos
```

### Create Link
```sh
ln -sfn ~/git/81_cnf__nixos/nixos ./links/nixos
```

### Apply Custom Configuration System-Wide
Replace the default `/etc/nixos` directory with a symlink to the Git-managed configuration:
```sh
sudo rm -rf /etc/nixos
sudo ln -s ~/git/81_cnf__nixos/nixos /etc/nixos
```

### Verify the link:
```sh
ls -ld /etc/nixos
```

It should show:

```sh
/etc/nixos -> /home/iqra/git/81_cnf__nixos/nixos
```

### Rebuild

```sh
sudo nixos-rebuild switch
```