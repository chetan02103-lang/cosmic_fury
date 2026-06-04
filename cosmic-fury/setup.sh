#!/usr/bin/env bash
  # =============================================================
  #  COSMIC FURY — Project Setup Script
  #  Tested on macOS and Linux.
  # =============================================================
  #
  #  USAGE
  #  -----
  #  1. Make executable (first run only):
  #       chmod +x setup.sh
  #
  #  2. Run:
  #       ./setup.sh
  #
  #  3. Install dependencies & start dev server:
  #       cd cosmic-fury
  #       npm install
  #       npm run dev
  #       # Then open http://localhost:5173 in your browser
  #
  #  4. Open in VS Code:
  #       code cosmic-fury
  #       # (requires the 'code' CLI — install via VS Code ⇒ Cmd+Shift+P ⇒ "Shell Command: Install 'code' command in PATH")
  #
  # =============================================================

  set -e
  ROOT="cosmic-fury"

  if [ -d "$ROOT" ]; then
    echo "⚠️  Directory '$ROOT' already exists. Remove it first if you want a clean setup."
    echo "   rm -rf $ROOT"
    exit 1
  fi

  echo ""
  echo "🚀  Creating COSMIC FURY in ./$ROOT/"
  echo ""
  
mkdir -p "$(dirname "$ROOT/package.json")"
cat > "$ROOT/package.json" << '__COSMIC_FURY_EOF__'
{
    "name": "cosmic-fury",
    "version": "1.0.0",
    "private": true,
    "type": "module",
    "scripts": {
      "dev": "vite",
      "build": "tsc && vite build",
      "preview": "vite preview"
    },
    "dependencies": {
      "zustand": "^5.0.0",
      "react": "^18.3.1",
      "react-dom": "^18.3.1"
    },
    "devDependencies": {
      "@types/react": "^18.3.12",
      "@types/react-dom": "^18.3.1",
      "@types/node": "^22.0.0",
      "@vitejs/plugin-react": "^4.3.4",
      "typescript": "^5.6.3",
      "vite": "^6.0.1"
    }
  }
__COSMIC_FURY_EOF__

mkdir -p "$(dirname "$ROOT/tsconfig.json")"
cat > "$ROOT/tsconfig.json" << '__COSMIC_FURY_EOF__'
{
    "compilerOptions": {
      "target": "ES2020",
      "useDefineForClassFields": true,
      "lib": ["ES2020", "DOM", "DOM.Iterable"],
      "module": "ESNext",
      "skipLibCheck": true,
      "moduleResolution": "bundler",
      "allowImportingTsExtensions": true,
      "resolveJsonModule": true,
      "isolatedModules": true,
      "noEmit": true,
      "jsx": "react-jsx",
      "strict": false,
      "paths": { "@/*": ["./src/*"] }
    },
    "include": ["src"]
  }
__COSMIC_FURY_EOF__

mkdir -p "$(dirname "$ROOT/vite.config.ts")"
cat > "$ROOT/vite.config.ts" << '__COSMIC_FURY_EOF__'
import { defineConfig } from "vite";
  import react from "@vitejs/plugin-react";
  import path from "path";
  import { fileURLToPath } from "url";
  const __dirname = path.dirname(fileURLToPath(import.meta.url));
  export default defineConfig({
    plugins: [react()],
    resolve: { alias: { "@": path.resolve(__dirname, "src") } },
    server: { port: 5173, host: "0.0.0.0" },
  });
__COSMIC_FURY_EOF__

mkdir -p "$(dirname "$ROOT/index.html")"
cat > "$ROOT/index.html" << '__COSMIC_FURY_EOF__'
<!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>COSMIC FURY</title>
    </head>
    <body>
      <div id="root"></div>
      <script type="module" src="/src/main.tsx"></script>
    </body>
  </html>
__COSMIC_FURY_EOF__

mkdir -p "$(dirname "$ROOT/src/main.tsx")"
cat > "$ROOT/src/main.tsx" << '__COSMIC_FURY_EOF__'
import { createRoot } from "react-dom/client";
  import App from "./App";
  import "./index.css";
  createRoot(document.getElementById("root")!).render(<App />);
__COSMIC_FURY_EOF__

mkdir -p "$(dirname "$ROOT/src/App.tsx")"
cat > "$ROOT/src/App.tsx" << '__COSMIC_FURY_EOF__'
import Game from "@/pages/Game";
  function App() { return <Game />; }
  export default App;
__COSMIC_FURY_EOF__

