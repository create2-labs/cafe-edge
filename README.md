# cafe-edge

Edge / reverse-proxy images with Post-Quantum Cryptography (PQC) support for the CAFE platform. **NGINX is currently the only use case**, but the repository is designed so that other stacks (e.g. Traefik) can be added later; images are built on top of `oleglod/cafe-crypto-backend:runtime-oqs`.

This image is **consumed by [cafe-deploy](https://github.com/create2-labs/cafe-deploy)**. It does **not** include an nginx config; cafe-deploy provides the configuration at runtime (templates + entrypoint with `envsubst`).


## Overview

The **NGINX** image (current use case) provides:

- **NGINX** with TLS 1.3 and hybrid post-quantum key exchange (OQS)
- **gettext** (`envsubst`) for template rendering at startup in cafe-deploy
- **OpenSSL with OQS provider** from the base image `oleglod/cafe-crypto-backend:runtime-oqs`

Prerequisites for building: the OQS runtime image must exist (build from [cafe-crypto-backend](https://github.com/create2-labs/cafe-crypto-backend) or pull `oleglod/cafe-crypto-backend:runtime-oqs` from Docker Hub).

---

## Building the image

```bash
docker build -f nginx/Dockerfile -t oleglod/cafe-edge:nginx-latest ./nginx
```

**Prerequisite:** the base image must be available:

```bash
docker pull oleglod/cafe-crypto-backend:runtime-oqs
```

---

## Usage with cafe-deploy

[cafe-deploy](https://github.com/create2-labs/cafe-deploy) uses this image as the NGINX service. It:

1. Overrides the entrypoint with `entrypoint-nginx.sh`
2. Mounts its own templates (`templates/nginx/`) and writes the rendered config to `rendered/nginx/`
3. Mounts certificates from `volumes/nginx/certs/`
4. Runs `envsubst` then `nginx -c /rendered/nginx/nginx.conf`

So **no nginx config is baked into this image**; it is supplied at runtime by cafe-deploy.

To use the image from cafe-deploy, point the compose image to the published tag (e.g. `oleglod/cafe-edge:nginx-${NGINX_VERSION}` once you have aligned image naming and versions).

---

## Published image

CI publishes the image on Docker Hub on tag push (e.g. `v1.0.0`):

- `oleglod/cafe-edge:<tag>-nginx` (e.g. `v1.0.0-nginx`, `latest-nginx`)

See [.github/workflows/docker-release.yml](.github/workflows/docker-release.yml).

---

## Certificates

SSL certificates are **not** included in the image. They are mounted at runtime (e.g. by cafe-deploy from `volumes/nginx/certs/`).

To generate a self-signed certificate (e.g. for dev) using the OQS runtime:

```bash
./scripts/generate-hybrid-cert.sh
# or with a custom directory
./scripts/generate-hybrid-cert.sh /path/to/certs
```

The script uses `cafe-oqs:runtime`; ensure the image is available locally or use `oleglod/cafe-oqs:runtime` (and set `IMAGE=oleglod/cafe-oqs:runtime` in the script if needed).

---

## Standalone use (optional)

If you run the image **without** cafe-deploy, you must provide your own nginx config and certificates (the image has no default `nginx.conf`):

```bash
docker run -d \
  -p 80:80 -p 443:443 \
  -v /path/to/your/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v /path/to/certs:/etc/nginx/certs:ro \
  oleglod/cafe-edge:nginx-latest
```

Or override the command to point to a config you mount elsewhere (e.g. `/rendered/nginx/nginx.conf`).

---

## Repository layout

```
cafe-edge/
├── nginx/
│   └── Dockerfile          # Image definition (no config baked in)
├── scripts/
│   └── generate-hybrid-cert.sh
├── .github/workflows/
│   └── docker-release.yml  # Build and publish on tag push
└── README.md
```

---

## References

- [cafe-deploy](https://github.com/create2-labs/cafe-deploy) – deployment and nginx config/templates
- [cafe-crypto-backend](https://github.com/create2-labs/cafe-crypto-backend) – OQS base images (build-oqs, runtime-oqs)
- [NGINX](https://nginx.org/en/docs/) · [Open Quantum Safe](https://openquantumsafe.org/)
