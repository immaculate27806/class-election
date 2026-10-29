import 'package:flutter/material.dart';

import 'candidate.dart';
import 'election_home.dart';

String cleanName(String raw) {
  final words = raw.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  final _controller = TextEditingController();
  String? _message;
  bool _isError = false;

  Future<void> _add() async {
    final name = cleanName(_controller.text);
    if (name.isEmpty) {
      setState(() {
        _message = 'Candidate name cannot be empty.';
        _isError = true;
      });
      return;
    }

    // Check for duplicate names in Firestore
    final existing = await myCandidates()
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      setState(() {
        _message = '$name is already a candidate.';
        _isError = true;
      });
      return;
    }

    await myCandidates().add({'name': name, 'votes': 0});
    setState(() {
      _message = '$name added!';
      _isError = false;
      _controller.clear();
    });
  }

  Future<void> _delete(BuildContext context, Candidate c) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove candidate?'),
        content: Text('Remove ${c.name} from the election?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (sure == true) {
      await myCandidates().doc(c.id).delete();
      setState(() => _message = null);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidates'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [logoutAction(context)],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'New candidate name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_add),
                    ),
                    onChanged: (_) => setState(() => _message = null),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _add, child: const Text('Add')),
              ],
            ),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      _isError ? Colors.red.shade100 : Colors.green.shade100,
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
            ),
          const SizedBox(height: 8),
          // Live list from Firestore
          Expanded(
            child: StreamBuilder(
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

                final candidates = snapshot.data!.docs
                    .map(Candidate.fromDoc)
                    .toList();

                if (candidates.isEmpty) {
                  return const Center(
                      child: Text('No candidates yet. Add one above.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: candidates.length,
                  itemBuilder: (context, i) {
                    final c = candidates[i];
                    final canRemove = c.votes == 0;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(c.name[0],
                              style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(c.name),
                        subtitle: Text(
                            c.votes == 1 ? '1 vote' : '${c.votes} votes'),
                        trailing: canRemove
                            ? IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                tooltip: 'Remove candidate',
                                onPressed: () => _delete(context, c),
                              )
                            : const Tooltip(
                                message: 'Cannot remove: has votes',
                                child:
                                    Icon(Icons.lock, color: Colors.grey),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
