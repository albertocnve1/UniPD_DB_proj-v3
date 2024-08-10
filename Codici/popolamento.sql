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
    ID VARCHAR(50) PRIMARY KEY,
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
    Username VARCHAR(50) PRIMARY KEY, -- chiave primaria univoca
    UserID VARCHAR(50),
    NumeroCarta VARCHAR(16),
    FOREIGN KEY (Username) REFERENCES Utente(Username),
    FOREIGN KEY (UserID) REFERENCES Servizio_terzo(UserID),
    FOREIGN KEY (NumeroCarta) REFERENCES Carta_di_credito(Numero),
    CHECK (
        (UserID IS NOT NULL OR NumeroCarta IS NOT NULL) -- Almeno uno tra UserID e NumeroCarta deve essere non NULL
    )
);

-- Creazione della tabella Retribuzione
CREATE TABLE Retribuzione (
    ID_transazione VARCHAR(50) PRIMARY KEY,
    data_esecuzione DATE,
    importo NUMERIC(10, 2),
    IBAN_beneficiario VARCHAR(27) REFERENCES Artista(IBAN)
);





-- Inserimento dati nella tabella Etichetta_Discografica
INSERT INTO Etichetta_Discografica (P_IVA, Indirizzo_sede_legale, anno_fondazione, nome_etichetta, percentuale_royalties)
VALUES
('12345678901', 'Via Roma 1, Milano', 1990, 'Sony Music', 15.50),
('98765432109', 'Via Dante 7, Napoli', 2000, 'Universal Music', 18.00),
('19283746509', 'Corso Torino 45, Torino', 1985, 'Warner Music', 12.75);

-- Inserimento dati nella tabella Artista
INSERT INTO Artista (CF, Nome, email, Data_di_nascita, IBAN, PIVA_etichetta)
VALUES
('RSSMRA85M01H501Z', 'Kanye West', 'kanye.west@example.com', '1977-06-08', 'IT60X0542811101000000123456', '12345678901'),
('VRDLGI90A01C351Z', 'Ed Sheeran', 'ed.sheeran@example.com', '1991-02-17', 'IT60X0542811101000000789123', '98765432109'),
('BNCLRA75P22H501Y', 'The Beatles', 'the.beatles@example.com', '1960-01-01', 'IT60X0542811101000000567890', '19283746509'),
('GSMNDR80A01H501W', 'Ariana Grande', 'ariana.grande@example.com', '1993-06-26', 'IT60X0542811101000000345678', '12345678901'),
('BRCANB70A01H501X', 'Bruno Mars', 'bruno.mars@example.com', '1985-10-08', 'IT60X0542811101000000456789', '98765432109'),
('LNDRSN60A01H501T', 'Adele', 'adele@example.com', '1988-05-05', 'IT60X0542811101000000234567', '19283746509'),
('SRHMLS90A01H501L', 'Taylor Swift', 'taylor.swift@example.com', '1989-12-13', 'IT60X0542811101000000129876', '12345678901'),
('WDBRDG80A01H501V', 'The Weeknd', 'the.weeknd@example.com', '1990-02-16', 'IT60X0542811101000000789876', '98765432109'),
('PRJHSN50A01H501K', 'Coldplay', 'coldplay@example.com', '1996-03-02', 'IT60X0542811101000000678945', '19283746509'),
('MRTNGR40A01H501G', 'Drake', 'drake@example.com', '1986-10-24', 'IT60X0542811101000000987654', '12345678901'),
('MSCSEL90A01H501P', 'Muschio Selvaggio', 'muschio.selvaggio@example.com', '2020-01-01', 'IT60X0542811101000000111111', '12345678901'),
('JWRGNR80A01H501J', 'Joe Rogan Experience', 'joe.rogan@example.com', '2009-12-24', 'IT60X0542811101000000222222', '98765432109'),
('CNNPLY00A01H501C', 'The Daily', 'the.daily@example.com', '2017-01-30', 'IT60X0542811101000000333333', '19283746509');

