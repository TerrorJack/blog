let
  rev = "d4226e3a4b5fcf988027147164e86665d382bbfa";
  sha256 = "15rn7i0938sfl1v857mx6kqnqjpc80vha9fafj7nkd2ncjrbn2mc";
in
import (fetchTarball {
  inherit sha256;
  url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
})
