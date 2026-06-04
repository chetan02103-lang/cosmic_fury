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
