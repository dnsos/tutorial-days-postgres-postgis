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

-- And then, we can finally import the toilets:

INSERT INTO toilets (wall_id, description, city, address, postal_code, geometry, price, toilet_owner_id)
SELECT 
  -- We trim the VARCHAR rows in order to remove potential trailing whitespace:
	TRIM(toilets_temp."LavatoryID"),
	TRIM(toilets_temp."Description"),
	TRIM(toilets_temp."City"),
	TRIM(toilets_temp."Street"),
	TRIM(toilets_temp."PostalCode"),
  -- We use PostGIS functions to construct the geometry from latitude & longitude
  -- Note that we had to replace the comma with a dot because the original data uses a comma as the decimal separator (-> Germany)
	ST_SetSRID(ST_MakePoint(REPLACE(toilets_temp."Longitude", ',', '.')::DECIMAL, REPLACE(toilets_temp."Latitude", ',', '.')::DECIMAL),4326),
	REPLACE(toilets_temp."Price", ',', '.')::REAL,
  -- We check if it is owned by Wall and assign the appropriate ID's (in this case 2 or 3)
	CASE WHEN toilets_temp."isOwnedByWall" = 1 THEN 2 ELSE 3 END
FROM toilets_temp;

-- There is one weird issue I couldn't exactly figure out.
-- When importing with the previous query there was a recurrent error that the VARCHAR(5) restriction is violated.
-- So, for now I have just changed this via:

ALTER TABLE toilets
ALTER COLUMN postal_code TYPE VARCHAR(10);

-- After changing that the query should run successfully.

-- Now we insert the toilet features. First, the accessibility feature:

INSERT INTO toilet_features (toilet_id, feature_id)
SELECT
	(SELECT id FROM toilets WHERE toilets.wall_id = toilets_temp."LavatoryID"),
	(SELECT id FROM features WHERE name = 'Barrierefrei')
FROM toilets_temp
WHERE toilets_temp."isHandicappedAccessible" = 1;

-- Then, the Wickeltisch feature:

INSERT INTO toilet_features (toilet_id, feature_id)
SELECT
	(SELECT id FROM toilets WHERE toilets.wall_id = toilets_temp."LavatoryID"),
	(SELECT id FROM features WHERE name = 'Wickeltisch')
FROM toilets_temp
WHERE toilets_temp."hasChangingTable" = 1;

-- Lastly, the Urinal feature:

INSERT INTO toilet_features (toilet_id, feature_id)
SELECT
	(SELECT id FROM toilets WHERE toilets.wall_id = toilets_temp."LavatoryID"),
	(SELECT id FROM features WHERE name = 'Urinal')
FROM toilets_temp
WHERE toilets_temp."hasUrinal" = 1;