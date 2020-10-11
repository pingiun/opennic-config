{ config, pkgs, lib, ... }:

let

  image = import ./image.nix { inherit pkgs; };

  tier1-name = image.tier1-name;

  tier1-docker = image.tier1-docker;

  mnn-zone = pkgs.writeText "mnn.zone" ''
    $ORIGIN mnn.
    $TTL 24h

    mnn.  IN  SOA  ns1.mnn. hostmaster.pingiun.com. ( 2020101101 1800 900 604800 3600 )
    mnn.  IN  NS  ns1
    ns1    IN  A  159.69.80.121
    ns1    IN  AAAA  2a01:4f8:c2c:d45::2

    nic    IN  CNAME  blazeit.jelle.space.
  '';

in

{
  imports = [
    ./docker.nix
  ];

  config = {
    systemd.services.tier1dns = {
      description = "BIND Domain Name Tier 1 OpenNIC Server";
      after = [ "network.target" "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        outName="$(basename ${tier1-docker})"
        image="${tier1-name}:$(echo "$outName" | cut -d - -f 1)"

        cp ${mnn-zone} /persist/zones/mnn.zone

        ${pkgs.docker}/bin/docker load < ${tier1-docker}
      '';

      script = ''
        outName="$(basename ${tier1-docker})"
        image="${tier1-name}:$(echo "$outName" | cut -d - -f 1)"

        ${pkgs.docker}/bin/docker rm named || true
        ${pkgs.docker}/bin/docker run --name named -p 53:53 -p 53:53/udp -v /persist/zones:/zones $image -c /named-tier1.conf -fg
      '';

      preStop = ''
        ${pkgs.docker}/bin/docker stop named
      '';
    };
  };
}
