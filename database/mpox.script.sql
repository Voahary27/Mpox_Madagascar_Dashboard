DO $$
DECLARE p_id INT;
s_id INT;
curr_date DATE;
selected_district INT;
rand_val FLOAT;
d_mahajanga INT;
d_toamasina INT;
d_tananarive INT;
d_fianar INT;
d_ihosy INT;
BEGIN
INSERT INTO Region (nom)
VALUES ('Analamanga'),
    ('Vakinankaratra'),
    ('Itasy'),
    ('Bongolava'),
    ('Haute Matsiatra'),
    ('Amoron''i Mania'),
    ('Vatovavy'),
    ('Fitovinany'),
    ('Atsimo-Atsinanana'),
    ('Ihorombe'),
    ('Atsinanana'),
    ('Analanjirofo'),
    ('Alaotra-Mangoro'),
    ('Boeny'),
    ('Sofia'),
    ('Betsiboka'),
    ('Melaky'),
    ('DIANA'),
    ('Sava'),
    ('Atsimo-Andrefana'),
    ('Androy'),
    ('Anosy') ON CONFLICT (nom) DO NOTHING;
INSERT INTO District (nom, region_id)
VALUES (
        'Antananarivo Renivohitra',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Analamanga'
        )
    ),
    (
        'Antsirabe I',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Vakinankaratra'
        )
    ),
    (
        'Miarinarivo',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Itasy'
        )
    ),
    (
        'Tsiroanomandidy',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Bongolava'
        )
    ),
    (
        'Fianarantsoa',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Haute Matsiatra'
        )
    ),
    (
        'Ambositra',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Amoron''i Mania'
        )
    ),
    (
        'Manakara',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Fitovinany'
        )
    ),
    (
        'Mananjary',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Vatovavy'
        )
    ),
    (
        'Farafangana',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Atsimo-Atsinanana'
        )
    ),
    (
        'Ihosy',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Ihorombe'
        )
    ),
    (
        'Toamasina I',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Atsinanana'
        )
    ),
    (
        'Fenerive Est',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Analanjirofo'
        )
    ),
    (
        'Ambatondrazaka',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Alaotra-Mangoro'
        )
    ),
    (
        'Mahajanga I',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Boeny'
        )
    ),
    (
        'Antsohihy',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Sofia'
        )
    ),
    (
        'Maevatanana',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Betsiboka'
        )
    ),
    (
        'Maintirano',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Melaky'
        )
    ),
    (
        'Antsiranana I',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'DIANA'
        )
    ),
    (
        'Sambava',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Sava'
        )
    ),
    (
        'Toliara I',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Atsimo-Andrefana'
        )
    ),
    (
        'Ambovombe',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Androy'
        )
    ),
    (
        'Taolagnaro',
        (
            SELECT region_id
            FROM Region
            WHERE nom = 'Anosy'
        )
    ) ON CONFLICT (nom) DO NOTHING;
SELECT district_id INTO d_mahajanga
FROM District
WHERE nom = 'Mahajanga I';
SELECT district_id INTO d_toamasina
FROM District
WHERE nom = 'Toamasina I';
SELECT district_id INTO d_tananarive
FROM District
WHERE nom = 'Antananarivo Renivohitra';
SELECT district_id INTO d_fianar
FROM District
WHERE nom = 'Fianarantsoa';
SELECT district_id INTO d_ihosy
FROM District
WHERE nom = 'Ihosy';
FOR i IN 1..1000 LOOP rand_val := random();
IF rand_val < 0.40 THEN selected_district := d_toamasina;
ELSIF rand_val < 0.65 THEN selected_district := d_mahajanga;
ELSIF rand_val < 0.85 THEN selected_district := d_tananarive;
ELSIF rand_val < 0.95 THEN selected_district := d_fianar;
ELSIF rand_val < 0.98 THEN selected_district := d_ihosy;
ELSE selected_district := (
    SELECT district_id
    FROM District
    ORDER BY random()
    LIMIT 1
);
END IF;
INSERT INTO Patient (age, sexe, district_id)
VALUES (
        (FLOOR(random() * 35) + 10)::INT,
        CASE
            WHEN random() < 0.63 THEN 'M'
            ELSE 'F'
        END,
        selected_district
    );
END LOOP;
FOR p_id IN (
    SELECT patient_id
    FROM Patient
) LOOP IF random() < 0.80 THEN
INSERT INTO Echantillon (patient_id, type_echantillon, date_prelevement)
VALUES (
        p_id,
        'Ecouvillon cutane',
        CURRENT_DATE - (FLOOR(random() * 180) || ' days')::INTERVAL
    )
RETURNING sample_id INTO s_id;
INSERT INTO Test (sample_id, methode, resultat, date_test)
VALUES (
        s_id,
        (
            CASE
                WHEN random() < 0.85 THEN 'PCR'
                ELSE 'Serologie'
            END
        )::methode_type,
        (
            CASE
                WHEN random() < 0.65 THEN 'positif'
                WHEN random() < 0.95 THEN 'negatif'
                ELSE 'indetermine'
            END
        )::resultat_type,
        (
            SELECT date_prelevement
            FROM Echantillon
            WHERE sample_id = s_id
        ) + INTERVAL '1 day'
    );
END IF;
END LOOP;
FOR selected_district IN
SELECT district_id
FROM District LOOP curr_date := CURRENT_DATE - INTERVAL '180 days';
WHILE curr_date <= CURRENT_DATE LOOP IF EXTRACT(
    DOW
    FROM curr_date
) = 0 THEN IF selected_district IN (d_toamasina, d_mahajanga, d_tananarive, d_fianar) THEN
INSERT INTO Epidemiologie (
        district_id,
        date_rapport,
        cas_confirmes,
        cas_suspects,
        gueris,
        deces
    )
VALUES (
        selected_district,
        curr_date,
        FLOOR(random() * 25 + 5),
        FLOOR(random() * 40 + 10),
        FLOOR(random() * 20),
        CASE
            WHEN random() < 0.05 THEN 1
            ELSE 0
        END
    ) ON CONFLICT DO NOTHING;
ELSE
INSERT INTO Epidemiologie (
        district_id,
        date_rapport,
        cas_confirmes,
        cas_suspects,
        gueris,
        deces
    )
VALUES (
        selected_district,
        curr_date,
        0,
        FLOOR(random() * 2),
        0,
        0
    ) ON CONFLICT DO NOTHING;
END IF;
END IF;
curr_date := curr_date + INTERVAL '1 day';
END LOOP;
END LOOP;
END $$;
select count (*)
from epidemiologie;