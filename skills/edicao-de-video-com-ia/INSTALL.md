# Instalação — edicao-de-video-com-ia

Siga a convenção do INSTALACAO.md da raiz. Esta skill substitui `editar-video-ffmpeg` e
`video-motion-design`: se alguma delas estiver instalada, apague a pasta antiga depois de copiar
esta (`rm -rf /data/.claude/skills/editar-video-ffmpeg /data/.claude/skills/video-motion-design`).

Dependências (confira e diga ao mentorado o que achou):
1. `ffmpeg -version` e `node -v` (Node 18 ou mais novo). Os dois já vêm no ambiente padrão.
2. Transcrição: variável `GROQ_API_KEY` ou `GROQ_API_KEYS` no ambiente (`env | grep -c GROQ`).
   Se não tiver, o Nível 1 funciona normal; no Nível 2 avise que precisa de transcrição.
3. Bibliotecas do navegador que o Remotion usa pra renderizar (só pro Nível 2). Teste:
   ```bash
   for l in libnss3.so libnspr4.so libatk-1.0.so.0 libatk-bridge-2.0.so.0 libcups.so.2 libXcomposite.so.1 libXdamage.so.1 libgbm.so.1 libxkbcommon.so.0 libasound.so.2; do ls /usr/lib/x86_64-linux-gnu/$l >/dev/null 2>&1 || echo "falta $l"; done
   ```
   Se aparecer "falta", NÃO tente instalar nada como root. Diga ao mentorado: "A edição simples já
   funciona. Pra edição com animação, preciso que a equipe de suporte da Bravos libere umas
   bibliotecas do navegador no meu ambiente (pedido técnico rápido)." e siga só com o Nível 1 até lá.
   Nota pra equipe de suporte (pacotes apt, sem reiniciar nada): libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0
   libcups2 libxcomposite1 libxdamage1 libgbm1 libxkbcommon0 e o de áudio, que muda de nome conforme o sistema:
   `libasound2` no Debian 12 (containers) e `libasound2t64` no Ubuntu 24.04 (servidores dedicados).
4. Não rode render de teste na instalação (é pesado). Confirme ao mentorado em 1-2 frases o que a
   skill faz e que ele já pode pedir.
