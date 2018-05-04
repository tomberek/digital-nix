## Manging Digital Ocean server

### Why this is awesome

1. Reproducible server - kill it all and regenerate. Only things lost are user accounts and user-specific settings.
2. Like Terraform: manages VPC, subnets, elasticIP (unused for now), route tables, security groups, etc.
3. Updates are transactional and allows for rollback.
4. [Fail2ban](https://github.com/fail2ban/fail2ban) to quiet the noise of the internet
5. [sslh](https://linux.die.net/man/8/sslh) to allow 443 be used for SSH, HTTP, SSL, TINC, etc.
6. [Tinc VPN](https://www.tinc-vpn.org/) is a mesh-capable VPN.
7. [Mosh](https://mosh.org) for fast ssh
8. Can support larger networks of machines.

### Problems
1. Using a non-released and bleeding-edge version of nixops. This can be relaxed soon and we can clean up the boilerplate.
2. Collaborating in a team involves sharing the statefile. This can be done with GPG sharing, but is clunky. S3 support soon.
3. Supports Virtual Box, NixOS, AWS, GCE, Azure, Hetzner, Digital Ocean, libvirtd

### Using
These commands require three things:

1. [nix](https://nixos.org/nix/download.html) or run `make nix` in the top of this repo
2. access to `/server/<NAME>.nixops`: this is a statefile which manages deployments
3. access to `/server/secrets` directory (recommend to use git-crypt and the git-crypt.attributes file)

Both statefile and secrets are encrypted. Decrypt by having an admin add you to the [git-crypt](https://www.agwa.name/projects/git-crypt/) repo. You must have a GPG key. This is a **rough** overview of how to do this:
```bash
nix-env -iA nixpkgs.gnupg
gpg2 --full-generate-key
gpg2 -k  # this will show you your keys, find the id of your pub key
gpg2 --send-key <YOUR-PUB-KEY-ID>
# Contact an Admin who will add your key to the git repo, then in the repo:
git-crypt unlock
```
For a better GPG walkthrough, see [this page](https://alexcabal.com/creating-the-perfect-gpg-keypair/) or [GitHub's tutorial](https://help.github.com/articles/generating-a-new-gpg-key/).

#### Deploying the server
Ensure you have your authtoken in `./secrets/DO_token.txt` or wherever configuration.nix points to.
Pick a `NAME` such that the following will create `NAME.nixops` file in the current directory to track the state of this deployment:
```bash
./manage NAME create '<configuration.nix>'
```
or
```bash
./manage NAME create ./configuration.nix
```
Note: the former is harder to understand, but will be filesystem-location-independent. (You can move this folder around and everything will still work, portable). Then:
```bash
./manage NAME deploy
```
This will create the server, infect it with NixOS, deploy the configuration, activate services, etc.

#### SSH
At the moment, this will create a single machine, but can be easily extend such that this deployment manages multiple machines to whatever infrastructure desired. The following will SSH into your newly deployed box.
```bash
./manage NAME ssh machine
```

#### Update
```bash
./manage NAME deploy
```

### Destroy and Delete
```bash
./manage NAME destroy
./manage NAME delete
```

### Using Tinc VPN
`nix-env -iA nixpkgs.tinc_pre`

SSH into the server, adjust the `/var/run/tinc.NAME*/` file permissions and create an invitation. As root on the server:
```bash
./manage live ssh server
chown tinc.name /var/run/tinc.name*
tinc -n name invite <YOUR-COMPUTERS-NAME>
systemctl restart tinc.name
```

The output of the last command is used to join the network. You must also establish an IP. Avahi is the best. On your own computer:
```bash
tinc -n name join <output-of-invite-command>
echo "avahi-autoipd name -D" >> /etc/tinc/name/tinc-up
tinc -n name start
```
Then a cheap SOCKSv5 proxy for browsing can be made using the Avahi local link hostname:
```
ssh -D 8080 username@your-server -N
```

## Random notes
### Add user to GPG
```bash
git-crypt add-gpg-user USERID
```
