---
name: editar-video-ffmpeg
description: Editar vídeo e áudio com ffmpeg — cortar trechos, juntar clipes, extrair áudio, converter formato, comprimir pra WhatsApp, legendar com arquivo .srt, gerar thumbnail. Use quando o mentorado pedir qualquer edição simples de vídeo/áudio.
---

# Editar vídeo com ffmpeg

## Quando usar
O mentorado mandou um vídeo/áudio (ou apontou um arquivo) e pediu: cortar, juntar, converter, comprimir, extrair o áudio, tirar um pedaço, colocar legenda, gerar capa. Para edição criativa complexa (efeitos, motion), explique o limite e entregue o que dá.

## Regras de ouro
1. **Nunca sobrescreva o arquivo original.** Gere sempre um arquivo novo ao lado (sufixo `-editado`).
2. Confirme o resultado ANTES de entregar: cheque duração/tamanho do arquivo de saída (`ffprobe`).
3. Vídeo pra WhatsApp: H.264 + AAC, `-movflags +faststart`, alvo abaixo de 16MB quando possível.

## Receitas prontas
- Cortar do minuto A ao B (sem reencodar, rápido):
  `ffmpeg -i in.mp4 -ss 00:01:00 -to 00:02:30 -c copy out-editado.mp4`
  (se o corte sair com tela preta no início, reencode: troque `-c copy` por `-c:v libx264 -c:a aac`)
- Juntar clipes (mesmo formato): arquivo `lista.txt` com linhas `file 'clipe1.mp4'` etc, depois
  `ffmpeg -f concat -safe 0 -i lista.txt -c copy out-editado.mp4`
- Extrair áudio: `ffmpeg -i in.mp4 -vn -acodec libmp3lame -q:a 2 out-audio.mp3`
- Comprimir pra WhatsApp: `ffmpeg -i in.mp4 -vf "scale='min(1280,iw)':-2" -c:v libx264 -crf 26 -preset veryfast -c:a aac -b:a 96k -movflags +faststart out-editado.mp4`
- Converter formato: `ffmpeg -i in.mov -c:v libx264 -c:a aac out-editado.mp4`
- Legendar (queimar .srt no vídeo): `ffmpeg -i in.mp4 -vf subtitles=legenda.srt out-editado.mp4`
- Thumbnail no segundo 3: `ffmpeg -i in.mp4 -ss 3 -frames:v 1 capa.jpg`
- Acelerar 1.5x: `ffmpeg -i in.mp4 -vf "setpts=PTS/1.5" -af "atempo=1.5" out-editado.mp4`

## Fluxo
1. Localize o arquivo (se veio pelo WhatsApp, está na pasta de mídia do worker).
2. Rode `ffprobe -v quiet -show_format -show_streams` pra entender o que tem na mão.
3. Aplique a receita, confira a saída, entregue e diga em 1 frase o que fez.

## Cortes INTELIGENTES guiados pelo conteúdo (screenshots + transcrição)

Quando o mentorado pedir "corta as melhores partes", "tira os trechos mortos", "faz cortes pra
redes sociais" ou qualquer edição que exija ENTENDER o vídeo (não só posição de relógio):

1. **Meça a duração**: `ffprobe -v quiet -show_entries format=duration -of csv=p=0 in.mp4`
2. **Extraia screenshots em intervalo ADAPTATIVO** — alvo de 12 a 24 quadros no total,
   independente do tamanho do vídeo:
   - intervalo = duração ÷ 20 (arredonde), com piso de 2s e teto de 60s;
   - ex.: vídeo de 1 min → 1 quadro a cada 3s (~20 quadros); vídeo de 40 min → 1 a cada
     60s (~40 quadros; se passar de ~30, aumente o intervalo pra caber em 24);
   - `mkdir -p /tmp/frames && ffmpeg -i in.mp4 -vf fps=1/INTERVALO -q:v 5 /tmp/frames/f-%04d.jpg`
   - o timestamp de cada quadro é (número-1) × INTERVALO — anote junto de cada um.
3. **OLHE os quadros** (você enxerga imagens — leia os arquivos): descreva o que aparece em
   cada timestamp (pessoa falando, slide, tela, corte de cena, trecho parado).
4. **Transcreva o áudio**: extraia com `ffmpeg -i in.mp4 -vn -ac 1 -ar 16000 /tmp/audio.wav`
   e use o recurso de transcrição que JÁ EXISTE no seu ambiente (o mesmo que transcreve os
   áudios que chegam pelo WhatsApp). Se não encontrar o recurso, siga só com os quadros e
   avise o mentorado da limitação.
5. **Cruze as duas linhas do tempo** (o que se VÊ × o que se FALA) e monte um PLANO DE CORTES:
   lista de trechos com início–fim e o motivo de cada um (ex.: "0:42–1:15 — explicação do
   método, fala completa e tela limpa").
6. **Confirme o plano com o mentorado ANTES de renderizar.** Aprovado, execute os cortes com
   as receitas acima e entregue os arquivos.
7. Limpe `/tmp/frames` e `/tmp/audio.wav` no final.

Vídeo acima de ~30 min: avise que vai processar por blocos e trabalhe em partes de 10-15 min.
