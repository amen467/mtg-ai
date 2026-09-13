/*
  Warnings:

  - You are about to drop the `Test` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropTable
DROP TABLE "Test";

-- CreateTable
CREATE TABLE "Card" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "oracleText" TEXT,
    "manaCost" TEXT,
    "typeLine" TEXT,
    "power" TEXT,
    "toughness" TEXT,
    "colors" TEXT[],
    "colorIdentity" TEXT[],
    "keywords" TEXT[],
    "cmc" DOUBLE PRECISION,
    "reserved" BOOLEAN NOT NULL DEFAULT false,
    "digital" BOOLEAN NOT NULL DEFAULT false,
    "imageUri" TEXT,
    "scryfallUri" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Card_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Card_name_idx" ON "Card"("name");
