{
  stdenvNoCC,
  lib,
  pkgs,
}:
stdenvNoCC.mkDerivation {
  pname = "google-chrome-stable";
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
    install -Dm755 ${./script.sh} $out/bin/google-chrome-stable
    wrapProgram $out/bin/google-chrome-stable \
      --prefix PATH : ${
        lib.makeBinPath [
          pkgs.bubblewrap
        ]
      }
    substitute ${./google-chrome.desktop} \
      "$out/share/applications/google-chrome.desktop" \
      --replace-fail '@EXEC@' "$out/bin/chrome-wrapper %U"
  '';
}
