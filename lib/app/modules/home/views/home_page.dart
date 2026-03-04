import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../signup/controllers/AuthController.dart';
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F6F2),
          // Matches the off-white background
          elevation: 0,
          leadingWidth: 200,
          // Increased to fit the logo and text comfortably
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                // Rounded Square Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007953), // Deep green from image
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    height: 20,
                    width: 20,
                    'assets/images/leaf_rounded.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                // App Title
                const Text(
                  'Grocerly',
                  style: TextStyle(
                    color: Color(0xFF1B2E28),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    // Extra bold to match the image
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  _showCreateListBottomSheet(context);
                },
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text(
                  "New List",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007953), // Deep green
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
        body: IndexedStack(
          index: index,
          children: [
            _buildHomeContent(context),
            SizedBox(),
            _buildStatusPage(),
          ],
        ),
      );
    });
  }
  void _showCreateListBottomSheet(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

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
                "Create New List",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 20),

            /// List Name Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "List name (e.g. Weekly Groceries)",
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF007953)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Create Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007953),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  final name = nameController.text.trim();

                  if (name.isEmpty) {
                    Get.snackbar(
                      "Error",
                      "Please enter a list name",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  await controller.createList(name);

                  Get.back(); // Close sheet

                  Get.snackbar(
                    "Success",
                    "List created successfully",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: const Text(
                  "Create List",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _historyView(BuildContext context) {
    final completedLists = controller.lists
        .where(
          (doc) => (doc.data() as Map<String, dynamic>)['completed'] == true,
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "RECENT ACTIVITY",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4F2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              _activityTile(
                icon: Icons.check,
                text: "You completed Cherry Tomatoes",
                time: "2 days ago",
              ),
              _activityTile(
                icon: Icons.add,
                text: "Emma added Sparkling Water",
                time: "4 days ago",
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        /// PAST LISTS TITLE
        const Text(
          "PAST LISTS",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 12),

        ...completedLists.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data["name"] ?? "Unnamed List";
          final itemsCount = data["itemsCount"] ?? 0;
          final purchasedCount = data["purchasedCount"] ?? 0;

          final percent = itemsCount == 0 ? 0.0 : purchasedCount / itemsCount;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE9E2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Archived",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E6F55),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  "$purchasedCount of $itemsCount items",
                  style: const TextStyle(fontSize: 13),
                ),

                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2E6F55),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("2 people", style: TextStyle(fontSize: 13)),
                    Row(
                      children: [
                        Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.green,
                        ),
                        SizedBox(width:10),
                        Text(
                          "Done",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2E6F55),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return Obx(() {
      if (controller.lists.isEmpty) {
        return Center(child: Text("No grocery lists yet"));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OrderToggleSwitch(),
          ),
          Expanded(
            child: controller.showActive.value
                ? _listsView(context) // ACTIVE
                : _historyView(context), // HISTORY
          ),
        ],
      );
    });
  }

  Widget _listsView(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.lists.length,
      itemBuilder: (context, index) {
        final doc = controller.lists[index];
        final data = doc.data() as Map<String, dynamic>;

        final name = data["name"] ?? "Unnamed List";
        final itemsCount = data["itemsCount"] ?? 0;
        final purchasedCount = data["purchasedCount"] ?? 0;

        final percent = itemsCount == 0 ? 0.0 : purchasedCount / itemsCount;

        return GestureDetector(
          onTap: () {
            Get.to(() => ListDetailsPage(listId: doc.id, listName: name));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE9E2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Color(0xFF2E6F55),
                      ),
                    ),
                     SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Mar 3",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// Progress Text Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$purchasedCount of $itemsCount items",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "${(percent * 100).toInt()}%",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                 SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2E6F55),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(
                      Icons.group_outlined,
                      size: 16,
                      color: Colors.black54,
                    ),

                    const SizedBox(width: 8),

                    _memberAvatar("S"),
                    const SizedBox(width: 6),
                    _memberAvatar("M"),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _memberAvatar(String letter) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: const Color(0xFFDCE9E2),
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E6F55),
        ),
      ),
    );
  }

  Widget _buildStatusPage() {
    return Obx(() {
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
        padding: EdgeInsets.all(12),
        children: [
          Text(
            "Uncompleted (${incompleteLists.length})",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          if (incompleteLists.isEmpty) Text("No Uncompleted lists"),
          ...incompleteLists.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data["name"] ?? "Unnamed List";
            return Card(
              color: Colors.red[100],
              child: ListTile(
                title: Text(name),
                trailing: Icon(Icons.close, color: Colors.red),
                onTap: () {
                  Get.to(() => ListDetailsPage(listId: doc.id, listName: name));
                },
              ),
            );
          }),
          SizedBox(height: 24),
          Text(
            "Completed (${completedLists.length})",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          if (completedLists.isEmpty) Text("No completed lists"),
          ...completedLists.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data["name"] ?? "Unnamed List";
            return Card(
              color: Colors.white,
              child: ListTile(
                title: Text(name),
                trailing: Icon(Icons.check_circle, color: Colors.green),
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

  Widget _activityTile({
    required IconData icon,
    required String text,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFDCE9E2),
            child: Icon(icon, size: 16, color: Color(0xFF2E6F55)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderToggleSwitch extends StatelessWidget {
  final HomeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final showActive = controller.showActive.value;

      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F6F2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTab(
              label: "Active",
              icon: Icons.shopping_cart_outlined,
              isSelected: showActive,
              onTap: () => controller.showActive.value = true,
            ),
            const SizedBox(width: 8),
            _buildTab(
              label: "History",
              icon: Icons.history,
              isSelected: !showActive,
              onTap: () => controller.showActive.value = false,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFF1B2E28)
                  : const Color(0xFF7A8D86),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF1B2E28)
                    : const Color(0xFF7A8D86),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
