---
name: ata-de-reuniao
description: Transformar áudio ou vídeo de reunião em ata profissional — transcrição, decisões tomadas, ações com responsável e prazo, pendências. Use quando o mentorado mandar gravação de reunião/call e pedir resumo, ata, "o que ficou decidido", ou quando mandar um áudio longo pedindo organização do conteúdo.
---

# Ata de reunião

## Quando usar
O mentorado mandou gravação (áudio ou vídeo) de reunião, call ou mentoria e quer: ata,
resumo, decisões, próximos passos. Também vale pra áudio longo de brainstorm próprio.

## Fluxo
1. Localize o arquivo recebido (mídia do WhatsApp fica na pasta de mídia do worker).
2. Se for vídeo, extraia o áudio: ffmpeg -i in.mp4 -vn -ac 1 -ar 16000 /tmp/reuniao.wav
3. Transcreva usando o recurso de transcrição que JÁ EXISTE no seu ambiente (o mesmo motor
   que transcreve os áudios que chegam pelo WhatsApp). Gravação acima de ~30 min: processe
   em blocos de 10-15 min (ffmpeg -ss/-t) e junte as partes.
4. Monte a ata com ESTAS seções:
   - Resumo em 3 linhas (o essencial pra quem não vai ler o resto)
   - Participantes (só os que a gravação permitir identificar — não chute nomes)
   - Decisões tomadas
   - Ações: o quê · quem ficou responsável · prazo (se dito)
   - Pendências e pontos sem conclusão
5. Regra de ouro: a ata registra o que FOI DITO. Não invente decisão, responsável nem prazo
   que não estejam na gravação — o que ficou vago entra em "Pendências".
6. Entregue a ata no chat. Se a pessoa pedir "manda a transcrição completa", entregue à parte.
7. Limpe os arquivos temporários (/tmp/reuniao.wav etc) no final.
