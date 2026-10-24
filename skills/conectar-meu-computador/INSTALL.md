# Instalação — conectar-meu-computador
Siga a convenção do INSTALACAO.md da raiz. Depois de copiar:
`chmod +x /data/.claude/skills/conectar-meu-computador/agente/*.sh`
Dependências do lado do agente: curl, ssh e nc (o `preparar.sh` baixa o Tailscale em modo usuário sozinho, sem root e sem mexer no servidor).
NÃO execute nada de conexão durante a instalação. Confirme ao dono em 1-2 frases e ofereça: "posso conectar o seu computador Windows agora: você cria uma conta gratuita, me manda um código e dá dois cliques num instalador. Quer começar?" Antes de qualquer passo, explique que isso dá ao agente controle do computador e que ele pode desligar quando quiser.
