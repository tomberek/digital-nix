let name = "test";
in
{
  resources.sshKeyPairs.ssh-key = {};

  machine = { config, pkgs, lib, ... }: {
    #imports = [ ./xserver.nix ];
    deployment.targetEnv = "digitalOcean";
    deployment.digitalOcean.enableIpv6 = true;
    deployment.digitalOcean.region = "nyc1";
    deployment.digitalOcean.size = "1gb";
    deployment.digitalOcean.authToken = builtins.readFile ./secrets/DO_token.txt;

    # System packages installed
    environment.systemPackages = with pkgs; [
      openssh openssl sqlite-interactive vim tree gitAndTools.git tinc_pre];

    deployment.keys."openvpn.ovpn" = {
		text = builtins.readFile ./secrets/openvpn.ovpn;
	};
    services.openvpn.servers.testing = {
      config = ''
        config /run/keys/openvpn.ovpn
      '';
      autoStart = true;
    };

    # key-based access only
    services.openssh = {
      enable = true;
      challengeResponseAuthentication = false;
      passwordAuthentication = false;
    };

    users.users.tom = {
      initialPassword = builtins.readFile ./secrets/otp.txt;
      isNormalUser = true;
    };
    users.mutableUsers = false;
    #config.networking.hostName = "digital.tomberek.info";
    networking = {
      firewall = {
        allowedTCPPorts = [22 443 655 3389 8080];
        allowedUDPPorts = [443 655 1194];
      };
    };
    networking.nat = {
      enable = true;
      externalInterface = "ens3";
      internalInterfaces  = [ "vpn-dev" ];
    };
    networking.firewall.trustedInterfaces = [ "vpn-dev" ];

    # General security setting
    services.fail2ban.enable=true;
    services.fail2ban.jails.ssh-iptables2 = ''
      filter   = sshd[mode=aggressive]
      action = iptables-multiport[name=SSH, port="22", protocol=tcp]
      maxretry = 10
      '';
    services.fail2ban.jails.nginx-botsearch = ''
      filter   = nginx-botsearch
      action = iptables-multiport[name=NGINXBOT, port="443", protocol=tcp]
      '';
    services.fail2ban.jails.nginx-http-auth = ''
      filter   = nginx-http-auth
      action = iptables-multiport[name=NGINXAUTH, port="443", protocol=tcp]
      '';

    # Uses sslh to serve ssh and tinc over 443 if needed
    services.sslh = { enable = true;
                      listenAddress = "0.0.0.0";
                      verbose = false;
                      appendConfig = ''
      protocols:
      (
        { name: "ssh"; service: "ssh"; host: "localhost"; port: "22"; probe: "builtin"; },
        { name: "openvpn"; host: "localhost"; port: "1194"; probe: "builtin"; },
        { name: "http"; host: "localhost"; port: "80"; probe: "builtin"; },
        { name: "ssl"; host: "localhost"; port: "4430"; probe: "builtin"; },
        { name: "tinc"; host: "localhost"; port: "655"; probe: "builtin"; }
      );
    '';
    };

    
    /*
    # Layer 3
    services.tinc.networks."${name}" = {
      name = lib.replaceChars ["." "-"] ["_" "_"] config.networking.hostName;
      #interfaceType = "tap";
      chroot = false;
      # Mode = switch
      extraConfig = ''
        AutoConnect = yes
        LocalDiscovery = yes
        '';
      listenAddress = "0.0.0.0 655";
    };
    */

    # Mosh for latency-free interaction
    programs.mosh.enable=true;

    # Avahi for discovery - currently off
    services.avahi = { enable = false;
      #interfaces = [ "lo" "${name}" ];
      ipv6 = true;
      nssmdns = true;
      hostName = lib.replaceChars ["." "-"] ["_" "_"] config.networking.hostName;
      domainName = "local";
      wideArea = true;
      publish.enable=true;
      publish.domain=true;
      publish.addresses=true;
      publish.hinfo=true;
      publish.workstation=true;
      publish.userServices=true;
    };
  };

}