mkdir -p "$(dirname "$ROOT/src/index.css")"
cat > "$ROOT/src/index.css" << '__COSMIC_FURY_EOF__'
* { margin: 0; padding: 0; box-sizing: border-box; }
  body { background: #020814; color: #e0eeff; font-family: monospace; overflow: hidden; }
  #root { width: 100vw; height: 100vh; }
__COSMIC_FURY_EOF__

mkdir -p "$(dirname "$ROOT/src/game/types.ts")"
cat > "$ROOT/src/game/types.ts" << '__COSMIC_FURY_EOF__'
export type GameScreen = 'menu' | 'ship-select' | 'playing' | 'upgrade' | 'boss-incoming' | 'gameover';
export type GameMode = 'endless' | 'boss-rush';
export type WeaponType = 'laser' | 'double' | 'plasma' | 'homing';
export type EnemyType = 'scout' | 'tank' | 'swarm' | 'elite' | 'sniper';

export interface TrailPoint {
  x: number; y: number; alpha: number;
}

export interface Player {
  x: number; y: number; vx: number; vy: number;
  angle: number;
  aimAngle: number;
  hp: number; maxHp: number;
  shield: number; maxShield: number;
  shieldTimer: number;
  invincibleTimer: number;
  protectionEnd: number;
  speed: number;
  fireRate: number;
  weapon: WeaponType;
  bulletDamage: number;
  skin: number;
  fireTimer: number;
  score: number;
  coins: number;
  combo: number;
  comboTimer: number;
  comboMax: number;
  specialCooldown: number;
  blackHoleCooldown: number;
  trail: TrailPoint[];
  runXp: number;
}

export interface Enemy {
  id: string;
  type: EnemyType;
  x: number; y: number; vx: number; vy: number;
  angle: number;
  hp: number; maxHp: number;
  coinValue: number;
  scoreValue: number;
  fireTimer: number;
  behaviorTimer: number;
  behaviorPhase: number;
  radius: number;
  speed: number;
  hitFlashTimer: number;
}

export interface Boss {
  x: number; y: number; vx: number; vy: number;
  angle: number;
  hp: number; maxHp: number;
  phase: 1 | 2 | 3;
  attackTimer: number;
  attackPattern: number;
  moveTimer: number;
  moveTargetX: number;
  moveTargetY: number;
  shieldActive: boolean;
  shieldTimer: number;
  entranceTimer: number;
  deathTimer: number;
  radius: number;
  bossNum: number;
  hitFlashTimer: number;
  lastPlayerWeapon: WeaponType;
  plasmaHits: number;
}

export interface BlackHole {
  id: string;
  x: number; y: number;
  life: number; maxLife: number;
  radius: number;
  pullStrength: number;
}

export interface Bullet {
  id: string;
  owner: 'player' | 'enemy' | 'boss';
  x: number; y: number; vx: number; vy: number;
  damage: number;
  life: number;
  style: string;
  size: number;
  homingTargetId?: string;
  angle?: number;
}

export interface Particle {
  id: string;
  x: number; y: number;
  vx: number; vy: number;
  life: number; maxLife: number;
  color: string;
  size: number;
  glow: boolean;
  style: 'dot' | 'spark' | 'ring';
  ringRadius?: number;
}

export interface Coin {
  id: string;
  x: number; y: number;
  vx: number; vy: number;
  value: number;
  life: number;
}

export interface InputState {
  keys: Set<string>;
  mouseX: number;
  mouseY: number;
  mouseDown: boolean;
}

export type UpgradeType = 'speed' | 'firerate' | 'shield' | 'double' | 'plasma' | 'homing' | 'maxhp' | 'damage';

export interface UpgradeOption {
  type: UpgradeType;
  label: string;
  desc: string;
  cost: number;
  color: string;
  icon: string;
  available: boolean;
}

export interface WaveConfig {
  scouts: number;
  tanks: number;
  swarms: number;
  elites: number;
  snipers: number;
  isBoss: boolean;
}

__COSMIC_FURY_EOF__
echo "  ✓  $ROOT/src/game/types.ts"

mkdir -p "$(dirname "$ROOT/src/game/audio.ts")"
cat > "$ROOT/src/game/audio.ts" << '__COSMIC_FURY_EOF__'
class AudioManager {
  private ctx: AudioContext | null = null;
  private masterGain: GainNode | null = null;
  public muted = false;

  init() {
    if (this.ctx) return;
    try {
      this.ctx = new AudioContext();
      this.masterGain = this.ctx.createGain();
      this.masterGain.gain.value = 0.4;
      this.masterGain.connect(this.ctx.destination);
    } catch {}
  }

  private get dest() { return this.masterGain; }
  private get now() { return this.ctx?.currentTime ?? 0; }

  private osc(freq: number, type: OscillatorType, duration: number, gainPeak: number, endFreq?: number) {
    if (!this.ctx || !this.dest || this.muted) return;
    const o = this.ctx.createOscillator();
    const g = this.ctx.createGain();
    o.connect(g); g.connect(this.dest);
    o.type = type;
    o.frequency.setValueAtTime(freq, this.now);
    if (endFreq !== undefined) o.frequency.exponentialRampToValueAtTime(endFreq, this.now + duration);
    g.gain.setValueAtTime(gainPeak, this.now);
    g.gain.exponentialRampToValueAtTime(0.001, this.now + duration);
    o.start(this.now);
    o.stop(this.now + duration + 0.01);
  }

  private noise(duration: number, gainPeak: number, filterFreq: number) {
    if (!this.ctx || !this.dest || this.muted) return;
    const size = Math.floor(this.ctx.sampleRate * duration);
    const buf = this.ctx.createBuffer(1, size, this.ctx.sampleRate);
    const data = buf.getChannelData(0);
    for (let i = 0; i < size; i++) data[i] = Math.random() * 2 - 1;
    const src = this.ctx.createBufferSource();
    src.buffer = buf;
    const g = this.ctx.createGain();
    const f = this.ctx.createBiquadFilter();
    f.type = 'lowpass'; f.frequency.value = filterFreq;
    src.connect(f); f.connect(g); g.connect(this.dest);
    g.gain.setValueAtTime(gainPeak, this.now);
    g.gain.exponentialRampToValueAtTime(0.001, this.now + duration);
    src.start(this.now);
  }

  laser() { this.osc(900, 'sine', 0.08, 0.12, 400); }
  doubleLaser() {
    this.osc(900, 'sine', 0.08, 0.08, 400);
    setTimeout(() => this.osc(1100, 'sine', 0.08, 0.08, 600), 30);
  }
  plasma() { this.osc(180, 'sawtooth', 0.25, 0.15, 80); }
  missile() { this.osc(300, 'sawtooth', 0.15, 0.1, 100); }

  explosion(size = 1.0) {
    this.noise(0.3, 0.35 * size, 150 + size * 80);
    this.osc(120 * size, 'sawtooth', 0.2, 0.1 * size, 30);
  }
  bossExplosion() {
    this.noise(0.6, 0.5, 80);
    this.osc(80, 'sawtooth', 0.4, 0.2, 20);
    setTimeout(() => this.noise(0.4, 0.3, 60), 200);
  }

  coin() { this.osc(1400, 'sine', 0.07, 0.08, 1800); }
  shieldHit() { this.osc(600, 'sine', 0.15, 0.1, 200); }
  playerHit() { this.noise(0.15, 0.25, 300); this.osc(200, 'sawtooth', 0.1, 0.08, 80); }
  bossHit() { this.noise(0.1, 0.15, 200); this.osc(100, 'square', 0.08, 0.06, 50); }
  bossPhase() {
    this.osc(200, 'sawtooth', 0.3, 0.2, 400);
    setTimeout(() => this.osc(300, 'sawtooth', 0.3, 0.15, 600), 150);
  }
  waveComplete() {
    this.osc(600, 'sine', 0.15, 0.1);
    setTimeout(() => this.osc(800, 'sine', 0.15, 0.1), 150);
    setTimeout(() => this.osc(1000, 'sine', 0.2, 0.12), 300);
  }
  comboUp() { this.osc(1200 + (Math.random() * 200), 'sine', 0.05, 0.06); }
}

export const audio = new AudioManager();

__COSMIC_FURY_EOF__
echo "  ✓  $ROOT/src/game/audio.ts"

mkdir -p "$(dirname "$ROOT/src/game/draw.ts")"
cat > "$ROOT/src/game/draw.ts" << '__COSMIC_FURY_EOF__'
import type { Player, Enemy, Boss, Bullet, Particle, Coin, TrailPoint } from './types';

const uid = () => Math.random().toString(36).slice(2);

/* ── Background ────────────────────────────────────────────────── */
export interface StarLayer { x: number; y: number; size: number; alpha: number; speed: number; }
export interface Nebula { x: number; y: number; r: number; color: string; alpha: number; }

export function buildStars(w: number, h: number): StarLayer[] {
  return Array.from({ length: 260 }, () => ({
    x: Math.random() * w,
    y: Math.random() * h,
    size: Math.random() * 2 + 0.2,
    alpha: Math.random() * 0.7 + 0.1,
    speed: (Math.random() * 0.6 + 0.1),
  }));
}

export function buildNebulae(w: number, h: number): Nebula[] {
  const colors = ['#4433ff', '#aa22ff', '#ff2266', '#0055ff', '#22ccff'];
  return Array.from({ length: 8 }, () => ({
    x: Math.random() * w,
    y: Math.random() * h,
    r: 100 + Math.random() * 200,
    color: colors[Math.floor(Math.random() * colors.length)],
    alpha: 0.03 + Math.random() * 0.05,
  }));
}

export function drawBackground(
  ctx: CanvasRenderingContext2D,
  stars: StarLayer[],
  nebulae: Nebula[],
  scrollY: number,
  W: number, H: number,
  time: number
) {
  const bg = ctx.createLinearGradient(0, 0, 0, H);
  bg.addColorStop(0, '#01020d');
  bg.addColorStop(1, '#020515');
  ctx.fillStyle = bg;
  ctx.fillRect(0, 0, W, H);

  for (const n of nebulae) {
    const ny = ((n.y + scrollY * 0.05) % (H + n.r * 2)) - n.r;
    const grad = ctx.createRadialGradient(n.x, ny, 0, n.x, ny, n.r);
    grad.addColorStop(0, n.color + Math.floor(n.alpha * 255).toString(16).padStart(2, '0'));
    grad.addColorStop(1, 'transparent');
    ctx.fillStyle = grad;
    ctx.fillRect(n.x - n.r, ny - n.r, n.r * 2, n.r * 2);
  }

  ctx.globalAlpha = 1;
  for (const s of stars) {
    const sy = ((s.y + scrollY * s.speed) % (H + 4)) - 2;
    const tw = 0.75 + 0.25 * Math.sin(time * 1.5 + s.x * 0.1);
    ctx.globalAlpha = s.alpha * tw;
    ctx.fillStyle = '#c8d8ff';
    ctx.beginPath();
    ctx.arc(s.x, sy, s.size, 0, Math.PI * 2);
    ctx.fill();
  }
  ctx.globalAlpha = 1;
}

/* ── Trail ──────────────────────────────────────────────────────── */
export function drawTrail(ctx: CanvasRenderingContext2D, trail: TrailPoint[], color: string) {
  if (trail.length < 2) return;
  ctx.save();
  for (let i = 1; i < trail.length; i++) {
    const a = trail[i - 1]; const b = trail[i];
    ctx.globalAlpha = b.alpha * 0.55;
    ctx.strokeStyle = color;
    ctx.lineWidth = 4 * b.alpha;
    ctx.shadowBlur = 8;
    ctx.shadowColor = color;
    ctx.beginPath();
    ctx.moveTo(a.x, a.y);
    ctx.lineTo(b.x, b.y);
    ctx.stroke();
  }
  ctx.restore();
}

/* ── Player Ship ────────────────────────────────────────────────── */
const SHIP_COLORS = ['#00e5ff', '#ff6622', '#44ff88'];
const TRAIL_COLORS = ['#0099bb', '#cc4411', '#228844'];
const GLOW_COLORS = ['#00e5ff', '#ff4400', '#00ff66'];

export function getShipColor(skin: number) { return SHIP_COLORS[skin] ?? SHIP_COLORS[0]; }
export function getTrailColor(skin: number) { return TRAIL_COLORS[skin] ?? TRAIL_COLORS[0]; }

export function drawPlayer(ctx: CanvasRenderingContext2D, p: Player, time: number, invincible: boolean) {
  if (invincible && Math.floor(time * 10) % 2 === 0) return;
  const color = SHIP_COLORS[p.skin] ?? SHIP_COLORS[0];
  const glow = GLOW_COLORS[p.skin] ?? GLOW_COLORS[0];
  const S = 16;

  ctx.save();
  ctx.translate(p.x, p.y);
  ctx.rotate(p.angle);

  // Engine flame
  const thrust = Math.hypot(p.vx, p.vy) > 20;
  if (thrust) {
    const fl = S * (0.8 + Math.random() * 0.6);
    const g = ctx.createLinearGradient(-S * 0.4, 0, -S * 0.4 - fl, 0);
    g.addColorStop(0, 'rgba(255,180,0,0.9)');
    g.addColorStop(0.6, 'rgba(255,60,0,0.4)');
    g.addColorStop(1, 'transparent');
    ctx.beginPath();
    ctx.moveTo(-S * 0.5, -S * 0.28);
    ctx.lineTo(-S * 0.4 - fl, 0);
    ctx.lineTo(-S * 0.5, S * 0.28);
    ctx.fillStyle = g;
    ctx.fill();
  }

  ctx.shadowBlur = 18;
  ctx.shadowColor = glow;

  if (p.skin === 0) {
    // Fighter: classic V-shape
    ctx.strokeStyle = color; ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(S, 0);
    ctx.lineTo(-S * 0.5, -S * 0.75);
    ctx.lineTo(-S * 0.25, 0);
    ctx.lineTo(-S * 0.5, S * 0.75);
    ctx.closePath();
    ctx.stroke();
    ctx.fillStyle = color + '1a'; ctx.fill();
    // Accent lines
    ctx.strokeStyle = color + 'aa'; ctx.lineWidth = 1;
    ctx.beginPath(); ctx.moveTo(S * 0.3, 0); ctx.lineTo(-S * 0.2, -S * 0.4); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(S * 0.3, 0); ctx.lineTo(-S * 0.2, S * 0.4); ctx.stroke();
  } else if (p.skin === 1) {
    // Destroyer: wide, boxy
    ctx.strokeStyle = color; ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(S, 0);
    ctx.lineTo(S * 0.3, -S * 0.6);
    ctx.lineTo(-S * 0.6, -S * 0.9);
    ctx.lineTo(-S * 0.8, -S * 0.3);
    ctx.lineTo(-S * 0.5, 0);
    ctx.lineTo(-S * 0.8, S * 0.3);
    ctx.lineTo(-S * 0.6, S * 0.9);
    ctx.lineTo(S * 0.3, S * 0.6);
    ctx.closePath();
    ctx.stroke();
    ctx.fillStyle = color + '1a'; ctx.fill();
  } else {
    // Interceptor: sleek arrowhead
    ctx.strokeStyle = color; ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(S, 0);
    ctx.lineTo(S * 0.2, -S * 0.25);
    ctx.lineTo(-S * 0.7, -S * 0.55);
    ctx.lineTo(-S * 0.9, -S * 0.2);
    ctx.lineTo(-S * 0.6, 0);
    ctx.lineTo(-S * 0.9, S * 0.2);
    ctx.lineTo(-S * 0.7, S * 0.55);
    ctx.lineTo(S * 0.2, S * 0.25);
    ctx.closePath();
    ctx.stroke();
    ctx.fillStyle = color + '1a'; ctx.fill();
  }

  // Engine glow dot
  ctx.shadowBlur = 10;
  ctx.fillStyle = '#ffaa22';
  ctx.beginPath(); ctx.arc(-S * 0.4, 0, 3, 0, Math.PI * 2); ctx.fill();

  ctx.restore();
}

/* ── Enemies ────────────────────────────────────────────────────── */
export function drawEnemy(ctx: CanvasRenderingContext2D, e: Enemy, time: number) {
  ctx.save();
  ctx.translate(e.x, e.y);
  ctx.rotate(e.angle);

  switch (e.type) {
    case 'scout': {
      ctx.shadowBlur = 12; ctx.shadowColor = '#44ff44';
      ctx.strokeStyle = '#44ff44'; ctx.lineWidth = 1.5;
      ctx.beginPath();
      ctx.moveTo(14, 0); ctx.lineTo(-10, -9); ctx.lineTo(-6, 0); ctx.lineTo(-10, 9);
      ctx.closePath(); ctx.stroke();
      ctx.fillStyle = '#44ff4411'; ctx.fill();
      // Engine
      ctx.fillStyle = '#ffaa00';
      ctx.shadowColor = '#ffaa00'; ctx.shadowBlur = 6;
      ctx.beginPath(); ctx.arc(-7, 0, 2.5, 0, Math.PI * 2); ctx.fill();
      break;
    }
    case 'tank': {
      ctx.shadowBlur = 14; ctx.shadowColor = '#ff3322';
      ctx.strokeStyle = '#cc2211'; ctx.lineWidth = 2;
      // Body
      ctx.beginPath();
      ctx.moveTo(18, 0); ctx.lineTo(10, -14);
      ctx.lineTo(-14, -14); ctx.lineTo(-18, -6);
      ctx.lineTo(-18, 6); ctx.lineTo(-14, 14);
      ctx.lineTo(10, 14); ctx.closePath(); ctx.stroke();
      ctx.fillStyle = '#441111'; ctx.fill();
      // Cannons
      ctx.strokeStyle = '#ff4433'; ctx.lineWidth = 3;
      ctx.beginPath(); ctx.moveTo(14, -8); ctx.lineTo(22, -8); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(14, 8); ctx.lineTo(22, 8); ctx.stroke();
      // Core glow
      ctx.fillStyle = '#ff2200'; ctx.shadowColor = '#ff2200'; ctx.shadowBlur = 10;
      ctx.beginPath(); ctx.arc(0, 0, 5, 0, Math.PI * 2); ctx.fill();
      break;
    }
    case 'swarm': {
      ctx.shadowBlur = 8; ctx.shadowColor = '#00ccff';
      ctx.strokeStyle = '#00ccff'; ctx.lineWidth = 1.2;
      ctx.beginPath();
      ctx.moveTo(9, 0); ctx.lineTo(0, -6); ctx.lineTo(-9, 0); ctx.lineTo(0, 6);
      ctx.closePath(); ctx.stroke();
      ctx.fillStyle = '#00ccff22'; ctx.fill();
      break;
    }
    case 'elite': {
      ctx.shadowBlur = 16; ctx.shadowColor = '#cc44ff';
      ctx.strokeStyle = '#aa22ff'; ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo(16, 0); ctx.lineTo(6, -12);
      ctx.lineTo(-8, -16); ctx.lineTo(-16, -6);
      ctx.lineTo(-12, 0); ctx.lineTo(-16, 6);
      ctx.lineTo(-8, 16); ctx.lineTo(6, 12);
      ctx.closePath(); ctx.stroke();
      ctx.fillStyle = '#330044'; ctx.fill();
      // Rotating accent ring
      ctx.rotate(time * 2);
      ctx.strokeStyle = '#ff44ff66'; ctx.lineWidth = 1;
      ctx.setLineDash([4, 4]);
      ctx.beginPath(); ctx.arc(0, 0, 10, 0, Math.PI * 2); ctx.stroke();
      ctx.setLineDash([]);
      break;
    }
  }
  ctx.restore();
}

/* ── Boss ───────────────────────────────────────────────────────── */
export function drawBoss(ctx: CanvasRenderingContext2D, boss: Boss, time: number) {
  const { x, y, angle, hp, maxHp, phase, shieldActive, entranceTimer } = boss;
  const alive = boss.deathTimer <= 0;

  ctx.save();
  ctx.translate(x, y);

  // Phase colors
  const coreColor = phase === 3 ? '#ff0044' : phase === 2 ? '#ff6600' : '#cc44ff';
  const accentColor = phase === 3 ? '#ff4477' : phase === 2 ? '#ffaa00' : '#ee88ff';
  const glowColor = phase === 3 ? '#ff0033' : phase === 2 ? '#ff8800' : '#aa00ff';

  ctx.rotate(angle + (phase >= 2 ? time * 0.3 : time * 0.15));

  if (alive) {
    ctx.shadowBlur = 40; ctx.shadowColor = glowColor;

    // Outer arms (6)
    for (let i = 0; i < 6; i++) {
      ctx.save();
      ctx.rotate((i / 6) * Math.PI * 2);
      ctx.strokeStyle = accentColor; ctx.lineWidth = 3;
      ctx.beginPath();
      ctx.moveTo(28, 0); ctx.lineTo(60, 0);
      ctx.stroke();
      // Cannon tip
      ctx.fillStyle = coreColor; ctx.shadowColor = coreColor; ctx.shadowBlur = 12;
      ctx.beginPath(); ctx.arc(60, 0, 5, 0, Math.PI * 2); ctx.fill();
      ctx.restore();
    }

    // Main body (hexagon)
    ctx.strokeStyle = accentColor; ctx.lineWidth = 3;
    ctx.beginPath();
    for (let i = 0; i < 6; i++) {
      const a = (i / 6) * Math.PI * 2;
      i === 0 ? ctx.moveTo(Math.cos(a) * 28, Math.sin(a) * 28)
               : ctx.lineTo(Math.cos(a) * 28, Math.sin(a) * 28);
    }
    ctx.closePath(); ctx.stroke();
    ctx.fillStyle = '#110022'; ctx.fill();

    // Inner rotating ring (phase 2+)
    if (phase >= 2) {
      ctx.save();
      ctx.rotate(-time * 4);
      ctx.strokeStyle = coreColor + 'aa'; ctx.lineWidth = 2;
      ctx.setLineDash([6, 4]);
      ctx.beginPath(); ctx.arc(0, 0, 20, 0, Math.PI * 2); ctx.stroke();
      ctx.setLineDash([]);
      ctx.restore();
    }

    // Core pulsing
    const pulse = 0.7 + 0.3 * Math.sin(time * 6 + phase);
    const coreR = 12 * pulse;
    const coreGrad = ctx.createRadialGradient(0, 0, 0, 0, 0, coreR);
    coreGrad.addColorStop(0, '#ffffff');
    coreGrad.addColorStop(0.3, coreColor);
    coreGrad.addColorStop(1, glowColor + '00');
    ctx.fillStyle = coreGrad;
    ctx.shadowBlur = 20; ctx.shadowColor = coreColor;
    ctx.beginPath(); ctx.arc(0, 0, coreR, 0, Math.PI * 2); ctx.fill();

    // HP bar arc
    const hpAngle = (hp / maxHp) * Math.PI * 2;
    ctx.strokeStyle = '#00ff8866'; ctx.lineWidth = 4;
    ctx.beginPath(); ctx.arc(0, 0, 38, -Math.PI / 2, -Math.PI / 2 + hpAngle); ctx.stroke();
  }

  // Shield bubble
  if (shieldActive) {
    ctx.rotate(-angle);
    ctx.strokeStyle = '#00ccff'; ctx.lineWidth = 2; ctx.globalAlpha = 0.5 + 0.3 * Math.sin(time * 8);
    ctx.shadowBlur = 20; ctx.shadowColor = '#00ccff';
    ctx.setLineDash([8, 6]);
    ctx.lineDashOffset = -time * 30;
    ctx.beginPath(); ctx.arc(0, 0, 75, 0, Math.PI * 2); ctx.stroke();
    ctx.setLineDash([]);
    ctx.globalAlpha = 1;
  }

  ctx.restore();
}

/* ── Bullets ────────────────────────────────────────────────────── */
export function drawBullet(ctx: CanvasRenderingContext2D, b: Bullet, time: number) {
  ctx.save();
  switch (b.style) {
    case 'laser': {
      ctx.shadowBlur = 12; ctx.shadowColor = '#00e5ff';
      ctx.fillStyle = '#00e5ff';
      ctx.beginPath(); ctx.arc(b.x, b.y, b.size, 0, Math.PI * 2); ctx.fill();
      // Streak
      const len = 12; const dx = b.vx / Math.hypot(b.vx, b.vy);
      const dy = b.vy / Math.hypot(b.vx, b.vy);
      ctx.strokeStyle = '#00e5ff88'; ctx.lineWidth = 2;
      ctx.beginPath(); ctx.moveTo(b.x - dx * len, b.y - dy * len); ctx.lineTo(b.x, b.y); ctx.stroke();
      break;
    }
    case 'double': {
      ctx.shadowBlur = 10; ctx.shadowColor = '#00ff88';
      ctx.fillStyle = '#00ff88';
      ctx.beginPath(); ctx.arc(b.x, b.y, b.size, 0, Math.PI * 2); ctx.fill();
      const len2 = 10; const dx2 = b.vx / Math.hypot(b.vx, b.vy); const dy2 = b.vy / Math.hypot(b.vx, b.vy);
      ctx.strokeStyle = '#00ff8866'; ctx.lineWidth = 1.5;
      ctx.beginPath(); ctx.moveTo(b.x - dx2 * len2, b.y - dy2 * len2); ctx.lineTo(b.x, b.y); ctx.stroke();
      break;
    }
    case 'plasma': {
      const pulse = 0.8 + 0.2 * Math.sin(time * 15);
      const r = b.size * pulse;
      const grad = ctx.createRadialGradient(b.x, b.y, 0, b.x, b.y, r);
      grad.addColorStop(0, '#ffffff');
      grad.addColorStop(0.3, '#aa00ff');
      grad.addColorStop(1, '#4400ff00');
      ctx.fillStyle = grad; ctx.shadowBlur = 20; ctx.shadowColor = '#8800ff';
      ctx.beginPath(); ctx.arc(b.x, b.y, r, 0, Math.PI * 2); ctx.fill();
      break;
    }
    case 'missile': {
      ctx.shadowBlur = 10; ctx.shadowColor = '#ffaa00';
      ctx.fillStyle = '#ffcc00';
      ctx.save(); ctx.translate(b.x, b.y); ctx.rotate(Math.atan2(b.vy, b.vx));
      ctx.beginPath(); ctx.moveTo(8, 0); ctx.lineTo(-6, -4); ctx.lineTo(-4, 0); ctx.lineTo(-6, 4); ctx.closePath();
      ctx.fill(); ctx.restore();
      break;
    }
    case 'e_basic': {
      ctx.shadowBlur = 8; ctx.shadowColor = '#ff6600';
      ctx.fillStyle = '#ff4400';
      ctx.beginPath(); ctx.arc(b.x, b.y, b.size, 0, Math.PI * 2); ctx.fill();
      break;
    }
    case 'e_spread': {
      ctx.shadowBlur = 8; ctx.shadowColor = '#ff8800';
      ctx.fillStyle = '#ff6600';
      ctx.beginPath(); ctx.arc(b.x, b.y, b.size, 0, Math.PI * 2); ctx.fill();
      const l3 = 8; const dx3 = b.vx / Math.hypot(b.vx, b.vy); const dy3 = b.vy / Math.hypot(b.vx, b.vy);
      ctx.strokeStyle = '#ff660066'; ctx.lineWidth = 2;
      ctx.beginPath(); ctx.moveTo(b.x - dx3 * l3, b.y - dy3 * l3); ctx.lineTo(b.x, b.y); ctx.stroke();
      break;
    }
    case 'e_homing': {
      ctx.shadowBlur = 10; ctx.shadowColor = '#ff44ff';
      ctx.fillStyle = '#ee00ff';
      ctx.beginPath(); ctx.arc(b.x, b.y, b.size, 0, Math.PI * 2); ctx.fill();
      break;
    }
    case 'b_beam': {
      const pulse2 = 0.7 + 0.3 * Math.sin(time * 20);
      ctx.shadowBlur = 16; ctx.shadowColor = '#aa00ff';
      ctx.fillStyle = '#cc44ff';
      ctx.beginPath(); ctx.arc(b.x, b.y, b.size * pulse2, 0, Math.PI * 2); ctx.fill();
      break;
    }
    case 'b_orb': {
      const pulse3 = 0.85 + 0.15 * Math.sin(time * 12);
      const gr = ctx.createRadialGradient(b.x, b.y, 0, b.x, b.y, b.size * pulse3);
      gr.addColorStop(0, '#ffffff');
      gr.addColorStop(0.4, '#ff2255');
      gr.addColorStop(1, '#ff000000');
      ctx.fillStyle = gr; ctx.shadowBlur = 20; ctx.shadowColor = '#ff0044';
      ctx.beginPath(); ctx.arc(b.x, b.y, b.size * pulse3, 0, Math.PI * 2); ctx.fill();
      break;
    }
  }
  ctx.restore();
}

/* ── Particles ──────────────────────────────────────────────────── */
export function drawParticle(ctx: CanvasRenderingContext2D, p: Particle) {
  const t = p.life / p.maxLife;
  ctx.save();
  ctx.globalAlpha = t;

  if (p.style === 'ring') {
    const r = (p.ringRadius ?? 10) * (1 - t) * 3;
    ctx.strokeStyle = p.color; ctx.lineWidth = 2 * t;
    if (p.glow) { ctx.shadowBlur = 12; ctx.shadowColor = p.color; }
    ctx.beginPath(); ctx.arc(p.x, p.y, r, 0, Math.PI * 2); ctx.stroke();
  } else if (p.style === 'spark') {
    const dx = p.vx / Math.hypot(p.vx, p.vy) * p.size * 3;
    const dy = p.vy / Math.hypot(p.vx, p.vy) * p.size * 3;
    ctx.strokeStyle = p.color; ctx.lineWidth = p.size * 0.8;
    if (p.glow) { ctx.shadowBlur = 6; ctx.shadowColor = p.color; }
    ctx.beginPath(); ctx.moveTo(p.x - dx, p.y - dy); ctx.lineTo(p.x, p.y); ctx.stroke();
  } else {
    if (p.glow) { ctx.shadowBlur = 8; ctx.shadowColor = p.color; }
    ctx.fillStyle = p.color;
    ctx.beginPath(); ctx.arc(p.x, p.y, p.size * t, 0, Math.PI * 2); ctx.fill();
  }
  ctx.restore();
}

/* ── Coins ──────────────────────────────────────────────────────── */
export function drawCoin(ctx: CanvasRenderingContext2D, c: Coin, time: number) {
  const bob = Math.sin(time * 4 + c.x) * 2;
  ctx.save();
  ctx.translate(c.x, c.y + bob);
  ctx.shadowBlur = 10; ctx.shadowColor = '#ffcc00';
  ctx.fillStyle = '#ffcc00';
  ctx.beginPath(); ctx.arc(0, 0, 6, 0, Math.PI * 2); ctx.fill();
  ctx.fillStyle = '#ffee88';
  ctx.beginPath(); ctx.arc(-1.5, -1.5, 2.5, 0, Math.PI * 2); ctx.fill();
  ctx.restore();
}

/* ── Cursor Rocket ──────────────────────────────────────────────── */
export function drawCursorRocket(ctx: CanvasRenderingContext2D, x: number, y: number, angle: number, time: number) {
  const S = 12;
  ctx.save();
  ctx.translate(x, y); ctx.rotate(angle);
  const pulse = 0.6 + 0.4 * Math.sin(time * 12);
  const fl = S * (0.9 + pulse * 0.5);
  const grad = ctx.createLinearGradient(-S * 0.4, 0, -S * 0.4 - fl, 0);
  grad.addColorStop(0, `rgba(255,180,0,${0.9 * pulse})`);
  grad.addColorStop(0.6, `rgba(255,60,0,${0.4 * pulse})`);
  grad.addColorStop(1, 'transparent');
  ctx.beginPath();
  ctx.moveTo(-S * 0.4, -S * 0.22); ctx.lineTo(-S * 0.4 - fl, 0); ctx.lineTo(-S * 0.4, S * 0.22);
  ctx.fillStyle = grad; ctx.fill();
  ctx.shadowBlur = 16; ctx.shadowColor = '#ff9900';
  ctx.strokeStyle = '#ffaa33'; ctx.lineWidth = 1.5;
  ctx.beginPath();
  ctx.moveTo(S, 0); ctx.lineTo(-S * 0.4, -S * 0.55);
  ctx.lineTo(-S * 0.7, -S * 0.28); ctx.lineTo(-S * 0.4, 0);
  ctx.lineTo(-S * 0.7, S * 0.28); ctx.lineTo(-S * 0.4, S * 0.55);
  ctx.closePath(); ctx.stroke();
  ctx.fillStyle = 'rgba(255,130,20,0.18)'; ctx.fill();
  ctx.shadowBlur = 8; ctx.shadowColor = '#ffffaa'; ctx.fillStyle = '#ffee88';
  ctx.beginPath(); ctx.arc(S * 0.35, 0, S * 0.18, 0, Math.PI * 2); ctx.fill();
  ctx.restore();
}

/* ── Explosion factory ──────────────────────────────────────────── */
export function makeExplosion(x: number, y: number, color: string, count = 14, big = false): Particle[] {
  const parts: Particle[] = [];
  const base = big ? 2.2 : 1.0;
  // Shockwave ring
  parts.push({ id: uid(), x, y, vx: 0, vy: 0, life: 0.4, maxLife: 0.4, color, size: 4, glow: true, style: 'ring', ringRadius: big ? 30 : 16 });
  // Sparks
  for (let i = 0; i < count; i++) {
    const a = Math.random() * Math.PI * 2;
    const spd = 80 + Math.random() * (big ? 220 : 130);
    parts.push({ id: uid(), x, y, vx: Math.cos(a) * spd, vy: Math.sin(a) * spd, life: 0.4 + Math.random() * 0.5, maxLife: 0.9, color, size: base + Math.random() * 2, glow: true, style: 'spark' });
  }
  // Glowing dots
  for (let i = 0; i < Math.floor(count * 0.6); i++) {
    const a = Math.random() * Math.PI * 2;
    const spd = 30 + Math.random() * 80;
    parts.push({ id: uid(), x, y, vx: Math.cos(a) * spd, vy: Math.sin(a) * spd, life: 0.5 + Math.random() * 0.8, maxLife: 1.3, color: '#ffffff', size: base, glow: false, style: 'dot' });
  }
  return parts;
}

__COSMIC_FURY_EOF__
echo "  ✓  $ROOT/src/game/draw.ts"

mkdir -p "$(dirname "$ROOT/src/game/store.ts")"
cat > "$ROOT/src/game/store.ts" << '__COSMIC_FURY_EOF__'
import { create } from 'zustand';
import type {
  GameScreen, GameMode, Player, Enemy, Boss, Bullet, Particle, Coin,
  InputState, UpgradeType, UpgradeOption, WaveConfig, WeaponType,
} from './types';
import { makeExplosion } from './draw';
import { audio } from './audio';

const uid = () => Math.random().toString(36).slice(2, 9);

/* ── Constants ─────────────────────────────────────────────────── */
const PLAYER_RADIUS = 14;
const COIN_ATTRACT_RADIUS = 90;
const COMBO_EXPIRE = 3.0;
const BOSS_WAVES = [3, 6, 9, 12]; // multiples of 3

/* ── Helpers ───────────────────────────────────────────────────── */
function clamp(v: number, lo: number, hi: number) { return Math.max(lo, Math.min(hi, v)); }
function angleDiff(a: number, b: number) {
  let d = ((b - a + Math.PI * 3) % (Math.PI * 2)) - Math.PI;
  return d;
}
function randomEdge(W: number, H: number): [number, number] {
  const side = Math.floor(Math.random() * 4);
  if (side === 0) return [Math.random() * W, -30];
  if (side === 1) return [W + 30, Math.random() * H];
  if (side === 2) return [Math.random() * W, H + 30];
  return [-30, Math.random() * H];
}

function makePlayer(skin: number, weapon: WeaponType): Player {
  return {
    x: 0, y: 0, vx: 0, vy: 0,
    angle: -Math.PI / 2, aimAngle: -Math.PI / 2,
    hp: 3, maxHp: 3,
    shield: 0, maxShield: 3,
    shieldTimer: 0,
    invincibleTimer: 0,
    protectionEnd: Date.now() + 3000,
    speed: 230, fireRate: 0.18,
    weapon, bulletDamage: 1.0, skin,
    fireTimer: 0,
    score: 0, coins: 4,
    combo: 0, comboTimer: 0, comboMax: 0,
    specialCooldown: 0,
    trail: [],
  };
}

function makeEnemy(type: Enemy['type'], W: number, H: number, waveNum: number): Enemy {
  const [x, y] = randomEdge(W, H);
  const diff = 1 + (waveNum - 1) * 0.12;
  const base: Partial<Enemy> = { id: uid(), type, x, y, vx: 0, vy: 0, angle: 0, behaviorTimer: Math.random() * 10, behaviorPhase: 0, fireTimer: Math.random() * 2 };
  switch (type) {
    case 'scout': return { ...base, hp: Math.ceil(2 * diff), maxHp: Math.ceil(2 * diff), coinValue: 1, scoreValue: 100, radius: 13, speed: 105 * Math.min(diff, 2) } as Enemy;
    case 'tank':  return { ...base, hp: Math.ceil(8 * diff), maxHp: Math.ceil(8 * diff), coinValue: 3, scoreValue: 350, radius: 22, speed: 52 } as Enemy;
    case 'swarm': return { ...base, hp: 1, maxHp: 1, coinValue: 1, scoreValue: 60, radius: 8, speed: 155 * Math.min(diff, 1.8) } as Enemy;
    case 'elite': return { ...base, hp: Math.ceil(5 * diff), maxHp: Math.ceil(5 * diff), coinValue: 2, scoreValue: 250, radius: 16, speed: 85 * Math.min(diff, 1.6) } as Enemy;
  }
}

function makeBoss(W: number, H: number, bossNum: number): Boss {
  const phases = bossNum <= 1 ? 1 : bossNum <= 2 ? 2 : 3;
  const maxHp = 150 + bossNum * 80;
  return {
    x: W / 2, y: -80,
    vx: 0, vy: 0,
    angle: Math.PI / 2,
    hp: maxHp, maxHp,
    phase: 1,
    attackTimer: 3.5,
    attackPattern: 0,
    moveTimer: 0, moveTargetX: W / 2, moveTargetY: H * 0.22,
    shieldActive: false, shieldTimer: 0,
    entranceTimer: 2.0, deathTimer: 0,
    radius: 65,
    bossNum,
  };
}

function getWaveConfig(wave: number, mode: GameMode): WaveConfig {
  if (mode === 'boss-rush') return { scouts: 0, tanks: 0, swarms: 0, elites: 0, isBoss: true };
  const isBoss = wave % 3 === 0;
  if (isBoss) return { scouts: 0, tanks: 0, swarms: 0, elites: 0, isBoss: true };
  const d = wave;
  return {
    scouts: Math.min(3 + d * 2, 18),
    tanks: Math.max(0, Math.min(d - 1, 7)),
    swarms: Math.max(0, Math.min((d - 2) * 3, 14)),
    elites: Math.max(0, Math.min(d - 3, 5)),
    isBoss: false,
  };
}

function buildUpgradeOptions(p: Player, wave: number): UpgradeOption[] {
  const all: UpgradeOption[] = [
    { type: 'speed', label: 'Afterburner', desc: '+20% movement speed', cost: 2, color: '#00e5ff', icon: '⚡', available: true },
    { type: 'firerate', label: 'Rapid Core', desc: '+20% fire rate', cost: 2, color: '#00ff88', icon: '🔫', available: true },
    { type: 'shield', label: 'Shield Module', desc: '+1 shield charge (absorbs 1 hit)', cost: 2, color: '#4488ff', icon: '🛡️', available: p.maxShield < 3 || p.shield < p.maxShield },
    { type: 'maxhp', label: 'Hull Plating', desc: '+1 max HP', cost: 3, color: '#ff6644', icon: '❤️', available: p.maxHp < 6 },
    { type: 'double', label: 'Twin Cannons', desc: 'Unlock double laser', cost: 3, color: '#00ff88', icon: '✦', available: p.weapon === 'laser' },
    { type: 'plasma', label: 'Plasma Core', desc: 'Unlock plasma cannon', cost: 4, color: '#aa44ff', icon: '🌀', available: p.weapon !== 'plasma' && p.weapon !== 'homing' },
    { type: 'homing', label: 'Homing Array', desc: 'Unlock homing missiles', cost: 4, color: '#ffaa00', icon: '🎯', available: p.weapon !== 'homing' },
    { type: 'damage', label: 'Overcharge', desc: '+25% bullet damage', cost: 3, color: '#ff4466', icon: '💥', available: p.bulletDamage < 2.5 },
  ];
  // pick 3 random available ones, shuffle available ones
  const avail = all.filter(u => u.available);
  for (let i = avail.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [avail[i], avail[j]] = [avail[j], avail[i]];
  }
  return avail.slice(0, 3);
}

/* ── Store ──────────────────────────────────────────────────────── */
interface GameStore {
  screen: GameScreen;
  mode: GameMode;
  wave: number;
  wavePhase: 'spawning' | 'fighting' | 'cleared' | 'boss';
  spawnQueue: Enemy['type'][];
  spawnTimer: number;
  bossNum: number;

  W: number; H: number;
  scrollY: number;

  player: Player;
  enemies: Enemy[];
  boss: Boss | null;
  playerBullets: Bullet[];
  enemyBullets: Bullet[];
  particles: Particle[];
  coins: Coin[];

  shake: number;
  shakeX: number; shakeY: number;

  upgradeOptions: UpgradeOption[];
  highScore: number;

  setDimensions: (w: number, h: number) => void;
  startGame: (mode: GameMode, skin: number, weapon: WeaponType) => void;
  tick: (dt: number, input: InputState) => void;
  purchaseUpgrade: (type: UpgradeType) => void;
  continueAfterUpgrade: () => void;
  restartGame: () => void;
  goToMenu: () => void;
}

export const useGameStore = create<GameStore>()((set, get) => ({
  screen: 'menu',
  mode: 'endless',
  wave: 0,
  wavePhase: 'fighting',
  spawnQueue: [],
  spawnTimer: 0,
  bossNum: 0,
  W: 800, H: 600,
  scrollY: 0,
  player: makePlayer(0, 'laser'),
  enemies: [],
  boss: null,
  playerBullets: [],
  enemyBullets: [],
  particles: [],
  coins: [],
  shake: 0, shakeX: 0, shakeY: 0,
  upgradeOptions: [],
  highScore: 0,

  setDimensions: (W, H) => set({ W, H }),

  startGame: (mode, skin, weapon) => {
    const { W, H } = get();
    const wave = 1;
    const cfg = getWaveConfig(wave, mode);
    const queue: Enemy['type'][] = [];
    for (let i = 0; i < cfg.scouts; i++) queue.push('scout');
    for (let i = 0; i < cfg.tanks; i++) queue.push('tank');
    for (let i = 0; i < cfg.swarms; i++) queue.push('swarm');
    for (let i = 0; i < cfg.elites; i++) queue.push('elite');
    // shuffle
    for (let i = queue.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [queue[i], queue[j]] = [queue[j], queue[i]];
    }

    const p = makePlayer(skin, weapon);
    p.x = W / 2; p.y = H / 2;

    let boss: Boss | null = null;
    let wavePhase: GameStore['wavePhase'] = 'spawning';
    if (cfg.isBoss) {
      boss = makeBoss(W, H, 1);
      wavePhase = 'boss';
    }

    set({
      screen: 'playing', mode, wave, wavePhase,
      spawnQueue: cfg.isBoss ? [] : queue,
      spawnTimer: 0, bossNum: cfg.isBoss ? 1 : 0,
      player: p, enemies: [], boss,
      playerBullets: [], enemyBullets: [], particles: [], coins: [],
      shake: 0, shakeX: 0, shakeY: 0, scrollY: 0,
    });
  },

  tick: (dt, input) => {
    const s = get();
    if (s.screen !== 'playing') return;

    const { W, H } = s;
    let p = { ...s.player };
    let enemies = [...s.enemies];
    let boss = s.boss ? { ...s.boss } : null;
    let playerBullets = [...s.playerBullets];
    let enemyBullets = [...s.enemyBullets];
    let particles = [...s.particles];
    let coins = [...s.coins];
    let shake = Math.max(0, s.shake - dt);
    let scrollY = s.scrollY + dt * 40;
    let spawnQueue = [...s.spawnQueue];
    let spawnTimer = s.spawnTimer;
    let wave = s.wave;
    let wavePhase = s.wavePhase;
    let bossNum = s.bossNum;

    /* ─ Player movement ─ */
    const spd = p.speed;
    let ax = 0; let ay = 0;
    const kk = input.keys;
    if (kk.has('ArrowLeft') || kk.has('a') || kk.has('A')) ax -= 1;
    if (kk.has('ArrowRight') || kk.has('d') || kk.has('D')) ax += 1;
    if (kk.has('ArrowUp') || kk.has('w') || kk.has('W')) ay -= 1;
    if (kk.has('ArrowDown') || kk.has('s') || kk.has('S')) ay += 1;
    if (ax !== 0 && ay !== 0) { ax *= 0.707; ay *= 0.707; }
    p.vx += (ax * spd - p.vx) * Math.min(1, dt * 8);
    p.vy += (ay * spd - p.vy) * Math.min(1, dt * 8);
    p.x = clamp(p.x + p.vx * dt, 18, W - 18);
    p.y = clamp(p.y + p.vy * dt, 18, H - 18);

    // Aim angle → mouse or movement direction
    const mx = input.mouseX; const my = input.mouseY;
    const hasMouse = mx > 0 || my > 0;
    if (hasMouse) {
      p.aimAngle = Math.atan2(my - p.y, mx - p.x);
    } else if (ax !== 0 || ay !== 0) {
      p.aimAngle = Math.atan2(ay, ax);
    }
    // Ship faces movement direction
    if (ax !== 0 || ay !== 0) {
      const targetAngle = Math.atan2(ay, ax);
      p.angle += angleDiff(p.angle, targetAngle) * Math.min(1, dt * 10);
    } else {
      p.angle += angleDiff(p.angle, p.aimAngle) * Math.min(1, dt * 5);
    }

    // Trail
    const speed2 = p.vx * p.vx + p.vy * p.vy;
    if (speed2 > 800) {
      p.trail = [{ x: p.x, y: p.y, alpha: 0.9 }, ...p.trail.slice(0, 22).map(t => ({ ...t, alpha: t.alpha * 0.82 }))].filter(t => t.alpha > 0.02);
    } else {
      p.trail = p.trail.slice(0, 22).map(t => ({ ...t, alpha: t.alpha * 0.88 })).filter(t => t.alpha > 0.02);
    }

    /* ─ Player shooting (auto-fire) ─ */
    p.fireTimer = Math.max(0, p.fireTimer - dt);
    p.specialCooldown = Math.max(0, p.specialCooldown - dt);
    p.invincibleTimer = Math.max(0, p.invincibleTimer - dt);

    if (p.fireTimer <= 0) {
      const bspd = 480;
      const ax2 = Math.cos(p.aimAngle); const ay2 = Math.sin(p.aimAngle);
      const dmg = p.bulletDamage;

      if (p.weapon === 'laser') {
        playerBullets.push({ id: uid(), owner: 'player', x: p.x, y: p.y, vx: ax2 * bspd, vy: ay2 * bspd, damage: dmg, life: 1.1, style: 'laser', size: 3.5 });
        audio.laser();
      } else if (p.weapon === 'double') {
        const perp = { x: -ay2 * 8, y: ax2 * 8 };
        playerBullets.push({ id: uid(), owner: 'player', x: p.x + perp.x, y: p.y + perp.y, vx: ax2 * bspd, vy: ay2 * bspd, damage: dmg * 0.7, life: 1.1, style: 'double', size: 3 });
        playerBullets.push({ id: uid(), owner: 'player', x: p.x - perp.x, y: p.y - perp.y, vx: ax2 * bspd, vy: ay2 * bspd, damage: dmg * 0.7, life: 1.1, style: 'double', size: 3 });
        audio.doubleLaser();
      } else if (p.weapon === 'plasma') {
        playerBullets.push({ id: uid(), owner: 'player', x: p.x, y: p.y, vx: ax2 * 280, vy: ay2 * 280, damage: dmg * 2.5, life: 1.8, style: 'plasma', size: 11 });
        audio.plasma();
      } else if (p.weapon === 'homing') {
        // find nearest enemy
        let nearestId: string | undefined;
        let nearestDist = Infinity;
        for (const e of enemies) {
          const d = Math.hypot(e.x - p.x, e.y - p.y);
          if (d < nearestDist) { nearestDist = d; nearestId = e.id; }
        }
        if (boss && Math.hypot(boss.x - p.x, boss.y - p.y) < nearestDist) nearestId = 'boss';
        playerBullets.push({ id: uid(), owner: 'player', x: p.x, y: p.y, vx: ax2 * 320, vy: ay2 * 320, damage: dmg * 1.5, life: 2.2, style: 'missile', size: 5, homingTargetId: nearestId });
        audio.missile();
      }

      const rateMulti = p.weapon === 'plasma' ? 2.8 : p.weapon === 'homing' ? 1.4 : 1.0;
      p.fireTimer = p.fireRate * rateMulti;
    }

    /* ─ Shield recharge ─ */
    if (p.shield < p.maxShield) {
      p.shieldTimer += dt;
      if (p.shieldTimer > 6) { p.shield++; p.shieldTimer = 0; }
    } else { p.shieldTimer = 0; }

    /* ─ Player bullets update ─ */
    playerBullets = playerBullets
      .map(b => {
        let nx = b.x + b.vx * dt;
        let ny = b.y + b.vy * dt;
        let nvx = b.vx; let nvy = b.vy;
        // Homing logic
        if (b.style === 'missile' && b.homingTargetId) {
          let tx: number | undefined; let ty: number | undefined;
          if (b.homingTargetId === 'boss' && boss) { tx = boss.x; ty = boss.y; }
          else {
            const target = enemies.find(e => e.id === b.homingTargetId);
            if (target) { tx = target.x; ty = target.y; }
            else {
              // retarget nearest
              let nd = Infinity;
              for (const e of enemies) { const d = Math.hypot(e.x - b.x, e.y - b.y); if (d < nd) { nd = d; tx = e.x; ty = e.y; } }
              if (boss) { const d = Math.hypot(boss.x - b.x, boss.y - b.y); if (d < nd) { tx = boss.x; ty = boss.y; } }
            }
          }
          if (tx !== undefined && ty !== undefined) {
            const ta = Math.atan2(ty - b.y, tx - b.x);
            const ca = Math.atan2(b.vy, b.vx);
            const turn = clamp(angleDiff(ca, ta), -dt * 4, dt * 4);
            const spd3 = Math.hypot(b.vx, b.vy);
            const na = ca + turn;
            nvx = Math.cos(na) * spd3; nvy = Math.sin(na) * spd3;
          }
        }
        return { ...b, x: nx, y: ny, vx: nvx, vy: nvy, life: b.life - dt };
      })
      .filter(b => b.life > 0 && b.x > -30 && b.x < W + 30 && b.y > -30 && b.y < H + 30);

    /* ─ Enemies update ─ */
    const newEnemyBullets: Bullet[] = [];
    enemies = enemies.map(e => {
      let { x, y, vx, vy, angle, fireTimer, behaviorTimer, behaviorPhase, speed } = e;
      const dx = p.x - x; const dy = p.y - y;
      const dist = Math.hypot(dx, dy) || 1;
      const toPlayer = { x: dx / dist, y: dy / dist };
      behaviorTimer += dt;

      if (e.type === 'scout') {
        const zigzag = Math.sin(behaviorTimer * 2.8) * 85;
        const perp = { x: -toPlayer.y, y: toPlayer.x };
        vx += (toPlayer.x * speed + perp.x * zigzag - vx) * Math.min(1, dt * 3.5);
        vy += (toPlayer.y * speed + perp.y * zigzag - vy) * Math.min(1, dt * 3.5);
        angle = Math.atan2(vy, vx);
        fireTimer -= dt;
        if (fireTimer <= 0) {
          const a = Math.atan2(p.y - y, p.x - x) + (Math.random() - 0.5) * 0.3;
          newEnemyBullets.push({ id: uid(), owner: 'enemy', x, y, vx: Math.cos(a) * 210, vy: Math.sin(a) * 210, damage: 1, life: 1.8, style: 'e_basic', size: 4 });
          fireTimer = 2.2 + Math.random() * 0.8;
        }
      } else if (e.type === 'tank') {
        vx += (toPlayer.x * speed - vx) * Math.min(1, dt * 2.0);
        vy += (toPlayer.y * speed - vy) * Math.min(1, dt * 2.0);
        angle = Math.atan2(vy, vx);
        fireTimer -= dt;
        if (fireTimer <= 0) {
          const baseA = Math.atan2(p.y - y, p.x - x);
          for (const da of [-0.38, 0, 0.38]) {
            const a = baseA + da;
            newEnemyBullets.push({ id: uid(), owner: 'enemy', x, y, vx: Math.cos(a) * 190, vy: Math.sin(a) * 190, damage: 1, life: 2.0, style: 'e_spread', size: 5 });
          }
          fireTimer = 3.0 + Math.random();
        }
      } else if (e.type === 'swarm') {
        // Circle target point near player
        if (behaviorTimer > 2.5) { behaviorTimer = 0; behaviorPhase = (behaviorPhase + 1) % 6; }
        const orbitAngle = behaviorPhase * (Math.PI / 3) + behaviorTimer;
        const orbitR = 80 + Math.random() * 40;
        const tx = p.x + Math.cos(orbitAngle) * orbitR;
        const ty = p.y + Math.sin(orbitAngle) * orbitR;
        const ex = tx - x; const ey = ty - y;
        vx += (ex * 0.04 * speed - vx) * Math.min(1, dt * 5);
        vy += (ey * 0.04 * speed - vy) * Math.min(1, dt * 5);
        angle = Math.atan2(vy, vx);
      } else if (e.type === 'elite') {
        // Strafe perpendicular, approach slowly
        const perp2 = { x: -toPlayer.y * (behaviorPhase === 0 ? 1 : -1), y: toPlayer.x * (behaviorPhase === 0 ? 1 : -1) };
        const approachFactor = dist > 200 ? 0.6 : 0.1;
        vx += (toPlayer.x * speed * approachFactor + perp2.x * speed * 0.7 - vx) * Math.min(1, dt * 2.5);
        vy += (toPlayer.y * speed * approachFactor + perp2.y * speed * 0.7 - vy) * Math.min(1, dt * 2.5);
        if (behaviorTimer > 2.8) { behaviorTimer = 0; behaviorPhase = behaviorPhase === 0 ? 1 : 0; }
        angle = Math.atan2(vy, vx);
        fireTimer -= dt;
        if (fireTimer <= 0) {
          // Homing-ish: aim slightly past player
          const a = Math.atan2(p.y - y, p.x - x);
          newEnemyBullets.push({ id: uid(), owner: 'enemy', x, y, vx: Math.cos(a) * 230, vy: Math.sin(a) * 230, damage: 1, life: 1.7, style: 'e_homing', size: 4.5 });
          fireTimer = 1.8 + Math.random() * 0.5;
        }
      }

      // Keep in arena
      x = clamp(x + vx * dt, -60, W + 60);
      y = clamp(y + vy * dt, -60, H + 60);

      return { ...e, x, y, vx, vy, angle, fireTimer, behaviorTimer, behaviorPhase };
    });

    /* ─ Boss update ─ */
    if (boss && boss.entranceTimer > 0) {
      boss.entranceTimer -= dt;
      boss.y = Math.min(H * 0.22, boss.y + (H * 0.22 - (-80)) / 2 * dt);
    } else if (boss && boss.deathTimer <= 0) {
      // Phase check
      const hpPct = boss.hp / boss.maxHp;
      const newPhase: Boss['phase'] = hpPct > 0.6 ? 1 : hpPct > 0.3 ? 2 : 3;
      if (newPhase !== boss.phase) {
        const oldPhase = boss.phase;
        boss.phase = newPhase;
        particles.push(...makeExplosion(boss.x, boss.y, '#cc44ff', 20, true));
        audio.bossPhase();
        shake = Math.max(shake, 0.4);
        if (newPhase === 3) boss.shieldActive = false;
      }

      // Boss movement
      boss.moveTimer -= dt;
      if (boss.moveTimer <= 0) {
        boss.moveTargetX = W * 0.15 + Math.random() * W * 0.7;
        boss.moveTargetY = H * 0.08 + Math.random() * H * 0.35;
        const moveTime = boss.phase === 3 ? 1.2 : boss.phase === 2 ? 1.8 : 2.5;
        boss.moveTimer = moveTime;
        if (boss.phase === 3 && Math.random() < 0.35) {
          // Charge at player in phase 3
          boss.moveTargetX = p.x;
          boss.moveTargetY = p.y;
          boss.moveTimer = 0.7;
        }
      }
      const bdx = boss.moveTargetX - boss.x; const bdy = boss.moveTargetY - boss.y;
      const bspd2 = boss.phase === 3 ? 240 : boss.phase === 2 ? 160 : 100;
      boss.vx += (bdx * 0.05 * bspd2 - boss.vx) * Math.min(1, dt * 2.5);
      boss.vy += (bdy * 0.05 * bspd2 - boss.vy) * Math.min(1, dt * 2.5);
      boss.x = clamp(boss.x + boss.vx * dt, 80, W - 80);
      boss.y = clamp(boss.y + boss.vy * dt, 70, H * 0.45);
      boss.angle += dt * (boss.phase >= 2 ? 0.6 : 0.3);

      // Shield behavior
      boss.shieldTimer = Math.max(0, boss.shieldTimer - dt);
      if (boss.phase < 3 && !boss.shieldActive && boss.shieldTimer <= 0 && Math.random() < dt * 0.04) {
        boss.shieldActive = true;
        boss.shieldTimer = 4.0;
      }
      if (boss.shieldActive && boss.shieldTimer <= 0) {
        boss.shieldActive = false;
        boss.shieldTimer = 8.0;
      }

      // Boss attacks
      boss.attackTimer -= dt;
      if (boss.attackTimer <= 0) {
        const attackDelay = boss.phase === 3 ? 0.9 : boss.phase === 2 ? 1.3 : 1.8;
        boss.attackTimer = attackDelay;
        const pattern = boss.attackPattern;

        if (pattern === 0 || boss.phase === 3) {
          // Ring shot
          const count = boss.phase === 3 ? 16 : boss.phase === 2 ? 12 : 8;
          for (let i = 0; i < count; i++) {
            const a = (i / count) * Math.PI * 2;
            newEnemyBullets.push({ id: uid(), owner: 'boss', x: boss.x, y: boss.y, vx: Math.cos(a) * 200, vy: Math.sin(a) * 200, damage: 1, life: 2.5, style: 'b_beam', size: 7 });
          }
        }
        if (pattern === 1 || boss.phase >= 2) {
          // Spread toward player
          const baseA = Math.atan2(p.y - boss.y, p.x - boss.x);
          const count2 = boss.phase === 3 ? 9 : boss.phase === 2 ? 7 : 5;
          const spread = 0.28;
          for (let i = 0; i < count2; i++) {
            const a = baseA + (i - Math.floor(count2 / 2)) * spread;
            newEnemyBullets.push({ id: uid(), owner: 'boss', x: boss.x, y: boss.y, vx: Math.cos(a) * 260, vy: Math.sin(a) * 260, damage: 1, life: 2.0, style: 'b_orb', size: 10 });
          }
        }
        if (boss.phase >= 2 && pattern === 2) {
          // Rotating beams
          for (let i = 0; i < 3; i++) {
            const a = boss.angle + (i / 3) * Math.PI * 2;
            newEnemyBullets.push({ id: uid(), owner: 'boss', x: boss.x, y: boss.y, vx: Math.cos(a) * 300, vy: Math.sin(a) * 300, damage: 1, life: 1.8, style: 'b_beam', size: 8 });
          }
        }

        boss.attackPattern = (boss.attackPattern + 1) % (boss.phase >= 2 ? 3 : 2);
      }
    }

    /* ─ Enemy bullets update ─ */
    enemyBullets = [...enemyBullets, ...newEnemyBullets]
      .map(b => ({ ...b, x: b.x + b.vx * dt, y: b.y + b.vy * dt, life: b.life - dt }))
      .filter(b => b.life > 0 && b.x > -40 && b.x < W + 40 && b.y > -40 && b.y < H + 40);

    /* ─ Particles update ─ */
    particles = particles
      .map(pp => {
        const fric = pp.style === 'spark' ? 0.88 : 0.96;
        return { ...pp, x: pp.x + pp.vx * dt, y: pp.y + pp.vy * dt, vx: pp.vx * fric, vy: pp.vy * fric, life: pp.life - dt };
      })
      .filter(pp => pp.life > 0);

    /* ─ Coins update ─ */
    coins = coins.map(c => {
      let { x, y, vx, vy } = c;
      const cdx = p.x - x; const cdy = p.y - y;
      const cdist = Math.hypot(cdx, cdy) || 1;
      if (cdist < COIN_ATTRACT_RADIUS) {
        const pull = (COIN_ATTRACT_RADIUS - cdist) / COIN_ATTRACT_RADIUS * 400;
        vx += (cdx / cdist) * pull * dt;
        vy += (cdy / cdist) * pull * dt;
      }
      vx *= 0.96; vy *= 0.96;
      x += vx * dt; y += vy * dt;
      return { ...c, x, y, vx, vy, life: c.life - dt };
    }).filter(c => c.life > 0);

    /* ─ Collision: player bullets vs enemies ─ */
    const hitsEnemies = new Set<string>();
    const hitsBoss = new Set<string>();
    playerBullets = playerBullets.filter(b => {
      for (const e of enemies) {
        if (hitsEnemies.has(b.id)) break;
        if (Math.hypot(b.x - e.x, b.y - e.y) < e.radius) {
          hitsEnemies.add(b.id);
          // damage enemy
          const idx = enemies.findIndex(x => x.id === e.id);
          if (idx >= 0) {
            enemies[idx] = { ...enemies[idx], hp: enemies[idx].hp - b.damage };
            if (enemies[idx].hp <= 0) {
              // enemy killed
              const color = e.type === 'scout' ? '#44ff44' : e.type === 'tank' ? '#ff3322' : e.type === 'swarm' ? '#00ccff' : '#cc44ff';
              particles.push(...makeExplosion(e.x, e.y, color, e.type === 'tank' ? 20 : 10, e.type === 'tank'));
              audio.explosion(e.type === 'tank' ? 1.5 : 0.7);
              shake = Math.max(shake, e.type === 'tank' ? 0.25 : 0.12);
              // Drop coins
              for (let i = 0; i < e.coinValue; i++) {
                const ca = Math.random() * Math.PI * 2;
                coins.push({ id: uid(), x: e.x, y: e.y, vx: Math.cos(ca) * 60, vy: Math.sin(ca) * 60, value: 1, life: 8 });
              }
              // Combo
              p.combo++;
              p.comboTimer = COMBO_EXPIRE;
              p.comboMax = Math.max(p.comboMax, p.combo);
              if (p.combo > 0 && p.combo % 5 === 0) audio.comboUp();
              const multi = p.combo >= 20 ? 5 : p.combo >= 10 ? 3 : p.combo >= 5 ? 2 : 1;
              p.score += e.scoreValue * multi;
              enemies[idx] = { ...enemies[idx], hp: -9999 }; // mark dead
            }
          }
          return b.style !== 'plasma'; // plasma pierces
        }
      }
      // vs boss
      if (boss && boss.deathTimer <= 0 && boss.entranceTimer <= 0 && !hitsBoss.has(b.id)) {
        if (!boss.shieldActive && Math.hypot(b.x - boss.x, b.y - boss.y) < boss.radius) {
          hitsBoss.add(b.id);
          boss.hp = Math.max(0, boss.hp - b.damage);
          audio.bossHit();
          shake = Math.max(shake, 0.18);
          particles.push(...makeExplosion(b.x, b.y, '#cc44ff', 5));
          if (boss.hp <= 0 && boss.deathTimer <= 0) {
            boss.deathTimer = 2.5;
            particles.push(...makeExplosion(boss.x, boss.y, '#ff44ff', 40, true));
            particles.push(...makeExplosion(boss.x, boss.y, '#ffaa00', 30, true));
            audio.bossExplosion();
            shake = Math.max(shake, 0.8);
            // Boss loot
            for (let i = 0; i < 12; i++) {
              const ca = Math.random() * Math.PI * 2;
              coins.push({ id: uid(), x: boss.x, y: boss.y, vx: Math.cos(ca) * 120, vy: Math.sin(ca) * 120, value: 1, life: 12 });
            }
            p.score += 5000 * boss.bossNum;
          }
          return false;
        }
      }
      return true;
    });
    enemies = enemies.filter(e => e.hp > 0);

    /* ─ Collision: enemy bullets vs player ─ */
    if (p.invincibleTimer <= 0 && Date.now() > p.protectionEnd) {
      enemyBullets = enemyBullets.filter(b => {
        if (Math.hypot(b.x - p.x, b.y - p.y) < PLAYER_RADIUS + b.size) {
          if (p.shield > 0) {
            p.shield = Math.max(0, p.shield - 1);
            audio.shieldHit();
            particles.push(...makeExplosion(b.x, b.y, '#4488ff', 6));
            shake = Math.max(shake, 0.15);
          } else {
            p.hp--;
            audio.playerHit();
            shake = Math.max(shake, 0.35);
            p.invincibleTimer = 2.2;
            p.combo = 0; p.comboTimer = 0;
            particles.push(...makeExplosion(p.x, p.y, '#00e5ff', 12));
            if (p.hp <= 0) {
              // Game Over
              particles.push(...makeExplosion(p.x, p.y, '#ffaa00', 25, true));
              audio.explosion(2);
              set({
                player: p, enemies, boss, playerBullets, enemyBullets, particles, coins, shake,
                screen: 'gameover', highScore: Math.max(s.highScore, p.score),
              });
              return false;
            }
          }
          return false;
        }
        return true;
      });
    }

    /* ─ Collision: player vs enemies (ramming) ─ */
    if (p.invincibleTimer <= 0 && Date.now() > p.protectionEnd) {
      for (const e of enemies) {
        if (Math.hypot(e.x - p.x, e.y - p.y) < e.radius + PLAYER_RADIUS - 4) {
          if (p.shield > 0) {
            p.shield--;
            audio.shieldHit();
          } else {
            p.hp--;
            audio.playerHit();
            shake = Math.max(shake, 0.3);
            if (p.hp <= 0) {
              set({ player: p, enemies, boss, playerBullets, enemyBullets, particles, coins, shake, screen: 'gameover', highScore: Math.max(s.highScore, p.score) });
              return;
            }
          }
          p.invincibleTimer = 2.0;
          p.combo = 0; p.comboTimer = 0;
          break;
        }
      }
    }

    /* ─ Coin pickup ─ */
    coins = coins.filter(c => {
      if (Math.hypot(c.x - p.x, c.y - p.y) < 18) {
        p.coins += c.value;
        p.score += 10;
        audio.coin();
        return false;
      }
      return true;
    });

    /* ─ Combo timer ─ */
    if (p.comboTimer > 0) {
      p.comboTimer -= dt;
      if (p.comboTimer <= 0) p.combo = 0;
    }

    /* ─ Camera shake offset ─ */
    const shakeX = shake > 0 ? (Math.random() - 0.5) * shake * 18 : 0;
    const shakeY = shake > 0 ? (Math.random() - 0.5) * shake * 18 : 0;

    /* ─ Wave / spawn logic ─ */
    let spawnQueueNew = spawnQueue;
    if (wavePhase === 'spawning') {
      spawnTimer -= dt;
      if (spawnTimer <= 0 && spawnQueueNew.length > 0) {
        const type = spawnQueueNew[0];
        enemies.push(makeEnemy(type, W, H, wave));
        spawnQueueNew = spawnQueueNew.slice(1);
        spawnTimer = 0.65;
      }
      if (spawnQueueNew.length === 0) wavePhase = 'fighting';
    }

    if (wavePhase === 'fighting' && enemies.length === 0) {
      wavePhase = 'cleared';
    }

    // Boss death sequence
    if (boss && boss.deathTimer > 0) {
      boss.deathTimer -= dt;
      if (boss.deathTimer % 0.35 < dt) {
        const bx = boss.x + (Math.random() - 0.5) * 80;
        const by = boss.y + (Math.random() - 0.5) * 60;
        particles.push(...makeExplosion(bx, by, '#ff6600', 8, false));
      }
      if (boss.deathTimer <= 0) {
        // Boss fully dead → upgrade screen
        const options = buildUpgradeOptions(p, wave);
        audio.waveComplete();
        set({
          player: p, enemies: [], boss: null, playerBullets: [], enemyBullets, particles, coins, shake, shakeX, shakeY,
          scrollY, spawnQueue: [], spawnTimer: 0, wave, wavePhase: 'cleared', bossNum,
          screen: 'upgrade', upgradeOptions: options,
        });
        return;
      }
    }

    if (wavePhase === 'cleared' && (!boss || boss.deathTimer <= 0)) {
      const options = buildUpgradeOptions(p, wave);
      audio.waveComplete();
      set({
        player: p, enemies: [], boss: null, playerBullets, enemyBullets: [], particles, coins, shake, shakeX, shakeY,
        scrollY, spawnQueue: [], spawnTimer: 0, wave, wavePhase,
        screen: 'upgrade', upgradeOptions: options,
      });
      return;
    }

    // Boss entrance done, wave active
    if (boss && boss.entranceTimer > 0 && wavePhase === 'boss') {
      // Still entering
    }

    set({
      player: p, enemies, boss, playerBullets, enemyBullets, particles, coins,
      shake, shakeX, shakeY, scrollY,
      spawnQueue: spawnQueueNew, spawnTimer, wave, wavePhase, bossNum,
    });
  },

  purchaseUpgrade: (type) => {
    const { player: p } = get();
    if (type === 'speed') { set({ player: { ...p, speed: Math.min(p.speed + 44, 400), coins: p.coins - 2 } }); }
    else if (type === 'firerate') { set({ player: { ...p, fireRate: Math.max(p.fireRate * 0.82, 0.06), coins: p.coins - 2 } }); }
    else if (type === 'shield') { set({ player: { ...p, maxShield: Math.min(p.maxShield + 1, 3), shield: Math.min(p.shield + 1, Math.min(p.maxShield + 1, 3)), coins: p.coins - 2 } }); }
    else if (type === 'maxhp') { set({ player: { ...p, maxHp: p.maxHp + 1, hp: p.hp + 1, coins: p.coins - 3 } }); }
    else if (type === 'double') { set({ player: { ...p, weapon: 'double', coins: p.coins - 3 } }); }
    else if (type === 'plasma') { set({ player: { ...p, weapon: 'plasma', coins: p.coins - 4 } }); }
    else if (type === 'homing') { set({ player: { ...p, weapon: 'homing', coins: p.coins - 4 } }); }
    else if (type === 'damage') { set({ player: { ...p, bulletDamage: Math.min(p.bulletDamage + 0.25, 2.5), coins: p.coins - 3 } }); }
  },

  continueAfterUpgrade: () => {
    const { wave, mode, W, H, player } = get();
    const nextWave = wave + 1;
    const cfg = getWaveConfig(nextWave, mode);
    const queue: Enemy['type'][] = [];
    for (let i = 0; i < cfg.scouts; i++) queue.push('scout');
    for (let i = 0; i < cfg.tanks; i++) queue.push('tank');
    for (let i = 0; i < cfg.swarms; i++) queue.push('swarm');
    for (let i = 0; i < cfg.elites; i++) queue.push('elite');
    for (let i = queue.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [queue[i], queue[j]] = [queue[j], queue[i]];
    }

    const newBossNum = cfg.isBoss ? get().bossNum + 1 : get().bossNum;
    const boss = cfg.isBoss ? makeBoss(W, H, newBossNum) : null;

    const newPlayer = { ...player, protectionEnd: Date.now() + 2000, invincibleTimer: 0 };

    set({
      screen: 'playing', wave: nextWave,
      wavePhase: cfg.isBoss ? 'boss' : 'spawning',
      spawnQueue: cfg.isBoss ? [] : queue,
      spawnTimer: 0, bossNum: newBossNum,
      player: newPlayer, enemies: [], boss,
      playerBullets: [], enemyBullets: [],
    });
  },

  restartGame: () => {
    const { mode, player } = get();
    get().startGame(mode, player.skin, player.weapon);
  },
  goToMenu: () => set({ screen: 'menu' }),
}));

__COSMIC_FURY_EOF__
echo "  ✓  $ROOT/src/game/store.ts"

mkdir -p "$(dirname "$ROOT/src/pages/Game.tsx")"
cat > "$ROOT/src/pages/Game.tsx" << '__COSMIC_FURY_EOF__'
import { useEffect, useRef, useCallback } from 'react';
import { useGameStore } from '../game/store';
import {
  buildStars, buildNebulae, drawBackground, drawTrail, drawPlayer,
  drawEnemy, drawBoss, drawBullet, drawParticle, drawCoin,
  drawCursorRocket, getTrailColor, StarLayer, Nebula,
} from '../game/draw';
import { audio } from '../game/audio';
import type { InputState } from '../game/types';
import MainMenu from '../components/game/MainMenu';
import HUD from '../components/game/HUD';
import UpgradeShop from '../components/game/UpgradeShop';
import GameOver from '../components/game/GameOver';

export default function Game() {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const rafRef = useRef<number>(0);
  const lastTimeRef = useRef<number>(0);
  const timeRef = useRef<number>(0);
  const inputRef = useRef<InputState>({ keys: new Set(), mouseX: 0, mouseY: 0, mouseDown: false });
  const starsRef = useRef<StarLayer[]>([]);
  const nebulaeRef = useRef<Nebula[]>([]);
  const mouseVisible = useRef(true);
  const mouseMoveRef = useRef<{ x: number; y: number; angle: number }>({ x: -100, y: -100, angle: 0 });
  const prevMouseRef = useRef({ x: 0, y: 0 });

  const { screen, player, enemies, boss, playerBullets, enemyBullets, particles, coins, shake, shakeX, shakeY, scrollY, setDimensions, tick } = useGameStore();

  /* ── Resize ─────────────────────────────────────────────────── */
  useEffect(() => {
    const canvas = canvasRef.current!;
    const resize = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
      starsRef.current = buildStars(canvas.width, canvas.height);
      nebulaeRef.current = buildNebulae(canvas.width, canvas.height);
      setDimensions(canvas.width, canvas.height);
    };
    resize();
    window.addEventListener('resize', resize);
    return () => window.removeEventListener('resize', resize);
  }, [setDimensions]);

  /* ── Input ──────────────────────────────────────────────────── */
  useEffect(() => {
    const inp = inputRef.current;
    const onKey = (e: KeyboardEvent) => {
      if (e.type === 'keydown') inp.keys.add(e.key);
      else inp.keys.delete(e.key);
    };
    const onMouseMove = (e: MouseEvent) => {
      const rect = canvasRef.current?.getBoundingClientRect();
      if (!rect) return;
      const nx = e.clientX - rect.left;
      const ny = e.clientY - rect.top;
      const dx = nx - prevMouseRef.current.x;
      const dy = ny - prevMouseRef.current.y;
      if (Math.hypot(dx, dy) > 1) {
        mouseMoveRef.current.angle = Math.atan2(dy, dx);
        prevMouseRef.current = { x: nx, y: ny };
      }
      mouseMoveRef.current.x = nx;
      mouseMoveRef.current.y = ny;
      inp.mouseX = nx;
      inp.mouseY = ny;
      mouseVisible.current = true;
    };
    const onMouseDown = (e: MouseEvent) => {
      inp.mouseDown = true;
      audio.init();
    };
    const onMouseUp = () => { inp.mouseDown = false; };
    const onMouseLeave = () => { mouseVisible.current = false; };
    const onMouseEnter = () => { mouseVisible.current = true; };
    window.addEventListener('keydown', onKey);
    window.addEventListener('keyup', onKey);
    window.addEventListener('mousemove', onMouseMove);
    window.addEventListener('mousedown', onMouseDown);
    window.addEventListener('mouseup', onMouseUp);
    canvasRef.current?.addEventListener('mouseleave', onMouseLeave);
    canvasRef.current?.addEventListener('mouseenter', onMouseEnter);
    return () => {
      window.removeEventListener('keydown', onKey);
      window.removeEventListener('keyup', onKey);
      window.removeEventListener('mousemove', onMouseMove);
      window.removeEventListener('mousedown', onMouseDown);
      window.removeEventListener('mouseup', onMouseUp);
    };
  }, []);

  /* ── Game Loop ──────────────────────────────────────────────── */
  const loop = useCallback((now: number) => {
    const dt = Math.min((now - lastTimeRef.current) / 1000, 0.05);
    lastTimeRef.current = now;
    timeRef.current += dt;
    const t = timeRef.current;

    const canvas = canvasRef.current;
    if (!canvas) { rafRef.current = requestAnimationFrame(loop); return; }
    const ctx = canvas.getContext('2d')!;
    const W = canvas.width; const H = canvas.height;

    const s = useGameStore.getState();

    // Tick game if playing
    if (s.screen === 'playing') {
      tick(dt, inputRef.current);
    }

    // Get fresh state
    const gs = useGameStore.getState();

    /* ─ Shake transform ─ */
    ctx.save();
    if (gs.shake > 0) ctx.translate(gs.shakeX, gs.shakeY);

    /* ─ Background ─ */
    drawBackground(ctx, starsRef.current, nebulaeRef.current, gs.scrollY, W, H, t);

    if (gs.screen === 'playing' || gs.screen === 'gameover') {
      /* ─ Coins ─ */
      for (const c of gs.coins) drawCoin(ctx, c, t);

      /* ─ Particles (under entities) ─ */
      for (const p of gs.particles) drawParticle(ctx, p);

      /* ─ Player bullets ─ */
      for (const b of gs.playerBullets) drawBullet(ctx, b, t);

      /* ─ Enemy bullets ─ */
      for (const b of gs.enemyBullets) drawBullet(ctx, b, t);

      /* ─ Enemies ─ */
      for (const e of gs.enemies) drawEnemy(ctx, e, t);

      /* ─ Boss ─ */
      if (gs.boss) drawBoss(ctx, gs.boss, t);

      /* ─ Player trail ─ */
      const trailColor = getTrailColor(gs.player.skin);
      drawTrail(ctx, gs.player.trail, trailColor);

      /* ─ Player ─ */
      if (gs.screen === 'playing') {
        drawPlayer(ctx, gs.player, t, gs.player.invincibleTimer > 0);
      }

      /* ─ Protection shield ring ─ */
      if (gs.screen === 'playing' && gs.player.protectionEnd > Date.now()) {
        const rem = gs.player.protectionEnd - Date.now();
        const secs = Math.ceil(rem / 1000);
        ctx.save();
        ctx.globalAlpha = 0.4 + 0.2 * Math.sin(t * 8);
        ctx.strokeStyle = '#00ffcc'; ctx.lineWidth = 2.5;
        ctx.shadowBlur = 20; ctx.shadowColor = '#00ffcc';
        ctx.setLineDash([8, 5]); ctx.lineDashOffset = -t * 40;
        ctx.beginPath(); ctx.arc(gs.player.x, gs.player.y, 36, 0, Math.PI * 2); ctx.stroke();
        ctx.setLineDash([]); ctx.restore();
        // Countdown
        ctx.save();
        ctx.font = 'bold 38px "Courier New"';
        ctx.textAlign = 'center'; ctx.shadowBlur = 24; ctx.shadowColor = '#00ffcc';
        ctx.fillStyle = '#00ffcc'; ctx.globalAlpha = 0.85;
        ctx.fillText(String(secs), W / 2, H / 2 - 80);
        ctx.font = '11px "Courier New"'; ctx.globalAlpha = 0.55;
        ctx.fillText('SHIELD ACTIVE', W / 2, H / 2 - 54);
        ctx.restore();
      }
    }

    ctx.restore(); // end shake

    /* ─ Cursor rocket ─ */
    if (mouseVisible.current) {
      const m = mouseMoveRef.current;
      drawCursorRocket(ctx, m.x, m.y, m.angle, t);
    }

    rafRef.current = requestAnimationFrame(loop);
  }, [tick]);

  useEffect(() => {
    lastTimeRef.current = performance.now();
    rafRef.current = requestAnimationFrame(loop);
    return () => cancelAnimationFrame(rafRef.current);
  }, [loop]);

  return (
    <div style={{ width: '100vw', height: '100vh', overflow: 'hidden', background: '#01020d', cursor: 'none', position: 'relative' }}>
      <canvas ref={canvasRef} style={{ display: 'block' }} />
      {screen === 'menu' && <MainMenu />}
      {screen === 'playing' && <HUD />}
      {screen === 'upgrade' && <UpgradeShop />}
      {screen === 'gameover' && <GameOver />}
    </div>
  );
}

