class UserModel {
  final String uid;
  final String name;
  final int age;
  final String gender;
  final String phoneNumber;
  final String photoUrl;
  final List<String> interests;
  final int coinsBalance;
  final String bio;

  UserModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.photoUrl,
    required this.interests,
    this.coinsBalance = 20,
    this.bio = '',
  });

  // Convert UserModel to Map (to save in Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'interests': interests,
      'coinsBalance': coinsBalance,
      'bio': bio,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Convert Map from Firestore to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      coinsBalance: map['coinsBalance'] ?? 20,
      bio: map['bio'] ?? '',
    );
  }
}
