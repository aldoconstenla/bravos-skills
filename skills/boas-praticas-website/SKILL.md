---
name: boas-praticas-website
description: Auditar a página/site do mentorado e deixá-la completa depois do prompt que a criou — favicon, title e meta description, imagem de compartilhamento (OG), JSON-LD de negócio local, sitemap.xml, robots.txt, llms.txt, imagens em WebP, política de privacidade e aviso de cookies (LGPD). O agente lê a página, lista item a item o que falta e por quê, e aplica o que o mentorado aprovar (se a página é dele, ele mesmo faz; se é de outra ferramenta, entrega o trecho e o lugar exato). Para medir, aponta as skills google-analytics e microsoft-clarity. Use quando pedirem "vê o que falta no meu site", "meu site está pronto?", "melhorar meu site pro Google", "política de privacidade", "aviso de cookies", "JSON-LD", "favicon", "site lento".
---

# Boas práticas de website (o que fazer DEPOIS que a IA gerou a página)

Uma página gerada por prompt costuma nascer bonita e incompleta: sem ícone, sem prévia no
WhatsApp, invisível pro Google, pesada e sem base legal pra coletar dado. Esta skill fecha isso.
Você faz um **diagnóstico** primeiro, mostra a lista com o porquê de cada item em uma linha, e
só então aplica, um item por vez, com o "ok" da pessoa.

Regras fixas:
- **Página sua** (está nos seus arquivos): você aplica e publica. **Página de outra ferramenta**
  (Wix, WordPress, Framer, Hostinger, Webflow): você entrega o trecho pronto e diz onde colar.
- Nunca invente dado do negócio (endereço, telefone, horário, CNPJ). Pergunte ou pegue do que já
  está na página.
- Não prometa resultado no Google. Estas práticas fazem a página **ser encontrada e entendida**;
  posição é outra conversa.

## PASSO 1 — Diagnóstico (você executa, sem pedir nada)
Peça a URL (ou use a página que você mantém). Baixe o HTML (`curl -sL <url>`) e verifique cada
item. Monte a tabela: ✅ tem · ⚠️ tem mas incompleto · ❌ falta.

| # | Item | Como conferir | Por que importa (diga assim pra pessoa) |
|---|------|---------------|------------------------------------------|
| 1 | Favicon | `<link rel="icon">` presente e o arquivo responde 200 | É o ícone da aba; sem ele o site parece inacabado |
| 2 | Title + meta description | `<title>` com 30-60 caracteres e `<meta name="description">` com 120-160 | É o que o Google mostra no resultado |
| 3 | Imagem de compartilhamento (OG) | `og:title`, `og:description`, `og:image` (1200×630), `og:url`; `twitter:card` | É a prévia quando alguém manda seu link no WhatsApp/Instagram |
| 4 | JSON-LD de negócio local | `<script type="application/ld+json">` com `LocalBusiness` (ou o subtipo: Dentist, Attorney, Physician, etc.) | Diz ao Google quem você é, onde atende, que horas e as perguntas frequentes |
| 5 | sitemap.xml | `/sitemap.xml` responde 200 e lista as páginas | Mapa que o Google segue pra visitar tudo |
| 6 | robots.txt | `/robots.txt` responde 200, permite indexar e aponta o sitemap | Regra do que pode e do que não pode ser indexado |
| 7 | llms.txt | `/llms.txt` (opcional) | Mesma ideia do robots, pras IAs. **Aposta, não obrigação**: não faz mal, não faz milagre |
| 8 | Imagens leves | `<img>` em WebP/AVIF, com `width/height` e `loading="lazy"`; nada acima de ~300 KB | Página que demora a abrir desperdiça o dinheiro do anúncio |
| 9 | Política de privacidade | link visível no rodapé, página existe | LGPD: quem coleta dado (formulário, Analytics, Pixel) precisa dizer o que coleta e pra quê |
| 10 | Aviso de cookies | banner com aceitar/recusar; scripts de análise/marketing só depois do aceite | Guia de cookies da ANPD: cookies não essenciais pedem aviso/consentimento |
| 11 | Medição | tag do Google Analytics e/ou Clarity presente | Se não mede, chuta. Instale pelas skills **google-analytics** e **microsoft-clarity** |

Apresente o resultado como lista curta, do mais importante pro menos: **primeiro 9-10 (base
legal), depois 2-3-4 (ser achado e entendido), depois 1-5-6-8, e 7 por último**. Termine com:
"quer que eu aplique? posso ir um item por vez". Não aplique nada sem o ok.

## PASSO 2 — Aplicar (um item por vez, com o ok)

### 1 · Favicon
Gere um PNG 512×512 com a inicial/logo do negócio (ou peça o logo). No `<head>`:
```html
<link rel="icon" href="/favicon.png" type="image/png">
<link rel="apple-touch-icon" href="/favicon.png">
```

### 2 · Title e meta description
Modelo: **Title** = `O que faz em [cidade] | Nome` (ex.: `Dentista em Alphaville | Dra. Ana Lima`).
**Description** = 1 frase com o serviço, o diferencial e o chamado (`Clareamento e implantes com
avaliação gratuita. Agende pelo WhatsApp.`). Uma por página.

