# Tour Group & Expense (Flutter, No Packages)

A clean Material 3 Flutter app to manage a tour group and track expenses in four sections:
**Transport, Meal, Motel, Others**.

## Features
- Add/remove members (unlimited).
- Add expenses: title, amount, section, payer, participants (equal split).
- Per-section totals + per-member per-section breakdown.
- Overall balances (+ receive / - pay) and greedy settlement suggestions.
- Pure Flutter (no 3rd-party packages) with a clean, modern UI.

## Run
```bash
flutter run
```
Create a release APK:
```bash
flutter build apk
```

> Data is in-memory only for this MVP (resets on restart). Add persistence later with shared_preferences if you want.
