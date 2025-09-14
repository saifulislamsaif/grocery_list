import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../controller/AuthController.dart';

class HomeController extends GetxController {
  final AuthController authController = Get.find();

  // Reactive variables
  var userName = ''.obs;
  var lists = <DocumentSnapshot>[].obs;
  var completedCount = 0.obs;
  var incompleteCount = 0.obs;

  String? get uid => authController.user?.uid;

  @override
  void onInit() {
    super.onInit();
    if (uid != null) {
      _listenUserName();
      _listenGroceryLists();
    }
  }

  void _listenUserName() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      userName.value = data?['name'] ?? '';
    });
  }

  void _listenGroceryLists() {
    FirebaseFirestore.instance
        .collection('grocery_lists')
        .where('members', arrayContains: uid)
        .snapshots()
        .listen((snapshot) {
      lists.value = snapshot.docs;
      _updateProgress();
    });
  }

  void _updateProgress() {
    int completed = 0;
    int incomplete = 0;
    for (var doc in lists) {
      final data = doc.data() as Map<String, dynamic>;
      if (data["completed"] == true) {
        completed++;
      } else {
        incomplete++;
      }
    }
    completedCount.value = completed;
    incompleteCount.value = incomplete;
  }

  double get progress {
    final total = completedCount.value + incompleteCount.value;
    return total == 0 ? 0.0 : completedCount.value / total;
  }

  Future<void> updateUserName(String newName) async {
    if (uid == null || newName.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'name': newName});
  }

  Future<void> createList(String name) async {
    if (uid == null || name.isEmpty) return;
    await FirebaseFirestore.instance.collection("grocery_lists").add({
      "name": name,
      "ownerId": uid,
      "members": [uid],
      "itemsCount": 0,
      "purchasedCount": 0,
      "createdAt": FieldValue.serverTimestamp(),
      "completed": false,
    });
  }

  Future<void> renameList(String listId, String newName) async {
    if (newName.isEmpty) return;
    await FirebaseFirestore.instance
        .collection("grocery_lists")
        .doc(listId)
        .update({"name": newName});
    Get.snackbar("Updated", "List renamed successfully",
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> deleteList(String listId, String name) async {
    await FirebaseFirestore.instance
        .collection("grocery_lists")
        .doc(listId)
        .delete();
    Get.snackbar("Deleted", "$name deleted successfully",
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> markCompleted(String listId, String name) async {
    await FirebaseFirestore.instance
        .collection("grocery_lists")
        .doc(listId)
        .update({"completed": true});
    Get.snackbar("Completed", "$name marked as completed",
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> inviteMember(String listId, String email) async {
    if (email.isEmpty) return;

    final userQuery = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .get();

    if (userQuery.docs.isEmpty) {
      Get.snackbar("Error", "User not found",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final uidToAdd = userQuery.docs.first.id;

    await FirebaseFirestore.instance
        .collection("grocery_lists")
        .doc(listId)
        .update({
      "members": FieldValue.arrayUnion([uidToAdd]),
    });

    Get.snackbar("Success", "$email added to the list",
        snackPosition: SnackPosition.BOTTOM);
  }
}
