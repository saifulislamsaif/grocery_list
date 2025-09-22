import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/AuthController.dart';
import 'SignUp.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _buildBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Login"),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget _buildBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/login_bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEmailField(),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 20),
        _buildErrorText(),
        const SizedBox(height: 10),
        _buildLoginButton(),
        const SizedBox(height: 12),
        _buildSignUpLink(),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Email",
        prefixIcon: const Icon(Icons.email
        ,size: 16,),

        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }


  Widget _buildPasswordField() {
    return Obx(
          () => TextField(
        controller: passwordController,
        obscureText: !showPassword.value,
        decoration: InputDecoration(
          labelText: "Password",
          prefixIcon: const Icon(Icons.lock,size: 16,),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 10,
            minHeight: 10,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              size: 16,
              showPassword.value ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () => showPassword.value = !showPassword.value,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }


  Widget _buildErrorText() {
    return Obx(
          () => authController.errorMessage.isNotEmpty
          ? Text(
        authController.errorMessage.value,
        style: const TextStyle(color: Colors.red),
      )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
          () => ElevatedButton(
        onPressed: authController.isLoading.value ? null : handleLogin,
        style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xc7b8ff00),
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
    );
  }

  Widget _buildSignUpLink() {
    return TextButton(
      onPressed: () => Get.to(() => SignUpPage()),
      child: const Text("Don't have an account? Sign Up"),
    );
  }
}