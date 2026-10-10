# Starter Remotion: corte vertical com moldura, títulos e legenda

Projeto pronto pra copiar. Você só escreve o `src/roteiro.ts` de cada vídeo (as cenas e os
tempos); o motor (`src/Main.tsx`) fica igual. Grave cada bloco abaixo no arquivo indicado,
dentro da pasta do projeto (ex.: `/data/projetos/<nome-do-corte>/`).

Estrutura:
```
<projeto>/
  package.json  tsconfig.json
  src/index.ts  src/Root.tsx  src/Main.tsx  src/roteiro.ts
  public/fala.mp4       ← vídeo do falante JÁ recortado (sem áudio), mesma duração do corte
  public/audio.wav      ← áudio do corte, normalizado
  public/palavras.json  ← transcrição palavra a palavra do CORTE (tempos começando em 0)
  entregas/             ← mp4 final e folha de frames
```

## package.json
```json
{
  "name": "corte-video",
  "private": true,
  "scripts": {
    "render": "remotion render src/index.ts Corte entregas/corte.mp4 --codec h264 --pixel-format yuv420p --crf 18 --concurrency 2 --timeout=120000"
  },
  "dependencies": {
    "@remotion/cli": "4.0.533",
    "@remotion/google-fonts": "4.0.533",
    "@remotion/media-utils": "4.0.533",
    "react": "18.3.1",
    "react-dom": "18.3.1",
    "remotion": "4.0.533"
  }
}
```

## tsconfig.json
```json
{
  "compilerOptions": {
    "target": "ES2020", "module": "ES2020", "moduleResolution": "node", "jsx": "react-jsx",
    "strict": false, "esModuleInterop": true, "resolveJsonModule": true, "skipLibCheck": true
  },
  "include": ["src"]
}
```

## src/index.ts
```ts
import {registerRoot} from 'remotion';
import {RemotionRoot} from './Root';
registerRoot(RemotionRoot);
```

## src/Root.tsx
```tsx
import React from 'react';
import {Composition} from 'remotion';
import {Main} from './Main';
import {CONFIG} from './roteiro';
export const RemotionRoot: React.FC = () => (
  <Composition id="Corte" component={Main} durationInFrames={Math.ceil(CONFIG.duracao * 30)} fps={30} width={1080} height={1920} />
);
```

## src/roteiro.ts (o que muda a cada vídeo — exemplo comentado)
```ts
// Tudo em SEGUNDOS do corte (0 = primeiro quadro). Tempos SEMPRE tirados do palavras.json.
export const CONFIG = {
  duracao: 55.2,                 // duração exata do audio.wav (ffprobe)
  cor: '#9BFF5A',                // cor de destaque (1 só)
  corClara: '#C9FF9E',           // variação clara da mesma cor
  alerta: '#FF4D4D',             // 2ª cor, só pra negação/erro (use pouco)
  fundo: '#050c07',              // fundo quase preto puxado pra cor de destaque
};

// Modos da moldura do falante ao longo do vídeo:
//  'card' = moldura grande no centro · 'mini' = moldura menor embaixo, espaço pra título em cima
//  'full' = falante some, tela cheia de motion (títulos gigantes, medidor, ícones)
export const MODOS: [number, 'card' | 'mini' | 'full'][] = [
  [0, 'mini'], [6.0, 'full'], [8.9, 'card'], [14.0, 'full'], [20.6, 'mini'],
];

// "Socos" de zoom: segundos das palavras mais fortes (a moldura dá um empurrão de zoom ali)
export const SOCOS = [1.55, 3.31, 13.1];

// Telas cheias que ganham o anel girando atrás (opcional)
export const ANEIS: {t0: number; t1: number; cy?: number}[] = [{t0: 6.0, t1: 8.9}];

// Marcação nos textos: *palavra* = cor de destaque · [palavra] = caixa colorida · ~palavra~ = cor de alerta
export type Cena =
  | {tipo: 'titulo'; t0: number; t1: number; top: number; size: number; linhas: string[]; atraso?: number}
  | {tipo: 'chip'; t0: number; t1: number; top: number; texto: string; claro?: boolean}
  | {tipo: 'balao'; t0: number; t1: number; top: number; left: number; texto: string}
  | {tipo: 'medidor'; t0: number; t1: number; top: number; nivel: number; total?: number; acende: number; rotulo: string}
  | {tipo: 'check'; t0: number; t1: number; top: number; texto: string}
  | {tipo: 'carimbo'; t0: number; t1: number; top: number; texto: string}
  | {tipo: 'icone'; t0: number; t1: number; top: number; icone: 'pessoa' | 'caixa' | 'alvo' | 'raio' | 'coracao' | 'relogio'};

export const CENAS: Cena[] = [
  {tipo: 'chip', t0: 0, t1: 5.95, top: 110, texto: 'Nome · Programa'},
  {tipo: 'titulo', t0: 0, t1: 2.5, top: 250, size: 140, linhas: ['o *“não”*', 'não é pra você']},
  {tipo: 'titulo', t0: 6.0, t1: 8.85, top: 560, size: 240, linhas: ['*3 níveis*']},
  {tipo: 'medidor', t0: 15.0, t1: 20.5, top: 1130, nivel: 1, acende: 15.2, rotulo: 'nível de consciência'},
  {tipo: 'balao', t0: 13.1, t1: 13.9, top: 980, left: 560, texto: 'Não.'},
];
```

