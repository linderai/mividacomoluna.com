// ════════════════════════════════════════════════════════════════════════
//  MIVIDACOMOLUNA · embers.js — theme-aware ember drift.
//  Forked from jezabel.xyz/assets/embers.js (which was vendored from
//  storiesbyjez.com/html/snake-bg.js). Drifts a "temperature" colour
//  between MAGENTA and the paired accent (BLUE in theme-blue, RED in
//  theme-red). Reads the theme class from <html> each frame so the
//  toggle button repaints live, no listener wiring. Exposes the drifted
//  RGB on :root as --temp / --temp-soft. Self-injecting, idempotent.
// ════════════════════════════════════════════════════════════════════════
(function () {
  if (window.__mvclEmbers) return;
  window.__mvclEmbers = true;

  // Per-theme COLD → MID → HOT triples.
  //   theme-blue: deep-blue → magenta → cyan-blue   (cool to electric)
  //   theme-red:  deep-red  → magenta → orange-red  (warm to bloom)
  var PALETTE = {
    blue: { COLD:[ 60, 90,200], MID:[255, 43,214], HOT:[ 61,240,255] },
    red:  { COLD:[120,  0, 40], MID:[255, 43,214], HOT:[255, 80, 60] }
  };

  var Temp = (function () {
    var t = 0.5, target = 0.5;
    setInterval(function () { target = Math.random(); }, 4000 + Math.random() * 2800);
    function lerp(a, b, k) { return a.map(function (v, i) { return Math.round(v + (b[i] - v) * k); }); }
    function currentPalette(){
      return document.documentElement.classList.contains('theme-red')
        ? PALETTE.red : PALETTE.blue;
    }
    return {
      step: function () { t += (target - t) * 0.011; return t; },
      rgb:  function (v) {
        var p = currentPalette();
        return v <= 0.5 ? lerp(p.COLD, p.MID, v / 0.5) : lerp(p.MID, p.HOT, (v - 0.5) / 0.5);
      }
    };
  })();

  function init() {
    if (document.getElementById('mvclEmbers')) return;
    var c = document.createElement('canvas');
    c.id = 'mvclEmbers';
    c.style.cssText = 'position:fixed;inset:0;z-index:0;pointer-events:none;';
    document.body.insertBefore(c, document.body.firstChild);
    var x = c.getContext('2d');

    var W, H, DPR, bits = [];
    function build() {
      DPR = Math.min(window.devicePixelRatio || 1, 2);
      W = c.width  = window.innerWidth  * DPR;
      H = c.height = window.innerHeight * DPR;
      c.style.width  = window.innerWidth  + 'px';
      c.style.height = window.innerHeight + 'px';
      var n = Math.floor(window.innerWidth * window.innerHeight / 20000);
      bits = [];
      for (var i = 0; i < n; i++) bits.push({
        x: Math.random() * W, y: Math.random() * H,
        r: (Math.random() * 1.8 + 0.5) * DPR,
        vy: -(Math.random() * 0.22 + 0.05) * DPR,
        vx: (Math.random() - 0.5) * 0.10 * DPR,
        a: Math.random() * 0.55 + 0.25, ph: Math.random() * 6.28
      });
    }
    build();
    window.addEventListener('resize', build);

    var root = document.documentElement.style, t = 0;
    function frame() {
      t += 0.016;
      var v = Temp.step(), col = Temp.rgb(v);
      x.clearRect(0, 0, W, H);
      x.globalCompositeOperation = 'lighter';
      root.setProperty('--temp',      'rgb(' + col[0] + ',' + col[1] + ',' + col[2] + ')');
      root.setProperty('--temp-soft', 'rgba(' + col[0] + ',' + col[1] + ',' + col[2] + ',.5)');
      for (var i = 0; i < bits.length; i++) {
        var b = bits[i];
        b.y += b.vy; b.x += b.vx + Math.sin(t + b.ph) * 0.15 * DPR;
        if (b.y < -4) { b.y = H + 4; b.x = Math.random() * W; }
        var fl = b.a * (0.6 + 0.4 * Math.sin(t * 2 + b.ph));
        x.beginPath(); x.arc(b.x, b.y, b.r, 0, 6.2832);
        x.fillStyle = 'rgba(' + col[0] + ',' + col[1] + ',' + col[2] + ',' + fl + ')';
        x.fill();
      }
      requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
  }

  if (document.body) init();
  else document.addEventListener('DOMContentLoaded', init);
})();
