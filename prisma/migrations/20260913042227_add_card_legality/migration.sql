-- CreateTable
CREATE TABLE "CardLegality" (
    "id" TEXT NOT NULL,
    "cardId" TEXT NOT NULL,
    "format" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "effectiveAt" TIMESTAMP(3) NOT NULL,
    "sourceUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CardLegality_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "CardLegality_cardId_idx" ON "CardLegality"("cardId");

-- CreateIndex
CREATE INDEX "CardLegality_format_idx" ON "CardLegality"("format");

-- CreateIndex
CREATE INDEX "CardLegality_effectiveAt_idx" ON "CardLegality"("effectiveAt");

-- CreateIndex
CREATE UNIQUE INDEX "CardLegality_cardId_format_effectiveAt_key" ON "CardLegality"("cardId", "format", "effectiveAt");

-- AddForeignKey
ALTER TABLE "CardLegality" ADD CONSTRAINT "CardLegality_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES "Card"("id") ON DELETE CASCADE ON UPDATE CASCADE;
