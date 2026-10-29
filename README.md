# Ijwi Class Vote

A Flutter app where a class elects its representative. Every vote counts exactly once, names are cleaned before they are used, results are ranked, and a tie is never shown as a fake winner.

- **Student:** Immaculate Mutarutwa
- **Course:** Mobile Programming, Innovation Center (Week 2 · Session 4, Mini Project Building)
- **Project chosen:** Class Election
- **GitHub:** https://github.com/immaculate27806/class-election

## Features

**Vote screen**
- The voter types their name, then taps a candidate card to vote
- Shows the total number of votes so far
- Clear green or red message after every attempt

**Results screen**
- Every candidate ranked, highest votes first (ties sorted by name)
- Votes, percentage with one decimal (for example `44.4%`) and a bar of the same size
- Banner: `Winner: Keza`, or `Tie between Keza and Mutoni (4 votes each)`
- Shows `No votes yet` before any vote, never `NaN%`
- **Reset** button with an "Are you sure?" dialog

**Candidates screen**
- Add a candidate; empty names and duplicates are refused
- Remove a candidate only if they have no votes (a lock icon shows when removal is not allowed)

**Rules and checks**
- Names are cleaned: spaces removed at both ends, extra spaces between words removed, Title Case (`  keza  uwase ` becomes `Keza Uwase`)
- Each voter can vote only once: `aLINE` votes, then `Aline` is refused with "Aline has already voted"
- Friendly empty-state messages when there are no candidates
- Three sample candidates at the start: Keza, Mutoni, Ishimwe

## Screenshots

| Vote | Results (winner) |
|---|---|
| ![Vote screen](screenshots/vote.png) | ![Results with a winner](screenshots/results-winner.png) |

| Results (tie) | Candidates |
|---|---|
| ![Results with a tie](screenshots/results-tie.png) | ![Candidates screen](screenshots/candidates.png) |

## How the code is organised

All the code is in `lib/main.dart`:
- `cleanName()`: cleans any name before it is compared or stored
- `Candidate`: the model class (name and votes)
- `ElectionState`: holds the data and all the rules (`vote`, `addCandidate`, `removeCandidate`, `reset`, `ranked`, `bannerText`), outside of `build`
- `VoteScreen`, `ResultsScreen`, `CandidatesScreen`: the three screens, shown with a bottom navigation bar and always up to date because they listen to `ElectionState`

## How to run

```
git clone https://github.com/immaculate27806/class-election.git
cd class-election
flutter pub get
flutter run -d chrome
```

## Think questions

**1. Why must names be cleaned before they are compared? Give an example of what goes wrong otherwise.**

The computer compares letters exactly, so `aline`, `ALINE` and ` Aline ` look like three different names even though they are the same person. If I compared first and cleaned later, Aline could vote three times, and `keza` could be added as a second candidate next to `Keza`. Cleaning first turns all of them into `Aline`, so the same person is always recognised as the same voter.

**2. How does your app decide between a winner and a tie? Explain it in plain words.**

The app first ranks the candidates from the most votes to the fewest and takes the top score. Then it collects every candidate who has exactly that top score. If only one candidate has it, that candidate is the winner. If two or more share it, the banner says it is a tie and lists their names with the number of votes they share. If nobody has voted yet, it says "No votes yet" instead.

## Built with

Flutter and Dart (Material 3, teal theme).