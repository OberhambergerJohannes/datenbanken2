--b
CREATE OR REPLACE TYPE Ort_Typ AS OBJECT (
    OrtId INTEGER,
    Postleitzahl INTEGER,
    Bezeichnung VARCHAR2(50)
);
/

CREATE OR REPLACE TYPE Immobilien_Typ AS OBJECT (
    ImmobilienId INTEGER,
    Bezeichnung VARCHAR2(100),
    Beschreibung VARCHAR2(1000),
    Ort REF Ort_Typ
)NOT FINAL NOT INSTANTIABLE;
/

CREATE OR REPLACE TYPE Zimmer_Typ AS OBJECT (
    ZimmerId INTEGER,
    Größe INTEGER,
    Typ VARCHAR2(50),
    Ausstattung VARCHAR2(100)
);
/

CREATE OR REPLACE TYPE Zimmer_Nested_Table_Typ AS TABLE OF Zimmer_Typ;
/

CREATE OR REPLACE TYPE Grundstücke_Typ UNDER Immobilien_Typ (
    Größe INTEGER,
    Lage VARCHAR2(50)
) NOT FINAL INSTANTIABLE;
/

CREATE OR REPLACE TYPE Gebäude_Typ UNDER Immobilien_Typ (
    ZimmerPositionen Zimmer_Nested_Table_Typ,
    Auf_Grundstück REF Grundstücke_Typ
)NOT FINAL INSTANTIABLE;
/

CREATE OR REPLACE TYPE Gebäude_REF_Nested_Table_Typ AS TABLE OF REF Gebäude_Typ;
/

ALTER TYPE Grundstücke_Typ 
ADD ATTRIBUTE (GebäudeRefNested Gebäude_REF_Nested_Table_Typ)
CASCADE;
/


CREATE OR REPLACE TYPE Seegrundstücke_Typ UNDER Grundstücke_Typ (
    Seezugangsfläche INTEGER
) FINAL INSTANTIABLE;
/

CREATE OR REPLACE TYPE Waldgrundstücke_Typ UNDER Grundstücke_Typ (
    Waldtyp VARCHAR2(100)
) FINAL INSTANTIABLE;
/

CREATE OR REPLACE TYPE Immobilien_REF_NESTED_TABLE AS TABLE OF REF Immobilien_Typ;
/

CREATE OR REPLACE TYPE Makler_Typ AS OBJECT (
    MaklerId INTEGER,
    Vorname VARCHAR2(100),
    Nachname VARCHAR2(100),
    Geburtsdatum DATE,
    AngestelltSeit DATE,
    RefImmobilien Immobilien_REF_NESTED_TABLE
) FINAL INSTANTIABLE;
/

CREATE TABLE Ort_Tab OF Ort_Typ (
    OrtId PRIMARY KEY
);
/

CREATE TABLE Immobilien_Tab OF Immobilien_Typ (
    ImmobilienId PRIMARY KEY
);
/

CREATE TABLE Makler_Tab OF Makler_Typ (
    MaklerId PRIMARY KEY
)
NESTED TABLE RefImmobilien STORE AS Makler_REF_Immobilien;
/

--c
INSERT INTO Ort_Tab VALUES (
    Ort_Typ(1, 4040, 'Helms Klamm')
);

INSERT INTO Immobilien_Tab VALUES (
    Gebäude_Typ(
        1,
        'Bilbos Hobbithütte',
        'Kein Ort für wilde Parties',
        (SELECT REF(o) FROM ORT_TAB o WHERE o.ORTID = 1),
        Zimmer_Nested_Table_Typ(
            Zimmer_Typ(1, 50, 'Küch-Wohnzimmer', 'Tisch, Sessel'),
            Zimmer_Typ(2, 12, 'Schlafzimmer', 'Bett, Kleiderschrank'),
            Zimmer_Typ(3, 18, 'Garderobe', 'Garderobenständer')
        ),
        NULL
    )
);

INSERT INTO Immobilien_Tab VALUES (
    WALDGRUNDSTÜCKE_TYP(
        2,
        'Eisengard',
        'They are taking the Hobbits to Eisengard',
        (SELECT REF(o) FROM ORT_TAB o WHERE o.ORTID = 1),
        7000,
        'coole Lage',
        Gebäude_REF_Nested_Table_Typ((SELECT TREAT(REF(gebäude) AS REF Gebäude_Typ)
            FROM Immobilien_Tab gebäude
            WHERE gebäude.ImmobilienId = 1)),
        'Tannenwald'
    )
);

