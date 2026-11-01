
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
const BOSS_WAVES = [3, 6, 9, 12];

/* ── Helpers ───────────────────────────────────────────────────── */
function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

function angleDiff(a: number, b: number) {
  return ((b - a + Math.PI * 3) % (Math.PI * 2)) - Math.PI;
}

function randomEdge(W: number, H: number): [number, number] {
  const side = Math.floor(Math.random() * 4);

  if (side === 0) return [Math.random() * W, -30];
  if (side === 1) return [W + 30, Math.random() * H];
  if (side === 2) return [Math.random() * W, H + 30];

  return [-30, Math.random() * H];
}

/* ── Player ────────────────────────────────────────────────────── */
function makePlayer(skin: number, weapon: WeaponType): Player {
  return {
    x: 0,
    y: 0,
    vx: 0,
    vy: 0,
    angle: -Math.PI / 2,
    aimAngle: -Math.PI / 2,

    hp: 3,
    maxHp: 3,
    shield: 0,
    maxShield: 3,
    shieldTimer: 0,
    invincibleTimer: 0,
    protectionEnd: Date.now() + 3000,

    speed: 230,
    fireRate: 0.18,
    weapon,
    bulletDamage: 1.0,
    skin,
    fireTimer: 0,

    score: 0,
    coins: 4,
    combo: 0,
    comboTimer: 0,
    comboMax: 0,

    specialCooldown: 0,
    blackHoleCooldown: 0,
    runXp: 0,

    trail: [],
  };
}

/* ── Enemies ───────────────────────────────────────────────────── */
function makeEnemy(
  type: Enemy['type'],
  W: number,
  H: number,
  waveNum: number
): Enemy {
  const [x, y] = randomEdge(W, H);
  const diff = 1 + (waveNum - 1) * 0.12;

  const base: Partial<Enemy> = {
    id: uid(),
    type,
    x,
    y,
    vx: 0,
    vy: 0,
    angle: 0,
    behaviorTimer: Math.random() * 10,
    behaviorPhase: 0,
    fireTimer: Math.random() * 2,
  };

  switch (type) {
    case 'scout':
      return {
        ...base,
        hp: Math.ceil(2 * diff),
        maxHp: Math.ceil(2 * diff),
        coinValue: 1,
        scoreValue: 100,
        radius: 13,
        speed: 105 * Math.min(diff, 2),
      } as Enemy;

    case 'tank':
      return {
        ...base,
        hp: Math.ceil(8 * diff),
        maxHp: Math.ceil(8 * diff),
        coinValue: 3,
        scoreValue: 350,
        radius: 22,
        speed: 52,
      } as Enemy;

    case 'swarm':
      return {
        ...base,
        hp: 1,
        maxHp: 1,
        coinValue: 1,
        scoreValue: 60,
        radius: 8,
        speed: 155 * Math.min(diff, 1.8),
      } as Enemy;

    case 'elite':
      return {
        ...base,
        hp: Math.ceil(5 * diff),
        maxHp: Math.ceil(5 * diff),
        coinValue: 2,
        scoreValue: 250,
        radius: 16,
        speed: 85 * Math.min(diff, 1.6),
      } as Enemy;
  }
}

/* ── Boss ──────────────────────────────────────────────────────── */
function makeBoss(W: number, H: number, bossNum: number): Boss {
  const maxHp = 150 + bossNum * 80;

  return {
    x: W / 2,
    y: -80,
    vx: 0,
    vy: 0,
    angle: Math.PI / 2,

    hp: maxHp,
    maxHp,
    phase: 1,

    attackTimer: 3.5,
    attackPattern: 0,

    moveTimer: 0,
    moveTargetX: W / 2,
    moveTargetY: H * 0.22,

    shieldActive: false,
    shieldTimer: 0,

    entranceTimer: 2.0,
    deathTimer: 0,

    radius: 65,
    bossNum,

    hitFlashTimer: 0,
    lastPlayerWeapon: 'laser',
    plasmaHits: 0,
  };
}

/* ── Wave Configuration ────────────────────────────────────────── */
function getWaveConfig(wave: number, mode: GameMode): WaveConfig {
  if (mode === 'boss-rush') {
    return {
      scouts: 0,
      tanks: 0,
      swarms: 0,
      elites: 0,
      snipers: 0,
      isBoss: true,
    };
  }

  const isBoss = wave % 3 === 0;

  if (isBoss) {
    return {
      scouts: 0,
      tanks: 0,
      swarms: 0,
      elites: 0,
      snipers: 0,
      isBoss: true,
    };
  }

  const d = wave;

  return {
    scouts: Math.min(3 + d * 2, 18),
    tanks: Math.max(0, Math.min(d - 1, 7)),
    swarms: Math.max(0, Math.min((d - 2) * 3, 14)),
    elites: Math.max(0, Math.min(d - 3, 5)),
    snipers: 0,
    isBoss: false,
  };
}

