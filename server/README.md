# Reechi proxy backend

Tiny zero-dependency Node server that sits between the app and the AI provider so
the **provider API key never ships in the app**. Default provider is Google
**Gemini 2.5 Flash Image** ("nano-banana").

## Run locally

```bash
cd server
cp .env.example .env          # then paste your GEMINI_API_KEY
# get a key at https://aistudio.google.com/apikey
export $(grep -v '^#' .env | xargs)   # load env vars
npm start                     # → http://localhost:8787
```

Smoke test:

```bash
curl localhost:8787/health    # {"ok":true}
```

## Point the app at it

In `Sources/Config.swift`:

```swift
static let backendURL: URL? = URL(string: "http://localhost:8787")
```

- **Simulator** can reach `localhost` directly.
- **Real iPhone** can't reach your Mac's `localhost`. Use your Mac's LAN IP
  (e.g. `http://192.168.1.42:8787`, same Wi-Fi) or expose it with
  `ngrok http 8787` and use the https URL. (Add an ATS exception for plain http,
  or just use the ngrok https URL.)

While `backendURL` is `nil`, the app uses the offline CoreImage mock — nothing breaks.

## API

`POST /generate`  — header `X-App-Token: <APP_TOKEN>`
```json
{ "style": "Ghibli", "image": "<base64 jpeg>" }   →   { "image": "<base64 png>" }
```

## Swapping providers

`generateWithGemini()` in `index.js` is the only provider-specific piece. To use
fal.ai / Replicate (FLUX + InstantID/PuLID for stronger face identity), replace
that one function and keep the same `{style,image} → {image}` contract.

## Before production

- Replace the static `APP_TOKEN` with real per-user auth (Sign in with Apple).
- Check the user's RevenueCat credits **before** calling the provider.
- Add a content-safety filter and basic rate limiting.
- Deploy to a host with `fetch` + Node 18 (Render, Railway, Fly, a VM) or port
  the single handler to Cloudflare Workers / Vercel / Supabase Edge Functions.
