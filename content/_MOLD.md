---
# ─────────────────────────────────────────────────────────────────────────────
#  EL MOLDE — plantilla de bloque · mividacomoluna.com
#  Copiar este archivo para crear un bloque. NO editar el molde con contenido.
#
#  Regla: este front-matter ES el esquema de la futura tabla. Cada campo de acá
#  es una columna después. El body es el TEXT/CLOB. Cuando pasemos a BD, esto se
#  levanta mecánicamente — por eso los campos existen HOY aunque no se usen aún.
#
#  Camino: .md (ahora) → BD (después) → calls por sar1a.lempyra.com (después).
#  Nada de esto se publica: `content/` es fuente, `docs/` es lo publicado.
# ─────────────────────────────────────────────────────────────────────────────

# ── identidad ────────────────────────────────────────────────────────────────
id:        ruta-00-slug         # PK estable. Nunca se reusa, nunca se renumera.
route:     /ruta/               # dónde renderiza. Debe existir en docs/.
order:     0                    # los bloques suben: 0 es el más viejo, abajo.
lang:      es

# ── qué es ───────────────────────────────────────────────────────────────────
title:     ""
subtitle:  ""
kind:      story                # story · terminal · product · lesson · entity
status:    draft                # draft → canon (canon = L lo aprobó)
updated:   2026-07-30

# ── gobernanza [0] ───────────────────────────────────────────────────────────
# Etiqueta epistémica. El runtime las distingue visualmente y NUNCA deja que una
# se convierta en otra. Ficción = METAFORA. Un bloque que afirma algo del mundo
# real (producto, zodiaco, lección) necesita fuentes Y falsador, o no publica.
label:     METAFORA             # DATO · INFERENCIA · HIPOTESIS · METAFORA · DESCONOCIDO
sources:   []
falsifier: ""                   # vacío SOLO si label es METAFORA pura

# ── acceso: humano y agente son dos puertas distintas ────────────────────────
# El muro de login dice "probá que sos humano". x402 dice "probá que pagaste".
# Un bot puede lo segundo, no lo primero. Por eso hay dos carriles, no uno.
access:
  human:   public               # public · account · paid
  agent:   x402                 # free · x402 · denied
  price:
    amount:   0
    currency: USD
    unit:     block             # block · route · corpus

# ── superficie legible por máquina ───────────────────────────────────────────
# Esto es lo que un agente compra/previsualiza antes de pagar la entrada.
# Escribirlo bien es el producto, no metadata de relleno.
audience:    [human, agent]
summary:     ""                 # una línea. Qué pasa acá.
keywords:    []
entities:    []                 # [luna, L, IO, ...] — quién/dónde aparece
canon_state: ""                 # el DELTA: qué queda siendo verdad después de este bloque
---

## Cuerpo

Un solo cuerpo, en prosa. **No se escribe dos veces** — una versión "para humanos" y otra
"para IAs" garantizan deriva entre las dos, y la deriva es la que después contradice el canon.

Lo que una IA necesita de más no es otra prosa: es **estructura y procedencia** — y eso ya está
arriba, en `entities`, `canon_state`, `label` y `summary`. La misma prosa, mejor enmarcada.

Escribir para que las dos lecturas ganen: concreto, sin adorno hueco, con los nombres propios
dichos (no "él", sino quién), y con el cambio de estado explícito. Eso es lo que hace un texto
navegable para un modelo — y, casualmente, también lo que lo hace bueno para una persona.
