
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/AuthController.dart';
import '../../invitation/views/invitation_view.dart';
import '../controllers/home_controller.dart';
import 'list_details_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController controller = Get.put(HomeController());
  final AuthController authController = Get.find();
  final HomeController navController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = navController.selectedIndex.value;
      return Scaffold(
        backgroundColor: Colors.green[50],
        appBar: AppBar(
          titleSpacing: 0,
          backgroundColor: Colors.green[50],
          leadingWidth: 60,          leading: Obx(() {
          final name = controller.userName.value.trim();
          final user = name.isNotEmpty ? name.toUpperCase() : '?';
          return Padding(
            padding: const EdgeInsets.all(0.0),
            child: GestureDetector(
              onTap: () {
                _showEditNameDialog(context);
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                child: Text(
                  user,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
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
        body: IndexedStack(
          index: index,
          children: [
            _buildHomeContent(context),
            const SizedBox(),
            _buildStatusPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.green[100],
          elevation: 50,
          currentIndex: index,
          onTap: (i) {
            if (i == 1) {
              _showCreateListDialog(context);
            } else {
              navController.changeTab(i);
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box),
              label: 'Add List',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle),
              label: 'Status',
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHomeContent(BuildContext context) {
    return Obx(() {
      if (controller.lists.isEmpty) {
        return const Center(child: Text("No grocery lists yet"));
      }
      return Column(
        children: [
          _overviewCard(context),
          Expanded(child: _listsView(context)),
        ],
      );
    });
  }

  Widget _overviewCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Colors.grey, Colors.grey]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Overview",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  "Completed: ${controller.completedCount.value} | Uncompleted: ${controller.incompleteCount.value}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => LinearProgressIndicator(
                  value: controller.progress,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listsView(BuildContext context) {
    return ListView.builder(
      itemCount: controller.lists.length,
      itemBuilder: (context, index) {
        final doc = controller.lists[index];
        final data = doc.data() as Map<String, dynamic>;
        final name = data["name"] ?? "Unnamed List";
        final itemsCount = data["itemsCount"] ?? 0;
        final purchasedCount = data["purchasedCount"] ?? 0;
        final percent = itemsCount == 0 ? 0.0 : purchasedCount / itemsCount;

        return Card(
          color: Colors.grey[600],
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Get.to(() => ListDetailsPage(listId: doc.id, listName: name));
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
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$purchasedCount of $itemsCount items purchased",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 6,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusPage() {
    return Obx(() {
      // completed ও incomplete আলাদা লিস্ট
      final completedLists = controller.lists
          .where(
            (doc) => (doc.data() as Map<String, dynamic>)['completed'] == true,
          )
          .toList();

      final incompleteLists = controller.lists
          .where(
            (doc) => (doc.data() as Map<String, dynamic>)['completed'] != true,
          )
          .toList();

      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            "Uncompleted (${incompleteLists.length})",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (incompleteLists.isEmpty) const Text("No Uncompleted lists"),
          ...incompleteLists.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data["name"] ?? "Unnamed List";
            return Card(
              color: Colors.red[100],
              child: ListTile(
                title: Text(name),
                trailing: const Icon(Icons.close, color: Colors.red),
                onTap: () {
                  Get.to(() => ListDetailsPage(listId: doc.id, listName: name));
                },
              ),
            );
          }),
          const SizedBox(height: 24),
          Text(
            "Completed (${completedLists.length})",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (completedLists.isEmpty) const Text("No completed lists"),
          ...completedLists.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data["name"] ?? "Unnamed List";
            return Card(
              color: Colors.green[100],
              child: ListTile(
                title: Text(name),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
                onTap: () {
                  Get.to(() => ListDetailsPage(listId: doc.id, listName: name));
                },
              ),
            );
          }),
        ],
      );
    });
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
    final TextEditingController controllerText = TextEditingController(
      text: controller.userName.value,
    );
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
              Get.snackbar(
                "Updated",
                "Name updated successfully",
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showOwnerActions(BuildContext context, String listId, String name) {
    Get.bottomSheet(
      backgroundColor: Colors.grey[50],
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
                    decoration: const InputDecoration(
                      hintText: "Enter new list name",
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        final newName = renameController.text.trim();
                        if (newName.isNotEmpty) {
                          Get.back();
                          await controller.renameList(listId, newName);
                        }
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