### 3 · Imagem de compartilhamento (OG)
Crie uma imagem 1200×630 com nome, o que faz e uma frase; salve como `/og.jpg`. No `<head>`:
```html
<meta property="og:title" content="...">
<meta property="og:description" content="...">
<meta property="og:image" content="https://SEUSITE/og.jpg">
<meta property="og:url" content="https://SEUSITE/">
<meta property="og:type" content="website">
<meta name="twitter:card" content="summary_large_image">
```
Peça pra pessoa testar mandando o link pra ela mesma no WhatsApp (a prévia pode levar minutos
pra atualizar; se ficar velha, mude a URL da imagem, ex. `/og.jpg?v=2`).

### 4 · JSON-LD de negócio local
Pegue os dados da própria página; o que faltar, pergunte (nome, tipo, endereço completo,
telefone com DDD, horários, URL, 3-6 perguntas frequentes). Escolha o tipo mais específico que
existir (`Dentist`, `Attorney`, `Physician`, `MedicalClinic`, `Restaurant`, `HairSalon`…; na
dúvida `LocalBusiness`). Insira antes de `</head>`:
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Dentist",
  "name": "Nome do negócio",
  "url": "https://SEUSITE/",
  "telephone": "+55 11 9XXXX-XXXX",
  "image": "https://SEUSITE/og.jpg",
  "address": {"@type":"PostalAddress","streetAddress":"Rua X, 123","addressLocality":"Cidade","addressRegion":"SP","postalCode":"00000-000","addressCountry":"BR"},
  "openingHoursSpecification": [{"@type":"OpeningHoursSpecification","dayOfWeek":["Monday","Tuesday","Wednesday","Thursday","Friday"],"opens":"09:00","closes":"18:00"}],
  "sameAs": ["https://instagram.com/perfil"]
}
</script>
<script type="application/ld+json">
{ "@context":"https://schema.org", "@type":"FAQPage", "mainEntity":[
  {"@type":"Question","name":"Pergunta 1?","acceptedAnswer":{"@type":"Answer","text":"Resposta curta."}}
]}
</script>
```
Se o negócio é só online (sem endereço), use `ProfessionalService`/`Organization` sem `address`.
Valide colando o HTML em **https://validator.schema.org** (ou peça pra pessoa colar a URL).

### 5 · sitemap.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>https://SEUSITE/</loc><lastmod>AAAA-MM-DD</lastmod></url>
  <url><loc>https://SEUSITE/politica-de-privacidade</loc></url>
</urlset>
```
Uma linha por página real. Depois de publicar, envie no Search Console (skill google-analytics,
Fase 3).

### 6 · robots.txt
```
User-agent: *
Allow: /
Sitemap: https://SEUSITE/sitemap.xml
```
Nunca deixe `Disallow: /` num site que deve aparecer no Google.

### 7 · llms.txt (opcional, diga que é aposta)
Arquivo de texto na raiz: nome do negócio, uma frase do que faz, cidade, e a lista das páginas
com uma linha cada. Só isso.

### 8 · Imagens leves
Converta para WebP (`cwebp -q 82 foto.jpg -o foto.webp` ou `ffmpeg -i foto.jpg -q:v 80 foto.webp`),
redimensione ao tamanho exibido (hero ≤ 1600 px de largura), e nas tags use `width`, `height` e
`loading="lazy"` (menos na primeira imagem visível). Alvo: página inteira abaixo de ~1,5 MB.

### 9 · Política de privacidade
Gere a página `/politica-de-privacidade` em linguagem simples, com: quem é o controlador (nome,
CNPJ/CPF, e-mail de contato), quais dados coleta (formulário, WhatsApp, Analytics, Clarity, Pixel,
cookies), pra quê, com quem compartilha (Google, Meta, Microsoft), por quanto tempo guarda, os
direitos da pessoa pela LGPD (acesso, correção, exclusão, revogação) e como pedir. Data de
atualização. Link no rodapé de todas as páginas. Diga que é um modelo de boa-fé: para negócio
regulado ou volume grande, um advogado revisa.

### 10 · Aviso de cookies
Banner fixo no rodapé com o texto `Usamos cookies para medir o uso do site e melhorar sua
experiência.` e dois botões: **Aceitar** e **Recusar**, mais link pra política. Regra: os scripts
de análise/marketing (Analytics, Clarity, Pixel) só carregam **depois** do Aceitar; a escolha fica
em `localStorage` por 6-12 meses. Se a página é sua, implemente assim: envolva os scripts numa
função `carregarMedicao()` chamada só quando `localStorage.cookies === 'aceito'`. Em ferramentas
prontas, use o banner nativo (Wix/Hostinger têm) ou um plugin de consentimento.

### 11 · Medição
Se não há tag: ofereça instalar pelas skills **google-analytics** (Analytics + Search Console) e
**microsoft-clarity** (mapa de calor). Se as skills não estiverem instaladas, diga que existem no
marketplace.

## PASSO 3 — Reconferir e fechar
Rode o diagnóstico de novo e mostre a tabela antes × depois. Confirme em 3 linhas o que mudou,
o que ficou pendente por depender da pessoa (dados, logo, revisão jurídica) e lembre que o Google
leva dias pra refletir. Quando a página ganhar Analytics, combine uma leitura em 7 dias.