__COSMIC_FURY_EOF__
echo "  ✓  $ROOT/src/pages/Game.tsx"

mkdir -p "$(dirname "$ROOT/src/components/game/MainMenu.tsx")"
cat > "$ROOT/src/components/game/MainMenu.tsx" << '__COSMIC_FURY_EOF__'
import { useState } from 'react';
import { useGameStore } from '../../game/store';
import { audio } from '../../game/audio';
import type { GameMode, WeaponType } from '../../game/types';

const SHIPS = [
  { name: 'FIGHTER', desc: 'Balanced speed & armor. Best for beginners.', color: '#00e5ff' },
  { name: 'DESTROYER', desc: 'Slower but heavily armored. Extra firepower.', color: '#ff6622' },
  { name: 'INTERCEPTOR', desc: 'Blazing speed, light armor. High skill ceiling.', color: '#44ff88' },
];
const WEAPONS: { type: WeaponType; label: string; desc: string; color: string }[] = [
  { type: 'laser', label: 'LASER', desc: 'Rapid single beam', color: '#00e5ff' },
  { type: 'double', label: 'TWIN', desc: 'Dual parallel beams', color: '#00ff88' },
  { type: 'plasma', label: 'PLASMA', desc: 'Slow, massive orb', color: '#aa44ff' },
  { type: 'homing', label: 'HOMING', desc: 'Smart missiles', color: '#ffaa00' },
];

