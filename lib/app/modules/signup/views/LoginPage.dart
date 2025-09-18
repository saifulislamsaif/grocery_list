import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/AuthController.dart';
import 'SignUp.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final RxBool showPassword = false.obs;

    void handleLogin() {
      final email = emailController.text.trim();
      final pass = passwordController.text.trim();
      if (email.isEmpty || pass.isEmpty) {
        authController.errorMessage.value = "Email এবং Password দিন";
        return;
      }
      authController.login(email, pass);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),

            Obx(
              () => TextField(
                controller: passwordController,
                obscureText: !showPassword.value,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => showPassword.value = !showPassword.value,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Error text
            Obx(
              () => authController.errorMessage.isNotEmpty
                  ? Text(
                      authController.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                    )
                  : const SizedBox(),
            ),

            const SizedBox(height: 10),

            Obx(
              () => ElevatedButton(
                onPressed: authController.isLoading.value ? null : handleLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: authController.isLoading.value
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Login"),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Get.to(() => SignUpPage()),
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
