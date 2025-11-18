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


DECLARE
    gebäude_ref REF Gebäude_Typ;
    ort_ref REF Ort_Typ;
    grundstück_ref REF Grundstücke_Typ;
BEGIN
    SELECT REF(o) INTO ort_ref
    FROM ORT_TAB o 
    WHERE o.ORTID = 1;

    -- create building
    INSERT INTO Immobilien_Tab VALUES (
        Gebäude_Typ(
            1,
            'Bilbos Hobbithütte',
            'Kein Ort für wilde Parties',
            ort_ref,
            Zimmer_Nested_Table_Typ(
                Zimmer_Typ(1, 50, 'Küch-Wohnzimmer', 'Tisch, Sessel'),
                Zimmer_Typ(2, 12, 'Schlafzimmer', 'Bett, Kleiderschrank'),
                Zimmer_Typ(3, 18, 'Garderobe', 'Garderobenständer')
            ),
            NULL  -- ref will be added later
        )
    );


    SELECT TREAT(REF(gebäude) AS REF Gebäude_Typ) INTO gebäude_ref
    FROM Immobilien_Tab gebäude
    WHERE gebäude.ImmobilienId = 1;

    INSERT INTO Immobilien_Tab VALUES (
        WALDGRUNDSTÜCKE_TYP(
            2,
            'Eisengard',
            'They are taking the Hobbits to Eisengard',
            ort_ref,
            7000,
            'coole Lage',
            Gebäude_REF_Nested_Table_Typ(gebäude_ref),
            'Tannenwald'
        )
    );

    SELECT TREAT(REF(grundstück) AS REF Grundstücke_Typ) INTO grundstück_ref
    FROM Immobilien_Tab grundstück
    WHERE grundstück.ImmobilienId = 2; 

    UPDATE Immobilien_Tab tab
    SET VALUE(tab) = Gebäude_Typ(
        tab.ImmobilienId,
        tab.Bezeichnung,
        tab.Beschreibung,
        tab.Ort,
        TREAT(VALUE(tab) AS Gebäude_Typ).ZimmerPositionen,
        grundstück_ref
    )
    WHERE tab.ImmobilienId = 1;
END;
/

-- Benkos Privatvilla
DECLARE
    gebäude_ref REF Gebäude_Typ;
    ort_ref REF Ort_Typ;
    grundstück_ref REF Grundstücke_Typ;
BEGIN
    SELECT REF(o) INTO ort_ref
    FROM ORT_TAB o 
    WHERE o.ORTID = 1;

    -- create building
    INSERT INTO Immobilien_Tab VALUES (
        Gebäude_Typ(
            3,
            'Benkos Ultravilla',
            'Gehört der Mutter',
            ort_ref,
            Zimmer_Nested_Table_Typ(
                Zimmer_Typ(4, 100012, 'Küch-Wohnzimmer', 'Butler, Guccimesser'),
                Zimmer_Typ(5, 67, 'Abstellkammer', 'Gucci-Abstellregal'),
                Zimmer_Typ(6, 100000, 'Benkos Kinderzimmer', 'Ultramega-Guccibett'),
                Zimmer_Typ(7, 10000, 'Rooftop Skyview Pool', 'Ultramega-Guccipool')
            ),
            NULL  -- ref will be added later
        )
    );


    SELECT TREAT(REF(gebäude) AS REF Gebäude_Typ) INTO gebäude_ref
    FROM Immobilien_Tab gebäude
    WHERE gebäude.ImmobilienId = 3;

    INSERT INTO Immobilien_Tab VALUES (
        WALDGRUNDSTÜCKE_TYP(
            4,
            'Benkos Privatvilla',
            'Villa eines ehemaligen Kakaoherstellers',
            ort_ref,
            5000,
            'Richtig cooler Seezugang für Reiche',
            Gebäude_REF_Nested_Table_Typ(gebäude_ref),
            1000
        )
    );

    SELECT TREAT(REF(grundstück) AS REF Grundstücke_Typ) INTO grundstück_ref
    FROM Immobilien_Tab grundstück
    WHERE grundstück.ImmobilienId = 4; 

    UPDATE Immobilien_Tab tab
    SET VALUE(tab) = Gebäude_Typ(
        tab.ImmobilienId,
        tab.Bezeichnung,
        tab.Beschreibung,
        tab.Ort,
        TREAT(VALUE(tab) AS Gebäude_Typ).ZimmerPositionen,
        grundstück_ref
    )
    WHERE tab.ImmobilienId = 3;
END;
/

DECLARE
    immobilien_ref_1 REF Immobilien_Typ;
    immobilien_ref_2 REF Immobilien_Typ;
    immobilien_ref_3 REF Immobilien_Typ;
    immobilien_ref_4 REF Immobilien_Typ;
    
    -- variable to hold all properties
    alle_immobilien Immobilien_REF_NESTED_TABLE;
BEGIN
    SELECT REF(i) INTO immobilien_ref_1 FROM Immobilien_Tab i WHERE i.ImmobilienId = 1;
    SELECT REF(i) INTO immobilien_ref_2 FROM Immobilien_Tab i WHERE i.ImmobilienId = 2;
    SELECT REF(i) INTO immobilien_ref_3 FROM Immobilien_Tab i WHERE i.ImmobilienId = 3;
    SELECT REF(i) INTO immobilien_ref_4 FROM Immobilien_Tab i WHERE i.ImmobilienId = 4;

    -- refs of all properties
    alle_immobilien := Immobilien_REF_NESTED_TABLE(
        immobilien_ref_1,
        immobilien_ref_2,
        immobilien_ref_3,
        immobilien_ref_4
    );

    -- Insert new Markler
    INSERT INTO Makler_Tab VALUES (
        Makler_Typ(
            1,
            'Karl', 
            'Klammer', 
            TO_DATE('2000-01-01', 'YYYY-MM-DD'),
            TO_DATE('2025-11-11', 'YYYY-MM-DD'), 
            alle_immobilien 
        )
    );
END;
/

SELECT 
    im_tab.ImmobilienId,
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
DROP TYPE Zimmer_Nested_Table_Type FORCE;
DROP TYPE Grundstücke_Typ FORCE;
DROP TYPE Gebäude_Typ FORCE;
DROP TYPE Gebäude_REF_Nested_Table_Type FORCE;
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

--b
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