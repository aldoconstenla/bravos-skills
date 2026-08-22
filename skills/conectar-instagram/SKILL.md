---
name: conectar-instagram
description: Conectar o Instagram do mentorado ao agente via Meta Graph API — setup guiado passo a passo (app na Meta, permissões, token de 60 dias) e depois postar foto, Reels, story e carrossel direto pelo agente. Use quando pedirem "conecta meu Instagram", "quero postar pelo agente", "configura o Instagram", ou quando pedirem pra publicar algo no Instagram.
---

# Conectar e postar no Instagram (Meta Graph API)

Método oficial validado pela equipe Bravos. Você tem DOIS papéis: guiar o SETUP (uma vez)
e depois OPERAR as postagens.

## FASE 1 — Setup guiado (uma etapa por vez, no ritmo da pessoa)

Conduza como um assistente paciente: mande UMA etapa, espere a pessoa confirmar, siga.

### Pré-requisitos (confirme antes de tudo)
1. Instagram no modo PROFISSIONAL (Empresarial ou Criador): Configurações → Conta →
   Mudar para conta profissional.
2. O Instagram vinculado a uma PÁGINA do Facebook (se não tiver: facebook.com/pages/create).
3. Acesso ao Meta for Developers (developers.facebook.com) com a MESMA conta do Facebook.

### Passo 1 — Criar o app
developers.facebook.com → Meus Apps → Criar app → tipo "Outro" → Próximo → tipo
"Empresa" → Próximo → nome livre (ex.: Agente-Instagram) + e-mail → Criar app.

### Passo 2 — Caso de uso do Instagram
No painel do app: tela "Adicionar casos de uso" → "Outros" → role até "API do Instagram" →
Configurar → Personalizar → na permissão "instagram_content_publish" clique em Adicionar →
vincule a Página do Facebook conectada ao Instagram, se pedir.
(Se a pessoa saiu da tela: menu lateral → Casos de uso → Adicionar.)

### Passo 3 — Gerar o token (curta duração)
developers.facebook.com/tools/explorer → dropdown "Meta App" → escolher o app criado →
em Permissões, DIGITAR manualmente uma a uma (o dropdown costuma falhar — avise isso):
instagram_basic · instagram_content_publish · pages_show_list · pages_read_engagement
→ Gerar token de acesso → autorizar no pop-up → copiar o token INTEIRO (começa com EAAV...).

### Passo 4 — Trocar por token de 60 dias
Peça à pessoa o App ID (topo da página do app) e o App Secret (Configurações → Básicas →
Mostrar). Aí VOCÊ faz a troca:
curl "https://graph.facebook.com/oauth/access_token?grant_type=fb_exchange_token&client_id=APP_ID&client_secret=APP_SECRET&fb_exchange_token=TOKEN_CURTO"
→ a resposta traz o token de ~60 dias.

### Passo 5 — Verificar e guardar
1. Valide: GET graph.facebook.com/debug_token?input_token=TOKEN&access_token=TOKEN →
   confira is_valid=true e "instagram_content_publish" nos scopes. O ID da conta Instagram
   está em granular_scopes → instagram_content_publish → target_ids.
2. Confirme o acesso: GET graph.facebook.com/v21.0/ID_CONTA?fields=id,username,followers_count,media_count&access_token=TOKEN
   → voltou username? Conectado!
3. GUARDE em /data/.env-instagram (chmod 600): IG_ACCESS_TOKEN, IG_ACCOUNT_ID,
   IG_APP_ID, IG_APP_SECRET. NUNCA repita o token de volta no chat nem em grupo.
4. Anote a data: o token vence em ~60 dias — avise o mentorado por volta do dia 50 pra
   renovar (mesma troca do Passo 4, com um token novo do Explorer).

## FASE 2 — Postar (sempre em 2 etapas)

A) Criar container: POST graph.facebook.com/v21.0/{IG_ACCOUNT_ID}/media
   com { image_url (URL PÚBLICA), caption, media_type } → retorna CONTAINER_ID
B) Publicar: POST graph.facebook.com/v21.0/{IG_ACCOUNT_ID}/media_publish
   com { creation_id: CONTAINER_ID } → retorna MEDIA_ID = publicado. Confirme ao mentorado.

Tipos: feed foto = IMAGE + image_url · Reels = REELS + video_url (aguarde o processamento
antes do publish) · story foto = STORIES + image_url · story com link = STORIES + image_url +
source_url · carrossel = CAROUSEL + children (IDs de containers).

⚠️ A mídia precisa estar numa URL PÚBLICA (a Meta busca de fora — arquivo local não serve).
Use a pasta pública do site do mentorado neste container pra hospedar temporariamente e
apague depois de publicar.

Limites da Meta: 50 publicações/dia por conta (feed+stories+reels somados) · imagem JPG/PNG
320-1440px, proporção 1:1 ou 4:5 · vídeo MP4/MOV, 3s a 15min.

## Avisos honestos
- App em modo Desenvolvimento: só o ADMIN do app usa a API — pra conta própria do
  mentorado isso basta; não precisa publicar o app nem passar por revisão da Meta.
- Se algo falhar, mostre ao mentorado a MENSAGEM DE ERRO da Meta e em qual passo parou —
  nunca diga que conectou sem o Passo 5 ter confirmado username.