## src/Main.tsx (motor — não precisa mexer)
```tsx
import React from 'react';
import {AbsoluteFill, OffthreadVideo, Audio, staticFile, useCurrentFrame, useVideoConfig, spring, Easing} from 'remotion';
import {useAudioData, visualizeAudio} from '@remotion/media-utils';
import {loadFont as loadAnton} from '@remotion/google-fonts/Anton';
import {loadFont as loadSerif} from '@remotion/google-fonts/InstrumentSerif';
import {loadFont as loadInter} from '@remotion/google-fonts/Inter';
import {loadFont as loadMono} from '@remotion/google-fonts/JetBrainsMono';
import PALAVRAS from '../public/palavras.json';
import {CONFIG, MODOS, SOCOS, ANEIS, CENAS, Cena} from './roteiro';

const {fontFamily: TITULO} = loadAnton();
const {fontFamily: SERIF} = loadSerif('italic');
const {fontFamily: TEXTO} = loadInter();
const {fontFamily: MONO} = loadMono();
const C = CONFIG.cor, C2 = CONFIG.corClara, RED = CONFIG.alerta, BG = CONFIG.fundo, ESCURO = '#0a1a08';
const FPS = 30;
const ease = Easing.bezier(0.22, 1, 0.36, 1);
const cl = (v: number) => Math.max(0, Math.min(1, v));
const useT = () => useCurrentFrame() / FPS;
type P = {w: string; s: number; e: number};
const palavras: P[] = PALAVRAS as P[];
const hex = (h: string, a: number) => { const n = parseInt(h.slice(1), 16); return `rgba(${(n >> 16) & 255},${(n >> 8) & 255},${n & 255},${a})`; };

// ---------- moldura: um elemento só que viaja entre os modos ----------
const RECT = {card: {x: 160, y: 300, w: 760, h: 950, o: 1}, mini: {x: 250, y: 790, w: 580, h: 725, o: 1}, full: {x: 250, y: 1500, w: 580, h: 725, o: 0}};
const modoIdx = (t: number) => { let i = 0; MODOS.forEach(([s], k) => { if (t >= s) i = k; }); return i; };
const modo = (t: number) => MODOS[modoIdx(t)][1];
const rectAt = (t: number) => {
  const i = modoIdx(t); const [s, m] = MODOS[i]; const a = RECT[i > 0 ? MODOS[i - 1][1] : m], b = RECT[m];
  const p = ease(cl((t - s) / 0.45)); const L = (k: keyof typeof a) => a[k] + (b[k] - a[k]) * p;
  return {x: L('x'), y: L('y'), w: L('w'), h: L('h'), o: L('o')};
};

// entrada com mola + saída rápida
const useIn = (t0: number, t1: number) => {
  const f = useCurrentFrame(); const {fps} = useVideoConfig(); const t = f / fps;
  const sp = spring({frame: f - t0 * fps, fps, config: {damping: 15, stiffness: 150, mass: 0.7}});
  const vis = t >= t0 - 0.01 && t <= t1 + 0.25;
  return {sp, op: vis ? Math.min(cl((t - t0) / 0.18), cl((t1 - t) / 0.22)) : 0, vis, t};
};

// *destaque*  [caixa]  ~alerta~
const Marcado: React.FC<{txt: string}> = ({txt}) => {
  const partes = txt.split(/(\*[^*]+\*|\[[^\]]+\]|~[^~]+~)/g).filter(Boolean);
  return <>{partes.map((p, i) => {
    if (p.startsWith('*')) return <span key={i} style={{color: C, textShadow: `0 0 30px ${hex(C, 0.55)}`}}>{p.slice(1, -1)}</span>;
    if (p.startsWith('[')) return <span key={i} style={{background: C, color: ESCURO, padding: '0 18px', borderRadius: 10}}>{p.slice(1, -1)}</span>;
    if (p.startsWith('~')) return <span key={i} style={{color: RED}}>{p.slice(1, -1)}</span>;
    return <span key={i}>{p}</span>;
  })}</>;
};

const Fundo: React.FC = () => {
  const t = useT();
  const pts = Array.from({length: 34}, (_, i) => ({x: ((i * 397) % 1080) + Math.sin(t * 0.6 + i) * 18, y: (((i * 733) % 1920) - t * (14 + (i % 5) * 7) + 7680) % 1920, r: 1.5 + (i % 3), a: 0.15 + (i % 4) * 0.08}));
  const mask = 'radial-gradient(ellipse at 50% 45%, black 30%, transparent 75%)';
  return (
    <AbsoluteFill style={{background: BG}}>
      <AbsoluteFill style={{background: `radial-gradient(ellipse at 50% 32%, ${hex(C, 0.16)}, transparent 58%), radial-gradient(ellipse at 50% 100%, ${hex(C, 0.1)}, transparent 45%)`}} />
      <AbsoluteFill style={{opacity: 0.18, backgroundImage: `linear-gradient(${hex(C, 0.35)} 1px, transparent 1px), linear-gradient(90deg, ${hex(C, 0.35)} 1px, transparent 1px)`, backgroundSize: '90px 90px', backgroundPosition: `0px ${(t * 12) % 90}px`, maskImage: mask, WebkitMaskImage: mask}} />
      <svg width={1080} height={1920} style={{position: 'absolute', inset: 0}}>{pts.map((p, i) => <circle key={i} cx={p.x} cy={p.y} r={p.r} fill={C} opacity={p.a} />)}</svg>
      <AbsoluteFill style={{background: 'radial-gradient(ellipse at 50% 50%, transparent 55%, rgba(0,0,0,.75))'}} />
    </AbsoluteFill>
  );
};

const Anel: React.FC<{t0: number; t1: number; cy?: number}> = ({t0, t1, cy = 760}) => {
  const {op, vis, t} = useIn(t0, t1); if (!vis) return null; const r = 420, cx = 540;
  return <svg width={1080} height={1920} style={{position: 'absolute', inset: 0, zIndex: 3, opacity: op}}>
    <g transform={`rotate(${t * 18} ${cx} ${cy})`}><circle cx={cx} cy={cy} r={r} fill="none" stroke={C} strokeOpacity={0.35} strokeWidth={2} strokeDasharray="6 14" /></g>
    <g transform={`rotate(${-t * 30} ${cx} ${cy})`}><circle cx={cx} cy={cy} r={r * 0.82} fill="none" stroke={C} strokeOpacity={0.55} strokeWidth={4} strokeDasharray={`${r * 1.1} ${r * 0.6}`} /></g>
    <circle cx={cx} cy={cy} r={r * 0.62} fill={hex(C, 0.05)} stroke={C} strokeOpacity={0.25} strokeWidth={1.5} />
  </svg>;
};

const Moldura: React.FC = () => {
  const t = useT(); const r = rectAt(t); if (r.o <= 0.01) return null;
  const brilho = 0.55 + 0.25 * Math.sin(t * 3);
  const soco = SOCOS.reduce((a, s) => a + Math.max(0, 1 - Math.abs(t - s - 0.12) / 0.28) * 0.045, 0);
  const z = 1.04 + 0.015 * Math.sin(t * 0.7) + soco; // micro-zoom contínuo: a imagem nunca fica parada
  return (
    <div style={{position: 'absolute', left: r.x, top: r.y, width: r.w, height: r.h, opacity: r.o, zIndex: 5, borderRadius: 34, overflow: 'hidden', border: `4px solid ${C}`, boxShadow: `0 0 ${40 * brilho}px ${hex(C, 0.55 * brilho)}, 0 30px 80px rgba(0,0,0,.6)`}}>
      <OffthreadVideo src={staticFile('fala.mp4')} muted style={{width: '100%', height: '100%', objectFit: 'cover', transform: `scale(${z})`}} />
      <div style={{position: 'absolute', inset: 0, background: 'linear-gradient(180deg, rgba(0,0,0,0) 62%, rgba(0,0,0,.55))'}} />
      <div style={{position: 'absolute', top: 18, left: 0, right: 0, display: 'flex', justifyContent: 'center'}}><div style={{width: 120, height: 8, borderRadius: 4, background: C, opacity: 0.9}} /></div>
    </div>
  );
};

const Titulo: React.FC<Extract<Cena, {tipo: 'titulo'}>> = ({t0, t1, top, size, linhas, atraso = 0.12}) => {
  const {op, vis, t} = useIn(t0, t1); if (!vis) return null;
  return <div style={{position: 'absolute', top, left: 40, right: 40, textAlign: 'center', zIndex: 7, opacity: op}}>
    {linhas.map((l, i) => { const p = ease(cl((t - t0 - i * atraso) / 0.35));
      return <div key={i} style={{fontFamily: TITULO, fontSize: size, lineHeight: 1.02, color: '#fff', textTransform: 'uppercase', letterSpacing: 1, opacity: p, transform: `translateY(${(1 - p) * 60}px) scale(${0.9 + 0.1 * p})`, filter: `blur(${(1 - p) * 8}px)`, textShadow: '0 8px 40px rgba(0,0,0,.6)'}}><Marcado txt={l} /></div>; })}
  </div>;
};
const Chip: React.FC<Extract<Cena, {tipo: 'chip'}>> = ({t0, t1, top, texto, claro}) => {
  const {sp, op, vis} = useIn(t0, t1); if (!vis) return null;
  return <div style={{position: 'absolute', top, left: 0, right: 0, display: 'flex', justifyContent: 'center', zIndex: 8, opacity: op, transform: `translateY(${(1 - sp) * -30}px)`}}>
    <div style={{fontFamily: TEXTO, fontWeight: 800, fontSize: 30, letterSpacing: 1, padding: '10px 26px', borderRadius: 40, background: claro ? C : 'rgba(10,22,12,.85)', color: claro ? ESCURO : C2, border: `2px solid ${C}`}}>{texto}</div>
  </div>;
};
const Balao: React.FC<Extract<Cena, {tipo: 'balao'}>> = ({t0, t1, top, left, texto}) => {
  const {sp, op, vis} = useIn(t0, t1); if (!vis) return null;
  return <div style={{position: 'absolute', top, left, zIndex: 9, opacity: op, transform: `scale(${0.6 + 0.4 * sp}) rotate(${(1 - sp) * 8}deg)`, transformOrigin: 'left bottom'}}>
    <div style={{background: '#fff', color: '#111', fontFamily: TEXTO, fontWeight: 800, fontSize: 46, padding: '20px 32px', borderRadius: '30px 30px 30px 6px', boxShadow: '0 20px 50px rgba(0,0,0,.5)'}}><svg viewBox="0 0 20 20" width={30} height={30} style={{marginRight: 12, verticalAlign: -3}}><path d="M3 3 L17 17 M17 3 L3 17" stroke={RED} strokeWidth="4.5" strokeLinecap="round" /></svg>{texto}</div>
  </div>;
};
const Medidor: React.FC<Extract<Cena, {tipo: 'medidor'}>> = ({t0, t1, top, nivel, total = 3, acende, rotulo}) => {
  const {sp, op, vis, t} = useIn(t0, t1); if (!vis) return null; const p = ease(cl((t - acende) / 0.5));
  return <div style={{position: 'absolute', top, left: 0, right: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', zIndex: 8, opacity: op, transform: `translateY(${(1 - sp) * 40}px)`}}>
    <div style={{fontFamily: MONO, fontSize: 26, color: C2, letterSpacing: 4, textTransform: 'uppercase', marginBottom: 14}}>{rotulo}</div>
    <div style={{display: 'flex', gap: 16}}>{Array.from({length: total}, (_, k) => k + 1).map((n) => { const on = n < nivel ? 1 : n === nivel ? p : 0;
      return <div key={n} style={{width: Math.min(190, 640 / total), height: 34, borderRadius: 10, border: `2px solid ${C}`, background: hex(C, 0.08 + 0.85 * on), boxShadow: on > 0.5 ? `0 0 30px ${hex(C, 0.6)}` : 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: MONO, fontWeight: 700, fontSize: 22, color: on > 0.5 ? ESCURO : C}}>{n}</div>; })}</div>
  </div>;
};
const Check: React.FC<Extract<Cena, {tipo: 'check'}>> = ({t0, t1, top, texto}) => {
  const {sp, op, vis, t} = useIn(t0, t1); if (!vis) return null; const d = ease(cl((t - t0 - 0.1) / 0.4));
  return <div style={{position: 'absolute', top, left: 0, right: 0, display: 'flex', justifyContent: 'center', zIndex: 9, opacity: op, transform: `translateX(${(1 - sp) * 200}px)`}}>
    <div style={{display: 'flex', alignItems: 'center', gap: 18, background: 'rgba(10,22,12,.9)', border: `3px solid ${C}`, borderRadius: 26, padding: '16px 30px', boxShadow: `0 0 40px ${hex(C, 0.35)}`}}>
      <svg viewBox="0 0 40 40" width={54} height={54}><circle cx="20" cy="20" r="18" fill={C} /><path d="M11 21 L18 28 L30 13" stroke={ESCURO} strokeWidth="5" fill="none" strokeLinecap="round" strokeDasharray={34} strokeDashoffset={34 * (1 - d)} /></svg>
      <span style={{fontFamily: TEXTO, fontWeight: 800, fontSize: 44, color: '#fff'}}>{texto}</span>
    </div>
  </div>;
};
const Carimbo: React.FC<Extract<Cena, {tipo: 'carimbo'}>> = ({t0, t1, top, texto}) => {
  const {sp, op, vis} = useIn(t0, t1); if (!vis) return null;
  return <div style={{position: 'absolute', top, left: 0, right: 0, display: 'flex', justifyContent: 'center', zIndex: 8, opacity: op}}>
    <div style={{fontFamily: TITULO, fontSize: 130, color: RED, border: `8px solid ${RED}`, borderRadius: 18, padding: '0 34px', transform: `rotate(-7deg) scale(${2.2 - 1.2 * sp})`, letterSpacing: 4}}>{texto}</div>
  </div>;
};
const ICONES: Record<string, React.ReactNode> = {
  pessoa: <><circle cx="50" cy="32" r="18" fill={C} /><path d="M16 92 C 18 62, 82 62, 84 92 Z" fill={C} /></>,
  caixa: <><path d="M50 10 L88 28 L88 72 L50 90 L12 72 L12 28 Z" fill={hex(C, 0.15)} stroke={C} strokeWidth="4" /><path d="M12 28 L50 46 L88 28 M50 46 L50 90" stroke={C} strokeWidth="4" fill="none" /></>,
  alvo: <><circle cx="50" cy="50" r="40" fill="none" stroke={C} strokeWidth="6" /><circle cx="50" cy="50" r="24" fill="none" stroke={C} strokeWidth="6" /><circle cx="50" cy="50" r="9" fill={C} /></>,
  raio: <path d="M56 6 L20 56 L46 56 L40 94 L80 40 L54 40 Z" fill={C} />,
  coracao: <path d="M50 88 C 10 60, 8 30, 28 18 C 40 11, 50 20, 50 28 C 50 20, 60 11, 72 18 C 92 30, 90 60, 50 88 Z" fill={C} />,
  relogio: <><circle cx="50" cy="50" r="40" fill="none" stroke={C} strokeWidth="6" /><path d="M50 26 L50 52 L66 62" stroke={C} strokeWidth="6" fill="none" strokeLinecap="round" /></>,
};
const Icone: React.FC<Extract<Cena, {tipo: 'icone'}>> = ({t0, t1, top, icone}) => {
  const {sp, op, vis, t} = useIn(t0, t1); if (!vis) return null;
  return <div style={{position: 'absolute', top: top + Math.sin((t - t0) * 2.4) * 8, left: 0, right: 0, display: 'flex', justifyContent: 'center', zIndex: 7, opacity: op, transform: `scale(${0.5 + 0.5 * sp})`}}>
    <svg viewBox="0 0 100 100" width={180} height={180}>{ICONES[icone]}</svg>
  </div>;
};

// legenda palavra a palavra: grupos curtos, palavra falada na cor de destaque
const GRUPOS: P[][] = (() => {
  const gs: P[][] = []; let cur: P[] = [];
  palavras.forEach((w, i) => { cur.push(w); const nx = palavras[i + 1]; const chars = cur.map((x) => x.w).join(' ').length;
    if (!nx || /[.,?!]$/.test(w.w) || chars > 22 || nx.s - w.e > 0.4 || MODOS.some(([s]) => s > 0 && w.e <= s + 0.05 && nx.s >= s - 0.05)) { gs.push(cur); cur = []; } });
  if (cur.length) gs.push(cur); return gs;
})();
const Legenda: React.FC = () => {
  const t = useT();
  const gi = GRUPOS.findIndex((g, i) => { const nx = GRUPOS[i + 1]; return t >= g[0].s - 0.05 && t < (nx ? nx[0].s - 0.05 : g[g.length - 1].e + 0.5); });
  if (gi < 0) return null; const g = GRUPOS[gi]; const p = ease(cl((t - (g[0].s - 0.05)) / 0.14));
  const ativa = g.reduce((a, w, i) => (t >= w.s - 0.03 ? i : a), -1); const m = modo(t);
  return <div style={{position: 'absolute', zIndex: 12, top: m === 'card' ? 1300 : m === 'mini' ? 1535 : 1420, left: 70, right: 70, textAlign: 'center', fontFamily: SERIF, fontStyle: 'italic', fontSize: 58, lineHeight: 1.1, textTransform: 'uppercase', color: '#fff', letterSpacing: 1, opacity: p, transform: `translateY(${(1 - p) * 10}px)`, textShadow: '0 3px 14px rgba(0,0,0,.95), 0 0 2px rgba(0,0,0,.9)'}}>
    {g.map((w, i) => <span key={i}><span style={{color: i === ativa ? C : '#fff', opacity: i > ativa ? 0.55 : 1}}>{w.w.replace(/[.,?!]/g, '')}</span>{i < g.length - 1 ? ' ' : ''}</span>)}
  </div>;
};

const Barras: React.FC = () => {
  const f = useCurrentFrame(); const {fps} = useVideoConfig(); const audio = useAudioData(staticFile('audio.wav'));
  if (!audio) return null; const v = visualizeAudio({fps, frame: f, audioData: audio, numberOfSamples: 32});
  return <div style={{position: 'absolute', bottom: 150, left: 120, right: 120, height: 90, display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', zIndex: 4, opacity: 0.55}}>
    {[...v.slice(0, 24).reverse(), ...v.slice(0, 24)].map((x, i) => <div key={i} style={{width: 9, height: Math.max(4, Math.min(90, Math.sqrt(x) * 160)), background: C, borderRadius: 3}} />)}
  </div>;
};
const Flash: React.FC = () => {
  const t = useT(); const a = MODOS.filter(([s, m]) => s > 0 && m === 'full').reduce((acc, [s]) => acc + Math.max(0, 1 - Math.abs(t - s) / 0.12) * 0.2, 0);
  return a > 0.01 ? <AbsoluteFill style={{background: C, opacity: a, zIndex: 20, mixBlendMode: 'screen'}} /> : null;
};
const Cenas: React.FC = () => <>{CENAS.map((c, i) => {
  switch (c.tipo) {
    case 'titulo': return <Titulo key={i} {...c} />; case 'chip': return <Chip key={i} {...c} />;
    case 'balao': return <Balao key={i} {...c} />; case 'medidor': return <Medidor key={i} {...c} />;
    case 'check': return <Check key={i} {...c} />; case 'carimbo': return <Carimbo key={i} {...c} />;
    case 'icone': return <Icone key={i} {...c} />; default: return null;
  }
})}</>;

export const Main: React.FC = () => (
  <AbsoluteFill style={{background: BG}}>
    <Fundo /><Barras />{ANEIS.map((a, i) => <Anel key={i} {...a} />)}<Moldura /><Cenas /><Legenda /><Flash />
    <Audio src={staticFile('audio.wav')} />
  </AbsoluteFill>
);
```

## Posições de referência (tela 1080×1920)
- Faixa de cima (chip/rótulo): top 110 a 190.
- Título no modo `mini` (falante embaixo): top 230 a 450, size 110 a 140.
- Título em tela cheia (`full`): top 560 a 900, size 150 a 240.
- Medidor/ícone em tela cheia: top 300 a 1130.
- Moldura `card` ocupa y 300→1250; `mini` ocupa y 790→1515. Não ponha título em cima da moldura.
- Legenda: o motor posiciona sozinho (y 1300 a 1535; no modo `mini` fica logo abaixo da moldura).
- Símbolos (✕ ✓ ★) podem não existir na fonte e virar quadrado: desenhe em SVG, como o balão faz. Nada importante abaixo de y≈1600 (interface do Reels/TikTok).
