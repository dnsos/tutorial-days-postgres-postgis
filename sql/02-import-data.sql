-- Create the temporary table

CREATE TEMPORARY TABLE "toilets_temp"(
  "LavatoryID" VARCHAR(255),
  "Description" VARCHAR(255),
  "City" VARCHAR(255),
  "Street" VARCHAR(255),
  "Number" INTEGER,
  "PostalCode" VARCHAR(5),
  "Country" VARCHAR(255),
  "Longitude" DECIMAL,
  "Latitude" DECIMAL,
  "isOwnedByWall" INTEGER,
  "isHandicappedAccessible", INTEGER,
  "Price" REAL,
  "canBePayedWithCoins" INTEGER,
  "canBePayedInApp" INTEGER,
  "canBePayedWithNFC" INTEGER,
  "hasChangingTable" INTEGER,
  "Label" INTEGER,
  "hasUrinal" INTEGER,
  "FID" INTEGER
);

-- I've made a mistake by enforcing the types too much.
-- Actually I would like to copy as much as-is as possible and do the type-casting later.

ALTER TABLE "toilets_temp"
ALTER COLUMN "Longitude" TYPE VARCHAR(255),
ALTER COLUMN "Latitude" TYPE VARCHAR(255),
ALTER COLUMN "Price" TYPE VARCHAR(255);

-- We even need to change the PostalCode column because sometimes there are trailing whitespace characters which violate the VARCHAR(5) restriction.

ALTER TABLE "toilets_temp"
ALTER COLUMN "PostalCode" TYPE VARCHAR(255);

-- It's possible to inspect a table by using:

SELECT *
FROM information_schema.columns
WHERE table_name = 'toilets_temp';

-- After fixing the column types, we can import the CSV:

COPY "toilets_temp"
FROM '/path/to/repo/assets/data/berliner-toiletten-standorte.csv'
DELIMITER ';'
CSV HEADER;

-- Success! We can view our imported data with:

SELECT * FROM toilets_temp;

-- Next, we move the data to our actual tables.

-- First we manually add the toilet owners, possible features, and possible payment methods:

INSERT INTO toilet_owners (name)
VALUES ('Wall'), ('Andere');

INSERT INTO features (name, description)
VALUES ('Barrierefrei', 'Barrierefreier Zugang, z.B. für Rollstuflfahrer*innen'), ('Wickeltisch', 'Ein Wickeltisch ist verfügbar'), ('Urinal', 'Hat ein Urinal');

INSERT INTO payment_methods (name)
VALUES ('Münzen'), ('Scheine'), ('Berliner Toiletten-App'), ('NFC'), ('Kreditkarte'), ('EC-Karte');