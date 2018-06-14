# run with `nix-build shell.nix`, and then reference the bin/python in pycharm

with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "env";

  # Mandatory boilerplate for buildable env
  env = buildEnv { name = name; paths = buildInputs; };
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup; ln -s $env $out
  '';

  # Customizable development requirements
  buildInputs = [
    # Add packages from nix-env -qaP | grep -i needle queries
    jetbrains.pycharm-community
    vscode
    nodejs
    terraform_0_11
    plantuml

    # With Python configuration requiring a special wrapper
    (python36.buildEnv.override {
      ignoreCollisions = true;
      extraLibs = with python36Packages; [
        # Add pythonPackages without the prefix
        numpy
        scipy
      ];
    })
  ];

  # Customizable development shell setup
  shellHook = ''
  '';
}
