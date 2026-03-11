# Pianificazione operativa degli interventi sulle slide

## Scopo del documento

Questo file non e piu una diagnosi generale del corso. Da qui in avanti diventa la roadmap operativa degli interventi che implementero sulle slide.

Obiettivo:

- aumentare chiarezza, coerenza e continuita didattica
- non introdurre teoria nuova non necessaria
- mantenere il rigore del corso
- rendere il modulo 3 una vera introduzione a PHP fortemente centrata anche su MySQL e prepared statements
- restare entro un livello adatto a una quinta ITST Informatica

## Vincoli didattici che guideranno le modifiche

### Livello atteso

Il corso deve restare:

- introduttivo sul piano operativo
- rigoroso sul piano concettuale
- accessibile senza richiedere strumenti o pattern professionali avanzati

### Cosa rafforzero nel modulo 3

- flusso richiesta -> PHP -> MySQL -> risposta HTML
- connessione PDO di base
- query semplici
- prepared statements
- lettura da form
- validazione essenziale
- inserimento e visualizzazione dati

### Cosa non portero al centro del modulo 3

- architetture MVC
- ORM
- routing avanzato
- gestione avanzata delle sessioni
- transazioni complesse
- sicurezza avanzata oltre le basi didattiche
- tecniche troppo professionali per il livello della classe

## Principi editoriali da applicare prima di tutto

Questi principi verranno implementati in tutto il corso prima o durante le revisioni di modulo.

### 1. Struttura fissa delle slide dense

Dove possibile, ogni slide teorica o mista seguira questa scansione:

1. problema o domanda iniziale
2. idea intuitiva
3. definizione o regola
4. esempio minimo
5. errore tipico o avvertenza
6. esito operativo: cosa lo studente deve saper fare

### 2. Distinzione costante tra piani diversi

Rendero piu esplicito quando una frase appartiene a:

- modello teorico
- traduzione logica
- SQL / DBMS reale
- scelta progettuale pratica

### 3. Riduzione del carico cognitivo

Interverro per:

- separare contenuti centrali da approfondimenti
- evitare troppi cambi di esempio nella stessa sequenza
- ridurre blocchi che fondono definizione, eccezione e implementazione nello stesso punto

### 4. Raccordi piu visibili

Ogni modulo dovra far capire meglio:

- da dove arriva
- cosa sta consolidando
- cosa prepara nel modulo successivo

## Ordine operativo di implementazione

L'implementazione non verra fatta modulo per modulo nell'ordine numerico puro. Seguiro invece l'ordine di impatto didattico.

## Fase 1 — Riallineamento globale del corso

### Obiettivo

Rendere coerente la promessa del corso prima di intervenire nel dettaglio delle singole slide.

### Interventi

- aggiornare il tono e la funzione di `programma.html`
- chiarire nei moduli introduttivi cosa e concettuale, cosa e logico, cosa e implementativo
- fissare un lessico uniforme per `schema`, `istanza`, `vincolo`, `traduzione`, `implementazione`

### Output atteso

- percorso piu leggibile gia dal menu del corso
- minore ambiguita sui passaggi tra moduli

## Fase 2 — Revisione prioritaria del modulo 3

Questo e il blocco da correggere per primo, perche oggi e quello con la maggiore distanza tra promessa didattica e sviluppo reale.

### Obiettivo generale del modulo 3 dopo la revisione

Il modulo 3 dovra raccontare una progressione molto chiara:

1. come funziona una richiesta web
2. come si scrive PHP di base
3. come PHP riceve dati da form
4. come PHP si collega a MySQL
5. come si eseguono query semplici con prepared statements
6. come si mostra il risultato in HTML

### Strategia operativa sul modulo 3

- mantenere PHP come asse principale
- usare MySQL non come appendice, ma come applicazione costante dei costrutti PHP di base
- evitare di trasformare il modulo in un corso backend avanzato

### Interventi slide per slide

#### `lez3_1` — Obiettivi e percorso

Intervento:

- riscrivere la promessa del modulo in modo piu preciso
- dichiarare esplicitamente che il focus e: PHP base + interazione essenziale con MySQL
- eliminare promesse troppo grandi o troppo vaghe

Esito atteso:

- aspettativa corretta fin dall'inizio

#### `lez3_2` — Ripasso e flusso richiesta/risposta

Intervento:

- ridurre il peso dei dettagli generali su TCP/HTTPS se non sono direttamente funzionali al modulo
- mettere al centro il percorso concreto del dato:
  browser -> form -> PHP -> MySQL -> HTML
- chiudere la slide con una mini-mappa mentale di tutto il modulo

Esito atteso:

- la slide diventa un vero ponte verso il lavoro pratico, non un ripasso troppo dispersivo

#### `lez3_3` — Setup ambiente

Intervento:

