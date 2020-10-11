{ config, pkgs, lib, ... }:

{
  config = {
    virtualisation.docker = {
      enable = true;
      autoPrune = {
        enable = true;
        flags = [ "--all" ];
      };
    };
  };
}
