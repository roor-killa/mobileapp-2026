/**
 * Base URL du json-server Docker (port 3001).
 *
 * Par défaut on utilise le chemin relatif `/json-api`, proxifié par Vite vers
 * `http://127.0.0.1:3001` — sinon le navigateur bloque les appels (CORS).
 *
 * Surcharge explicite : `VITE_API_BASE_URL=http://localhost:3001` dans `.env`
 */
export function getJsonServerBaseUrl(): string {
  const fromEnv = import.meta.env.VITE_API_BASE_URL?.trim();
  if (fromEnv) {
    return fromEnv.replace(/\/$/, "");
  }
  return "/json-api";
}
