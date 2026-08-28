---
name: area-de-membros
description: Instalar e operar a Área de Membros do mentorado — plataforma própria de cursos com painel de administração (cursos, módulos, aulas, "ver como aluno"), painel do aluno com banner, controle de turmas e acessos, aulas por YouTube (player próprio) e Panda Video, PDF e links, descrição em markdown e liberação automática de acesso via webhook da Greenn. Use quando o mentorado quiser vender ou entregar curso próprio numa área de membros dele.
---

# Área de Membros

## O que é
Uma plataforma de área de membros completa e de marca própria: o mentorado gerencia cursos, módulos e aulas num painel de administração, e os alunos dele assistem num painel limpo com a marca DELE. Suporta aulas por link do YouTube (com player próprio, sem cara de YouTube), Panda Video (HLS), PDF e links, descrição das aulas em markdown, turmas, controle de acessos e liberação automática de matrícula via webhook da Greenn.

## Quando usar
O mentorado pediu pra ter área de membros, hospedar um curso próprio, entregar conteúdo pago pra alunos, ou automatizar a liberação de acesso após a compra (Greenn).

## Como instalar
Siga o INSTALL.md desta skill — ele clona o código do repositório oficial da Área de Membros, instala as dependências e sobe o serviço. Na primeira execução o sistema cria o banco de dados completo e o usuário administrador inicial sozinho.

## Como operar depois de instalada
- Toda a personalização (nome do site, logo, cores, textos) é feita por variáveis no `.env` e pela tela de configurações — nada é fixo no código.
- Admin: criar curso → módulos → aulas (link YouTube ou Panda, PDF, links, descrição em markdown) → turmas e acessos. O modo "ver como aluno" mostra exatamente o que o aluno vê.
- Aluno: recebe o link, define a senha no primeiro acesso e assiste.
- Greenn: configure o webhook apontando pra rota indicada no README do projeto; venda aprovada cria o aluno e a matrícula automaticamente, reembolso cancela o acesso.
- O README do repositório é a referência completa (portas, variáveis, backup do banco).

## Regras de ouro
1. NUNCA suba o serviço com o admin inicial padrão sem trocar a senha (o sistema força a troca no primeiro login — não pule).
2. O banco (SQLite) é do MENTORADO: faça backup antes de qualquer atualização de versão.
3. Não edite arquivos do código pra personalizar marca — use o `.env`/configurações; assim as atualizações do repositório não sobrescrevem nada.