export default function MainMenu() {
  const startGame = useGameStore(s => s.startGame);
  const [step, setStep] = useState<'mode' | 'ship' | 'weapon'>('mode');
  const [mode, setMode] = useState<GameMode>('endless');
  const [skin, setSkin] = useState(0);
  const [weapon, setWeapon] = useState<WeaponType>('laser');

  const begin = () => {
    audio.init();
    startGame(mode, skin, weapon);
  };

  return (
    <div style={{
      position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center', zIndex: 10,
      background: 'linear-gradient(180deg,rgba(1,2,18,0.85) 0%,rgba(4,6,32,0.92) 100%)',
      fontFamily: "'Courier New', monospace",
    }}>
      {/* Title */}
      <div style={{ textAlign: 'center', marginBottom: 32 }}>
        <div style={{ fontSize: 52, fontWeight: 900, letterSpacing: 10, color: '#00e5ff', textShadow: '0 0 30px #00e5ff, 0 0 60px #0066ff', lineHeight: 1 }}>
          COSMIC FURY
        </div>
        <div style={{ fontSize: 13, letterSpacing: 6, color: '#4488aa', marginTop: 8 }}>
          ── DEEP SPACE ANNIHILATION ──
        </div>
      </div>

      {/* Step: Mode */}
      {step === 'mode' && (
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16 }}>
          <div style={{ color: '#4488aa', fontSize: 12, letterSpacing: 4, marginBottom: 8 }}>SELECT MODE</div>
          {[
            { mode: 'endless' as GameMode, label: 'ENDLESS', desc: 'Survive infinite waves. Upgrades between waves.', color: '#00e5ff' },
            { mode: 'boss-rush' as GameMode, label: 'BOSS RUSH', desc: 'Nothing but boss fights. One after another.', color: '#ff4466' },
          ].map(m => (
            <button key={m.mode} onClick={() => { setMode(m.mode); setStep('ship'); }}
              style={{
                width: 340, padding: '18px 24px', background: 'transparent',
                border: `2px solid ${m.color}44`, color: m.color,
                fontSize: 18, letterSpacing: 4, cursor: 'pointer',
                boxShadow: `0 0 16px ${m.color}22`, transition: 'all 0.15s',
                textAlign: 'left',
              }}
              onMouseEnter={e => { (e.target as HTMLElement).style.background = m.color + '18'; (e.target as HTMLElement).style.borderColor = m.color; }}
              onMouseLeave={e => { (e.target as HTMLElement).style.background = 'transparent'; (e.target as HTMLElement).style.borderColor = m.color + '44'; }}
            >
              <div style={{ fontWeight: 900 }}>{m.label}</div>
              <div style={{ fontSize: 11, color: '#88aacc', marginTop: 4, letterSpacing: 1 }}>{m.desc}</div>
            </button>
          ))}
        </div>
      )}

      {/* Step: Ship */}
      {step === 'ship' && (
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
          <div style={{ color: '#4488aa', fontSize: 12, letterSpacing: 4, marginBottom: 4 }}>CHOOSE YOUR SHIP</div>
          <div style={{ display: 'flex', gap: 12 }}>
            {SHIPS.map((sh, i) => (
              <button key={i} onClick={() => setSkin(i)}
                style={{
                  width: 130, padding: '16px 10px',
                  background: skin === i ? sh.color + '22' : 'transparent',
                  border: `2px solid ${skin === i ? sh.color : sh.color + '44'}`,
                  color: sh.color, fontSize: 13, cursor: 'pointer', letterSpacing: 2,
                  boxShadow: skin === i ? `0 0 20px ${sh.color}44` : 'none', transition: 'all 0.15s',
                }}
              >
                <div style={{ fontSize: 32, marginBottom: 8 }}>🚀</div>
                <div style={{ fontWeight: 900, fontSize: 11 }}>{sh.name}</div>
                <div style={{ fontSize: 10, color: '#88aacc', marginTop: 6, letterSpacing: 0.5, lineHeight: 1.4 }}>{sh.desc}</div>
              </button>
            ))}
          </div>
          <div style={{ display: 'flex', gap: 12, marginTop: 8 }}>
            <button onClick={() => setStep('mode')} style={{ ...btnStyle('#4488aa') }}>← BACK</button>
            <button onClick={() => setStep('weapon')} style={{ ...btnStyle('#00e5ff') }}>NEXT →</button>
          </div>
        </div>
      )}

      {/* Step: Weapon */}
      {step === 'weapon' && (
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
          <div style={{ color: '#4488aa', fontSize: 12, letterSpacing: 4, marginBottom: 4 }}>STARTING WEAPON</div>
          <div style={{ display: 'flex', gap: 10 }}>
            {WEAPONS.map(w => (
              <button key={w.type} onClick={() => setWeapon(w.type)}
                style={{
                  width: 100, padding: '14px 8px',
                  background: weapon === w.type ? w.color + '22' : 'transparent',
                  border: `2px solid ${weapon === w.type ? w.color : w.color + '44'}`,
                  color: w.color, fontSize: 12, cursor: 'pointer', letterSpacing: 1,
                  boxShadow: weapon === w.type ? `0 0 16px ${w.color}44` : 'none', transition: 'all 0.15s',
                }}
              >
                <div style={{ fontWeight: 900, fontSize: 13 }}>{w.label}</div>
                <div style={{ fontSize: 10, color: '#88aacc', marginTop: 6, letterSpacing: 0.5 }}>{w.desc}</div>
              </button>
            ))}
          </div>
          <div style={{ display: 'flex', gap: 12, marginTop: 12 }}>
            <button onClick={() => setStep('ship')} style={{ ...btnStyle('#4488aa') }}>← BACK</button>
            <button onClick={begin} style={{ ...btnStyle('#00e5ff'), padding: '14px 40px', fontSize: 16, fontWeight: 900 }}>
              LAUNCH ▶
            </button>
          </div>
        </div>
      )}

      {/* Controls hint */}
      <div style={{ position: 'absolute', bottom: 24, color: '#2a4455', fontSize: 11, letterSpacing: 2 }}>
        WASD / ARROWS — MOVE &nbsp;│&nbsp; AIM WITH MOUSE &nbsp;│&nbsp; AUTO-FIRE
      </div>
    </div>
  );
}

