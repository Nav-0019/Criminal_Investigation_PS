import os
import shutil
import tempfile
import logging
from datetime import datetime

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import whisper
import uvicorn

# ── Logging ─────────────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("namma_shield")

# ── App ─────────────────────────────────────────────────────────────────────────
app = FastAPI(
    title="Namma Shield Backend",
    description="AI-powered scam call detection API for NammaShield",
    version="1.0.0",
)

# ── CORS — allow Flutter app from any origin ────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Whisper model ───────────────────────────────────────────────────────────────
MODEL_SIZE = os.environ.get("WHISPER_MODEL", "tiny")  # Use 'base' or 'small' for better accuracy if RAM allows
model = None


@app.on_event("startup")
async def load_model():
    global model
    logger.info("Loading Whisper model: %s …", MODEL_SIZE)
    model = whisper.load_model(MODEL_SIZE)
    logger.info("Whisper model loaded successfully.")


# ── Fraud Detection ─────────────────────────────────────────────────────────────
FRAUD_CATEGORIES = {
    "otp_fraud": [
        "otp", "one time password", "verification code",
        "don't share", "do not share", "share otp",
    ],
    "bank_fraud": [
        "bank", "account blocked", "account suspended", "suspend",
        "debit", "credit", "manager", "branch", "transfer",
        "neft", "rtgs", "imps",
    ],
    "kyc_fraud": [
        "kyc", "update kyc", "verify kyc", "pan card",
        "aadhaar", "aadhar", "pan number",
    ],
    "upi_fraud": [
        "upi", "upi pin", "google pay", "phonepe", "paytm",
        "bhim", "upi id",
    ],
    "card_fraud": [
        "credit card", "debit card", "cvv", "card details",
        "expiry", "card number", "card blocked",
    ],
    "phishing": [
        "click link", "click here", "http", "www",
        "download app", "apk", "anydesk", "teamviewer",
        "install", "remote access",
    ],
    "urgency": [
        "urgent", "immediately", "limited time", "act now",
        "penalty", "fine", "deadline", "last chance",
        "within 24 hours", "expire",
    ],
    "authority_impersonation": [
        "rbi", "police", "government", "official", "customs",
        "cbi", "income tax", "it department", "court order",
        "arrest warrant", "legal action", "trai",
    ],
    "lottery_prize": [
        "won", "prize", "lottery", "reward", "kbc",
        "lucky winner", "congratulations", "selected",
    ],
    "loan_scam": [
        "loan", "interest rate", "pre-approved",
        "no documentation", "instant loan", "processing fee",
    ],
    "insurance_scam": [
        "insurance", "policy expired", "claim bonus",
        "maturity amount",
    ],
}


def detect_fraud(text: str) -> dict:
    """Analyse transcript text and return fraud detection results."""
    text_lower = text.lower()

    matched_words: list[str] = []
    detected_types: list[str] = []

    for category, keywords in FRAUD_CATEGORIES.items():
        for word in keywords:
            if word in text_lower:
                matched_words.append(word)
                if category not in detected_types:
                    detected_types.append(category)

    # Weighted scoring: more unique categories → higher risk
    keyword_score = min(len(matched_words) * 12, 70)
    category_bonus = min(len(detected_types) * 10, 30)
    score = min(keyword_score + category_bonus, 100)

    if score >= 65:
        risk = "HIGH"
    elif score >= 35:
        risk = "MEDIUM"
    else:
        risk = "LOW"

    return {
        "fraud_score": score,
        "risk": risk,
        "highlighted_words": list(set(matched_words)),
        "fraud_types": detected_types,
    }


# ── Allowed audio extensions ────────────────────────────────────────────────────
ALLOWED_EXTENSIONS = {".wav", ".mp3", ".ogg", ".m4a", ".aac", ".flac", ".webm", ".wma"}

def _validate_extension(filename: str) -> str:
    """Return lowercase extension or raise 400."""
    ext = os.path.splitext(filename)[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported file type '{ext}'. Allowed: {', '.join(sorted(ALLOWED_EXTENSIONS))}",
        )
    return ext


# ── Routes ──────────────────────────────────────────────────────────────────────

@app.get("/")
async def health_check():
    """Health-check endpoint."""
    return {
        "status": "healthy",
        "service": "Namma Shield Backend",
        "model": f"whisper-{MODEL_SIZE}",
        "timestamp": datetime.utcnow().isoformat(),
    }


@app.get("/health")
async def health():
    """Explicit health endpoint for deployment platforms."""
    return {"status": "ok"}


@app.post("/analyze/")
async def analyze(file: UploadFile = File(...)):
    """
    Accept an audio file, transcribe it with Whisper,
    run fraud detection, and return the results.
    """
    if not file.filename:
        raise HTTPException(status_code=400, detail="No file uploaded.")

    ext = _validate_extension(file.filename)

    # Save to a temp file (supports concurrent requests)
    with tempfile.NamedTemporaryFile(delete=False, suffix=ext) as tmp:
        shutil.copyfileobj(file.file, tmp)
        temp_path = tmp.name

    try:
        logger.info("⏳ Transcribing: %s (%s)", file.filename, ext)
        result = model.transcribe(temp_path)
        transcript = result.get("text", "").strip()
        language = result.get("language", "unknown")
        logger.info("✅ Transcription complete — %d chars, language=%s", len(transcript), language)

        # Run fraud analysis
        fraud = detect_fraud(transcript)

        return {
            "success": True,
            "filename": file.filename,
            "transcript": transcript,
            "language": language,
            "fraud_score": fraud["fraud_score"],
            "risk": fraud["risk"],
            "highlighted_words": fraud["highlighted_words"],
            "fraud_types": fraud["fraud_types"],
        }

    except Exception as e:
        logger.error("❌ Analysis failed for %s: %s", file.filename, e, exc_info=True)
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")

    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)


# ── Entry point ─────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    host = os.environ.get("HOST", "0.0.0.0")
    port = int(os.environ.get("PORT", 8000))
    logger.info("Starting Namma Shield on %s:%d", host, port)
    uvicorn.run(app, host=host, port=port)