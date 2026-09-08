---
name: google-ads
description: Conectar o Google Ads do mentorado ao agente e operar as campanhas pela conversa — setup guiado por conta de serviço (sem tela de OAuth) e token de desenvolvedor do próprio mentorado; depois relatórios, diagnóstico, e criação de campanhas, grupos, palavras-chave e anúncios com guardas de segurança. Use quando pedirem "conectar meu Google Ads", "como estão minhas campanhas", "cria uma campanha de pesquisa", "adiciona palavras-chave", "quanto gastei essa semana".
---

# Google Ads no agente

Método: **conta de serviço do Google** adicionada como usuária da conta Google Ads (não expira,
não passa por tela de aprovação de app) + **token de desenvolvedor da conta administradora do
próprio mentorado**. Você guia o setup (uma vez) e depois opera pela API REST oficial (v25).
Nada aqui usa credencial da Bravos.

Dois estágios, e isso precisa ficar claro pra pessoa desde o início:
- **Estágio 1 (no mesmo dia):** o token nasce no nível "Explorer" e já permite LER tudo
  (relatórios, campanhas, custos, diagnóstico).
- **Estágio 2 (uns 5 dias úteis):** com o nível "Basic" aprovado pela Google, passa a CRIAR e
  EDITAR (campanhas, grupos, palavras-chave, anúncios, orçamentos).

## FASE 1 — Setup guiado (uma etapa por vez, ~15 min de cliques)

Antes de começar: rode `date`, crie a pasta `/data/google-ads` (chmod 700) e grave o helper da
seção "Helper" deste arquivo em `/data/google-ads/gads.js` (se ainda não existir). Teste com
`node /data/google-ads/gads.js` (deve imprimir o uso). Só então conduza a pessoa.

### Passo 1 — Projeto no Google Cloud
Peça pra pessoa acessar console.cloud.google.com (logada no Gmail que administra o Google Ads)
→ menu do topo → "Novo projeto" → nome livre (ex.: Agente-Ads) → Criar → selecionar o projeto.

### Passo 2 — Ativar a API
Menu ☰ → "APIs e serviços" → "Biblioteca" → buscar "Google Ads API" → Ativar.

### Passo 3 — Conta de serviço e chave
Menu ☰ → "IAM e administrador" → "Contas de serviço" → "Criar conta de serviço" → nome
(ex.: agente-ads) → Criar e continuar → PULAR permissões → Concluir. Clique na conta criada →
aba "Chaves" → "Adicionar chave" → "Criar nova chave" → JSON → Criar. Um .json baixa.

### Passo 4 — Me mandar a chave
A pessoa envia o .json pelo painel. Salve em `/data/google-ads/sa.json` com chmod 600.
NUNCA repita o conteúdo no chat. Leia o campo `client_email` e diga esse e-mail à pessoa.

### Passo 5 — Dar acesso à conta Google Ads
Google Ads (ads.google.com), na conta do negócio → "Administrador" (engrenagem) → "Acesso e
segurança" → aba "Usuários" → botão "+" → colar o e-mail da conta de serviço → nível de acesso
**"Padrão"** (basta pra operar campanhas) → Enviar convite. Como é conta de serviço, o acesso
entra na hora, sem aceite por e-mail. Anote o **ID do cliente** (10 dígitos, canto superior
direito, formato 123-456-7890) → guarde sem hífens.

### Passo 6 — Conta administradora e token de desenvolvedor
Explique: o token de desenvolvedor só existe em conta administradora (MCC). É gratuita.
1. ads.google.com/home/tools/manager-accounts → "Criar conta de administrador" → nome livre.
2. Dentro da administradora: "Administrador" → "Centro de API" → aceitar os termos → o token
   aparece (22 caracteres). Guarde.
3. Vincular a conta do negócio à administradora: na administradora → "Contas" → "+" →
   "Vincular conta existente" → colar o ID do cliente → a pessoa aceita o convite na conta do
   negócio (Administrador → Acesso e segurança → Administradores). Anote o **ID da
   administradora** (também 10 dígitos).
