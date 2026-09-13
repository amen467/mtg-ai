-- CreateTable
CREATE TABLE "ReleaseNote" (
    "id" TEXT NOT NULL,
    "setCode" TEXT,
    "releaseDate" TIMESTAMP(3),
    "cardName" TEXT,
    "text" TEXT NOT NULL,
    "sourceUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ReleaseNote_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ReleaseNote_setCode_idx" ON "ReleaseNote"("setCode");

-- CreateIndex
CREATE INDEX "ReleaseNote_cardName_idx" ON "ReleaseNote"("cardName");

-- CreateIndex
CREATE INDEX "ReleaseNote_releaseDate_idx" ON "ReleaseNote"("releaseDate");
