DROP TYPE IF EXISTS methode_type CASCADE;
CREATE TYPE methode_type AS ENUM ('PCR', 'Serologie', 'Autre');
DROP TYPE IF EXISTS resultat_type CASCADE;
CREATE TYPE resultat_type AS ENUM ('positif', 'negatif', 'indetermine');
CREATE TABLE Region (
    region_id SERIAL PRIMARY KEY,
    nom VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE District (
    district_id SERIAL PRIMARY KEY,
    nom VARCHAR(100) UNIQUE NOT NULL,
    region_id INT REFERENCES Region(region_id)
);
CREATE TABLE Patient (
    patient_id SERIAL PRIMARY KEY,
    age INT NOT NULL,
    sexe CHAR(1) CHECK (sexe IN ('M', 'F')) NOT NULL,
    district_id INT REFERENCES District(district_id)
);
CREATE TABLE Echantillon (
    sample_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL REFERENCES Patient(patient_id),
    type_echantillon VARCHAR(50) NOT NULL,
    date_prelevement DATE NOT NULL
);
CREATE TABLE Test (
    test_id SERIAL PRIMARY KEY,
    sample_id INT NOT NULL REFERENCES Echantillon(sample_id),
    methode methode_type NOT NULL,
    resultat resultat_type NOT NULL,
    date_test DATE NOT NULL
);
CREATE TABLE Epidemiologie (
    district_id INT REFERENCES District(district_id),
    date_rapport DATE NOT NULL,
    cas_confirmes INT DEFAULT 0,
    cas_suspects INT DEFAULT 0,
    gueris INT DEFAULT 0,
    deces INT DEFAULT 0,
    PRIMARY KEY (district_id, date_rapport)
);