4. Ainda no Centro de API, peça o **acesso Basic** ("Solicitar acesso básico"): formulário com
   site do negócio no ar, e-mail de contato e uso ("gerenciar as próprias campanhas com um
   agente"). Sem isso o token fica em Explorer: só leitura. A aprovação leva ~5 dias úteis.

### Passo 7 — Gravar a configuração
Escreva `/data/google-ads/config.json` (chmod 600):
```json
{ "developer_token": "XXXX", "customer_id": "1234567890", "login_customer_id": "0987654321",
  "max_daily_budget_brl": 50, "api_version": "v25" }
```
`login_customer_id` = ID da administradora (necessário quando o acesso vem pela hierarquia).
`max_daily_budget_brl` = teto de orçamento diário que a pessoa aceita; pergunte e grave.

### Passo 8 — Testar de verdade
```
node /data/google-ads/gads.js accounts
node /data/google-ads/gads.js search "SELECT customer.descriptive_name, customer.currency_code FROM customer"
```
Voltou o nome da conta → conectado. Confirme à pessoa citando o nome da conta e a moeda.
Erros comuns:
- `DEVELOPER_TOKEN_NOT_APPROVED` → o token ainda está "Pendente"/Explorer tentando algo além de
  leitura, ou a conta é de produção com token de teste. Leitura funciona; escrita espera o Basic.
- `USER_PERMISSION_DENIED` → falta o `login_customer_id` (ID da administradora) ou a conta de
  serviço não foi adicionada como usuária (Passo 5).
- `invalid_grant` no token → a API não foi ativada no projeto (Passo 2) ou a chave está errada.
- `PERMISSION_DENIED ... developer-token` → header ausente: confira o config.json.

## FASE 2 — Ler e diagnosticar (funciona desde o dia 1)

Sempre por GAQL via `gads.js search "<consulta>"`. Datas: rode `date` antes; a API trabalha com
`segments.date` e `DURING LAST_7_DAYS`, `LAST_30_DAYS`, `THIS_MONTH`, ou `BETWEEN 'AAAA-MM-DD' AND '...'`.
Valores vêm em micros (R$ 1 = 1.000.000): converta antes de responder.

Consultas prontas:
- Visão geral:
  `SELECT campaign.name, campaign.status, metrics.cost_micros, metrics.clicks, metrics.impressions, metrics.conversions FROM campaign WHERE segments.date DURING LAST_7_DAYS ORDER BY metrics.cost_micros DESC`
- Palavras-chave que gastam sem converter:
  `SELECT ad_group_criterion.keyword.text, ad_group_criterion.keyword.match_type, metrics.cost_micros, metrics.clicks, metrics.conversions FROM keyword_view WHERE segments.date DURING LAST_30_DAYS AND metrics.clicks > 0 ORDER BY metrics.cost_micros DESC`
- Termos de pesquisa reais: `SELECT search_term_view.search_term, metrics.clicks, metrics.cost_micros, metrics.conversions FROM search_term_view WHERE segments.date DURING LAST_30_DAYS ORDER BY metrics.clicks DESC`
- Orçamentos: `SELECT campaign_budget.name, campaign_budget.amount_micros, campaign.name FROM campaign_budget`
- Anúncios: `SELECT ad_group_ad.ad.responsive_search_ad.headlines, ad_group_ad.status, ad_group.name FROM ad_group_ad`

Ao devolver: 3 a 6 linhas, o número que importa primeiro (gasto, cliques, custo por clique,
conversões), uma leitura ("essa palavra levou 40% do gasto e zero conversão") e um próximo passo
pequeno. Nunca despeje a tabela crua.

## FASE 3 — Criar e editar (só depois do Basic)

Ordem obrigatória pra uma campanha de Pesquisa nova:
1. Orçamento: `campaignBudgets:mutate` com `amountMicros` diário (respeitando o teto do config).
2. Campanha: `campaigns:mutate` com `status: PAUSED`, `advertisingChannelType: SEARCH`,
   `manualCpc: {}` (ou `maximizeConversions` se houver conversão configurada),
   `networkSettings` só pesquisa Google, `campaignBudget` do passo 1.
3. Segmentação: `campaignCriteria:mutate` com localização (Brasil = `geoTargetConstants/2076`;
   cidades: buscar em `geo_target_constant`) e idioma português (`languageConstants/1014`).
4. Grupo: `adGroups:mutate` (`type: SEARCH_STANDARD`, `cpcBidMicros`).
5. Palavras-chave: `adGroupCriteria:mutate` (`keyword.text`, `matchType` PHRASE/EXACT/BROAD).
6. Anúncio responsivo: `adGroupAds:mutate` (`responsiveSearchAd` com 8 a 15 títulos até 30
   caracteres e 2 a 4 descrições até 90; `finalUrls`), `status: PAUSED`.
7. Só então, com pedido explícito da pessoa, ativar campanha e anúncio (`status: ENABLED`).

Como executar: monte o JSON das operações num arquivo e rode
`node /data/google-ads/gads.js mutate <service> <arquivo.json>` — sem `--confirm` o helper faz
só a validação na Google (`validateOnly`) e mostra o que ACONTECERIA. Mostre essa prévia à pessoa
em linguagem simples (nome, orçamento diário, palavras, títulos) e só repita com `--confirm`
depois de um "confirma"/"pode criar" explícito na conversa.

### Guardas (não são opcionais)
- Prévia sempre; escrita só com `--confirm` depois do sim da pessoa naquela mensagem.
- Orçamento acima de `max_daily_budget_brl` → o helper recusa; não contorne, pergunte se ela quer
  subir o teto (e grave o novo valor no config só se ela disser).
- Campanha e anúncio nascem PAUSADOS. Ativar é um pedido à parte.
- Nunca use correspondência ampla com CPC manual sem avisar que isso gasta rápido.
- Nunca apague campanha: pause. Nunca mexa em faturamento, pagamentos ou usuários da conta.
- Registre cada escrita em `/data/google-ads/log.jsonl` (o helper já faz): a pessoa pode pedir
  "o que você mudou hoje?".
- Chave e token são segredo: ficam em `/data/google-ads`, fora de qualquer resposta ou grupo.

## Helper — `/data/google-ads/gads.js` (Node 20, sem dependências)

Grave exatamente este conteúdo no arquivo indicado (Fase 1, antes do Passo 1):

```js
#!/usr/bin/env node
// gads.js — acesso à Google Ads API (REST) com conta de serviço. Sem dependências.
// uso: gads.js accounts | search "<GAQL>" [customer_id] | mutate <service> <ops.json> [--confirm] [--enable]
const fs = require('fs'), crypto = require('crypto'), path = require('path');
const DIR = '/data/google-ads', CFG = path.join(DIR, 'config.json'), SA = path.join(DIR, 'sa.json'), LOG = path.join(DIR, 'log.jsonl');
const die = (m) => { console.error('ERRO: ' + m); process.exit(1); };
const USO = 'uso: gads.js accounts | search "<GAQL>" [customer_id] | mutate <service> <ops.json> [--confirm] [--enable]';
if (!process.argv[2]) { console.log(USO); process.exit(0); } // uso funciona antes do setup
if (!fs.existsSync(CFG) || !fs.existsSync(SA)) die('faltam ' + CFG + ' e/ou ' + SA + ' (Fase 1 da skill)');
const cfg = JSON.parse(fs.readFileSync(CFG, 'utf8')), sa = JSON.parse(fs.readFileSync(SA, 'utf8'));
const V = cfg.api_version || 'v25', BASE = 'https://googleads.googleapis.com/' + V;
const b64 = (o) => Buffer.from(typeof o === 'string' ? o : JSON.stringify(o)).toString('base64url');
async function token() {
  const now = Math.floor(Date.now() / 1000);
  const jwt = b64({ alg: 'RS256', typ: 'JWT' }) + '.' + b64({ iss: sa.client_email, scope: 'https://www.googleapis.com/auth/adwords', aud: 'https://oauth2.googleapis.com/token', iat: now, exp: now + 3600 });
  const sig = crypto.createSign('RSA-SHA256').update(jwt).sign(sa.private_key, 'base64url');
  const r = await fetch('https://oauth2.googleapis.com/token', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + jwt + '.' + sig });
  const j = await r.json(); if (!j.access_token) die('token: ' + JSON.stringify(j)); return j.access_token;
}
function headers(tk) { const h = { Authorization: 'Bearer ' + tk, 'developer-token': cfg.developer_token, 'Content-Type': 'application/json' }; if (cfg.login_customer_id) h['login-customer-id'] = String(cfg.login_customer_id); return h; }
async function call(url, body, tk) {
  const r = await fetch(url, { method: body ? 'POST' : 'GET', headers: headers(tk), body: body ? JSON.stringify(body) : undefined });
  const t = await r.text(); let j; try { j = JSON.parse(t); } catch { j = { raw: t }; }
  if (!r.ok) { const e = (j.error && (j.error.details || [])[0]) || {}; die(`HTTP ${r.status} ${(j.error || {}).message || ''} ${JSON.stringify(e.errors || e).slice(0, 600)}`); }
  return j;
}
const cid = (x) => String(x || cfg.customer_id).replace(/-/g, '');
function guard(service, ops, enable) {
  const teto = Number(cfg.max_daily_budget_brl || 50);
  for (const op of ops) {
    const c = op.create || op.update || {};
    if (service === 'campaignBudgets' && c.amountMicros && Number(c.amountMicros) / 1e6 > teto) die(`orçamento diário R$ ${Number(c.amountMicros) / 1e6} acima do teto R$ ${teto} (config.max_daily_budget_brl)`);
    if ((service === 'campaigns' || service === 'adGroupAds') && op.create && !enable) c.status = 'PAUSED';
    if (op.remove) die('remover não é permitido por esta skill: use update com status PAUSED');
  }
}
(async () => {
  const [cmd, a, b, ...rest] = process.argv.slice(2); const flags = new Set([b, ...rest].filter(x => typeof x === 'string' && x.startsWith('--')));
  if (!['accounts', 'search', 'mutate'].includes(cmd)) die('comando desconhecido: ' + cmd + '\n' + USO);
  let ops, confirm;
  if (cmd === 'mutate') { // guardas ANTES de qualquer rede: teto e status são decididos aqui
    if (!a || !b || b.startsWith('--')) die('uso: mutate <service> <ops.json> [--confirm] [--enable]');
    ops = JSON.parse(fs.readFileSync(b, 'utf8')); if (!Array.isArray(ops) || !ops.length) die('ops.json precisa ser uma lista de operações');
    confirm = flags.has('--confirm'); guard(a, ops, flags.has('--enable'));
    if (process.env.GADS_DRY === '1') { console.log('GUARDAS OK (GADS_DRY=1, sem rede)'); console.log(JSON.stringify(ops, null, 1)); return; }
  }
  const tk = await token();
  if (cmd === 'accounts') { const j = await call(BASE + '/customers:listAccessibleCustomers', null, tk); console.log(JSON.stringify(j, null, 1)); return; }
  if (cmd === 'search') { if (!a) die('falta a consulta GAQL'); let out = [], pageToken; do { const j = await call(`${BASE}/customers/${cid(b && !b.startsWith('--') ? b : null)}/googleAds:search`, { query: a, pageSize: 1000, pageToken }, tk); out = out.concat(j.results || []); pageToken = j.nextPageToken; } while (pageToken && out.length < 5000); console.log(JSON.stringify(out, null, 1)); return; }
  if (cmd === 'mutate') {
    const body = { operations: ops, validateOnly: !confirm, partialFailure: false };
    const j = await call(`${BASE}/customers/${cid()}/${a}:mutate`, body, tk);
    fs.appendFileSync(LOG, JSON.stringify({ ts: new Date().toISOString(), service: a, confirm, ops, result: j }) + '\n');
    console.log(confirm ? 'EXECUTADO' : 'PRÉVIA (validateOnly, nada foi alterado)'); console.log(JSON.stringify(j, null, 1)); return;
  }
  die('comando desconhecido: ' + cmd);
})().catch(e => die(e.message));
```
