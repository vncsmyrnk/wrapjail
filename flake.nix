{
  description = "A collection of bwrap wrappers for safety reasons";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };

      googleChrome = pkgs.callPackage ./src/google-chrome { };
      claudeCode = pkgs.callPackage ./src/claude-code { };
      copilot = pkgs.callPackage ./src/copilot { };

      wrappers = pkgs.symlinkJoin {
        name = "wrappers-collection";
        paths = [
          googleChrome
          claudeCode
          copilot
        ];
      };

    in
    {
      packages.${system}.default = wrappers;
      apps.${system} = {
        install-xdg-env = {
          type = "app";
          program = "${pkgs.writeShellScript "install-xdg-env" ''
            mkdir -p "$HOME/.config/environment.d"
            ln -sfn ${pkgs.writeText "10-nix-xdg.conf" ''
              XDG_DATA_DIRS=''${HOME}/.nix-profile/share:/nix/var/nix/profiles/default/share:/usr/local/share:/usr/share
            ''} "$HOME/.config/environment.d/10-nix-xdg.conf"
          ''}";
        };
      };
    };
}
