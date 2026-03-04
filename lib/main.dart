import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'app/modules/signup/controllers/AuthController.dart';
import 'app/modules/signup/views/LoginPage.dart';
import 'app/modules/home/views/home_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shared Grocery List',
      home:  Root(),
    );
  }
}


class Root extends StatelessWidget {
   Root({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    return Obx(() {
      if (authController.user != null) {
        return  HomePage();
      } else {
        return  LoginPage();
      }
    });
  }
}
