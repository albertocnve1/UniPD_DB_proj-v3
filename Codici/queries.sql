-- Recupera la lista degli artisti e il numero totale di riproduzioni delle loro canzoni
SELECT A.Nome AS Artista, SUM(C.Riproduzioni) AS Totale_Riproduzioni
FROM Artista A
JOIN Canzone C ON A.CF = C.CF_artista
GROUP BY A.Nome
ORDER BY Totale_Riproduzioni DESC;

-- Trova gli utenti che hanno almeno 3 canzoni preferite da un singolo album
SELECT PB.Username_utente, C.Titolo_album, COUNT(*) AS Numero_Canzoni
FROM Preferenza_Brani PB
JOIN Canzone C ON PB.Titolo_canzone = C.Titolo AND PB.CF_artista = C.CF_artista AND PB.Titolo_album = C.Titolo_album
GROUP BY PB.Username_utente, C.Titolo_album
HAVING COUNT(*) >= 3;

-- Trova gli episodi più popolari di ciascun podcast, ovvero quelli con il maggior numero di riproduzioni
SELECT A.Nome AS Podcast, E.Titolo AS Episodio, E.riproduzioni
FROM Episodio E
JOIN Artista A ON E.CF_artista = A.CF
JOIN (
    SELECT CF_artista, MAX(riproduzioni) AS MaxRiproduzioni
    FROM Episodio
    GROUP BY CF_artista
) AS SubQuery ON E.CF_artista = SubQuery.CF_artista AND E.riproduzioni = SubQuery.MaxRiproduzioni;


-- Calcola la retribuzione totale ricevuta da ciascun artista, raggruppata per artista e suddivisa per mese, e mostra solo i mesi in cui un artista ha ricevuto più di 500 euro
SELECT 
    A.Nome AS Artista, 
    EXTRACT(MONTH FROM R.data_esecuzione) AS Mese, 
    SUM(R.importo) AS Totale_Retribuzione
FROM 
    Artista A
JOIN 
    Retribuzione R ON A.IBAN = R.IBAN_beneficiario
GROUP BY 
    A.Nome, EXTRACT(MONTH FROM R.data_esecuzione)
HAVING 
    SUM(R.importo) > 500
ORDER BY 
    A.Nome, Mese;


-- Elenca tutti gli utenti con un abbonamento annuale
SELECT 
    U.Username, 
    U.Nome, 
    U.Cognome, 
    A.Data_sottoscrizione, 
    A.Data_scadenza, 
    A.Prezzo
FROM 
    Utente U
JOIN 
    Abbonamento A ON U.Username = A.utente_abbonato
WHERE 
    A.Data_scadenza = A.Data_sottoscrizione + INTERVAL '1 year'
ORDER BY 
    A.Data_sottoscrizione DESC;



CREATE INDEX idx_abbonamento_utente_abbonato ON Abbonamento (utente_abbonato);
CREATE INDEX idx_abbonamento_data_sottoscrizione ON Abbonamento (Data_sottoscrizione);



