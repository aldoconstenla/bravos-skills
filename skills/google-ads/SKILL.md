---
name: google-ads
description: Conectar o Google Ads do mentorado ao agente e operar as campanhas pela conversa. O agente faz o setup (gera os comandos que criam projeto, conta de serviço e chave, descobre os IDs pela API, grava a configuração e testa) e orienta o mentorado só nas liberações que exigem a conta dele (colar no Cloud Shell, dar acesso no Google Ads, pegar o token de desenvolvedor). Depois: relatórios, diagnóstico e criação de campanhas, grupos, palavras-chave e anúncios com guardas. Use quando pedirem "conectar meu Google Ads", "como estão minhas campanhas", "cria uma campanha", "quanto gastei".
---

# Google Ads no agente

Método: **conta de serviço do Google** adicionada como usuária da conta Google Ads (não expira, não
passa por tela de aprovação de app) + **token de desenvolvedor da conta administradora do próprio
mentorado**. API REST oficial (v25). Nada aqui usa credencial da Bravos.

Divisão de trabalho: **você faz** tudo que dá pra fazer com comando e API (gerar o script de
criação, ler a chave, descobrir IDs, gravar configuração, testar, diagnosticar). **A pessoa faz**
só o que exige a conta Google dela: colar um bloco no Cloud Shell, liberar o acesso no Google Ads
e pegar o token de desenvolvedor. Você conduz uma etapa por vez, verifica cada uma pela API e diz
com precisão o que falta. Nunca peça pra pessoa "configurar" nada: peça cliques concretos, com o
link direto.

Dois estágios, avise desde o início:
- **Estágio 1 (no mesmo dia):** token nasce no nível "Explorer" e já permite LER tudo (relatórios,
  campanhas, custos, diagnóstico).
- **Estágio 2 (uns 5 dias úteis):** com o nível "Basic" aprovado pela Google, passa a CRIAR e
  EDITAR (campanhas, grupos, palavras-chave, anúncios, orçamentos).

## FASE 1 — Setup (você executa; a pessoa libera)

### Etapa 0 — Preparar (só você)
1. `date`. Crie `/data/google-ads` (chmod 700). Grave o helper da seção "Helper" em
   `/data/google-ads/gads.js` e confira com `node /data/google-ads/gads.js` (imprime o uso).
2. Gere um ID de projeto único: `agente-ads-` + 6 caracteres minúsculos/dígitos aleatórios
   (ex.: `agente-ads-k3m9x2`). Guarde em `/data/google-ads/setup.json` como `project_id`.
3. Monte o bloco do Cloud Shell abaixo com esse ID e mande pra pessoa junto com a instrução da
   Etapa 1. Explique em uma frase o que o bloco faz (cria um projeto de tecnologia no Google dela,
   liga a API do Google Ads, cria um "usuário robô" e gera a chave dele).

### Etapa 1 — Cloud Shell (a pessoa cola, você lê o resultado)
Peça: abrir **https://shell.cloud.google.com** no computador, logada no Gmail que administra o
Google Ads (na 1ª vez aparece um termo pra aceitar e o terminal demora ~30 s pra abrir). Colar o
bloco inteiro e apertar Enter. Se pedir "Authorize", clicar em Autorizar.
```bash
P="agente-ads-XXXXXX"; gcloud projects create "$P" --name="Agente Ads" --quiet \
&& gcloud config set project "$P" --quiet \
&& gcloud services enable googleads.googleapis.com --project="$P" --quiet \
&& gcloud iam service-accounts create agente-ads --display-name="Agente Ads" --project="$P" --quiet \
&& sleep 5 && gcloud iam service-accounts keys create "$HOME/agente-ads-key.json" \
   --iam-account="agente-ads@$P.iam.gserviceaccount.com" --project="$P" --quiet \
&& echo "===== COPIE DAQUI ATE O FIM E MANDE PRO AGENTE =====" && cat "$HOME/agente-ads-key.json"
```
A pessoa copia tudo a partir da linha "COPIE DAQUI" e cola pra você (ou baixa o arquivo pelo
menu ⋮ do Cloud Shell → Download → `agente-ads-key.json` e envia pelo painel).
Você: salve em `/data/google-ads/sa.json` (chmod 600). NUNCA repita o conteúdo no chat. Confira
que tem `client_email` e `private_key`. Diga à pessoa o `client_email` (algo como
`agente-ads@agente-ads-xxxxxx.iam.gserviceaccount.com`): é o "usuário robô" que ela vai liberar.
Problemas comuns: "already exists" no ID → gere outro ID e repita; "billing" → o Google Ads API
não exige faturamento, ignore; ela colou só uma parte → peça o bloco de novo, inteiro.

