# CheckedIn

> One check. Complete proof.

A native iOS app for people with OCD-style checking anxiety. Photograph your stove, door, or iron — get objective proof with timestamp, location, and AI verdict. No more going back.

---

## Features

- **One-tap capture** — photo, location, and AI analysis in seconds
- **Proof screen** — clear human verdict, confirmed by photo
- **AI analysis** — Apple Vision classifies the image to confirm whether an appliance is on/off or a door is open/closed
- **Session Mode** — guided checklist before leaving home
- **Anti-recheck friction** — gentle reminder if you check twice in 30 minutes
- **Voice confirmation** — spoken verdict after each successful check
- **Auto-expiry** — checks delete themselves after 24 hours
- **100% on-device** — no account, no cloud, no tracking

---

<!-- Screenshots coming soon -->

## Tech Stack

| | |
|---|---|
| Language | Swift 5.9 |
| UI | SwiftUI |
| Storage | SwiftData |
| AI | Apple Vision |
| Location | CoreLocation |
| Voice | AVSpeechSynthesizer |
| Camera | AVFoundation |
| Min iOS | 17.0 |

---

## Architecture

```
MVVM — strict separation of logic and views

CheckedIn/
├── Models/
│   ├── SafeCheck.swift
│   ├── SessionItem.swift
│   └── SessionCheck.swift
├── ViewModels/
│   ├── CheckFeedViewModel.swift
│   ├── SessionViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── CheckFeedView.swift
│   ├── CheckDetailView.swift
│   ├── CheckCardView.swift
│   ├── CameraView.swift
│   ├── SessionView.swift
│   ├── RecheckFrictionSheet.swift
│   └── SettingsView.swift
├── Services/
│   ├── CameraService.swift
│   ├── LocationService.swift
│   ├── VisionService.swift
│   ├── SpeechService.swift
│   ├── ExpiryService.swift
│   └── HapticService.swift
└── Helpers/
    ├── VerdictFormatter.swift
    └── RecentCheckResult.swift
```

---

## Requirements

- Xcode 15+
- iOS 17.0+
- Physical device for camera and location testing

---


No dependencies. No package manager. Build and run.

---

## Privacy

- All data stays on device
- No analytics, no tracking, no ads
- Camera and location used locally only
- Checks auto-delete after 24 hours

---

## Design Principles

- Calm, minimal, native iOS
- Follows Apple HIG throughout
- No streaks, counters, or gamification
- No confidence scores in UI
- Human-readable verdicts only
- Psychologically safe — reduces checking, never reinforces it

---

## Author

Built by [@sushanttiwari_14](https://github.com/sushanttiwari-14)
