/* An authored, local ritual preview. No inference, accounts, credits or private storage. */
(function () {
  'use strict';
  document.addEventListener('click', function (event) {
    var link = event.target.closest('[data-enter-world]');
    if (link && window.MVCLWorld) window.MVCLWorld.set(link.dataset.enterWorld);
  });
  var form = document.getElementById('ritual-form');
  if (!form) return;
  var readings = {
    beginnings: {
      title:'Volver a empezar', cards:[['✦','La chispa'],['◇','El umbral'],['↟','Las alas']],
      appears:'Hay comienzos que no se parecen al entusiasmo. Se parecen a hacer espacio, aun sin tener la certeza de que algo vaya a ocuparlo. La chispa invita a distinguir lo que todavía querés de lo que aprendiste a querer para otras personas.',
      tension:'El umbral representa la espera de una autorización perfecta: más tiempo, más seguridad, otra versión de vos. Prepararte puede ayudarte; convertir cada duda en una condición pendiente también puede inmovilizarte. ¿Cuál de las dos cosas está pasando?',
      perspective:'Las alas no son una garantía de éxito. Son una imagen de capacidad en movimiento. Elegí una acción pequeña y reversible que puedas probar esta semana. No necesitás resolver toda tu vida para obtener una primera respuesta del mundo.',
      question:'¿Qué intentarías si no tuvieras que demostrar que ya sabés hacerlo?'
    },
    bonds: {
      title:'Lo que deseo en un vínculo', cards:[['♡','El deseo'],['◈','El espejo'],['☾','La orilla']],
      appears:'El deseo puede pedir cercanía, reconocimiento, juego o descanso. Ponerle nombre evita exigirle a un solo vínculo que lo sea todo. Esta lectura propone mirar qué experiencia buscás, antes de decidir quién tendría que ofrecértela.',
      tension:'El espejo separa lo que observaste de lo que imaginaste. Ninguna carta puede verificar qué siente otra persona. Anotá para vos un hecho concreto y una interpretación: se pueden parecer mucho sin ser lo mismo.',
      perspective:'La orilla es el punto donde podés acercarte sin desaparecer dentro de alguien más. Pensá en una conversación clara, un límite o una invitación. Pedir conexión y conservar tu criterio pueden existir en la misma frase.',
      question:'¿Cómo se vería la reciprocidad en hechos, no solamente en posibilidades?'
    },
    release: {
      title:'Cerrar un ciclo', cards:[['◌','El eco'],['⌁','La grieta'],['☽','La semilla']],
      appears:'El eco representa algo que sigue ocupando espacio aunque ya haya cambiado. Puede ser una costumbre, un proyecto o una expectativa. Reconocer lo que significó no te obliga a mantenerlo intacto.',
      tension:'La grieta propone mirar el costo de sostener una forma que ya no te sirve. No todo malestar exige una ruptura; a veces pide un ajuste, una pausa o una conversación. La diferencia merece tiempo y evidencia, no una sentencia de una carta.',
      perspective:'La semilla no borra lo anterior. Usa lo aprendido para elegir qué cuidar después. Definí una cosa que querés conservar y otra que podés dejar de repetir. Un cierre también puede ser gradual.',
      question:'¿Qué parte de esta historia querés llevar contigo, y cuál ya no necesitás repetir?'
    }
  };
  var chosen = null, revealed = 0;
  var status = document.getElementById('ritual-status');
  var reveal = document.getElementById('ritual-reveal');
  var result = document.getElementById('ritual-result');
  var cards = Array.from(document.querySelectorAll('.ritual-card'));
  form.addEventListener('submit', function (event) {
    event.preventDefault();
    chosen = readings[document.getElementById('ritual-intent').value];
    if (!chosen) return;
    revealed = 0;
    result.hidden = true;
    cards.forEach(function (card) {
      card.classList.remove('revealed');
      card.querySelector('.symbol').textContent = '✧';
      card.querySelector('strong').textContent = 'Por revelar';
    });
    document.getElementById('ritual-table').hidden = false;
    reveal.disabled = false;
    reveal.textContent = 'Revelar el primer símbolo';
    status.textContent = 'Tu intención: ' + chosen.title + '. Tres símbolos, a tu ritmo.';
    reveal.focus();
  });
  reveal.addEventListener('click', function () {
    if (!chosen || revealed >= 3) return;
    var card = cards[revealed], data = chosen.cards[revealed];
    card.querySelector('.symbol').textContent = data[0];
    card.querySelector('strong').textContent = data[1];
    card.classList.add('revealed');
    revealed += 1;
    status.textContent = 'Símbolo ' + revealed + ' de 3: ' + data[1] + '.';
    reveal.textContent = revealed === 1 ? 'Revelar el segundo símbolo' : 'Revelar el tercer símbolo';
    if (revealed === 3) {
      reveal.disabled = true;
      reveal.textContent = 'Lectura revelada';
      document.getElementById('reading-title').textContent = chosen.title;
      ['appears','tension','perspective','question'].forEach(function (key) {
        document.getElementById('reading-' + key).textContent = chosen[key];
      });
      result.hidden = false;
      status.textContent += ' Tu lectura completa está disponible.';
      document.getElementById('reading-title').focus();
    }
  });
  document.getElementById('ritual-save').addEventListener('click', function () {
    if (!chosen || revealed !== 3) return;
    var content = ['MI VIDA COMO LUNA — RITUAL DE MUESTRA', chosen.title,
      'Lectura editorial simbólica; no es una predicción ni una consulta personalizada por IA.',
      chosen.cards.map(function (c) { return c[1]; }).join(' · '),
      'LO QUE APARECE',chosen.appears,'LA TENSIÓN',chosen.tension,
      'OTRA PERSPECTIVA',chosen.perspective,'PARA LLEVARTE',chosen.question].join('\n\n');
    var url = URL.createObjectURL(new Blob([content], {type:'text/plain;charset=utf-8'}));
    var link = document.createElement('a');
    link.href = url; link.download = 'Luna-lectura-de-muestra.txt';
    document.body.appendChild(link); link.click(); link.remove();
    setTimeout(function () { URL.revokeObjectURL(url); }, 1000);
    status.textContent = 'Descarga solicitada. El archivo se guarda en tu dispositivo; no en una cuenta.';
  });
})();
