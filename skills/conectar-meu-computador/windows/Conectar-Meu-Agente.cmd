@echo off
rem ============================================================
rem  Conectar-Meu-Agente.cmd  -  de dois cliques e confirme "Sim"
rem  Liga o seu computador ao SEU agente de IA (tela, mouse, teclado).
rem  Para desfazer tudo: Desconectar-Meu-Agente.cmd
rem ============================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$t=[IO.File]::ReadAllText('%~f0'); $m='#'+'PS'+'_INICIO#'; iex ($t.Substring($t.IndexOf($m)+$m.Length))"
exit /b
#PS_INICIO#
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms, Microsoft.VisualBasic
function Aviso($msg, $titulo='Conectar meu agente') { $f = New-Object System.Windows.Forms.Form -Property @{TopMost=$true}; [void][System.Windows.Forms.MessageBox]::Show($f, $msg, $titulo); $f.Dispose() }
function Etapa($msg) { Write-Host ""; Write-Host ">> $msg" -ForegroundColor Cyan }
$base = 'C:\ProgramData\MeuAgente'; New-Item -ItemType Directory -Force -Path $base | Out-Null
$tmp  = Join-Path $env:TEMP 'meuagente'; New-Item -ItemType Directory -Force -Path $tmp | Out-Null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try {
  Write-Host "Conectar meu computador ao meu agente de IA" -ForegroundColor Yellow
  Write-Host "Nao feche esta janela. Leva de 2 a 5 minutos."

  # 1) Codigo de conexao que o agente gerou (auth key do Tailscale + chave publica do agente)
  $codigo = [Microsoft.VisualBasic.Interaction]::InputBox("Cole aqui o CODIGO DE CONEXAO que o seu agente te mandou no chat.`n`n(Se voce so quer RETOMAR um acesso pausado, deixe em branco e clique OK.)", "Conectar meu agente", "")
  if (-not $codigo) {
    if (Test-Path (Join-Path $base 'PAUSADO')) {
      Remove-Item (Join-Path $base 'PAUSADO') -Force
      Set-Service sshd -StartupType Automatic -ErrorAction SilentlyContinue; Start-Service sshd -ErrorAction SilentlyContinue
      Start-ScheduledTask -TaskName 'MeuAgenteAjudante' -ErrorAction SilentlyContinue
      Aviso "Acesso RETOMADO. Seu agente voltou a enxergar este computador."; exit
    }
    Aviso "Nenhum codigo colado. Nada foi alterado."; exit
  }
  $cfg = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($codigo.Trim())) | ConvertFrom-Json
  if (-not $cfg.authkey -or -not $cfg.pubkey) { throw "Codigo de conexao invalido. Peca um novo ao seu agente." }
  if ($cfg.authkey -notlike 'tskey-*') { throw "O codigo nao tem uma chave do Tailscale valida." }

  # 2) Tailscale
  $ts = "$env:ProgramFiles\Tailscale\tailscale.exe"
  if (-not (Test-Path $ts)) {
    Etapa "Instalando o Tailscale (rede privada entre o seu PC e o seu agente)..."
    $msi = Join-Path $tmp 'tailscale.msi'
    Invoke-WebRequest 'https://pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.msi' -OutFile $msi -UseBasicParsing
    Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart TS_UNATTENDEDMODE=always" -Wait
    for ($i=0; $i -lt 30 -and -not (Test-Path $ts); $i++) { Start-Sleep 2 }
  }
  Etapa "Entrando na sua rede Tailscale..."
  & $ts up --authkey=$($cfg.authkey) --unattended --reset | Out-Null
  $ip = $null
  for ($i=0; $i -lt 30 -and -not $ip; $i++) { $ip = (& $ts ip -4 2>$null | Select-Object -First 1); if (-not $ip) { Start-Sleep 2 } }
  if (-not $ip) { throw "O Tailscale nao conectou. Confira a internet e peca um codigo novo ao agente." }
  $nome = (& $ts status --json | ConvertFrom-Json).Self.HostName

  # 3) OpenSSH Server (canal do agente)
  if (-not (Get-Service sshd -ErrorAction SilentlyContinue)) {
    Etapa "Instalando o OpenSSH (o canal seguro do agente)..."
    $rel = Invoke-RestMethod 'https://api.github.com/repos/PowerShell/Win32-OpenSSH/releases/latest' -Headers @{ 'User-Agent' = 'meuagente' }
    $asset = $rel.assets | Where-Object { $_.name -like 'OpenSSH-Win64-v*.msi' } | Select-Object -First 1
    if ($asset) {
      $msi2 = Join-Path $tmp 'openssh.msi'
      Invoke-WebRequest $asset.browser_download_url -OutFile $msi2 -UseBasicParsing
      Start-Process msiexec.exe -ArgumentList "/i `"$msi2`" /qn /norestart" -Wait
    } else {
      Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 | Out-Null
    }
  }
  Etapa "Configurando o acesso so por chave (sem senha)..."
  $sshDir = 'C:\ProgramData\ssh'; New-Item -ItemType Directory -Force -Path $sshDir | Out-Null
  Start-Service sshd -ErrorAction SilentlyContinue; Start-Sleep 2; Stop-Service sshd -ErrorAction SilentlyContinue
  $ak = Join-Path $sshDir 'administrators_authorized_keys'
  $linha = $cfg.pubkey.Trim()
  $atual = @(); if (Test-Path $ak) { $atual = Get-Content $ak }
  if ($atual -notcontains $linha) { Add-Content -Path $ak -Value $linha -Encoding ascii }
  icacls $ak /inheritance:r /grant "*S-1-5-32-544:F" /grant "*S-1-5-18:F" | Out-Null
  $conf = Join-Path $sshDir 'sshd_config'
  if (Test-Path $conf) {
    $c = Get-Content $conf
    $c = $c | ForEach-Object { if ($_ -match '^\s*#?\s*PasswordAuthentication\s') { 'PasswordAuthentication no' } else { $_ } }
    if (-not ($c -match '^PasswordAuthentication no')) { $c = @('PasswordAuthentication no') + $c }
    Set-Content -Path $conf -Value $c -Encoding ascii
  }
  Set-Service sshd -StartupType Automatic
  Start-Service sshd

  # 4) Firewall: porta 22 SO pela rede Tailscale (nunca pela internet)
  Etapa "Fechando o firewall (so a sua rede privada entra)..."
  Get-NetFirewallPortFilter -Protocol TCP -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -eq '22' } |
    Get-NetFirewallRule | Where-Object { $_.DisplayName -ne 'Meu Agente - SSH via Tailscale' } | Disable-NetFirewallRule -ErrorAction SilentlyContinue
  Remove-NetFirewallRule -DisplayName 'Meu Agente - SSH via Tailscale' -ErrorAction SilentlyContinue
  New-NetFirewallRule -DisplayName 'Meu Agente - SSH via Tailscale' -Direction Inbound -Protocol TCP -LocalPort 22 -InterfaceAlias 'Tailscale' -Action Allow -Profile Any | Out-Null

  # 5) Ajudante de tela/mouse/teclado (roda na sua sessao, so quando voce esta logado)
  Etapa "Instalando o ajudante de tela e mouse..."
  $helper = @'
# Ajudante do agente: tela, mouse e teclado. Comandos em C:\ProgramData\MeuAgente\io\cmd.txt (1 por linha)
# shot | move x,y | click x,y | dclick x,y | rclick x,y | type texto | key {SENDKEYS} | open url-ou-programa | wait ms
# Interruptor: se existir C:\ProgramData\MeuAgente\PAUSADO, o ajudante nao obedece nada.
Add-Type -MemberDefinition '[DllImport("user32.dll")]public static extern bool SetProcessDPIAware();[DllImport("user32.dll")]public static extern void mouse_event(int f,int x,int y,int d,int e);' -Name M -Namespace W
[W.M]::SetProcessDPIAware() | Out-Null
Add-Type -AssemblyName System.Windows.Forms,System.Drawing
$io="C:\ProgramData\MeuAgente\io"; New-Item -ItemType Directory -Force -Path $io | Out-Null
function Shot($o){ $b=[System.Windows.Forms.SystemInformation]::VirtualScreen; $bmp=New-Object Drawing.Bitmap $b.Width,$b.Height; $g=[Drawing.Graphics]::FromImage($bmp); $g.CopyFromScreen($b.X,$b.Y,0,0,$bmp.Size); $bmp.Save($o,[Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose(); "$($b.Width)x$($b.Height)" }
function Pos($s){ $q=$s-split ','; [System.Windows.Forms.Cursor]::Position=New-Object Drawing.Point([int]$q[0],[int]$q[1]) }
function Clk($d,$u){ [W.M]::mouse_event($d,0,0,0,0); [W.M]::mouse_event($u,0,0,0,0) }
while($true){
  $c=Join-Path $io "cmd.txt"
  if(Test-Path $c){
    $lines=Get-Content $c; Remove-Item $c -Force; $out=@()
    if(Test-Path "C:\ProgramData\MeuAgente\PAUSADO"){ $out+="erro: acesso PAUSADO pelo dono do computador" }
    else { foreach($l in $lines){ $l=$l.Trim(); if(!$l){continue}; $p=$l -split '\s+',2
      try{
        $r=switch($p[0]){
          "shot"{ Shot (Join-Path $io "screen.png") }
          "move"{ Pos $p[1] }
          "click"{ Pos $p[1]; Clk 2 4 }
          "dclick"{ Pos $p[1]; Clk 2 4; Clk 2 4 }
          "rclick"{ Pos $p[1]; Clk 8 16 }
          "type"{ [System.Windows.Forms.SendKeys]::SendWait(($p[1] -replace '([+^%~(){}\[\]])','{$1}')) }
          "key"{ [System.Windows.Forms.SendKeys]::SendWait($p[1]) }
          "open"{ Start-Process $p[1] }
          "wait"{ Start-Sleep -Milliseconds ([int]$p[1]) }
          default { "comando desconhecido" }
        }
        $out+="ok $l $r"
      } catch { $out+="erro $l : $_" } } }
    $out | Out-File (Join-Path $io "result.txt")
  }
  Start-Sleep -Milliseconds 100
}
'@
  $hp = Join-Path $base 'ajudante.ps1'
  Set-Content -Path $hp -Value $helper -Encoding UTF8
  New-Item -ItemType Directory -Force -Path (Join-Path $base 'io') | Out-Null
  Remove-Item (Join-Path $base 'PAUSADO') -ErrorAction SilentlyContinue
  $usuario = "$env:USERDOMAIN\$env:USERNAME"
  # quem rodou como admin pode ser outro usuario; usamos o dono da sessao interativa
  try { $sess = (Get-CimInstance Win32_ComputerSystem).UserName; if ($sess) { $usuario = $sess } } catch {}
  $acao = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$hp`""
  $gatilho = New-ScheduledTaskTrigger -AtLogOn -User $usuario
  $principal = New-ScheduledTaskPrincipal -UserId $usuario -LogonType Interactive -RunLevel Highest
  $sett = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero)
  Register-ScheduledTask -TaskName 'MeuAgenteAjudante' -Action $acao -Trigger $gatilho -Principal $principal -Settings $sett -Force | Out-Null
  Start-ScheduledTask -TaskName 'MeuAgenteAjudante'

  # 6) Codigo de retorno pro agente
  $userSsh = ($usuario -split '\\')[-1]
  $volta = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes((@{ ip = $ip; nome = $nome; usuario = $userSsh } | ConvertTo-Json -Compress)))
  Set-Clipboard -Value $volta
  try { Set-Content -Path ([Environment]::GetFolderPath('Desktop') + '\CODIGO-DO-AGENTE.txt') -Value ("Cole este codigo no chat do seu agente:`r`n`r`n" + $volta) -Encoding UTF8 } catch {}
  Aviso ("Pronto! Seu computador esta conectado.`n`nO CODIGO DE RETORNO ja foi copiado e tambem salvo no arquivo CODIGO-DO-AGENTE.txt na sua Area de Trabalho.`nVolte no chat do seu agente e cole (Ctrl+V).`n`nCodigo: $volta`n`nPra pausar ou desligar: Desconectar-Meu-Agente.cmd") 'Conectado!'
} catch {
  Aviso ("Nao deu certo nesta etapa:`n`n$($_.Exception.Message)`n`nTire um print desta mensagem e mande pro seu agente.") 'Conectar meu agente - erro'
}
