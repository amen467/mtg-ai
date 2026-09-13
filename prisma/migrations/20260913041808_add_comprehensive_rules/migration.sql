-- CreateTable
CREATE TABLE "ComprehensiveRule" (
    "id" TEXT NOT NULL,
    "ruleNumber" TEXT NOT NULL,
    "section" TEXT,
    "title" TEXT,
    "text" TEXT NOT NULL,
    "parentId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ComprehensiveRule_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ComprehensiveRule_ruleNumber_key" ON "ComprehensiveRule"("ruleNumber");

-- CreateIndex
CREATE INDEX "ComprehensiveRule_section_idx" ON "ComprehensiveRule"("section");

-- CreateIndex
CREATE INDEX "ComprehensiveRule_parentId_idx" ON "ComprehensiveRule"("parentId");

-- AddForeignKey
ALTER TABLE "ComprehensiveRule" ADD CONSTRAINT "ComprehensiveRule_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "ComprehensiveRule"("id") ON DELETE SET NULL ON UPDATE CASCADE;
