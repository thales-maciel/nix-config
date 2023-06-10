{ pkgs, system, home-manager, username, stateVersion, ... }:

let
  stablePackages = with pkgs; [
    # Shell
    zplug
    bat
    lsd
    htop
    tmux
    fzf
    lazygit
    lazydocker
    ranger
    jq
    dunst
    espanso
    fnm
    haskellPackages.greenclip

    # Applications
    vscode
    discord
    peek
    obs-studio
    vlc
    ferdium
    openvpn3
    firefox

    # Desktop
    htop
    xbanish
    neofetch
    xclip
    ripgrep
    unzip
    p7zip
    unrar
  ];
  unstablePackages = with pkgs.unstable; [
    # Applications
    spotify

    #Libraries
    ffmpeg-full
  ];
in
{
  ${username} = home-manager.lib.homeManagerConfiguration {
    inherit pkgs system username stateVersion;
    homeDirectory = "/home/${username}";
    configuration = {
      programs.home-manager.enable = true;
      home.packages = stablePackages ++ unstablePackages;

      # Restart services on change
      systemd.user.startServices = "sd-switch";

      imports = (import ./programs) ++ (import ./services);
    };
  };
}
