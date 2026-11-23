import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  const AppUser({required this.uid, this.email, this.displayName, this.photoUrl});

  factory AppUser.fromFirebase(User user) => AppUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  Map<String, dynamic> toJson() => {
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
      };
}
