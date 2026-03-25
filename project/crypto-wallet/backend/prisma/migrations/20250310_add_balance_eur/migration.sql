-- Add balanceEur to User and create VirementEur table
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "balanceEur" DECIMAL(65,30) NOT NULL DEFAULT 2000;

CREATE TABLE IF NOT EXISTS "VirementEur" (
    "id" TEXT NOT NULL,
    "fromUserId" TEXT NOT NULL,
    "toUserId" TEXT NOT NULL,
    "amount" DECIMAL(65,30) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "VirementEur_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "VirementEur_fromUserId_idx" ON "VirementEur"("fromUserId");
CREATE INDEX IF NOT EXISTS "VirementEur_toUserId_idx" ON "VirementEur"("toUserId");