### Etapa 2 — Liberar o acesso no Google Ads (a pessoa)
Link direto: **https://ads.google.com/aw/accountaccess/users** (na conta do negócio; se abrir
outra conta, trocar pelo seletor no topo). Botão "+" → colar o e-mail do robô → nível de acesso
**Padrão** → Enviar convite. Como é conta de serviço, o acesso entra na hora.
Você verifica: ainda não dá pra chamar a API sem o token (Etapa 3), então só confirme que ela
clicou e siga. Peça também o **ID do cliente** que aparece no topo (formato 123-456-7890) ou
descubra sozinho na Etapa 4.

### Etapa 3 — Token de desenvolvedor (a pessoa, com seus links)
Explique: o token só existe em conta administradora (MCC), que é gratuita.
1. Criar a administradora: **https://ads.google.com/home/tools/manager-accounts/** → "Criar conta
   de administrador" → nome livre → Criar.
2. Pegar o token: dentro da administradora, **https://ads.google.com/aw/apicenter** → aceitar os
   termos → copiar o token (22 caracteres) e mandar pra você. Guarde em `config.json` (Etapa 4).
3. Vincular a conta do negócio à administradora: na administradora → "Contas" → "+" → "Vincular
   conta existente" → colar o ID do cliente → depois, na conta do negócio, aceitar o convite em
   Administrador → Acesso e segurança → aba "Administradores". Peça o **ID da administradora**
   (10 dígitos, topo da tela) ou descubra na Etapa 4.
4. Liberar o robô também na administradora (mesmo caminho da Etapa 2, agora dentro da
   administradora): isso deixa você operar por toda a hierarquia.
