{
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
  lib,
  stdenv,
}:
rustPlatform.buildRustPackage rec {
  pname = "cserun";
  version = "0.1.1";

  nativeBuildInputs = lib.optionals stdenv.isLinux [pkg-config];

  buildInputs = lib.optionals stdenv.isLinux [openssl];

  src = fetchFromGitHub {
    owner = "xxxbrian";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-kjToOar+o2qYLNRFy07FBNKK6S2Yixeoo0iKbmADHsQ=";
  };

  cargoHash = "sha256-/53YMy0IASB+SrmF5edUCl3V5kIyylvgcUIGxvDdhWs=";

  meta = {
    description = "CSERun is a utility tool designed to assist UNSW CSE students in running course commands such as autotest and give in their local environment";
    homepage = "https://cserun.bojin.co";
    license = lib.licenses.mit;
  };
}
