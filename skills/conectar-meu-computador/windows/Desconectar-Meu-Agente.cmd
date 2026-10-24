@echo off
rem ============================================================
rem  Desconectar-Meu-Agente.cmd  -  de dois cliques e confirme "Sim"
rem  Corta o acesso do agente ao seu computador (pausar ou remover tudo).
rem ============================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$t=[IO.File]::ReadAllText('%~f0'); $m='#'+'PS'+'_INICIO#'; iex ($t.Substring($t.IndexOf($m)+$m.Length))"
exit /b
#PS_INICIO#
Add-Type -AssemblyName System.Windows.Forms
$base = 'C:\ProgramData\MeuAgente'
$r = [System.Windows.Forms.MessageBox]::Show("SIM = PAUSAR (o agente fica sem acesso; de dois cliques em Conectar de novo pra voltar)`n`nNAO = REMOVER TUDO (apaga a chave do agente, o ajudante, o firewall e sai do Tailscale)`n`nCANCELAR = nao mexer em nada", "Desconectar meu agente", 'YesNoCancel')
if ($r -eq 'Cancel') { exit }
New-Item -ItemType Directory -Force -Path $base | Out-Null
Set-Content (Join-Path $base 'PAUSADO') 'pausado pelo dono'
Stop-ScheduledTask -TaskName 'MeuAgenteAjudante' -ErrorAction SilentlyContinue
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -like '*MeuAgente*ajudante.ps1*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Stop-Service sshd -ErrorAction SilentlyContinue
Set-Service sshd -StartupType Disabled -ErrorAction SilentlyContinue
if ($r -eq 'No') {
  Unregister-ScheduledTask -TaskName 'MeuAgenteAjudante' -Confirm:$false -ErrorAction SilentlyContinue
  Remove-NetFirewallRule -DisplayName 'Meu Agente - SSH via Tailscale' -ErrorAction SilentlyContinue
  Remove-Item 'C:\ProgramData\ssh\administrators_authorized_keys' -Force -ErrorAction SilentlyContinue
  $ts = "$env:ProgramFiles\Tailscale\tailscale.exe"; if (Test-Path $ts) { & $ts logout 2>$null | Out-Null }
  Remove-Item $base -Recurse -Force -ErrorAction SilentlyContinue
  [void][System.Windows.Forms.MessageBox]::Show("Tudo removido. O agente nao tem mais nenhum acesso a este computador.`n(O app Tailscale continua instalado; pode desinstalar pelo Painel de Controle se quiser.)", "Desconectado")
} else {
  [void][System.Windows.Forms.MessageBox]::Show("Acesso PAUSADO. O agente nao consegue mais entrar.`nPra voltar: de dois cliques em Conectar-Meu-Agente.cmd.", "Pausado")
}
