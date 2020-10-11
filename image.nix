{ pkgs, ... }:

rec {
  tier1-name = "opennic-tier1";

  tier1-docker = pkgs.dockerTools.buildImage {
    name = tier1-name;
    contents = [ pkgs.coreutils pkgs.bind ./named-tier1-conf ];

    config = {
      Entrypoint = [ "/bin/named" ];
      ExposedPorts = {
        "53/tcp" = {};
        "53/udp" = {};
      };
      Volumes = {
        "/zones" = {};
      };
    };
  };

  tier2-name = "opennic-tier2";

  tier2-docker = pkgs.dockerTools.buildImage {
    name = tier2-name;
    contents = [ pkgs.coreutils pkgs.bind ./named-tier2-conf ];

    config = {
      Entrypoint = [ "/bin/named" ];
      ExposedPorts = {
        "53/tcp" = {};
        "53/udp" = {};
      };
      Volumes = {
        "/zones" = {};
      };
    };
  };
}
