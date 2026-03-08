import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grocerry_list/app/modules/home/views/home_page.dart';
import '../controllers/AuthController.dart';


class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final AuthController authController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void handleSignUp() async {
    await authController.signUp(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    Get.offAll(() => HomePage());
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
          
                  /// TITLE
                  const Text(
                    "Grocerly",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          
                  const SizedBox(height: 6),
          
                  /// SUBTITLE
                  const Text(
                    "Create your account",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
          
                  const SizedBox(height: 40),
          
                  /// NAME FIELD
                  _buildInputField(
                    controller: nameController,
                    hint: "Display name",
                  ),
          
                  const SizedBox(height: 16),
          
                  /// EMAIL FIELD
                  _buildInputField(
                    controller: emailController,
                    hint: "Email",
                  ),
          
                  const SizedBox(height: 16),
          
                  /// PASSWORD FIELD
                  _buildInputField(
                    controller: passwordController,
                    hint: "Password",
                    obscureText: true,
                  ),
          
                  const SizedBox(height: 24),
          
                  /// SIGN UP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2F7D57),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
          
                  const SizedBox(height: 20),
          
                  /// LOGIN TEXT
                  TextButton(
                    onPressed: () => Get.back(),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Sign In",
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
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
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


