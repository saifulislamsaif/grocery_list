import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class ListDetailsPage extends StatelessWidget {
  final String listId;
  final String listName;

  const ListDetailsPage({super.key, required this.listId, required this.listName});

  @override
  Widget build(BuildContext context) {
    final itemsRef = FirebaseFirestore.instance
        .collection("grocery_lists")
        .doc(listId)
        .collection("items");

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7), // Light off-white background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(listName, style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection("grocery_lists").doc(listId).snapshots(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data() as Map<String, dynamic>?;
                int total = data?['itemsCount'] ?? 0;
                int done = data?['purchasedCount'] ?? 0;
                return Text(
                  "${total - done} remaining · $done done",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                );
              },
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _showSharedMembersSheet(context, listId);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.group_outlined, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.green[100],
                    child: const Text("S", style: TextStyle(fontSize: 10)),
                  ),
                  const SizedBox(width: 4),
                  const Text("2", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: itemsRef.orderBy("createdAt", descending: false).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final allDocs = snapshot.data!.docs;
          final toBuy = allDocs.where((d) => !(d['purchased'] ?? false)).toList();
          final completed = allDocs.where((d) => (d['purchased'] ?? false)).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (toBuy.isNotEmpty) ...[
                _buildSectionHeader("TO BUY (${toBuy.length})"),
                ...toBuy.map((doc) => _buildListItem(doc, false)),
              ],
              const SizedBox(height: 24),
              if (completed.isNotEmpty) ...[
                _buildSectionHeader("COMPLETED (${completed.length})"),
                ...completed.map((doc) => _buildListItem(doc, true)),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF006D4E), // Dark Teal from image
        onPressed: () => _showCreateItemBottomSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  void _showSharedMembersSheet(BuildContext context, String listId) {

    final controller = Get.find<HomeController>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// drag indicator
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                /// Title
                const Center(
                  child: Text(
                    "Shared Members",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                const Center(
                  child: Text(
                    "People who have access to this list",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Label
                const Text(
                  "SHARED WITH",
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 12),

                /// Members list
                Obx(() {
                  final list = controller.lists.firstWhere((e) => e.id == listId);

                  final data = list.data() as Map<String, dynamic>;
                  final members = List<String>.from(data["members"] ?? []);

                  return Wrap(
                    spacing: 10,
                    children: members.map((uid) {

                      final letter = uid.substring(0, 1).toUpperCase();

                      return _memberChip(
                        letter,
                        uid == controller.uid ? "You" : "Member",
                        isOwner: uid == data["ownerId"],
                      );

                    }).toList(),
                  );
                }),

                const SizedBox(height: 20),

                /// Invite button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text("Invite"),
                    onPressed: () {
                      Get.back();
                      _showInviteDialog(listId);
                    },
                  ),
                ),

                const SizedBox(height: 10),

                /// Close button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
  void _showInviteDialog(String listId) {

    final TextEditingController emailController = TextEditingController();
    final controller = Get.find<HomeController>();

    Get.dialog(
      AlertDialog(
        title: const Text("Invite Member"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            hintText: "Enter user email",
          ),
        ),
        actions: [

          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();

              await controller.inviteMember(listId, email);
            },
            child: const Text("Invite"),
          ),
        ],
      ),
    );
  }
  Widget _memberChip(String letter, String name, {bool isOwner = false}) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.green[100],
            child: Text(
              letter,
              style: const TextStyle(fontSize: 11),
            ),
          ),

          const SizedBox(width: 6),

          Text(
            name,
            style: const TextStyle(fontSize: 13),
          ),

          if (isOwner)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                "(owner)",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildListItem(DocumentSnapshot doc, bool isCompleted) {
    final data = doc.data() as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFF2F2EB) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: GestureDetector(
          onTap: () => _toggleStatus(doc),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? const Color(0xFF006D4E) : Colors.transparent,
              border: Border.all(color: isCompleted ? const Color(0xFF006D4E) : Colors.grey.shade400, width: 2),
            ),
            child: isCompleted ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
          ),
        ),
        title: Text(
          data['name'] ?? "",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isCompleted ? Colors.grey[600] : Colors.black87,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          "${data['quantity'] ?? '1'}  ·  by ${data['addedBy'] ?? 'You'}",
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
        trailing: isCompleted
            ? const Text("✓ Sarah", style: TextStyle(color: Color(0xFF006D4E), fontSize: 12))
            : IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => doc.reference.delete()),
      ),
    );
  }

  void _toggleStatus(DocumentSnapshot doc) async {
    final bool current = doc['purchased'] ?? false;
    await doc.reference.update({"purchased": !current});
    await _updateCounters(listId);
  }

  void _showCreateItemBottomSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Add Item", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            TextField(
                controller: nameCtrl,
                decoration: InputDecoration(hintText: "Item name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))
            ),
            const SizedBox(height: 12),

            TextField(
                controller: qtyCtrl,
                decoration: InputDecoration(hintText: "Quantity (e.g. 10kg, 2 boxes)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006D4E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final itemName = nameCtrl.text.trim();
                  final itemQty = qtyCtrl.text.trim();

                  if (itemName.isNotEmpty) {
                    try {
                      await _addItemToFirestore(
                        name: itemName,
                        quantity: itemQty,
                      );

                      Navigator.of(Get.context!).pop(); // Always works

                    } catch (e) {
                      debugPrint("Add failed: $e");
                    }
                  }
                },
                child: const Text("Add to List", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
  Future<void> _addItemToFirestore({
    required String name,
    required String quantity,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("grocery_lists")
          .doc(listId)
          .collection("items")
          .add({
        "name": name,
        "quantity": quantity.isEmpty ? "1" : quantity,
        "purchased": false,
        "addedBy": "You",
        "createdAt": FieldValue.serverTimestamp(),
      });

      await _updateCounters(listId);
    } catch (e) {
      debugPrint("Error adding item: $e");
      Get.snackbar("Error", "Failed to add item");
    }
  }
  Future<void> _updateCounters(String listId) async {
    final items = await FirebaseFirestore.instance.collection("grocery_lists").doc(listId).collection("items").get();
    int total = items.docs.length;
    int purchased = items.docs.where((doc) => doc["purchased"] == true).length;
    await FirebaseFirestore.instance.collection("grocery_lists").doc(listId).update({
      "itemsCount": total,
      "purchasedCount": purchased,
    });
  }
}
