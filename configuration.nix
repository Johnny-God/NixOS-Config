########################################################################### USEFUL THINGS
  # GENERATIONS
  # Latest Known Good :41
  # Known Bad: 31, 32, 33, 34, 35

  # COMMANDS
  # Check Nvidia Driver Version
  #   nvidia-smi

  # Check NixOS Running Generations
  #   sudo nix-env --list-generations --profile /nix/var/nix/profiles/system :System Generation
  #   nix-env --list-generations :User Generation

  # Custom Commands
  # 1 "sudo nixos-rebuild switch"
  # 2 "sudo nixos-rebuild build"
  # 3 "sudo reboot" with confirmation

  # FORMATTING
  # Page Divider
  ################################################################


# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

########################################################### PACKAGES, PROGRAMS, AND SERVICES
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
      gitkraken

      # CUSTOM COMMANDS
      (writeShellScriptBin "1" ''
        #! ${pkgs.runtimeShell}
        echo "SUDO NIXOS-REBUILD SWITCH"
        sudo nixos-rebuild switch
      '')
      (writeShellScriptBin "2" ''
        #! ${pkgs.runtimeShell}
        echo "SUDO NIXOS-REBUILD BUILD"
        sudo nixos-rebuild build
      '')
      (writeShellScriptBin "3" ''
        #! ${pkgs.runtimeShell}
        echo "SUDO REBOOT"
        read -p "Reboot? (y/N): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
          echo "Rebooting..."
          wait 0.5
          sudo reboot
        else
          echo "Reboot canceled."
        fi
      '')
    ];
  };

  # SYSTEM PACKAGES
  environment.systemPackages = with pkgs; [
    vim
    kdePackages.ktexteditor
    kdePackages.kate
    piper
    libratbag
    git
    appimagekit
    appimage-run
    wine
    vulkan-loader
    clinfo
    glxinfo
    vulkan-tools
    pciutils
    aha
    wayland-utils
    protonup-ng
  ];

  ### ENABLE PROGRAMS
  programs.steam.enable = true;

  ### ENABLE SERVICES
  services.ratbagd.enable = true;

  ################################################################ CUSTOM SYSTEM CONFIGURATION

  # Linux kernel and Nvidia driver
  boot.kernelPackages = pkgs.linuxPackages_zen.extend (self: super: {
    nvidiaPackages = super.nvidiaPackages // { nvidia = self.nvidiaPackages.production; };
  });

  # Recognize & Run AppImages
  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };

  # Nvidia Driver
  hardware.nvidia = {
  modesetting.enable = true;
  open = false;
  nvidiaSettings = true;
  powerManagement.enable = false;
  powerManagement.finegrained = false;
  };

  # Enable 32-bit application support (optional but recommended)
  hardware.opengl.driSupport32Bit = true;

  # Enable Unfree Packages
  nixpkgs.config.allowUnfree = true;

################################################################ DEFAULT SYSTEM CONFIGURATION

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

 
  # X11 Services (Windowing System, Keyboard Layout, KDE Plasma)
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
    displayManager.sddm.enable = true;
    videoDrivers = ["nvidia"];
  };
  services.desktopManager.plasma6.enable = true;

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
  # settings for stateful data, like file locations & database versions
  # on your system were taken. It‘s perfectly fine & recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

