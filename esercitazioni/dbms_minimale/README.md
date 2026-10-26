# Laboratorio: MiniDB su file binario

## Analisi didattica

L'esercitazione propone la costruzione di un piccolo gestore di record persistenti in C++17. Non vuole imitare SQL: mette invece in evidenza alcuni meccanismi che un DBMS deve realizzare sotto il livello logico, cioè organizzazione fisica dei record, ricerca, vincoli sulla chiave, aggiornamento in posizione, cancellazione logica e recupero dello spazio.

La consegna è calibrata per una quinta ITST informatica in due sessioni da tre ore, assumendo come prerequisiti:

- funzioni, `struct`, cicli e menu testuali;
- stream e file binari di base;
- passaggio di parametri per riferimento;
- compilazione di un programma C++ composto da un solo file.

Le decisioni che mantengono il lavoro entro sei ore sono intenzionali:

- un solo tipo di record (`Libro`) e un solo archivio;
- record a dimensione fissa e stringhe rappresentate con array di `char`;
- ricerca sequenziale, senza indici e senza strutture dati dinamiche obbligatorie;
- interfaccia, acquisizione validata e stampa già disponibili nello starter;
- nessun parser SQL, relazione tra tabelle, concorrenza o formato multipiattaforma;
- cancellazione fisica realizzata come compattazione dell'intero archivio.

Il punto didatticamente più ricco è la distinzione tra:

1. **cancellazione logica**, che modifica sul posto il flag `attivo` e lascia uno slot riutilizzabile;
2. **rimozione fisica**, che copia i soli record attivi in un file temporaneo e sostituisce l'archivio.

Questa distinzione rende visibili costo, frammentazione e necessità di una politica di recupero dello spazio, senza richiedere algoritmi oltre il livello atteso.

## Materiali pronti

- `consegna.html`: testo completo da mostrare o distribuire agli studenti;
- `starter/main.cpp`: progetto iniziale compilabile, con menu e input già realizzati;
- questa guida: note di conduzione e rubrica per il docente.

Compilazione dello starter con GCC/MinGW:

```text
g++ -std=c++17 -Wall -Wextra -pedantic main.cpp -o minidb
```

Su Windows si può usare come nome del file di output `minidb.exe`.

## Scansione consigliata delle 6 ore

### Sessione 1 — persistenza e operazioni di lettura/inserimento

| Tempo | Attività | Esito osservabile |
|---:|---|---|
| 0–20 min | Lettura del problema, analisi del record e del file | Gli studenti sanno spiegare slot, chiave e flag `attivo` |
| 20–45 min | Esame e compilazione dello starter | Menu funzionante, nessun warning nuovo |
| 45–90 min | Elenco e ricerca sequenziale per ID | Archivio inesistente gestito; ricerca corretta |
| 90–140 min | Inserimento con controllo della chiave | Record persistenti e duplicati rifiutati |
| 140–165 min | Inserimento: scansione completa e memorizzazione del primo slot libero | Codice predisposto al riuso, da verificare dopo la cancellazione |
| 165–180 min | Collaudo intermedio e salvataggio | Riavvio del programma senza perdita dei dati |

Checkpoint minimo al termine: inserimento, elenco, ricerca e persistenza devono funzionare. Il riutilizzo degli slot può essere terminato all'inizio della seconda sessione se la classe procede più lentamente.

### Sessione 2 — modifiche, cancellazione e compattazione

| Tempo | Attività | Esito osservabile |
|---:|---|---|
| 0–20 min | Ripresa e correzione dei test della sessione 1 | Base stabile |
| 20–65 min | Modifica sul posto | Cambiano i dati, non cambiano ID e numero di slot |
| 65–105 min | Cancellazione logica, statistiche e verifica del riuso | Il record sparisce; lo slot viene poi riutilizzato |
| 105–145 min | Compattazione con temporaneo e backup | Gli slot cancellati vengono rimossi fisicamente |
| 145–170 min | Sequenza di collaudo obbligatoria | Tutti gli esiti attesi verificati |
| 170–180 min | Breve relazione e consegna | Codice, archivio di prova e relazione |

## Difficoltà prevedibili e interventi

- **Confusione fra modalità di apertura.** Far annotare prima di programmare quali funzioni leggono, quali appendono e quali richiedono `ios::in | ios::out | ios::binary`.
- **Duplicato collocato dopo uno slot libero.** Durante l'inserimento lo studente deve ricordare il primo slot cancellato ma continuare a leggere fino all'EOF; scrivere subito potrebbe creare due ID attivi uguali.
- **Scrittura nel punto sbagliato.** Richiamare la formula `offset = numeroSlot * sizeof(Libro)` e far stampare temporaneamente l'offset trovato.
- **EOF e stato dello stream.** Se lo stesso `fstream` viene riutilizzato dopo una scansione terminata, serve `clear()` prima di `seekp`; è più semplice chiudere e riaprire il file.
- **EOF scambiato per errore.** `read` fallisce anche alla normale fine del file. Per riconoscere un record finale incompleto si può osservare `gcount()`: a EOF regolare non restano byte letti parzialmente.
- **Record cancellati ancora visibili.** Chiedere agli studenti di centralizzare il predicato `record.attivo != 0` in tutte le operazioni di lettura logica.
- **Compattazione fragile.** Pretendere la chiusura di entrambi i file prima di rimuovere o rinominare e usare un breve passaggio tramite `libri.bak`; l'originale non va toccato se la copia temporanea fallisce.
- **Tempo insufficiente.** Conservare come obbligatorie le sette operazioni elencate; soltanto le estensioni finali restano facoltative.

## Rubrica proposta (30 punti)

| Area | Punti | Evidenze |
|---|---:|---|
| Formato e persistenza | 4 | File binario, record fissi, dati presenti dopo il riavvio |
| Elenco e ricerca | 5 | Solo record attivi, ID assente gestito correttamente |
| Inserimento | 5 | Validazione, chiave attiva univoca, riuso di uno slot o append |
| Modifica | 4 | Scrittura in posizione senza alterare chiave e flag |
| Cancellazione logica | 3 | Flag aggiornato; record non più visibile |
| Compattazione | 4 | Copia dei soli attivi e sostituzione controllata del file |
| Robustezza e qualità | 3 | Errori di apertura gestiti, funzioni coese, niente duplicazione rilevante |
| Collaudo e relazione | 2 | Sequenza richiesta documentata e risultati coerenti |

Soglia suggerita: 18/30. Un programma che memorizza tutto solo in memoria non raggiunge la sufficienza, perché manca l'obiettivo centrale della persistenza.

La chiave è univoca fra i record attivi: dopo una cancellazione logica lo stesso ID può essere inserito nuovamente. È utile dichiarare questa scelta prima dell'avvio del lavoro, perché entrambe le politiche sarebbero possibili in un sistema reale.

## Varianti

Per una classe che usa il C, la stessa traccia resta valida sostituendo `fstream` con `FILE*`, `read/write` con `fread/fwrite` e `seekg/seekp` con `fseek`. Conviene però predisporre uno starter C separato: far tradurre anche tutta l'interfaccia sottrarrebbe tempo agli obiettivi sui file.

Per una classe molto rapida, le estensioni più coerenti sono esportazione CSV, ricerca parziale case-insensitive e creazione di un piccolo indice secondario `ID → offset`. Non è consigliato rendere queste parti obbligatorie nelle sei ore.
