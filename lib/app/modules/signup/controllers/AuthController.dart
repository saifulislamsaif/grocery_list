import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:grocerry_list/app/modules/signup/views/LoginPage.dart';

import '../../home/controllers/home_controller.dart';
import '../../home/views/home_page.dart';


class AuthController extends GetxController {
  AuthController({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  final Rxn<User> firebaseUser = Rxn<User>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  User? get user => firebaseUser.value;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
  }



  Future<void> signUp(String name, String email, String password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = cred.user;

      if (user != null) {
        await _db.collection("users").doc(user.uid).set({
          "name": name,
          "email": email,
          "created_at": FieldValue.serverTimestamp(),
        });
        Get.offAll(() => LoginPage());
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.snackbar(
        "Success",
        "Logged in successfully",
        snackPosition: SnackPosition.BOTTOM,
      );


      Get.offAll(() => HomePage());


      final homeController = Get.find<HomeController>();
      homeController
          .resetAndListen(); // <-- you can define this in HomeController
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Error",
        e.message ?? "Login failed",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
  // Login
  void onLogin(User user) {
    final homeController = Get.find<HomeController>();

    // Cancel any previous listeners
    homeController.cancelUserListener();


    homeController.userName.value = '';
    homeController.lists.clear();
    homeController.completedCount.value = 0;
    homeController.incompleteCount.value = 0;


    homeController.listenUserName();
    homeController.listenGroceryLists();
  }


}
