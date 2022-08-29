-- First we setup all the tables that do not have foreign keys

CREATE TABLE "payment_methods"(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	"updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "features"(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "description" VARCHAR(255),
	"created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	"updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "toilet_owners"(
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
	"created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	"updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Next, we create the most important toilets table.

CREATE TABLE "toilets"(
    "id" SERIAL PRIMARY KEY,
    -- The dataset provides a LavatroryId which is supposed to be unique. However, we want to additionally rely on our own id column.
    "wall_id" VARCHAR(50) NOT NULL,
    "description" VARCHAR(255),
    "city" VARCHAR(100),
    "address" VARCHAR(255),
    "postal_code" VARCHAR(5),
    -- PostGIS column:
    "geometry" geography(POINT, 4326) NOT NULL,
    -- We use REAL because a price is only ever going to need a precision of two decimal points.
    -- In addition, REAL only uses 4 bytes, while e.g. DOUBLE PRECISION uses 8 bytes.
    "price" REAL NOT NULL,
	"created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	"updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    -- The toilet_owner_id column is special.
    -- First, it references the id column on the toilet_owners table which makes sure that there is an owner associated with a toilet.
    -- We also want to delete a toilet if the toilet_owner is deleted, that's why we use ON DELETE CASCADE
	"toilet_owner_id" INTEGER NOT NULL REFERENCES toilet_owners(id) ON DELETE CASCADE
);

-- Before continuing, let's a dd some comments to each table to clarify its purpose

COMMENT ON TABLE toilets IS 'Information that directly describes a toilet such as address, geolocation, and price.';

COMMENT ON TABLE toilet_owners IS 'Information about toilet owners (currently only name).';

COMMENT ON TABLE payment_methods IS 'Possible payment methods for toilets.';

COMMENT ON TABLE features IS 'Possible features of a toilet.';

-- Now we create the association tables for our many-to-many relationships

CREATE TABLE "toilet_features"(
    "id" SERIAL PRIMARY KEY,
    -- If a toilet is deleted, all of its feature associations can also be deleted:
    "toilet_id" INTEGER NOT NULL REFERENCES toilets(id) ON DELETE CASCADE,
    -- If a feature is deleted, all of its toilet associations can also be deleted:
    "feature_id" INTEGER NOT NULL REFERENCES features(id) ON DELETE CASCADE,
    -- We can only associate a toilet with a feature once, so we set a UNIQUE constraint:
	UNIQUE (toilet_id, feature_id)
);

CREATE TABLE "toilet_payment_methods"(
    "id" SERIAL PRIMARY KEY,
    -- If a toilet is deleted, all of its feature associations can also be deleted:
    "toilet_id" INTEGER NOT NULL REFERENCES toilets(id) ON DELETE CASCADE,
    -- If a payment method is deleted, all of its toilet associations can also be deleted:
    "payment_method_id" INTEGER NOT NULL REFERENCES payment_methods(id) ON DELETE CASCADE,
    -- We can only associate a toilet with a payment method once, so we set a UNIQUE constraint:
	UNIQUE (toilet_id, payment_method_id)
);