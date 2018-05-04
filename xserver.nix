{ config, pkgs, ...}:
{
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "${pkgs.icewm}/bin/icewm";
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    autorun = true;
  };
}
