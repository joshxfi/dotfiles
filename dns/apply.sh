#!/bin/sh
# Point system DNS at Cloudflare (1.1.1.1). This changes machine-wide network
# settings, so install.sh does not run it; rerun it by hand on each machine.

set -eu

ipv4='1.1.1.1 1.0.0.1'
ipv6='2606:4700:4700::1111 2606:4700:4700::1001'

case "$(uname -s)" in
  Darwin)
    # Set DNS on every enabled service backed by a device. VPN services such as
    # Tailscale have no device and keep their own DNS (MagicDNS).
    networksetup -listnetworkserviceorder |
      awk '/^\(\*\) / { name = ""; next }
           /^\([0-9]+\) / { sub(/^\([0-9]+\) /, ""); name = $0; next }
           /Device: [^)]/ && name != "" { print name; name = "" }' |
      while IFS= read -r service; do
        # shellcheck disable=SC2086 # Split the server lists into arguments.
        networksetup -setdnsservers "$service" $ipv4 $ipv6
        printf 'Applied:       Cloudflare DNS on %s\n' "$service"
      done

    dscacheutil -flushcache
    killall -HUP mDNSResponder 2>/dev/null || true
    ;;

  Linux)
    if command -v nmcli >/dev/null 2>&1; then
      # Global DNS overrides the servers each NetworkManager connection gets
      # from DHCP, so every Wi-Fi network uses Cloudflare.
      conf=/etc/NetworkManager/conf.d/90-cloudflare-dns.conf
      printf '[global-dns-domain-*]\nservers=%s\n' \
        "$(printf '%s %s' "$ipv4" "$ipv6" | tr ' ' ',')" |
        sudo tee "$conf" >/dev/null
      sudo nmcli general reload conf
      printf 'Applied:       Cloudflare DNS in %s\n' "$conf"
    elif command -v resolvectl >/dev/null 2>&1; then
      conf=/etc/systemd/resolved.conf.d/90-cloudflare-dns.conf
      sudo mkdir -p "$(dirname -- "$conf")"
      printf '[Resolve]\nDNS=%s %s\nDomains=~.\n' "$ipv4" "$ipv6" |
        sudo tee "$conf" >/dev/null
      sudo systemctl restart systemd-resolved
      printf 'Applied:       Cloudflare DNS in %s\n' "$conf"
    else
      printf 'Skipped DNS: neither nmcli nor resolvectl found\n' >&2
      exit 1
    fi
    ;;

  *)
    printf 'Unsupported operating system: %s\n' "$(uname -s)" >&2
    exit 1
    ;;
esac
