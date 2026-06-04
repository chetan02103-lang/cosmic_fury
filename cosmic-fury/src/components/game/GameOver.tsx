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
