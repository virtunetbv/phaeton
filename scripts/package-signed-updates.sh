#!/usr/bin/env bash
# Wrap already signed release archives; never reads a private signing key.
set -euo pipefail
package_dir=${1:?Usage: package-signed-updates.sh DIST PUBLIC_KEY}
public_key=${2:?Usage: package-signed-updates.sh DIST PUBLIC_KEY}
openssl dgst -sha256 -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:digest \
  -verify "$public_key" -signature "$package_dir/SHA256SUMS.sig" "$package_dir/SHA256SUMS"
found=0
for package in "$package_dir"/phaeton-*.tar.gz; do
  [[ -f "$package" ]] || continue
  name=${package##*/}
  # USTAR names fit without GNU/PAX extension entries, which the device rejects.
  [[ ${#name} -le 100 && "$name" != *\\* ]] || { echo "Unsupported package name" >&2; exit 1; }
  expected=$(awk -v name="$name" '$2 == name || $2 == "*" name { print $1 }' "$package_dir/SHA256SUMS")
  actual=$(openssl dgst -sha256 "$package" | awk '{ print $NF }')
  [[ ${#expected} -eq 64 && "$expected" == "$actual" ]] || { echo "Signed checksum mismatch: $name" >&2; exit 1; }
  tar --format=ustar -cf "${package%.tar.gz}.phaeton-update" -C "$package_dir" "$name" SHA256SUMS SHA256SUMS.sig
  found=$((found + 1))
done
[[ $found -gt 0 ]] || { echo "No signed release packages found" >&2; exit 1; }
