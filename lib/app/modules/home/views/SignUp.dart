import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grocerry_list/app/modules/home/views/home_page.dart';
import '../../../controller/AuthController.dart';


class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final AuthController authController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.green[50],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authController.signUp(
                  nameController.text,
                  emailController.text,
                  passwordController.text,
                );
                Get.offAll(
                  () =>  HomePage(),
                ); // Sign up done → redirect to login
              },
              child: const Text("Sign Up"),
            ),

            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
