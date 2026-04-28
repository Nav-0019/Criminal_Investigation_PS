# Namma Shield Backend

AI-powered scam call detection API.

## Quick Start (local)

```bash
cd backend
python -m venv .venv
# Windows:
.venv\Scripts\activate
# macOS/Linux:
source .venv/bin/activate

pip install -r requirements.txt
python main.py
```

The API will start at `http://localhost:8000`.

## Environment Variables

| Variable        | Default   | Description                      |
| --------------- | --------- | -------------------------------- |
| `WHISPER_MODEL` | `base`    | Whisper model size (tiny/base/small/medium/large) |
| `HOST`          | `0.0.0.0` | Bind address                     |
| `PORT`          | `8000`    | Server port                      |

## API Endpoints

| Method | Path         | Description              |
| ------ | ------------ | ------------------------ |
| GET    | `/`          | Health check             |
| GET    | `/health`    | Deployment health probe  |
| POST   | `/analyze/`  | Analyze an audio file    |

## Deploy with Docker

```bash
docker build -t namma-shield-backend .
docker run -p 8000:8000 namma-shield-backend
```

## Deploy to Railway / Render

1. Push this `backend/` folder to a Git repo
2. Connect the repo to Railway or Render
3. Set the root directory to `backend/`
4. The platform will detect the `Procfile` and deploy automatically