- mantenere solo i dettagli di setup strettamente utili
- rendere molto chiaro il risultato finale richiesto:
  server attivo, database creato, utente dedicato, connessione PDO funzionante
- segnalare che PDO e lo strumento base che useremo nel resto del modulo

Esito atteso:

- lo studente capisce che il setup non e fine a se stesso ma prepara il lavoro con query e prepared statements

#### `lez3_4` — Primo script PHP

Intervento:

- mantenere la natura introduttiva
- collegare subito il concetto di output dinamico al fatto che in seguito i dati potranno arrivare anche dal database
- rafforzare la separazione tra logica PHP e markup HTML

Esito atteso:

- il primo script PHP non appare isolato, ma come base del rendering di dati reali

#### `lez3_5` — Sintassi base e tipi

Intervento:

- semplificare i blocchi troppo carichi
- privilegiare esempi collegati a input form, valori numerici da salvare, dati da mostrare in pagina
- ridurre la dispersione tra molti micro-concetti nello stesso flusso

Esito atteso:

- la sintassi di base viene percepita come strumento per trattare dati applicativi concreti

#### `lez3_6` — Datatype e array

Intervento:

- tenere gli array come struttura centrale per capire risultati di query, righe, profili, liste di record
- alleggerire dove il confronto con altri linguaggi diventa troppo esteso rispetto all'obiettivo del modulo
- rendere esplicito l'uso degli array in preparazione a fetch di dati dal DB

Esito atteso:

- gli array non sono solo teoria di linguaggio, ma preparazione alla manipolazione dei dati SQL

#### `lez3_7` — Funzioni utili sugli array

Intervento:

- riposizionare gli esempi in chiave pratica: elaborare risultati, pulire input, trasformare dati da mostrare
- far capire quando usare queste funzioni dentro script che leggono o mostrano dati

Esito atteso:

- la slide diventa strumento di lavoro sul dato, non semplice catalogo di utility

#### `lez3_8` — Esercizi PHP

Intervento:

- declassare la slide da nodo centrale del percorso a laboratorio o appendice di esercitazione
- lasciare gli esercizi piu coerenti col percorso web e dati
- valutare di alleggerire o marginalizzare quelli troppo scollegati dall'asse PHP + MySQL

Esito atteso:

- il modulo non perde continuita narrativa

#### `lez3_9` — Superglobali

Intervento:

- riorganizzare la slide per famiglie funzionali:
  input, upload, contesto, cookie, sessione
- enfatizzare molto di piu `$_GET`, `$_POST` e validazione minima, che sono il ponte diretto verso le query parametrizzate
- mantenere il resto come completamento, non come centro

Esito atteso:

- la slide diventa una preparazione naturale all'inserimento dati nel database

#### `lez3_10` — Funzioni fondamentali

Intervento:

- legare le funzioni a compiti tipici del modulo:
  validare un input, formattare un dato, creare una funzione di supporto per il DB
- ridurre gli esempi troppo generici se non aiutano il filo del modulo

Esito atteso:

- la nozione di funzione viene connessa a piccoli strumenti riusabili di una web app didattica

#### `lez3_11` — Funzioni approfondimento

Intervento:

- mantenere solo gli approfondimenti utili a livello quinta ITST
- lasciare type hinting e ritorni tipizzati come estensione utile
- tenere closure e arrow function in posizione secondaria, come cultura utile ma non asse centrale
- chiudere il modulo con una sintesi esplicita che riconnetta:
  form, input, PHP, funzioni, PDO, query parametrizzate, output HTML

Esito atteso:

- il modulo 3 si chiude su una competenza concreta, non su un semplice elenco di funzionalita del linguaggio

### Correzione strutturale specifica sul contenuto MySQL

Durante la revisione del modulo 3 implementero un riallineamento forte:

- ogni 2-3 slide dovra ricomparire il legame con MySQL
- i prepared statements dovranno essere presentati come pratica base e non come approfondimento opzionale
- gli esempi dovranno arrivare almeno a:
  connessione
  SELECT base
  INSERT base da form
  visualizzazione del risultato in HTML

Questo senza introdurre complessita eccessiva.

## Fase 3 — Revisione del modulo 1

Il modulo 1 e solido, ma va reso piu leggibile nel ritmo.

### Obiettivo

Ridurre la densita iniziale senza perdere il rigore formale che caratterizza il corso.

### Interventi

#### `lez1_1`

- rendere il contesto storico piu funzionale all'idea di svolta del modello relazionale
- spostare il focus dalla cronologia al problema risolto

#### `lez1_2`

- separare meglio i nuclei:
  relazione, schema, istanza, proprieta, NULL
- segnalare piu chiaramente quando si esce dal modello puro

#### `lez1_3`

- uniformare la presentazione dei vincoli:
  definizione naturale, formula, esempio, conseguenza

#### `lez1_4`

- mantenere il cuore teorico sulle chiavi
- contenere o etichettare piu chiaramente i criteri pratici avanzati di scelta della PK

