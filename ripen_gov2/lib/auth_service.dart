import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register User and Auto-Assign Admin Role for First User
  Future<String?> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String birthday,
    required String mobileNumber,
  }) async {
    try {
      // Create user with Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        // Check if there is already an admin in Firestore
        QuerySnapshot adminQuery =
            await _firestore
                .collection('users')
                .where('role', isEqualTo: 1)
                .get();

        // If no admin exists, make this user an admin
        int role = adminQuery.docs.isEmpty ? 1 : 0; // 1 for admin, 0 for user
        String status = 'active'; // Default status is active

        // Store user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'role': role,
          'status': status,
          'createdAt': FieldValue.serverTimestamp(),
          'firstName': firstName,
          'lastName': lastName,
          'birthday': birthday,
          'mobileNumber': mobileNumber,
          'lastLogin': FieldValue.serverTimestamp(), // Track last login time
        });

        return "User registered as ${role == 1 ? 'admin' : 'user'}";
      }
    } catch (e) {
      return "Error: $e";
    }
    return null;
  }

  // Login User
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        if (userData != null) {
          // Update last login time
          await _firestore.collection('users').doc(user.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });

          // Check if the user is inactive
          Timestamp lastLogin = userData['lastLogin'];
          DateTime lastLoginDate = lastLogin.toDate();
          DateTime threeMonthsAgo = DateTime.now().subtract(Duration(days: 90));

          if (lastLoginDate.isBefore(threeMonthsAgo)) {
            // Update status to inactive
            await _firestore.collection('users').doc(user.uid).update({
              'status': 'inactive',
            });
            userData['status'] = 'inactive';
          } else {
            // Update status to active
            await _firestore.collection('users').doc(user.uid).update({
              'status': 'active',
            });
            userData['status'] = 'active';
          }
        }

        return userData;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // Logout User
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
