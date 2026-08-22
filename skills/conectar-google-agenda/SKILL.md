---
name: conectar-google-agenda
description: Conectar o Google Agenda (Calendar) do mentorado ao agente — setup guiado via conta de serviço do Google e depois consultar compromissos, criar e remarcar eventos direto pela conversa. Use quando pedirem "conecta minha agenda", "marca na minha agenda", "o que tenho amanhã", "configura o Google Calendar".
---

# Conectar e usar o Google Agenda

Método: CONTA DE SERVIÇO do Google — não expira como token de usuário, não passa por tela
de aprovação de app, e a pessoa só faz cliques simples. Você guia o setup (uma vez) e depois
opera a agenda.

## FASE 1 — Setup guiado (uma etapa por vez, ~10 min)

### Passo 1 — Projeto no Google Cloud
Peça pra pessoa acessar console.cloud.google.com (logada no Gmail da agenda) →
menu do topo → "Novo projeto" → nome livre (ex.: Agente-Agenda) → Criar.

### Passo 2 — Ativar a API do Calendar
No projeto criado: menu ☰ → "APIs e serviços" → "Biblioteca" → buscar
"Google Calendar API" → Ativar.

### Passo 3 — Criar a conta de serviço
Menu ☰ → "IAM e administrador" → "Contas de serviço" → "Criar conta de serviço" →
nome livre (ex.: agente) → Criar e continuar → pode PULAR as permissões de projeto →
Concluir. Depois clique na conta criada → aba "Chaves" → "Adicionar chave" →
"Criar nova chave" → tipo JSON → Criar. Um arquivo .json baixa no computador.

### Passo 4 — Me mandar a chave e compartilhar a agenda
1. A pessoa te envia o arquivo .json (pelo painel). Salve em
   /data/.google-agenda-sa.json com chmod 600. NUNCA repita o conteúdo no chat.
2. Dentro do .json tem o campo "client_email" (algo como agente@projeto.iam.gserviceaccount.com).
   Diga esse e-mail à pessoa e peça: Google Agenda (calendar.google.com) → engrenagem →
   Configurações → escolher a agenda na lista da esquerda → "Compartilhar com pessoas
   específicas" → Adicionar → colar o e-mail da conta de serviço → permissão
   "Fazer alterações nos eventos" → Enviar.

### Passo 5 — Testar de verdade
Com a chave salva, gere um access token OAuth de conta de serviço (JWT assinado com a
private_key do .json, scope https://www.googleapis.com/auth/calendar) e chame:
GET https://www.googleapis.com/calendar/v3/calendars/EMAIL_DA_PESSOA/events?maxResults=3
→ voltaram eventos (ou lista vazia sem erro 404/403)? Conectado — confirme à pessoa
citando o próximo compromisso dela. Erro 404/403 = a agenda ainda não foi compartilhada
com o client_email (volte ao Passo 4.2).

## FASE 2 — Operar a agenda

- "O que tenho amanhã/semana?" → GET /events com timeMin/timeMax (fuso America/Sao_Paulo).
- Criar: POST /calendars/{email}/events com summary, start/end (dateTime + timeZone),
  description e, se pedirem convidado, attendees.
- Remarcar/cancelar: localize o evento por horário+título, confirme com a pessoa QUAL é
  antes de mexer, então PATCH ou DELETE.
- Sempre confirme por texto o que criou/alterou (título, dia, hora) — a pessoa não vê a
  agenda na conversa.

## Regras
- O calendarId é o E-MAIL da pessoa (agenda principal) — guarde junto com a chave.
- Rode date antes de interpretar "amanhã", "sexta que vem" — nunca chute a data de hoje.
- Nunca crie, mude ou apague evento sem pedido explícito; remarcação sempre com confirmação.
- A chave .json é SEGREDO: fica no /data, fora de qualquer resposta, grupo ou log.
