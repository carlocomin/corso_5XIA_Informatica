#include <algorithm>
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <string>
#include <type_traits>

// MiniDB - starter per il laboratorio.
// Le funzioni di interfaccia sono complete; le funzioni di archivio marcate
// TODO costituiscono il lavoro richiesto.

const std::string NOME_FILE = "libri.dat";

struct Libro {
    std::int32_t id;
    char titolo[51];
    char autore[41];
    std::int32_t anno;
    std::uint8_t attivo; // 1 = record attivo, 0 = record cancellato
};

static_assert(std::is_trivially_copyable_v<Libro>,
              "Libro deve poter essere copiato come sequenza di byte");

int leggiIntero(const std::string& messaggio, int minimo, int massimo);
std::string leggiTesto(const std::string& messaggio, std::size_t lunghezzaMassima);
Libro acquisisciLibro(std::int32_t id);
void stampaIntestazione();
void stampaLibro(const Libro& libro);

void elencaAttivi(const std::string& nomeFile);
bool cercaPerId(const std::string& nomeFile, std::int32_t id,
                Libro& trovato, std::streamoff& offset);
bool inserisci(const std::string& nomeFile, const Libro& nuovo);
bool modifica(const std::string& nomeFile, std::int32_t id,
              const Libro& nuoviDati);
bool cancellaLogicamente(const std::string& nomeFile, std::int32_t id);
void mostraStatistiche(const std::string& nomeFile);
bool compatta(const std::string& nomeFile);

template <std::size_t N>
void copiaTesto(char (&destinazione)[N], const std::string& testo) {
    std::memset(destinazione, 0, N);
    const std::size_t quanti = std::min(testo.size(), N - 1);
    std::memcpy(destinazione, testo.data(), quanti);
}

int main() {
    int scelta;

    do {
        std::cout << "\n=== MiniDB biblioteca ===\n"
                  << "1. Elenca libri attivi\n"
                  << "2. Cerca per ID\n"
                  << "3. Inserisci\n"
                  << "4. Modifica\n"
                  << "5. Cancella logicamente\n"
                  << "6. Mostra statistiche\n"
                  << "7. Compatta archivio\n"
                  << "0. Esci\n";

        scelta = leggiIntero("Scelta: ", 0, 7);

        if (scelta == 1) {
            elencaAttivi(NOME_FILE);
        } else if (scelta == 2) {
            const auto id = leggiIntero("ID da cercare: ", 1,
                                        std::numeric_limits<int>::max());
            Libro trovato{};
            std::streamoff offset = 0;
            if (cercaPerId(NOME_FILE, id, trovato, offset)) {
                stampaIntestazione();
                stampaLibro(trovato);
                std::cout << "Offset nel file: " << offset << " byte\n";
            } else {
                std::cout << "Nessun libro attivo con questo ID.\n";
            }
        } else if (scelta == 3) {
            const auto id = leggiIntero("Nuovo ID: ", 1,
                                        std::numeric_limits<int>::max());
            Libro esistente{};
            std::streamoff offset = 0;
            if (cercaPerId(NOME_FILE, id, esistente, offset)) {
                std::cout << "ID gia' assegnato a un record attivo.\n";
            } else {
                const Libro nuovo = acquisisciLibro(id);
                std::cout << (inserisci(NOME_FILE, nuovo)
                                  ? "Inserimento completato.\n"
                                  : "Inserimento non eseguito.\n");
            }
        } else if (scelta == 4) {
            const auto id = leggiIntero("ID da modificare: ", 1,
                                        std::numeric_limits<int>::max());
            Libro trovato{};
            std::streamoff offset = 0;
            if (!cercaPerId(NOME_FILE, id, trovato, offset)) {
                std::cout << "Record attivo non trovato.\n";
            } else {
                stampaIntestazione();
                stampaLibro(trovato);
                std::cout << "Inserisci i nuovi dati (l'ID non cambia).\n";
                const Libro nuoviDati = acquisisciLibro(id);
                std::cout << (modifica(NOME_FILE, id, nuoviDati)
                                  ? "Modifica completata.\n"
                                  : "Modifica non eseguita.\n");
            }
        } else if (scelta == 5) {
            const auto id = leggiIntero("ID da cancellare: ", 1,
                                        std::numeric_limits<int>::max());
            std::cout << (cancellaLogicamente(NOME_FILE, id)
                              ? "Cancellazione logica completata.\n"
                              : "Cancellazione non eseguita.\n");
        } else if (scelta == 6) {
            mostraStatistiche(NOME_FILE);
        } else if (scelta == 7) {
            std::cout << (compatta(NOME_FILE)
                              ? "Compattazione completata.\n"
                              : "Compattazione non eseguita.\n");
        }
    } while (scelta != 0);

    return 0;
}