UPDATE Immobilien_Tab tab
SET VALUE(tab) = Gebäude_Typ(
    tab.ImmobilienId,
    tab.Bezeichnung,
    tab.Beschreibung,
    tab.Ort,
    TREAT(VALUE(tab) AS Gebäude_Typ).ZimmerPositionen,
    (SELECT TREAT(REF(grundstück) AS REF Grundstücke_Typ)
	FROM Immobilien_Tab grundstück
	WHERE grundstück.ImmobilienId = 2)
)
WHERE tab.ImmobilienId = 1;



INSERT INTO Immobilien_Tab VALUES (
    Gebäude_Typ(
        3,
        'Benkos Ultravilla',
        'Gehört der Mutter',
        (SELECT REF(o) FROM ORT_TAB o WHERE o.ORTID = 1),
        Zimmer_Nested_Table_Typ(
            Zimmer_Typ(4, 100012, 'Küch-Wohnzimmer', 'Butler, Guccimesser'),
            Zimmer_Typ(5, 67, 'Abstellkammer', 'Gucci-Abstellregal'),
            Zimmer_Typ(6, 100000, 'Benkos Kinderzimmer', 'Ultramega-Guccibett'),
            Zimmer_Typ(7, 10000, 'Rooftop Skyview Pool', 'Ultramega-Guccipool')
        ),
        NULL
    )
);

INSERT INTO Immobilien_Tab VALUES (
        WALDGRUNDSTÜCKE_TYP(
        4,
        'Benkos Privatvilla',
        'Villa eines ehemaligen Kakaoherstellers',
        (SELECT REF(o) FROM ORT_TAB o WHERE o.ORTID = 1),
        5000,
        'Richtig cooler Seezugang für Reiche',
        Gebäude_REF_Nested_Table_Typ((SELECT TREAT(REF(gebäude) AS REF Gebäude_Typ)
            FROM Immobilien_Tab gebäude
            WHERE gebäude.ImmobilienId = 3)),
        1000
    )
);

UPDATE Immobilien_Tab it
SET VALUE(it) = Gebäude_Typ(
    it.ImmobilienId,
    it.Bezeichnung,
    it.Beschreibung,
    it.Ort,
    TREAT(VALUE(it) AS Gebäude_Typ).ZimmerPositionen,
    (SELECT TREAT(REF(grundstück) AS REF Grundstücke_Typ)
	FROM Immobilien_Tab grundstück
	WHERE grundstück.ImmobilienId = 4)
)
WHERE it.ImmobilienId = 3;

INSERT INTO Makler_Tab VALUES (
    Makler_Typ(
        1,
        'Karl', 
        'Klammer', 
        TO_DATE('2000-01-01', 'YYYY-MM-DD'),
        TO_DATE('2025-11-11', 'YYYY-MM-DD'), 
        Immobilien_REF_NESTED_TABLE(
            (SELECT REF(i) FROM Immobilien_Tab i WHERE i.ImmobilienId = 1),
            (SELECT REF(i) FROM Immobilien_Tab i WHERE i.ImmobilienId = 2),
            (SELECT REF(i) FROM Immobilien_Tab i WHERE i.ImmobilienId = 3),
            (SELECT REF(i) FROM Immobilien_Tab i WHERE i.ImmobilienId = 4)
        )
    )
);

SELECT im_tab.ImmobilienId,
im_tab.Bezeichnung,
im_tab.BESCHREIBUNG,
DEREF(im_tab.ORT)
FROM Immobilien_Tab im_tab;
/

SELECT
ma_tab.MAKLERID,
ma_tab.NACHNAME,
ma_tab.REFIMMOBILIEN
FROM MAKLER_TAB ma_tab;
/

/*
DROP TYPE Ort_Typ FORCE;
DROP TYPE Immobilien_Typ FORCE;
DROP TYPE Zimmer_Typ FORCE;
DROP TYPE Zimmer_Nested_Table_Typ FORCE;
DROP TYPE Grundstücke_Typ FORCE;
DROP TYPE Gebäude_Typ FORCE;
DROP TYPE Gebäude_REF_Nested_Table_Typ FORCE;
DROP TYPE Grundstücke_Typ FORCE;
DROP TYPE Seegrundstücke_Typ FORCE;
DROP TYPE Waldgrundstücke_Typ FORCE;
DROP TYPE Immobilien_REF_NESTED_TABLE FORCE;
DROP TYPE Makler_Typ FORCE;

Drop TABLE Immobilien_Tab CASCADE CONSTRAINT;
Drop TABLE Makler_Tab CASCADE CONSTRAINT;
Drop TABLE Ort_Tab CASCADE CONSTRAINT;
Drop TABLE Makler_REF_Immobilien CASCADE CONSTRAINT;
*/

