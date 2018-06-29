let
  defaultPkgs = import <nixpkgs> {};
  pinnedPkgs = import (defaultPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "a8c71037e041"; # 21 June 2018
    sha256 = "1z4cchcw7qgjhy0x6mnz7iqvpswc2nfjpdynxc54zpm66khfrjqw";
  }) {};

in

{ nixpkgs ? pinnedPkgs }:

let
  pkgs = if nixpkgs == null then defaultPkgs else pinnedPkgs;

  buildTools = with pkgs; [
    awscli
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
        pip
        virtualenv
      ];
    })
  ];

  devEnv = with pkgs; buildEnv {
    name = "devEnv";
    paths = buildTools;
  };
in
  pkgs.runCommand "setupEnv" {
    buildInputs = [
      devEnv
    ];
    shellHook = ''
        export region=ap-southeast-2
    '';
  } ""
