CREATE TABLE "toilets"(
    "id" INTEGER NOT NULL,
    "wall_id" VARCHAR(255) NOT NULL,
    "description" VARCHAR(255) NULL,
    "city" VARCHAR(255) NULL,
    "address" VARCHAR(255) NULL,
    "postal_code" VARCHAR(255) NULL,
    "geometry" geography(POINT, 4326) NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "toilet_owner_id" INTEGER NOT NULL
);
ALTER TABLE
    "toilets" ADD PRIMARY KEY("id");
CREATE TABLE "toilet_owners"(
    "id" INTEGER NOT NULL,
    "name" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "toilet_owners" ADD PRIMARY KEY("id");
CREATE TABLE "payment_methods"(
    "id" INTEGER NOT NULL,
    "name" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "payment_methods" ADD PRIMARY KEY("id");
CREATE TABLE "features"(
    "id" INTEGER NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "features" ADD PRIMARY KEY("id");
CREATE TABLE "toilet_features"(
    "id" INTEGER NOT NULL,
    "toilet_id" INTEGER NOT NULL,
    "feature_id" INTEGER NOT NULL
);
ALTER TABLE
    "toilet_features" ADD PRIMARY KEY("id");
CREATE TABLE "toilet_payment_methods"(
    "id" INTEGER NOT NULL,
    "toilet_id" INTEGER NOT NULL,
    "payment_method_id" INTEGER NOT NULL
);
ALTER TABLE
    "toilet_payment_methods" ADD PRIMARY KEY("id");
ALTER TABLE
    "toilets" ADD CONSTRAINT "toilets_toilet_owner_id_foreign" FOREIGN KEY("toilet_owner_id") REFERENCES "toilet_owners"("id");
ALTER TABLE
    "toilet_features" ADD CONSTRAINT "toilet_features_toilet_id_foreign" FOREIGN KEY("toilet_id") REFERENCES "toilets"("id");
ALTER TABLE
    "toilet_features" ADD CONSTRAINT "toilet_features_feature_id_foreign" FOREIGN KEY("feature_id") REFERENCES "features"("id");
ALTER TABLE
    "toilet_payment_methods" ADD CONSTRAINT "toilet_payment_methods_toilet_id_foreign" FOREIGN KEY("toilet_id") REFERENCES "toilets"("id");
ALTER TABLE
    "toilet_payment_methods" ADD CONSTRAINT "toilet_payment_methods_payment_method_id_foreign" FOREIGN KEY("payment_method_id") REFERENCES "payment_methods"("id");