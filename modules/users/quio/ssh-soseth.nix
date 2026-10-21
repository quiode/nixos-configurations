{...}: let
  # Replace this with your SOSETH username.
  sosethUser = "dschwaiger";

  # Copy the private key to this path, or change it to the key you use.
  sosethIdentityFile = "~/.ssh/id_ed25519";

  userHosts = [
    "cm-lee.sos.ethz.ch"
    "cm.sos.ethz.ch"
    "cm-hci.sos.ethz.ch"
    "sender.sos.ethz.ch"
    "portal-hci.sos.ethz.ch"
    "portal-lee.sos.ethz.ch"
    "radiuscd.sos.ethz.ch"
    "mixer.sos.ethz.ch"
    "beast.sos.ethz.ch"
  ];

  rootHosts = [
    "comp-4.sos.ethz.ch"
    "comp-epyc-lee-1.sos.ethz.ch"
    "comp-epyc-lee-2.sos.ethz.ch"
    "comp-epyc-lee-3.sos.ethz.ch"
    "comp-epyc-lee-4.sos.ethz.ch"
    "app.vsos.ethz.ch"
    "bak-1.sos.ethz.ch"
    "ceph-a.sos.ethz.ch"
    "ceph-b.sos.ethz.ch"
    "ceph-c.sos.ethz.ch"
    "dc1.sos.ethz.ch"
    "dc2.sos.ethz.ch"
    "app-1.sos.ethz.ch"
    "app-2.sos.ethz.ch"
    "apt.sos.ethz.ch"
    "box.sos.ethz.ch"
    "ci-1.sos.ethz.ch"
    "ci-2.sos.ethz.ch"
    "comp-ivy-cab-1.sos.ethz.ch"
    "ctrl.sos.ethz.ch"
    "git.sos.ethz.ch"
    "latex.vsos.ethz.ch"
    "maas.sos.ethz.ch"
    "mail-1.sos.ethz.ch"
    "mail-2.sos.ethz.ch"
    "mail-gate-alpha.sos.ethz.ch"
    "mail-gate-beta.sos.ethz.ch"
    "manage.vsos.ethz.ch"
    "mon-cab.sos.ethz.ch"
    "mon-hci.sos.ethz.ch"
    "mon-lee.sos.ethz.ch"
    "pwd.sos.ethz.ch"
    "relay-radius.sos.ethz.ch"
    "reservation.sos.ethz.ch"
    "status.vsos.ethz.ch"
    "stor-1.sos.ethz.ch"
    "webmail.sos.ethz.ch"
    "webmail-new.sos.ethz.ch"
    "mon.sos.ethz.ch"
    "app-3.sos.ethz.ch"
    "chat.sos.ethz.ch"
    "files.sos.ethz.ch"
  ];

  mkHost = user: {
    User = user;
    IdentityFile = sosethIdentityFile;
  };

  hostSettings =
    builtins.listToAttrs (map (host: {
        name = host;
        value = mkHost sosethUser;
      })
      userHosts)
    // builtins.listToAttrs (map (host: {
        name = host;
        value = mkHost "root";
      })
      rootHosts)
    // {
      "vmwiz.vsos.ethz.ch" = {
        User = "root";
        IdentityFile = sosethIdentityFile;
        Port = 2222;
      };
    };
in {
  programs.ssh.settings = hostSettings;
}
