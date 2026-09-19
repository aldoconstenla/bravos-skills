---
name: microsoft-clarity
description: Guiar o mentorado a colocar o Microsoft Clarity (mapa de calor e gravação de sessão, grátis) na página dele e a interpretar o que vê. O agente conduz a criação do projeto, pega o código do Clarity, instala na página (se a página é do agente, ele instala; se é de terceiros, entrega o trecho e o lugar exato), confere que está gravando e explica mapa de calor, gravações e os alertas de frustração. Lembra de política de privacidade e aviso de cookies (LGPD). Use quando pedirem "mapa de calor", "ver onde as pessoas clicam", "por que ninguém clica no botão", "instalar o Clarity", "gravar a navegação do meu site".
---

# Microsoft Clarity no site do mentorado

O Clarity mostra **onde as pessoas clicam, até onde rolam e grava a navegação** de cada visita.
É grátis, sem limite de tráfego. Objetivo: em uma conversa, a página do mentorado passa a ser
gravada e ele sabe ler o mapa de calor. Você conduz **uma etapa por vez**, com link e clique
exatos; a pessoa faz só o que exige a conta dela.

Regras fixas:
- Nunca peça senha nem acesso à conta Microsoft. Você só precisa do **código do projeto**
  (10 caracteres, letras e números), que não é segredo.
- Página feita por você → **você instala**. Página em outra ferramenta → você entrega o trecho e
  o lugar exato.
- Clarity grava sessões: lembre a pessoa (uma frase) de que isso exige **política de privacidade
  e aviso de cookies** (LGPD) e que o Clarity mascara textos digitados por padrão. Ofereça gerar
  os dois documentos na sequência.

## FASE 1 — Criar o projeto (a pessoa clica)
1. Abrir **https://clarity.microsoft.com** e entrar com Google, Microsoft ou Facebook (recomende
   o mesmo Gmail usado no Analytics, pra ficar tudo numa conta só).
2. Clicue em **Adicionar novo projeto**: nome = nome do site, URL = endereço do site (com https),
   categoria = a que mais parecer. **Adicionar novo projeto**.
3. Na tela de instalação escolha **Instalar manualmente**. Aparece um trecho de código com um
   ID de 10 caracteres dentro de `"clarity", "script", "XXXXXXXXXX"`. Peça pra ela copiar o trecho
   inteiro (ou só o ID) e te mandar.

Grave em `/data/clarity/config.json`: `{"site":"<url>","clarity_id":"XXXXXXXXXX","instalado_em":null}`.

## FASE 2 — Instalar (você executa)
Trecho oficial (substitua o ID). Vai **dentro do `<head>`**, em todas as páginas:
```html
<script type="text/javascript">
    (function(c,l,a,r,i,t,y){
        c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
        t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
        y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
    })(window, document, "clarity", "script", "XXXXXXXXXX");
</script>
```
- **Página sua**: insira após `<head>` (pode ficar logo abaixo da tag do Google Analytics, se
  houver). Publique e confira no código-fonte da página publicada que o ID está lá.
- **Outra ferramenta**: WordPress → plugin oficial "Microsoft Clarity" ou o campo de scripts do
  cabeçalho; Wix → Configurações → Rastreamento e análise → Novo → Código personalizado (Head);
  Framer/Webflow → Código personalizado → Head; Hostinger Website Builder → Integrações → Código
  personalizado. Na tela de instalação do Clarity também existe a aba **Instalar em plataforma**
  com o passo a passo de cada uma.
- Se a pessoa já usa o **Google Tag Manager**, o Clarity pode ser instalado por lá (opção na
  mesma tela) sem mexer na página.

### Conferir que está gravando
Peça pra ela abrir o site no celular e navegar 20-30 segundos (rolar, clicar num botão). Em
**clarity.microsoft.com → o projeto → Gravações**, a sessão aparece em até 2 horas (normalmente
minutos). Também dá pra ver em **Configurações → Configuração → Instalação** se está "Rastreando".
Quando aparecer, marque `instalado_em` no config.

## FASE 3 — Ler o Clarity (você ensina, em linguagem simples)
Três lugares, nessa ordem:
- **Mapas de calor**: escolha a página → **Cliques** (onde clicam: se clicam em coisa que não é
  botão, falta clareza) e **Rolagem** (até onde descem: a linha onde metade das pessoas parou é
  onde o botão principal precisa estar).
- **Gravações**: assista 5 sessões de celular. Repare onde a pessoa hesita, volta, e onde sai.
- **Painel → Insights**: "cliques de raiva" (clicou várias vezes no mesmo lugar), "cliques
  mortos" (clicou em algo que não responde) e "rolagem excessiva". Cada um aponta um conserto
  concreto na página.
Se a pessoa faz tráfego pago, ensine a filtrar por **origem** (Filtros → Fonte de tráfego) pra
ver só quem veio do anúncio.

Quando ela trouxer um mapa de calor ou uma gravação, sua devolutiva é **um conserto por vez**:
o que a pessoa fez, o que isso indica, o que mudar na página. Se a página é sua, proponha a
mudança e aplique com o "ok".

## Fechamento
Confirme em 3 linhas o que ficou pronto (código instalado, gravando, onde olhar), lembre da
política de privacidade + aviso de cookies, e combine uma leitura em 7 dias, quando houver
gravações suficientes pra decidir algo.
