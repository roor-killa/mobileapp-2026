-- Migration : renommer vers appwriteId
-- Exécutez UNE des lignes ci-dessous selon votre colonne actuelle (supabaseId ou pocketbaseId) :

-- Si vous aviez supabaseId :
-- ALTER TABLE "User" RENAME COLUMN "supabaseId" TO "appwriteId";

-- Si vous aviez pocketbaseId :
-- ALTER TABLE "User" RENAME COLUMN "pocketbaseId" TO "appwriteId";

-- Si vous partez de zéro, ajoutez la colonne :
ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "appwriteId" TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS "User_appwriteId_key" ON "User"("appwriteId");
