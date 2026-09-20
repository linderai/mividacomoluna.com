/* One world, two hosts. Visual preference only: never changes auth or model routing. */
(function () {
  'use strict';
  var root = document.documentElement;
  var key = 'mvcl_world_v1';
  var world = 'colors';
  try { if (localStorage.getItem(key) === 'goth') world = 'goth'; } catch (_) {}
  root.dataset.world = world;
  root.classList.remove('theme-red');
  root.classList.add('theme-blue');

  function paint() {
    root.dataset.world = world;
    document.querySelectorAll('[data-world-toggle]').forEach(function (button) {
      button.setAttribute('aria-pressed', String(world === 'goth'));
      button.setAttribute('aria-label', world === 'goth'
        ? 'Goth · Luna. Cambiar a Colors · Linder'
        : 'Colors · Linder. Cambiar a Goth · Luna');
      button.title = world === 'goth' ? 'Entrar al mundo de Linder' : 'Entrar al mundo de Luna';
    });
    document.querySelectorAll('[data-world-name]').forEach(function (el) {
      el.textContent = world === 'goth' ? 'Luna' : 'Linder';
    });
    document.querySelectorAll('[data-world-role]').forEach(function (el) {
      el.textContent = world === 'goth' ? 'Goth · Moon · Rituals' : 'Colors · Music · City';
    });
  }
  function setWorld(next, persist) {
    if (next !== 'colors' && next !== 'goth') return;
    world = next;
    if (persist) { try { localStorage.setItem(key, world); } catch (_) {} }
    paint();
    window.dispatchEvent(new CustomEvent('mvcl:worldchange', { detail: { world: world } }));
  }
  window.MVCLWorld = {
    current: function () { return world; },
    set: function (next) { setWorld(next, true); },
    toggle: function () { setWorld(world === 'colors' ? 'goth' : 'colors', true); }
  };
  document.addEventListener('click', function (event) {
    if (event.target.closest('[data-world-toggle]')) window.MVCLWorld.toggle();
  });
  window.addEventListener('storage', function (event) {
    if (event.key === key || event.key === null) {
      setWorld(event.newValue === 'goth' ? 'goth' : 'colors', false);
    }
  });
  // Same-origin embedded zodiac receives an immediate update; no credentials or messages sent.
  try {
    if (window.parent !== window && window.parent.MVCLWorld) {
      world = window.parent.MVCLWorld.current();
      root.dataset.world = world;
      window.parent.addEventListener('mvcl:worldchange', function (event) {
        setWorld(event.detail.world, false);
      });
    }
  } catch (_) {}
  document.addEventListener('DOMContentLoaded', paint, { once: true });
})();
