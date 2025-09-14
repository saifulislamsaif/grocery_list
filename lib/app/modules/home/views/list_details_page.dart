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
      appBar: AppBar(
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
                  // 🔄 Update counters in parent list
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
          _showAddItemDialog(context, itemsRef, itemController);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context,
      CollectionReference<Map<String, dynamic>> itemsRef,
      TextEditingController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Item"),
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
