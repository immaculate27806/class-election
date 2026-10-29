import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Model ─────────────────────────────────────────────────────────────────────
class Candidate {
  final String id;
  final String name;
  final int votes;

  const Candidate({this.id = '', required this.name, this.votes = 0});

  Map<String, dynamic> toMap() => {'name': name, 'votes': votes};

  factory Candidate.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Candidate(
      id: doc.id,
      name: data['name'] as String,
      votes: (data['votes'] as num).toInt(),
    );
  }
}

// ── Firestore collection helpers ──────────────────────────────────────────────

/// users/{uid}/candidates
CollectionReference<Map<String, dynamic>> myCandidates() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('candidates');
}

/// users/{uid}/voters
CollectionReference<Map<String, dynamic>> myVoters() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('voters');
}

// ── Sample data written once when a new account is created ───────────────────
Future<void> addSampleCandidates() async {
  final samples = ['Keza', 'Mutoni', 'Ishimwe'];
  final batch = FirebaseFirestore.instance.batch();
  for (final name in samples) {
    batch.set(myCandidates().doc(), {'name': name, 'votes': 0});
  }
  await batch.commit();
}
