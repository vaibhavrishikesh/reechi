// Reechi proxy backend — turns a selfie + style into an AI-generated image.
//
// The iOS app talks ONLY to this server; the provider API key lives here (env),
// never in the app. Zero dependencies — runs on Node 18+ with `node index.js`.
//
//   GEMINI_API_KEY=...  APP_TOKEN=dev-reechi-token  node index.js
//
// Endpoints:
//   GET  /health    -> { ok: true }
//   POST /generate  -> { style, image(base64 jpeg) }  =>  { image(base64) }

import http from "node:http";

const PORT = process.env.PORT || 8787;
const APP_TOKEN = process.env.APP_TOKEN || "dev-reechi-token";
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "";
const MODEL = process.env.GEMINI_MODEL || "gemini-2.5-flash-image"; // "nano-banana"

// Per-style prompt engineering lives server-side (easy to tweak without an app update).
const STYLE_PROMPTS = {
  "Action Figure":
    "Transform the person in this photo into a collectible action figure sealed in blister-pack toy packaging, glossy plastic, studio toy photography. Preserve their face, hair and likeness clearly.",
  "Ghibli":
    "Repaint this portrait in Studio Ghibli hand-drawn anime style: soft painterly shading, warm light, gentle background. Keep the person's face and likeness recognizable.",
  "Anime Hero":
    "Restyle this portrait as a bold shonen manga/anime hero: clean line art, dramatic cel shading, vivid colors. Keep the face likeness.",
  "Polaroid":
    "Make this look like a vintage Polaroid instant photo: faded film colors, soft grain, slight vignette, warm cast. Keep the person realistic and recognizable.",
  "Pixar 3D":
    "Render the person as a cute Pixar-style 3D animated character: smooth subsurface skin, big expressive eyes, soft cinematic lighting. Preserve their likeness and features.",
  "Cyberpunk":
    "Restyle this portrait as a neon cyberpunk character: glowing magenta/cyan rim light, futuristic city bokeh, high contrast. Keep the face likeness.",
};

function send(res, status, obj) {
  const body = JSON.stringify(obj);
  res.writeHead(status, { "Content-Type": "application/json" });
  res.end(body);
}

function readBody(req, limitBytes = 12 * 1024 * 1024) {
  return new Promise((resolve, reject) => {
    let size = 0;
    const chunks = [];
    req.on("data", (c) => {
      size += c.length;
      if (size > limitBytes) reject(new Error("payload too large"));
      else chunks.push(c);
    });
    req.on("end", () => resolve(Buffer.concat(chunks).toString("utf8")));
    req.on("error", reject);
  });
}

// Call Gemini 2.5 Flash Image (nano-banana) to edit the image with the prompt.
async function generateWithGemini(prompt, imageB64) {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${GEMINI_API_KEY}`;
  const payload = {
    contents: [
      {
        parts: [
          { text: prompt },
          { inline_data: { mime_type: "image/jpeg", data: imageB64 } },
        ],
      },
    ],
  };
  const r = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  if (!r.ok) throw new Error(`provider ${r.status}: ${await r.text()}`);
  const data = await r.json();
  const parts = data?.candidates?.[0]?.content?.parts ?? [];
  const img = parts.find((p) => p.inlineData || p.inline_data);
  const b64 = img?.inlineData?.data || img?.inline_data?.data;
  if (!b64) throw new Error("provider returned no image");
  return b64;
}

const server = http.createServer(async (req, res) => {
  if (req.method === "GET" && req.url === "/health") return send(res, 200, { ok: true });

  if (req.method === "POST" && req.url === "/generate") {
    // --- auth (placeholder for real per-user auth / RevenueCat credit check) ---
    if (req.headers["x-app-token"] !== APP_TOKEN) return send(res, 401, { error: "unauthorized" });
    if (!GEMINI_API_KEY) return send(res, 500, { error: "server missing GEMINI_API_KEY" });

    try {
      const { style, image } = JSON.parse(await readBody(req));
      const prompt = STYLE_PROMPTS[style];
      if (!prompt) return send(res, 400, { error: `unknown style: ${style}` });
      if (!image) return send(res, 400, { error: "missing image" });

      // TODO: check the user's remaining credits here before spending money.
      const out = await generateWithGemini(prompt, image);
      return send(res, 200, { image: out });
    } catch (e) {
      console.error(e);
      return send(res, 502, { error: String(e.message || e) });
    }
  }

  send(res, 404, { error: "not found" });
});

server.listen(PORT, () => console.log(`Reechi proxy on http://localhost:${PORT}`));