int leggiIntero(const std::string& messaggio, int minimo, int massimo) {
    int valore;
    while (true) {
        std::cout << messaggio;
        if (std::cin >> valore && valore >= minimo && valore <= massimo) {
            std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
            return valore;
        }
        std::cout << "Valore non valido: inserire un intero tra "
                  << minimo << " e " << massimo << ".\n";
        std::cin.clear();
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    }
}

std::string leggiTesto(const std::string& messaggio,
                       std::size_t lunghezzaMassima) {
    std::string testo;
    while (true) {
        std::cout << messaggio;
        std::getline(std::cin, testo);
        if (!testo.empty() && testo.size() <= lunghezzaMassima) {
            return testo;
        }
        std::cout << "Il testo deve contenere da 1 a " << lunghezzaMassima
                  << " caratteri.\n";
    }
}

Libro acquisisciLibro(std::int32_t id) {
    Libro libro{};
    libro.id = id;
    copiaTesto(libro.titolo, leggiTesto("Titolo (max 50): ", 50));
    copiaTesto(libro.autore, leggiTesto("Autore (max 40): ", 40));
    libro.anno = leggiIntero("Anno (1450-2100): ", 1450, 2100);
    libro.attivo = 1;
    return libro;
}

void stampaIntestazione() {
    std::cout << std::left << std::setw(8) << "ID"
              << std::setw(52) << "TITOLO"
              << std::setw(42) << "AUTORE"
              << std::setw(8) << "ANNO" << '\n'
              << std::string(110, '-') << '\n';
}

void stampaLibro(const Libro& libro) {
    std::cout << std::left << std::setw(8) << libro.id
              << std::setw(52) << libro.titolo
              << std::setw(42) << libro.autore
              << std::setw(8) << libro.anno << '\n';
}

void elencaAttivi(const std::string& nomeFile) {
    // TODO 1: aprire in lettura binaria, leggere un Libro alla volta e
    // stampare soltanto quelli con attivo != 0. Gestire il file inesistente.
    (void)nomeFile;
    std::cout << "[TODO] elencaAttivi\n";
}

bool cercaPerId(const std::string& nomeFile, std::int32_t id,
                Libro& trovato, std::streamoff& offset) {
    // TODO 2: scansione sequenziale. Restituire true solo per un record
    // attivo con ID uguale; offset e' la posizione iniziale del record.
    (void)nomeFile;
    (void)id;
    (void)trovato;
    (void)offset;
    return false;
}

bool inserisci(const std::string& nomeFile, const Libro& nuovo) {
    // TODO 3: rifiutare un ID gia' attivo. Ricordare il primo slot con
    // attivo == 0, ma terminare l'intera scansione prima di scrivere:
    // un duplicato potrebbe trovarsi piu' avanti. Se non ci sono slot
    // liberi, aprire in modalita' append (che crea anche un file assente).
    (void)nomeFile;
    (void)nuovo;
    return false;
}

bool modifica(const std::string& nomeFile, std::int32_t id,
              const Libro& nuoviDati) {
    // TODO 4: cercare l'offset e sovrascrivere esattamente quel record.
    // Usare seekp(offset, std::ios::beg). ID e flag attivo devono restare
    // invariati. Restituire false se l'ID e' assente o si verifica un errore.
    (void)nomeFile;
    (void)id;
    (void)nuoviDati;
    return false;
}

bool cancellaLogicamente(const std::string& nomeFile, std::int32_t id) {
    // TODO 5: trovare il record attivo, porre attivo a 0 e riscriverlo
    // nella stessa posizione con seekp(offset, std::ios::beg). La dimensione
    // del file non deve cambiare. Segnalare internamente gli errori di I/O.
    (void)nomeFile;
    (void)id;
    return false;
}

void mostraStatistiche(const std::string& nomeFile) {
    // TODO 6: mostrare slot totali, record attivi, record cancellati e
    // dimensione in byte (slotTotali * sizeof(Libro)). Un file assente
    // equivale a un archivio con tutti i valori uguali a zero.
    (void)nomeFile;
    std::cout << "[TODO] mostraStatistiche\n";
}

bool compatta(const std::string& nomeFile) {
    // TODO 7: copiare i soli record attivi in libri.tmp. Solo dopo una
    // copia riuscita e la chiusura degli stream, rinominare l'originale
    // in libri.bak e il temporaneo in originale. In caso di errore tentare
    // il ripristino; a operazione riuscita eliminare il backup. Un file
    // inesistente produce false; un file esistente ma vuoto e' invece valido.
    (void)nomeFile;
    return false;
}
