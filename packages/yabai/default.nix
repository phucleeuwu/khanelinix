{
  lib,
  fetchFromGitHub,
  installShellFiles,
  xcbuild,
  xxd,
  apple-sdk_15,
  darwinMinVersionHook,
  llvmPackages_19,
  nix-update-script,
  versionCheckHook,
}:
let
  inherit (llvmPackages_19) stdenv;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "yabai";
  version = "7.1.4";

  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = "yabai";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-i/UqmBNTLBYY4ORI1Y7FWr+LZK0f/qMdWLPPuTb9+2w=";
  };

  nativeBuildInputs = [
    installShellFiles
    xcbuild
    xxd
  ];

  buildInputs = [
    (darwinMinVersionHook "11.0")
    apple-sdk_15
  ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/icons/hicolor/scalable/apps}

    cp ./bin/yabai $out/bin/yabai
    ${lib.optionalString stdenv.hostPlatform.isx86_64 "cp ./assets/icon/icon.svg $out/share/icons/hicolor/scalable/apps/yabai.svg"}
    installManPage ./doc/yabai.1

    runHook postInstall
  '';

  postPatch = # bash
    ''
      # aarch64 code is compiled on all targets, which causes our Apple SDK headers to error out.
      # Since multilib doesn't work on darwin i dont know of a better way of handling this.
      substituteInPlace makefile \
      --replace-fail "-arch arm64e" "" \
      ${lib.optionalString stdenv.isAarch64 ''--replace-fail '-arch x86_64' "-arch arm64" ''} \
      ${lib.optionalString stdenv.isx86_64 ''--replace-fail '-arch arm64' "" ''} \
      --replace-fail "clang" "${stdenv.cc.targetPrefix}clang"
    '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tiling window manager for macOS based on binary space partitioning";
    longDescription = ''
      yabai is a window management utility that is designed to work as an extension to the built-in
      window manager of macOS. yabai allows you to control your windows, spaces and displays freely
      using an intuitive command line interface and optionally set user-defined keyboard shortcuts
      using skhd and other third-party software.
    '';
    homepage = "https://github.com/koekeishiya/yabai";
    changelog = "https://github.com/koekeishiya/yabai/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "yabai";
    maintainers = with lib.maintainers; [
      cmacrae
      shardy
      khaneliman
    ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