5. Pedir o **acesso Basic**: ainda no Centro de API → "Solicitar acesso básico" → formulário com o
   site do negócio no ar, e-mail de contato e uso ("gerenciar as próprias campanhas com um
   agente"). Sem isso o token fica em Explorer: só leitura. Aprovação ~5 dias úteis.

### Etapa 4 — Configurar e testar (só você)
1. Grave `/data/google-ads/config.json` (chmod 600) com o que já tem:
   `{"developer_token":"...","api_version":"v25","max_daily_budget_brl":50}`
2. Rode `node /data/google-ads/gads.js accounts`: volta a lista de IDs que o robô enxerga.
   Se vierem dois, o de 10 dígitos que é a administradora vai em `login_customer_id` e o da conta
   do negócio em `customer_id`; se vier um só, é o `customer_id` (e deixe `login_customer_id` de
   fora até a vinculação da Etapa 3.3 acontecer). Descubra qual é qual com
   `search "SELECT customer.id, customer.descriptive_name, customer.manager FROM customer"`
   (`manager: true` = administradora). Complete o config.json.
3. Pergunte o teto de orçamento diário que a pessoa aceita e grave em `max_daily_budget_brl`.
4. Rode `node /data/google-ads/gads.js check`: ele testa token, acesso, leitura e se a escrita
   está liberada, e imprime um laudo. Traduza o laudo pra pessoa em 3 linhas: o que já funciona,
   o que falta e o link exato do que falta. Se tudo ok na leitura, confirme citando o nome da
   conta e a moeda. Repita o `check` sempre que ela disser que fez uma liberação.

Erros e o que fazer:
- `invalid_grant` no token → API não ativada no projeto ou chave errada: repita a Etapa 1.
- `USER_PERMISSION_DENIED` → robô não liberado na conta (Etapa 2) ou falta `login_customer_id`.
- `DEVELOPER_TOKEN_NOT_APPROVED` em escrita → token ainda em Explorer: aguardar o Basic (3.5).
- `DEVELOPER_TOKEN_NOT_APPROVED` em leitura → o token está "Pendente" numa conta de produção;
  confirme que foi aceito o termo no Centro de API e que a conta não é de teste.
- `PERMISSION_DENIED ... developer-token` → header ausente: confira o config.json.

## FASE 2 — Ler e diagnosticar (funciona desde o dia 1)

Sempre por GAQL via `gads.js search "<consulta>"`. Datas: rode `date` antes; a API usa
`segments.date DURING LAST_7_DAYS | LAST_30_DAYS | THIS_MONTH` ou `BETWEEN 'AAAA-MM-DD' AND '...'`.
Valores vêm em micros (R$ 1 = 1.000.000): converta antes de responder.

Consultas prontas:
- Visão geral: `SELECT campaign.name, campaign.status, metrics.cost_micros, metrics.clicks, metrics.impressions, metrics.conversions FROM campaign WHERE segments.date DURING LAST_7_DAYS ORDER BY metrics.cost_micros DESC`
- Palavras que gastam sem converter: `SELECT ad_group_criterion.keyword.text, ad_group_criterion.keyword.match_type, metrics.cost_micros, metrics.clicks, metrics.conversions FROM keyword_view WHERE segments.date DURING LAST_30_DAYS AND metrics.clicks > 0 ORDER BY metrics.cost_micros DESC`
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
   `manualCpc: {}` (ou `maximizeConversions` se houver conversão configurada), `networkSettings`
   só pesquisa Google, `campaignBudget` do passo 1.
3. Segmentação: `campaignCriteria:mutate` com localização (Brasil = `geoTargetConstants/2076`;
   cidades: buscar em `geo_target_constant`) e idioma português (`languageConstants/1014`).
4. Grupo: `adGroups:mutate` (`type: SEARCH_STANDARD`, `cpcBidMicros`).
5. Palavras-chave: `adGroupCriteria:mutate` (`keyword.text`, `matchType` PHRASE/EXACT/BROAD).
6. Anúncio responsivo: `adGroupAds:mutate` (`responsiveSearchAd` com 8 a 15 títulos até 30
   caracteres e 2 a 4 descrições até 90; `finalUrls`), `status: PAUSED`.
7. Só então, com pedido explícito da pessoa, ativar campanha e anúncio (`status: ENABLED`).

Como executar: monte o JSON das operações num arquivo e rode
`node /data/google-ads/gads.js mutate <service> <arquivo.json>` — sem `--confirm` o helper faz só
a validação na Google (`validateOnly`) e mostra o que ACONTECERIA. Mostre essa prévia à pessoa em
linguagem simples (nome, orçamento diário, palavras, títulos) e só repita com `--confirm` depois
de um "confirma"/"pode criar" explícito na conversa.

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

Grave exatamente este conteúdo no arquivo indicado (Etapa 0):

```js
#!/usr/bin/env node
// gads.js — acesso à Google Ads API (REST) com conta de serviço. Sem dependências.
const fs = require('fs'), crypto = require('crypto'), path = require('path');
const DIR = process.env.GADS_DIR || '/data/google-ads', CFG = path.join(DIR, 'config.json'), SA = path.join(DIR, 'sa.json'), LOG = path.join(DIR, 'log.jsonl');
const die = (m) => { console.error('ERRO: ' + m); process.exit(1); };
const USO = 'uso: gads.js accounts | check | search "<GAQL>" [customer_id] | mutate <service> <ops.json> [--confirm] [--enable]';
if (!process.argv[2]) { console.log(USO); process.exit(0); } // uso funciona antes do setup
if (!fs.existsSync(SA)) die('falta ' + SA + ' (Etapa 1: chave da conta de serviço)');
if (!fs.existsSync(CFG)) die('falta ' + CFG + ' (Etapa 4: developer_token)');
const cfg = JSON.parse(fs.readFileSync(CFG, 'utf8')), sa = JSON.parse(fs.readFileSync(SA, 'utf8'));
if (!sa.client_email || !sa.private_key) die('sa.json sem client_email/private_key: repita a Etapa 1');
if (!cfg.developer_token) die('config.json sem developer_token (Etapa 3.2)');
const V = cfg.api_version || 'v25', BASE = 'https://googleads.googleapis.com/' + V;
const b64 = (o) => Buffer.from(typeof o === 'string' ? o : JSON.stringify(o)).toString('base64url');
async function token() {
  const now = Math.floor(Date.now() / 1000);
  const jwt = b64({ alg: 'RS256', typ: 'JWT' }) + '.' + b64({ iss: sa.client_email, scope: 'https://www.googleapis.com/auth/adwords', aud: 'https://oauth2.googleapis.com/token', iat: now, exp: now + 3600 });
  const sig = crypto.createSign('RSA-SHA256').update(jwt).sign(sa.private_key, 'base64url');
  const r = await fetch('https://oauth2.googleapis.com/token', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + jwt + '.' + sig });
  const j = await r.json(); if (!j.access_token) die('token: ' + JSON.stringify(j)); return j.access_token;
}
function headers(tk) { const h = { Authorization: 'Bearer ' + tk, 'developer-token': cfg.developer_token, 'Content-Type': 'application/json' }; if (cfg.login_customer_id) h['login-customer-id'] = String(cfg.login_customer_id).replace(/-/g, ''); return h; }
async function call(url, body, tk, soft) {
  const r = await fetch(url, { method: body ? 'POST' : 'GET', headers: headers(tk), body: body ? JSON.stringify(body) : undefined });
  const t = await r.text(); let j; try { j = JSON.parse(t); } catch { j = { raw: t }; }
  if (!r.ok) { const e = (j.error && (j.error.details || [])[0]) || {}; const msg = `HTTP ${r.status} ${(j.error || {}).message || ''} ${JSON.stringify(e.errors || e).slice(0, 600)}`; if (soft) return { _erro: msg }; die(msg); }
  return j;
}
const cid = (x) => String(x || cfg.customer_id || '').replace(/-/g, '');
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
  if (!['accounts', 'check', 'search', 'mutate'].includes(cmd)) die('comando desconhecido: ' + cmd + '\n' + USO);
  let ops, confirm;
  if (cmd === 'mutate') { // guardas ANTES de qualquer rede
    if (!a || !b || b.startsWith('--')) die('uso: mutate <service> <ops.json> [--confirm] [--enable]');
    ops = JSON.parse(fs.readFileSync(b, 'utf8')); if (!Array.isArray(ops) || !ops.length) die('ops.json precisa ser uma lista de operações');
    confirm = flags.has('--confirm'); guard(a, ops, flags.has('--enable'));
    if (process.env.GADS_DRY === '1') { console.log('GUARDAS OK (GADS_DRY=1, sem rede)'); console.log(JSON.stringify(ops, null, 1)); return; }
    if (!cid()) die('config.json sem customer_id (Etapa 4.2)');
  }
  const tk = await token();
  if (cmd === 'accounts') { const j = await call(BASE + '/customers:listAccessibleCustomers', null, tk); console.log(JSON.stringify(j, null, 1)); return; }
  if (cmd === 'check') { // laudo das liberações: token → acesso → leitura → escrita
    const laudo = { token: 'OK (chave da conta de serviço válida)' };
    const acc = await call(BASE + '/customers:listAccessibleCustomers', null, tk, true);
    laudo.acesso = acc._erro ? 'FALTA: ' + acc._erro : `OK: robô enxerga ${(acc.resourceNames || []).length} conta(s): ${(acc.resourceNames || []).map(x => x.split('/')[1]).join(', ')}`;
    if (!cid()) { laudo.leitura = 'PENDENTE: customer_id ausente no config.json (Etapa 4.2)'; console.log(JSON.stringify(laudo, null, 1)); return; }
    const s = await call(`${BASE}/customers/${cid()}/googleAds:search`, { query: 'SELECT customer.id, customer.descriptive_name, customer.currency_code, customer.manager FROM customer' }, tk, true);
    laudo.leitura = s._erro ? 'FALTA: ' + s._erro : 'OK: ' + JSON.stringify(((s.results || [])[0] || {}).customer || {});
    const w = await call(`${BASE}/customers/${cid()}/campaignBudgets:mutate`, { operations: [{ create: { name: 'teste-liberacao-' + Date.now(), amountMicros: '1000000', deliveryMethod: 'STANDARD', explicitlyShared: false } }], validateOnly: true }, tk, true);
    laudo.escrita = w._erro ? (/DEVELOPER_TOKEN_NOT_APPROVED/.test(w._erro) ? 'AINDA NÃO: token em Explorer (só leitura). Pedir acesso Basic em https://ads.google.com/aw/apicenter' : 'FALTA: ' + w._erro) : 'OK: escrita liberada (validação passou)';
    console.log(JSON.stringify(laudo, null, 1)); return;
  }
  if (cmd === 'search') { if (!a) die('falta a consulta GAQL'); const c = cid(b && !b.startsWith('--') ? b : null); if (!c) die('sem customer_id: passe como 2º argumento ou grave no config.json'); let out = [], pageToken; do { const j = await call(`${BASE}/customers/${c}/googleAds:search`, { query: a, pageSize: 1000, pageToken }, tk); out = out.concat(j.results || []); pageToken = j.nextPageToken; } while (pageToken && out.length < 5000); console.log(JSON.stringify(out, null, 1)); return; }
  if (cmd === 'mutate') {
    const body = { operations: ops, validateOnly: !confirm, partialFailure: false };
    const j = await call(`${BASE}/customers/${cid()}/${a}:mutate`, body, tk);
    fs.appendFileSync(LOG, JSON.stringify({ ts: new Date().toISOString(), service: a, confirm, ops, result: j }) + '\n');
    console.log(confirm ? 'EXECUTADO' : 'PRÉVIA (validateOnly, nada foi alterado)'); console.log(JSON.stringify(j, null, 1)); return;
  }
})().catch(e => die(e.message));
```
