#!/bin/bash
# Garante o tailscaled (modo usuário) rodando. Idempotente: pode chamar sempre antes de usar.
D="$HOME/.meu-pc"
"$D/bin/tailscale" --socket="$D/ts.sock" status >/dev/null 2>&1 && exit 0
nohup "$D/bin/tailscaled" --tun=userspace-networking --state="$D/ts.state" --socket="$D/ts.sock" >"$D/tailscaled.log" 2>&1 &
for i in $(seq 1 20); do "$D/bin/tailscale" --socket="$D/ts.sock" status >/dev/null 2>&1 && exit 0; sleep 1; done
exit 0
