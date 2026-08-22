# Instalação — editar-video-ffmpeg

Siga a convenção do INSTALACAO.md da raiz. Depois de copiar a skill:

1. Verifique a dependência: `ffmpeg -version`.
2. Se não existir, instale conforme o sistema (`apt-get install -y ffmpeg` como root,
   ou avise o mentorado que pediu instalação ao suporte se você não tiver permissão).
3. Teste rápido: gere 1s de vídeo de teste
   `ffmpeg -f lavfi -i testsrc=duration=1:size=320x240:rate=10 /tmp/teste-skill.mp4`
   e apague em seguida. Se funcionou, confirme ao mentorado.
