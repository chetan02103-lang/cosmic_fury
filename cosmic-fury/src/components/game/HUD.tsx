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