const btnStyle = (color: string): React.CSSProperties => ({
  padding: '12px 24px', background: 'transparent',
  border: `2px solid ${color}66`, color, fontSize: 13,
  letterSpacing: 3, cursor: 'pointer', transition: 'all 0.15s',
  fontFamily: "'Courier New', monospace",
});

__COSMIC_FURY_EOF__
echo "  ✓  $ROOT/src/components/game/MainMenu.tsx"

mkdir -p "$(dirname "$ROOT/src/components/game/HUD.tsx")"
cat > "$ROOT/src/components/game/HUD.tsx" << '__COSMIC_FURY_EOF__'
import { useGameStore } from '../../game/store';

export default function HUD() {
  const { player: p, wave, wavePhase, boss, enemies, spawnQueue, mode } = useGameStore();
  const multi = p.combo >= 20 ? 5 : p.combo >= 10 ? 3 : p.combo >= 5 ? 2 : 1;
  const shipColor = ['#00e5ff', '#ff6622', '#44ff88'][p.skin] ?? '#00e5ff';
  const weaponLabel = { laser: 'LASER', double: 'TWIN', plasma: 'PLASMA', homing: 'HOMING' }[p.weapon];

  const enemiesLeft = enemies.length + spawnQueue.length;

  return (
    <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', fontFamily: "'Courier New', monospace" }}>
      {/* Boss HP bar */}
      {boss && boss.deathTimer <= 0 && boss.entranceTimer <= 0 && (
        <div style={{ position: 'absolute', top: 0, left: 0, right: 0, padding: '10px 20px', background: 'rgba(0,0,0,0.7)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <span style={{ color: boss.phase === 3 ? '#ff0044' : boss.phase === 2 ? '#ff6600' : '#cc44ff', fontSize: 11, letterSpacing: 3, minWidth: 100 }}>
              ⚠ BOSS {boss.bossNum} · P{boss.phase}
            </span>
            <div style={{ flex: 1, height: 12, background: '#1a0022', border: '1px solid #440055', borderRadius: 2, overflow: 'hidden', position: 'relative' }}>
              <div style={{
                width: `${(boss.hp / boss.maxHp) * 100}%`, height: '100%',
                background: boss.phase === 3 ? 'linear-gradient(90deg,#ff0044,#ff4477)' : boss.phase === 2 ? 'linear-gradient(90deg,#ff6600,#ffaa00)' : 'linear-gradient(90deg,#8800ff,#cc44ff)',
                boxShadow: `0 0 8px ${boss.phase === 3 ? '#ff0044' : boss.phase === 2 ? '#ff6600' : '#cc44ff'}`,
                transition: 'width 0.1s', borderRadius: 2,
              }} />
            </div>
            <span style={{ color: '#660077', fontSize: 10, minWidth: 60, textAlign: 'right' }}>
              {boss.hp} / {boss.maxHp}
            </span>
          </div>
        </div>
      )}

      {/* Boss entrance warning */}
      {boss && boss.entranceTimer > 0 && (
        <div style={{ position: 'absolute', top: '30%', left: '50%', transform: 'translate(-50%,-50%)', textAlign: 'center' }}>
          <div style={{ fontSize: 36, fontWeight: 900, color: '#ff0044', textShadow: '0 0 30px #ff0044', letterSpacing: 8, animation: 'pulse 0.5s infinite' }}>
            ⚠ BOSS INCOMING ⚠
          </div>
          <div style={{ fontSize: 13, color: '#ff4466', letterSpacing: 4, marginTop: 8 }}>BRACE FOR IMPACT</div>
        </div>
      )}

      {/* Top-left: Score & Wave */}
      <div style={{ position: 'absolute', top: 14, left: 16 }}>
        <div style={{ color: shipColor, fontSize: 22, fontWeight: 900, letterSpacing: 2, textShadow: `0 0 10px ${shipColor}` }}>
          {p.score.toLocaleString()}
        </div>
        <div style={{ color: '#2a5566', fontSize: 10, letterSpacing: 3 }}>SCORE</div>
        <div style={{ color: '#335577', fontSize: 11, letterSpacing: 2, marginTop: 4 }}>
          WAVE {wave} · {mode === 'boss-rush' ? 'BOSS RUSH' : 'ENDLESS'}
        </div>
        {wavePhase !== 'boss' && enemiesLeft > 0 && (
          <div style={{ color: '#223344', fontSize: 10, letterSpacing: 2 }}>⚡ {enemiesLeft} REMAINING</div>
        )}
      </div>

      {/* Top-right: HP + Shield + Coins + Weapon */}
      <div style={{ position: 'absolute', top: 14, right: 16, textAlign: 'right' }}>
        {/* HP */}
        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 4, marginBottom: 4 }}>
          {Array.from({ length: p.maxHp }).map((_, i) => (
            <span key={i} style={{ fontSize: 16, color: i < p.hp ? '#ff4444' : '#1a1a1a', textShadow: i < p.hp ? '0 0 8px #ff2222' : 'none' }}>♥</span>
          ))}
        </div>
        {/* Shield */}
        {p.maxShield > 0 && (
          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 4, marginBottom: 4 }}>
            {Array.from({ length: p.maxShield }).map((_, i) => (
              <span key={i} style={{ fontSize: 13, color: i < p.shield ? '#4488ff' : '#0a1422', textShadow: i < p.shield ? '0 0 6px #2266ff' : 'none' }}>◈</span>
            ))}
          </div>
        )}
        {/* Coins */}
        <div style={{ color: '#ffcc00', fontSize: 12, letterSpacing: 2, textShadow: '0 0 8px #ffaa00' }}>
          ◉ {p.coins} COINS
        </div>
        {/* Weapon */}
        <div style={{ color: '#334455', fontSize: 10, letterSpacing: 2, marginTop: 2 }}>
          ⚡ {weaponLabel}
        </div>
      </div>

      {/* Combo (center) */}
      {p.combo >= 3 && (
        <div style={{
          position: 'absolute', top: '50%', left: '50%',
          transform: 'translate(-50%, -50%)',
          textAlign: 'center', pointerEvents: 'none',
        }}>
          <div style={{
            fontSize: 13 + p.combo * 0.4, fontWeight: 900,
            color: multi >= 5 ? '#ff0044' : multi >= 3 ? '#ff6600' : multi >= 2 ? '#ffcc00' : '#00ff88',
            textShadow: `0 0 20px currentColor`,
            letterSpacing: 4, opacity: Math.min(1, p.comboTimer / 0.8),
            transition: 'color 0.2s',
          }}>
            {p.combo}× COMBO
          </div>
          {multi > 1 && (
            <div style={{ fontSize: 12, color: '#ffcc00', letterSpacing: 3, textShadow: '0 0 10px #ffaa00' }}>
              {multi}× SCORE MULTIPLIER
            </div>
          )}
        </div>
      )}

      {/* Wave clear flash */}
      {wavePhase === 'cleared' && (
        <div style={{ position: 'absolute', top: '40%', left: '50%', transform: 'translate(-50%,-50%)', textAlign: 'center' }}>
          <div style={{ fontSize: 32, color: '#00ff88', textShadow: '0 0 20px #00ff88', fontWeight: 900, letterSpacing: 6 }}>
            WAVE CLEAR
          </div>
        </div>
      )}

      <style>{`
        @keyframes pulse { 0%,100%{opacity:1} 50%{opacity:0.5} }
      `}</style>
    </div>
  );
}

