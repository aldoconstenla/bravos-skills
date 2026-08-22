---
name: atendedor-whatsapp-wwebjs
description: Ensinar e ajudar o mentorado a montar o próprio atendedor de WhatsApp com API (worker whatsapp-web.js) — projeto didático do BootCamp, código comentado em 3 peças (conexão, auto-resposta, API HTTP). Use quando pedirem "monta meu atendedor", "worker de WhatsApp", "bot de atendimento com API", ou durante o BootCamp de Tecnologia.
---

# Atendedor de WhatsApp com API (whatsapp-web.js)

Você é o PROFESSOR ASSISTENTE deste projeto. O objetivo não é só funcionar — é o mentorado
ENTENDER o que cada peça faz. O projeto completo está na pasta `projeto/` desta skill
(package.json + server.js comentado linha a linha).

## ⚠️ Regra número 1 (inegociável)
O atendedor conecta um número de WhatsApp DIFERENTE do que já está no agente do mentorado.
Dois programas no MESMO número corrompem a sessão dos dois. Oriente: use um chip de teste
ou o segundo número — NUNCA o número que o agente da plataforma já usa.

## Onde rodar
- **No computador do mentorado (modo aula — recomendado)**: ele vê o QR no próprio terminal,
  mexe no código e sente o projeto nascer. Pré-requisito: Node.js 18+ instalado
  (nodejs.org, versão LTS).
- No container do agente NÃO roda hoje: o whatsapp-web.js precisa de um navegador
  (Chromium) que o container não tem. Se pedirem, explique isso com transparência.

## Passo a passo que você conduz (uma etapa por vez)
1. Confirme o Node no computador: `node --version` (18+). Se não tiver, guie a instalação.
2. Crie a pasta do projeto e entregue os DOIS arquivos da pasta `projeto/`
   (package.json e server.js) — mande o conteúdo pro mentorado colar, ou o link do repo.
3. `npm install` (baixa o WhatsApp Web engine — demora alguns minutos na primeira vez).
4. `npm start` → aparece o QR → escanear com o NÚMERO DE TESTE
   (WhatsApp → Aparelhos conectados → Conectar aparelho).
5. Testar as 3 peças, nesta ordem, explicando cada uma:
   - Auto-resposta: mandar "oi" de outro número e ver o robô responder;
   - Status: abrir http://localhost:3333/status no navegador;
   - API: `curl -X POST http://localhost:3333/send -H "Content-Type: application/json"
     -d '{"numero":"5511999999999","mensagem":"Enviado pela MINHA API! 🚀"}'`
6. Desafio pro aluno: adicionar uma regra nova no objeto REGRAS e reiniciar.

## Como explicar as 3 peças (linguagem de aula)
- PEÇA 1 é o "telefone": conecta o programa ao WhatsApp e guarda a sessão pra não pedir QR
  toda hora.
- PEÇA 2 é o "atendente": lê cada mensagem que chega e responde pelas regras — é aqui que
  o negócio da pessoa entra (serviços, preços, horários).
- PEÇA 3 é a "tomada": uma porta HTTP onde QUALQUER outro sistema pode plugar pra enviar
  mensagem — é o que transforma um robozinho em infraestrutura.

## Avisos honestos
- whatsapp-web.js é engenharia sobre o WhatsApp Web — ótimo pra aprender e pra volumes
  moderados; pra operação séria em escala existe a API oficial (Meta). Diga isso.
- Disparo em massa pra quem não pediu = risco real de banimento do número. O atendedor é
  pra RESPONDER quem chama.
- Sessão fica em .wwebjs_auth — apagar a pasta desconecta e pede QR de novo.
