# Receitas de preparo (ffmpeg + transcrição) e conferência

Use caminhos absolutos. `IN` = vídeo original. `P` = pasta do projeto.

## 1. Transcrever o vídeo longo pra achar o trecho
Áudio leve em blocos de 10 min (a API aceita arquivo pequeno):
```bash
mkdir -p $P/trab && cd $P/trab
ffmpeg -y -i "$IN" -vn -ac 1 -ar 16000 -b:a 32k audio-todo.mp3
ffmpeg -y -i audio-todo.mp3 -f segment -segment_time 600 -c copy bloco-%02d.mp3
```
Transcreva cada bloco com o script do passo 3 (`transcrever.mjs`), somando 600 s × número do
bloco aos tempos. Se já existir transcrição do vídeo (arquivo .txt/.json com minutagem), use ela
e não gaste API.

## 2. Cortar o trecho escolhido (com folga) e conferir
```bash
# corte com reencode (preciso no quadro): de A a B em segundos
ffmpeg -y -ss A -to B -i "$IN" -c:v libx264 -crf 16 -preset fast -c:a aac -b:a 192k $P/trab/trecho.mp4
```
Quer tirar uma repetição do meio? Corte em pedaços e junte (concat reencodado, sem tranco de áudio):
```bash
ffmpeg -y -i trecho.mp4 -filter_complex "[0:v]trim=start=0:end=12.4,setpts=PTS-STARTPTS[v0];[0:a]atrim=start=0:end=12.4,asetpts=PTS-STARTPTS[a0];[0:v]trim=start=18.1,setpts=PTS-STARTPTS[v1];[0:a]atrim=start=18.1,asetpts=PTS-STARTPTS[a1];[v0][a0][v1][a1]concat=n=2:v=1:a=1[v][a]" -map "[v]" -map "[a]" -c:v libx264 -crf 16 -c:a aac corte.mp4
```
Corte SEMPRE no silêncio entre palavras (use os tempos do `palavras.json`: fim de uma palavra e
início da próxima). Nunca no meio de palavra.

## 3. Transcrição palavra a palavra do CORTE (Groq Whisper)
Grave como `$P/trab/transcrever.mjs`:
```js
// uso: node transcrever.mjs <audio.mp3|wav> <saida.json> [deslocamento_s]
import fs from 'fs';
const [, , arq, saida, desl = '0'] = process.argv;
const chave = (process.env.GROQ_API_KEY || process.env.GROQ_API_KEYS || '').split(/[,\s]+/).filter(Boolean)[0];
if (!chave) { console.error('Sem chave da Groq no ambiente (GROQ_API_KEY/GROQ_API_KEYS).'); process.exit(1); }
const fd = new FormData();
fd.append('file', new Blob([fs.readFileSync(arq)]), arq.split('/').pop());
fd.append('model', 'whisper-large-v3');
fd.append('language', 'pt');
fd.append('response_format', 'verbose_json');
fd.append('timestamp_granularities[]', 'word');
fd.append('timestamp_granularities[]', 'segment');
const r = await fetch('https://api.groq.com/openai/v1/audio/transcriptions', {method: 'POST', headers: {Authorization: `Bearer ${chave}`}, body: fd});
const j = await r.json();
if (!r.ok) { console.error(JSON.stringify(j)); process.exit(1); }
const d = Number(desl);
const palavras = (j.words || []).map((w) => ({w: w.word.trim(), s: +(w.start + d).toFixed(2), e: +(w.end + d).toFixed(2)}));
fs.writeFileSync(saida, JSON.stringify(palavras));
fs.writeFileSync(saida.replace(/\.json$/, '.txt'), (j.segments || []).map((s) => `[${(s.start + d).toFixed(1)}] ${s.text.trim()}`).join('\n'));
console.log('palavras:', palavras.length);
```
Para o corte final:
```bash
ffmpeg -y -i $P/trab/corte.mp4 -vn -ac 1 -ar 16000 $P/trab/corte-16k.wav
node $P/trab/transcrever.mjs $P/trab/corte-16k.wav $P/public/palavras.json
```
NÃO passe prompt pro Whisper (com prompt ele inventa frases). Se der limite de taxa (429),
espere 1-2 min ou use outra chave da lista. Confira nomes próprios e corrija à mão no JSON
(só o texto da palavra, nunca os tempos).