-- Inserimento dati nella tabella Album
INSERT INTO Album (Titolo, CF_artista, Genere, Durata, data_di_pubblicazione, Riproduzioni)
VALUES
('The Life of Pablo', 'RSSMRA85M01H501Z', 'Hip-Hop', 3600, '2016-02-14', 150000000),
('Divide', 'VRDLGI90A01C351Z', 'Pop', 4200, '2017-03-03', 100000000),
('Abbey Road', 'BNCLRA75P22H501Y', 'Rock', 3500, '1969-09-26', 200000000),
('Sweetener', 'GSMNDR80A01H501W', 'Pop', 3800, '2018-08-17', 90000000),
('24K Magic', 'BRCANB70A01H501X', 'R&B', 3200, '2016-11-18', 120000000),
('25', 'LNDRSN60A01H501T', 'Pop', 3000, '2015-11-20', 220000000),
('1989', 'SRHMLS90A01H501L', 'Pop', 3900, '2014-10-27', 250000000),
('Starboy', 'WDBRDG80A01H501V', 'R&B', 3600, '2016-11-25', 130000000),
('A Head Full of Dreams', 'PRJHSN50A01H501K', 'Rock', 3800, '2015-12-04', 80000000),
('Scorpion', 'MRTNGR40A01H501G', 'Hip-Hop', 4000, '2018-06-29', 110000000);

