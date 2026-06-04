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
