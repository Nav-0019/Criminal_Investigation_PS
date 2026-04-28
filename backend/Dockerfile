FROM python:3.11-slim

# Install ffmpeg (required by Whisper)
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Hugging Face Spaces requires a non-root user
RUN useradd -m -u 1000 user
USER user
ENV PATH="/home/user/.local/bin:$PATH"

WORKDIR /app

# Install Python dependencies
COPY --chown=user requirements.txt .
# Install CPU-only PyTorch to keep image size small
RUN pip install --user --no-cache-dir torch torchaudio --index-url https://download.pytorch.org/whl/cpu
RUN pip install --user --no-cache-dir -r requirements.txt

# Copy application code
COPY --chown=user main.py .

# Environment defaults
ENV WHISPER_MODEL=tiny
ENV HOST=0.0.0.0
ENV PORT=7860

EXPOSE 7860

# Run with python to gracefully handle the dynamic PORT
CMD ["python", "main.py"]
