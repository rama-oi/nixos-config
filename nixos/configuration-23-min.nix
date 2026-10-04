{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "pam";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Los_Angeles";
  users.users.pam = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  security.sudo.wheelNeedsPassword = false;
  services.xserver = {
    enable = true;
    # displayManager.lightdm.enable = true;
    # displayManager.autoLogin.enable = true;
    # displayManager.autoLogin.user = "pam";
    windowManager.i3.enable = true;
    # libinput.enable = true;
  };
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # environment.systemPackages = with pkgs; [
  #   i3
  #   st
  #   caja
  # ];

  # environment.etc."i3/config".text = ''
  #   set $mod Mod4
  #   bindsym $mod+z exec st
  #   bindsym $mod+x kill
  # '';

  system.stateVersion = "23.11";
}