---
name: edicao-de-video-com-ia
description: Edição de vídeo completa, do simples ao profissional. Simples (ffmpeg): cortar, juntar, comprimir pra WhatsApp, extrair áudio, legendar, capa. Profissional (Remotion): achar o melhor trecho de um vídeo longo (podcast, live, aula), abrir com gancho, falante em moldura que entra e sai, títulos e elementos animados no tempo da fala, legenda palavra a palavra, áudio normalizado e conferência quadro a quadro antes de entregar. Use quando o mentorado pedir qualquer edição de vídeo, "corte pra Reels/TikTok", "vídeo editado de verdade", "com animação" ou "motion design".
---

# Edição de vídeo com IA

Esta skill tem dois níveis. Escolha pelo pedido:

| Pedido | Caminho |
|---|---|
| Cortar, juntar, comprimir, extrair áudio, converter, capa, legenda simples | **Nível 1** (só ffmpeg, minutos) |
| "Corte pro Reels", "vídeo editado", "com animação", "profissional", "pega o melhor trecho" | **Nível 2** (Remotion, 30 a 90 min) |

Arquivos de apoio desta skill (leia quando chegar na etapa):
- `referencia/receitas-preparo.md`: comandos de corte, transcrição palavra a palavra, áudio, recorte do falante, render e folha de frames.
- `referencia/starter-remotion.md`: projeto Remotion pronto (motor + roteiro de exemplo).
- `referencia/exemplo-roteiro.md`: um roteiro completo de 55 s, cena a cena, pra servir de modelo de ritmo.

## Regras que valem pros dois níveis
1. **Nunca sobrescreva o original.** Trabalhe numa pasta de projeto (`/data/projetos/<nome>/`).
2. **Confira antes de entregar** (`ffprobe` + olhar quadros). Nunca entregue vídeo que você não viu.
3. **Espaço do servidor:** depois de entregar, peça "consegue baixar e abrir aí? Me avisa quando tiver salvo, que eu libero o espaço aqui". Só apague (original, trabalho e saída) DEPOIS da confirmação. Sem confirmação, pergunte de novo na próxima conversa.
4. Entrega pra redes/WhatsApp: H.264 + AAC, `yuv420p`, `-movflags +faststart`.

---

## Nível 1: edição simples (ffmpeg)
- Cortar de A a B: `ffmpeg -ss A -to B -i in.mp4 -c:v libx264 -crf 18 -c:a aac out-editado.mp4`
- Juntar clipes iguais: `lista.txt` com `file 'a.mp4'` por linha → `ffmpeg -f concat -safe 0 -i lista.txt -c copy out-editado.mp4`
- Extrair áudio: `ffmpeg -i in.mp4 -vn -c:a libmp3lame -q:a 2 out.mp3`
- Comprimir pra WhatsApp: `ffmpeg -i in.mp4 -vf "scale='min(1280,iw)':-2" -c:v libx264 -crf 26 -preset veryfast -c:a aac -b:a 96k -movflags +faststart out-editado.mp4`
- Legenda .srt queimada na zona segura (vertical): `ffmpeg -i in.mp4 -vf "subtitles=leg.srt:force_style='Alignment=2,MarginV=90,Fontsize=20,Outline=2,Bold=1'" out-editado.mp4`
- Capa no segundo 3: `ffmpeg -ss 3 -i in.mp4 -frames:v 1 capa.jpg`
- Acelerar 1,5×: `ffmpeg -i in.mp4 -vf "setpts=PTS/1.5" -af "atempo=1.5" out-editado.mp4`
Fluxo: `ffprobe` no original → receita → `ffprobe` na saída + 1 quadro conferido → entrega com 1 frase do que foi feito.

---

## Nível 2: corte profissional (Remotion)

O resultado bom vem do método, não da ferramenta. Siga as 7 etapas na ordem e dê notícia ao mentorado a cada etapa concluída.

### Etapa 1: combinar (1 mensagem só, pergunte só o que faltar)
- **Onde vai postar?** Reels/TikTok/Shorts = vertical 1080×1920 (padrão). Feed = 1080×1350. YouTube = 1920×1080.
- **Qual trecho?** Se ele não souber, você sugere (Etapa 2). Duração ideal: 40 a 60 s.
- **Cor da marca?** Se não tiver, use 1 cor de destaque que combine com o vídeo.
- Avise o prazo: "fica pronto em mais ou menos 1 hora; te mando uma amostra antes".

### Etapa 2: achar o trecho (quando o vídeo é longo)
1. Transcreva o vídeo com minutagem (receitas §1).
2. Leia a transcrição e marque **frases que param o dedo**: afirmação forte, contradição ("o não não é pra você"), número, conselho prático, frase que dá vontade de mandar pra alguém.
3. Escolha um trecho de 40 a 70 s que tenha: uma ideia só, começo-meio-fim e uma frase forte que possa ABRIR o vídeo.
4. Mande 2 ou 3 opções ao mentorado com minutagem e a frase-gancho de cada uma; se ele já escolheu, siga.

