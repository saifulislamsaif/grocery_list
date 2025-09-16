import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../signup/controllers/AuthController.dart';

class InvitePage extends StatelessWidget {
  InvitePage({Key? key}) : super(key: key);

  final AuthController authController = Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final String currentUid = authController.user!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitations'),
        centerTitle: true,
        backgroundColor: Colors.green[50],
      ),
      backgroundColor: Colors.green[50],
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection('invitations')
            .where('toUid', isEqualTo: currentUid)
            .where('status', isEqualTo: 'pending')
            .orderBy('sentAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending invitations'));
          }

          final invites = snapshot.data!.docs;

          return ListView.builder(
            itemCount: invites.length,
            itemBuilder: (context, index) {
              final doc = invites[index];
              final data = doc.data() as Map<String, dynamic>;
              final listName = data['listName'] ?? 'Unnamed List';
              final fromUid = data['fromUid'] ?? '';
              final sentAt = (data['sentAt'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  title: Text(listName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(
                    'Invited by: $fromUid\n'
                        'Sent: ${sentAt != null ? sentAt.toLocal().toString() : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () =>
                            _acceptInvite(doc.id, data['listId']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _declineInvite(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _acceptInvite(String inviteId, String listId) async {
    final uid = authController.user!.uid;


    await _db.collection('grocery_lists').doc(listId).update({
      'members': FieldValue.arrayUnion([uid]),
    });


    await _db.collection('invitations').doc(inviteId).update({
      'status': 'accepted',
    });

    Get.snackbar('Accepted', 'You have joined the list',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _declineInvite(String inviteId) async {
    await _db.collection('invitations').doc(inviteId).update({
      'status': 'declined',
    });

    Get.snackbar('Declined', 'Invitation declined',
        snackPosition: SnackPosition.BOTTOM);
  }
}
