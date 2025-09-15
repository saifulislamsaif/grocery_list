import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../modules/home/controllers/home_controller.dart';
import '../modules/home/views/LoginPage.dart';
import '../modules/home/views/home_page.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Rx<User?> firebaseUser = Rx<User?>(null);

  User? get user => firebaseUser.value;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  // Sign Up
  Future<void> signUp(String name, String email, String password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = cred.user;

      if (user != null) {
        await _db.collection("users").doc(user.uid).set({
          "name": name,
          "email": email,
          "created_at": FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.snackbar("Success", "Logged in successfully", snackPosition: SnackPosition.BOTTOM);

      // Optional: after login, navigate to HomePage
      Get.offAll(() => HomePage());

      // Optional: initialize HomeController data for new user
      final homeController = Get.find<HomeController>();
      homeController.resetAndListen(); // <-- you can define this in HomeController

    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Login failed", snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Login
  void onLogin(User user) {
    final homeController = Get.find<HomeController>();

    // Cancel any previous listeners
    homeController.cancelUserListener();

    // Reset variables
    homeController.userName.value = '';
    homeController.lists.clear();
    homeController.completedCount.value = 0;
    homeController.incompleteCount.value = 0;

    // Re-listen for new user
    homeController.listenUserName();
    homeController.listenGroceryLists();
  }


  // Logout
  void logout() async {
    await FirebaseAuth.instance.signOut();

    // Reset HomeController data
    final homeController = Get.find<HomeController>();
    homeController.userName.value = '';
    homeController.lists.clear();
    homeController.completedCount.value = 0;
    homeController.incompleteCount.value = 0;

    // Cancel old user subscription
    homeController.cancelUserListener();

    // Navigate to login page
    Get.offAll(() => LoginPage());
  }

}