### Etapa 3: estrutura com gancho
- **Os 3 primeiros segundos decidem tudo.** O vídeo abre com a frase mais forte do trecho, escrita grande na tela desde o quadro 0 (mesmo que ela seja dita no fim: vira um título-promessa).
- Depois do gancho, o trecho conta **como se chegou** naquela frase, em blocos (ex.: nível 1 → 2 → 3; problema → virada → solução).
- O fechamento repete ou completa a frase do gancho (dá sensação de "fechou").
- Tire do meio: repetição, frase pela metade, "né, tipo, então" longos, desvio de assunto (receitas §2). Nunca corte algo que mude o sentido do que a pessoa disse.
- Escreva o plano numa tabela (tempo · o que é dito · o que aparece na tela) ANTES de programar.

### Etapa 4: preparar os materiais
Siga receitas §2 a §5: corte final → `palavras.json` (transcrição palavra a palavra do CORTE) → `audio.wav` normalizado em −14 LUFS → `fala.mp4` (falante recortado em retrato 4:5, sem áudio).

### Etapa 5: montar (starter-remotion.md)
Copie o starter e escreva só o `roteiro.ts`. Regras de direção:
- **Ritmo:** nada fica igual na tela por mais de 2 a 3 segundos. A cada frase muda algo: título novo, chip, ícone, medidor, troca de modo da moldura, "soco" de zoom. A moldura já tem micro-zoom contínuo.
- **Tudo no tempo da fala:** o tempo de entrada de cada elemento é o `s` da palavra que ele representa no `palavras.json` (entre 0,05 e 0,15 s antes). Nunca chute segundo redondo.
- **Alternar modos:** comece em `mini` (falante embaixo + gancho em cima); vá pra `full` (tela cheia de motion) nas ideias-chave e nas viradas; volte pro `card` (falante grande) quando a pessoa conta história ou a expressão dela importa. Troque de modo a cada 5 a 9 s.
- **Título destaca, não repete:** 2 a 5 palavras, a ideia da frase, não a frase inteira (a legenda já tem a frase). Uma palavra por título em destaque (`*palavra*` ou `[palavra]`).
- **Mostre a ideia:** níveis/etapas → medidor; rejeição → balão "Não." ou carimbo; algo certo → check; pessoa/produto/objetivo → ícone. Um elemento principal por vez.
- **Paleta:** fundo escuro + 1 cor de destaque + branco. A cor de alerta (vermelho) só em negação/erro, pouco.
- **Legenda** palavra a palavra com a palavra falada destacada (o motor faz sozinho). Fora do rosto e acima da zona da interface.
- **Socos de zoom** (`SOCOS`) nas 5 a 8 palavras mais fortes.
- **Nunca invente** número, estudo, resultado, título ou cargo que a pessoa não disse. Chip de assinatura com nome e tema, só com o que é verdade.
- Use `exemplo-roteiro.md` como régua de densidade: ~25 a 35 cenas em 55 s.

### Etapa 6: amostra, render e conferência (OBRIGATÓRIA)
1. Renderize uma amostra de 8 s do meio, olhe os quadros e mande ao mentorado se ele quis aprovar o estilo.
2. Render completo (receitas §6).
3. **Folha de frames do vídeo INTEIRO a 1 quadro por segundo** (receitas §7) e olhe a folha toda. Checklist:
   - [ ] o quadro 0 já mostra o gancho (nada de tela vazia no começo)
   - [ ] nenhum trecho com a mesma imagem por mais de 3 quadros seguidos da folha
   - [ ] título nunca em cima do rosto, da moldura ou da legenda; nada cortado na borda
   - [ ] legenda lendo certo e acompanhando a fala (confira 3 pontos contra o `palavras.json`)
   - [ ] palavras com acento certo; nomes próprios corretos
   - [ ] nada importante abaixo de y≈1600 (interface do app)
   - [ ] fim fecha a ideia (sem cortar no meio de palavra)
   - [ ] `ffprobe`: h264, yuv420p, áudio presente, duração = `CONFIG.duracao`
4. Achou problema: corrige no `roteiro.ts`, renderiza de novo, gera folha de novo. Só sai quando passar no checklist inteiro.

### Etapa 7: entrega
Mande o mp4 e uma mensagem curta:
> "Prontinho! Corte de 55 s do trecho 33:10–34:12 (o 'não' não é pra você). Abre com a frase mais forte e depois mostra os 3 níveis. Legenda palavra a palavra, áudio nivelado pra redes. Se quiser outro trecho, tenho mais 2 sugestões: 18:44 e 35:12."

Depois, regra 3 (confirmação de download antes de apagar).

## Armadilhas conhecidas
- **Memória:** render com `--concurrency 4` no máximo; se `free -m` mostrar menos de 1,5 GB livres, use `--concurrency 2`. Uma coisa pesada por vez.
- **Primeiro render baixa um navegador** (~100 MB) pro cache; se falhar com "lib... not found", veja o INSTALL.md (bibliotecas do navegador).
- **Fontes** vêm do Google Fonts no render: precisa de internet. Sem internet, troque as fontes por `sans-serif`/`serif`.
- **Áudio fora de sincronia:** quase sempre é `palavras.json` de um arquivo diferente do `audio.wav`. Os dois têm que sair do MESMO `corte.mp4`.
- **Tela preta no começo do corte:** use o corte com reencode (receitas §2), não `-c copy`.
- **Whisper com prompt inventa texto.** Sem prompt, sempre.
