# Play listing — Canvas

ElecTream. Package `com.electream.canvas`. Version **0.9.17**. Play first; iOS later.

## Title (30)

Canvas

## Short description (80)

A clean notes app. Write on your phone, keep it local, attach a photo if you want.

## Full description

Canvas is a small notes app with a dark UI. Write, edit, attach a photo, done.

Notes live on your device. Optional Google sign-in is available. No ads.

Published by ElecTream.

## Data safety (draft)

- Collected: notes and images on device; optional Google account if signed in
- Shared: no ads; Google is a processor if you sign in
- Encrypted in transit: yes when talking to Google/Firebase
- Users can delete: uninstall / remove notes; listing contact for account deletion until that UI ships
- Children: no

## Before upload

- [ ] Release signing (not debug keys) + `version: 0.9.17+N`
- [ ] Vendor or publish `local_sync` so a store CI can `flutter pub get`
- [ ] `flutter build appbundle --release`
- [ ] Play App Signing SHAs in Firebase / OAuth for `com.electream.canvas`
- [ ] Public HTTPS URL for [PRIVACY.md](PRIVACY.md)
- [ ] Phone screenshots + 1024×500 feature graphic (`assets/icon.png`)
- [ ] Data safety form; camera/photos declared
- [ ] Confirm GPL-3 vs Play distribution, or relicense before listing
- [ ] In-app account deletion if Google Sign-In stays in the shipped build
