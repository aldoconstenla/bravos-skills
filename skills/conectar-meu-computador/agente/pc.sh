#!/bin/bash
# Cliente do ajudante no PC do dono. Uso: pc.sh "cmd1" "cmd2" ...  |  pc.sh get <saida.png>  |  pc.sh teste
# Comandos: shot | move x,y | click x,y | dclick x,y | rclick x,y | type texto | key {SENDKEYS} | open url-ou-programa | wait ms
# Mande VÁRIOS comandos por chamada (1 ida e volta por lote).
D="$HOME/.meu-pc"; . "$D/pc.conf" || { echo "falta registrar o PC (registrar.sh)"; exit 1; }
bash "$D/ligar.sh"
O=(-i "$D/chave" -o StrictHostKeyChecking=accept-new -o "UserKnownHostsFile=$D/known_hosts" -o ConnectTimeout=15 -o ControlMaster=auto -o "ControlPath=$D/cm-%r@%h" -o ControlPersist=20m -o "ProxyCommand=$D/bin/tailscale --socket=$D/ts.sock nc %h %p")
H="$PC_USER@$PC_IP"
if [ "$1" = teste ]; then ssh "${O[@]}" "$H" 'powershell -NoProfile -Command "hostname; whoami"'; exit; fi
if [ "$1" = get ]; then scp -q "${O[@]}" "$H:C:/ProgramData/MeuAgente/io/screen.png" "$2"; exit; fi
printf '%s\r\n' "$@" | ssh "${O[@]}" "$H" 'powershell -NoProfile -Command "$io=''C:\ProgramData\MeuAgente\io''; Remove-Item $io\result.txt -EA 0; $input | Set-Content $io\cmd.tmp; Move-Item -Force $io\cmd.tmp $io\cmd.txt; for($i=0;$i -lt 300;$i++){ if(Test-Path $io\result.txt){ Start-Sleep -m 50; Get-Content $io\result.txt; break }; Start-Sleep -m 100 }"'
