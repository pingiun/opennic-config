# opennic-config
Configuration files to create a opennic (secondary) server

## How to use

I use nixops to deploy a tier1 and tier2 server. Here is the configuration I use for one of my servers:

```nix
{
  lowii = { nodes, lib, ... }: {
    deployment.targetHost = "lowii.jelle.space";

    imports = [
      ./hardware/lowii.nix
      ./modules/opennic-config/tier2.nix
      ./modules/update-docker.nix
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    networking.hostId = "4eac9b68";

    nixpkgs.localSystem.system = "x86_64-linux";

    networking.useDHCP = false;
    networking.interfaces.ens2.useDHCP = true;

    networking.firewall.interfaces.ens2.allowedUDPPorts = [ 53 ];
    networking.firewall.interfaces.ens2.allowedTCPPorts = [ 53 ];
  };
}
```

A Docker container is automatically generated from the nix definitions. You should look up the latest version on the [Docker hub](https://hub.docker.com/repository/registry-1.docker.io/pingiun/opennic-tier2/tags?page=1).

You can use the following command to get a tier2 server running:

```shell
docker run --name named -p 53:53 -p 53:53/udp -v /place/for/zones:/zones pingiun/opennic-tier2:<latest version> -c /named-tier2.conf -fg
```

The Docker includes a config which uses my tier1 server as a primary, and serves the micronations TLDs.
