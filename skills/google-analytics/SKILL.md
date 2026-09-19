---
name: google-analytics
description: Guiar o mentorado a colocar o Google Analytics (GA4) na página dele e a ler os números. O agente conduz a criação da conta e da propriedade, pega a tag de medição (G-XXXXXXX), instala o código na página (se a página é do agente, ele mesmo instala; se é de terceiros, entrega o trecho e o lugar exato), confere que está medindo, verifica o domínio no Search Console pelo próprio Analytics e explica os relatórios básicos. Lembra de política de privacidade e aviso de cookies (LGPD). Use quando pedirem "colocar Analytics no site", "quantas pessoas entraram na minha página", "instalar a tag do Google", "Search Console", "medir meu site".
---

# Google Analytics (GA4) no site do mentorado

Objetivo: em uma conversa, a página do mentorado passa a ser medida pelo Google Analytics e ele
sabe onde olhar os números. Você faz tudo que dá pra fazer por texto e por código; a pessoa faz
só os cliques que exigem a conta Google dela. Conduza **uma etapa por vez**, com o link direto e
o clique exato. Nunca diga "configure o Analytics": diga onde clicar.

Regras fixas:
- Nunca peça senha, nem acesso à conta Google da pessoa. Você só precisa da **tag de medição**
  (começa com `G-`), que não é segredo.
- Se a página foi feita por você (está nos seus arquivos), **você instala o código**. Se a página
  mora em outra ferramenta (Wix, WordPress, Framer, Hostinger etc.), você entrega o trecho pronto e
  diz exatamente onde colar (cabeçalho / "head") naquela ferramenta.
- Sempre que instalar Analytics, lembre a pessoa (uma frase) de que a página precisa de
  **política de privacidade e aviso de cookies** (LGPD), e ofereça gerar os dois na sequência.

## FASE 1 — Criar a conta e pegar a tag (a pessoa clica, você conduz)

### Etapa 1 — Conta e propriedade
Peça pra abrir **https://analytics.google.com** logada no Gmail que ela quer usar como dono do
site (o mesmo que vai usar no Search Console depois). Diga:
1. Clique em **Começar a medir** (ou, se já tem conta, engrenagem **Administrador** → **Criar** →
   **Propriedade**).
2. **Nome da conta**: o nome do negócio. Marque as caixas de compartilhamento como vier e avance.
3. **Nome da propriedade**: o nome do site. Fuso: Brasil. Moeda: Real (BRL). Avance.
4. Nas perguntas de negócio (setor, tamanho, objetivos), qualquer resposta serve. Aceite os
   termos.
5. Em **Plataforma**, escolha **Web**. Cole a URL do site (com https) e dê um nome ao fluxo.
   Deixe a **medição aprimorada** ligada. Clique em **Criar fluxo**.

### Etapa 2 — A tag
Na tela do fluxo aparece **ID de métricas: G-XXXXXXXXXX**. Peça pra ela copiar e te mandar só
esse código. Confira o formato: `G-` seguido de 8 a 12 letras/números. Se vier `UA-`, é o
Analytics antigo (desligado); peça pra criar uma propriedade GA4 como acima. Se vier `GT-` ou
`AW-`, também serve no mesmo trecho.

Grave em `/data/analytics/config.json`: `{"site":"<url>","ga_id":"G-...","instalado_em":null}`.

## FASE 2 — Instalar na página (você executa)

Trecho oficial (substitua o ID). Vai **dentro do `<head>`, o mais alto possível**, em todas as
páginas:
```html
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```
- **Página sua**: localize o(s) arquivo(s) HTML (ou o layout/template) e insira o trecho logo após
  `<head>`. Se o site for gerado (Next, Astro, etc.), coloque no componente de head compartilhado.
  Publique como você normalmente publica. Depois abra a página e confira no código-fonte que o
  `G-` está lá.
- **Página em outra ferramenta**: entregue o trecho e o caminho: WordPress → plugin "Site Kit"
  (Google) ou o campo de scripts do cabeçalho do tema; Wix → Configurações → Rastreamento e
  análise → Novo → Google Analytics (cola só o ID); Framer/Webflow → Configurações do site →
  Código personalizado → Head; Hostinger Website Builder → Integrações → Google Analytics (ID).
- Não instale duas vezes (dois `G-` na mesma página inflam os números).

### Conferir que está medindo
Peça pra ela abrir o site no celular (rede móvel, não o Wi-Fi do computador) e, em
**analytics.google.com → Relatórios → Tempo real**, ver o contador subir em até 1 minuto. Se
subir, marque `instalado_em` no config e diga "está medindo". Se não subir em 5 minutos: o
trecho não está no `<head>`, o ID está errado, ou há bloqueador de anúncios no aparelho de teste.

## FASE 3 — Search Console pelo próprio Analytics (a pessoa clica)
1. Abrir **https://search.google.com/search-console** com o **mesmo** Gmail.
2. Em **Adicionar propriedade**, escolher a opção da **direita (Prefixo do URL)** e colar a URL
   exata do site (com https e com/sem www igual ao que abre).
3. Em "Verificar a propriedade", abrir **Google Analytics** e clicar em **Verificar**. Funciona
   porque a tag `G-` já está na página e a conta é a mesma. Se falhar, esperar 10 minutos (a tag
   precisa ter sido vista pelo Google) e tentar de novo.
4. Depois de verificado: **Sitemaps** → colar `https://<site>/sitemap.xml` → Enviar (se o site não
   tem sitemap, gere um e publique antes). Explique que os dados do Search Console demoram 1 a 3
   dias pra aparecer.

## FASE 4 — Ler os números (você ensina, em linguagem simples)
Ensine a olhar só três coisas no começo, em **Relatórios**:
- **Tempo real**: quem está no site agora. Serve pra testar anúncio e post.
- **Aquisição → Aquisição de tráfego**: de onde as pessoas vêm (Google orgânico, Instagram,
  anúncio, direto). É onde se vê se o tráfego pago está chegando.
- **Engajamento → Páginas e telas**: quais páginas as pessoas mais abrem e quanto tempo ficam.
Quando a pessoa quiser "conversão" (formulário enviado, clique no WhatsApp), configure um
**evento-chave**: em **Administrador → Eventos**, marque `click` ou crie um evento para o botão
do WhatsApp e ligue a chave. Se a página é sua, dispare `gtag('event','whatsapp_click')` no
clique do botão.

Se a pessoa quiser que **você** leia os relatórios por ela automaticamente, isso pede a API de
dados do GA4 com uma conta de serviço (mesmo desenho da skill google-ads). Ofereça como próximo
passo, não faça agora sem ela pedir.

## Fechamento
Ao terminar: confirme em 3 linhas o que ficou pronto (tag instalada, tempo real medindo, Search
Console verificado), lembre da política de privacidade + aviso de cookies, e diga que em 24-48 h
os relatórios começam a encher.
