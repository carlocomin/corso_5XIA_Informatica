$ErrorActionPreference = 'Stop'

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$commonStyle = @'
    .box{background:var(--panel,#fff);border-radius:12px;padding:12px;box-shadow:0 2px 6px rgba(0,0,0,.08);margin-bottom:14px}
    .note{background:#f7faff;border-left:4px solid #3b82f6;padding:.6rem .8rem;border-radius:8px;margin:.35rem 0;display:inline-block}
    .warn{background:#fff7ed;border-left:4px solid #f59e0b;padding:.6rem .8rem;border-radius:8px;margin:.35rem 0;display:inline-block}
    .ok{background:#eefbf1;border-left:4px solid #22c55e;padding:.6rem .8rem;border-radius:8px;margin:.35rem 0;display:inline-block}
    .inner-box, .inner-box p, .inner-box ul, .inner-box ol, .inner-box li, .inner-box pre, .inner-box code{ text-align:left !important; }
    .inner-box ul, .inner-box ol{ margin:.5rem 0 .75rem 1rem; padding-left:1.25rem; list-style-position:outside; }
    pre{ white-space:pre; tab-size:4; margin:0 0 1rem 0; padding:.5rem .75rem; }
    pre code{ display:block; text-align:left !important; }
    table{ width:100%; border-collapse:collapse; }
    th,td{ border-bottom:1px solid #e5e7eb; padding:.45rem .5rem; vertical-align:top; text-align:left; }
    th{ background:#f8fafc; }
    .def{font-weight:600}
'@

$slides = @(
    @{
        Num = 1
        Menu = 'Lez5.1: Introduzione e obiettivi'
        Title = 'Introduzione e obiettivi'
        H1 = 'Transazioni concorrenti: perché servono e perché sono difficili'
        Body = @'
        <h2>Perché questo modulo</h2>
        <div class="box">
          <p>Nei moduli precedenti abbiamo studiato <strong>schema</strong>, <strong>vincoli</strong>, <strong>SQL</strong> e <strong>normalizzazione</strong>. Ora aggiungiamo una dimensione nuova: <strong>il tempo di esecuzione</strong>.</p>
          <p class="note">Una base di dati può essere progettata bene e interrogata bene, ma produrre comunque errori se più utenti agiscono nello stesso momento.</p>
          <p>Non basta quindi sapere <em>quali dati</em> conservare o <em>quale query</em> eseguire: bisogna capire anche <strong>come il sistema coordina più operazioni concorrenti</strong>.</p>
        </div>

        <h2>Cosa saprai fare alla fine</h2>
        <div class="box">
          <ul>
            <li>Riconoscere le principali <strong>anomalie delle transazioni concorrenti</strong>.</li>
            <li>Capire l'idea di <strong>schedule corretto</strong> e di <strong>serializzabilità</strong>.</li>
            <li>Spiegare il ruolo di <strong>lock</strong>, <strong>2PL</strong> e <strong>livelli di isolamento</strong>.</li>
            <li>Collegare la teoria al comportamento reale di <strong>PostgreSQL</strong> e <strong>MySQL/InnoDB</strong>.</li>
          </ul>
        </div>

        <h2>Sequenza della lezione</h2>
        <div class="box">
          <ol>
            <li>Perché la concorrenza è necessaria.</li>
            <li>Quali errori può produrre.</li>
            <li>Come si formalizza la correttezza.</li>
            <li>Come il DBMS cerca di garantirla in pratica.</li>
          </ol>
          <p class="ok">L'idea chiave sarà sempre la stessa: <strong>parallelismo sì, incoerenza no</strong>.</p>
          <p class="note">La sequenza è voluta: prima l'intuizione pratica, poi la teoria, infine i meccanismi concreti usati dai DBMS.</p>
        </div>
'@
    }
    @{
        Num = 2
        Menu = 'Lez5.2: Da dove arriviamo'
        Title = 'Da dove arriviamo'
        H1 = 'Dal modello relazionale all''esecuzione corretta nel tempo'
        Body = @'
        <h2>Richiamo dei moduli precedenti</h2>
        <div class="box">
          <ul>
            <li>Nel <strong>modulo 1</strong> abbiamo visto tabelle, chiavi e vincoli del modello relazionale.</li>
            <li>Nel <strong>modulo 2</strong> abbiamo modellato il dominio con E-R.</li>
            <li>Nel <strong>modulo 3</strong> abbiamo usato SQL e MySQL in un flusso applicativo.</li>
            <li>Nel <strong>modulo 4</strong> abbiamo studiato dipendenze e normalizzazione.</li>
          </ul>
        </div>

        <h2>Il nuovo problema</h2>
        <div class="box">
          <p>Finora abbiamo ragionato soprattutto su <strong>struttura</strong> e <strong>significato</strong> dei dati.</p>
          <p>Ora dobbiamo ragionare anche su <strong>come le operazioni si eseguono nel tempo</strong>, quando più utenti leggono e modificano la stessa base di dati.</p>
          <p class="warn">Una query corretta, da sola, non basta a garantire una esecuzione concorrente corretta.</p>
          <p>Il problema si sposta quindi dal solo livello logico al comportamento complessivo del sistema mentre più transazioni sono attive.</p>
        </div>

        <h2>Domanda-guida</h2>
        <div class="box">
          <p><strong>Quando due transazioni concorrenti producono un risultato equivalente a una esecuzione corretta "una dopo l'altra"?</strong></p>
          <p class="note">Questa domanda porta alle anomalie, agli schedule e ai meccanismi di controllo della concorrenza.</p>
        </div>
'@
    }
    @{
        Num = 3
        Menu = 'Lez5.3: Perché serve la concorrenza'
        Title = 'Perché la concorrenza è necessaria'
        H1 = 'Un DBMS non può lavorare una richiesta per volta'
        Body = @'
        <h2>Molti utenti, molte richieste</h2>
        <div class="box">
          <p>Un DBMS reale serve contemporaneamente <strong>più applicazioni</strong>, <strong>più utenti</strong> e <strong>più processi</strong>.</p>
          <p>Le richieste possono arrivare in numero elevato: il carico viene spesso misurato in <strong>transazioni per secondo</strong>.</p>
        </div>

        <h2>Perché non basta l'esecuzione seriale</h2>
        <div class="box">
          <ul>
            <li>Eseguire ogni transazione solo dopo la precedente ridurrebbe troppo il <strong>throughput</strong>.</li>
            <li>I tempi di risposta diventerebbero troppo alti.</li>
            <li>Molte risorse del sistema resterebbero inutilizzate in attesa.</li>
          </ul>
          <p class="ok">La concorrenza serve quindi ad aumentare efficienza e reattività.</p>
          <p class="note">L'obiettivo non è "fare tutto in parallelo", ma usare il parallelismo quando possibile senza compromettere il significato corretto delle operazioni.</p>
        </div>

        <h2>Il prezzo della concorrenza</h2>
        <div class="box">
          <p class="warn">Se le operazioni concorrenti non sono controllate, i dati possono diventare incoerenti.</p>
          <p class="note">Il problema non è fare le cose in parallelo, ma farle in parallelo <strong>senza cambiare il risultato corretto</strong>.</p>
        </div>
'@
    }
    @{
        Num = 4
        Menu = 'Lez5.4: Che cos''è una transazione'
        Title = 'Che cos''è una transazione'
        H1 = 'Transazione = unità logica di lavoro'
        Body = @'
        <h2>Definizione intuitiva</h2>
        <div class="box">
          <p>Una <strong>transazione</strong> è una sequenza di operazioni che deve essere considerata come un'unica unità logica di lavoro.</p>
          <p class="ok">O tutte le operazioni vanno a buon fine, oppure il sistema deve annullarne gli effetti.</p>
          <p>Questo accade perché molte operazioni applicative non hanno senso se vengono eseguite solo "a metà".</p>
        </div>

        <h2>Esempio: trasferimento di denaro</h2>
        <div class="box">
<pre><code class="language-sql">START TRANSACTION;
UPDATE account SET saldo = saldo - 100 WHERE id = 10;
UPDATE account SET saldo = saldo + 100 WHERE id = 19;
COMMIT;</code></pre>
          <p>Le due istruzioni rappresentano un'unica operazione logica: <strong>spostare 100 euro</strong> da un conto all'altro.</p>
        </div>

        <h2>Perché è una vera unità</h2>
        <div class="box">
          <ul>
            <li>Se si esegue solo il prelievo, i dati diventano scorretti.</li>
            <li>Se si esegue solo l'accredito, i dati diventano scorretti.</li>
            <li>Il sistema deve garantire il comportamento <strong>tutto o niente</strong>.</li>
          </ul>
          <p class="note">Una transazione quindi non è un semplice gruppo di query, ma un blocco con un significato applicativo unitario.</p>
        </div>
'@
    }
    @{
        Num = 5
        Menu = 'Lez5.5: Proprietà ACID'
        Title = 'Proprietà ACID'
        H1 = 'Le quattro proprietà fondamentali delle transazioni'
        Body = @'
        <h2>Atomicità e consistenza</h2>
        <div class="box">
          <p><span class="def">Atomicità</span>: la transazione è indivisibile, quindi i suoi effetti sono tutti visibili oppure tutti annullati.</p>
          <p><span class="def">Consistenza</span>: se la base di dati è consistente prima della transazione, deve esserlo anche dopo la sua conclusione corretta.</p>
          <p class="note">La consistenza riguarda il rispetto dei vincoli del sistema: chiavi, vincoli di dominio, integrità referenziale e regole applicative.</p>
        </div>

        <h2>Isolamento e persistenza</h2>
        <div class="box">
          <p><span class="def">Isolamento</span>: ogni transazione deve comportarsi come se stesse lavorando da sola.</p>
          <p><span class="def">Persistenza</span>: dopo il commit gli effetti non devono andare perduti, anche in presenza di guasti.</p>
          <p class="note">L'isolamento è la proprietà che rende necessario il controllo della concorrenza: senza isolamento, le transazioni si disturbano a vicenda.</p>
        </div>

        <h2>Focus della lezione</h2>
        <div class="box">
          <p class="note">In questo modulo ci concentreremo soprattutto sulla proprietà di <strong>isolamento</strong>, cioè sul controllo delle interferenze tra transazioni concorrenti.</p>
        </div>
'@
    }
    @{
        Num = 6
        Menu = 'Lez5.6: COMMIT, ROLLBACK, autocommit'
        Title = 'COMMIT, ROLLBACK e autocommit'
        H1 = 'Quando una transazione conferma o annulla i suoi effetti'
        Body = @'
        <h2>Le due operazioni fondamentali</h2>
        <div class="box">
          <ul>
            <li><code>COMMIT</code>: segnala che la transazione è andata a buon fine e rende definitivi i cambiamenti.</li>
            <li><code>ROLLBACK</code>: annulla gli effetti prodotti dalla transazione.</li>
          </ul>
        </div>

        <h2>Sessione SQL minima</h2>
        <div class="box">
<pre><code class="language-sql">START TRANSACTION;
UPDATE R SET B = 'z';
ROLLBACK;

START TRANSACTION;
INSERT INTO R(A,B) VALUES (10,'x');
COMMIT;</code></pre>
          <p class="note">Dopo il rollback, il primo aggiornamento non deve lasciare tracce permanenti.</p>
        </div>

        <h2>Attenzione all'autocommit</h2>
        <div class="box">
          <p>Molti DBMS lavorano di default in <strong>autocommit mode</strong>: ogni istruzione viene confermata automaticamente.</p>
          <p class="warn">Se vogliamo ragionare davvero su una transazione composta da più istruzioni, l'autocommit va gestito con attenzione.</p>
          <p>Dal punto di vista didattico questo è decisivo: se ogni query fa commit da sola, perdiamo proprio l'idea di blocco unitario formato da più passi.</p>
        </div>
'@
    }
    @{
        Num = 7
        Menu = 'Lez5.7: Il problema centrale'
        Title = 'Il problema centrale'
        H1 = 'Le transazioni concorrenti si intrecciano'
        Body = @'
        <h2>Dal codice alle operazioni elementari</h2>
        <div class="box">
          <p>Dal punto di vista teorico, una transazione può essere vista come una sequenza di <strong>letture</strong> e <strong>scritture</strong>.</p>
          <p>Quando due transazioni sono concorrenti, queste operazioni possono <strong>alternarsi</strong>.</p>
        </div>

        <h2>Perché nasce il rischio</h2>
        <div class="box">
          <ul>
            <li>Una transazione può leggere dati modificati da un'altra.</li>
            <li>Una scrittura può sovrascrivere un risultato ancora non stabilizzato.</li>
            <li>Un'analisi può essere fatta su una base di dati che cambia "sotto i piedi".</li>
          </ul>
          <p class="note">Le singole operazioni possono essere corrette prese una per una, ma l'intreccio complessivo può comunque produrre un risultato sbagliato.</p>
        </div>

        <h2>Passo successivo</h2>
        <div class="box">
          <p class="ok">Prima di definire cosa è corretto, vediamo cosa può andare storto: le <strong>anomalie della concorrenza</strong>.</p>
        </div>
'@
    }
    @{
        Num = 8
        Menu = 'Lez5.8: Panoramica delle anomalie'
        Title = 'Panoramica delle anomalie'
        H1 = 'Che cosa può andare storto'
        Body = @'
        <h2>Le anomalie principali</h2>
        <div class="box">
          <table>
            <thead>
              <tr><th>Anomalia</th><th>Idea di base</th></tr>
            </thead>
            <tbody>
              <tr><td>Perdita di aggiornamento</td><td>un aggiornamento corretto viene sovrascritto da un altro</td></tr>
              <tr><td>Lettura sporca</td><td>si legge un dato scritto da una transazione non ancora confermata</td></tr>
              <tr><td>Lettura inconsistente</td><td>lo stesso dato letto due volte produce risultati diversi</td></tr>
              <tr><td>Aggiornamento fantasma</td><td>una analisi aggregata usa dati cambiati durante il calcolo</td></tr>
              <tr><td>Inserimento fantasma</td><td>tra due letture compaiono nuovi record che soddisfano un predicato</td></tr>
            </tbody>
          </table>
        </div>

        <h2>Idea comune</h2>
        <div class="box">
          <p class="warn">In tutti i casi, il problema nasce dal fatto che una transazione non vede la base di dati in modo stabile e isolato.</p>
          <p>Le anomalie hanno nomi diversi, ma raccontano tutte la stessa difficoltà: mantenere una visione coerente dei dati mentre altre transazioni stanno lavorando.</p>
        </div>
'@
    }
    @{
        Num = 9
        Menu = 'Lez5.9: Perdita di aggiornamento'
        Title = 'Perdita di aggiornamento'
        H1 = 'Due aggiornamenti corretti localmente, risultato globale sbagliato'
        Body = @'
        <h2>Scenario</h2>
        <div class="box">
          <p>Supponiamo che <code>x = 2</code> e che due transazioni vogliano entrambe incrementare <code>x</code> di 1.</p>
<pre><code class="language-text">T1: r(x), x := x + 1, w(x)
T2: r(x), x := x + 1, w(x)</code></pre>
        </div>

        <h2>Interleaving scorretto</h2>
        <div class="box">
<pre><code class="language-text">T1: r1(x)   legge 2
T2: r2(x)   legge 2
T2: w2(x)   scrive 3
T1: w1(x)   scrive 3</code></pre>
          <p>Il valore finale è <code>3</code>, ma in una esecuzione seriale corretta dovrebbe essere <code>4</code>.</p>
        </div>

        <h2>Che cosa è successo</h2>
        <div class="box">
          <p class="warn">L'effetto di uno dei due incrementi è andato perso.</p>
          <p class="note">L'anomalia è tipica quando due transazioni leggono lo stesso valore iniziale e poi scrivono risultati incompatibili tra loro.</p>
          <p>Per questo è una delle anomalie più intuitive: mostra subito che la correttezza locale di due transazioni non garantisce la correttezza globale del sistema.</p>
        </div>
'@
    }
    @{
        Num = 10
        Menu = 'Lez5.10: Lettura sporca'
        Title = 'Lettura sporca'
        H1 = 'Leggere un dato che poi viene annullato'
        Body = @'
        <h2>Scenario</h2>
        <div class="box">
          <p>La transazione <code>T1</code> scrive un nuovo valore, ma non ha ancora fatto commit. Nel frattempo <code>T2</code> lo legge.</p>
        </div>

        <h2>Interleaving scorretto</h2>
        <div class="box">
<pre><code class="language-text">T1: w1(x)
T2: r2(x)
T1: abort / rollback</code></pre>
          <p><code>T2</code> ha letto un valore che non doveva essere considerato stabile.</p>
        </div>

        <h2>Perché è pericolosa</h2>
        <div class="box">
          <p class="warn">Se <code>T2</code> continua la sua elaborazione sulla base di quel valore, costruisce risultati dipendenti da un dato che in realtà non esiste più.</p>
          <p class="note">La lettura sporca è quindi legata direttamente alla distinzione tra <strong>scritture provvisorie</strong> e <strong>scritture confermate</strong>.</p>
        </div>

        <h2>Nota di rigore</h2>
        <div class="box">
          <p class="note">Nella teoria degli schedule spesso si lavora prima su <strong>commit-proiezioni</strong>, cioè sequenze in cui restano solo le transazioni confermate.</p>
          <p class="note">Per questo la dirty read richiede un'attenzione specifica: non si lascia descrivere bene se si eliminano subito le transazioni abortite.</p>
        </div>
'@
    }
    @{
        Num = 11
        Menu = 'Lez5.11: Lettura inconsistente e aggiornamento fantasma'
        Title = 'Lettura inconsistente e aggiornamento fantasma'
        H1 = 'Analisi incoerente durante la lettura'
        Body = @'
        <h2>Lettura inconsistente</h2>
        <div class="box">
          <p>Una transazione legge due volte lo stesso dato in momenti diversi, ma tra le due letture un'altra transazione lo modifica e fa commit.</p>
<pre><code class="language-text">T1: r1(x) ... r1(x)
T2: r2(x), w2(x), commit</code></pre>
          <p class="warn">La stessa transazione <code>T1</code> osserva due valori diversi di <code>x</code>.</p>
        </div>

        <h2>Aggiornamento fantasma</h2>
        <div class="box">
          <p>Una transazione calcola, ad esempio, la somma di più saldi. Durante il calcolo un'altra transazione modifica alcuni valori coinvolti.</p>
          <p class="note">Il risultato finale dell'aggregazione non corrisponde né alla situazione iniziale né a quella finale completa.</p>
          <p class="note">In questi materiali manteniamo il termine <strong>aggiornamento fantasma</strong> nel senso usato da Montanari: una forma di <strong>analisi inconsistente</strong> su dati già presenti.</p>
        </div>

        <h2>Idea comune</h2>
        <div class="box">
          <p class="ok">In entrambi i casi, la transazione analizza una base di dati che <strong>cambia mentre la sta leggendo</strong>.</p>
          <p>La differenza è nel tipo di osservazione: rilettura dello stesso dato nel primo caso, lettura complessiva di più dati nel secondo.</p>
        </div>
'@
    }
    @{
        Num = 12
        Menu = 'Lez5.12: Inserimento fantasma'
        Title = 'Inserimento fantasma'
        H1 = 'Quando cambia l''insieme dei record letti'
        Body = @'
        <h2>Scenario tipico</h2>
        <div class="box">
          <p>Una transazione seleziona tutti i record che soddisfano una condizione e calcola, ad esempio, una somma o una media.</p>
          <p>Tra una lettura e la successiva, un'altra transazione <strong>inserisce</strong> un nuovo record che soddisfa quella stessa condizione.</p>
        </div>

        <h2>Perché è diverso dall'aggiornamento fantasma</h2>
        <div class="box">
          <ul>
            <li>Nell'aggiornamento fantasma cambiano dati già presenti e già letti.</li>
            <li>Nell'inserimento fantasma cambia l'<strong>insieme dei record selezionati</strong>.</li>
          </ul>
          <p class="warn">Il problema è legato al predicato della query, non solo a singole tuple già esistenti.</p>
        </div>

        <h2>Conseguenza</h2>
        <div class="box">
          <p class="note">Per impedire davvero questa anomalia non basta sempre bloccare solo i record presenti: bisogna in qualche modo proteggere anche il <strong>predicato di selezione</strong>.</p>
          <p>Questo chiarisce perché l'inserimento fantasma è più sottile: il problema non riguarda solo i dati già letti, ma anche quelli che potrebbero comparire durante la transazione.</p>
        </div>
'@
    }
    @{
        Num = 13
        Menu = 'Lez5.13: Sintesi delle anomalie'
        Title = 'Sintesi delle anomalie'
        H1 = 'Riepilogo: anomalia, dinamica, effetto'
        Body = @'
        <h2>Tabella di sintesi</h2>
        <div class="box">
          <table>
            <thead>
              <tr><th>Anomalia</th><th>Dinamica tipica</th><th>Effetto</th></tr>
            </thead>
            <tbody>
              <tr><td>Perdita di aggiornamento</td><td>due scritture partono dallo stesso valore iniziale</td><td>uno degli aggiornamenti scompare</td></tr>
              <tr><td>Lettura sporca</td><td>si legge una scrittura non committed</td><td>si usano dati provvisori</td></tr>
              <tr><td>Lettura inconsistente</td><td>letture ripetute dello stesso dato</td><td>la stessa transazione vede risultati diversi</td></tr>
              <tr><td>Aggiornamento fantasma</td><td>analisi aggregata su dati modificati durante il calcolo</td><td>risultato finale incoerente</td></tr>
              <tr><td>Inserimento fantasma</td><td>nuovi record compaiono tra due letture</td><td>cambia l'insieme selezionato</td></tr>
            </tbody>
          </table>
        </div>

        <h2>Che cosa dobbiamo garantire</h2>
        <div class="box">
          <p class="ok">L'obiettivo non è eliminare la concorrenza, ma far sì che l'intreccio delle operazioni si comporti come una esecuzione corretta.</p>
        </div>

        <h2>Micro-verifica</h2>
        <div class="box">
          <p><strong>Domanda</strong>: quale anomalia compare se una transazione rilegge lo stesso dato e ottiene due valori diversi dopo il commit di un'altra transazione?</p>
          <button id="btnMV13" onclick="toggleBox('btnMV13','ansMV13')">Mostra ▼</button>
          <div id="ansMV13" style="display:none; margin-top:.5rem">
            <p class="ok">È una <strong>lettura inconsistente</strong> (o lettura non ripetibile).</p>
            <p class="note">Qui non si sta leggendo un dato sporco: il problema non è il rollback, ma il fatto che il dato cambia tra due letture della stessa transazione.</p>
          </div>
        </div>
'@
    }
    @{
        Num = 14
        Menu = 'Lez5.14: Formalizzare le transazioni'
        Title = 'Formalizzare le transazioni'
        H1 = 'Dalle query alle operazioni r_i(x) e w_i(x)'
        Body = @'
        <h2>Notazione minima</h2>
        <div class="box">
          <ul>
            <li><code>r_i(x)</code>: la transazione <code>T_i</code> legge l'oggetto <code>x</code>.</li>
            <li><code>w_i(x)</code>: la transazione <code>T_i</code> scrive l'oggetto <code>x</code>.</li>
          </ul>
        </div>

        <h2>Perché si fa questa astrazione</h2>
        <div class="box">
          <p>La teoria del controllo della concorrenza non ha bisogno di conoscere tutti i dettagli del calcolo interno.</p>
          <p class="note">Le interessano soprattutto le azioni di <strong>ingresso/uscita sui dati</strong>: letture e scritture.</p>
          <p>Grazie a questa astrazione possiamo confrontare transazioni molto diverse usando un linguaggio comune e più semplice da analizzare.</p>
        </div>

        <h2>Esempio</h2>
        <div class="box">
<pre><code class="language-text">T1: r1(x) r1(y) w1(x) w1(y)</code></pre>
          <p>La transazione è qui rappresentata solo tramite le operazioni che possono interferire con altre transazioni.</p>
        </div>
'@
    }
    @{
        Num = 15
        Menu = 'Lez5.15: Che cos''è uno schedule'
        Title = 'Che cos''è uno schedule'
        H1 = 'Uno schedule è un interleaving di operazioni'
        Body = @'
        <h2>Definizione</h2>
        <div class="box">
          <p>Uno <strong>schedule</strong> è una sequenza di operazioni di lettura e scrittura appartenenti a un insieme di transazioni concorrenti.</p>
<pre><code class="language-text">S: r1(x) r2(z) w1(x) w2(z) ...</code></pre>
        </div>

        <h2>Schedule seriale</h2>
        <div class="box">
          <p>Uno schedule è <strong>seriale</strong> se le operazioni di ogni transazione compaiono tutte in blocco, senza essere interrotte da altre transazioni.</p>
          <p class="ok">È il riferimento ideale di correttezza, ma riduce al minimo il parallelismo.</p>
        </div>

        <h2>Schema visivo minimo</h2>
        <div class="box">
          <table>
            <thead>
              <tr><th>Tipo</th><th>Esempio</th></tr>
            </thead>
            <tbody>
              <tr>
                <td><strong>Seriale</strong></td>
                <td><code>r1(x) w1(x) r2(x) w2(x)</code></td>
              </tr>
              <tr>
                <td><strong>Interleaved</strong></td>
                <td><code>r1(x) r2(x) w1(x) w2(x)</code></td>
              </tr>
            </tbody>
          </table>
          <p class="note">Nel secondo caso c'è concorrenza vera: le operazioni delle due transazioni si alternano.</p>
        </div>

        <h2>Perché ci serve</h2>
        <div class="box">
          <p class="note">Per capire se un intreccio concorrente è corretto, lo confronteremo con il comportamento di una qualche esecuzione seriale.</p>
          <p>Lo schedule è quindi il punto di incontro tra la descrizione pratica della concorrenza e la sua analisi teorica.</p>
        </div>
'@
    }
    @{
        Num = 16
        Menu = 'Lez5.16: Schedule serializzabile'
        Title = 'Schedule serializzabile'
        H1 = 'Corretto non significa seriale, ma equivalente a un seriale'
        Body = @'
        <h2>L'idea di correttezza</h2>
        <div class="box">
          <p>Uno schedule concorrente è considerato corretto se produce lo <strong>stesso risultato</strong> di uno schedule seriale sulle stesse transazioni.</p>
        </div>

        <h2>Definizione intuitiva</h2>
        <div class="box">
          <p class="ok">Uno schedule si dice <strong>serializzabile</strong> se è equivalente a un qualche schedule seriale.</p>
          <p>In questo modo manteniamo il parallelismo, ma senza perdere la correttezza semantica.</p>
        </div>

        <h2>Il punto delicato</h2>
        <div class="box">
          <p class="warn">Bisogna però chiarire bene cosa significhi "produrre lo stesso risultato".</p>
          <p class="note">Da qui nascono diverse nozioni di equivalenza tra schedule.</p>
          <p>Il nodo teorico è proprio questo: non basta dire "si assomigliano", bisogna specificare con precisione che cosa osserviamo e che cosa vogliamo preservare.</p>
        </div>
'@
    }
    @{
        Num = 17
        Menu = 'Lez5.17: Equivalenza rispetto alle viste'
        Title = 'Equivalenza rispetto alle viste'
        H1 = 'La nozione teorica più generale presentata nella lezione'
        Body = @'
        <h2>Relazione legge</h2>
        <div class="box">
          <p>Dire che una lettura <code>r_i(x)</code> <strong>legge da</strong> una scrittura <code>w_j(x)</code> significa che <code>w_j(x)</code> è l'ultima scrittura di <code>x</code> prima di quella lettura.</p>
        </div>

        <h2>Scritture finali</h2>
        <div class="box">
          <p>Per ogni oggetto <code>x</code>, ci interessa anche quale transazione esegue l'<strong>ultima scrittura</strong> su <code>x</code> nello schedule.</p>
        </div>

        <h2>Definizione intuitiva</h2>
        <div class="box">
          <p>Due schedule sono <strong>equivalenti rispetto alle viste</strong> se:</p>
          <ul>
            <li>ogni lettura legge dallo stesso valore/scrittura nei due schedule;</li>
            <li>le scritture finali coincidono.</li>
          </ul>
          <p class="ok">È una nozione teoricamente forte, perché guarda al comportamento osservabile delle letture e del risultato finale.</p>
        </div>

        <h2>Mini-esempio</h2>
        <div class="box">
<pre><code class="language-text">S1: w1(x) r2(x) w2(x) r3(y)
S2: r3(y) w1(x) r2(x) w2(x)</code></pre>
          <p>La lettura <code>r2(x)</code> legge da <code>w1(x)</code> in entrambi gli schedule, e la scrittura finale su <code>x</code> resta <code>w2(x)</code>.</p>
          <p>L'operazione <code>r3(y)</code> è indipendente da quelle su <code>x</code>, quindi può essere spostata senza alterare la "vista" osservata sui dati coinvolti.</p>
          <p class="note">L'idea da fissare non è il formalismo completo, ma il fatto che contano <strong>chi legge da chi</strong> e <strong>chi scrive per ultimo</strong>.</p>
        </div>
'@
    }
    @{
        Num = 18
        Menu = 'Lez5.18: Dai limiti delle viste ai conflitti'
        Title = 'Dai limiti delle viste ai conflitti'
        H1 = 'Perché serve una nozione più operativa'
        Body = @'
        <h2>Limite pratico della view serializability</h2>
        <div class="box">
          <p>La serializzabilità rispetto alle viste è molto generale, ma non è semplice da usare direttamente per decidere in pratica se uno schedule è corretto.</p>
          <p class="warn">Dal punto di vista operativo è troppo costosa e poco maneggevole per uno scheduler reale.</p>
        </div>

        <h2>Azioni in conflitto</h2>
        <div class="box">
          <p>Due operazioni di transazioni diverse sono in conflitto se:</p>
          <ul>
            <li>agiscono sullo stesso oggetto;</li>
            <li>almeno una delle due è una scrittura.</li>
          </ul>
          <p class="note">Si distinguono i casi <code>rw</code>, <code>wr</code> e <code>ww</code>.</p>
        </div>

        <h2>Passo successivo</h2>
        <div class="box">
          <p class="ok">Da qui si arriva all'equivalenza rispetto ai conflitti, molto più adatta a essere controllata in pratica.</p>
          <p>Didatticamente, questo è il passaggio da una nozione più generale e potente a una più semplice da usare operativamente.</p>
        </div>
'@
    }
    @{
        Num = 19
        Menu = 'Lez5.19: Grafo dei conflitti'
        Title = 'Grafo dei conflitti'
        H1 = 'Aciclico = schedule corretto rispetto ai conflitti'
        Body = @'
        <h2>Equivalenza rispetto ai conflitti</h2>
        <div class="box">
          <p>Due schedule sono equivalenti rispetto ai conflitti se mantengono lo stesso ordine per ogni coppia di operazioni in conflitto.</p>
          <p class="ok">Uno schedule è <strong>conflict-serializable</strong> se è equivalente rispetto ai conflitti a uno schedule seriale.</p>
        </div>

        <h2>Il grafo dei conflitti</h2>
        <div class="box">
          <ul>
            <li>I nodi del grafo sono le transazioni.</li>
            <li>C'è un arco <code>T_i → T_j</code> se una operazione di <code>T_i</code> deve precedere una operazione conflittuale di <code>T_j</code>.</li>
          </ul>
          <p class="ok">Criterio fondamentale: <strong>se il grafo è aciclico, lo schedule è conflict-serializable</strong>.</p>
        </div>

        <h2>Esempio minimo</h2>
        <div class="box">
<pre><code class="language-text">S: r1(x) w1(x) r2(x) w2(x)</code></pre>
          <p>Le operazioni di <code>T1</code> su <code>x</code> devono precedere quelle conflittuali di <code>T2</code>, quindi il grafo contiene l'arco <code>T1 → T2</code>.</p>
          <p class="ok">Il grafo è aciclico, quindi lo schedule è equivalente al seriale <code>T1, T2</code>.</p>
        </div>

        <h2>Che cosa succede se compare un ciclo</h2>
        <div class="box">
          <p>Se il grafo contiene, per esempio, sia <code>T1 → T2</code> sia <code>T2 → T1</code>, nessun ordinamento seriale può rispettare entrambe le precedenze.</p>
          <p class="warn">Il ciclo segnala quindi che lo schedule <strong>non è conflict-serializable</strong>.</p>
        </div>

        <h2>Procedura operativa</h2>
        <div class="box">
          <ol>
            <li>Individua le coppie di operazioni in conflitto.</li>
            <li>Disegna un arco dalla transazione che deve venire prima a quella che deve venire dopo.</li>
            <li>Controlla se il grafo contiene un ciclo.</li>
          </ol>
          <p class="ok">Se non c'è ciclo, puoi leggere il grafo come un ordine seriale compatibile.</p>
        </div>
'@
    }
    @{
        Num = 20
        Menu = 'Lez5.20: Locking e lock manager'
        Title = 'Locking e lock manager'
        H1 = 'Dal controllo teorico al controllo operativo'
        Body = @'
        <h2>Perché servono i lock</h2>
        <div class="box">
          <p>Controllare continuamente tutti gli schedule è troppo oneroso. Il DBMS usa quindi meccanismi più operativi: i <strong>lock</strong>.</p>
        </div>

        <h2>Tipi di lock</h2>
        <div class="box">
          <ul>
            <li><strong>Read / shared lock</strong>: consente la lettura e può essere condiviso da più transazioni.</li>
            <li><strong>Write / exclusive lock</strong>: consente la scrittura ed è esclusivo.</li>
          </ul>
        </div>

        <h2>Compatibilità essenziale</h2>
        <div class="box">
          <table>
            <thead>
              <tr><th>Richiesta</th><th>Risorsa libera</th><th>Già in read lock</th><th>Già in write lock</th></tr>
            </thead>
            <tbody>
              <tr><td>Read lock</td><td>si</td><td>si</td><td>no</td></tr>
              <tr><td>Write lock</td><td>si</td><td>no</td><td>no</td></tr>
            </tbody>
          </table>
          <p class="note">Il <strong>lock manager</strong> tiene traccia di questi stati e decide se concedere il lock o mettere la transazione in attesa.</p>
          <p>Il lock quindi non è solo un "blocco": è un modo con cui il DBMS impone un ordine di accesso compatibile con la correttezza.</p>
        </div>
'@
    }
    @{
        Num = 21
        Menu = 'Lez5.21: 2PL e 2PL stretto'
        Title = '2PL e 2PL stretto'
        H1 = 'Due fasi per ottenere serializzabilità'
        Body = @'
        <h2>Locking a due fasi (2PL)</h2>
        <div class="box">
          <p>Nel protocollo <strong>2PL</strong> una transazione:</p>
          <ul>
            <li>prima acquisisce progressivamente i lock (<strong>fase crescente</strong>);</li>
            <li>poi rilascia progressivamente i lock (<strong>fase calante</strong>);</li>
            <li>dopo aver rilasciato un lock, non può acquisirne altri.</li>
          </ul>
        </div>

        <h2>2PL stretto</h2>
        <div class="box">
          <p>Nel <strong>2PL stretto</strong> i lock vengono rilasciati solo dopo <code>COMMIT</code> o <code>ROLLBACK</code>.</p>
          <p class="ok">Questo evita la lettura sporca, perché nessuna transazione può leggere dati ancora provvisori.</p>
        </div>

        <h2>Schema delle due fasi</h2>
        <div class="box">
<pre><code class="language-text">fase crescente:   lock(x)  lock(y)  lock(z)
uso delle risorse:      r(x)  w(y)  r(z)
fase calante:                    unlock(z) unlock(y) unlock(x)</code></pre>
          <p class="note">Nel 2PL normale il punto chiave è: <strong>dopo il primo unlock non posso più acquisire nuovi lock</strong>.</p>
          <p>Questa disciplina evita che una transazione continui a cambiare la propria situazione di lock in modo non controllabile.</p>
        </div>

        <h2>Limite importante</h2>
        <div class="box">
          <p class="note">Per impedire anche l'<strong>inserimento fantasma</strong>, non bastano i lock su record già presenti: servono meccanismi che proteggano anche il predicato di selezione.</p>
        </div>
'@
    }
    @{
        Num = 22
        Menu = 'Lez5.22: Deadlock e livelli di isolamento'
        Title = 'Deadlock e livelli di isolamento'
        H1 = 'Il controllo della concorrenza ha un costo'
        Body = @'
        <h2>Deadlock</h2>
        <div class="box">
          <p>Un <strong>deadlock</strong> si ha quando due transazioni restano in attesa l'una dell'altra.</p>
<pre><code class="language-text">T1 blocca x e aspetta y
T2 blocca y e aspetta x</code></pre>
          <p>Strategie tipiche: <strong>timeout</strong>, <strong>rilevamento</strong> del ciclo, <strong>prevenzione</strong>.</p>
        </div>

        <h2>Idea visiva: attesa circolare</h2>
        <div class="box">
          <table>
            <thead>
              <tr><th>Transazione</th><th>Possiede</th><th>Aspetta</th></tr>
            </thead>
            <tbody>
              <tr><td><code>T1</code></td><td><code>x</code></td><td><code>y</code></td></tr>
              <tr><td><code>T2</code></td><td><code>y</code></td><td><code>x</code></td></tr>
            </tbody>
          </table>
          <p class="warn">Nessuna delle due può proseguire senza un intervento del sistema.</p>
        </div>

        <h2>Livelli di isolamento SQL</h2>
        <div class="box">
          <table>
            <thead>
              <tr><th>Livello</th><th>Letture sporche</th><th>Letture inconsistenti</th><th>Fantasmi</th></tr>
            </thead>
            <tbody>
              <tr><td>Read Uncommitted</td><td>possibili</td><td>possibili</td><td>possibili</td></tr>
              <tr><td>Read Committed</td><td>non possibili</td><td>possibili</td><td>possibili</td></tr>
              <tr><td>Repeatable Read</td><td>non possibili</td><td>non possibili</td><td>possibili</td></tr>
              <tr><td>Serializable</td><td>non possibili</td><td>non possibili</td><td>non possibili</td></tr>
            </tbody>
          </table>
        </div>

        <h2>Idea finale della slide</h2>
        <div class="box">
          <p class="warn">Maggiore isolamento significa in generale minore libertà di concorrenza e più costo di controllo.</p>
        </div>

        <h2>Come leggere la tabella</h2>
        <div class="box">
          <p><strong>Read Uncommitted</strong> privilegia il parallelismo ma accetta anche anomalie gravi.</p>
          <p><strong>Serializable</strong> è il riferimento più forte: il comportamento deve risultare equivalente a una esecuzione seriale.</p>
          <p class="note">I livelli intermedi rappresentano compromessi diversi tra correttezza osservabile e prestazioni.</p>
          <p>La tabella va quindi letta come una scala di compromessi, non come un semplice elenco di etichette.</p>
        </div>
'@
    }
    @{
        Num = 23
        Menu = 'Lez5.23: PostgreSQL e MySQL'
        Title = 'PostgreSQL e MySQL: comportamento reale'
        H1 = 'Lo standard è una guida, il DBMS concreto conta'
        Body = @'
        <h2>PostgreSQL</h2>
        <div class="box">
          <ul>
            <li>Il livello di default è <strong>Read Committed</strong>.</li>
            <li>Usa tecniche basate su <strong>MVCC</strong> e snapshot.</li>
            <li>Il livello <strong>Read Uncommitted</strong> viene di fatto trattato come <strong>Read Committed</strong>.</li>
            <li>Il suo <strong>Repeatable Read</strong> è in alcuni casi più forte di quello previsto dallo standard.</li>
          </ul>
        </div>

        <h2>MySQL / InnoDB</h2>
        <div class="box">
          <ul>
            <li>Il livello di default è <strong>Repeatable Read</strong>.</li>
            <li>Combina idee di <strong>MVCC</strong> e <strong>locking</strong>.</li>
            <li>Nel livello <strong>Read Uncommitted</strong> può mostrare anomalie come la dirty read.</li>
            <li>Nel livello <strong>Serializable</strong> usa un comportamento più restrittivo, anche tramite lock aggiuntivi.</li>
          </ul>
        </div>

        <h2>Cosa deve restare</h2>
        <div class="box">
          <ul>
            <li>La teoria serve per capire i problemi e le soluzioni generali.</li>
            <li>I livelli SQL danno una classificazione utile, ma non dicono tutto da soli.</li>
            <li>Conta sempre anche <strong>l'implementazione concreta del DBMS</strong>.</li>
          </ul>
          <p class="ok">Con questa lezione si chiude il ponte tra teoria delle basi di dati e comportamento reale dei sistemi transazionali.</p>
          <p class="note">Sapere "come si chiama" un livello non basta: bisogna capire anche con quali tecniche concrete il DBMS cerca di realizzarlo.</p>
        </div>
'@
    }
)

function Get-MenuHtml {
    param([array]$AllSlides)

    $items = foreach ($slide in $AllSlides) {
        "      <li><a href=`"lez5_$($slide.Num).html`">$($slide.Menu)</a></li>"
    }

    return @"
  <!-- BEGIN MENU -->
  <button class="menu-toggle" onclick="toggleMenu()">&#9776; Menu</button>
  <div class="sidebar" id="menu">
    <h2>Lezione 5 — Transazioni concorrenti</h2>
    <ul>
$($items -join "`n")
    </ul>
  </div>
  <!-- END MENU -->
"@
}

function Get-PrevJs {
    param([int]$Num)
    if ($Num -eq 1) {
        return 'if (history.length > 1) { history.back(); } else { window.location.href = "../programma.html"; }'
    }
    return "window.location.href = `"lez5_$($Num - 1).html`";"
}

function Get-NextJs {
    param([int]$Num, [int]$MaxNum)
    if ($Num -eq $MaxNum) {
        return 'window.location.href = "../programma.html";'
    }
    return "window.location.href = `"lez5_$($Num + 1).html`";"
}

$menuHtml = Get-MenuHtml -AllSlides $slides
$maxNum = ($slides | Measure-Object -Property Num -Maximum).Maximum

foreach ($slide in $slides) {
    $prevJs = Get-PrevJs -Num $slide.Num
    $nextJs = Get-NextJs -Num $slide.Num -MaxNum $maxNum
    $nextLabel = if ($slide.Num -eq $maxNum) { 'Programma &#8594;' } else { 'Avanti &#8594;' }

    $html = @"
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>ITST – 5ª · Lez5_$($slide.Num) · $($slide.Title)</title>
  <link rel="stylesheet" href="../style.css" />
  <link rel="stylesheet" href="../default.css" />
  <script src="../highlight.js"></script>
  <script>
    try { hljs.highlightAll(); } catch (e) {}
    function prevSlide(){ $prevJs }
    function nextSlide(){ $nextJs }
    function toggleMenu(){ document.getElementById('menu').classList.toggle('open'); }
    function toggleBox(btnId, boxId){
      const box = document.getElementById(boxId);
      const btn = document.getElementById(btnId);
      const open = box.style.display === 'block';
      box.style.display = open ? 'none' : 'block';
      btn.textContent = open ? 'Mostra ▼' : 'Nascondi ▲';
    }
    document.addEventListener('DOMContentLoaded', function(){
      var current = window.location.pathname.split('/').pop();
      var link = document.querySelector('#menu a[href="' + current + '"]');
      if (link) link.classList.add('active');
    });
  </script>
  <style>
$commonStyle
  </style>
</head>
<body>
$menuHtml

  <div class="slide">
    <h1>$($slide.H1)</h1>

    <div class="nav-buttons" style="margin-bottom:10px">
      <button onclick="prevSlide()">&#8592; Indietro</button>
      <button onclick="nextSlide()">$nextLabel</button>
    </div>

    <div class="content-box">
      <div class="inner-box">
$($slide.Body)
      </div>
    </div>

    <div class="nav-buttons" style="margin-top:10px">
      <button onclick="prevSlide()">&#8592; Indietro</button>
      <button onclick="nextSlide()">$nextLabel</button>
    </div>
  </div>
</body>
</html>
"@

    $path = Join-Path $root ("lez5_{0}.html" -f $slide.Num)
    [System.IO.File]::WriteAllText($path, $html, $utf8NoBom)
}
