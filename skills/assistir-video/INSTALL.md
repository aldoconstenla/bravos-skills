# Instalação — assistir-video

Siga a convenção do INSTALACAO.md da raiz. Depois de copiar a skill:

1. Confirme o ffmpeg: `ffmpeg -version`.
2. Instale o yt-dlp (arquivo único, build oficial do projeto yt-dlp no GitHub; a versão nightly acompanha melhor as mudanças dos sites):
   `mkdir -p ~/.local/bin && curl -sL https://github.com/yt-dlp/yt-dlp-nightly-builds/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp && chmod +x ~/.local/bin/yt-dlp && ~/.local/bin/yt-dlp --version`
3. Confirme que existe a variável `GROQ_API_KEYS` (só confira se existe, NUNCA mostre o valor): `[ -n "$GROQ_API_KEYS" ] && echo ok`.
   Se não existir, avise o mentorado que vai precisar abrir um chamado no botão Suporte pra liberar a transcrição.
4. Teste rápido sem internet: gere 3s de vídeo de teste, rode os passos 2 e 3 da skill e confirme que saiu `folha_01.jpg`:
   `ffmpeg -f lavfi -i testsrc=duration=3:size=320x240:rate=10 /tmp/v-teste.mp4`, depois apague tudo.
5. Confirme ao mentorado: "Agora eu consigo assistir vídeos! O jeito mais garantido é me mandar o ARQUIVO do vídeo aqui. Link às vezes funciona, mas TikTok e Instagram costumam bloquear, e YouTube e cursos fechados (Hotmart etc.) não dá por aqui."
