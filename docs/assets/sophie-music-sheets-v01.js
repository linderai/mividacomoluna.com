/* Static music letters: local controls only; no network, account or audio handling. */
(() => {
  "use strict";

  const body = document.body;
  const $ = (selector) => document.querySelector(selector);
  const $$ = (selector) => [...document.querySelectorAll(selector)];
  const songId = body.dataset.songId;
  const notes = $("#session-notes");
  const status = $("#notes-status");
  const storageKey = songId ? `luna-music-notes:v1:${songId}` : null;
  let fontSize = 16;
  $$(".music-toolbar, .notes-controls").forEach(el => { el.hidden = false; });

  const tell = (message) => {
    if (status) status.textContent = message;
  };

  const setView = (view) => {
    if (view !== "letter" && view !== "rehearsal") return;
    body.dataset.view = view;
    $$("button[data-view]").forEach((button) => {
      button.setAttribute("aria-pressed", String(button.dataset.view === view));
    });
  };

  if ($$("button[data-view]").length) {
    $$("button[data-view]").forEach((button) => {
      button.addEventListener("click", () => setView(button.dataset.view));
    });
    setView(body.dataset.view === "rehearsal" ? "rehearsal" : "letter");
  }

  const showFontSize = () => {
    body.style.setProperty("--sheet-size", `${fontSize}px`);
    const output = $("#font-value");
    if (output) output.textContent = `${fontSize}px`;
  };
  $("#font-down")?.addEventListener("click", () => {
    fontSize = Math.max(13, fontSize - 1);
    showFontSize();
  });
  $("#font-up")?.addEventListener("click", () => {
    fontSize = Math.min(24, fontSize + 1);
    showFontSize();
  });
  showFontSize();

  $("#print-sheet")?.addEventListener("click", () => window.print());

  if (notes) {
    if (!storageKey) {
      tell("Esta hoja necesita un identificador antes de guardar notas.");
    } else {
      try {
        const saved = localStorage.getItem(storageKey);
        if (saved !== null) notes.value = saved;
        tell("Notas solo en este navegador. Pulsa Guardar para conservar cambios.");
      } catch {
        tell("El almacenamiento local no está disponible. Puedes escribir y descargar la hoja.");
      }
    }

    $("#save-notes")?.addEventListener("click", () => {
      if (!storageKey) return tell("No se pueden guardar notas sin identificador de canción.");
      try {
        localStorage.setItem(storageKey, notes.value);
        tell("Notas guardadas en este navegador.");
      } catch {
        tell("No se pudieron guardar. Descarga la hoja para conservar tus notas.");
      }
    });

    $("#clear-notes")?.addEventListener("click", () => {
      if (!window.confirm("¿Borrar las notas de esta canción en este navegador?")) return;
      if (!storageKey) return tell("No hay un identificador de canción para borrar notas.");
      try {
        localStorage.removeItem(storageKey);
        notes.value = "";
        tell("Notas de esta canción borradas en este navegador.");
      } catch {
        tell("No se pudieron borrar las notas guardadas.");
      }
    });
  }

  $("#download-sheet")?.addEventListener("click", () => {
    const title = $("#song-title")?.textContent?.trim() || "Hoja musical";
    const credit = $("#song-credit")?.textContent?.trim() || "";
    const sections = $$(".song-section").map((section) => {
      const heading = section.querySelector("h2")?.textContent?.trim() || "";
      const score = section.querySelector("pre")?.textContent?.trimEnd() || "";
      return `${heading}\n${score}`;
    });
    const parts = [title, credit, ...sections];
    if (notes?.value.trim()) parts.push(`Notas personales\n${notes.value.trim()}`);
    const blob = new Blob([parts.filter(Boolean).join("\n\n") + "\n"], { type: "text/plain;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `${(songId || "hoja-musical").replace(/[^a-z0-9_-]/gi, "-")}.txt`;
    document.body.append(link);
    link.click();
    link.remove();
    window.setTimeout(() => URL.revokeObjectURL(url), 1000);
  });
})();
