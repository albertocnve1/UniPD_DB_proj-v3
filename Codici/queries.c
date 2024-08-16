#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libpq-fe.h>

#define PG_HOST    "localhost"
#define PG_USER    "postgres"
#define PG_DB      "soundify"
#define PG_PASS    ""
#define PG_PORT    5432

void exit_nicely(PGconn *conn) {
    PQfinish(conn);
    exit(1);
}

void checkCommand(PGresult *res, PGconn *conn) {  // Rimosso 'const'
    if (PQresultStatus(res) != PGRES_COMMAND_OK) {
        printf("Comando fallito %s\n", PQerrorMessage(conn));
        PQclear(res);
        exit_nicely(conn);  // Passa conn non-const
    }
}

void checkResults(PGresult *res, PGconn *conn) {  // Rimosso 'const'
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        printf("Risultati inconsistenti %s\n", PQerrorMessage(conn));
        PQclear(res);
        exit_nicely(conn);  // Passa conn non-const
    }
}

void printLine(int nFields, int* maxWidths) {
    for (int i = 0; i < nFields; i++) {
        printf("+");
        for (int j = 0; j < maxWidths[i] + 2; j++) {
            printf("-");
        }
    }
    printf("+\n");
}

void execute_and_print_query(PGconn *conn, const char *query) {
    PGresult *res;
    int nFields, nTuples;
    int i, j;

    // Esegui la query
    res = PQexec(conn, query);
    checkResults(res, conn);

    // Ottieni il numero di campi nella query
    nFields = PQnfields(res);
    nTuples = PQntuples(res);

    // Calcola la larghezza massima per ciascun campo
    int maxWidths[nFields];
    for (i = 0; i < nFields; i++) {
        maxWidths[i] = strlen(PQfname(res, i));
        for (j = 0; j < nTuples; j++) {
            int fieldWidth = strlen(PQgetvalue(res, j, i));
            if (fieldWidth > maxWidths[i]) {
                maxWidths[i] = fieldWidth;
            }
        }
    }

    // Stampa linea superiore
    printLine(nFields, maxWidths);

    // Stampa i nomi delle colonne
    for (i = 0; i < nFields; i++) {
        printf("| %-*s ", maxWidths[i], PQfname(res, i));
    }
    printf("|\n");

    // Stampa linea di separazione
    printLine(nFields, maxWidths);

    // Stampa i valori delle righe
    for (i = 0; i < nTuples; i++) {
        for (j = 0; j < nFields; j++) {
            printf("| %-*s ", maxWidths[j], PQgetvalue(res, i, j));
        }
        printf("|\n");
    }

    // Stampa linea inferiore
    printLine(nFields, maxWidths);

    // Pulisci i risultati
    PQclear(res);
}

int main() {
    char conninfo[500];
    sprintf(conninfo, "postgresql://%s:%s@%s:%d/%s", PG_USER, PG_PASS, PG_HOST, PG_PORT, PG_DB);

    // Eseguo la connessione al database
    PGconn *conn;
    conn = PQconnectdb(conninfo);

    // Verifico lo stato di connessione
    if (PQstatus(conn) != CONNECTION_OK) {
        printf("Errore di connessione: %s\n", PQerrorMessage(conn));
        PQfinish(conn);
        exit(1);
    }

    const char* query[4] = {
        // Query 1: Episodi con il maggior numero di riproduzioni per ogni podcast
        "SELECT A.Nome AS Podcast, E.Titolo AS Episodio, E.riproduzioni "
        "FROM Episodio E "
        "JOIN Artista A ON E.CF_artista = A.CF "
        "JOIN (SELECT CF_artista, MAX(riproduzioni) AS MaxRiproduzioni FROM Episodio GROUP BY CF_artista) AS SubQuery "
        "ON E.CF_artista = SubQuery.CF_artista AND E.riproduzioni = SubQuery.MaxRiproduzioni;",

        // Query 2: Cerca brani di un artista specifico (richiede input del codice fiscale dell'artista) in ordine decrescente di ascolti
        "SELECT C.Titolo, C.Genere, C.Durata, C.Riproduzioni "
        "FROM Canzone C "
        "JOIN Artista A ON C.CF_artista = A.CF "
        "WHERE A.CF = '%s' "
        "ORDER BY C.Riproduzioni DESC;",

        // Query 3: Mostra i brani con più riproduzioni di quante specificate dall'utente
        "SELECT C.Titolo, C.Riproduzioni "
        "FROM Canzone C "
        "WHERE C.Riproduzioni > %d;",

        // Query 4: Trova tutti gli episodi pubblicati in un certo intervallo di tempo (richiede input utente)
        "SELECT E.Titolo, E.data_di_pubblicazione, A.Nome AS Podcast "
        "FROM Episodio E "
        "JOIN Artista A ON E.CF_artista = A.CF "
        "WHERE E.data_di_pubblicazione BETWEEN '%s' AND '%s';"
    };

    while (1) {
        printf("\n");
        printf("1. Episodi con il maggior numero di riproduzioni per ogni podcast\n");
        printf("2. Cerca brani di un artista specifico in ordine decrescente di ascolti\n");
        printf("3. Mostra i brani con più riproduzioni di quante specificate dall'utente\n");
        printf("4. Trova tutti gli episodi pubblicati in un certo intervallo di tempo\n");
        printf("Query da eseguire (0 per uscire): ");
        int q = 0;
        scanf("%d", &q);
        while (q < 0 || q > 4) {
            printf("Le query vanno da 1 a 4...\n");
            printf("Query da eseguire (0 per uscire): ");
            scanf("%d", &q);
        }
        if (q == 0) break;

        char queryTemp[1500];
        switch (q) {
            case 2: {
                char codiceFiscale[17];
                printf("Inserisci il codice fiscale dell'artista: ");
                scanf("%s", codiceFiscale);
                sprintf(queryTemp, query[1], codiceFiscale);
                execute_and_print_query(conn, queryTemp);
                break;
            }
            case 3: {
                int riproduzioni_minime;
                printf("Inserisci il numero minimo di riproduzioni: ");
                scanf("%d", &riproduzioni_minime);
                sprintf(queryTemp, query[2], riproduzioni_minime);
                execute_and_print_query(conn, queryTemp);
                break;
            }
            case 4: {
                char start_date[11], end_date[11];
                printf("Inserisci la data di inizio (YYYY-MM-DD): ");
                scanf("%s", start_date);
                printf("Inserisci la data di fine (YYYY-MM-DD): ");
                scanf("%s", end_date);
                sprintf(queryTemp, query[3], start_date, end_date);
                execute_and_print_query(conn, queryTemp);
                break;
            }
            default:
                execute_and_print_query(conn, query[q - 1]);
                break;
        }
    }

    PQfinish(conn);
    return 0;
}
