-- CreateTable
CREATE TABLE "Ruling" (
    "id" TEXT NOT NULL,
    "cardId" TEXT NOT NULL,
    "source" TEXT NOT NULL,
    "publishedAt" TIMESTAMP(3) NOT NULL,
    "comment" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Ruling_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Ruling_cardId_idx" ON "Ruling"("cardId");

-- CreateIndex
CREATE INDEX "Ruling_publishedAt_idx" ON "Ruling"("publishedAt");

-- AddForeignKey
ALTER TABLE "Ruling" ADD CONSTRAINT "Ruling_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES "Card"("id") ON DELETE CASCADE ON UPDATE CASCADE;
