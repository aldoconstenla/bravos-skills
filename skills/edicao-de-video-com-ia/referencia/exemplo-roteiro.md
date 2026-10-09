# Exemplo completo de roteiro (55 s, vertical)

Corte real feito pela equipe Bravos: trecho de podcast em que o palestrante explica os
3 níveis de consciência na venda ("o não não é pra você"). Use como régua de **densidade e
ritmo**: repare que a cada 2 a 3 segundos entra ou sai alguma coisa, e que os modos da moldura
trocam a cada 5 a 9 s.

Estrutura do corte:
- 0 a 6 s · GANCHO (modo `mini`): a frase mais forte escrita grande desde o quadro 0, em 3 títulos seguidos.
- 6 a 9 s · TELA CHEIA: o tema ("3 níveis de consciência na venda") com anel girando.
- 9 a 14 s · MOLDURA GRANDE: a situação ("quando você oferece um produto…") + balão "Não.".
- 14 a 20,6 s · TELA CHEIA: nível 1 (ícone de pessoa, títulos, medidor acendendo o 1).
- 20,6 a 28,3 s · MOLDURA BAIXA: rejeição (carimbo), "o nível mais baixo", medidor.
- 28,3 a 36,7 s · TELA CHEIA: nível 2 (maturidade, medidor no 2, ícone de caixa = produto).
- 36,7 a 47,9 s · MOLDURA GRANDE: "quando você confia no teu produto" + check.
- 47,9 a 53,3 s · TELA CHEIA: nível 3, a frase do gancho volta ("ela tá dando não pra ela mesma").
- 53,3 a 55,2 s · MOLDURA BAIXA: fechamento ("não é pra você.") + assinatura.

