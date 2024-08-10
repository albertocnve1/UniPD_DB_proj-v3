#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "libpq-fe.h"
#define PG_HOST "localhost"
#define PG_USER "albertocanavese"
#define PG_DB "soundify"
#define PG_PASS "" 
#define PG_PORT "5432"

void exit_nicely(PGconn *conn) {
    PQfinish(conn);
    exit(1);
}

PGconn* connect() {
    char conninfo[256];
    sprintf(conninfo, "host=%s user=%s dbname=%s password=%s port=%s",
        PG_HOST, PG_USER, PG_DB, PG_PASS, PG_PORT);

    PGconn* conn = PQconnectdb(conninfo);

    if (PQstatus(conn) != CONNECTION_OK) {
        fprintf(stderr, "Connection to database failed: %s\n", PQerrorMessage(conn));
        exit_nicely(conn);
    }

    return conn;
}

PGresult* execute(PGconn* conn, const char* query) {
    PGresult* res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Query failed: %s\n", PQerrorMessage(conn));
        PQclear(res);
        exit_nicely(conn);
    }

    return res;
}

void printLine(int campi, int* maxChar) {
    for (int j = 0; j < campi; ++j) {
        printf("+");
        for (int k = 0; k < maxChar[j] + 2; ++k)
            printf("-");
    }
    printf("+\n");
}

void printQuery(PGresult* res) {
    const int tuple = PQntuples(res), campi = PQnfields(res);
    char v[tuple + 1][campi][256];

    for (int i = 0; i < campi; ++i) {
        strcpy(v[0][i], PQfname(res, i));
    }
    for (int i = 0; i < tuple; ++i) {
        for (int j = 0; j < campi; ++j) {
            strcpy(v[i + 1][j], PQgetvalue(res, i, j));
        }
    }

    int maxChar[campi];
    for (int i = 0; i < campi; ++i) {
        maxChar[i] = 0;
    }

    for (int i = 0; i < campi; ++i) {
        for (int j = 0; j < tuple + 1; ++j) {
            int size = strlen(v[j][i]);
            maxChar[i] = size > maxChar[i] ? size : maxChar[i];
        }
    }

    printLine(campi, maxChar);
    for (int j = 0; j < campi; ++j) {
        printf("| %s", v[0][j]);
        for (int k = 0; k < maxChar[j] - (int)strlen(v[0][j]) + 1; ++k)
            printf(" ");
        if (j == campi - 1)
            printf("|");
    }
    printf("\n");
    printLine(campi, maxChar);

    for (int i = 1; i < tuple + 1; ++i) {
        for (int j = 0; j < campi; ++j) {
            printf("| %s", v[i][j]);
            for (int k = 0; k < maxChar[j] - (int)strlen(v[i][j]) + 1; ++k)
                printf(" ");
            if (j == campi - 1)
                printf("|");
        }
        printf("\n");
    }
    printLine(campi, maxChar);
}

int main() {
    PGconn* conn = connect();

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
                printQuery(execute(conn, queryTemp));
                break;
            }
            case 3: {
                int riproduzioni_minime;
                printf("Inserisci il numero minimo di riproduzioni: ");
                scanf("%d", &riproduzioni_minime);
                sprintf(queryTemp, query[2], riproduzioni_minime);
                printQuery(execute(conn, queryTemp));
                break;
            }
            case 4: {
                char start_date[11], end_date[11];
                printf("Inserisci la data di inizio (YYYY-MM-DD): ");
                scanf("%s", start_date);
                printf("Inserisci la data di fine (YYYY-MM-DD): ");
                scanf("%s", end_date);
                sprintf(queryTemp, query[3], start_date, end_date);
                printQuery(execute(conn, queryTemp));
                break;
            }
            default:
                printQuery(execute(conn, query[q - 1]));
                break;
        }
    }

    PQfinish(conn);
    return 0;
}
