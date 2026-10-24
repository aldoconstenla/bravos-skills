#!/bin/bash
# Grava o CÓDIGO DE RETORNO que o instalador do Windows mostrou (ip, nome, usuário).
# Uso: bash registrar.sh <CODIGO_DE_RETORNO>
D="$HOME/.meu-pc"
python3 - "$1" "$D/pc.conf" <<'PY'
import sys,json,base64
c=json.loads(base64.b64decode(sys.argv[1].strip()).decode())
open(sys.argv[2],'w').write(f'PC_IP={c["ip"]}\nPC_USER={c["usuario"]}\nPC_NOME={c.get("nome","")}\n')
print("ok:",c["nome"],c["ip"],c["usuario"])
PY
chmod 600 "$D/pc.conf"
