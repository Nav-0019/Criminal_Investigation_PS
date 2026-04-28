# Namma Shield Backend

AI-powered scam call detection API — FastAPI + OpenAI Whisper.

## Deploy to Railway (Recommended)

### Step 1 — Push to GitHub
Make sure this repo is on GitHub (it already is).

### Step 2 — Create Railway Project
1. Go to [railway.app](https://railway.app) → **New Project**
2. Choose **Deploy from GitHub repo**
3. Select this repository

### Step 3 — Set Root Directory
In Railway project settings → **Source** → set **Root Directory** to:
```
backend
```

### Step 4 — Set Environment Variables (optional)
In Railway project → **Variables**:

| Variable | Value | Notes |
|---|---|---|
| `WHISPER_MODEL` | `tiny` | Default. Use `base` for better accuracy (needs more RAM) |

Railway automatically provides `PORT` — **do not set it manually**.

### Step 5 — Deploy
Railway will auto-detect `nixpacks.toml` and:
- Install **ffmpeg** (required by Whisper)
- Install Python dependencies with **CPU-only PyTorch**
- Start the server on the correct port

> ⚠️ **First boot takes 2–5 minutes** — Whisper downloads the model (~75MB for tiny) on first startup.

### Step 6 — Get Your URL
Railway gives you a URL like:  
`https://your-app.up.railway.app`

Copy this and update `ApiConfig.baseUrl` in `frontend/lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-app.up.railway.app';
```

## API Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/` | Health check + model info |
| GET | `/health` | Deployment health probe |
| POST | `/analyze/` | Analyze an audio file |

### POST `/analyze/` — Request
```bash
curl -X POST https://your-app.up.railway.app/analyze/ \
  -F "file=@suspicious_call.mp3"
```

### POST `/analyze/` — Response
```json
{
  "success": true,
  "filename": "suspicious_call.mp3",
  "transcript": "Please share your OTP immediately...",
  "language": "en",
  "fraud_score": 85,
  "risk": "HIGH",
  "highlighted_words": ["otp", "immediately"],
  "fraud_types": ["otp_fraud", "urgency"]
}
```

## Run Locally

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate      # Windows
# source .venv/bin/activate  # macOS/Linux

pip install -r requirements.txt
python main.py
# → http://localhost:8000
```

## Model Size Guide

| Model | Size | RAM | Accuracy | Use case |
|---|---|---|---|---|
| `tiny` | 75 MB | ~200 MB | Good | Railway free tier |
| `base` | 150 MB | ~300 MB | Better | Railway hobby tier |
| `small` | 500 MB | ~500 MB | Best | Dedicated server |

## Deploy with Docker (Alternative)

```bash
docker build -t namma-shield-backend .
docker run -p 8000:8000 -e WHISPER_MODEL=tiny namma-shield-backend
```
