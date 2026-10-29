import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'candidate.dart';
import 'election_home.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  String _bannerText(List<Candidate> ranked, int total) {
    if (total == 0) return 'No votes yet';
    final top = ranked.first.votes;
    final tied = ranked.where((c) => c.votes == top).toList();
    if (tied.length == 1) return 'Winner: ${tied.first.name}';
    final names = tied.map((c) => c.name).join(' and ');
    return 'Tie between $names ($top votes each)';
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset all votes?'),
        content: const Text(
            'This will set every candidate back to 0 and clear all voters. Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reset')),
        ],
      ),
    );
    if (confirm != true) return;

    // Reset all candidate votes to 0
    final candidateDocs = await myCandidates().get();
    final batch = myCandidates().firestore.batch();
    for (final doc in candidateDocs.docs) {
      batch.update(doc.reference, {'votes': 0});
    }

    // Delete all voter records
    final voterDocs = await myVoters().get();
    for (final doc in voterDocs.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            onPressed: () => _confirmReset(context),
          ),
          logoutAction(context),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: myCandidates().orderBy('votes', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load results.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final ranked = snapshot.data!.docs.map(Candidate.fromDoc).toList();
          // Sort by votes desc, then name asc (same logic as before)
          ranked.sort((a, b) {
            final byVotes = b.votes.compareTo(a.votes);
            return byVotes != 0 ? byVotes : a.name.compareTo(b.name);
          });

          final total = ranked.fold<int>(0, (s, c) => s + c.votes);
          final banner = _bannerText(ranked, total);
          final isWinner = banner.startsWith('Winner');

          if (ranked.isEmpty) {
            return const Center(child: Text('No candidates yet.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isWinner
                        ? Colors.amber.shade100
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isWinner ? Colors.amber : Colors.blue,
                        width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isWinner ? Icons.emoji_events : Icons.handshake,
                        color: isWinner
                            ? Colors.amber.shade800
                            : Colors.blue.shade800,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          banner,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isWinner
                                ? Colors.amber.shade800
                                : Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Ranked list
                Expanded(
                  child: ListView.builder(
                    itemCount: ranked.length,
                    itemBuilder: (context, i) {
                      final c = ranked[i];
                      final pct = total == 0 ? 0.0 : c.votes / total;
                      final pctText = total == 0
                          ? 'No votes yet'
                          : '${(pct * 100).toStringAsFixed(1)}%';
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${i + 1}. ${c.name}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${c.votes == 1 ? '1 vote' : '${c.votes} votes'} · $pctText',
                                    style:
                                        TextStyle(color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 14,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation(
                                      Theme.of(context).colorScheme.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
