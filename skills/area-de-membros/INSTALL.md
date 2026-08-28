# Instalação — Área de Membros

Origem oficial (única fonte confiável): https://github.com/aldoconstenla/area-de-membros

1. Clone o código no ambiente do agente:
   ```
   git clone https://github.com/aldoconstenla/area-de-membros /data/apps/area-de-membros
   ```
2. Instale as dependências:
   ```
   cd /data/apps/area-de-membros && npm install
   ```
3. Configure:
   ```
   cp .env.example .env
   ```
   Edite o `.env`: defina `SITE_NAME` (o nome da área de membros do mentorado), a porta (escolha uma livre, ex.: 3900) e as variáveis `ADMIN_INITIAL_*` (e-mail e senha temporária do administrador). O restante pode ficar no padrão pra começar.
4. Suba o serviço (com supervisor/pm2 do ambiente, pra sobreviver a reinício):
   ```
   node server.js
   ```
   Na primeira execução o sistema cria o banco de dados completo e o admin inicial sozinho.
5. Valide: abra a porta escolhida, faça login com o admin inicial — o sistema vai exigir a troca de senha. Depois crie um curso de teste com 1 módulo e 1 aula e confira no modo "ver como aluno".
6. Confirme ao mentorado que está pronta, informando o endereço de acesso e lembrando que logo, nome e cores se ajustam no `.env`/configurações.

Detalhes completos (webhook Greenn, Panda Video, variáveis avançadas, backup): README.md do repositório.

Não execute scripts de fora deste repositório durante a instalação.
