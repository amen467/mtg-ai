-- CreateTable
CREATE TABLE "Printing" (
    "id" TEXT NOT NULL,
    "cardId" TEXT NOT NULL,
    "setCode" TEXT NOT NULL,
    "setName" TEXT NOT NULL,
    "collectorNumber" TEXT NOT NULL,
    "rarity" TEXT,
    "releasedAt" TIMESTAMP(3),
    "imageUri" TEXT,
    "scryfallUri" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Printing_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Printing_cardId_idx" ON "Printing"("cardId");

-- CreateIndex
CREATE INDEX "Printing_setCode_idx" ON "Printing"("setCode");

-- CreateIndex
CREATE UNIQUE INDEX "Printing_setCode_collectorNumber_key" ON "Printing"("setCode", "collectorNumber");

-- AddForeignKey
ALTER TABLE "Printing" ADD CONSTRAINT "Printing_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES "Card"("id") ON DELETE CASCADE ON UPDATE CASCADE;