-- Inserimento dati nella tabella Canzone
INSERT INTO Canzone (Titolo, CF_artista, Titolo_album, Genere, Durata, Riproduzioni, numero_traccia, data_di_pubblicazione)
VALUES
('Ultralight Beam', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 320, 75000000, 1, '2016-02-14'),
('Father Stretch My Hands Pt 1', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 140, 60000000, 2, '2016-02-14'),
('Pt 2', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 125, 55000000, 3, '2016-02-14'),
('Famous', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 185, 80000000, 4, '2016-02-14'),
('Feedback', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 160, 45000000, 5, '2016-02-14'),
('Low Lights', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 150, 30000000, 6, '2016-02-14'),
('Highlights', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 230, 50000000, 7, '2016-02-14'),
('Freestyle 4', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 135, 40000000, 8, '2016-02-14'),
('I Love Kanye', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 45, 55000000, 9, '2016-02-14'),
('Waves', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 180, 70000000, 10, '2016-02-14'),
('FML', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 210, 65000000, 11, '2016-02-14'),
('Real Friends', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 270, 62000000, 12, '2016-02-14'),
('Wolves', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 255, 63000000, 13, '2016-02-14'),
('Silver Surfer Intermission', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 85, 22000000, 14, '2016-02-14'),
('30 Hours', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 300, 48000000, 15, '2016-02-14'),
('No More Parties in LA', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 380, 55000000, 16, '2016-02-14'),
('Facts Charlie Heat Version', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 180, 49000000, 17, '2016-02-14'),
('Fade', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 190, 69000000, 18, '2016-02-14'),
('Saint Pablo', 'RSSMRA85M01H501Z', 'The Life of Pablo', 'Hip-Hop', 360, 45000000, 19, '2016-02-14'),
('Eraser', 'VRDLGI90A01C351Z', 'Divide', 'Pop', 230, 5000000, 1, '2017-03-03'),
('Castle on the Hill', 'VRDLGI90A01C351Z', 'Divide', 'Pop', 270, 80000000, 2, '2017-03-03'),
('Dive', 'VRDLGI90A01C351Z', 'Divide', 'Pop', 240, 60000000, 3, '2017-03-03'),
('Shape of You', 'VRDLGI90A01C351Z', 'Divide', 'Pop', 240, 150000000, 4, '2017-03-03'),
('Perfect', 'VRDLGI90A01C351Z', 'Divide', 'Pop', 263, 140000000, 5, '2017-03-03'),
('Galway Girl', 'VRDLGI90A01C351Z', 'Divide', 'Pop', 173, 130000000, 6, '2017-03-03'),
('Happier', 'VRDLGI90A01C351Z', 'Divide', 'Pop', 207, 110000000, 7, '2017-03-03'),
('New Man', 'VRDLGI90A01C351Z', 'Divide', 'Pop', 180, 45000000, 8, '2017-03-03'),
('Hearts Dont Break Around Here', 'VRDLGI90A01C351Z', 'Divide', 'Pop', 240, 40000000, 9, '2017-03-03'),
('What Do I Know', 'VRDLGI90A01C351Z', 'Divide', 'Pop', 240, 60000000, 10, '2017-03-03'),
('How Would You Feel Paean', 'VRDLGI90A01C351Z', 'Divide', 'Pop', 268, 50000000, 11, '2017-03-03'),
('Supermarket Flowers', 'VRDLGI90A01C351Z', 'Divide', 'Pop', 211, 70000000, 12, '2017-03-03'),
('Come Together', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 260, 180000000, 1, '1969-09-26'),
('Something', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 182, 160000000, 2, '1969-09-26'),
('Maxwell Silver Hammer', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 207, 110000000, 3, '1969-09-26'),
('Oh Darling', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 207, 95000000, 4, '1969-09-26'),
('Octopus Garden', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 175, 85000000, 5, '1969-09-26'),
('I Want You Shes So Heavy', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 467, 75000000, 6, '1969-09-26'),
('Here Comes The Sun', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 185, 230000000, 7, '1969-09-26'),
('Because', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 163, 120000000, 8, '1969-09-26'),
('You Never Give Me Your Money', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 240, 110000000, 9, '1969-09-26'),
('Sun King', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 146, 80000000, 10, '1969-09-26'),
('Mean Mr Mustard', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 66, 70000000, 11, '1969-09-26'),
('Polythene Pam', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 70, 70000000, 12, '1969-09-26'),
('She Came In Through the Bathroom Window', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 115, 90000000, 13, '1969-09-26'),
('Golden Slumbers', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 90, 95000000, 14, '1969-09-26'),
('Carry That Weight', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 105, 100000000, 15, '1969-09-26'),
('The End', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 140, 110000000, 16, '1969-09-26'),
('Her Majesty', 'BNCLRA75P22H501Y', 'Abbey Road', 'Rock', 23, 60000000, 17, '1969-09-26'),
('Raindrops An Angel Cried', 'GSMNDR80A01H501W', 'Sweetener', 'Pop', 38, 50000000, 1, '2018-08-17'),
('Blazed', 'GSMNDR80A01H501W', 'Sweetener', 'Pop', 200, 70000000, 2, '2018-08-17'),
('The Light Is Coming', 'GSMNDR80A01H501W', 'Sweetener', 'Pop', 225, 65000000, 3, '2018-08-17'),
('R E M', 'GSMNDR80A01H501W', 'Sweetener', 'Pop', 240, 85000000, 4, '2018-08-17'),
('God Is a Woman', 'GSMNDR80A01H501W', 'Sweetener', 'Pop', 197, 200000000, 5, '2018-08-17'),
('Sweetener', 'GSMNDR80A01H501W', 'Sweetener', 'Pop', 207, 120000000, 6, '2018-08-17'),
('Successful', 'GSMNDR80A01H501W', 'Sweetener', 'Pop', 200, 70000000, 7, '2018-08-17'),
('Everytime', 'GSMNDR80A01H501W', 'Sweetener', 'Pop', 170, 60000000, 8, '2018-08-17'),
('Breathin', 'GSMNDR80A01H501W', 'Sweetener', 'Pop', 197, 250000000, 9, '2018-08-17'),
('No Tears Left to Cry', 'GSMNDR80A01H501W', 'Sweetener', 'Pop', 210, 300000000, 10, '2018-08-17'),
('Borderline', 'GSMNDR80A01H501W', 'Sweetener', 'Pop', 180, 40000000, 11, '2018-08-17'),
('Better Off', 'GSMNDR80A01H501W', 'Sweetener', 'Pop', 182, 50000000, 12, '2018-08-17'),
('Goodnight n Go', 'GSMNDR80A01H501W', 'Sweetener', 'Pop', 200, 60000000, 13, '2018-08-17'),
('Pete Davidson', 'GSMNDR80A01H501W', 'Sweetener', 'Pop', 72, 35000000, 14, '2018-08-17'),
('Get Well Soon', 'GSMNDR80A01H501W', 'Sweetener', 'Pop', 309, 80000000, 15, '2018-08-17'),
('24K Magic', 'BRCANB70A01H501X', '24K Magic', 'R&B', 215, 95000000, 1, '2016-10-07'),
('Chunky', 'BRCANB70A01H501X', '24K Magic', 'R&B', 223, 70000000, 2, '2016-11-18'),
('Perm', 'BRCANB70A01H501X', '24K Magic', 'R&B', 192, 65000000, 3, '2016-11-18'),
('That s What I Like', 'BRCANB70A01H501X', '24K Magic', 'R&B', 187, 180000000, 4, '2016-11-18'),
('Versace on the Floor', 'BRCANB70A01H501X', '24K Magic', 'R&B', 264, 140000000, 5, '2016-11-18'),
('Straight Up and Down', 'BRCANB70A01H501X', '24K Magic', 'R&B', 207, 60000000, 6, '2016-11-18'),
('Calling All My Lovelies', 'BRCANB70A01H501X', '24K Magic', 'R&B', 249, 50000000, 7, '2016-11-18'),
('Finesse', 'BRCANB70A01H501X', '24K Magic', 'R&B', 212, 85000000, 8, '2016-11-18'),
('Too Good to Say Goodbye', 'BRCANB70A01H501X', '24K Magic', 'R&B', 292, 55000000, 9, '2016-11-18'),
('Hello', 'LNDRSN60A01H501T', '25', 'Pop', 295, 220000000, 1, '2015-10-23'),
('Send My Love To Your New Lover', 'LNDRSN60A01H501T', '25', 'Pop', 223, 150000000, 2, '2015-11-20'),
('I Miss You', 'LNDRSN60A01H501T', '25', 'Pop', 295, 80000000, 3, '2015-11-20'),
('When We Were Young', 'LNDRSN60A01H501T', '25', 'Pop', 292, 120000000, 4, '2015-11-20'),
('Remedy', 'LNDRSN60A01H501T', '25', 'Pop', 240, 90000000, 5, '2015-11-20'),
('Water Under the Bridge', 'LNDRSN60A01H501T', '25', 'Pop', 240, 100000000, 6, '2015-11-20'),
('River Lea', 'LNDRSN60A01H501T', '25', 'Pop', 222, 70000000, 7, '2015-11-20'),
('Love in the Dark', 'LNDRSN60A01H501T', '25', 'Pop', 276, 85000000, 8, '2015-11-20'),
('Million Years Ago', 'LNDRSN60A01H501T', '25', 'Pop', 224, 75000000, 9, '2015-11-20'),
('All I Ask', 'LNDRSN60A01H501T', '25', 'Pop', 271, 60000000, 10, '2015-11-20'),
('Sweetest Devotion', 'LNDRSN60A01H501T', '25', 'Pop', 246, 70000000, 11, '2015-11-20'),
('Welcome to New York', 'SRHMLS90A01H501L', '1989', 'Pop', 212, 140000000, 1, '2014-10-27'),
('Blank Space', 'SRHMLS90A01H501L', '1989', 'Pop', 231, 260000000, 2, '2014-11-10'),
('Style', 'SRHMLS90A01H501L', '1989', 'Pop', 231, 180000000, 3, '2014-10-27'),
('Out of the Woods', 'SRHMLS90A01H501L', '1989', 'Pop', 235, 110000000, 4, '2014-10-27'),
('All You Had to Do Was Stay', 'SRHMLS90A01H501L', '1989', 'Pop', 193, 90000000, 5, '2014-10-27'),
('Shake It Off', 'SRHMLS90A01H501L', '1989', 'Pop', 219, 300000000, 6, '2014-08-18'),
('I Wish You Would', 'SRHMLS90A01H501L', '1989', 'Pop', 207, 85000000, 7, '2014-10-27'),
('Bad Blood', 'SRHMLS90A01H501L', '1989', 'Pop', 185, 210000000, 8, '2014-10-27'),
('Wildest Dreams', 'SRHMLS90A01H501L', '1989', 'Pop', 230, 220000000, 9, '2014-10-27'),
('How You Get the Girl', 'SRHMLS90A01H501L', '1989', 'Pop', 243, 95000000, 10, '2014-10-27'),
('This Love', 'SRHMLS90A01H501L', '1989', 'Pop', 244, 70000000, 11, '2014-10-27'),
('I Know Places', 'SRHMLS90A01H501L', '1989', 'Pop', 197, 80000000, 12, '2014-10-27'),
('Clean', 'SRHMLS90A01H501L', '1989', 'Pop', 270, 75000000, 13, '2014-10-27'),
('Starboy', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 230, 140000000, 1, '2016-09-22'),
('Party Monster', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 241, 100000000, 2, '2016-11-25'),
('False Alarm', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 227, 80000000, 3, '2016-09-29'),
('Reminder', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 221, 110000000, 4, '2016-11-25'),
('Rockin', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 203, 70000000, 5, '2016-11-25'),
('Secrets', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 236, 90000000, 6, '2016-11-25'),
('True Colors', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 230, 65000000, 7, '2016-11-25'),
('Stargirl Interlude', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 150, 55000000, 8, '2016-11-25'),
('Sidewalks', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 222, 78000000, 9, '2016-11-25'),
('Six Feet Under', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 209, 67000000, 10, '2016-11-25'),
('Love to Lay', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 210, 69000000, 11, '2016-11-25'),
('A Lonely Night', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 230, 63000000, 12, '2016-11-25'),
('Attention', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 230, 65000000, 13, '2016-11-25'),
('Ordinary Life', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 230, 59000000, 14, '2016-11-25'),
('Nothing Without You', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 230, 62000000, 15, '2016-11-25'),
('All I Know', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 320, 61000000, 16, '2016-11-25'),
('Die for You', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 260, 140000000, 17, '2016-11-25'),
('I Feel It Coming', 'WDBRDG80A01H501V', 'Starboy', 'R&B', 240, 160000000, 18, '2016-11-25'),
('A Head Full of Dreams', 'PRJHSN50A01H501K', 'A Head Full of Dreams', 'Rock', 230, 90000000, 1, '2015-12-04'),
('Birds', 'PRJHSN50A01H501K', 'A Head Full of Dreams', 'Rock', 230, 60000000, 2, '2015-12-04'),
('Hymn for the Weekend', 'PRJHSN50A01H501K', 'A Head Full of Dreams', 'Rock', 262, 200000000, 3, '2015-12-04'),
('Everglow', 'PRJHSN50A01H501K', 'A Head Full of Dreams', 'Rock', 287, 75000000, 4, '2015-12-04'),
('Adventure of a Lifetime', 'PRJHSN50A01H501K', 'A Head Full of Dreams', 'Rock', 250, 160000000, 5, '2015-11-06'),
('Fun', 'PRJHSN50A01H501K', 'A Head Full of Dreams', 'Rock', 270, 50000000, 6, '2015-12-04'),
('Kaleidoscope', 'PRJHSN50A01H501K', 'A Head Full of Dreams', 'Rock', 100, 30000000, 7, '2015-12-04'),
('Army of One', 'PRJHSN50A01H501K', 'A Head Full of Dreams', 'Rock', 360, 45000000, 8, '2015-12-04'),
('Amazing Day', 'PRJHSN50A01H501K', 'A Head Full of Dreams', 'Rock', 288, 40000000, 9, '2015-12-04'),
('Colour Spectrum', 'PRJHSN50A01H501K', 'A Head Full of Dreams', 'Rock', 87, 25000000, 10, '2015-12-04'),
('Up&Up', 'PRJHSN50A01H501K', 'A Head Full of Dreams', 'Rock', 403, 70000000, 11, '2015-12-04'),
('Survival', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 217, 70000000, 1, '2018-06-29'),
('Nonstop', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 217, 160000000, 2, '2018-06-29'),
('Elevate', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 228, 90000000, 3, '2018-06-29'),
('Emotionless', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 308, 95000000, 4, '2018-06-29'),
('Gods Plan', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 198, 130000000, 5, '2018-01-19'),
('I m Upset', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 211, 110000000, 6, '2018-05-26'),
('8 Out of 10', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 193, 80000000, 7, '2018-06-29'),
('Mob Ties', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 216, 95000000, 8, '2018-06-29'),
('Can t Take a Joke', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 178, 85000000, 9, '2018-06-29'),
('Sandra s Rose', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 210, 60000000, 10, '2018-06-29'),
('Talk Up', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 203, 70000000, 11, '2018-06-29'),
('Is There More', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 224, 65000000, 12, '2018-06-29'),
('Peak', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 211, 62000000, 13, '2018-06-29'),
('Summer Games', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 241, 58000000, 14, '2018-06-29'),
('Jaded', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 257, 60000000, 15, '2018-06-29'),
('Nice for What', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 211, 240000000, 16, '2018-06-29'),
('Finesse', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 222, 78000000, 17, '2018-06-29'),
('Ratchet Happy Birthday', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 220, 49000000, 18, '2018-06-29'),
('That s How You Feel', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 163, 53000000, 19, '2018-06-29'),
('Blue Tint', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 175, 72000000, 20, '2018-06-29'),
('In My Feelings', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 213, 250000000, 21, '2018-06-29'),
('Don t Matter to Me', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 248, 100000000, 22, '2018-06-29'),
('After Dark', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 314, 72000000, 23, '2018-06-29'),
('Final Fantasy', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 239, 51000000, 24, '2018-06-29'),
('March 14', 'MRTNGR40A01H501G', 'Scorpion', 'Hip-Hop', 303, 57000000, 25, '2018-06-29');

