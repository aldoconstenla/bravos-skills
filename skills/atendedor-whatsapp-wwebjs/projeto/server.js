// ============================================================
//  MEU ATENDEDOR DE WHATSAPP — BootCamp NeuroMaster
//  3 peças: (1) conexão com o WhatsApp, (2) auto-resposta,
//  (3) uma API HTTP pra outros sistemas mandarem mensagem.
// ============================================================

const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const express = require('express');

// ---------- PEÇA 1: conexão com o WhatsApp ----------
// LocalAuth guarda sua sessão na pasta .wwebjs_auth — você só
// escaneia o QR na primeira vez.
const client = new Client({
  authStrategy: new LocalAuth(),
  puppeteer: { headless: true, args: ['--no-sandbox', '--disable-setuid-sandbox'] }
});

client.on('qr', (qr) => {
  console.log('\n📱 Escaneie este QR com o WhatsApp (Aparelhos conectados):\n');
  qrcode.generate(qr, { small: true });
});

client.on('ready', () => {
  console.log('✅ Conectado! Seu atendedor está no ar.');
  console.log('   Teste a API: http://localhost:3333/status');
});

// ---------- PEÇA 2: auto-resposta (o "atendedor") ----------
// Regras simples: se a mensagem contém X, responde Y.
// Edite o objeto REGRAS e reinicie (Ctrl+C e npm start).
const REGRAS = [
  { contem: ['oi', 'olá', 'ola', 'bom dia', 'boa tarde', 'boa noite'],
    resposta: 'Olá! 👋 Aqui é o atendedor automático. Digite *1* pra ver os serviços ou *2* pra falar com um humano.' },
  { contem: ['1'],
    resposta: 'Nossos serviços:\n• Serviço A\n• Serviço B\n• Serviço C\nResponda com o nome do serviço pra saber mais!' },
  { contem: ['2'],
    resposta: 'Certo! Já chamei um atendente humano, aguarde um instante. 😊' },
];

client.on('message', async (msg) => {
  // Ignora grupos e status — atendedor é pra conversa direta
  if (msg.from.includes('@g.us') || msg.from === 'status@broadcast') return;

  const texto = (msg.body || '').toLowerCase().trim();
  for (const regra of REGRAS) {
    if (regra.contem.some(palavra => texto === palavra || texto.includes(palavra))) {
      await msg.reply(regra.resposta);
      console.log(`🤖 respondi "${texto.slice(0, 30)}" de ${msg.from}`);
      return; // aplica só a primeira regra que casar
    }
  }
});

// ---------- PEÇA 3: API HTTP ----------
// Qualquer sistema seu (site, planilha, outro robô) pode mandar
// mensagem via POST http://localhost:3333/send
const app = express();
app.use(express.json());

app.get('/status', (req, res) => {
  res.json({ ok: true, conectado: client.info ? true : false });
});

app.post('/send', async (req, res) => {
  const { numero, mensagem } = req.body || {};
  if (!numero || !mensagem) {
    return res.status(400).json({ ok: false, erro: 'Envie { "numero": "5511999999999", "mensagem": "..." }' });
  }
  try {
    const chatId = numero.replace(/\D/g, '') + '@c.us';
    await client.sendMessage(chatId, mensagem);
    res.json({ ok: true, para: chatId });
  } catch (e) {
    res.status(500).json({ ok: false, erro: e.message });
  }
});

app.listen(3333, () => console.log('🌐 API no ar em http://localhost:3333'));
client.initialize();
