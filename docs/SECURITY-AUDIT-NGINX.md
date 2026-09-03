# nginx — Phase 0 Scout findings (acceptance)

> Dernière revue : 2026-09-01 — baseline `RUN_ID=20260901-111146`  
> Image : `oleglod/cafe-edge-nginx` (base `cafe-crypto-backend:runtime-oqs` + `apt install nginx`)

## Synthèse Scout

| Sévérité | Count | Statut Phase 0 |
| --- | --- | --- |
| Critical | 1 | **Accepté** (alpha publique, voir ci-dessous) |
| High | 2 | **Accepté** (modules non utilisés / pas de correctif Debian) |
| Medium / Low | 3 / 39 | Suivi ; pas bloquant RC no-draft |

Rapport détaillé : `reports/cafe-edge-security-audit-20260901-111146.md`

## Findings et décision

### CVE-2026-42533 — nginx (Critical)

- **Paquet image** : `nginx` `1.26.3-3+deb12u7` (Debian via `runtime-oqs`)
- **Correctif upstream** : nginx **1.30.4-3** — **non disponible** dans les dépôts Debian de la base image au moment de l’audit
- **Condition d’exploitation** : `map` avec regex + capture référencée avant la sortie du map (config nginx avancée)
- **Config CAFE** : templates fournis par `cafe-deploy` à l’exécution ; pas de `map` regex identifié dans la config edge standard (reverse proxy + TLS)
- **Décision** : acceptation documentée pour **alpha publique** jusqu’à rebuild sur base `runtime-oqs` / nginx packagé ≥ 1.30.4 ou image nginx officielle épinglée
- **Réévaluation** : à chaque rebuild `runtime-oqs` et avant passage GA

### CVE-2026-60005 — ngx_http_slice_module (High)

- Module **non activé** dans notre build nginx Debian (`slice` absent des templates deploy)
- Accepté : surface non exposée

### CVE-2026-56434 — ngx_http_ssi_module (High)

- SSI **non configuré** ; `proxy_buffering` / `proxy_pass` SSI chain non utilisée dans la config edge standard
- Accepté : surface non exposée

## Actions de sortie Phase 0

1. Surveiller mises à jour `cafe-crypto-backend:runtime-oqs` (prérequis edge + frontend)
2. Re-audit Scout après bump base ; viser **C=0** avant GA
3. Plan plateforme : `cafe-deploy/reports/platform-security-plan-*.md`

## Références

- [F5 K000162097](https://my.f5.com/manage/s/article/K000162097) (CVE-2026-42533)
- `cafe-deploy/SECURITY_ENHANCEMENT.md` — critères Phase 0
