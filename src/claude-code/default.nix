{
  stdenvNoCC,
  lib,
  pkgs,
}:
stdenvNoCC.mkDerivation {
  pname = "claude";
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
    mkdir -p "$out/bin" "$out/share/applications"
    install -Dm755 ${./script.sh} $out/bin/claude
    wrapProgram $out/bin/claude \
      --prefix PATH : ${
        lib.makeBinPath [
          pkgs.bubblewrap
        ]
      }
  '';
}
