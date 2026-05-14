# ── Stage 1: builder ──────────────────────────────────────────────────────────
FROM python:3.12-slim AS builder

WORKDIR /build

# Install deps into a local prefix so we can copy cleanly
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: runtime ──────────────────────────────────────────────────────────
FROM python:3.12-slim AS runtime

# Non-root user (UID >= 10001 per spec)
RUN addgroup --gid 10001 helep && \
    adduser  --uid 10001 --gid 10001 --no-create-home --disabled-password helep

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /install /usr/local

# Copy only what the app needs — no tests, no IDE files
COPY app ./app
COPY requirements.txt .

# Data dir for SQLite PVC mount
RUN mkdir -p /data && chown helep:helep /data

USER helep

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

EXPOSE 8004

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8004"]