-- Inserimento dati nella tabella Episodio
INSERT INTO Episodio (Titolo, CF_artista, Genere, Durata, riproduzioni, data_di_pubblicazione)
VALUES
('Episodio 1 - Intervista con Fedez', 'MSCSEL90A01H501P', 'Podcast', 3600, 1000000, '2021-01-01'),
('Episodio 2 - Chiara Ferragni e l imprenditoria', 'MSCSEL90A01H501P', 'Podcast', 3400, 900000, '2021-01-08'),
('Episodio 3 - La musica e il cambiamento', 'MSCSEL90A01H501P', 'Podcast', 3800, 950000, '2021-01-15'),
('Episodio 4 - Il futuro del digitale', 'MSCSEL90A01H501P', 'Podcast', 4000, 1100000, '2021-01-22'),
('Episodio 5 - Il mondo delle start-up', 'MSCSEL90A01H501P', 'Podcast', 3500, 1050000, '2021-01-29'),
('Episodio 1 - Elon Musk talks SpaceX and Tesla', 'JWRGNR80A01H501J', 'Podcast', 7200, 5000000, '2019-09-07'),
('Episodio 2 - The Science of Nutrition with Dr Rhonda Patrick', 'JWRGNR80A01H501J', 'Podcast', 6900, 4500000, '2019-09-14'),
('Episodio 3 - Discussing Politics with Ben Shapiro', 'JWRGNR80A01H501J', 'Podcast', 6800, 4700000, '2019-09-21'),
('Episodio 4 - MMA and Mental Health with Georges St-Pierre', 'JWRGNR80A01H501J', 'Podcast', 7100, 4800000, '2019-09-28'),
('Episodio 5 - Exploring the Universe with Neil deGrasse Tyson', 'JWRGNR80A01H501J', 'Podcast', 7300, 5200000, '2019-10-05'),
('Episodio 1 - The Impeachment of Donald Trump', 'CNNPLY00A01H501C', 'Podcast', 1800, 3000000, '2020-01-20'),
('Episodio 2 - The COVID-19 Pandemic Explained', 'CNNPLY00A01H501C', 'Podcast', 1900, 3200000, '2020-01-27'),
('Episodio 3 - The Black Lives Matter Movement', 'CNNPLY00A01H501C', 'Podcast', 1700, 3100000, '2020-02-03'),
('Episodio 4 - The 2020 Presidential Election', 'CNNPLY00A01H501C', 'Podcast', 2000, 3300000, '2020-02-10'),
('Episodio 5 - Climate Change and Global Policy', 'CNNPLY00A01H501C', 'Podcast', 1850, 3400000, '2020-02-17');

