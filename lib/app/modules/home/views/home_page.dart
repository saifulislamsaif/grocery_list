import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/AuthController.dart';
import '../controllers/home_controller.dart';
import 'list_details_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController controller = Get.put(HomeController());
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.green[50],
        leadingWidth: 60,
        leading: Obx(() {
          final firstLetter = controller.userName.value.isNotEmpty
              ? controller.userName.toUpperCase()
              : '?';
          return Padding(
            padding: const EdgeInsets.all(0.0),
            child: GestureDetector(
              onTap: () {
                _showEditNameDialog(context);
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
          );
        }),
        title: const Text("Grocery Lists"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.lists.isEmpty) {
          return const Center(child: Text("No grocery lists yet"));
        }

        return Column(
          children: [
            Card(
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey, Colors.grey],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Overview",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white)),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                          "Completed: ${controller.completedCount.value}   |   Incomplete: ${controller.incompleteCount.value}",
                          style: const TextStyle(color: Colors.white))),
                      const SizedBox(height: 8),
                      Obx(() => LinearProgressIndicator(
                        value: controller.progress,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white),
                      )),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.lists.length,
                itemBuilder: (context, index) {
                  final doc = controller.lists[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data["name"] ?? "Unnamed List";
                  final itemsCount = data["itemsCount"] ?? 0;
                  final purchasedCount = data["purchasedCount"] ?? 0;
                  final percent = itemsCount == 0 ? 0.0 : purchasedCount / itemsCount;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.grey, Colors.grey],
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Get.to(() => ListDetailsPage(
                            listId: doc.id,
                            listName: name,
                          ));
                        },
                        onLongPress: () {
                          if (data["ownerId"] == controller.uid) {
                            _showOwnerActions(context, doc.id, name);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    const SizedBox(height: 6),
                                    Text("$purchasedCount of $itemsCount items purchased",
                                        style: const TextStyle(color: Colors.white70)),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percent,
                                        minHeight: 6,
                                        backgroundColor: Colors.white24,
                                        valueColor:
                                        const AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                                onPressed: () {
                                  Get.to(() => ListDetailsPage(
                                    listId: doc.id,
                                    listName: name,
                                  ));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }


  void _showCreateListDialog(BuildContext context) {
    final TextEditingController controllerText = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text("Create New List"),
        content: TextField(
          controller: controllerText,
          decoration: const InputDecoration(hintText: "List name"),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final name = controllerText.text.trim();
              if (name.isNotEmpty) {
                await controller.createList(name);
                Get.back();
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final TextEditingController controllerText =
    TextEditingController(text: controller.userName.value);
    Get.dialog(
      AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(
          controller: controllerText,
          decoration: const InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final newName = controllerText.text.trim();
              if (newName.isNotEmpty) {
                await controller.updateUserName(newName);
              }
              Get.back();
              Get.snackbar("Updated", "Name updated successfully",
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showOwnerActions(BuildContext context, String listId, String name) {
    Get.bottomSheet(
      Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Rename List"),
            onTap: () {
              Get.back();
              final TextEditingController renameController =
              TextEditingController(text: name);
              Get.dialog(
                AlertDialog(
                  title: const Text("Rename List"),
                  content: TextField(
                    controller: renameController,
                    decoration: const InputDecoration(hintText: "Enter new list name"),
                  ),
                  actions: [
                    TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
                    TextButton(
                      onPressed: () async {
                        final newName = renameController.text.trim();
                        if (newName.isNotEmpty) {
                          await controller.renameList(listId, newName);
                        }
                        Get.back();
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("Delete List"),
            onTap: () async {
              Get.back();
              await controller.deleteList(listId, name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text("Mark as Completed"),
            onTap: () async {
              Get.back();
              await controller.markCompleted(listId, name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text("Invite Member"),
            onTap: () {
              Get.back();
              _showInviteDialog(context, listId);
            },
          ),
        ],
      ),
    );
  }

  void _showInviteDialog(BuildContext context, String listId) {
    final TextEditingController emailController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text("Invite Member"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: "Enter member's email"),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                await controller.inviteMember(listId, email);
                Get.back();
              }
            },
            child: const Text("Invite"),
          ),
        ],
      ),
    );
  }
}
