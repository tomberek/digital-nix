let
  nixpkgs = builtins.fetchTarball {
    url = "https://releases.nixos.org/nixpkgs/nixpkgs-19.03pre155263.20c4986c4dd/nixexprs.tar.xz";
    sha256 = "1nkvh8ypbckx4f47p6hdc66ban2irvb0bqj6zci8kkd59ssncldp";
    #url = "https://d3g5gsiof5omrk.cloudfront.net/nixos/unstable/nixos-18.09pre133640.ea145b68a01/nixexprs.tar.xz";
    #sha256 = "18x1wab5skbffaizwpavip4jqf7d7bmkaxzna95hd4ypa9xmynwx";
  };

  pkgs = import nixpkgs { config = {}; };
in nixpkgs
