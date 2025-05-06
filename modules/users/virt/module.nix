{
  lib,
  config,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.users.virt;
in {
  options.modules.users.virt.enable = mkEnableOption "Enable the Virt User";

  config = mkIf cfg.enable {
    users = {
      groups.virt = {};

      users.virt = {
        isNormalUser = true;
        extraGroups = [];
        group = "virt";
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvENmoNJtelL9NIB+c/KSanF5kajF+/SuS1FuA3n5a7l/XFEw0YHw8vRZqjsJYHHjCyKba0BZ0kVu96JtiLEcR6SE7rpESuJ8hVL0JS8sVCjp+jjpmMM60aOx7vXPqR6BiOnCK74EpucEXrotUl0KYD0TEwE9O1ArML9Pxz2VFQ/mFjmmGmOg46B3N302T6t4Ng+YzavUW9E5S1Lw5hxQPR2G4ujLSFeIwchTTqG7SpJfzmczJ8XPQ6SJ2fNTkXfTNBOBOe5d8g1XNrZz55njV9IWIIpnOPDpKfPYCuubiFgkQv89n7fpS/lLr1sNyYnGVowjamOI6GKzWmG+hqkpnLz0sx5clurr6nMYb6MlmFsBi9saBoWyVLAQOhrat882Sk3dd5NebEA5A53ctk4oVd92Wda6PYvaVsC5KC+fqztE1+Zvi8jJR21l3Yh/GmlRBplKp/WlUJ+MF9MD+/mOaU9Ca8EmibitIjEkv1/GnQHR2KsHaFBooF7pfBQh3mxhfE1RF6a1Y2zzSO5GDzdQlDCQmjvB8KT0vEScna5dhw9ys+sS8Q5pqtpouObUUL4DRFr27GUpzrdKNtrJ4bonWFhPeurQBsXEvpMT/Xl4rH0+2WNeiSmTv2+U8U1y7Ld+tQa296EfgZ+62CMQLV7JRuJYoPpkc6nNtCJ8FIJPrPw== joshua@board"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIffUHUiY5LIzpG5EfwT6mbulPlwejd7rSztrJmMohP1 backup@pool"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII9S1UMVtJr2CHLg2XuSMyl8m2F/ezKULST7kM7saY2r backup@home"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6sBthWuPYqE+Bds9QKfg9ka0L6CAXsf0NrEEIvbq6lJdUt34tp/IjPtJe0g0cydgXpdLk/hsOM1tn0h/hCXBy2YjUab/aJbRZPf+qXD9ZLg4o1w/nPc4a64BsLwYAdtiS9osq15zUpzibYRLaaKhLlF7v4LY0tiwU7hUO8kQs/jxDBDfvx4xTexCWHoWcBtX9xdQQSXqX3JKhVjQxMfsYxw1TJZ6LZduAIxo8kKKJ+WXl8JpORu+c98OQ++ed1UMIxaAeviOJ34+0EK/wDtakzqLUGXL7h5OZ07p7jBCiLo4WYhAMIwSS20tWP2J3aS02v0Xd+BAdsPW1iKIVlJGBK8XWDIlYn9+otJ+TR3DK9ROGFBKJlBCs7n7NBFchE/2NmI0O0DASm/jn6tjFumk7aOKvycCu102zTnxzpuO+1NlV/xmZS+DnQb/mQxZy+1CAKMmxBGoY+BiPHFpbpD7O59AY5fuOm2G/5J32CzKPXTuLdgjttzsPi/QkS7FFwh8= joshua@pad"
        ];
      };
    };

    home-manager.users.virt = {
      home = {
        username = "virt";
        homeDirectory = "/home/virt";
      };
    };
  };
}
