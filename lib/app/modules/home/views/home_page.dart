import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../controller/AuthController.dart';
import 'list_details_page.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final uid = authController.user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Grocery Lists"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("grocery_lists")
            .where("members", arrayContains: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lists = snapshot.data!.docs;

          if (lists.isEmpty) {
            return const Center(child: Text("No grocery lists yet"));
          }

          // ✅ Count completed & incomplete lists
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
          final total = completed + incomplete;
          final progress = total == 0 ? 0.0 : completed / total;

          return Column(
            children: [
              // 🔹 Summary Card at the top
              Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Overview", style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text("Completed: $completed   |   Incomplete: $incomplete"),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔹 Expanded ListView of grocery lists
              Expanded(
                child: ListView.builder(
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    final doc = lists[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final name = data["name"] ?? "Unnamed List";
                    final itemsCount = data["itemsCount"] ?? 0;
                    final purchasedCount = data["purchasedCount"] ?? 0;

                    final percent = itemsCount == 0
                        ? 0.0
                        : purchasedCount / itemsCount;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(name, style: const TextStyle(fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("$purchasedCount of $itemsCount items purchased"),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(value: percent),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: () {
                            Get.to(() => ListDetailsPage(
                              listId: doc.id,
                              listName: name,
                            ));
                          },
                        ),
                        onLongPress: () {
                          if (data["ownerId"] == uid) {
                            _showOwnerActions(context, doc.id, name);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListDialog(context, uid),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateListDialog(BuildContext context, String? uid) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create New List"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "List name"),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty && uid != null) {
                await FirebaseFirestore.instance.collection("grocery_lists").add({
                  "name": controller.text,
                  "ownerId": uid,
                  "members": [uid],
                  "itemsCount": 0,
                  "purchasedCount": 0,
                  "createdAt": FieldValue.serverTimestamp(),
                  "completed": false,
                });
                Get.back();
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
  void _showOwnerActions(BuildContext context, String listId, String name) {
    final TextEditingController controller = TextEditingController(text: name);

    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Rename List"),
            onTap: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection("grocery_lists")
                  .doc(listId)
                  .update({"name": controller.text});
              Get.snackbar("Updated", "List renamed successfully",
                  snackPosition: SnackPosition.BOTTOM);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("Delete List"),
            onTap: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection("grocery_lists")
                  .doc(listId)
                  .delete();
              Get.snackbar("Deleted", "$name deleted successfully",
                  snackPosition: SnackPosition.BOTTOM);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text("Mark as Completed"),
            onTap: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection("grocery_lists")
                  .doc(listId)
                  .update({"completed": true});
              Get.snackbar("Completed", "$name marked as completed",
                  snackPosition: SnackPosition.BOTTOM);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text("Invite Member"),
            onTap: () {
              Navigator.of(context).pop(); // close bottom sheet first
              _showInviteDialog(context, listId);
            },
          ),

        ],
      ),
    );

  }
  void _showInviteDialog(BuildContext context, String listId) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Invite Member"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: "Enter member's email"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;

              try {
                // Find user by email
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

                // Add uid to members array
                await FirebaseFirestore.instance
                    .collection("grocery_lists")
                    .doc(listId)
                    .update({
                  "members": FieldValue.arrayUnion([uidToAdd])
                });

                Navigator.of(dialogContext).pop();
                Get.snackbar("Success", "$email added to the list",
                    snackPosition: SnackPosition.BOTTOM);
              } catch (e) {
                Get.snackbar("Error", e.toString(),
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: const Text("Invite"),
          ),
        ],
      ),
    );
  }


}

