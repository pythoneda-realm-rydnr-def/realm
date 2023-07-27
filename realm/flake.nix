{
  description = "Realm for pythoneda-realm-rydnr";
  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    pythoneda-realm-rydnr-events = {
      url = "github:pythoneda-realm-rydnr/events-artifact/0.0.1a2?dir=events";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-shared-pythoneda-domain.follows =
        "pythoneda-shared-pythoneda-domain";
    };
    pythoneda-shared-artifact-changes-events = {
      url =
        "github:pythoneda-shared-artifact-changes/events-artifact/0.0.1a5?dir=events";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-shared-pythoneda-domain.follows =
        "pythoneda-shared-pythoneda-domain";
    };
    pythoneda-shared-git-shared = {
      url = "github:pythoneda-shared-git/shared-artifact/0.0.1a7?dir=shared";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-shared-pythoneda-domain.follows =
        "pythoneda-shared-pythoneda-domain";
    };
    pythoneda-shared-pythoneda-domain = {
      url =
        "github:pythoneda-shared-pythoneda/domain-artifact/0.0.1a26?dir=domain";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        description = "Realm for pythoneda-realm-rydnr";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/pythoneda-realm-rydnr/realm";
        maintainers = [ "rydnr <github@acm-sl.org>" ];
        nixpkgsRelease = "nixos-23.05";
        shared = import ./nix/shared.nix;
        pythoneda-realm-rydnr-realm-for = { python, pythoneda-realm-rydnr-events
          , pythoneda-shared-artifact-changes-events
          , pythoneda-shared-git-shared, pythoneda-shared-pythoneda-domain
          , version }:
          let
            pname = "pythoneda-realm-rydnr-realm";
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            pythonpackage = "pythoneda.realm.rydnr";
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            pyprojectTemplateFile = ./pyprojecttoml.template;
            pyprojectTemplate = pkgs.substituteAll {
              authors = builtins.concatStringsSep ","
                (map (item: ''"${item}"'') maintainers);
              desc = description;
              inherit homepage pname pythonMajorMinorVersion pythonpackage
                version;
              package = builtins.replaceStrings [ "." ] [ "/" ] pythonpackage;
              pythonedaRealmRydnrEventsVersion =
                pythoneda-realm-rydnr-events.version;
              pythonedaSharedArtifactChangesEventsVersion =
                pythoneda-shared-artifact-changes-events.version;
              pythonedaSharedPythonedaDomainVersion =
                pythoneda-shared-pythoneda-domain.version;
              pythonedaSharedGitSharedVersion =
                pythoneda-shared-git-shared.version;
              src = pyprojectTemplateFile;
            };
            src = pkgs.fetchFromGitHub {
              owner = "pythoneda-realm-rydnr";
              repo = "realm";
              rev = version;
              sha256 = "sha256-TUH+QRpkL5j3UrsildOexTLqt4qWP7CjPsijKfpP0ao=";
            };

            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip pkgs.jq poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              pythoneda-realm-rydnr-events
              pythoneda-shared-artifact-changes-events
              pythoneda-shared-git-shared
              pythoneda-shared-pythoneda-domain
            ];

            checkInputs = with python.pkgs; [ pytest ];

            pythonImportsCheck = [ pythonpackage ];

            unpackPhase = ''
              cp -r ${src} .
              sourceRoot=$(ls | grep -v env-vars)
              chmod +w $sourceRoot
              cp ${pyprojectTemplate} $sourceRoot/pyproject.toml
            '';

            postInstall = ''
              pushd /build/$sourceRoot
              for f in $(find . -name '__init__.py'); do
                if [[ ! -e $out/lib/python${pythonMajorMinorVersion}/site-packages/$f ]]; then
                  cp $f $out/lib/python${pythonMajorMinorVersion}/site-packages/$f;
                fi
              done
              popd
              mkdir $out/dist
              cp dist/${wheelName} $out/dist
              jq ".url = \"$out/dist/${wheelName}\"" $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json > temp.json && mv temp.json $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json
            '';

            meta = with pkgs.lib; {
              inherit description homepage license maintainers;
            };
          };
        pythoneda-realm-rydnr-realm-0_0_1a2-for = { python
          , pythoneda-realm-rydnr-events
          , pythoneda-shared-artifact-changes-events
          , pythoneda-shared-git-shared, pythoneda-shared-pythoneda-domain }:
          pythoneda-realm-rydnr-realm-for {
            inherit python pythoneda-realm-rydnr-events
              pythoneda-shared-artifact-changes-events
              pythoneda-shared-git-shared pythoneda-shared-pythoneda-domain;
            version = "0.0.1a2";
          };
      in rec {
        packages = rec {
          pythoneda-realm-rydnr-realm-0_0_1a2-python38 =
            pythoneda-realm-rydnr-realm-0_0_1a2-for {
              python = pkgs.python38;
              pythoneda-realm-rydnr-events =
                pythoneda-realm-rydnr-events.packages.${system}.pythoneda-realm-rydnr-events-latest-python38;
              pythoneda-shared-artifact-changes-events =
                pythoneda-shared-artifact-changes-events.packages.${system}.pythoneda-shared-artifact-changes-events-latest-python38;
              pythoneda-shared-git-shared =
                pythoneda-shared-git-shared.packages.${system}.pythoneda-shared-git-shared-latest-python38;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python38;
            };
          pythoneda-realm-rydnr-realm-0_0_1a2-python39 =
            pythoneda-realm-rydnr-realm-0_0_1a2-for {
              python = pkgs.python39;
              pythoneda-realm-rydnr-events =
                pythoneda-realm-rydnr-events.packages.${system}.pythoneda-realm-rydnr-events-latest-python39;
              pythoneda-shared-artifact-changes-events =
                pythoneda-shared-artifact-changes-events.packages.${system}.pythoneda-shared-artifact-changes-events-latest-python39;
              pythoneda-shared-git-shared =
                pythoneda-shared-git-shared.packages.${system}.pythoneda-shared-git-shared-latest-python39;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python39;
            };
          pythoneda-realm-rydnr-realm-0_0_1a2-python310 =
            pythoneda-realm-rydnr-realm-0_0_1a2-for {
              python = pkgs.python310;
              pythoneda-realm-rydnr-events =
                pythoneda-realm-rydnr-events.packages.${system}.pythoneda-realm-rydnr-events-latest-python310;
              pythoneda-shared-artifact-changes-events =
                pythoneda-shared-artifact-changes-events.packages.${system}.pythoneda-shared-artifact-changes-events-latest-python310;
              pythoneda-shared-git-shared =
                pythoneda-shared-git-shared.packages.${system}.pythoneda-shared-git-shared-latest-python310;
              pythoneda-shared-pythoneda-domain =
                pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python310;
            };
          pythoneda-realm-rydnr-realm-latest-python38 =
            pythoneda-realm-rydnr-realm-0_0_1a2-python38;
          pythoneda-realm-rydnr-realm-latest-python39 =
            pythoneda-realm-rydnr-realm-0_0_1a2-python39;
          pythoneda-realm-rydnr-realm-latest-python310 =
            pythoneda-realm-rydnr-realm-0_0_1a2-python310;
          pythoneda-realm-rydnr-realm-latest =
            pythoneda-realm-rydnr-realm-latest-python310;
          default = pythoneda-realm-rydnr-realm-latest;
        };
        defaultPackage = packages.default;
        devShells = rec {
          pythoneda-realm-rydnr-realm-0_0_1a2-python38 = shared.devShell-for {
            package = packages.pythoneda-realm-rydnr-realm-0_0_1a2-python38;
            python = pkgs.python38;
            pythoneda-shared-pythoneda-domain =
              pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python38;
            inherit pkgs nixpkgsRelease;
          };
          pythoneda-realm-rydnr-realm-0_0_1a2-python39 = shared.devShell-for {
            package = packages.pythoneda-realm-rydnr-realm-0_0_1a2-python39;
            python = pkgs.python39;
            pythoneda-shared-pythoneda-domain =
              pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python39;
            inherit pkgs nixpkgsRelease;
          };
          pythoneda-realm-rydnr-realm-0_0_1a2-python310 = shared.devShell-for {
            package = packages.pythoneda-realm-rydnr-realm-0_0_1a2-python310;
            python = pkgs.python310;
            pythoneda-shared-pythoneda-domain =
              pythoneda-shared-pythoneda-domain.packages.${system}.pythoneda-shared-pythoneda-domain-latest-python310;
            inherit pkgs nixpkgsRelease;
          };
          pythoneda-realm-rydnr-realm-latest-python38 =
            pythoneda-realm-rydnr-realm-0_0_1a2-python38;
          pythoneda-realm-rydnr-realm-latest-python39 =
            pythoneda-realm-rydnr-realm-0_0_1a2-python39;
          pythoneda-realm-rydnr-realm-latest-python310 =
            pythoneda-realm-rydnr-realm-0_0_1a2-python310;
          pythoneda-realm-rydnr-realm-latest =
            pythoneda-realm-rydnr-realm-latest-python310;
          default = pythoneda-realm-rydnr-realm-latest;

        };
      });
}
