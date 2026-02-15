export default {
  async fetch(request: Request, env: { OPENAI_API_KEY: string }) {
    // CORS (dev friendly)
    const cors = {
      "access-control-allow-origin": "*",
      "access-control-allow-methods": "POST, OPTIONS",
      "access-control-allow-headers": "content-type",
    };

    if (request.method === "OPTIONS") {
      return new Response(null, { headers: cors });
    }

    if (request.method !== "POST") {
      return new Response("Use POST", { status: 405, headers: cors });
    }

    const ct = request.headers.get("content-type") || "";
    if (!ct.includes("multipart/form-data")) {
      return new Response("Content-Type must be multipart/form-data", {
        status: 400,
        headers: cors,
      });
    }

    const form = await request.formData();
    const file = form.get("image");
    const prompt = form.get("prompt");
    const sizeRaw = form.get("size");

    if (!(file instanceof File)) {
      return new Response("Missing field 'image' (file)", { status: 400, headers: cors });
    }
    if (typeof prompt !== "string" || !prompt.trim()) {
      return new Response("Missing field 'prompt'", { status: 400, headers: cors });
    }

    const sizeNum = Number(sizeRaw) === 512 ? 512 : 1024;
    const sizeStr = sizeNum === 512 ? "512x512" : "1024x1024";

    // Appel OpenAI images/edits (retour b64_json, mais seulement côté Worker)
    const upstream = new FormData();
    upstream.append("model", "gpt-image-1");
    upstream.append("prompt", prompt.trim());
    upstream.append("size", sizeStr);
    upstream.append("image", file, "input.jpg");

    const r = await fetch("https://api.openai.com/v1/images/edits", {
      method: "POST",
      headers: { Authorization: `Bearer ${env.OPENAI_API_KEY}` },
      body: upstream,
    });

    const text = await r.text();
    if (!r.ok) {
      // on renvoie le texte d'erreur (utile pour debug Flutter)
      return new Response(text, { status: r.status, headers: cors });
    }

    const json = JSON.parse(text);
    const b64 = json?.data?.[0]?.b64_json;
    if (!b64) {
      return new Response("No image returned", { status: 502, headers: cors });
    }

    // decode base64 => bytes
    const bin = Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));

    // ✅ réponse binaire directe
    return new Response(bin, {
      status: 200,
      headers: {
        ...cors,
        "content-type": "image/png",
        "cache-control": "public, max-age=31536000, immutable",
      },
    });
  },
};
