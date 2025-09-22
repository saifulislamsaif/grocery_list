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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text(
                      "Create Account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xf0131212), // change color to match your design
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text("Sign up",style:  TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Color(
                      0x980d50da))),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: nameController,
                    prefixIcon: Icons.person,
                    label: "Full Name",
                    hint: "Enter your full name",
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: emailController,
                    prefixIcon: Icons.email,
                    label: "Email",
                    hint: "Enter your email",
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: passwordController,
                    prefixIcon: Icons.lock,
                    label: "Password",
                    hint: "Enter your password",
                    obscureText: true,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: handleSignUp,

                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: const Color(0x980d47bf),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text("Sign Up",style: TextStyle(color: Colors.white),),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.black,       // default color for the whole sentence
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Login",
                            style: TextStyle(
                              color: Colors.blueAccent,    // grey only for the word "Login"
                              fontWeight: FontWeight.w500,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData prefixIcon,
    required String label,
    String? hint,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 8),
            Icon(prefixIcon, size: 12, color: Colors.grey,),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.grey,      // Grey stroke when not focused
                width: 1.2,              // Adjust thickness if you like
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.grey,      // Grey stroke when focused
                width: 1.5,
              ),
            ),
            // Optional: border property as a fallback
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }



}


