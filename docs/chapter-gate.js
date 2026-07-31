// chapter-gate.js — mividacomoluna.com
// Chapter One is the welcoming screen: a first-time visitor lands there, not on the site body.
// Deliberately conservative:
//   · fires ONLY on the site root (never on a deep link, so shared URLs keep working)
//   · once per browser session (sessionStorage), so navigating back doesn't loop
//   · escape hatches: ?skip on the URL, or a persistent localStorage opt-out
//   · replace() not assign(), so Back doesn't bounce the visitor
(function () {
  try {
    var SEEN = 'mvcl_ch1_seen';
    var OPTOUT = 'mvcl_ch1_optout';

    if (localStorage.getItem(OPTOUT) === '1') return;
    if (/[?&]skip\b/.test(location.search)) { sessionStorage.setItem(SEEN, '1'); return; }
    if (sessionStorage.getItem(SEEN) === '1') return;

    // Root only. Matches "/", "/index.html", and the same under a /docs/ prefix
    // (so it behaves identically on GitHub Pages and when served locally out of docs/).
    var p = location.pathname.replace(/\/index\.html?$/i, '/');
    if (!/(^\/$)|(\/docs\/$)/.test(p)) return;

    sessionStorage.setItem(SEEN, '1');
    location.replace('chapter-one/');
  } catch (e) {
    // Storage blocked (private mode / cookies off) — fail open to the site, never trap the visitor.
  }
})();
