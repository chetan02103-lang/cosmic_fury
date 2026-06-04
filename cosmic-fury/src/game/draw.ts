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
