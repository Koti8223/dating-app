import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save user profile
  Future<void> saveUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Check if profile exists
  Future<bool> userProfileExists(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists;
  }

  // Get all users except current user for home feed
  Future<List<UserModel>> getUsersForFeed() async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await _db
        .collection('users')
        .where('uid', isNotEqualTo: currentUid)
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();
  }

  // Like a user
  Future<void> likeUser({
    required String currentUid,
    required String likedUid,
  }) async {
    await _db
        .collection('users')
        .doc(currentUid)
        .collection('likes')
        .doc(likedUid)
        .set({'likedAt': DateTime.now().toIso8601String()});
  }

  // Skip a user
  Future<void> skipUser({
    required String currentUid,
    required String skippedUid,
  }) async {
    await _db
        .collection('users')
        .doc(currentUid)
        .collection('skips')
        .doc(skippedUid)
        .set({'skippedAt': DateTime.now().toIso8601String()});
  }

  // Seed dummy users for testing
  Future<void> seedTestUsers() async {
    final dummyUsers = [
      UserModel(
        uid: 'dummy_1',
        name: 'Aanya Sharma',
        age: 22,
        gender: 'Female',
        phoneNumber: '+919999999991',
        photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=60',
        interests: ['Music', 'Fitness', 'Reading'],
        coinsBalance: 50,
        bio: 'Love dancing, working out, and reading thriller books. Let\'s connect!',
      ),
      UserModel(
        uid: 'dummy_2',
        name: 'Rohan Verma',
        age: 24,
        gender: 'Male',
        phoneNumber: '+919999999992',
        photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop&q=60',
        interests: ['Gaming', 'Cricket', 'Music'],
        coinsBalance: 30,
        bio: 'Hardcore gamer and cricket enthusiast. Down for a chat anytime!',
      ),
      UserModel(
        uid: 'dummy_3',
        name: 'Ishita Patel',
        age: 21,
        gender: 'Female',
        phoneNumber: '+919999999993',
        photoUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=500&auto=format&fit=crop&q=60',
        interests: ['Gaming', 'Reading', 'Fitness'],
        coinsBalance: 40,
        bio: 'Avid reader and casual gamer. Looking for like-minded people.',
      ),
      UserModel(
        uid: 'dummy_4',
        name: 'Kabir Malhotra',
        age: 25,
        gender: 'Male',
        phoneNumber: '+919999999994',
        photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop&q=60',
        interests: ['Fitness', 'Music', 'Cricket'],
        coinsBalance: 25,
        bio: 'Gym addict and music lover. Let\'s grab coffee or go to a concert.',
      ),
    ];

    for (final user in dummyUsers) {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    }
  }
}

