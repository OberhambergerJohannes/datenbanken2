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

CREATE OR REPLACE TYPE Zimmer_NESTED_TABLE_TYPE AS TABLE OF Zimmer_Typ;
/

CREATE OR REPLACE TYPE Grundstücke_Typ UNDER Immobilien_Typ (
    Größe INTEGER,
    Lage VARCHAR2(50)
) NOT FINAL INSTANTIABLE;
/

CREATE OR REPLACE TYPE Gebäude_Typ UNDER Immobilien_Typ (
    ZimmerPositionen Zimmer_NESTED_TABLE_TYPE,
    Auf_Grundstück REF Grundstücke_Typ
)NOT FINAL INSTANTIABLE;
/

CREATE OR REPLACE TYPE Gebäude_NESTED_TABLE_TYPE AS TABLE OF Gebäude_Typ;
/

ALTER TYPE Grundstücke_Typ
ADD ATTRIBUTE (GebäudeNested Gebäude_NESTED_TABLE_TYPE)
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

CREATE OR REPLACE TYPE Makler_Typ AS OBJECT (
    MaklerId INTEGER,
    Vorname VARCHAR2(100),
    Nachname VARCHAR2(100),
    Geburtsdatum DATE,
    AngestelltSeit DATE
) FINAL INSTANTIABLE;
/

CREATE TABLE Ort_Tab OF Ort_Typ (
    OrtId PRIMARY KEY
) OBJECT IDENTIFIER IS PRIMARY KEY;

CREATE TABLE Immobilien_Tab OF Immobilien_Typ (
    ImmobilienId PRIMARY KEY
)OBJECT IDENTIFIER IS PRIMARY KEY;

CREATE TABLE Makler_Tab OF Makler_Typ (
    MaklerId PRIMARY KEY
);

--c
INSERT INTO Ort_Tab VALUES (
    Ort_Typ(1, 4040, 'Helms Klamm')
);

INSERT INTO Makler_Tab VALUES (
    Makler_Typ(1, 'Karl', 'Klammer', TO_DATE('2000-01-01', 'YYYY-MM-DD'), TO_DATE('2025-11-11', 'YYYY-MM-DD'))
);

INSERT INTO Immobilien_Tab VALUES (
    Waldgrundstücke_Typ(
        1,
        'Eisengard',
        'They are taking the Hobbits to Eisengard',
        (SELECT REF(o) FROM Ort_Tab o WHERE o.OrtId = 1),
        7000,
        'Cool',
        Gebäude_NESTED_TABLE_TYPE(
            Gebäude_Typ(
                1,
                'Bilbos Hobbithütte',
                'Kein Ort für wilde Parties',
                (SELECT REF(o) FROM Ort_Tab o WHERE o.OrtId = 1),
                Zimmer_NESTED_TABLE_TYPE(
                    Zimmer_Typ(1, 50, 'Küch-Wohnzimmer', 'Tisch, Sessel'),
                    Zimmer_Typ(2, 12, 'Schlafzimmer', 'Bett, Kleiderschrank'),
                    Zimmer_Typ(3, 18, 'Garderobe', 'Garderobenständer')
                ),
                (SELECT TREAT(REF(i) AS REF Grundstücke_Typ)
                 FROM immobilien_tab i WHERE i.immobilienid = 1)
            )
        ),
        'Tannenwald'
    )
);

INSERT INTO Immobilien_Tab VALUES (
    Seegrundstücke_Typ(
        2,
        'Benkos Privatvilla',
        'Villa eines ehemaligen Kakaoherstellers',
        (SELECT REF(o) FROM Ort_Tab o WHERE o.OrtId = 1),
        5000,
        'Richtig cooler Seezugang für Reiche',
        Gebäude_NESTED_TABLE_TYPE(
            Gebäude_Typ(
                2,
                'Benkos Ultravilla',
                'Gehört der Mutter',
                (SELECT REF(o) FROM Ort_Tab o WHERE o.OrtId = 1),
                Zimmer_NESTED_TABLE_TYPE(
                    Zimmer_Typ(4, 100012, 'Küch-Wohnzimmer', 'Butler, Guccimesser'),
                    Zimmer_Typ(5, 67, 'Abstellkammer', 'Gucci-Abstellregal'),
                    Zimmer_Typ(6, 100000, 'Benkos Kinderzimmer', 'Ultramega-Guccibett'),
                    Zimmer_Typ(7, 10000, 'Rooftop Skyview Pool', 'Ultramega-Guccipool')
                ),
                (SELECT TREAT(REF(i) AS REF Grundstücke_Typ)
                 FROM immobilien_tab i WHERE i.immobilienid = 2)
            )
        ),
        1000
    )
);

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
    MaxReichweite NUMBER(6)
);
/

CREATE TABLE Fahrzeug_Tab OF Fahrzeug_Typ (
    FahrzeugNr PRIMARY KEY
)
/


INSERT INTO Fahrzeug_Tab VALUES (Auto_Typ(0, 1700, 220));
INSERT INTO Fahrzeug_Tab VALUES (Auto_Typ(1, 1500, 200));
INSERT INTO Fahrzeug_Tab VALUES (EBike_Typ(2, 15, 52)); 
INSERT INTO Fahrzeug_Tab VALUES (Fahrzeug_Typ(3, 1000));
INSERT INTO Fahrzeug_Tab VALUES (EBike_Typ(4, 20, 56));

SELECT VALUE(f) FROM Fahrzeug_Tab f;
SELECT REF(f) FROM Fahrzeug_Tab f WHERE VALUE(f) IS OF (ONLY Auto_Typ);

SELECT VALUE(f).FahrzeugNr, VALUE(f).Gewicht, TREAT(VALUE(f) AS EBike_Typ).MaxReichweite FROM Fahrzeug_Tab f
WHERE VALUE(f) IS OF (ONLY EBike_Typ);

SELECT VALUE(f) FROM Fahrzeug_Tab f WHERE VALUE(f) IS OF (ONLY Fahrzeug_Typ);


/*
DROP TYPE Fahrzeug_Typ FORCE;
DROP TYPE EBike_Typ FORCE;
DROP TYPE Auto_Typ FORCE;
DROP TYPE Fahrzeug_Typ FORCE;
DROP TABLE Fahrzeug_Tab;*/
