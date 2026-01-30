#!/bin/bash
# Generate browser-compatible certificate (ECDSA)
# PQC is handled at TLS handshake level (ML-KEM)

set -e

CERT_DIR="${1:-./certs}"
IMAGE="oleglod/cafe-crypto-backend:runtime-oqs"

echo "Generating browser-compatible ECDSA certificate (P-384)"
echo "Certificate directory: $CERT_DIR"

mkdir -p "$CERT_DIR"

# 1️⃣ Generate ECDSA private key (P-384)
echo "Step 1: Generating ECDSA P-384 private key..."
docker run --rm \
  -v "$(pwd)/$CERT_DIR:/certs" \
  "$IMAGE" genpkey \
  -algorithm EC \
  -pkeyopt ec_paramgen_curve:P-384 \
  -out /certs/server.key

# 2️⃣ Generate self-signed certificate (ECDSA)
echo "Step 2: Generating self-signed ECDSA certificate..."
docker run --rm \
  -v "$(pwd)/$CERT_DIR:/certs" \
  "$IMAGE" req \
  -new \
  -x509 \
  -key /certs/server.key \
  -out /certs/server.crt \
  -days 365 \
  -sha384 \
  -subj "/C=FR/ST=Ile-de-France/L=Paris/O=CAFE/OU=Quantum/CN=localhost"

echo ""
echo "Certificate generated successfully!"
echo "Files:"
echo "  - Private key: $CERT_DIR/server.key"
echo "  - Certificate: $CERT_DIR/server.crt"

echo ""
echo "IMPORTANT:"
echo "- This certificate is browser-compatible (Chrome/Firefox/Safari)"
echo "- Post-quantum security is enforced at TLS handshake level (ML-KEM)"
echo ""

echo "Verify certificate:"
echo "  docker run --rm -v \"\$(pwd)/$CERT_DIR:/certs\" $IMAGE x509 -in /certs/server.crt -text -noout"
