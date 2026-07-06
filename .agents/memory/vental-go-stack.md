---
name: VenTal Go Flutter stack
description: Key constraints and decisions for the VenTal Go superapp project.
---

## Stack
Flutter + MapLibre GL + Provider + geolocator + url_launcher + shimmer + http. Package name: `vental_go`.

## Key rules
- `http` must be an explicit dependency in pubspec.yaml (not just transitive); otherwise `flutter analyze` reports `depend_on_referenced_packages` infos.
- MapLibre GL `withOpacity` triggers a deprecation warning — use `.withValues(alpha: x)` instead.
- `flutter build apk --release` requires Android SDK. Replit does not have Android SDK. Build step must be done on local machine or Android CI.
- `flutter analyze --no-pub` (after `flutter pub get`) is the gate before any release build.
- Checklist: `attached_assets/MASTER_CHECKLIST_V2_1783318866213.md` — follow strictly, no extras.

**Why:** Established in initial project setup sessions; reproducible lint failures if violated.

**How to apply:** Before shipping any new feature, run `flutter pub get && flutter analyze --no-pub` and confirm 0 issues.
