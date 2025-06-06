{
  mkShell,
  pkgs,
  lib,
  ...
}:
mkShell {
  packages =
    with pkgs;
    [
      bun
      nodejs_20
      eslint_d
      typescript-language-server
      typescript
      claude-code
      csharpier
      csharp-ls
      (
        with dotnetCorePackages;
        combinePackages [
          dotnet-aspnetcore_8
          dotnet-runtime_8
          dotnet-sdk_8
        ]
      )
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      react-native-debugger
    ];

  shellHook = ''

    echo 🔨 Migrator DevShell


  '';
}
