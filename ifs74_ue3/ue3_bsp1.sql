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
    Ort Ort_Typ
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

CREATE OR REPLACE TYPE Gebäude_Typ UNDER Immobilien_Typ (
    ZimmerPositionen Zimmer_NESTED_TABLE_TYPE,
    Auf_Grundstück REF Grundstücke_Typ
)NOT FINAL INSTANTIABLE;
/

CREATE OR REPLACE TYPE Gebäude_NESTED_TABLE_TYPE AS TABLE OF Gebäude_Typ;
/


CREATE OR REPLACE TYPE Grundstücke_Typ UNDER Immobilien_Typ (
    Größe INTEGER,
    Lage VARCHAR2(50)
) NOT FINAL INSTANTIABLE;
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