-- Inserimento dati nella tabella Utente
INSERT INTO Utente (Username, Nome, Cognome, email)
VALUES
('user1', 'Alice', 'Rossi', 'alice.rossi@example.com'),
('user2', 'Mario', 'Bianchi', 'mario.bianchi@example.com'),
('user3', 'Carla', 'Verdi', 'carla.verdi@example.com');

-- Inserimento dati nella tabella Playlist
INSERT INTO Playlist (Nome, Username_utente, Visibilita_pubblica)
VALUES
('Top 50 Rock Classics', 'user2', TRUE),
('Evening Chill', 'user2', FALSE),
('Party Anthems', 'user2', TRUE),
('Road Trip Vibes', 'user1', TRUE),
('Relaxing Sunday', 'user1', FALSE),
('Workout Hits', 'user1', TRUE);

-- Inserimento dati nella tabella Appartiene
INSERT INTO Appartiene (Nome_playlist, Username_utente, Titolo_canzone, CF_artista, Titolo_album)
VALUES
('Top 50 Rock Classics', 'user2', 'Come Together', 'BNCLRA75P22H501Y', 'Abbey Road'),
('Top 50 Rock Classics', 'user2', 'Something', 'BNCLRA75P22H501Y', 'Abbey Road'),
('Top 50 Rock Classics', 'user2', 'Maxwell Silver Hammer', 'BNCLRA75P22H501Y', 'Abbey Road'),
('Top 50 Rock Classics', 'user2', 'Oh Darling', 'BNCLRA75P22H501Y', 'Abbey Road'),
('Top 50 Rock Classics', 'user2', 'I Want You Shes So Heavy', 'BNCLRA75P22H501Y', 'Abbey Road'),
('Top 50 Rock Classics', 'user2', 'Here Comes The Sun', 'BNCLRA75P22H501Y', 'Abbey Road'),
('Top 50 Rock Classics', 'user2', 'The End', 'BNCLRA75P22H501Y', 'Abbey Road'),
('Top 50 Rock Classics', 'user2', 'Sun King', 'BNCLRA75P22H501Y', 'Abbey Road'),
('Top 50 Rock Classics', 'user2', 'Polythene Pam', 'BNCLRA75P22H501Y', 'Abbey Road'),
('Top 50 Rock Classics', 'user2', 'Golden Slumbers', 'BNCLRA75P22H501Y', 'Abbey Road'),
('Evening Chill', 'user2', 'No Tears Left to Cry', 'GSMNDR80A01H501W', 'Sweetener'),
('Evening Chill', 'user2', 'God Is a Woman', 'GSMNDR80A01H501W', 'Sweetener'),
('Evening Chill', 'user2', 'R E M', 'GSMNDR80A01H501W', 'Sweetener'),
('Evening Chill', 'user2', 'Sweetener', 'GSMNDR80A01H501W', 'Sweetener'),
('Evening Chill', 'user2', 'Breathin', 'GSMNDR80A01H501W', 'Sweetener'),
('Evening Chill', 'user2', 'Goodnight n Go', 'GSMNDR80A01H501W', 'Sweetener'),
('Evening Chill', 'user2', 'Everytime', 'GSMNDR80A01H501W', 'Sweetener'),
('Evening Chill', 'user2', 'Better Off', 'GSMNDR80A01H501W', 'Sweetener'),
('Evening Chill', 'user2', 'Pete Davidson', 'GSMNDR80A01H501W', 'Sweetener'),
('Evening Chill', 'user2', 'Get Well Soon', 'GSMNDR80A01H501W', 'Sweetener'),
('Party Anthems', 'user2', '24K Magic', 'BRCANB70A01H501X', '24K Magic'),
('Party Anthems', 'user2', 'Chunky', 'BRCANB70A01H501X', '24K Magic'),
('Party Anthems', 'user2', 'That s What I Like', 'BRCANB70A01H501X', '24K Magic'),
('Party Anthems', 'user2', 'Perm', 'BRCANB70A01H501X', '24K Magic'),
('Party Anthems', 'user2', 'Versace on the Floor', 'BRCANB70A01H501X', '24K Magic'),
('Party Anthems', 'user2', 'Finesse', 'BRCANB70A01H501X', '24K Magic'),
('Party Anthems', 'user2', 'Calling All My Lovelies', 'BRCANB70A01H501X', '24K Magic'),
('Party Anthems', 'user2', 'Straight Up and Down', 'BRCANB70A01H501X', '24K Magic'),
('Road Trip Vibes', 'user1', 'Shape of You', 'VRDLGI90A01C351Z', 'Divide'),
('Road Trip Vibes', 'user1', 'Castle on the Hill', 'VRDLGI90A01C351Z', 'Divide'),
('Road Trip Vibes', 'user1', 'Galway Girl', 'VRDLGI90A01C351Z', 'Divide'),
('Road Trip Vibes', 'user1', 'Perfect', 'VRDLGI90A01C351Z', 'Divide'),
('Road Trip Vibes', 'user1', 'Happier', 'VRDLGI90A01C351Z', 'Divide'),
('Road Trip Vibes', 'user1', 'Eraser', 'VRDLGI90A01C351Z', 'Divide'),
('Road Trip Vibes', 'user1', 'New Man', 'VRDLGI90A01C351Z', 'Divide'),
('Relaxing Sunday', 'user1', 'Hello', 'LNDRSN60A01H501T', '25'),
('Relaxing Sunday', 'user1', 'When We Were Young', 'LNDRSN60A01H501T', '25'),
('Relaxing Sunday', 'user1', 'Million Years Ago', 'LNDRSN60A01H501T', '25'),
('Relaxing Sunday', 'user1', 'Remedy', 'LNDRSN60A01H501T', '25'),
('Relaxing Sunday', 'user1', 'Love in the Dark', 'LNDRSN60A01H501T', '25'),
('Relaxing Sunday', 'user1', 'Send My Love To Your New Lover', 'LNDRSN60A01H501T', '25'),
('Relaxing Sunday', 'user1', 'All I Ask', 'LNDRSN60A01H501T', '25'),
('Relaxing Sunday', 'user1', 'River Lea', 'LNDRSN60A01H501T', '25'),
('Workout Hits', 'user1', 'Nonstop', 'MRTNGR40A01H501G', 'Scorpion'),
('Workout Hits', 'user1', 'Elevate', 'MRTNGR40A01H501G', 'Scorpion'),
('Workout Hits', 'user1', 'Nice for What', 'MRTNGR40A01H501G', 'Scorpion'),
('Workout Hits', 'user1', 'Mob Ties', 'MRTNGR40A01H501G', 'Scorpion'),
('Workout Hits', 'user1', 'Can t Take a Joke', 'MRTNGR40A01H501G', 'Scorpion'),
('Workout Hits', 'user1', 'Talk Up', 'MRTNGR40A01H501G', 'Scorpion'),
('Workout Hits', 'user1', 'Summer Games', 'MRTNGR40A01H501G', 'Scorpion');

