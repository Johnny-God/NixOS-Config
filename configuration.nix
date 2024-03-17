# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

################################################################################################################################################# PACKAGES, PROGRAMS, AND SERVICES
{
    ### USER CONFIG
    users.users.ben = {
    isNormalUser = true;
    description = "Benjamin Wood";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      bambu-studio
      obsidian
      steam
      discord
      freecad
      bottles
    ];
  };

  # SYSTEM PACKAGES
  security.polkit.enable = true;
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    kdePackages.ktexteditor
    kdePackages.kate
    piper
     libratbag
    git
    appimagekit
    appimage-run
  ];

  ### ENABLE PROGRAMS
  programs.steam.enable = true;
  #programs.bambu-studio.enable = true;

  ### ENABLE SERVICES
  services.ratbagd.enable = true;

################################################################################################################################################# CUSTOM SYSTEM CONFIGURATION

      # Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

      # Recognize and Run AppImages
  boot.binfmt.registrations.appimage = {
  wrapInterpreterInShell = false;
  interpreter = "${pkgs.appimage-run}/bin/appimage-run";
  recognitionType = "magic";
  offset = 0;
  mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
  magicOrExtension = ''\x7fELF....AI\x02'';
};

      # Enable Nix Flakes
  nix.extraOptions = ''experimental-features = nix-command flakes'';

      # NVIDIA Drivers and OpenGL
  hardware.nvidia = {
    modesetting.enable = true;  # Required for the driver
    nvidiaSettings = true;      # Enable Nvidia settings GUI tool
    package = config.boot.kernelPackages.nvidiaPackages.stable; # Latest Stable Driver
  };

  services.xserver.videoDrivers = ["nvidia"];  # Tell Xorg to use the Nvidia driver

  hardware.opengl = {
  enable = true;
  driSupport = true;
  driSupport32Bit = true;
};


################################################################################################################################################# DEFAULT SYSTEM CONFIGURATION

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
 
  # Networking   
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Time zone.
  time.timeZone = "America/New_York";

  # Localization
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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

 
  # X11 Services (Windowing System, Keyboard Layout, and KDE Plasma)
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

