---
name: pesquisa-contatos-web
description: Pesquisar na internet contatos e dados públicos de empresas e profissionais (nome, site, telefone público, Instagram, endereço, avaliações) e entregar organizado em lista ou tabela. Use quando o mentorado pedir "pesquisa X pra mim", "acha o contato de", "monta uma lista de empresas/clínicas/lojas de tal segmento em tal cidade".
---

# Pesquisa de contatos na web

## Quando usar
Pedidos como: "monta uma lista de dentistas em Osasco com telefone", "acha o Instagram dessas 5 lojas", "quem é o dono da empresa X", "pesquisa clínicas de estética perto de mim".

## Regras (inegociáveis)
1. **Só dados PÚBLICOS**: o que a própria empresa/pessoa publica (site, Google, Instagram, listas públicas). Nunca buscar CPF, dados pessoais privados ou driblar bloqueio de site.
2. **Diga a fonte** de cada dado (site oficial, perfil do Google, Instagram) — dado sem fonte não entra.
3. **Não invente**: campo que não achou fica como "não encontrado", nunca chute telefone/e-mail.
4. Uso comercial responsável: a lista é pra prospecção educada do mentorado, não pra disparo em massa. Se ele pedir disparo em massa pra lista fria, oriente sobre risco de banimento do WhatsApp.

## Fluxo
1. Entenda o alvo: segmento + cidade/região + o que ele quer de cada contato (telefone? Instagram? site?).
2. Busque em camadas: busca web pelo segmento+cidade → confira site oficial → confira perfil público do Google (avaliações) → Instagram.
3. Entregue em tabela simples: Nome | Telefone público | Instagram | Site | Fonte | Observação.
4. Listas grandes: entregue as 10-20 melhores primeiro e pergunte se ele quer mais — qualidade vale mais que volume.

## Entrega em página interativa (padrão a partir de 22/ago/2026)
Além da tabela na conversa, TODA lista com 5+ contatos deve ser entregue também como
**página HTML de prospecção** — um arquivo único que o mentorado abre em qualquer navegador
(computador ou celular) e usa como painel de trabalho.

**Como gerar:**
1. Crie UM arquivo `<segmento>-<cidade>.html` (ex.: `veterinarias-sao-paulo.html`), auto-contido
   (CSS e JS inline, nenhuma dependência externa, nenhuma chamada de rede), e salve em
   **`/data/projetos/prospeccao/`** (crie a pasta se não existir). Essa pasta já é servida pelo
   site do mentorado: a página fica no ar em
   **`https://<subdominio-do-mentorado>.bravosdigital.com.br/prospeccao/<arquivo>.html`** —
   entregue esse LINK pro mentorado (não o arquivo).
   ⚠️ Tudo em `/data/projetos` é PÚBLICO por design: apenas dados públicos da pesquisa entram
   na página — nunca dado sensível, credencial ou informação privada do mentorado.
2. Visual PREMIUM (capricho é requisito, não enfeite):
   - fundo escuro profundo (#0e0e10 → #17171a em gradiente sutil), destaques dourados (#d4af37/#e6c968),
     texto claro com hierarquia (título forte, metadados discretos);
   - tipografia do sistema bem usada: `font-family: -apple-system, 'Segoe UI', Roboto, sans-serif`,
     título 28-32px bold, corpo 15-16px, line-height 1.5;
   - cartões com borda 1px rgba(212,175,55,.18), raio 14-16px, sombra suave, hover/active com
     leve elevação; transições de 150-250ms em opacidade e transform (nunca em width/height);
   - cabeçalho da página com segmento + cidade + data da pesquisa e uma barra de progresso dourada
     de contatados; contador em números tabulares;
   - botões/checkbox com área de toque ≥44px, foco visível, e ícones SVG inline (NUNCA emoji como ícone);
   - mobile-first de verdade: 1 coluna no celular, grid responsivo no desktop, sem scroll horizontal.
3. Cada contato é um cartão com:
   - Nome, telefone público (link `tel:`), Instagram (link), site (link), fonte e observação da pesquisa;
   - ☑️ **checkbox "Já entrei em contato"** — cartão marcado fica visualmente "apagado" (opacidade menor + selo ✓);
   - 📝 **campo de anotação livre** (textarea) pro mentorado registrar como foi o contato.
4. **Persistência:** salve marcações e anotações no `localStorage` do navegador
   (chave única por página, ex. `prospeccao-<segmento>-<cidade>`, guardando por índice+nome).
   Ao abrir de novo NO MESMO navegador, tudo volta como estava. Avise o mentorado disso na entrega
   (se abrir em outro aparelho, as marcações não acompanham o arquivo).
5. No topo da página: contador "X de Y contatados", campo de busca por nome e filtro
   (todos / pendentes / contatados).
6. Entregue o LINK da página pro mentorado pelo canal em que ele pediu e explique em 2 linhas
   como usar (marcar contatado + anotar; as marcações ficam salvas no navegador dele).

**Teste antes de entregar:** abra mentalmente o fluxo — marcar, anotar, fechar, reabrir.
O JS deve ler o localStorage no load e reaplicar estado. Sem framework, só vanilla JS.