-- Inserimento dati nella tabella Preferenza_Brani
INSERT INTO Preferenza_Brani (Username_utente, Titolo_canzone, CF_artista, Titolo_album)
VALUES
('user1', 'Shape of You', 'VRDLGI90A01C351Z', 'Divide'),
('user1', 'Castle on the Hill', 'VRDLGI90A01C351Z', 'Divide'),
('user1', 'Hello', 'LNDRSN60A01H501T', '25'),
('user1', 'Gods Plan', 'MRTNGR40A01H501G', 'Scorpion'),
('user1', 'Perfect', 'VRDLGI90A01C351Z', 'Divide'),
('user2', 'Come Together', 'BNCLRA75P22H501Y', 'Abbey Road'),
('user2', 'Here Comes The Sun', 'BNCLRA75P22H501Y', 'Abbey Road'),
('user2', 'No Tears Left to Cry', 'GSMNDR80A01H501W', 'Sweetener'),
('user2', '24K Magic', 'BRCANB70A01H501X', '24K Magic'),
('user2', 'Blazed', 'GSMNDR80A01H501W', 'Sweetener'),
('user3', 'Blank Space', 'SRHMLS90A01H501L', '1989'),
('user3', 'Style', 'SRHMLS90A01H501L', '1989'),
('user3', 'Adventure of a Lifetime', 'PRJHSN50A01H501K', 'A Head Full of Dreams'),
('user3', 'Starboy', 'WDBRDG80A01H501V', 'Starboy'),
('user3', 'Die for You', 'WDBRDG80A01H501V', 'Starboy');

