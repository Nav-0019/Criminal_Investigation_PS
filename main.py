from fastapi import FastAPI, File, UploadFile
import shutil
import whisper

app = FastAPI()

# Load Whisper model
model = whisper.load_model("tiny")


# 🧠 Fraud Detection Function
def detect_fraud(text):
    text_lower = text.lower()

    fraud_categories = {
        "otp_fraud": ["otp", "one time password", "verification code"],
        "bank_fraud": ["bank", "account blocked", "suspend", "debit", "credit"],
        "kyc_fraud": ["kyc", "update kyc", "verify kyc"],
        "card_fraud": ["credit card", "debit card", "cvv", "card details"],
        "phishing": ["click link", "http", "www", "download app"],
        "urgency": ["urgent", "immediately", "limited time", "act now"],
        "authority": ["rbi", "police", "government", "official"],
        "lottery": ["won", "prize", "lottery", "reward"],
        "loan_scam": ["loan", "interest rate", "pre-approved"],
    }

    matched_words = []
    detected_types = []

    for category, keywords in fraud_categories.items():
        for word in keywords:
            if word in text_lower:
                matched_words.append(word)
                detected_types.append(category)

    score = min(len(matched_words) * 15, 100)

    if score > 70:
        risk = "HIGH"
    elif score > 40:
        risk = "MEDIUM"
    else:
        risk = "LOW"

    return score, risk, list(set(matched_words)), list(set(detected_types))


# 🎙️ Analyze API
@app.post("/analyze/")
async def analyze(file: UploadFile = File(...)):

    filename = "audio_input"

    # Save uploaded file
    with open(filename, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # 🎙️ Transcribe audio
    result = model.transcribe(filename)
    transcript = result["text"]

    # 🧠 Fraud detection
    score, risk, words, types = detect_fraud(transcript)

    return {
        "transcript": transcript,
        "fraud_score": score,
        "risk": risk,
        "highlighted_words": words,
        "fraud_types": types
    }