--2
CREATE TABLE Fahrzeug (
    FahrzeugNr NUMBER(4) PRIMARY KEY,
    Gewicht NUMBER(6));

CREATE TABLE Auto (
    FahrzeugNr NUMBER(4) PRIMARY KEY,
    MaxGeschwindigkeit NUMBER(6),
    FOREIGN KEY (FahrzeugNr)
    REFERENCES Fahrzeug);

CREATE TABLE Fahrrad (
    FahrzeugNr NUMBER(4) PRIMARY KEY,
    Rahmenhoehe NUMBER(6),
    FOREIGN KEY (FahrzeugNr)
    REFERENCES Fahrzeug);

CREATE TABLE EBike (
    FahrzeugNr NUMBER(4) PRIMARY KEY,
    MaxReichweite NUMBER(6),
    FOREIGN KEY (FahrzeugNr)
    REFERENCES Fahrrad);

INSERT INTO Fahrzeug (FahrzeugNr, Gewicht) VALUES (0, 700);
INSERT INTO Fahrzeug (FahrzeugNr, Gewicht) VALUES (1, 1500);
INSERT INTO Fahrzeug (FahrzeugNr, Gewicht) VALUES (2, 15);
INSERT INTO Fahrzeug (FahrzeugNr, Gewicht) VALUES (3, 22);
INSERT INTO Auto (FahrzeugNr, MaxGeschwindigkeit) VALUES (1, 170);
INSERT INTO Fahrrad (FahrzeugNr, Rahmenhoehe) VALUES (2, 46);
INSERT INTO Fahrrad (FahrzeugNr, Rahmenhoehe) VALUES (3, 50);
INSERT INTO EBike (FahrzeugNr, MaxReichweite) VALUES (3, 140);

--a
CREATE OR REPLACE TYPE Fahrzeug_Typ AS OBJECT (
    FahrzeugNr NUMBER(4),
    Gewicht NUMBER(6)
) NOT FINAL;
/

CREATE OR REPLACE TYPE Auto_Typ UNDER Fahrzeug_Typ(
    MaxGeschwindigkeit NUMBER(6)
);
/

CREATE OR REPLACE TYPE EBike_Typ UNDER Fahrzeug_Typ(
    Rahmenhoehe NUMBER,
    MaxReichweite NUMBER(6)
);
/

CREATE OR REPLACE VIEW Fahrzeug_Typ_View 
OF Fahrzeug_Typ  
WITH OBJECT IDENTIFIER (FahrzeugNr)
AS 
SELECT Fahrzeug_Typ(f.FahrzeugNr, f.Gewicht)
FROM Fahrzeug f;
/

CREATE OR REPLACE VIEW Auto_Typ_View
OF Auto_Typ
UNDER Fahrzeug_Typ_View
AS
SELECT f.FahrzeugNr,f.Gewicht,a.MaxGeschwindigkeit
FROM Fahrzeug f
JOIN Auto a 
ON f.FahrzeugNr = a.FahrzeugNr;
/

CREATE OR REPLACE VIEW EBike_Typ_View
OF EBike_Typ
UNDER Fahrzeug_Typ_View
AS 
SELECT f.FahrzeugNr, f.Gewicht, r.Rahmenhoehe, e.MaxReichweite
FROM Fahrzeug f
JOIN Fahrrad r ON r.FahrzeugNr = f.FahrzeugNr
JOIN EBike e ON e.FahrzeugNr = r.FahrzeugNr
/

--b
SELECT VALUE(f) FROM Fahrzeug_Typ_View f;
SELECT REF(a) FROM Auto_Typ_View a;
SELECT VALUE(e).FahrzeugNr, VALUE(e).Gewicht, VALUE(e).Rahmenhoehe, VALUE(e).MaxReichweite FROM EBike_Typ_View e;
SELECT VALUE(f) FROM Fahrzeug_Typ_View f WHERE VALUE(f) IS OF (ONLY Fahrzeug_Typ);