```ts
export const CONFIG = {duracao: 55.13, cor: '#9BFF5A', corClara: '#C9FF9E', alerta: '#FF4D4D', fundo: '#050c07'};

export const MODOS: [number, 'card' | 'mini' | 'full'][] = [
  [0, 'mini'], [6.0, 'full'], [8.9, 'card'], [13.95, 'full'], [20.6, 'mini'],
  [28.3, 'full'], [36.73, 'card'], [47.9, 'full'], [53.3, 'mini'],
];
export const SOCOS = [1.55, 3.31, 5.43, 13.14, 21.86, 25.62, 44.15, 53.97];
export const ANEIS = [{t0: 6.0, t1: 8.9}, {t0: 48.4, t1: 53.3, cy: 900}];

export const CENAS: Cena[] = [
  // GANCHO
  {tipo: 'chip', t0: 0, t1: 5.95, top: 110, texto: 'Nome do convidado no Nome do Podcast'},
  {tipo: 'titulo', t0: 0, t1: 2.5, top: 250, size: 140, linhas: ['o *“não”*', 'não é pra você']},
  {tipo: 'titulo', t0: 2.55, t1: 4.58, top: 250, size: 120, linhas: ['não pegue', 'o *não* dos outros']},
  {tipo: 'titulo', t0: 4.62, t1: 5.98, top: 250, size: 120, linhas: ['ela tá dando não', 'pra [ela mesma]'], atraso: 0.5},
  // TEMA
  {tipo: 'titulo', t0: 6.0, t1: 8.85, top: 560, size: 240, linhas: ['*3 níveis*']},
  {tipo: 'titulo', t0: 7.15, t1: 8.85, top: 900, size: 90, linhas: ['de consciência', 'na venda']},
  // SITUAÇÃO
  {tipo: 'chip', t0: 9.0, t1: 13.9, top: 190, texto: 'quando você oferece um produto…'},
  {tipo: 'balao', t0: 13.1, t1: 13.9, top: 980, left: 560, texto: 'Não.'},
  // NÍVEL 1
  {tipo: 'chip', t0: 14.0, t1: 20.55, top: 170, texto: 'NÍVEL 1 · quem está começando', claro: true},
  {tipo: 'icone', t0: 14.3, t1: 20.55, top: 330, icone: 'pessoa'},
  {tipo: 'titulo', t0: 14.9, t1: 17.7, top: 560, size: 170, linhas: ['quem está', '*começando*'], atraso: 0.25},
  {tipo: 'titulo', t0: 17.8, t1: 20.55, top: 560, size: 200, linhas: ['o não é']},
  {tipo: 'titulo', t0: 19.45, t1: 20.55, top: 790, size: 240, linhas: ['[pra mim]']},
  {tipo: 'medidor', t0: 15.0, t1: 20.55, top: 1130, nivel: 1, acende: 15.2, rotulo: 'nível de consciência'},
  // REJEIÇÃO
  {tipo: 'carimbo', t0: 21.8, t1: 24.4, top: 330, texto: 'REJEITADO'},
  {tipo: 'chip', t0: 20.7, t1: 24.4, top: 150, texto: '“essa pessoa me rejeitou”'},
  {tipo: 'chip', t0: 24.5, t1: 28.25, top: 150, texto: 'o nível mais baixo das vendas'},
  {tipo: 'medidor', t0: 24.6, t1: 28.25, top: 300, nivel: 1, acende: 25.6, rotulo: 'nível 1 de 3'},
  {tipo: 'titulo', t0: 25.55, t1: 28.25, top: 450, size: 130, linhas: ['o mais ~baixo~']},
  // NÍVEL 2
  {tipo: 'chip', t0: 28.35, t1: 36.7, top: 170, texto: 'NÍVEL 2 · maturidade', claro: true},
  {tipo: 'medidor', t0: 28.6, t1: 36.7, top: 300, nivel: 2, acende: 31.1, rotulo: 'com o tempo…'},
  {tipo: 'titulo', t0: 28.85, t1: 30.65, top: 640, size: 170, linhas: ['com o tempo']},
  {tipo: 'titulo', t0: 30.7, t1: 32.45, top: 640, size: 170, linhas: ['[maturidade]']},
  {tipo: 'titulo', t0: 32.5, t1: 34.9, top: 620, size: 150, linhas: ['o não', '~não~ é pra mim']},
  {tipo: 'icone', t0: 35.0, t1: 36.7, top: 560, icone: 'caixa'},
  {tipo: 'titulo', t0: 35.1, t1: 36.7, top: 800, size: 170, linhas: ['é pro meu', '[produto]'], atraso: 0.35},
  // CONFIANÇA
  {tipo: 'chip', t0: 36.85, t1: 40.6, top: 190, texto: 'mais maturidade…'},
  {tipo: 'chip', t0: 40.65, t1: 47.85, top: 190, texto: 'quando você confia no teu produto', claro: true},
  {tipo: 'check', t0: 44.1, t1: 47.85, top: 1080, texto: 'meu produto é bom'},
  // NÍVEL 3 (volta a frase do gancho)
  {tipo: 'chip', t0: 47.95, t1: 53.25, top: 170, texto: 'NÍVEL 3 · o mais alto', claro: true},
  {tipo: 'medidor', t0: 48.1, t1: 53.25, top: 300, nivel: 3, acende: 48.8, rotulo: 'terceiro nível de consciência'},
  {tipo: 'titulo', t0: 48.7, t1: 50.8, top: 620, size: 170, linhas: ['terceiro', '*nível*'], atraso: 0.25},
  {tipo: 'titulo', t0: 50.85, t1: 53.25, top: 640, size: 130, linhas: ['ela tá dando não', 'pra [ela mesma]'], atraso: 0.9},
  // FECHAMENTO
  {tipo: 'titulo', t0: 53.35, t1: 55.2, top: 230, size: 130, linhas: ['não é pra *você*.']},
  {tipo: 'chip', t0: 53.6, t1: 55.2, top: 110, texto: 'Nome · tema do conteúdo'},
];
```

O que observar neste exemplo:
- O gancho usa 3 títulos em 6 s: ritmo alto logo no começo, quando a pessoa decide se fica.
- Em tela cheia, sempre 2 ou 3 elementos que se revezam (chip fixo em cima + títulos que trocam + medidor/ícone).
- Na moldura, poucos elementos (chip em cima + 1 inserção pontual), porque o rosto é o foco.
- A frase do gancho volta perto do fim: o espectador entende por que ela abriu o vídeo.
