import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    final TextEditingController itemController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[50],
        title: Text(listName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: itemsRef.orderBy("createdAt", descending: false).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return const Center(child: Text("No items yet. Add some!"));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final doc = items[index];
              final data = doc.data() as Map<String, dynamic>;
              final itemName = data["name"] ?? "Unnamed";
              final purchased = data["purchased"] ?? false;

              return CheckboxListTile(
                title: Text(
                  itemName,
                  style: TextStyle(
                    decoration:
                    purchased ? TextDecoration.lineThrough : null,
                  ),
                ),
                value: purchased,
                onChanged: (val) async {
                  await doc.reference.update({"purchased": val});
                  await _updateCounters(listId);
                },
                secondary: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await doc.reference.delete();
                    await _updateCounters(listId);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateListBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  void _showCreateListBottomSheet(BuildContext context) {
    final TextEditingController controllerText = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Drag Handle
            Center(
              child: Container(
                height: 5,
                width: 40,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            /// Title
            const Center(
              child: Text(
                "Add Item",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 6),

            /// Subtitle
            Center(
              child: Text(
                "Add a new item to your list",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),

            const SizedBox(height: 20),

            /// TextField
            TextField(
              controller: controllerText,
              decoration: InputDecoration(
                hintText: "Item name",
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.green),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// TextField
            TextField(
              controller: controllerText,
              decoration: InputDecoration(
                hintText: "Quantity(e.g. 2L, 1 dozen",
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.green),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Add Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  final name = controllerText.text.trim();
                  // if (name.isNotEmpty) {
                  //   await controller.createList(name);
                  //   Get.back();
                  // }
                },
                child: const Text("Add Item", style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 2),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
  void _showAddItemDialog(BuildContext context,
      CollectionReference<Map<String, dynamic>> itemsRef,
      TextEditingController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Item"),
        backgroundColor: Colors.green[100],
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Item name"),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await itemsRef.add({
                  "name": controller.text,
                  "purchased": false,
                  "createdAt": FieldValue.serverTimestamp(),
                });
                controller.clear();
                await _updateCounters(listId);
                Get.back();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCounters(String listId) async {
    final itemsSnapshot = await FirebaseFirestore.instance
        .collection("grocery_lists")
        .doc(listId)
        .collection("items")
        .get();

    int total = itemsSnapshot.docs.length;
    int purchased =
        itemsSnapshot.docs.where((doc) => doc["purchased"] == true).length;

    await FirebaseFirestore.instance.collection("grocery_lists").doc(listId).update({
      "itemsCount": total,
      "purchasedCount": purchased,
    });
  }
}
