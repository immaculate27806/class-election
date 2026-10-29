Ijwi Class Vote
Project chosen: Class Election (Mini Project Building, Week 2 · Session 4) Author: YOUR NAME HERE

A small Flutter app where a class elects its representative. Names are cleaned, each voter votes once, and results are ranked with percentages and a winner/tie banner.

Features
Vote screen: type your name, tap a candidate; total votes shown
Names cleaned (trimmed, single spaces, Title Case): aLINE and Aline are the same voter
One vote per voter ("Aline has already voted")
Results ranked highest first, with votes, percentage (1 decimal) and a bar
Banner: Winner: Keza or Tie between Keza and Mutoni (4 votes each)
"No votes yet" before any vote (never NaN%)
Candidates screen: add (no empty/duplicate names), remove only if 0 votes
Reset with an "Are you sure?" dialog
Empty-state messages when there are no candidates
Screenshots
Vote screen: screenshots/vote.png
Results with a winner: screenshots/results-winner.png
Results with a tie: screenshots/results-tie.png
Candidates screen: screenshots/candidates.png
Think questions
1. Why must names be cleaned before they are compared? Because aline, ALINE and Aline look different to the computer even though they are the same person. If I compared first, Aline could vote three times, or "keza" could be added as a second candidate next to "Keza". Cleaning first makes them all Aline.

2. How does your app decide between a winner and a tie? It ranks the candidates by votes, then takes the top score. It collects every candidate who has that same top score. If only one candidate has it, that candidate is the winner. If two or more share it, the banner says it is a tie and lists their names.