/* ── Upgrade Options ───────────────────────────────────────────── */
function buildUpgradeOptions(p: Player, wave: number): UpgradeOption[] {
  const all: UpgradeOption[] = [
    {
      type: 'speed',
      label: 'Afterburner',
      desc: '+20% movement speed',
      cost: 2,
      color: '#00e5ff',
      icon: '⚡',
      available: true,
    },
    {
      type: 'firerate',
      label: 'Rapid Core',
      desc: '+20% fire rate',
      cost: 2,
      color: '#00ff88',
      icon: '🔫',
      available: true,
    },
    {
      type: 'shield',
      label: 'Shield Module',
      desc: '+1 shield charge (absorbs 1 hit)',
      cost: 2,
      color: '#4488ff',
      icon: '🛡️',
      available: p.maxShield < 3 || p.shield < p.maxShield,
    },
    {
      type: 'maxhp',
      label: 'Hull Plating',
      desc: '+1 max HP',
      cost: 3,
      color: '#ff6644',
      icon: '❤️',
      available: p.maxHp < 6,
    },
    {
      type: 'double',
      label: 'Twin Cannons',
      desc: 'Unlock double laser',
      cost: 3,
      color: '#00ff88',
      icon: '✦',
      available: p.weapon === 'laser',
    },
    {
      type: 'plasma',
      label: 'Plasma Core',
      desc: 'Unlock plasma cannon',
      cost: 4,
      color: '#aa44ff',
      icon: '🌀',
      available: p.weapon !== 'plasma' && p.weapon !== 'homing',
    },
    {
      type: 'homing',
      label: 'Homing Array',
      desc: 'Unlock homing missiles',
      cost: 4,
      color: '#ffaa00',
      icon: '🎯',
      available: p.weapon !== 'homing',
    },
    {
      type: 'damage',
      label: 'Overcharge',
      desc: '+25% bullet damage',
      cost: 3,
      color: '#ff4466',
      icon: '💥',
      available: p.bulletDamage < 2.5,
    },
  ];

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

  W: number;
  H: number;
  scrollY: number;

  player: Player;
  enemies: Enemy[];
  boss: Boss | null;
  playerBullets: Bullet[];
  enemyBullets: Bullet[];
  particles: Particle[];
  coins: Coin[];

  shake: number;
  shakeX: number;
  shakeY: number;

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

  W: 800,
  H: 600,
  scrollY: 0,

  player: makePlayer(0, 'laser'),
  enemies: [],
  boss: null,
  playerBullets: [],
  enemyBullets: [],
  particles: [],
  coins: [],

  shake: 0,
  shakeX: 0,
  shakeY: 0,

  upgradeOptions: [],
  highScore: 0,

  setDimensions: (W, H) => set({ W, H }),

  /* ── Start Game ─────────────────────────────────────────────── */
  startGame: (mode, skin, weapon) => {
    const { W, H } = get();
    const wave = 1;
    const cfg = getWaveConfig(wave, mode);
    const queue: Enemy['type'][] = [];

    for (let i = 0; i < cfg.scouts; i++) queue.push('scout');
    for (let i = 0; i < cfg.tanks; i++) queue.push('tank');
    for (let i = 0; i < cfg.swarms; i++) queue.push('swarm');
    for (let i = 0; i < cfg.elites; i++) queue.push('elite');

    for (let i = queue.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [queue[i], queue[j]] = [queue[j], queue[i]];
    }

    const p = makePlayer(skin, weapon);
    p.x = W / 2;
    p.y = H / 2;

    let boss: Boss | null = null;
    let wavePhase: GameStore['wavePhase'] = 'spawning';

    if (cfg.isBoss) {
      boss = makeBoss(W, H, 1);
      wavePhase = 'boss';
    }

    set({
      screen: 'playing',
      mode,
      wave,
      wavePhase,
      spawnQueue: cfg.isBoss ? [] : queue,
      spawnTimer: 0,
      bossNum: cfg.isBoss ? 1 : 0,
      player: p,
      enemies: [],
      boss,
      playerBullets: [],
      enemyBullets: [],
      particles: [],
      coins: [],
      shake: 0,
      shakeX: 0,
      shakeY: 0,
      scrollY: 0,
    });
  },

  /* ── Main Game Loop ─────────────────────────────────────────── */
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

    /* ─ Player Movement ─ */
    const spd = p.speed;
    let ax = 0;
    let ay = 0;
    const kk = input.keys;

    if (kk.has('ArrowLeft') || kk.has('a') || kk.has('A')) ax -= 1;
    if (kk.has('ArrowRight') || kk.has('d') || kk.has('D')) ax += 1;
    if (kk.has('ArrowUp') || kk.has('w') || kk.has('W')) ay -= 1;
    if (kk.has('ArrowDown') || kk.has('s') || kk.has('S')) ay += 1;

    if (ax !== 0 && ay !== 0) {
      ax *= 0.707;
      ay *= 0.707;
    }

    p.vx += (ax * spd - p.vx) * Math.min(1, dt * 8);
    p.vy += (ay * spd - p.vy) * Math.min(1, dt * 8);

    p.x = clamp(p.x + p.vx * dt, 18, W - 18);
    p.y = clamp(p.y + p.vy * dt, 18, H - 18);

    const mx = input.mouseX;
    const my = input.mouseY;
    const hasMouse = mx > 0 || my > 0;

    if (hasMouse) {
      p.aimAngle = Math.atan2(my - p.y, mx - p.x);
    } else if (ax !== 0 || ay !== 0) {
      p.aimAngle = Math.atan2(ay, ax);
    }

    if (ax !== 0 || ay !== 0) {
      const targetAngle = Math.atan2(ay, ax);
      p.angle += angleDiff(p.angle, targetAngle) * Math.min(1, dt * 10);
    } else {
      p.angle += angleDiff(p.angle, p.aimAngle) * Math.min(1, dt * 5);
    }

    /* ─ Trail ─ */
    const speed2 = p.vx * p.vx + p.vy * p.vy;

    if (speed2 > 800) {
      p.trail = [
        { x: p.x, y: p.y, alpha: 0.9 },
        ...p.trail.slice(0, 22).map(t => ({
          ...t,
          alpha: t.alpha * 0.82,
        })),
      ].filter(t => t.alpha > 0.02);
    } else {
      p.trail = p.trail
        .slice(0, 22)
        .map(t => ({ ...t, alpha: t.alpha * 0.88 }))
        .filter(t => t.alpha > 0.02);
    }

    /* ─ Player Shooting ─ */
    p.fireTimer = Math.max(0, p.fireTimer - dt);
    p.specialCooldown = Math.max(0, p.specialCooldown - dt);
    p.blackHoleCooldown = Math.max(0, p.blackHoleCooldown - dt);
    p.invincibleTimer = Math.max(0, p.invincibleTimer - dt);

    if (p.fireTimer <= 0) {
      const bspd = 480;
      const ax2 = Math.cos(p.aimAngle);
      const ay2 = Math.sin(p.aimAngle);
      const dmg = p.bulletDamage;

      if (p.weapon === 'laser') {
        playerBullets.push({
          id: uid(),
          owner: 'player',
          x: p.x,
          y: p.y,
          vx: ax2 * bspd,
          vy: ay2 * bspd,
          damage: dmg,
          life: 1.1,
          style: 'laser',
          size: 3.5,
        });
        audio.laser();

      } else if (p.weapon === 'double') {
        const perp = { x: -ay2 * 8, y: ax2 * 8 };

        playerBullets.push({
          id: uid(),
          owner: 'player',
          x: p.x + perp.x,
          y: p.y + perp.y,
          vx: ax2 * bspd,
          vy: ay2 * bspd,
          damage: dmg * 0.7,
          life: 1.1,
          style: 'double',
          size: 3,
        });

        playerBullets.push({
          id: uid(),
          owner: 'player',
          x: p.x - perp.x,
          y: p.y - perp.y,
          vx: ax2 * bspd,
          vy: ay2 * bspd,
          damage: dmg * 0.7,
          life: 1.1,
          style: 'double',
          size: 3,
        });

        audio.doubleLaser();

      } else if (p.weapon === 'plasma') {
        playerBullets.push({
          id: uid(),
          owner: 'player',
          x: p.x,
          y: p.y,
          vx: ax2 * 280,
          vy: ay2 * 280,
          damage: dmg * 2.5,
          life: 1.8,
          style: 'plasma',
          size: 11,
        });
        audio.plasma();

      } else if (p.weapon === 'homing') {
        let nearestId: string | undefined;
        let nearestDist = Infinity;

        for (const e of enemies) {
          const d = Math.hypot(e.x - p.x, e.y - p.y);
          if (d < nearestDist) {
            nearestDist = d;
            nearestId = e.id;
          }
        }

        if (boss && Math.hypot(boss.x - p.x, boss.y - p.y) < nearestDist) {
          nearestId = 'boss';
        }

        playerBullets.push({
          id: uid(),
          owner: 'player',
          x: p.x,
          y: p.y,
          vx: ax2 * 320,
          vy: ay2 * 320,
          damage: dmg * 1.5,
          life: 2.2,
          style: 'missile',
          size: 5,
          homingTargetId: nearestId,
        });

        audio.missile();
      }

      const rateMulti =
        p.weapon === 'plasma' ? 2.8 :
        p.weapon === 'homing' ? 1.4 : 1.0;

      p.fireTimer = p.fireRate * rateMulti;
    }

    /* ─ Shield Recharge ─ */
    if (p.shield < p.maxShield) {
      p.shieldTimer += dt;

      if (p.shieldTimer > 6) {
        p.shield++;
        p.shieldTimer = 0;
      }
    } else {
      p.shieldTimer = 0;
    }

    /* ─ Player Bullets Update ─ */
    playerBullets = playerBullets
      .map(b => {
        const nx = b.x + b.vx * dt;
        const ny = b.y + b.vy * dt;
        let nvx = b.vx;
        let nvy = b.vy;

        if (b.style === 'missile' && b.homingTargetId) {
          let tx: number | undefined;
          let ty: number | undefined;

          if (b.homingTargetId === 'boss' && boss) {
            tx = boss.x;
            ty = boss.y;
          } else {
            const target = enemies.find(e => e.id === b.homingTargetId);

            if (target) {
              tx = target.x;
              ty = target.y;
            } else {
              let nd = Infinity;

              for (const e of enemies) {
                const d = Math.hypot(e.x - b.x, e.y - b.y);
                if (d < nd) {
                  nd = d;
                  tx = e.x;
                  ty = e.y;
                }
              }

              if (boss) {
                const d = Math.hypot(boss.x - b.x, boss.y - b.y);
                if (d < nd) {
                  tx = boss.x;
                  ty = boss.y;
                }
              }
            }
          }

          if (tx !== undefined && ty !== undefined) {
            const ta = Math.atan2(ty - b.y, tx - b.x);
            const ca = Math.atan2(b.vy, b.vx);
            const turn = clamp(angleDiff(ca, ta), -dt * 4, dt * 4);
            const spd3 = Math.hypot(b.vx, b.vy);
            const na = ca + turn;

            nvx = Math.cos(na) * spd3;
            nvy = Math.sin(na) * spd3;
          }
        }

        return {
          ...b,
          x: nx,
          y: ny,
          vx: nvx,
          vy: nvy,
          life: b.life - dt,
        };
      })
      .filter(b =>
        b.life > 0 &&
        b.x > -30 && b.x < W + 30 &&
        b.y > -30 && b.y < H + 30
      );

    /* ─ Enemies Update ─ */
    const newEnemyBullets: Bullet[] = [];

    enemies = enemies.map(e => {
      let {
        x, y, vx, vy, angle,
        fireTimer, behaviorTimer, behaviorPhase, speed,
      } = e;

      const dx = p.x - x;
      const dy = p.y - y;
      const dist = Math.hypot(dx, dy) || 1;

      const toPlayer = {
        x: dx / dist,
        y: dy / dist,
      };

      behaviorTimer += dt;

      if (e.type === 'scout') {
        const zigzag = Math.sin(behaviorTimer * 2.8) * 85;
        const perp = { x: -toPlayer.y, y: toPlayer.x };

        vx += (
          toPlayer.x * speed + perp.x * zigzag - vx
        ) * Math.min(1, dt * 3.5);

        vy += (
          toPlayer.y * speed + perp.y * zigzag - vy
        ) * Math.min(1, dt * 3.5);

        angle = Math.atan2(vy, vx);
        fireTimer -= dt;

        if (fireTimer <= 0) {
          const a =
            Math.atan2(p.y - y, p.x - x) +
            (Math.random() - 0.5) * 0.3;

          newEnemyBullets.push({
            id: uid(),
            owner: 'enemy',
            x,
            y,
            vx: Math.cos(a) * 210,
            vy: Math.sin(a) * 210,
            damage: 1,
            life: 1.8,
            style: 'e_basic',
            size: 4,
          });

          fireTimer = 2.2 + Math.random() * 0.8;
        }

      } else if (e.type === 'tank') {
        vx += (
          toPlayer.x * speed - vx
        ) * Math.min(1, dt * 2.0);

        vy += (
          toPlayer.y * speed - vy
        ) * Math.min(1, dt * 2.0);

        angle = Math.atan2(vy, vx);
        fireTimer -= dt;

        if (fireTimer <= 0) {
          const baseA = Math.atan2(p.y - y, p.x - x);

          for (const da of [-0.38, 0, 0.38]) {
            const a = baseA + da;

            newEnemyBullets.push({
              id: uid(),
              owner: 'enemy',
              x,
              y,
              vx: Math.cos(a) * 190,
              vy: Math.sin(a) * 190,
              damage: 1,
              life: 2.0,
              style: 'e_spread',
              size: 5,
            });
          }

          fireTimer = 3.0 + Math.random();
        }

      } else if (e.type === 'swarm') {
        if (behaviorTimer > 2.5) {
          behaviorTimer = 0;
          behaviorPhase = (behaviorPhase + 1) % 6;
        }

        const orbitAngle = behaviorPhase * (Math.PI / 3) + behaviorTimer;
        const orbitR = 80 + Math.random() * 40;

        const tx = p.x + Math.cos(orbitAngle) * orbitR;
        const ty = p.y + Math.sin(orbitAngle) * orbitR;

        const ex = tx - x;
        const ey = ty - y;

        vx += (ex * 0.04 * speed - vx) * Math.min(1, dt * 5);
        vy += (ey * 0.04 * speed - vy) * Math.min(1, dt * 5);

        angle = Math.atan2(vy, vx);

      } else if (e.type === 'elite') {
        const perp2 = {
          x: -toPlayer.y * (behaviorPhase === 0 ? 1 : -1),
          y: toPlayer.x * (behaviorPhase === 0 ? 1 : -1),
        };

        const approachFactor = dist > 200 ? 0.6 : 0.1;

        vx += (
          toPlayer.x * speed * approachFactor +
          perp2.x * speed * 0.7 - vx
        ) * Math.min(1, dt * 2.5);

        vy += (
          toPlayer.y * speed * approachFactor +
          perp2.y * speed * 0.7 - vy
        ) * Math.min(1, dt * 2.5);

        if (behaviorTimer > 2.8) {
          behaviorTimer = 0;
          behaviorPhase = behaviorPhase === 0 ? 1 : 0;
        }

        angle = Math.atan2(vy, vx);
        fireTimer -= dt;

        if (fireTimer <= 0) {
          const a = Math.atan2(p.y - y, p.x - x);

          newEnemyBullets.push({
            id: uid(),
            owner: 'enemy',
            x,
            y,
            vx: Math.cos(a) * 230,
            vy: Math.sin(a) * 230,
            damage: 1,
            life: 1.7,
            style: 'e_homing',
            size: 4.5,
          });

          fireTimer = 1.8 + Math.random() * 0.5;
        }
      }

      x = clamp(x + vx * dt, -60, W + 60);
      y = clamp(y + vy * dt, -60, H + 60);

      return {
        ...e,
        x, y, vx, vy, angle,
        fireTimer, behaviorTimer, behaviorPhase,
      };
    });

    /* ─ Boss Update ─ */
    if (boss && boss.entranceTimer > 0) {
      boss.entranceTimer -= dt;
      boss.y = Math.min(
        H * 0.22,
        boss.y + (H * 0.22 - (-80)) / 2 * dt
      );

    } else if (boss && boss.deathTimer <= 0) {
      const hpPct = boss.hp / boss.maxHp;

      const newPhase: Boss['phase'] =
        hpPct > 0.6 ? 1 :
        hpPct > 0.3 ? 2 : 3;

      if (newPhase !== boss.phase) {
        boss.phase = newPhase;

        particles.push(
          ...makeExplosion(boss.x, boss.y, '#cc44ff', 20, true)
        );

        audio.bossPhase();
        shake = Math.max(shake, 0.4);

        if (newPhase === 3) boss.shieldActive = false;
      }

      boss.moveTimer -= dt;

      if (boss.moveTimer <= 0) {
        boss.moveTargetX = W * 0.15 + Math.random() * W * 0.7;
        boss.moveTargetY = H * 0.08 + Math.random() * H * 0.35;

        const moveTime =
          boss.phase === 3 ? 1.2 :
          boss.phase === 2 ? 1.8 : 2.5;

        boss.moveTimer = moveTime;

        if (boss.phase === 3 && Math.random() < 0.35) {
          boss.moveTargetX = p.x;
          boss.moveTargetY = p.y;
          boss.moveTimer = 0.7;
        }
      }

      const bdx = boss.moveTargetX - boss.x;
      const bdy = boss.moveTargetY - boss.y;

      const bspd2 =
        boss.phase === 3 ? 240 :
        boss.phase === 2 ? 160 : 100;

      boss.vx += (
        bdx * 0.05 * bspd2 - boss.vx
      ) * Math.min(1, dt * 2.5);

      boss.vy += (
        bdy * 0.05 * bspd2 - boss.vy
      ) * Math.min(1, dt * 2.5);

      boss.x = clamp(boss.x + boss.vx * dt, 80, W - 80);
      boss.y = clamp(boss.y + boss.vy * dt, 70, H * 0.45);

      boss.angle += dt * (boss.phase >= 2 ? 0.6 : 0.3);

      boss.shieldTimer = Math.max(0, boss.shieldTimer - dt);

      if (
        boss.phase < 3 &&
        !boss.shieldActive &&
        boss.shieldTimer <= 0 &&
        Math.random() < dt * 0.04
      ) {
        boss.shieldActive = true;
        boss.shieldTimer = 4.0;
      }

      if (boss.shieldActive && boss.shieldTimer <= 0) {
        boss.shieldActive = false;
        boss.shieldTimer = 8.0;
      }

      /* ─ Boss Attacks ─ */
      boss.attackTimer -= dt;

      if (boss.attackTimer <= 0) {
        const attackDelay =
          boss.phase === 3 ? 0.9 :
          boss.phase === 2 ? 1.3 : 1.8;

        boss.attackTimer = attackDelay;
        const pattern = boss.attackPattern;

        if (pattern === 0 || boss.phase === 3) {
          const count =
            boss.phase === 3 ? 16 :
            boss.phase === 2 ? 12 : 8;

          for (let i = 0; i < count; i++) {
            const a = (i / count) * Math.PI * 2;

            newEnemyBullets.push({
              id: uid(),
              owner: 'boss',
              x: boss.x,
              y: boss.y,
              vx: Math.cos(a) * 200,
              vy: Math.sin(a) * 200,
              damage: 1,
              life: 2.5,
              style: 'b_beam',
              size: 7,
            });
          }
        }

        if (pattern === 1 || boss.phase >= 2) {
          const baseA = Math.atan2(p.y - boss.y, p.x - boss.x);

          const count2 =
            boss.phase === 3 ? 9 :
            boss.phase === 2 ? 7 : 5;

          const spread = 0.28;

          for (let i = 0; i < count2; i++) {
            const a =
              baseA + (i - Math.floor(count2 / 2)) * spread;

            newEnemyBullets.push({
              id: uid(),
              owner: 'boss',
              x: boss.x,
              y: boss.y,
              vx: Math.cos(a) * 260,
              vy: Math.sin(a) * 260,
              damage: 1,
              life: 2.0,
              style: 'b_orb',
              size: 10,
            });
          }
        }

        if (boss.phase >= 2 && pattern === 2) {
          for (let i = 0; i < 3; i++) {
            const a = boss.angle + (i / 3) * Math.PI * 2;

            newEnemyBullets.push({
              id: uid(),
              owner: 'boss',
              x: boss.x,
              y: boss.y,
              vx: Math.cos(a) * 300,
              vy: Math.sin(a) * 300,
              damage: 1,
              life: 1.8,
              style: 'b_beam',
              size: 8,
            });
          }
        }

        boss.attackPattern =
          (boss.attackPattern + 1) % (boss.phase >= 2 ? 3 : 2);
      }
    }

    /* ─ Enemy Bullets Update ─ */
    enemyBullets = [...enemyBullets, ...newEnemyBullets]
      .map(b => ({
        ...b,
        x: b.x + b.vx * dt,
        y: b.y + b.vy * dt,
        life: b.life - dt,
      }))
      .filter(b =>
        b.life > 0 &&
        b.x > -40 && b.x < W + 40 &&
        b.y > -40 && b.y < H + 40
      );

    /* ─ Particles Update ─ */
    particles = particles
      .map(pp => {
        const fric = pp.style === 'spark' ? 0.88 : 0.96;

        return {
          ...pp,
          x: pp.x + pp.vx * dt,
          y: pp.y + pp.vy * dt,
          vx: pp.vx * fric,
          vy: pp.vy * fric,
          life: pp.life - dt,
        };
      })
      .filter(pp => pp.life > 0);

    /* ─ Coins Update ─ */
    coins = coins
      .map(c => {
        let { x, y, vx, vy } = c;

        const cdx = p.x - x;
        const cdy = p.y - y;
        const cdist = Math.hypot(cdx, cdy) || 1;

        if (cdist < COIN_ATTRACT_RADIUS) {
          const pull =
            (COIN_ATTRACT_RADIUS - cdist) /
            COIN_ATTRACT_RADIUS * 400;

          vx += (cdx / cdist) * pull * dt;
          vy += (cdy / cdist) * pull * dt;
        }

        vx *= 0.96;
        vy *= 0.96;

        x += vx * dt;
        y += vy * dt;

        return { ...c, x, y, vx, vy, life: c.life - dt };
      })
      .filter(c => c.life > 0);

    /* ─ Player Bullets vs Enemies ─ */
    const hitsEnemies = new Set<string>();
    const hitsBoss = new Set<string>();

    playerBullets = playerBullets.filter(b => {
      for (const e of enemies) {
        if (hitsEnemies.has(b.id)) break;

        if (Math.hypot(b.x - e.x, b.y - e.y) < e.radius) {
          hitsEnemies.add(b.id);

          const idx = enemies.findIndex(x => x.id === e.id);

          if (idx >= 0) {
            enemies[idx] = {
              ...enemies[idx],
              hp: enemies[idx].hp - b.damage,
            };

            if (enemies[idx].hp <= 0) {
              const color =
                e.type === 'scout' ? '#44ff44' :
                e.type === 'tank' ? '#ff3322' :
                e.type === 'swarm' ? '#00ccff' : '#cc44ff';

              particles.push(
                ...makeExplosion(
                  e.x,
                  e.y,
                  color,
                  e.type === 'tank' ? 20 : 10,
                  e.type === 'tank'
                )
              );

              audio.explosion(e.type === 'tank' ? 1.5 : 0.7);
              shake = Math.max(shake, e.type === 'tank' ? 0.25 : 0.12);

              for (let i = 0; i < e.coinValue; i++) {
                const ca = Math.random() * Math.PI * 2;

                coins.push({
                  id: uid(),
                  x: e.x,
                  y: e.y,
                  vx: Math.cos(ca) * 60,
                  vy: Math.sin(ca) * 60,
                  value: 1,
                  life: 8,
                });
              }

              p.combo++;
              p.comboTimer = COMBO_EXPIRE;
              p.comboMax = Math.max(p.comboMax, p.combo);

              if (p.combo > 0 && p.combo % 5 === 0) {
                audio.comboUp();
              }

              const multi =
                p.combo >= 20 ? 5 :
                p.combo >= 10 ? 3 :
                p.combo >= 5 ? 2 : 1;

              p.score += e.scoreValue * multi;
              enemies[idx] = { ...enemies[idx], hp: -9999 };
            }
          }

          return b.style !== 'plasma';
        }
      }

      /* ─ Player Bullets vs Boss ─ */
      if (
        boss &&
        boss.deathTimer <= 0 &&
        boss.entranceTimer <= 0 &&
        !hitsBoss.has(b.id)
      ) {
        if (
          !boss.shieldActive &&
          Math.hypot(b.x - boss.x, b.y - boss.y) < boss.radius
        ) {
          hitsBoss.add(b.id);
          boss.hp = Math.max(0, boss.hp - b.damage);

          audio.bossHit();
          shake = Math.max(shake, 0.18);

          particles.push(
            ...makeExplosion(b.x, b.y, '#cc44ff', 5)
          );

          if (boss.hp <= 0 && boss.deathTimer <= 0) {
            boss.deathTimer = 2.5;

            particles.push(
              ...makeExplosion(boss.x, boss.y, '#ff44ff', 40, true)
            );

            particles.push(
              ...makeExplosion(boss.x, boss.y, '#ffaa00', 30, true)
            );

            audio.bossExplosion();
            shake = Math.max(shake, 0.8);

            for (let i = 0; i < 12; i++) {
              const ca = Math.random() * Math.PI * 2;

              coins.push({
                id: uid(),
                x: boss.x,
                y: boss.y,
                vx: Math.cos(ca) * 120,
                vy: Math.sin(ca) * 120,
                value: 1,
                life: 12,
              });
            }

            p.score += 5000 * boss.bossNum;
          }

          return false;
        }
      }

      return true;
    });

    enemies = enemies.filter(e => e.hp > 0);

    /* ─ Enemy Bullets vs Player ─ */
    if (p.invincibleTimer <= 0 && Date.now() > p.protectionEnd) {
      enemyBullets = enemyBullets.filter(b => {
        if (
          Math.hypot(b.x - p.x, b.y - p.y) <
          PLAYER_RADIUS + b.size
        ) {
          if (p.shield > 0) {
            p.shield = Math.max(0, p.shield - 1);

            audio.shieldHit();

            particles.push(
              ...makeExplosion(b.x, b.y, '#4488ff', 6)
            );

            shake = Math.max(shake, 0.15);

          } else {
            p.hp--;
            audio.playerHit();

            shake = Math.max(shake, 0.35);
            p.invincibleTimer = 2.2;
            p.combo = 0;
            p.comboTimer = 0;

            particles.push(
              ...makeExplosion(p.x, p.y, '#00e5ff', 12)
            );

            if (p.hp <= 0) {
              particles.push(
                ...makeExplosion(p.x, p.y, '#ffaa00', 25, true)
              );

              audio.explosion(2);

              set({
                player: p,
                enemies,
                boss,
                playerBullets,
                enemyBullets,
                particles,
                coins,
                shake,
                screen: 'gameover',
                highScore: Math.max(s.highScore, p.score),
              });

              return false;
            }
          }

          return false;
        }

        return true;
      });
    }

    /* ─ Player vs Enemies ─ */
    if (p.invincibleTimer <= 0 && Date.now() > p.protectionEnd) {
      for (const e of enemies) {
        if (
          Math.hypot(e.x - p.x, e.y - p.y) <
          e.radius + PLAYER_RADIUS - 4
        ) {
          if (p.shield > 0) {
            p.shield--;
            audio.shieldHit();

          } else {
            p.hp--;
            audio.playerHit();
            shake = Math.max(shake, 0.3);

            if (p.hp <= 0) {
              set({
                player: p,
                enemies,
                boss,
                playerBullets,
                enemyBullets,
                particles,
                coins,
                shake,
                screen: 'gameover',
                highScore: Math.max(s.highScore, p.score),
              });

              return;
            }
          }

          p.invincibleTimer = 2.0;
          p.combo = 0;
          p.comboTimer = 0;
          break;
        }
      }
    }

    /* ─ Coin Pickup ─ */
    coins = coins.filter(c => {
      if (Math.hypot(c.x - p.x, c.y - p.y) < 18) {
        p.coins += c.value;
        p.score += 10;
        audio.coin();
        return false;
      }

      return true;
    });

    /* ─ Combo Timer ─ */
    if (p.comboTimer > 0) {
      p.comboTimer -= dt;

      if (p.comboTimer <= 0) {
        p.combo = 0;
      }
    }

    /* ─ Camera Shake ─ */
    const shakeX =
      shake > 0 ? (Math.random() - 0.5) * shake * 18 : 0;

    const shakeY =
      shake > 0 ? (Math.random() - 0.5) * shake * 18 : 0;

    /* ─ Wave / Spawn Logic ─ */
    let spawnQueueNew = spawnQueue;

    if (wavePhase === 'spawning') {
      spawnTimer -= dt;

      if (spawnTimer <= 0 && spawnQueueNew.length > 0) {
        const type = spawnQueueNew[0];

        enemies.push(makeEnemy(type, W, H, wave));
        spawnQueueNew = spawnQueueNew.slice(1);
        spawnTimer = 0.65;
      }

      if (spawnQueueNew.length === 0) {
        wavePhase = 'fighting';
      }
    }

    if (wavePhase === 'fighting' && enemies.length === 0) {
      wavePhase = 'cleared';
    }

    /* ─ Boss Death Sequence ─ */
    if (boss && boss.deathTimer > 0) {
      boss.deathTimer -= dt;

      if (boss.deathTimer % 0.35 < dt) {
        const bx = boss.x + (Math.random() - 0.5) * 80;
        const by = boss.y + (Math.random() - 0.5) * 60;

        particles.push(
          ...makeExplosion(bx, by, '#ff6600', 8, false)
        );
      }

      if (boss.deathTimer <= 0) {
        const options = buildUpgradeOptions(p, wave);
        audio.waveComplete();

        set({
          player: p,
          enemies: [],
          boss: null,
          playerBullets: [],
          enemyBullets,
          particles,
          coins,
          shake,
          shakeX,
          shakeY,
          scrollY,
          spawnQueue: [],
          spawnTimer: 0,
          wave,
          wavePhase: 'cleared',
          bossNum,
          screen: 'upgrade',
          upgradeOptions: options,
        });

        return;
      }
    }

    /* ─ Wave Cleared ─ */
    if (wavePhase === 'cleared' && (!boss || boss.deathTimer <= 0)) {
      const options = buildUpgradeOptions(p, wave);
      audio.waveComplete();

      set({
        player: p,
        enemies: [],
        boss: null,
        playerBullets,
        enemyBullets: [],
        particles,
        coins,
        shake,
        shakeX,
        shakeY,
        scrollY,
        spawnQueue: [],
        spawnTimer: 0,
        wave,
        wavePhase,
        screen: 'upgrade',
        upgradeOptions: options,
      });

      return;
    }

    set({
      player: p,
      enemies,
      boss,
      playerBullets,
      enemyBullets,
      particles,
      coins,
      shake,
      shakeX,
      shakeY,
      scrollY,
      spawnQueue: spawnQueueNew,
      spawnTimer,
      wave,
      wavePhase,
      bossNum,
    });
  },

  /* ── Purchase Upgrade ────────────────────────────────────────── */
  purchaseUpgrade: (type) => {
    const { player: p } = get();

    if (type === 'speed') {
      set({
        player: {
          ...p,
          speed: Math.min(p.speed + 44, 400),
          coins: p.coins - 2,
        },
      });

    } else if (type === 'firerate') {
      set({
        player: {
          ...p,
          fireRate: Math.max(p.fireRate * 0.82, 0.06),
          coins: p.coins - 2,
        },
      });

    } else if (type === 'shield') {
      set({
        player: {
          ...p,
          maxShield: Math.min(p.maxShield + 1, 3),
          shield: Math.min(
            p.shield + 1,
            Math.min(p.maxShield + 1, 3)
          ),
          coins: p.coins - 2,
        },
      });

    } else if (type === 'maxhp') {
      set({
        player: {
          ...p,
          maxHp: p.maxHp + 1,
          hp: p.hp + 1,
          coins: p.coins - 3,
        },
      });

    } else if (type === 'double') {
      set({
        player: {
          ...p,
          weapon: 'double',
          coins: p.coins - 3,
        },
      });

    } else if (type === 'plasma') {
      set({
        player: {
          ...p,
          weapon: 'plasma',
          coins: p.coins - 4,
        },
      });

    } else if (type === 'homing') {
      set({
        player: {
          ...p,
          weapon: 'homing',
          coins: p.coins - 4,
        },
      });

    } else if (type === 'damage') {
      set({
        player: {
          ...p,
          bulletDamage: Math.min(p.bulletDamage + 0.25, 2.5),
          coins: p.coins - 3,
        },
      });
    }
  },

  /* ── Continue After Upgrade ──────────────────────────────────── */
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

    const newBossNum = cfg.isBoss
      ? get().bossNum + 1
      : get().bossNum;

    const boss = cfg.isBoss
      ? makeBoss(W, H, newBossNum)
      : null;

    const newPlayer = {
      ...player,
      protectionEnd: Date.now() + 2000,
      invincibleTimer: 0,
    };

    set({
      screen: 'playing',
      wave: nextWave,
      wavePhase: cfg.isBoss ? 'boss' : 'spawning',
      spawnQueue: cfg.isBoss ? [] : queue,
      spawnTimer: 0,
      bossNum: newBossNum,
      player: newPlayer,
      enemies: [],
      boss,
      playerBullets: [],
      enemyBullets: [],
    });
  },

  /* ── Restart / Menu ──────────────────────────────────────────── */
  restartGame: () => {
    const { mode, player } = get();
    get().startGame(mode, player.skin, player.weapon);
  },

  goToMenu: () => set({ screen: 'menu' }),
}));
