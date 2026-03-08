import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/AuthController.dart';
import 'SignUp.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool showPassword = false.obs;
  final AuthController authController = Get.put(AuthController());

  void handleLogin() {
    authController.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
          
                  /// LOGO
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xff2F7D57),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
          
                  const SizedBox(height: 20),
          
                  /// APP NAME
                  const Text(
                    "Grocerly",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          
                  const SizedBox(height: 6),
          
                  const Text(
                    "Welcome back",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
          
                  const SizedBox(height: 40),
          
                  /// EMAIL FIELD
                  _buildInputField(
                    controller: emailController,
                    hint: "Email",
                  ),
          
                  const SizedBox(height: 16),
          
                  /// PASSWORD FIELD
                  Obx(
                        () => _buildInputField(
                      controller: passwordController,
                      hint: "Password",
                      obscureText: !showPassword.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          showPassword.value = !showPassword.value;
                        },
                      ),
                    ),
                  ),
          
                  const SizedBox(height: 20),
          
                  /// ERROR MESSAGE
                  Obx(() => authController.errorMessage.isNotEmpty
                      ? Text(
                    authController.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  )
                      : const SizedBox()),
          
                  const SizedBox(height: 20),
          
                  /// SIGN IN BUTTON
                  Obx(
                        () => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                        authController.isLoading.value ? null : handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2F7D57),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
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
                            : const Text(
                          "Sign In",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
          
                  const SizedBox(height: 20),
          
                  /// SIGN UP TEXT
                  TextButton(
                    onPressed: () => Get.to(() => SignUpPage()),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              color: Color(0xff2F7D57),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
