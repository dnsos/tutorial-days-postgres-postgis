-- We now want to perform a data (not schema) migration of the 50 free toilets.

-- We first craete a temporary table that mirrors the columns in the original dataset:

CREATE TEMPORARY TABLE "free_toilets_temp"(
  "Standort" VARCHAR(255),
  "Bezirk" VARCHAR(255),
  "Typ" VARCHAR(255),
  "Aufbau" VARCHAR(255)
);

-- The original dataset is not completely clean. We've had to manually remove ";;;;;;;;;;;" from every row because the original dataset contained empty columns.
-- (It might have been possible to remove these already during the export from XLSX to CSV)

-- We then insert the dataset into the table:

COPY "free_toilets_temp"("Standort", "Bezirk", "Typ", "Aufbau")
FROM '/path/to/repo/assets/data/anlage_standorte-fuer-die-entgeltlose-benutzung-von-50-berliner-toiletten.csv'
DELIMITER ';'
CSV HEADER;

-- Note that we included the column names in the COPY statement. This was actually not necessary since we wanted to import all columns.

-- Okay, this doesn't work. Or it might somehow, but I will skip this for now.
-- If the dataset of the 50 free toilets simply had an ID, this wouldn't be a problem.
-- But matching the address with the address + appendix/comment thingy is really tricky.
-- I tried some things like this:

SELECT toilets.address, free_toilets_temp."Standort" FROM free_toilets_temp JOIN toilets ON CONCAT('%', toilets.address, '%') SIMILAR TO CONCAT('%', free_toilets_temp."Standort", '%');

-- While it yields some results, not all toilets are matched.
-- Continuing and maybe coming back to this later.

DROP TABLE free_toilets_temp;
