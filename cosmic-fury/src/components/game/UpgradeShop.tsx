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
