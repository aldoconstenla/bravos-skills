---
name: assistir-video
description: Assistir um vídeo de verdade (TikTok, Reels, vídeo enviado pelo WhatsApp/painel ou link público de arquivo) — baixa, separa os quadros nas mudanças de cena, monta uma folha de quadros, transcreve a fala com os tempos e cruza tudo. Use sempre que o mentorado mandar um vídeo ou link e pedir pra você "ver", "assistir", "analisar", "resumir" ou "modelar" o vídeo.
---

# Assistir vídeo

Você CONSEGUE assistir vídeos. Não diga que não consegue. Você não "vê" o arquivo direto: você o transforma em duas coisas que consegue ler, e cruza as duas.
1. **Folha de quadros:** imagens do vídeo, tiradas em cada mudança de cena e no mínimo 1 a cada 2,5 s, com o horário gravado em cada uma.
2. **Transcrição com tempos:** o que é falado, minuto a minuto.

## Quando usar
O mentorado mandou um vídeo (arquivo no WhatsApp/painel) ou um link, e quer que você veja, resuma, analise, extraia o roteiro ou modele o formato.

## O que dá e o que NÃO dá (fale isso com clareza se for o caso)
- ✅ **Dá sempre:** vídeo enviado como arquivo (WhatsApp, painel). Esse é o caminho mais garantido.
- ✅ **Por link:** TikTok, Reels públicos, link direto de arquivo (.mp4, Google Drive público) e a maioria dos sites públicos que o `yt-dlp` suporta.
- ⚠️ Se um link der erro (as redes mudam de vez em quando), tente atualizar o yt-dlp UMA vez (repita o passo 2 do INSTALL.md); se continuar, peça pro mentorado salvar o vídeo no celular e te mandar o ARQUIVO aqui. Não insista nem tente contornar bloqueio.
- ❌ **YouTube:** bloqueia downloads vindos de servidores como o seu. Peça o arquivo do vídeo, ou que o mentorado cole a transcrição.
- ❌ **Cursos fechados (Hotmart, Kiwify, área de membros):** mesmo com usuário e senha, esta skill não entra em plataforma de curso. Diga que não é por aqui e sugira enviar o arquivo da aula, se ele tiver direito de baixar.
- ❌ **Vídeo privado ou que exige login:** peça o arquivo.

## Passo a passo
Trabalhe numa pasta própria: `D=/tmp/video-$(date +%s); mkdir -p $D; cd $D`

**1. Pegar o vídeo**
- Se for arquivo: copie pra `$D/v.mp4`.
- Se for link: `~/.local/bin/yt-dlp -q --no-warnings -o "v.%(ext)s" --merge-output-format mp4 "<link>"`
- Se falhar, diga com honestidade e de forma simples ("não consegui baixar por esse link") e peça o arquivo. Não tente contornar bloqueio.

**2. Quadros nas mudanças de cena + 1 a cada 2,5 s (com o horário gravado)**
```
ffmpeg -loglevel error -i v.mp4 -vf "select='isnan(prev_selected_t)+gte(t-prev_selected_t\,2.5)+gt(scene\,0.35)*gte(t-prev_selected_t\,0.8)',scale=270:-2,drawtext=text='%{pts\:hms}':x=6:y=6:fontsize=20:fontcolor=yellow:box=1:boxcolor=black@0.6" -vsync vfr f_%03d.jpg
```
- Quem detecta a mudança de cena é o ffmpeg, comparando os pixels de um quadro com o anterior, antes de você ver qualquer coisa. Isso não gasta nada.
- Vídeo com mais de 10 min: troque `2.5` por `8` pra não gerar quadros demais.

**3. Folha de quadros (32 por folha, 8 colunas × 4 linhas)**
```
ffmpeg -loglevel error -y -i f_%03d.jpg -vf "tile=8x4:padding=4:color=white" folha_%02d.jpg
```
Leia CADA `folha_XX.jpg` com a sua ferramenta de ler imagens.

**4. Transcrever a fala (com tempos)**
```
ffmpeg -loglevel error -y -i v.mp4 -vn -ac 1 -ar 16000 -b:a 48k a.mp3
KEY=$(echo "$GROQ_API_KEYS" | cut -d, -f1)
curl -s https://api.groq.com/openai/v1/audio/transcriptions -H "Authorization: Bearer $KEY" \
  -F file=@a.mp3 -F model=whisper-large-v3 -F language=pt -F response_format=verbose_json > t.json
python3 -c "import json;d=json.load(open('t.json'));[print(f\"[{int(s['start'])//60}:{int(s['start'])%60:02d}] {s['text'].strip()}\") for s in d.get('segments',[])]"
```
- Nunca mostre nem repita a chave.
- Se a primeira chave der erro de limite, tente a próxima (`-f2`, `-f3`…).
- Áudio maior que 25 MB: corte em partes de 20 min antes de transcrever.

**4b. Apagar o vídeo JÁ (obrigatório)**
Depois de gerar as folhas e o `a.mp3`, apague o vídeo na hora: `rm -f $D/v.mp4 $D/v.*`.
Vídeo ocupa muito espaço, e o servidor é compartilhado. Você não precisa mais dele: tudo o que importa já está nas folhas e na transcrição.

**5. Cruzar e responder**
Junte fala e imagem pelo horário. Na resposta ao mentorado:
- do que o vídeo trata, em 1–2 frases;
- a estrutura: gancho dos primeiros 3 s, blocos, CTA final;
- o que aparece NA TELA e não é falado: textos, tabelas, gráficos, cortes, b-roll. É aqui que você mostra que assistiu de verdade.
- o formato: duração, ritmo de cortes, estilo de legenda, cenário;
- se ele pediu, como adaptar pro negócio dele.

## Regras
- Não invente o que não viu: se um trecho ficou ilegível na folha, diga.
- Conteúdo de terceiros serve pra estudo e modelagem, nunca pra copiar ou repostar.
- **Nada de vídeo fica guardado no servidor.** Ao terminar, apague a pasta inteira (`rm -rf $D`), inclusive folhas e áudio. Se o vídeo veio como arquivo (WhatsApp ou painel), apague também a cópia que você usou. Se o mentorado quiser guardar algo, entregue o resumo em texto: o vídeo ele já tem.
- Se ele perguntar, explique: "eu assisto e apago o vídeo em seguida, pra não lotar o servidor. Se precisar de novo, é só me mandar outra vez." 