#### `lez1_5`

- separare meglio la definizione di FK dal comportamento operativo del DBMS

#### `lez1_6`

- trasformarla in una vera chiusura del modulo:
  perche il relazionale distingue logico e fisico e perche questo conta

### Esito atteso

- ingresso piu graduale nel formalismo
- miglior ponte verso E-R e progettazione logica

## Fase 4 — Revisione del modulo 2

Il modulo 2 ha una buona sequenza, ma alcune slide sono troppo dense e anticipano troppo.

### Obiettivo

Rendere piu lineare il passaggio:

- dal dominio reale al modello concettuale
- dal modello concettuale alla traduzione relazionale

### Interventi

#### `lez2_1`

- rafforzare il collegamento esplicito con il modulo 1

#### `lez2_2`

- separare meglio entita, attributi e chiavi

#### `lez2_3`

- chiarire in modo piu netto cardinalita vs partecipazione

#### `lez2_4`

- mettere al centro il concetto di identita dipendente

#### `lez2_5`

- alleggerire una slide oggi troppo carica
- tenere la preview di traduzione solo come richiamo finale breve

#### `lez2_6`

- stabilizzare le nozioni `disgiunta/sovrapposta` e `totale/parziale`
- migliorare la leggibilita del loro impatto progettuale

#### `lez2_7`

- spezzare meglio il percorso interno
- chiarire continuamente quali vincoli sono direttamente traducibili e quali no

### Esito atteso

- minor carico cognitivo
- migliore preparazione al modulo 4

## Fase 5 — Revisione del modulo 4

Il modulo 4 e gia il piu robusto sul piano logico. Qui l'obiettivo non e cambiare il contenuto, ma rafforzarne la memorizzazione e la leggibilita.

### Obiettivo

Inserire segnaletica didattica piu forte in una sequenza lunga e astratta.

### Interventi

#### `lez4_1` -> `lez4_3`

- chiudere la mini-sequenza con una sintesi operativa chiara su `X+`

#### `lez4_4` -> `lez4_6`

- rendere piu procedurale la logica della copertura minimale
- stabilizzare checklist e ordine dei test

#### `lez4_7` -> `lez4_10`

- rendere piu visibile la funzione specifica di ogni slide della decomposizione

#### `lez4_11` -> `lez4_13`

- rafforzare il contrasto tra 2NF e 3NF

#### `lez4_14` -> `lez4_16`

- chiudere con una sintesi forte di:
  3NF, BCNF, lossless join, dependency preservation

### Esito atteso

- modulo piu facile da seguire senza indebolire il rigore

## Sequenza concreta di implementazione nei file

L'ordine effettivo di lavoro sara questo:

1. `programma.html`
2. `lez3_1.html`
3. `lez3_2.html`
4. `lez3_3.html`
5. `lez3_4.html`
6. `lez3_5.html`
7. `lez3_6.html`
8. `lez3_7.html`
9. `lez3_8.html`
10. `lez3_9.html`
11. `lez3_10.html`
12. `lez3_11.html`
13. `lez1_1.html`
14. `lez1_2.html`
15. `lez1_3.html`
16. `lez1_4.html`
17. `lez1_5.html`
18. `lez1_6.html`
19. `lez2_1.html`
20. `lez2_2.html`
21. `lez2_3.html`
22. `lez2_4.html`
23. `lez2_5.html`
24. `lez2_6.html`
25. `lez2_7.html`
26. `lez4_1.html`
27. `lez4_2.html`
28. `lez4_3.html`
29. `lez4_4.html`
30. `lez4_5.html`
31. `lez4_6.html`
32. `lez4_7.html`
33. `lez4_8.html`
34. `lez4_9.html`
35. `lez4_10.html`
36. `lez4_11.html`
37. `lez4_12.html`
38. `lez4_13.html`
39. `lez4_14.html`
40. `lez4_15.html`
41. `lez4_16.html`

## Criteri di verifica durante l'implementazione

Dopo ogni blocco di lavoro controllero che:

- il titolo dica davvero cosa la slide fa imparare
- l'idea centrale sia visibile entro i primi elementi della slide
- gli approfondimenti non oscurino il contenuto base
- i cambi di livello siano espliciti
- il modulo 3 resti concretamente ancorato a MySQL e prepared statements di base
- il livello resti adatto a una quinta ITST

## Esito finale atteso

Dopo l'implementazione, il corso dovra risultare:

- piu continuo tra moduli
- piu leggibile nelle slide dense
- piu coerente nelle promesse didattiche
- piu forte nel collegare teoria, modellazione e pratica
- piu efficace nel modulo PHP/MySQL senza diventare avanzato

## Nota operativa finale

La prossima attivita non sara piu ridefinire il piano. Sara iniziare l'implementazione effettiva di questa sequenza di interventi, partendo dal riallineamento globale e poi dal modulo 3.
