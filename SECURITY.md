# Security policy — Pannipe

This repository is **public**. Treat every commit as world-readable.

## Never commit

| Item | Local location | Template in git |
|------|----------------|-----------------|
| App secrets | `.env` | `.env.example` |
| Google Maps (Android) | `android/secrets.properties` | `android/secrets.properties.example` |
| Google Maps (iOS) | `ios/Runner/Secrets.plist` | `ios/Runner/Secrets.plist.example` |
| Firebase Android | `android/app/google-services.json` | `android/app/google-services.json.example` |
| Firebase iOS | `ios/Runner/GoogleService-Info.plist` | (create via FlutterFire) |
| Signing keys | `*.jks`, `*.keystore`, `*.p12`, `*.p8`, `*.pem` | — |
| Service accounts | `*service-account*.json`, `firebase-adminsdk*.json` | — |
| SMTP | Firebase Functions secrets only | — |

## Pre-push checklist (SR / security engineer)

```bash
# 1) Confirm secrets are ignored
git check-ignore -v .env android/secrets.properties ios/Runner/Secrets.plist android/app/google-services.json

# 2) No real keys in the index
git grep -n "AIza" -- . ':!.env.example' ':!*example*' ':!README.md' ':!SECURITY.md' || true
git status --ignored | findstr /I ".env secrets google-services Secrets.plist"

# 3) Diff review before push
git diff --cached
git ls-files | findstr /I "env secrets google-services keystore pem"
```

If a real key ever lands in git history: **rotate it in Google Cloud / Firebase immediately**, then purge history or accept rotation as the fix (public forks may already have cloned it).

## Runtime controls

- **Firestore / Storage rules** — least privilege; guests only read catalogue; orders constrained; OTP docs server-only.
- **Cloud Functions** — Admin SDK for fee integrity + custom tokens; SMTP via `defineSecret`.
- **API key restrictions** — restrict Maps + Firebase client keys by Android package + SHA, iOS bundle ID, and API list in Google Cloud Console.
- **No hardcoded keys in Dart/Swift/Kotlin** — `Env` + native placeholders only.

## Reporting

If you find a leaked credential or rules bypass in this public repo, open a private report with the maintainers and rotate affected keys first.
