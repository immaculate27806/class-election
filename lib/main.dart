import 'package:flutter/material.dart';

void main() {
  runApp(const ClassElectionApp());
}

// ── Name cleaning helper ──────────────────────────────────────────────────────
String cleanName(String raw) {
  final words = raw.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

String votesText(int n) => n == 1 ? '1 vote' : '$n votes';

// ── Data model ────────────────────────────────────────────────────────────────
class Candidate {
  final String name;
  int votes;
  Candidate(this.name, {this.votes = 0});
}

// ── App state ─────────────────────────────────────────────────────────────────
class ElectionState extends ChangeNotifier {
  final List<Candidate> _candidates = [
    Candidate('Keza'),
    Candidate('Mutoni'),
    Candidate('Ishimwe'),
  ];
  final Set<String> _voters = {};

  List<Candidate> get candidates => List.unmodifiable(_candidates);
  int get totalVotes => _candidates.fold(0, (s, c) => s + c.votes);

  String? vote(String rawVoter, Candidate candidate) {
    final voter = cleanName(rawVoter);
    if (voter.isEmpty) return 'Please enter your name.';
    if (_voters.contains(voter)) return '$voter has already voted.';
    _voters.add(voter);
    candidate.votes++;
    notifyListeners();
    return null;
  }

  String? addCandidate(String rawName) {
    final name = cleanName(rawName);
    if (name.isEmpty) return 'Candidate name cannot be empty.';
    if (_candidates.any((c) => c.name == name)) return '$name is already a candidate.';
    _candidates.add(Candidate(name));
    notifyListeners();
    return null;
  }

  bool canRemove(Candidate c) => c.votes == 0;

  void removeCandidate(Candidate c) {
    _candidates.remove(c);
    notifyListeners();
  }

  void reset() {
    for (final c in _candidates) c.votes = 0;
    _voters.clear();
    notifyListeners();
  }

  List<Candidate> get ranked {
    final list = List<Candidate>.from(_candidates);
    list.sort((a, b) {
      final byVotes = b.votes.compareTo(a.votes);
      return byVotes != 0 ? byVotes : a.name.compareTo(b.name);
    });
    return list;
  }

  String get bannerText {
    final total = totalVotes;
    if (total == 0) return 'No votes yet';
    final sorted = ranked;
    final top = sorted.first.votes;
    final tied = sorted.where((c) => c.votes == top).toList();
    if (tied.length == 1) return 'Winner: ${tied.first.name}';
    final names = tied.map((c) => c.name).join(' and ');
    return 'Tie between $names ($top votes each)';
  }
}

// ── Main app ──────────────────────────────────────────────────────────────────
class ClassElectionApp extends StatelessWidget {
  const ClassElectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ijwi Class Vote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ElectionHome(),
    );
  }
}

// ── Bottom nav home ───────────────────────────────────────────────────────────
class ElectionHome extends StatefulWidget {
  const ElectionHome({super.key});

  @override
  State<ElectionHome> createState() => _ElectionHomeState();
}

class _ElectionHomeState extends State<ElectionHome> {
  final ElectionState _state = ElectionState();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      VoteScreen(state: _state),
      ResultsScreen(state: _state),
      CandidatesScreen(state: _state),
    ];
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) => Scaffold(
        body: screens[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.how_to_vote), label: 'Vote'),
            NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Results'),
            NavigationDestination(icon: Icon(Icons.people), label: 'Candidates'),
          ],
        ),
      ),
    );
  }
}

// ── Vote Screen ───────────────────────────────────────────────────────────────
class VoteScreen extends StatefulWidget {
  final ElectionState state;
  const VoteScreen({super.key, required this.state});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final _nameController = TextEditingController();
  String? _message;
  bool _isError = false;

  void _vote(Candidate candidate) {
    final error = widget.state.vote(_nameController.text, candidate);
    setState(() {
      if (error != null) {
        _message = error;
        _isError = true;
      } else {
        _message = '${cleanName(_nameController.text)} voted for ${candidate.name}!';
        _isError = false;
        _nameController.clear();
      }
    });
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
      ),
      body: Padding(
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
            Text('Total votes so far: ${widget.state.totalVotes}'),
            const SizedBox(height: 8),
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isError ? Colors.red.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _isError ? Colors.red.shade800 : Colors.green.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text('Tap a candidate to vote:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: widget.state.candidates.isEmpty
                  ? const Center(
                      child: Text('No candidates yet. Add one in the Candidates tab.'))
                  : ListView.builder(
                itemCount: widget.state.candidates.length,
                itemBuilder: (context, i) {
                  final c = widget.state.candidates[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(c.name[0],
                            style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(c.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.how_to_vote),
                      onTap: () => _vote(c),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Results Screen ────────────────────────────────────────────────────────────
class ResultsScreen extends StatelessWidget {
  final ElectionState state;
  const ResultsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final ranked = state.ranked;
    final total = state.totalVotes;
    final banner = state.bannerText;
    final isWinner = banner.startsWith('Winner');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset votes'),
                  content: const Text('Are you sure? All votes will be cleared.'),
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
              if (confirm == true) state.reset();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isWinner ? Colors.amber.shade100 : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isWinner ? Colors.amber : Colors.blue, width: 2),
              ),
              child: Row(
                children: [
                  Icon(
                    isWinner ? Icons.emoji_events : Icons.handshake,
                    color: isWinner ? Colors.amber.shade800 : Colors.blue.shade800,
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
            Expanded(
              child: ranked.isEmpty
                  ? const Center(child: Text('No candidates yet.'))
                  : ListView.builder(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${i + 1}. ${c.name}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text('${votesText(c.votes)} · $pctText',
                                  style:
                                      TextStyle(color: Colors.grey.shade700)),
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
      ),
    );
  }
}

// ── Candidates Screen ─────────────────────────────────────────────────────────
class CandidatesScreen extends StatefulWidget {
  final ElectionState state;
  const CandidatesScreen({super.key, required this.state});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  final _controller = TextEditingController();
  String? _message;
  bool _isError = false;

  void _add() {
    final error = widget.state.addCandidate(_controller.text);
    setState(() {
      if (error != null) {
        _message = error;
        _isError = true;
      } else {
        _message = '${cleanName(_controller.text)} added!';
        _isError = false;
        _controller.clear();
      }
    });
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
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
            const SizedBox(height: 8),
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isError ? Colors.red.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _isError ? Colors.red.shade800 : Colors.green.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: widget.state.candidates.isEmpty
                  ? const Center(child: Text('No candidates yet. Add one above.'))
                  : ListView.builder(
                itemCount: widget.state.candidates.length,
                itemBuilder: (context, i) {
                  final c = widget.state.candidates[i];
                  final canRemove = widget.state.canRemove(c);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(c.name[0],
                            style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(c.name),
                      subtitle: Text(votesText(c.votes)),
                      trailing: canRemove
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Remove candidate',
                              onPressed: () {
                                widget.state.removeCandidate(c);
                                setState(() => _message = null);
                              },
                            )
                          : const Tooltip(
                              message: 'Cannot remove: has votes',
                              child: Icon(Icons.lock, color: Colors.grey),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}