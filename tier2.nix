{ config, pkgs, lib, ... }:

let

  image = import ./image.nix { inherit pkgs; };

  tier2-name = image.tier2-name;

  tier2-docker = image.tier2-docker;

in

{
  imports = [
    ./docker.nix
  ];

  config = {
    systemd.services.tier2dns = {
      description = "BIND Domain Name Tier 2 OpenNIC Server";
      after = [ "network.target" "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        outName="$(basename ${tier2-docker})"
        image="${tier2-name}:$(echo "$outName" | cut -d - -f 1)"

        ${pkgs.docker}/bin/docker load < ${tier2-docker}
      '';

      script = ''
        outName="$(basename ${tier2-docker})"
        image="${tier2-name}:$(echo "$outName" | cut -d - -f 1)"

        ${pkgs.docker}/bin/docker rm named || true
        ${pkgs.docker}/bin/docker run --name named -p 53:53 -p 53:53/udp -v /persist/zones:/zones $image -c /named-tier2.conf -fg
      '';

      preStop = ''
        ${pkgs.docker}/bin/docker stop named
      '';
    };
  };
}