-- Inserimento dati nella tabella Preferenza_Episodi
INSERT INTO Preferenza_Episodi (Username_utente, Titolo_episodio, CF_artista)
VALUES
('user1', 'Episodio 1 - The Impeachment of Donald Trump', 'CNNPLY00A01H501C'),
('user1', 'Episodio 2 - The COVID-19 Pandemic Explained', 'CNNPLY00A01H501C'),
('user2', 'Episodio 3 - Discussing Politics with Ben Shapiro', 'JWRGNR80A01H501J'),
('user2', 'Episodio 5 - Exploring the Universe with Neil deGrasse Tyson', 'JWRGNR80A01H501J'),
('user2', 'Episodio 3 - The Black Lives Matter Movement', 'CNNPLY00A01H501C'),
('user3', 'Episodio 5 - Il mondo delle start-up', 'MSCSEL90A01H501P'),
('user3', 'Episodio 4 - Il futuro del digitale', 'MSCSEL90A01H501P');

-- Inserimento dati nella tabella Abbonamento
INSERT INTO Abbonamento (ID, Data_sottoscrizione, Data_scadenza, Prezzo, utente_abbonato)
VALUES
('ABB001', '2023-01-01', '2024-02-01', 9.99, 'user1'),
('ABB002', '2023-02-15', '2024-02-15', 119.99, 'user2'),
('ABB003', '2023-03-10', '2023-04-10', 9.99, 'user3');

