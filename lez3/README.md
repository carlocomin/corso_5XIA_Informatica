# Lezione 3 — Algebra relazionale

Il modulo si colloca fra la traduzione E-R/relazionale (lezione 2) e PHP/MySQL (lezione 4).
L'ingresso è [lez3_1.html](lez3_1.html).

## Struttura didattica

- 1–2: introduzione, scopo, storia, lessico, notazione e database guida.
- 3–8: selezione, proiezione, rinomina, prodotto cartesiano, unione, differenza e intersezione derivata.
- 9–11: inner, theta, equi, natural, left, right e full outer join.
- 12: metodo di risoluzione ed equivalenze con le loro condizioni.
- 13–14: 8 esempi easy (E1–E8).
- 15–16: 8 esempi medium (M1–M8).
- 17–19: 6 esempi hard (H1–H6).
- 20: riepilogo, errori comuni e 3 esercizi aggiuntivi con soluzione.

Ogni interrogazione svolta contiene domanda, passaggi motivati, espressione algebrica,
tabella completa del risultato e un controllo sui casi problematici.
Le soluzioni sono in pannelli apribili con HTML details, funzionanti anche senza JavaScript.

## Prerequisiti e convenzioni

Gli studenti devono conoscere schema, istanza, dominio, tupla, chiavi e chiavi esterne.
La pagina 2 riprende il lessico e mantiene disponibili tutte le istanze del database guida.
Le formule usano parametri fra parentesi quadre, equivalenti ai tradizionali pedici:
σ[condizione](R), π[attributi](R), ρ[Nuovo ← Vecchio](R).

Si usa algebra classica su insiemi senza duplicati e senza ordine delle tuple.
Unione, differenza e intersezione richiedono identici nomi di attributo e domini coerenti.
Gli outer join sono esplicitamente presentati come estensione con NULL.
Gli operatori di aggregazione e divisione non sono prerequisiti: le soglie fisse e il
“per tutti” vengono ricostruiti con copie rinominate, prodotto e differenza.

## Progressione consigliata

La lezione è un modulo articolato, non un singolo incontro. Una possibile scansione è:
1. fondamenti, dati e operatori unari;
2. prodotto, operatori insiemistici ed esempi easy;
3. famiglie di join ed esempi medium;
4. metodo per “non”, “tutti”, “soltanto”, self-join e problemi hard.

I problemi hard vanno affrontati dopo che gli studenti sanno verificare gli schemi
intermedi; si possono assegnare gradualmente come consolidamento.
La durata va adattata al tempo dedicato al lavoro autonomo.

## Dati e verifiche

Il database guida comprende 7 studenti, 5 corsi e 13 iscrizioni.
Contiene volutamente due studentesse omonime, uno studente senza iscrizioni, un corso
senza iscritti, un'insufficienza e un massimo a pari merito.
I 22 risultati sono stati calcolati con operatori insiemistici e confrontati con
risultati attesi espliciti. La cardinalità di ogni risultato è riportata nelle slide.

Le fonti primarie e didattiche sono collegate nelle pagine 1, 11 e 20.
Non sono richieste librerie esterne o accesso Internet per leggere le slide.
