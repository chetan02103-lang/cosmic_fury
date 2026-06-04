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
