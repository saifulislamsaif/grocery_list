import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../signup/controllers/AuthController.dart';

class HomeController extends GetxController {
  final AuthController authController = Get.find();
  var userName = ''.obs;
  var lists = <DocumentSnapshot>[].obs;
  var completedCount = 0.obs;
  var incompleteCount = 0.obs;
  late StreamSubscription<DocumentSnapshot> _userSub;
  late StreamSubscription<QuerySnapshot> _listsSub;
  var showActive = true.obs;
  final RxInt selectedIndex = 0.obs;
  String? get uid => authController.user?.uid;
  var invites = <DocumentSnapshot>[].obs;
  late StreamSubscription<QuerySnapshot> _inviteSub;

  @override
  void onInit() {
    super.onInit();
    if (uid != null) {
      _listenUserName();
      _listenGroceryLists();
      _listenInvites(); // ADD THIS
    }
  }
  void _listenInvites() {
    if (uid == null) return;

    _inviteSub = FirebaseFirestore.instance
        .collection("list_invites")
        .where("inviteeUid", isEqualTo: uid)
        .where("status", isEqualTo: "pending")
        .snapshots()
        .listen((snapshot) {
      invites.value = snapshot.docs;
    });
  }

  Future<void> acceptInvite(String inviteId, String listId) async {

    await FirebaseFirestore.instance
        .collection("grocery_lists")
        .doc(listId)
        .update({
      "members": FieldValue.arrayUnion([uid])
    });

    await FirebaseFirestore.instance
        .collection("list_invites")
        .doc(inviteId)
        .update({
      "status": "accepted"
    });

    Get.snackbar(
      "Success",
      "List added to your account",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  void listenUserName() {
    _userSub.cancel();
    _listenUserName();
  }

  void listenGroceryLists() {
    _listsSub.cancel();
    _listenGroceryLists();
  }

  void resetData() {
    userName.value = '';
    lists.clear();
    completedCount.value = 0;
    incompleteCount.value = 0;
  }

  void resetAndListen() {
    resetData();
    listenUserName();
    listenGroceryLists();
  }

  void clearState() {
    userName.value = '';
    lists.clear();
    completedCount.value = 0;
    incompleteCount.value = 0;
  }

  void _listenUserName() {
    _userSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
          final data = snapshot.data();
          userName.value = data?['name'] ?? '';
        });
  }

  void changeTab(int index) {
    if (index == 1) {
      return;
    }
    selectedIndex.value = index;
  }

  void _listenGroceryLists() {
    _listsSub = FirebaseFirestore.instance
        .collection('grocery_lists')
        .where('members', arrayContains: uid)
        .snapshots()
        .listen((snapshot) {
          lists.value = snapshot.docs;
          _updateProgress();
        });
  }

  void cancelUserListener() {
    _userSub.cancel();
    _listsSub.cancel();
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
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': newName,
    });
    userName.value = newName;
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
    Get.snackbar(
      "Updated",
      "List renamed successfully",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> deleteList(String listId, String name) async {
    await FirebaseFirestore.instance
        .collection("grocery_lists")
        .doc(listId)
        .delete();
    Get.snackbar(
      "Deleted",
      "$name deleted successfully",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> markCompleted(String listId, String name) async {
    await FirebaseFirestore.instance
        .collection("grocery_lists")
        .doc(listId)
        .update({"completed": true});
    Get.snackbar(
      "Completed",
      "$name marked as completed",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> inviteMember(String listId, String email) async {

    final userQuery = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .get();

    if (userQuery.docs.isEmpty) {
      Get.snackbar("Error","User not found");
      return;
    }

    final userDoc = userQuery.docs.first;
    final uidToAdd = userDoc.id;

    final listDoc = await FirebaseFirestore.instance
        .collection("grocery_lists")
        .doc(listId)
        .get();

    final listName = listDoc.data()?["name"] ?? "List";

    await FirebaseFirestore.instance.collection("list_invites").add({
      "listId": listId,
      "listName": listName,
      "ownerId": uid,
      "inviteeUid": uidToAdd,
      "inviteeEmail": email,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp()
    });

    Get.back();

    Get.snackbar(
      "Invite Sent",
      "$email invited successfully",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
