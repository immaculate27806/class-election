import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'candidate.dart';
import 'election_home.dart';

String cleanName(String raw) {
  final words = raw.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final _nameController = TextEditingController();
  String? _message;
  bool _isError = false;
  bool _busy = false;

  Future<void> _vote(Candidate candidate) async {
    final voterName = cleanName(_nameController.text);
    if (voterName.isEmpty) {
      setState(() {
        _message = 'Please enter your name.';
        _isError = true;
      });
      return;
    }

    setState(() => _busy = true);

    try {
      // Check if this voter name has already voted
      final existing = await myVoters().doc(voterName).get();
      if (existing.exists) {
        setState(() {
          _message = '$voterName has already voted.';
          _isError = true;
        });
        return;
      }

      // Record the voter and increment the candidate's votes atomically
      final batch = FirebaseFirestore.instance.batch();
      batch.set(myVoters().doc(voterName), {
        'name': voterName,
        'votedFor': candidate.id,
        'votedAt': FieldValue.serverTimestamp(),
      });
      batch.update(myCandidates().doc(candidate.id), {
        'votes': FieldValue.increment(1),
      });
      await batch.commit();

      setState(() {
        _message = '$voterName voted for ${candidate.name}!';
        _isError = false;
        _nameController.clear();
      });
    } catch (e) {
      setState(() {
        _message = 'Could not cast vote. Try again.';
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [logoutAction(context)],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: myCandidates().orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load candidates.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final candidates =
              snapshot.data!.docs.map(Candidate.fromDoc).toList();

          // Also stream total votes for the header
          final totalVotes =
              candidates.fold<int>(0, (acc, c) => acc + c.votes);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (_) => setState(() => _message = null),
                ),
                const SizedBox(height: 8),
                Text('Total votes so far: $totalVotes'),
                const SizedBox(height: 8),
                if (_message != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isError
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _message!,
                      style: TextStyle(
                        color: _isError
                            ? Colors.red.shade800
                            : Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Tap a candidate to vote:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: candidates.isEmpty
                      ? const Center(
                          child: Text(
                              'No candidates yet. Add one in the Candidates tab.'))
                      : ListView.builder(
                          itemCount: candidates.length,
                          itemBuilder: (context, i) {
                            final c = candidates[i];
                            return Card(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  child: Text(c.name[0],
                                      style: const TextStyle(
                                          color: Colors.white)),
                                ),
                                title: Text(c.name,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                trailing: _busy
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : const Icon(Icons.how_to_vote),
                                onTap: _busy ? null : () => _vote(c),
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
