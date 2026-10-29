# Ijwi Class Vote — Class Election App

A Flutter app for running a class election, built for Mobile Programming Week 3 Session 6.

## Features

### Session 4 (original)
- Vote for candidates by name
- Live results with progress bars and winner/tie banner
- Add and remove candidates
- Duplicate voter detection

### Session 6 — Firebase (this submission)
- **Authentication** — create account, log in, log out with email and password
- **Firestore** — all candidates and votes saved in the cloud under each user's private path
- **Live updates** — results update instantly without refreshing, using StreamBuilder
- **Private data** — Firestore security rules ensure each user only sees their own data
- **Sample data** — new accounts start with 3 sample candidates (Keza, Mutoni, Ishimwe)
- **Loading, error and empty states** on every screen

## Firestore structure

```
users/
  {uid}/
    candidates/   ← name, votes
    voters/       ← name, votedFor, votedAt
```

## Screenshots

| Login | Validation |
|---|---|
| ![Login](screenshots/login.png) | ![Validation](screenshots/login-validation.png) |

| Vote | Results |
|---|---|
| ![Vote](screenshots/vote.png) | ![Results](screenshots/results_winner.png) |

| Tie | Candidates |
|---|---|
| ![Tie](screenshots/results-tie.png) | ![Candidates](screenshots/candidates.png) |

## Tech stack

- Flutter + Dart
- Firebase Authentication (Email/Password)
- Cloud Firestore
- Material 3
