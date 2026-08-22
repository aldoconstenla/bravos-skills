# Bravos Skills — Marketplace oficial do ecossistema Bravos

Catálogo público de **skills** para os agentes de IA dos mentorados NeuroMaster / Bravos Academy.

## Como instalar uma skill no seu agente

1. Escolha a skill no Marketplace da plataforma NeuroMaster (ou na pasta `skills/` deste repositório).
2. Copie o comando de instalação mostrado no card.
3. Cole o comando numa conversa com o **seu agente**. Exemplo:

> Agente, instale a skill **editar-video-ffmpeg** deste repositório: https://github.com/aldoconstenla/bravos-skills — siga o INSTALL.md da skill.

O agente clona o repositório, valida a origem, copia a skill para a pasta de skills dele e confirma pra você. **Não precisa reiniciar nada** — a skill fica disponível na conversa seguinte.

## Estrutura

```
skills/
  <nome-da-skill>/
    SKILL.md    <- a skill em si (instruções que o agente passa a saber)
    INSTALL.md  <- passo a passo de instalação que o agente executa
```

## Segurança

- Este repositório é **público e sem segredos** — nunca commitamos tokens, senhas ou dados de mentorados.
- Skills oficiais moram SOMENTE aqui. O agente valida a origem (`aldoconstenla/bravos-skills`) antes de instalar.
- v1: skills são instruções em Markdown + assets. Sem scripts executáveis.

## Publicação (equipe)

Skills novas entram por push da Cláudia (agente operacional) após teste em container canário. Depois do push, cadastrar o item no catálogo do NeuroMaster para aparecer no Marketplace.
