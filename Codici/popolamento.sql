-- Creazione della tabella Etichetta Discografica
CREATE TABLE Etichetta_Discografica (
    P_IVA VARCHAR(20) PRIMARY KEY,
    Indirizzo_sede_legale TEXT,
    anno_fondazione INTEGER,
    nome_etichetta VARCHAR(100),
    percentuale_royalties NUMERIC(5, 2)
);

-- Creazione della tabella Artista con vincolo UNIQUE su IBAN
CREATE TABLE Artista (
    CF VARCHAR(16) PRIMARY KEY,
    Nome VARCHAR(100),
    email VARCHAR(100),
    Data_di_nascita DATE,
    IBAN VARCHAR(27) UNIQUE,
    PIVA_etichetta VARCHAR(20),
    FOREIGN KEY (PIVA_etichetta) REFERENCES Etichetta_Discografica(P_IVA)
);

-- Creazione della tabella Album
CREATE TABLE Album (
    Titolo VARCHAR(200),
    CF_artista VARCHAR(16),
    Genere VARCHAR(50),
    Durata INTEGER,
    data_di_pubblicazione DATE,
    Riproduzioni BIGINT,
    PRIMARY KEY (Titolo, CF_artista),
    FOREIGN KEY (CF_artista) REFERENCES Artista(CF)
);

-- Creazione della tabella Canzone
CREATE TABLE Canzone (
    Titolo VARCHAR(200),
    CF_artista VARCHAR(16),
    Titolo_album VARCHAR(200),
    Genere VARCHAR(50),
    Durata INTEGER,
    Riproduzioni BIGINT,
    numero_traccia INTEGER,
    data_di_pubblicazione DATE,
    PRIMARY KEY (Titolo, CF_artista, Titolo_album),
    FOREIGN KEY (CF_artista, Titolo_album) REFERENCES Album (CF_artista, Titolo)
);

-- Creazione della tabella Episodio
CREATE TABLE Episodio (
    Titolo VARCHAR(200),
    CF_artista VARCHAR(16),
    Genere VARCHAR(50),
    Durata INTEGER,
    riproduzioni BIGINT,
    data_di_pubblicazione DATE,
    PRIMARY KEY (Titolo, CF_artista),
    FOREIGN KEY (CF_artista) REFERENCES Artista(CF)
);

-- Creazione della tabella Utente
CREATE TABLE Utente (
    Username VARCHAR(50) PRIMARY KEY,
    Nome VARCHAR(100),
    Cognome VARCHAR(100),
    email VARCHAR(100)
);

-- Creazione della tabella Playlist
CREATE TABLE Playlist (
    Nome VARCHAR(200),
    Username_utente VARCHAR(50),
    Visibilita_pubblica BOOLEAN,
    PRIMARY KEY (Nome, Username_utente),
    FOREIGN KEY (Username_utente) REFERENCES Utente(Username)
);

-- Creazione della tabella Appartiene
CREATE TABLE Appartiene (
    Nome_playlist VARCHAR(200),
    Username_utente VARCHAR(50),
    Titolo_canzone VARCHAR(200),
    CF_artista VARCHAR(16),
    Titolo_album VARCHAR(200),
    PRIMARY KEY (Nome_playlist, Username_utente, Titolo_canzone, CF_artista, Titolo_album),
    FOREIGN KEY (Nome_playlist, Username_utente) REFERENCES Playlist (Nome, Username_utente),
    FOREIGN KEY (Titolo_canzone, CF_artista, Titolo_album) REFERENCES Canzone (Titolo, CF_artista, Titolo_album)
);

-- Creazione della tabella Preferenza Brani
CREATE TABLE Preferenza_Brani (
    Username_utente VARCHAR(50),
    Titolo_canzone VARCHAR(200),
    CF_artista VARCHAR(16),
    Titolo_album VARCHAR(200),
    PRIMARY KEY (Username_utente, Titolo_canzone, CF_artista, Titolo_album),
    FOREIGN KEY (Username_utente) REFERENCES Utente(Username),
    FOREIGN KEY (Titolo_canzone, CF_artista, Titolo_album) REFERENCES Canzone (Titolo, CF_artista, Titolo_album)
);

-- Creazione della tabella Preferenza Episodi
CREATE TABLE Preferenza_Episodi (
    Username_utente VARCHAR(50),
    Titolo_episodio VARCHAR(200),
    CF_artista VARCHAR(16),
    PRIMARY KEY (Username_utente, Titolo_episodio, CF_artista),
    FOREIGN KEY (Username_utente) REFERENCES Utente(Username),
    FOREIGN KEY (Titolo_episodio, CF_artista) REFERENCES Episodio (Titolo, CF_artista)
);

-- Creazione della tabella Abbonamento
CREATE TABLE Abbonamento (
    ID SERIAL PRIMARY KEY,
    Data_sottoscrizione DATE,
    Data_scadenza DATE,
    Prezzo NUMERIC(10, 2),
    utente_abbonato VARCHAR(50) REFERENCES Utente(Username)
);

-- Creazione della tabella Servizio_terzo
CREATE TABLE Servizio_terzo (
    UserID VARCHAR(50) PRIMARY KEY,
    nome_servizio VARCHAR(100)
);

-- Creazione della tabella Carta_di_credito
CREATE TABLE Carta_di_credito (
    Numero VARCHAR(16) PRIMARY KEY,
    intestatario VARCHAR(100),
    data_scadenza DATE,
    CVV VARCHAR(4),
    circuito VARCHAR(50)
);

-- Creazione della tabella Metodo di pagamento
CREATE TABLE Metodo_di_pagamento (
    Username VARCHAR(50),
    UserID VARCHAR(50),
    NumeroCarta VARCHAR(16),
    PRIMARY KEY (Username, UserID, NumeroCarta),
    FOREIGN KEY (Username) REFERENCES Utente(Username),
    FOREIGN KEY (UserID) REFERENCES Servizio_terzo(UserID),
    FOREIGN KEY (NumeroCarta) REFERENCES Carta_di_credito(Numero),
    CHECK ((UserID IS NOT NULL AND NumeroCarta IS NULL) OR (UserID IS NULL AND NumeroCarta IS NOT NULL))
);

-- Creazione della tabella Retribuzione
CREATE TABLE Retribuzione (
    ID_transazione SERIAL PRIMARY KEY,
    data_esecuzione DATE,
    importo NUMERIC(10, 2),
    IBAN_beneficiario VARCHAR(27) REFERENCES Artista(IBAN)
);
