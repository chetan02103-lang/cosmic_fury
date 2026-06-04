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
