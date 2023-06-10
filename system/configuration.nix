{ pkgs, lib, system, username, hostName, stateVersion, ... }:

{
  ${hostName} = lib.nixosSystem {
    inherit system;
    modules = [{
      imports = [ ./hardware-configuration.nix ];

      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.efi.efiSysMountPoint = "/boot/efi";

      networking = {
        inherit hostName;
        networkmanager.enable = true;
      };

      # Set your time zone.
      time.timeZone = "America/Sao_Paulo";

      # Select internationalisation properties.
      i18n.defaultLocale = "en_US.utf8";

      services = {
        gvfs.enable = true; # Nautilus file manager.
        joycond.enable = true;
        getty.autologinUser = username;

        dbus = {
          enable = true;
          packages = [ pkgs.dconf ];
        };

        xserver = {
          enable = true;
          layout = "us";
          videoDrivers = [ "nvidia" ];
          libinput = {
            enable = true;
            mouse = {
              accelProfile = "flat"; # Disable acceleration.
              middleEmulation = false; # Disable emulating middle click using left + right clicks;
            };
          };

          displayManager = {
            defaultSession = "none+i3";
            sddm.autoNumlock = true;

            autoLogin = {
              enable = true;
              user = username;
            };

            # Enable 240hz refresh rate.
            # setupCommands = "${pkgs.xorg.xrandr}/bin/xrandr --output DP-0 --mode 1920x1080 --rate 239.76";
          };

          windowManager.i3 = {
            enable = true;
            package = pkgs.i3-gaps;
          };
        };
      };

      console.useXkbConfig = true;

      hardware = {
        pulseaudio.enable = true;
        # opengl.driSupport32Bit = true; # Required for steam.
      };

      # Enable docker in rootless mode.
      virtualisation.docker.rootless = {
        enable = true;
        setSocketVariable = true;
      };

      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" "audio" "docker" ];
      };

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      environment = {
        # List packages installed in system profile. To search, run:
        # $ nix search wget
        systemPackages = with pkgs; [
          git
          docker-compose
          gnome.adwaita-icon-theme
          gnome.nautilus
        ];

        # Disable gui prompt when git asks for a password.
        extraInit = ''
          unset -v SSH_ASKPASS
        '';
      };

      fonts.fonts = with pkgs; [ nerdfonts ];

      # Open ports in the firewall.
      networking.firewall.allowedTCPPorts = [ 3000 8080 ];
      # networking.firewall.allowedUDPPorts = [ ... ];

      nix = {
        package = pkgs.nixFlakes;
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
        settings = {
          auto-optimise-store = true;
          experimental-features = [ "nix-command" "flakes" ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
          ];
          substituters = [
            "https://cache.nixos.org"
            "https://cache.iog.io"
          ];
        };
      };

      system.stateVersion = stateVersion;
    }];
  };
}
