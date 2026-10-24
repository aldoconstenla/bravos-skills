#!/bin/bash
# Prepara o lado do AGENTE: Tailscale em modo usuário (sem root, sem mexer na rede do container) + chave SSH própria.
# Uso: bash preparar.sh <AUTHKEY_DO_TAILSCALE> <nome-do-agente>
set -e
KEY="$1"; NOME="${2:-meu-agente}"
D="$HOME/.meu-pc"; mkdir -p "$D/bin"; chmod 700 "$D"
if [ ! -x "$D/bin/tailscaled" ]; then
  curl -fsSL https://pkgs.tailscale.com/stable/tailscale_latest_amd64.tgz -o "$D/ts.tgz"
  tar xzf "$D/ts.tgz" -C "$D" && cp "$D"/tailscale_*_amd64/tailscale "$D"/tailscale_*_amd64/tailscaled "$D/bin/" && rm -rf "$D"/tailscale_*_amd64 "$D/ts.tgz"
fi
[ -f "$D/chave" ] || ssh-keygen -q -t ed25519 -N "" -f "$D/chave" -C "agente-$NOME"
chmod 600 "$D/chave"
bash "$(dirname "$0")/ligar.sh" >/dev/null
"$D/bin/tailscale" --socket="$D/ts.sock" up --authkey="$KEY" --hostname="agente-$NOME" --accept-dns=false --accept-routes=false
# código de conexão pro dono colar no instalador do Windows (authkey + chave pública do agente)
python3 - "$KEY" "$D/chave.pub" <<'PY'
import sys,json,base64
print(base64.b64encode(json.dumps({"authkey":sys.argv[1],"pubkey":open(sys.argv[2]).read().strip()}).encode()).decode())
PY