-- Inserimento dati nella tabella Servizio_terzo
INSERT INTO Servizio_terzo (UserID, nome_servizio)
VALUES
('alice.rossi@appleid.com', 'Apple Pay'),
('carla.verdi@paypalid.com', 'PayPal');

-- Inserimento dati nella tabella Carta_di_credito
INSERT INTO Carta_di_credito (Numero, intestatario, data_scadenza, CVV, circuito)
VALUES
('1234567812345678', 'Alice Rossi', '2025-06-30', '123', 'Visa'),
('8765432187654321', 'Mario Bianchi', '2024-12-31', '456', 'MasterCard');

-- Inserimento dati nella tabella Metodo_di_pagamento
INSERT INTO Metodo_di_pagamento (Username, UserID, NumeroCarta)
VALUES
('user1', 'alice.rossi@appleid.com', NULL),  -- Utente 1 con solo servizio di terzi (es. Apple Pay)
('user2', NULL, '1234567812345678'),  -- Utente 2 con solo carta di credito
('user3', 'carla.verdi@paypalid.com', '8765432187654321');  -- Utente 3 con sia carta di credito che PayPal
          

-- Inserimento dati nella tabella Retribuzione
INSERT INTO Retribuzione (ID_transazione, data_esecuzione, importo, IBAN_beneficiario)
VALUES
('TRANS001', '2023-06-15', 500.00, 'IT60X0542811101000000123456'),  
('TRANS002', '2023-07-20', 450.00, 'IT60X0542811101000000789123'),  
('TRANS003', '2023-08-10', 600.00, 'IT60X0542811101000000567890'),  
('TRANS004', '2023-06-30', 550.00, 'IT60X0542811101000000345678'),  
('TRANS005', '2023-07-05', 500.00, 'IT60X0542811101000000456789'), 
('TRANS006', '2023-06-25', 700.00, 'IT60X0542811101000000234567'),  
('TRANS007', '2023-07-15', 650.00, 'IT60X0542811101000000129876'),  
('TRANS008', '2023-08-01', 600.00, 'IT60X0542811101000000789876'),  
('TRANS009', '2023-07-25', 550.00, 'IT60X0542811101000000678945'),  
('TRANS010', '2023-06-20', 620.00, 'IT60X0542811101000000987654');  