---
name: relatorio-semanal-do-negocio
description: Gerar relatório semanal do atendimento no WhatsApp do mentorado a partir do histórico local — quantos clientes chamaram, assuntos mais frequentes, quem ficou sem resposta, follow-ups prometidos e esquecidos. Use quando pedirem "como foi minha semana", "relatório de atendimento", "quem ficou sem resposta", "resumo dos clientes".
---

# Relatório semanal do negócio

## Quando usar
Pedidos como: "como foi a semana?", "quantos clientes me chamaram?", "alguém ficou sem
resposta?", "me dá um resumo do atendimento". Também serve pra período que a pessoa pedir
(dia, quinzena, mês).

## Onde estão os dados
O histórico de mensagens do WhatsApp fica no banco LOCAL do seu container (procure o
arquivo baileys.db — normalmente em /data; use sqlite3 SOMENTE LEITURA: sqlite3 -readonly).
Explore o schema primeiro (.tables / PRAGMA table_info) em vez de assumir nomes de coluna.

## O que medir (regras de honestidade)
1. Conversas com CLIENTES: exclua grupos, o próprio dono e mensagens de sistema.
2. "Sem resposta" = a ÚLTIMA mensagem da conversa é do cliente e ficou mais de X horas sem
   resposta (use 12h como padrão) — não conte quem já foi respondido depois.
3. Diga sempre o PERÍODO exato medido e o que ficou de fora (ex.: "não enxergo atendimentos
   que você fez direto pelo seu celular" — o banco só vê o que passou por aqui).
4. Número que você não conseguiu medir NÃO entra no relatório como se fosse medido.

## Formato de entrega
Resumo curto no topo (3 linhas: total de clientes, destaque da semana, alerta principal),
depois: novos contatos · assuntos mais frequentes · quem está SEM RESPOSTA (nome + há
quanto tempo) · promessas/follow-ups detectados nas conversas ("te mando amanhã", "te aviso")
que ainda não foram cumpridos · 2-3 sugestões práticas pra próxima semana.

## Privacidade
Os dados são do mentorado e ficam no container dele. Nunca envie trechos de conversa de
cliente pra fora, nem cite conteúdo sensível — no relatório, resuma o ASSUNTO, não a conversa.
