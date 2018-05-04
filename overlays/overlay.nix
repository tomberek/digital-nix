self: super: rec {
  nixopsUnstable2 = (super.callPackage <nixpkgs/pkgs/tools/package-management/nixops/generic.nix> ( rec {
      version = "1.6pre9999_f06763a"; #pre2282_08bb06c";
      src = super.fetchgit {
        url = "https://github.com/NixOS/nixops";
        #url = "https://hydra.nixos.org/build/64518294/download/2/nixops-${version}.tar.bz2";
        #sha256 = "1cl0869nl67fr5xk0jl9cvqbmma7d4vz5xbg56jpl7casrr3i51x";
        sha256 = "004hyp5bw9p9v7fag8d6ahnfz32bzfa5s7vqgkj06wizymcgb06h";
        rev = "f06763add1056124aaaa199d6616781b16d79b8e";
  };
    }
    )).overrideDerivation (oldAttrs: rec{
      namePrefix="";
      version = "1.6pre9999_f06763a"; #pre2282_08bb06c";
	  #buildInputs = [ self.pkgs.git self.pkgs.libxslt self.pkgs.docbook5_xsl ];
      patchPhase = ''
        for i in scripts/nixops setup.py doc/manual/manual.xml; do
            substituteInPlace $i --subst-var-by version ${version}
        done
        substituteInPlace nix/eval-machine-info.nix \
            --replace 'system.nixosVersion' 'system.nixos.version'
      '';
	  postInstall =
        ''
          # Backward compatibility symlink.
          ln -s nixops $out/bin/charon
          mkdir -p $out/share/nix/nixops
          cp -av nix/* $out/share/nix/nixops
        '';
		propagatedBuildInputs = with self.python2Packages;
		  [ prettytable
			boto
			boto3
			hetzner
			libcloud
			libvirt
			azure-storage
			azure-mgmt-compute
			azure-mgmt-network
			azure-mgmt-resource
			azure-mgmt-storage
			adal
			# Go back to sqlite once Python 2.7.13 is released
			pysqlite
			datadog
			digital-ocean
		  ];

    });
}
