BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "stocks" (
    "id" bigserial PRIMARY KEY,
    "tickerSymbol" text NOT NULL,
    "companyName" text,
    "sicCode" text,
    "grade" text,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "ticker_symbol_index" ON "stocks" USING btree ("tickerSymbol");


--
-- MIGRATION VERSION FOR zenvestor
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('zenvestor', '20250802170344195-add-stocks-table', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250802170344195-add-stocks-table', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
