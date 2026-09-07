{
  stdenvNoCC,
  lib,
  pkgs,
}:
stdenvNoCC.mkDerivation {
  pname = "copilot";
  version = "0.1.0";

  src = ./.;
  nativeBuildInputs = with pkgs; [
    installShellFiles
    makeWrapper
  ];

  doCheck = true;
  checkInputs = with pkgs; [ shellcheck ];
  checkPhase = ''
    shellcheck ${./script.sh}
  '';

  installPhase = ''
    patchShebangs .
    install -Dm755 ${./script.sh} $out/bin/copilot
    wrapProgram $out/bin/copilot \
      --prefix PATH : ${
        lib.makeBinPath [
          pkgs.bubblewrap
        ]
      }
  '';
}