__COSMIC_FURY_EOF__
echo "  ✓  $ROOT/src/components/game/HUD.tsx"

mkdir -p "$(dirname "$ROOT/src/components/game/UpgradeShop.tsx")"
cat > "$ROOT/src/components/game/UpgradeShop.tsx" << '__COSMIC_FURY_EOF__'
import { useGameStore } from '../../game/store';

export default function UpgradeShop() {
  const { upgradeOptions, player: p, purchaseUpgrade, continueAfterUpgrade, wave } = useGameStore();

  return (
    <div style={{
      position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center', zIndex: 10,
      background: 'rgba(1,3,20,0.92)',
      fontFamily: "'Courier New', monospace",
    }}>
      <div style={{ fontSize: 11, color: '#4488aa', letterSpacing: 5, marginBottom: 8 }}>WAVE {wave} COMPLETE</div>
      <div style={{ fontSize: 28, color: '#00e5ff', fontWeight: 900, letterSpacing: 6, textShadow: '0 0 20px #00e5ff', marginBottom: 4 }}>
        UPGRADE BAY
      </div>
      <div style={{ color: '#335566', fontSize: 11, letterSpacing: 2, marginBottom: 28 }}>
        ◉ {p.coins} COINS AVAILABLE
      </div>

      <div style={{ display: 'flex', gap: 16, marginBottom: 28 }}>
        {upgradeOptions.map((opt) => {
          const canAfford = p.coins >= opt.cost;
          return (
            <button key={opt.type} onClick={() => canAfford && purchaseUpgrade(opt.type)}
              style={{
                width: 170, padding: '22px 14px',
                background: canAfford ? opt.color + '12' : '#0a0a14',
                border: `2px solid ${canAfford ? opt.color + '88' : '#1a1a2a'}`,
                color: canAfford ? opt.color : '#334',
                fontSize: 13, cursor: canAfford ? 'pointer' : 'not-allowed',
                letterSpacing: 1, textAlign: 'center',
                boxShadow: canAfford ? `0 0 20px ${opt.color}22` : 'none',
                transition: 'all 0.15s',
              }}
              onMouseEnter={e => { if (canAfford) { (e.currentTarget as HTMLElement).style.background = opt.color + '28'; (e.currentTarget as HTMLElement).style.boxShadow = `0 0 30px ${opt.color}44`; } }}
              onMouseLeave={e => { (e.currentTarget as HTMLElement).style.background = canAfford ? opt.color + '12' : '#0a0a14'; (e.currentTarget as HTMLElement).style.boxShadow = canAfford ? `0 0 20px ${opt.color}22` : 'none'; }}
            >
              <div style={{ fontSize: 26, marginBottom: 8 }}>{opt.icon}</div>
              <div style={{ fontWeight: 900, fontSize: 12, letterSpacing: 2, marginBottom: 6 }}>{opt.label}</div>
              <div style={{ fontSize: 10, color: canAfford ? '#88aacc' : '#223', letterSpacing: 0.5, marginBottom: 12, lineHeight: 1.4 }}>{opt.desc}</div>
              <div style={{ fontSize: 12, fontWeight: 900 }}>◉ {opt.cost}</div>
              {!canAfford && <div style={{ fontSize: 9, color: '#334', marginTop: 4 }}>NOT ENOUGH COINS</div>}
            </button>
          );
        })}
      </div>

      {/* Current stats */}
      <div style={{ display: 'flex', gap: 20, marginBottom: 28, color: '#2a4455', fontSize: 10, letterSpacing: 2 }}>
        <span>SPD: {Math.round(p.speed)}</span>
        <span>RATE: {(1 / p.fireRate).toFixed(1)}/s</span>
        <span>DMG: ×{p.bulletDamage.toFixed(1)}</span>
        <span>HP: {p.hp}/{p.maxHp}</span>
        <span>SHIELD: {p.shield}/{p.maxShield}</span>
      </div>

      <button onClick={continueAfterUpgrade}
        style={{
          padding: '14px 40px', background: 'transparent',
          border: '2px solid #00e5ff66', color: '#00e5ff',
          fontSize: 15, fontWeight: 900, letterSpacing: 5, cursor: 'pointer',
          boxShadow: '0 0 20px #00e5ff22', transition: 'all 0.15s',
          fontFamily: "'Courier New', monospace",
        }}
        onMouseEnter={e => { (e.currentTarget as HTMLElement).style.background = '#00e5ff18'; (e.currentTarget as HTMLElement).style.boxShadow = '0 0 30px #00e5ff44'; }}
        onMouseLeave={e => { (e.currentTarget as HTMLElement).style.background = 'transparent'; (e.currentTarget as HTMLElement).style.boxShadow = '0 0 20px #00e5ff22'; }}
      >
        ▶ NEXT WAVE
      </button>
    </div>
  );
}

