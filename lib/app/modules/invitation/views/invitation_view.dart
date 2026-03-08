import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../home/controllers/home_controller.dart';
import '../../signup/controllers/AuthController.dart';

class InvitePage extends StatelessWidget {
  final HomeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invitations"),
      ),
      body: Obx(() {

        if (controller.invites.isEmpty) {
          return const Center(
            child: Text("No invites"),
          );
        }

        return ListView.builder(
          itemCount: controller.invites.length,
          itemBuilder: (context, index) {

            final doc = controller.invites[index];
            final data = doc.data() as Map<String, dynamic>;

            final listName = data["listName"];
            final listId = data["listId"];

            return Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                title: Text(listName),
                subtitle: const Text("Shared grocery list"),
                trailing: ElevatedButton(
                  onPressed: () {
                    controller.acceptInvite(doc.id, listId);
                  },
                  child: const Text("Accept"),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
