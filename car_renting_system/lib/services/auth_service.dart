import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Firebase Auth service.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUid => _auth.currentUser?.uid;
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isGuest => _auth.currentUser?.isAnonymous ?? false;

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      createdAt: DateTime.now(),
    );

    // Store user profile in Firestore (don't block signup if this fails)
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap())
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Warning: Failed to save user profile to Firestore: $e');
    }

    return user;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Try to get user profile from Firestore
    try {
      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Warning: Failed to fetch user profile from Firestore: $e');
    }

    // Fallback: build user from Firebase Auth data
    return UserModel(
      uid: credential.user!.uid,
      name: credential.user!.displayName ?? email.split('@').first,
      email: email,
      phone: '',
      role: 'buyer',
      createdAt: DateTime.now(),
    );
  }

  Future<UserModel?> getCurrentUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      debugPrint('Warning: Failed to get current user data: $e');
      final fbUser = _auth.currentUser;
      if (fbUser == null) return null;
      return UserModel(
        uid: fbUser.uid,
        name: fbUser.displayName ?? fbUser.email?.split('@').first ?? 'User',
        email: fbUser.email ?? '',
        phone: '',
        role: fbUser.isAnonymous ? 'buyer' : 'buyer',
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel> signInAsGuest() async {
    final credential = await _auth.signInAnonymously();
    final uid = credential.user!.uid;

    final guest = UserModel(
      uid: uid,
      name: 'Guest',
      email: 'guest@carrent.app',
      phone: '',
      role: 'buyer',
      createdAt: DateTime.now(),
    );

    // Store guest profile in Firestore (don't block if fails)
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(guest.toMap())
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Warning: Failed to save guest profile: $e');
    }

    return guest;
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap())
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Warning: Failed to update user profile: $e');
    }
  }
}