## 4. Áudio do corte, normalizado (−14 LUFS, padrão de redes)
```bash
ffmpeg -y -i $P/trab/corte.mp4 -vn -af "loudnorm=I=-14:TP=-1.5:LRA=11" -ar 48000 -ac 2 $P/public/audio.wav
ffprobe -v error -show_entries format=duration -of csv=p=0 $P/public/audio.wav   # → CONFIG.duracao
```

## 5. Vídeo do falante recortado pra moldura (retrato 4:5, sem áudio)
Olhe quadros do COMEÇO, do meio e do fim do corte (podcast troca de câmera: um plano aberto com 2 pessoas no início estraga o gancho). Ache onde está o rosto:
```bash
for s in 0.2 2 15 30; do ffmpeg -y -ss $s -i $P/trab/corte.mp4 -frames:v 1 -vf scale=640:-2 $P/trab/olhar-$s.jpg; done
```
Abra as imagens. Em vídeo 1920×1080, a janela 4:5 tem 864×1080; escolha o X (canto esquerdo)
que deixa o rosto no centro horizontal da janela, com a cabeça no terço de cima:
```bash
ffmpeg -y -i $P/trab/corte.mp4 -an -vf "crop=864:1080:X:0,scale=760:950,fps=30" -c:v libx264 -crf 18 -preset fast $P/public/fala.mp4
```
Tem troca de câmera no meio? Ache os cortes de cena e faça um crop por plano:
```bash
ffmpeg -i $P/trab/corte.mp4 -vf "select='gt(scene,0.3)',showinfo" -f null - 2>&1 | grep -o "pts_time:[0-9.]*"
```
(junte os planos com o mesmo concat do passo 2). Plano aberto com pessoa pequena: janela menor
(ex.: 640×800 a partir do rosto) e depois `scale=760:950`.

## 6. Render
```bash
cd $P && npm install --no-audit --no-fund
npx remotion render src/index.ts Corte entregas/corte.mp4 --codec h264 --pixel-format yuv420p --crf 18 --concurrency 4
```
Render leva ~3 a 5× a duração do vídeo. Antes do vídeo inteiro, renderize uma amostra de
8 s do meio pra validar visual: `--frames=600-840` (e olhe os quadros).

## 7. Folha de frames (conferência obrigatória)
```bash
ffmpeg -y -i $P/entregas/corte.mp4 -vf "fps=1,scale=216:-2,tile=10x6" -frames:v 1 $P/entregas/folha.jpg
ffprobe -v error -show_entries stream=codec_name,width,height,pix_fmt:format=duration -of compact $P/entregas/corte.mp4
```
Se o `ffprobe` mostrar `yuvj420p`, reconverta (alguns players recusam): `ffmpeg -y -i corte.mp4 -c:v libx264 -crf 18 -pix_fmt yuv420p -c:a copy -movflags +faststart corte-final.mp4`.
Vídeo com mais de 60 s gera mais de uma folha: troque por `tile=10x10`. Num trecho suspeito,
olhe de perto: `ffmpeg -ss 23 -t 2 -i corte.mp4 -vf "fps=4,scale=360:-2,tile=4x2" -frames:v 1 zoom.jpg`.

## 8. Arquivo leve pra WhatsApp (se o final passar de 16 MB)
```bash
ffmpeg -y -i corte.mp4 -c:v libx264 -crf 26 -preset slow -c:a aac -b:a 128k -movflags +faststart corte-whats.mp4
```
