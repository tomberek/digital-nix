self: super: {
  nixopsMaster = super.nixopsUnstable.overrideAttrs (old: {
    src = super.fetchurl {
      url = "https://github.com/NixOS/nixops/archive/v1.6.tar.gz";
      sha256 = "00y2arc5rffvy6xmx4p6ibpjyc61k8dkiabq7ccwwjgckz1d2dpb";
    };
  });
}
