import 'package:get/get.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import '../../signup/controllers/AuthController.dart';

class InvitationController extends GetxController {
  final AuthController auth = Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  RxList<QueryDocumentSnapshot> invites = <QueryDocumentSnapshot>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenInvitations();
  }

  void _listenInvitations() {
    final uid = auth.user?.uid;
    if (uid == null) return;

    _db
        .collection('invitations')
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .listen((snap) {
      invites.value = snap.docs;
    });
  }

  Future<void> acceptInvite(String inviteId, String listId) async {
    final uid = auth.user?.uid;
    if (uid == null) return;


    await _db.collection('grocery_lists').doc(listId).update({
      'members': FieldValue.arrayUnion([uid]),
    });


    await _db.collection('invitations').doc(inviteId).update({
      'status': 'accepted',
    });

    Get.snackbar('Accepted', 'You have joined the list',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> declineInvite(String inviteId) async {
    await _db.collection('invitations').doc(inviteId).update({
      'status': 'declined',
    });
    Get.snackbar('Declined', 'Invitation declined',
        snackPosition: SnackPosition.BOTTOM);
  }
}

