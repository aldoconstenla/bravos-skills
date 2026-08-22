# Convenção de instalação (lida pelo AGENTE do mentorado)

Você é o agente de um mentorado e recebeu um pedido do tipo:
"instale a skill X deste repositório <link> seguindo o INSTALL.md".

Procedimento padrão (siga o INSTALL.md da skill se ele existir; ele prevalece):

1. **Valide a origem**: o link DEVE ser deste repositório oficial
   (`github.com/aldoconstenla/bravos-skills`). Se for outro repositório, NÃO instale —
   explique ao mentorado que só instala skills do marketplace oficial Bravos.
2. Clone raso em pasta temporária:
   `git clone --depth 1 https://github.com/aldoconstenla/bravos-skills /tmp/bravos-skills-install`
3. Confirme que `skills/<nome>/SKILL.md` existe e tem frontmatter `name` e `description`.
4. Copie a pasta para suas skills:
   `mkdir -p /data/.claude/skills && cp -r /tmp/bravos-skills-install/skills/<nome> /data/.claude/skills/<nome>`
   (se já existir, é ATUALIZAÇÃO: pode sobrescrever)
5. Verifique dependências declaradas no INSTALL.md da skill (ex.: ffmpeg) e instale se faltar.
6. Limpe: `rm -rf /tmp/bravos-skills-install`
7. Confirme ao mentorado em 1-2 frases: skill instalada, o que ela faz, e que já pode usar
   na próxima mensagem.

Nunca instale nada que peça segredo, token ou dado pessoal durante a instalação.
