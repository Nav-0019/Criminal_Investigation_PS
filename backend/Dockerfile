FROM python:3.11-slim

# Install ffmpeg (required by Whisper)
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY main.py .

# Expose port
EXPOSE 8000

# Environment defaults
ENV WHISPER_MODEL=base
ENV HOST=0.0.0.0
ENV PORT=8000

# Run with uvicorn
CMD uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