__COSMIC_FURY_EOF__
echo "  ✓  $ROOT/src/components/game/UpgradeShop.tsx"

mkdir -p "$(dirname "$ROOT/src/components/game/GameOver.tsx")"
cat > "$ROOT/src/components/game/GameOver.tsx" << '__COSMIC_FURY_EOF__'
import { useGameStore } from '../../game/store';

export default function GameOver() {
  const { player: p, wave, highScore, restartGame, goToMenu } = useGameStore();
  const shipColor = ['#00e5ff', '#ff6622', '#44ff88'][p.skin] ?? '#00e5ff';

  return (
    <div style={{
      position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center', zIndex: 10,
      background: 'rgba(1,2,10,0.95)',
      fontFamily: "'Courier New', monospace",
    }}>
      <div style={{ fontSize: 46, fontWeight: 900, color: '#ff2244', letterSpacing: 8, textShadow: '0 0 40px #ff0033', marginBottom: 8 }}>
        ANNIHILATED
      </div>
      <div style={{ fontSize: 12, color: '#440011', letterSpacing: 4, marginBottom: 40 }}>
        YOUR SHIP HAS BEEN DESTROYED
      </div>

      <div style={{ display: 'flex', gap: 40, marginBottom: 40, textAlign: 'center' }}>
        <Stat label="FINAL SCORE" value={p.score.toLocaleString()} color={shipColor} big />
        <Stat label="WAVE REACHED" value={String(wave)} color="#ffcc00" big />
        <Stat label="BEST COMBO" value={`${p.comboMax}×`} color="#ff6600" big />
      </div>

      <div style={{ display: 'flex', gap: 40, marginBottom: 40, textAlign: 'center' }}>
        <Stat label="COINS EARNED" value={String(p.coins)} color="#ffcc00" />
        <Stat label="HIGH SCORE" value={highScore.toLocaleString()} color="#00ff88" />
      </div>

      <div style={{ display: 'flex', gap: 16 }}>
        <button onClick={restartGame} style={{ ...btnStyle('#00e5ff') }}>⚡ RETRY</button>
        <button onClick={goToMenu} style={{ ...btnStyle('#ff4466') }}>☰ MENU</button>
      </div>
    </div>
  );
}

function Stat({ label, value, color, big = false }: { label: string; value: string; color: string; big?: boolean }) {
  return (
    <div>
      <div style={{ fontSize: big ? 32 : 20, fontWeight: 900, color, textShadow: `0 0 12px ${color}`, letterSpacing: 2 }}>{value}</div>
      <div style={{ fontSize: 9, color: '#2a4455', letterSpacing: 3, marginTop: 4 }}>{label}</div>
    </div>
  );
}

const btnStyle = (color: string): React.CSSProperties => ({
  padding: '14px 32px', background: 'transparent',
  border: `2px solid ${color}66`, color,
  fontSize: 14, fontWeight: 900, letterSpacing: 4, cursor: 'pointer',
  boxShadow: `0 0 16px ${color}22`, transition: 'all 0.15s',
  fontFamily: "'Courier New', monospace",
});

__COSMIC_FURY_EOF__
echo "  ✓  $ROOT/src/components/game/GameOver.tsx"

  echo ""
  echo "✅  Done!  All files written to ./$ROOT/"
  echo ""
  echo "Next steps:"
  echo "  cd $ROOT"
  echo "  npm install"
  echo "  npm run dev"
  echo ""
  echo "Open in VS Code:"
  echo "  code $ROOT"
  echo ""
  